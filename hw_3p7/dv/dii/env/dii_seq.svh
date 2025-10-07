`ifndef <%=obj.BlockId%>_SEQ
`define <%=obj.BlockId%>_SEQ


typedef uvm_sequence #(uvm_sequence_item) uvm_virtual_sequence;


////////////////////////////////////////////////////////////////////////////////
//
// DII Master Sequence
//
////////////////////////////////////////////////////////////////////////////////
class dii_seq extends uvm_sequence;

    `uvm_object_param_utils(dii_seq);
    `uvm_declare_p_sequencer(smi_virtual_sequencer);

    static uvm_event_pool ev_pool = uvm_event_pool::get_global_pool();
    static uvm_event ev            = ev_pool.get("ev_<%=obj.DiiInfo[obj.Id].strRtlNamePrefix%>_ev");

    uvm_event        ev_N_cycles = ev_pool.get("ev_<%=obj.DiiInfo[obj.Id].strRtlNamePrefix%>_N_cycles");

    //knobs for this component
    const int            m_weights_for_k_num_cmd[2] = {95, 5};
<% if(obj.testBench == 'dii' || (obj.testBench == "fsys")) { %>
`ifdef VCS
    `define VCSorCDNS
   `elsif CDNS
    `define VCSorCDNS
   `endif 
<% }  %>
<% if(obj.testBench == 'dii') { %>
`ifdef VCSorCDNS
    const t_minmax_range m_minmax_for_k_num_cmd[2]  = '{'{m_min_range:1500,m_max_range:3000}, '{m_min_range:50000,m_max_range:50000}};
`else // `ifdef VCSorCDNS
    const t_minmax_range m_minmax_for_k_num_cmd[2]  = {{1500,3000},{50000,50000}};
`endif // `ifdef VCSorCDNS ... `else ...
<% } else {%>
    const t_minmax_range m_minmax_for_k_num_cmd[2]  = {{1500,3000},{50000,50000}};
<% } %>
    
    common_knob_class k_num_cmd  = new ("k_num_cmd", this, m_weights_for_k_num_cmd, m_minmax_for_k_num_cmd);
   
    common_knob_class wt_cmd_rd_nc      = new ("wt_cmd_rd_nc"      , this , m_weights_for_weight_knobs , m_minmax_for_weight_knobs);
    common_knob_class wt_cmd_wr_nc_ptl  = new ("wt_cmd_wr_nc_ptl"  , this , m_weights_for_weight_knobs , m_minmax_for_weight_knobs);
    common_knob_class wt_cmd_wr_nc_full = new ("wt_cmd_wr_nc_full" , this , m_weights_for_weight_knobs , m_minmax_for_weight_knobs);
    common_knob_class wt_cmd_cmo        = new ("wt_cmd_cmo"        , this , m_weights_for_weight_knobs , m_minmax_for_weight_knobs);

    common_knob_class wt_order_none     = new ("wt_order_none"     , this , m_weights_for_weight_knobs , m_minmax_for_weight_knobs);
    common_knob_class wt_order_write    = new ("wt_order_write"    , this , m_weights_for_weight_knobs , m_minmax_for_weight_knobs);
    common_knob_class wt_order_request  = new ("wt_order_request"  , this , m_weights_for_weight_knobs , m_minmax_for_weight_knobs);
    common_knob_class wt_order_endpoint = new ("wt_order_endpoint" , this , m_weights_for_weight_knobs , m_minmax_for_weight_knobs);

    common_knob_class wt_reuse_addr     = new ("wt_reuse_addr"     , this , m_weights_for_weight_knobs , m_minmax_for_weight_knobs);
    
    common_knob_class wt_dbad           = new ("wt_dbad"           , this , m_weights_const            , m_minmax_const_0         );
    common_knob_class k_alternate_be    = new ("k_alternate_be"    , this , m_weights_const            , m_minmax_const_0         );

    common_knob_class k_32b_cmdset      = new ("k_32b_cmdset"      , this , m_weights_const            , m_minmax_const_0         );
    common_knob_class k_64b_cmdset      = new ("k_64b_cmdset"      , this , m_weights_const            , m_minmax_const_0         );
    common_knob_class k_cov_directed_test      = new ("k_cov_directed_test"      , this , m_weights_const            , m_minmax_const_0         );
    
    common_knob_class wt_wrong_dut_id_cmd    = new ("wt_wrong_dut_id_cmd"    , this , m_weights_const , m_minmax_const_0         );
    common_knob_class wt_wrong_dut_id_strrsp = new ("wt_wrong_dut_id_strrsp" , this , m_weights_const , m_minmax_const_0         );
    common_knob_class wt_wrong_dut_id_dtw    = new ("wt_wrong_dut_id_dtw"    , this , m_weights_const , m_minmax_const_0         );
    common_knob_class wt_wrong_dut_id_dtrrsp = new ("wt_wrong_dut_id_dtrrsp" , this , m_weights_const , m_minmax_const_0         );
    common_knob_class wt_wrong_dut_id_dtwdbgrsp = new ("wt_wrong_dut_id_dtwdbgrsp" , this , m_weights_const , m_minmax_const_0         );

    //weight of exclusive CMD 
    common_knob_class wt_cmd_exclusive      = new ("wt_cmd_exclusive"      , this , m_weights_for_weight_knobs , m_minmax_for_weight_knobs);
    common_knob_class wt_exclusive_sequence      = new ("wt_exclusive_sequence"      , this , m_weights_for_weight_knobs , m_minmax_for_weight_knobs);

    const int            m_weights_for_k_dii_tm_weight[4] = {10, 10, 10, 70};
<% if(obj.testBench == 'dii') { %>
`ifdef VCSorCDNS
    const t_minmax_range m_minmax_for_k_dii_tm_weight[4]  =  '{'{m_min_range:0,m_max_range:0},'{m_min_range:50,m_max_range:50},'{m_min_range:100,m_max_range:100},'{m_min_range:0,m_max_range:100}};
`else // `ifdef VCSorCDNS
    const t_minmax_range m_minmax_for_k_dii_tm_weight[4]  = {{0,0},{50,50},{100,100},{0,100}};
`endif // `ifdef VCSorCDNS ... `else ...
<% } else {%>
    const t_minmax_range m_minmax_for_k_dii_tm_weight[4]  = {{0,0},{50,50},{100,100},{0,100}};
<% } %>
    
    common_knob_class k_dii_tm_weight  = new ("k_dii_tm_weight", this, m_weights_for_k_dii_tm_weight, m_minmax_for_k_dii_tm_weight);
    int k_dii_tm_weight_value;
    int overflow_buffer = 0;
    int new_scenario_var = 0;
    int read_cmd = 0; 
    int read_cmo_cmd = 0;
    int write_cmd =0;
    int overflow_buffer_test;
    int new_scenario;
    int introduce_cmdreq_delay;
    int read_after_read_scenario;
    int write_after_write_scenario;
    int read_after_read_scenario_var = 0;
    int overflow_buffer_test_2;
    int delay_time; 


    //system params
    int  nAius;
    const int    dut_ncore_unit_id = <%=obj.DiiInfo[obj.Id].FUnitId%>;
    const int    dii_nunit_id = <%=obj.DiiInfo[obj.Id].nUnitId%>;
    int unsigned seq_txn_id = 0; 
    bit enabled_32b_align_err = $test$plusargs("32b_align_err"); 
    bit stress_single_addr_enabled = $test$plusargs("stress_single_addr");
    bit performance_bw_test_enabled = $test$plusargs("performance_bw_test");
    bit request_32b_enabled = $test$plusargs("request_32b");

    //format conversion shim
    //TODO deprecate for smi_types, FIX nccmdrsp in jsons
   <% if(obj.testBench == 'dii') { %>
   `ifndef CDNS
    const eConcMsgClass str2class[string] = {
   `else // `ifndef CDNS
    const eConcMsgClass str2class[string] = '{
   `endif // `ifndef CDNS
   <% } else {%>
    const eConcMsgClass str2class[string] = {
   <% } %>
        "cmd_req_"    :   eConcMsgCmdReq ,
        "cmd_rsp_"    :   eConcMsgNcCmdRsp ,
        
        "str_req_"    :   eConcMsgStrReq ,
        "str_rsp_"    :   eConcMsgStrRsp ,
        
        "dtr_req_"    :   eConcMsgDtrReq ,
        "dtr_rsp_"    :   eConcMsgDtrRsp ,

        "dtw_req_"    :   eConcMsgDtwReq ,
        "dtw_rsp_"    :   eConcMsgDtwRsp ,

        "dtw_dbg_req_":   eConcMsgDtwDbgReq,
        "dtw_dbg_rsp_":   eConcMsgDtwDbgRsp,
        "sys_req_tx_"    :   eConcMsgSysReq   ,
        "sys_rsp_rx_"    :   eConcMsgSysRsp      


    } ;



    smi_seq          smi_seqs[eConcMsgClass];
    smi_sequencer    smi_seqrs[eConcMsgClass];
    
    addr_trans_mgr addr_mgr ;

    dii_exclusive_c  exclusive_q[$];
    dii_exclusive_c  load_exclusive_q[$];
  
<% if(obj.testBench == 'dii' || (obj.testBench == "fsys")) { %>
`ifdef VCSorCDNS
    uvm_event            e_msg_complete[string];
    eConcMsgClass h_eConcMsgClass;
`else // `ifndef VCS
    event            e_msg_complete[eConcMsgClass];
`endif // `ifndef VCS ... `else ...
<% } else {%>
    event            e_msg_complete[eConcMsgClass];
<% } %>

    semaphore        s_msgid[eConcMsgClass];
    semaphore        s_sending[eConcMsgClass];
    semaphore        s_txn; //big hammer synchronization for manipulation of non-threadsafe txn.  no perf penalty for serializing txn ops within 0 timesteps.
   
    //data store
    dii_txn_q        statemachine_q; 

    // dtr_rsp, str_rsp queues to generate out of order and delayed transmissions
    smi_seq_item     dtr_rsp_msg_q[$];
    smi_seq_item     str_rsp_msg_q[$];   
   
    // dtw_dbg_rsp queues to add delays
    smi_seq_item     dtw_dbg_rsp_msg_q[$];
    smi_addr_t       dii_addr_q[$];

    // sys_rsp_q queues
    smi_seq_item     sys_rsp_msg_q[$];
    int              sys_rsp_msg_wait_cycles;  
    int              sys_rsp_msg_q_time_limit;
    int              sys_ev_prot_timeout_val;
   // dtw_req queues to generate out of order regarding str_req
    smi_seq_item     dtw_req_msg_q[$];
   
    int              dtw_req_msg_wait_cycles;
    int              dtr_rsp_msg_wait_cycles;
    int              str_rsp_msg_wait_cycles;
    int              dtw_dbg_rsp_msg_wait_cycles;

    int              wait_cycle_step;
    int              dtw_req_msg_q_size_limit;   // DTR_RSP will wait until q size is reached
    int              dtw_req_msg_q_time_limit;
    int              dtr_rsp_msg_q_size_limit;   // DTR_RSP will wait until q size is reached
    int              dtr_rsp_msg_q_time_limit;   // OR DTR_RSP will wait until size limit is reached
    int              str_rsp_msg_q_size_limit;   // STR_RSP will wait until q size is reached
    int              str_rsp_msg_q_time_limit;   // OR STR_RSP will wait until size limit is reached
    
    int              cmd_spacing;  // minimum cycles between commands
    bit              cmd_throttle_en;
    bit              cmd_ceil_hit;
    int              cmd_throttle_ceil;       // issue up to this size and wait for all commands are done

    smi_seq_item     rq_or_ep_order[*];       // keep track such that there is at most 1 pending for <funit_id,axiid>
   
    bit                 pcie_test;
    bit [WSMIMPF2-2:0]  posted_axid;
    bit [WSMISRCID-1:0] pcie_aiuid;
    <% if(obj.testBench == 'dii' || (obj.testBench == "fsys")) { %>
    `ifdef VCS
     bit inside_fork_join_none_vcs;    
    `endif 
   <% } %>
   
//////////////////////////////////////////////////////////////////////////////////
// Init functions
//////////////////////////////////////////////////////////////////////////////////


   function new(string name = "dii_seq");
      int   spacing_value;

      super.new(name);
      
      addr_mgr = addr_trans_mgr::get_instance();    //singleton class constructed in base test
      
      statemachine_q = new(name);
      foreach (statemachine_q.txn_q[i])
      statemachine_q.txn_q.delete(i);
      if ($value$plusargs("cmd_spacing=%d", spacing_value)) begin
         cmd_spacing = spacing_value;
      end else begin
         cmd_spacing = 0;
      end

      if(!$value$plusargs("overflow_buffer_test=%d", overflow_buffer_test))begin //vyshak
        overflow_buffer_test = 0;
      end
      if(!$value$plusargs("delay_time=%d",delay_time))begin 
        delay_time = 0;
      end 
      if(!$value$plusargs("introduce_cmdreq_delay=%d",introduce_cmdreq_delay))begin
        introduce_cmdreq_delay = 0;
      end
      if(!$value$plusargs("new_scenario=%d", new_scenario))begin
        new_scenario = 0;
      end
      if(!$value$plusargs("read_after_read_scenario=%d", read_after_read_scenario))begin
        read_after_read_scenario = 0; 
      end 
      if(!$value$plusargs("write_after_write_scenario=%d", write_after_write_scenario))begin
        write_after_write_scenario = 0; 
      end 
       if(!$value$plusargs("overflow_buffer_test_2=%d", overflow_buffer_test_2))begin 
        overflow_buffer_test_2 = 0;
      end

      if ($test$plusargs("pcie_test")) begin
         assert(std::randomize(posted_axid));
         assert(std::randomize(pcie_aiuid));
         pcie_test = 1;
      end else begin
         pcie_test = 0;
      end

      if (! $value$plusargs("set_nAius=%d", nAius)) begin
         nAius = <%=obj.DveInfo[0].nAius%>;
      end

      cmd_throttle_en  =  $test$plusargs("cmd_throttle");
      cmd_ceil_hit     =  0;
      if (! $value$plusargs("cmd_throttle_init=%d", cmd_throttle_ceil)) begin
         cmd_throttle_ceil = 1;
      end
      
      // scoreboard should have checked the correctness of tm==0
      // all requests with tm==0 breaks error testing. So > 0
      k_dii_tm_weight_value = k_dii_tm_weight.get_value() + 1;
<% if(obj.testBench == 'dii') { %>
`ifdef VCSorCDNS
     h_eConcMsgClass = h_eConcMsgClass.first;
     e_msg_complete[h_eConcMsgClass.name] = ev_pool.get(h_eConcMsgClass.name);
     for(int i=0; i<h_eConcMsgClass.num()-1; i++) begin
       h_eConcMsgClass = h_eConcMsgClass.next;
       e_msg_complete[h_eConcMsgClass.name] = ev_pool.get(h_eConcMsgClass.name);
     end
`endif // `ifdef VCSorCDNS
<% } %>

   endfunction : new


    ///////////////////////////////////////////////////////////////////////////////
    // Manipulate Unused SMI Msg ID
    ///////////////////////////////////////////////////////////////////////////////

    //precondition: aiuid, msg class.
   task gen_msg_id(smi_seq_item msg);
      
        dii_txn outstanding_txns[$];
        smi_msg_id_t excluded_ids[$];

        <% if(obj.testBench == 'dii') { %>
           `ifdef CDNS
            int    smi_msg_id_cdns;
           `endif 
        <% }  %>
        while(1) begin : get_used_ids  //condition is internal
	    `uvm_info($sformatf("%m"), $sformatf("Get UsedId for msg: %p", msg), UVM_HIGH)
            s_msgid[msg.smi_conc_msg_class].get(1);   //critical region

            outstanding_txns = statemachine_q.txn_q.find with (item.isOutstanding(msg.smi_conc_msg_class)) ;

            outstanding_txns = outstanding_txns.find with (item.smi_recd[msg.smi_conc_msg_class].smi_src_ncore_unit_id == msg.smi_src_ncore_unit_id) ;  //must know that msg is present before can check its srcid.
	   
            //if available ids, continue
            if (num_smi_msg_id[msg.smi_conc_msg_class] > 0 ) begin
               if ( 
                   ( //if limited by credits 
                       outstanding_txns.size() < num_smi_msg_id[msg.smi_conc_msg_class]
                   )
                   && ( outstanding_txns.size() < (2**WSMIMSGID) )   //no msg may exceed state space of msgid
               ) begin
                   smi_msg_id_t msg_id;
                  
                   //format excludes for...
                   for (int i=0 ; i< outstanding_txns.size(); i++)
                       excluded_ids[i] = outstanding_txns[i].smi_recd[msg.smi_conc_msg_class].smi_msg_id;

                   //weird use of concatenation.  meets constraint iff after randomization, {msg.smi_msg_id, excluded_ids} contains only unique vals.
                   //if (! std::randomize(msg_id) with { unique {msg_id, excluded_ids}; }) begin
                   if (! std::randomize(msg_id) with { foreach (excluded_ids[i]) msg_id != excluded_ids[i]; }) begin
                       foreach (excluded_ids[i]) begin
                          `uvm_info($sformatf("%m"), $sformatf("%0d smi_msg_ids in use. Outstanding TXN=%p",
                                                               excluded_ids.size(), outstanding_txns.size()), UVM_NONE)
                          `uvm_info($sformatf("%m"), $sformatf("Pending smi_msg_ids=%p", excluded_ids[i]), UVM_NONE)
                       end
                      `uvm_error($sformatf("%m"), $sformatf("Not able to find smi_msg_id for %p", msg.smi_conc_msg_class))
                   end
                   msg.smi_msg_id = msg_id;
                   s_msgid[msg.smi_conc_msg_class].put(1);   //critical region  
                   return;

               end else begin
                   s_msgid[msg.smi_conc_msg_class].put(1);   //critical region  
                   `uvm_info($sformatf("%m"), $sformatf("UNIQ SMI_ID: all ID's used up (msg_type=%p outstanding=%0d credits=%0d). Need to wait",
                                                         msg.smi_conc_msg_class, outstanding_txns.size(), num_smi_msg_id[msg.smi_conc_msg_class]), UVM_LOW)
<% if(obj.testBench == 'dii') { %>
              `ifdef VCSorCDNS
                   e_msg_complete[msg.smi_conc_msg_class.name].wait_trigger();
              `else // `ifndef VCSorCDNS
                   @e_msg_complete[msg.smi_conc_msg_class];   //wait for free id
              `endif // `ifdef VCSorCDNS ... `else ...
              <% } else {%>
                   @e_msg_complete[msg.smi_conc_msg_class];   //wait for free id
<% } %>
               end
            end else begin
           <% if(obj.testBench == 'dii') { %>
           `ifndef CDNS
               void'(std::randomize(msg.smi_msg_id));
           `else // `ifndef CDNS
               void'(std::randomize(smi_msg_id_cdns));
               msg.smi_msg_id=smi_msg_id_cdns;
           `endif // `ifndef CDNS ... `else ...
           <% } else {%>
               void'(std::randomize(msg.smi_msg_id));
           <% } %>
               s_msgid[msg.smi_conc_msg_class].put(1);   //critical region  
               `uvm_info($sformatf("%m"), $sformatf("msg_type=%p does not have msg_id uniqness requirements", msg.smi_conc_msg_class), UVM_DEBUG)
               return;
            end
        end : get_used_ids

   endtask : gen_msg_id

   task throttle_cmd_issue(input smi_seq_item msg);
      dii_txn outstanding_txns[$];
      bit     issue_stall;
      
      if (cmd_throttle_en) begin
         issue_stall = 1;
         while (issue_stall == 1) begin : STALL_CHECK
            s_txn.get(1);
            outstanding_txns = statemachine_q.txn_q.find with (item.isOutstanding(msg.smi_conc_msg_class));
            if ((cmd_ceil_hit == 0) && (outstanding_txns.size() < cmd_throttle_ceil)) begin
               `uvm_info($sformatf("%m"), $sformatf("CMD_THROTTLE: ISSUE: pending=%0d, ceil=%0d, cmd_type:p", outstanding_txns.size(), cmd_throttle_ceil, msg.smi_msg_type), UVM_HIGH)
               issue_stall = 0;
               if (outstanding_txns.size() == (cmd_throttle_ceil -1)) begin
                  cmd_ceil_hit = 1;
                  `uvm_info($sformatf("%m"), $sformatf("CMD_THROTTLE: CEIL HIT  pending=%0d, ceil=%0d, cmd_type:p", outstanding_txns.size(), cmd_throttle_ceil, msg.smi_msg_type), UVM_HIGH)
               end
               s_txn.put(1);
            end else begin
               `uvm_info($sformatf("%m"), $sformatf("CMD_THROTTLE: STALL: pending=%0d, ceil=%0d, cmd_type:p", outstanding_txns.size(), cmd_throttle_ceil, msg.smi_msg_type), UVM_HIGH)
               issue_stall = 1;
               s_txn.put(1);
<% if(obj.testBench == 'dii') { %>
           `ifdef VCSorCDNS
               e_msg_complete[msg.smi_conc_msg_class.name].wait_trigger();
           `else // `ifdef VCSorCDNS
               @e_msg_complete[msg.smi_conc_msg_class];
           `endif // `ifdef VCSorCDNS ... `else ...
           <% } else {%>
               @e_msg_complete[msg.smi_conc_msg_class];
<% } %>
            end
         end // block: STALL_CHECK
      end // if (cmd_throttle_en)
            
   endtask : throttle_cmd_issue
   
   function tryRetire(dii_txn txn, smi_seq_item  msg);
        bit     retired;
        dii_txn outstanding_txns[$];
      
        retired = statemachine_q.tryRetireTxn(txn, 0);

        //retrigger msgid generator
        if ( (! txn.isOutstanding(msg.smi_conc_msg_class)) || retired ) begin
            `uvm_info($sformatf("%m"), $sformatf("UNIQ_SMI_ID: got retired msg %p", msg), UVM_MEDIUM)
<% if(obj.testBench == 'dii') { %>
`ifdef VCSorCDNS
            e_msg_complete[msg.smi_conc_msg_class.name].trigger();
`else // `ifdef VCSorCDNS
            ->e_msg_complete[msg.smi_conc_msg_class];
`endif // `ifdef VCSorCDNS ... `else ...
<% } else {%>
            ->e_msg_complete[msg.smi_conc_msg_class];
<% } %>
        end

        // handle command throttling
        if (cmd_throttle_en) begin
           outstanding_txns = statemachine_q.txn_q.find with (item.isOutstanding(eConcMsgCmdReq));
           if ( (cmd_ceil_hit == 1) && (outstanding_txns.size() == 0)) begin
              cmd_throttle_ceil++;
              cmd_ceil_hit = 0;
              `uvm_info($sformatf("%m"), $sformatf("CMD_THROTTLE: CEIL RST  pending=%0d, ceil=%0d, cmd_type:p", outstanding_txns.size(), cmd_throttle_ceil, msg.smi_msg_type), UVM_HIGH)
           end
        end
      
        if ( (retired) && (!msg.isDtwDbgReqMsg()) && (!msg.isDtwDbgRspMsg()) &&(!msg.isSysReqMsg()) && (!msg.isSysRspMsg()) ) begin
           bit [WSMINCOREUNITID+WSMIMPF2-1:0] msg_sig;
           msg_sig = (msg.smi_ns<<(WSMINCOREUNITID+WSMIMPF2-1))|((msg.smi_src_ncore_unit_id)<<(WSMIMPF2-1))|(msg.smi_mpf2[WSMIMPF2-2:0]);
           if (rq_or_ep_order.exists(msg_sig)) begin
              rq_or_ep_order.delete(msg_sig);
           end
           `uvm_info($sformatf("%m"), $sformatf("ORDER DEBUG: msg_sig=%p UNQID=%p MsgType=%p Funit=%0d AXID=%0h Addr=%p finished ordered request",
                                                msg_sig, txn.smi_recd[eConcMsgCmdReq].smi_unq_identifier, 
                                                txn.smi_recd[eConcMsgCmdReq].smi_msg_type, txn.smi_recd[eConcMsgCmdReq].smi_src_ncore_unit_id,
                                                txn.smi_recd[eConcMsgCmdReq].smi_mpf2[WSMIMPF2-2:0], txn.smi_recd[eConcMsgCmdReq].smi_addr), UVM_MEDIUM)
        end // if ( (retired) && (!msg.isDtwDbgReqMsg()) && (!msg.isDtwDbgRspMsg()) )
   endfunction : tryRetire


//////////////////////////////////////////////////////////////////////////////////
// txn level functions
//////////////////////////////////////////////////////////////////////////////////

   task gen_smi__cmd(smi_ncore_unit_id_bit_t which_aiu, output smi_seq_item cmd_msg);
        bit [WSMINCOREUNITID+WSMIMPF2-WSMINCOREPORTID-1:0] cmd_msg_sig;
        <% if(obj.testBench == 'dii') { %>
           `ifdef CDNS
            int    smi_intfsize_cdns;
           `endif 
        <% }  %>

        cmd_msg = new();

        cmd_msg.smi_conc_msg_class = eConcMsgCmdReq;    //supply the msg class in order to generate the id
        //#Stimulus.DII.DTWreq.InitId
        cmd_msg.smi_src_ncore_unit_id = which_aiu;
        cmd_msg.smi_targ_ncore_unit_id = smi_targ_ncore_unit_id(wt_wrong_dut_id_cmd);
        if (cmd_msg.smi_targ_ncore_unit_id != dut_ncore_unit_id) begin
           `uvm_info($sformatf("%m"), $sformatf("Generated msg:%p wrong TARGID %p", cmd_msg.smi_conc_msg_class, cmd_msg.smi_targ_ncore_unit_id), UVM_LOW)
        end
        genReqType(cmd_msg); 
        gen_msg_id(cmd_msg);         //--pause here until cmd msgid available

        // throttle command issue here
        throttle_cmd_issue(cmd_msg); //--pause here until 
      
        `uvm_info($sformatf("%m"), $sformatf("GEN_SMI__CMD debug: aiu_id=%p, msg_id=%p", which_aiu, cmd_msg.smi_msg_id), UVM_MEDIUM)
        genAddress(cmd_msg);
        genConcMisc(cmd_msg); 

        if ( k_32b_cmdset.get_value() ) begin 
            axi_axsize_t err_asize;
            smi_order_t  err_order;
            bit [5:0]    err_addr;
           
//            std::randomize(err_asize) with {err_asize != 2; err_asize <= 4;};
            assert(std::randomize(err_asize) with {err_asize < 2;});
            assert(std::randomize(err_order) with {err_order != SMI_ORDER_ENDPOINT; });
            assert(std::randomize(err_addr ) with {err_addr[1:0] != 2'b00; err_addr[5:2] == 3'b00; });
            // 32 bit supports only RD_NC and WR_NC_PTL
            randcase
                wt_cmd_rd_nc.get_value()        :   cmd_msg.smi_msg_type = CMD_RD_NC;
                wt_cmd_wr_nc_ptl.get_value()    :   cmd_msg.smi_msg_type = CMD_WR_NC_PTL;
                wt_cmd_cmo.get_value()          :
                begin // vyshak check trying for cmo
                  randcase
                    1   :   cmd_msg.smi_msg_type = CMD_CLN_SH_PER;
                    1   :   cmd_msg.smi_msg_type = CMD_CLN_INV;
                    1   :   cmd_msg.smi_msg_type = CMD_MK_INV;
                    1   :   cmd_msg.smi_msg_type = CMD_CLN_VLD;
                  endcase
	            end
            endcase
            cmd_msg.smi_mpf1_burst_type = INCR;
            cmd_msg.smi_mpf1_asize      = ($test$plusargs("32b_asize_err")?err_asize:2);
            cmd_msg.smi_mpf1_alength    = 0;
            cmd_msg.smi_size  = 2;
            if($test$plusargs("exclusive_txn")) cmd_msg.smi_es = 1;
            else cmd_msg.smi_es    = 0;
            cmd_msg.smi_order = ($test$plusargs("32b_order_err")?err_order:SMI_ORDER_ENDPOINT);
            if($test$plusargs("gen_order")) genOrder(cmd_msg);
           <% if(obj.testBench == 'dii') { %>
           `ifndef CDNS
            cmd_msg.smi_addr  = (enabled_32b_align_err?(cmd_msg.smi_addr[5:0] = err_addr):(cmd_msg.smi_addr & (~3)));   //4 byte size aligned
           `else // `ifndef CDNS
            if(enabled_32b_align_err)begin
            cmd_msg.smi_addr[5:0] = err_addr;
            end
            else begin
            cmd_msg.smi_addr=cmd_msg.smi_addr & (~3);   //4 byte size aligned
            end
           `endif // `ifndef CDNS
           <% } else {%>
            cmd_msg.smi_addr  = (enabled_32b_align_err?(cmd_msg.smi_addr[5:0] = err_addr):(cmd_msg.smi_addr & (~3)));   //4 byte size aligned
           <% } %>
           
           <% if(obj.testBench == 'dii') { %>
           `ifndef CDNS
            assert(std::randomize(cmd_msg.smi_intfsize) with {cmd_msg.smi_intfsize inside {[0:2]};});       
           `else // `ifndef CDNS
            assert(std::randomize(smi_intfsize_cdns) with {smi_intfsize_cdns inside {[0:2]};});   
            cmd_msg.smi_intfsize=smi_intfsize_cdns;
           `endif // `ifndef CDNS ... `else ...
           <% } else {%>
            assert(std::randomize(cmd_msg.smi_intfsize) with {cmd_msg.smi_intfsize inside {[0:2]};});
           <% } %>
        end
        else if (k_64b_cmdset.get_value()) begin
            int smi_size;
            cmd_msg.smi_mpf1_burst_type = INCR;
            cmd_msg.smi_mpf1_asize      = 1;
            cmd_msg.smi_mpf1_alength    = 0;
            cmd_msg.smi_es              = 0;
            cmd_msg.smi_st              = 1;
            cmd_msg.smi_addr[5:3]       = 3'b110;
            cmd_msg.smi_size            = 1;
            //cmd_msg.smi_addr  = cmd_msg.smi_addr & (~7);   //8 byte size aligned
           <% if(obj.testBench == 'dii') { %>
           `ifndef CDNS
            assert(std::randomize(cmd_msg.smi_intfsize) with {cmd_msg.smi_intfsize inside {[0:2]};}); 
           `else // `ifndef CDNS
            assert(std::randomize(smi_intfsize_cdns) with {smi_intfsize_cdns inside {[0:2]};}); 
            cmd_msg.smi_intfsize=smi_intfsize_cdns;
           `endif // `ifndef CDNS ... `else ...
           <% } else {%>
            assert(std::randomize(cmd_msg.smi_intfsize) with {cmd_msg.smi_intfsize inside {[0:2]};}); 
           <% } %>
            genOrder(cmd_msg);
         end
         else if (k_cov_directed_test.get_value()) begin
            int smi_size;
            cmd_msg.smi_mpf1_burst_type = INCR;
            cmd_msg.smi_mpf1_asize      = 1;
            cmd_msg.smi_mpf1_alength    = 0;
            cmd_msg.smi_es              = 0;
            cmd_msg.smi_st              = 1;
            //cmd_msg.smi_addr[5:3]       = 3'b110;
            cmd_msg.smi_size            = 5;
            cmd_msg.smi_ca              = 0;
            //cmd_msg.smi_addr  = cmd_msg.smi_addr & (~7);   //8 byte size aligned
            cmd_msg.smi_intfsize = 2; 
            genOrder(cmd_msg);
            `uvm_info($sformatf("%m"), $sformatf("debug k_cov_directed_test: st:%p,addr:%p,size:%p,intfsize:%p,bt:%p,asize:%p,alen:%p\nSMI_MSG:%p",
            cmd_msg.smi_st,cmd_msg.smi_addr, cmd_msg.smi_size,cmd_msg.smi_intfsize,
            cmd_msg.smi_mpf1_burst_type, cmd_msg.smi_mpf1_asize, cmd_msg.smi_mpf1_alength, cmd_msg), UVM_MEDIUM)
         end
         

        
        else begin
            genBurstType(cmd_msg);
            genSize(cmd_msg);
            genOrder(cmd_msg);
        end

        fixAddress(cmd_msg);

        if (cmd_msg.smi_es) begin
           int idx = -1;
           int exclusive_sequence;
           dii_exclusive_c exclusive_cmd;
           dii_exclusive_c load_exclusive_cmd;
           int exclusive_sequence_weight;
           exclusive_cmd            = new();
           exclusive_cmd.tof        = cmd_msg.smi_tof;
           exclusive_cmd.st         = cmd_msg.smi_st;
           exclusive_cmd.ca         = cmd_msg.smi_ca;
           exclusive_cmd.ac         = cmd_msg.smi_ac;
           exclusive_cmd.intfsize   = cmd_msg.smi_intfsize;
           exclusive_cmd.addr       = cmd_msg.smi_addr;
           exclusive_cmd.size       = cmd_msg.smi_size;
           exclusive_cmd.burst_type = cmd_msg.smi_mpf1_burst_type;
           exclusive_cmd.asize      = cmd_msg.smi_mpf1_asize;
           exclusive_cmd.alen       = cmd_msg.smi_mpf1_alength;
           exclusive_cmd.src_id     = cmd_msg.smi_src_ncore_unit_id;
           exclusive_cmd.flowid     = cmd_msg.smi_mpf2_flowid;
           exclusive_cmd.msg_type    = cmd_msg.smi_msg_type;
           exclusive_cmd.ns          = cmd_msg.smi_ns;
           if (exclusive_cmd.msg_type == CMD_RD_NC) begin
                        load_exclusive_q.push_back(exclusive_cmd);
           end
            if ($test$plusargs("wt_exclusive_sequence")) begin
               exclusive_sequence_weight = wt_exclusive_sequence.get_value();
            end 
            else begin
               exclusive_sequence_weight = 0;
            end
           exclusive_sequence = $urandom_range(0,100);
           if ((cmd_msg.smi_msg_type != CMD_RD_NC) && exclusive_sequence < exclusive_sequence_weight && load_exclusive_q.size() > 0 ) begin
                load_exclusive_q.shuffle();
                load_exclusive_cmd = load_exclusive_q.pop_front();
                cmd_msg.smi_tof                 = load_exclusive_cmd.tof;
                cmd_msg.smi_st                  = load_exclusive_cmd.st;
                cmd_msg.smi_ca                  = load_exclusive_cmd.ca;
                cmd_msg.smi_ac                  = load_exclusive_cmd.ac;
                cmd_msg.smi_intfsize            = load_exclusive_cmd.intfsize;
                cmd_msg.smi_addr                = load_exclusive_cmd.addr;
                cmd_msg.smi_size                = load_exclusive_cmd.size;
                cmd_msg.smi_src_ncore_unit_id   = load_exclusive_cmd.src_id;
                cmd_msg.smi_mpf2_flowid         = load_exclusive_cmd.flowid;
                cmd_msg.smi_ns                  = load_exclusive_cmd.ns  ;        
        

                if (cmd_msg.smi_tof != SMI_TOF_CHI) begin
                              cmd_msg.smi_mpf1_burst_type = load_exclusive_cmd.burst_type;
                              //#Stimulus.DII.CMDreq.Excel.Asize
                              cmd_msg.smi_mpf1_asize      = load_exclusive_cmd.asize;
                              //#Stimulus.DII.CMDreq.Excel.Alength
                              cmd_msg.smi_mpf1_alength    = load_exclusive_cmd.alen;
                end
                gen_msg_id(cmd_msg);  
           end
         else begin
           if (exclusive_q.size() == 0) begin
              exclusive_q.push_back(exclusive_cmd);
           end else begin
              for (int i=0; i<exclusive_q.size(); i++) begin
                 if (exclusive_q[i].addr == cmd_msg.smi_addr) begin
                    idx = i;
                    break;
                 end
              end
              if (idx < 0) begin
                 if (exclusive_q.size() > 4) begin
                    // force exclusive access match
                    exclusive_q.shuffle();
                    cmd_msg.smi_tof             = exclusive_q[0].tof;
                    cmd_msg.smi_st              = exclusive_q[0].st;
                    cmd_msg.smi_ca              = exclusive_q[0].ca;
                    cmd_msg.smi_ac              = exclusive_q[0].ac;
                    cmd_msg.smi_intfsize        = exclusive_q[0].intfsize;
                    cmd_msg.smi_addr            = exclusive_q[0].addr;
                    cmd_msg.smi_size            = exclusive_q[0].size;
                    cmd_msg.smi_mpf1_burst_type = exclusive_q[0].burst_type;
                    cmd_msg.smi_mpf1_asize      = exclusive_q[0].asize;
                    cmd_msg.smi_mpf1_alength    = exclusive_q[0].alen;
                    `uvm_info($sformatf("%m"), $sformatf("EXCLUSIVE Q %0d: tof:%p addr:%p", exclusive_q.size(), exclusive_q[0].tof, exclusive_q[0].addr), UVM_HIGH)
                 end else begin
                    exclusive_q.push_back(exclusive_cmd);
                 end
              end else begin
                 cmd_msg.smi_tof             = exclusive_q[idx].tof;
                 cmd_msg.smi_st              = exclusive_q[idx].st;
                 cmd_msg.smi_ca              = exclusive_q[idx].ca;
                 cmd_msg.smi_ac              = exclusive_q[idx].ac;
                 cmd_msg.smi_intfsize        = exclusive_q[idx].intfsize;
                 cmd_msg.smi_addr            = exclusive_q[idx].addr;
                 cmd_msg.smi_size            = exclusive_q[idx].size;
                 if (cmd_msg.smi_tof != SMI_TOF_CHI) begin
                    cmd_msg.smi_mpf1_burst_type = exclusive_q[idx].burst_type;
                    cmd_msg.smi_mpf1_asize      = exclusive_q[idx].asize;
                    cmd_msg.smi_mpf1_alength    = exclusive_q[idx].alen;
                 end
              end // else: !if(idx < 0)
           end // else: !if(exclusive_q.size() == 0)
        end
           cmd_msg.smi_vz = 1;// exclusive cmd should not have EWA CONC-10036
           `uvm_info($sformatf("%m"), $sformatf("EXCLUSIVE tof:%p,st:%p,ca:%p,ac:%paddr:%p,size:%p,bt:%p,asize:%p,alen:%p\nSMI_MSG:%p",
                                                cmd_msg.smi_tof, cmd_msg.smi_st, cmd_msg.smi_ca, cmd_msg.smi_ac, cmd_msg.smi_addr, cmd_msg.smi_size,
                                                cmd_msg.smi_mpf1_burst_type, cmd_msg.smi_mpf1_asize, cmd_msg.smi_mpf1_alength, cmd_msg), UVM_MEDIUM)
        end // if (cmd_msg.smi_es)
      
        if(cmd_msg.smi_msg_type inside {CMD_WR_NC_FULL,CMD_WR_NC_PTL}) begin
            genDp(cmd_msg);
	    genDWID(cmd_msg);
	end
        // configure optional fields
        cmd_msg.smi_steer           = (<%=smiObj.WSMISTEER  %>?$urandom():'b0);
        cmd_msg.smi_msg_pri         = (<%=smiObj.WSMIMSGPRI %>?$urandom():'b0);
	cmd_msg.smi_msg_tier        = (<%=smiObj.WSMIMSGTIER%>?$urandom():'b0);
	cmd_msg.smi_msg_qos         = (<%=smiObj.WSMIMSGQOS %>?$urandom():'b0);
        cmd_msg.smi_msg_hprot       = (<%=smiObj.WSMIHPROT  %>?$urandom():'b0);
        if ($test$plusargs("pmon_bw_user_bits")) begin
        cmd_msg.smi_ndp_aux         = (<%=smiObj.WSMINDPAUX %>?$urandom_range(5,15):'b0);
        `uvm_info($sformatf("%m"), $sformatf("dii seq debug Pmon bw user bits testcase is enabled"), UVM_LOW)
        end
        else begin
        cmd_msg.smi_ndp_aux         = (<%=smiObj.WSMINDPAUX %>?$urandom():'b0);
        end
        cmd_msg.smi_mpf2_dtr_msg_id = (<%=smiObj.WSMIMSGID  %>?$urandom():'b0);

        // CONC - 8836 and CONC - 8972 - cmdreq can have a RL of 2'b10 for a CMO if vz = 1
        if((cmd_msg.smi_msg_type inside {CMD_CLN_VLD, CMD_CLN_SH_PER, CMD_CLN_INV, CMD_MK_INV}) && (cmd_msg.smi_vz == 1'b1)) begin
           cmd_msg.smi_rl  = SMI_RL_COHERENCY;
        end

        // Need to check that requests do not have dependencies.
        cmd_msg.unpack_smi_unq_identifier();
        if (cmd_msg.smi_order != SMI_ORDER_NONE) begin
           cmd_msg_sig = (cmd_msg.smi_ns<<(WSMINCOREUNITID+WSMIMPF2-1))|(cmd_msg.smi_src_ncore_unit_id)|(cmd_msg.smi_mpf2[WSMIMPF2-2:0]);
           if ((!overflow_buffer_test_2 && !new_scenario && !read_after_read_scenario && !write_after_write_scenario && !$test$plusargs("only_write_ordered") && !$test$plusargs("only_eo_ordered") && !$test$plusargs("override")) || ($test$plusargs("check_rq_ep_order") && rq_or_ep_order.exists(cmd_msg_sig))) begin
              cmd_msg.smi_order = SMI_ORDER_NONE;
              `uvm_info($sformatf("%m"), $sformatf("GEN_SMI__CMD debug Reset: cmd order=%p, unq_id=%p sig=%p cmd=%p", cmd_msg.smi_order, cmd_msg.smi_unq_identifier,
                                                   cmd_msg_sig, rq_or_ep_order[cmd_msg_sig]), UVM_MEDIUM)
           end else begin
              rq_or_ep_order[cmd_msg_sig] = cmd_msg;
              `uvm_info($sformatf("%m"), $sformatf("GEN_SMI__CMD debug Set: cmd order=%p, unq_id=%p sig=%p cmd=%p", cmd_msg.smi_order, cmd_msg.smi_unq_identifier,
                                                   cmd_msg_sig, rq_or_ep_order[cmd_msg_sig]), UVM_MEDIUM)
           end
        end
        cmd_msg.unpack_smi_unq_identifier();
        `uvm_info($sformatf("%m"), $sformatf("GEN_SMI__CMD debug: cmd order=%p, unq_id=%p", cmd_msg.smi_order, cmd_msg.smi_unq_identifier), UVM_MEDIUM)
        //cmd_msg.pack_smi_seq_item(.isRtl(0));
        //cmd_msg.unpack_smi_seq_item();
        if (cmd_msg.smi_order != SMI_ORDER_NONE) begin
           `uvm_info($sformatf("%m"), $sformatf("GEN_SMI__CMD debug: order=%p mpf2=%p flowid=%p flowidv=%0d unq_id=%p queued unq_id=%p",
                                                cmd_msg.smi_order, cmd_msg.smi_mpf2, cmd_msg.smi_mpf2_flowid, cmd_msg.smi_mpf2_flowid_valid, cmd_msg.smi_unq_identifier,
                                                rq_or_ep_order[cmd_msg_sig].smi_unq_identifier), UVM_LOW)
       end
       `uvm_info($sformatf("%m"), $sformatf("gen_smi__cmd done: %p", cmd_msg), UVM_MEDIUM)
   endtask :  gen_smi__cmd

    //----------------------------------------------------------------

   //#Stimulus.DII.CMDreq.Mpf1.Burst_type
   function void genBurstType(smi_seq_item msg);
      smi_mpf1_burst_type_t burst_type;
      assert(std::randomize(burst_type) with { burst_type inside {INCR, WRAP}; });
      msg.smi_mpf1_burst_type = burst_type;
      `uvm_info($sformatf("%m"), $sformatf("GENBURSTTYPE: burst_type=%p", burst_type), UVM_HIGH)
   endfunction : genBurstType
      
    //new uniformly distributed or reuse outstanding addr of dut
    //#Stimulus.DII.CMDreq.Addr
   function void genAddress(smi_seq_item msg);
        bit done;
        int limit_num_addr;
        int gen_same_eo_addr_range;
      
        done = 0;
        if (!$value$plusargs("limit_num_addr=%d", limit_num_addr)) begin
           limit_num_addr = 0;
        end 
        if (!$value$plusargs("gen_same_eo_addr_range=%d", gen_same_eo_addr_range)) begin
           gen_same_eo_addr_range = 0;
        end 
       // $display("Vyshak and gen_same_eo_addr_range is %0d",gen_same_eo_addr_range);
        
        if(($test$plusargs("gen_same_eo_addr_range")))begin // to generate from same EO point
            msg.smi_addr = addr_mgr.gen_sel_targ_addr_from_unit_attr("DII",dii_nunit_id,0,1);
        end else if ((limit_num_addr == 0) || (dii_addr_q.size() < limit_num_addr)) begin // to support access a limitted set of addresses
           while (done == 0) begin
              addr_mgr.set_addr_collision_pct(dut_ncore_unit_id, 1, wt_reuse_addr.get_value());
              msg.smi_addr = addr_mgr.get_iocoh_addr(dut_ncore_unit_id, 1);  
              done = ( (msg.smi_addr < (<%=obj.AiuInfo[0].CsrInfo.csrBaseAddress.replace("0x","'h")%> << 20)) ||
                       (msg.smi_addr >= ((<%=obj.AiuInfo[0].CsrInfo.csrBaseAddress.replace("0x","'h")%> << 20) + ((<%=obj.AiuInfo[0].nrri%>+1) << 20))) );
           end
           `uvm_info($sformatf("%m"), $sformatf("Uint: %p\tALLOC addr: %p ", dut_ncore_unit_id, msg.smi_addr),UVM_HIGH)
           if (limit_num_addr != 0) begin
              dii_addr_q.push_back(msg.smi_addr);
           end
        end else begin // if ((limit_num_addr == 0) || (dii_addr_q.size() < limit_num_addr))
           dii_addr_q.shuffle();
           msg.smi_addr = dii_addr_q[0];
           `uvm_info($sformatf("%m"), $sformatf("Uint: %p\tREUSE addr: %p ", dut_ncore_unit_id, msg.smi_addr),UVM_HIGH)
        end
        msg.smi_addr[3:0] = $urandom_range(0,15); //addrmgr addr is 64b aligned

        if(new_scenario || $test$plusargs("exact_addr")) begin
            msg.smi_addr[7:0] = 4'b0000; // to make address exactly the same
        end
        
        if ( k_32b_cmdset.get_value() ) begin
           if($test$plusargs("randomize_3rdbit")) msg.smi_addr[2:0] = 3'b000;
           else msg.smi_addr[3:0] = 4'b0000;
        end else 
        
        if (stress_single_addr_enabled|| performance_bw_test_enabled) begin
           if (request_32b_enabled) begin
              msg.smi_addr[4:0] = 5'b00000;
           end else begin
              msg.smi_addr[5:0] = 6'b000000;
           end
        end
        `uvm_info("ADDR",$sformatf("The smi_addr is %0h",msg.smi_addr),UVM_HIGH);
        ev.trigger(msg);
   endfunction : genAddress

   // adjust address alignment
   // FOR NCORE3: No NARROW Initiator is supported!!
   function automatic void fixAddress(smi_seq_item msg);
      if (msg.smi_tof == SMI_TOF_CHI) begin
	 // for CHI access, need minimum dword aligned address
        if ( k_32b_cmdset.get_value() == 0 ) begin          
	   msg.smi_addr &= (stress_single_addr_enabled|| performance_bw_test_enabled) ? (~(8-1)) : (~(min(8, 2**msg.smi_size)-1));
        end else begin
           msg.smi_addr &= ( ~(4-1) );
        end
      end else begin
	 int unsigned mpf1_size;
	 int unsigned incr_top_addr;

	 mpf1_size = (msg.smi_mpf1_alength+1)*(2**msg.smi_mpf1_asize);
	 incr_top_addr = mpf1_size + (msg.smi_addr%CACHELINESIZE);
	 
	 // AXI
	 if ( msg.smi_st ) begin
            if ( msg.smi_mpf1_burst_type != INCR ) begin
	       msg.smi_addr = ( msg.smi_addr & (~(2**(msg.smi_intfsize+3)-1)) );
               `uvm_info($sformatf("%m"), $sformatf("FIXADDR 0"), UVM_HIGH)
	    end else if (msg.smi_mpf1_alength > 0) begin
	       if ( incr_top_addr > CACHELINESIZE ) begin   // INCR cannot cross cache line boundary
		  msg.smi_addr = msg.smi_addr - ((incr_top_addr&(~((2**(msg.smi_intfsize+3))-1)))-CACHELINESIZE);
                  `uvm_info($sformatf("%m"), $sformatf("FIXADDR 1: new_addr:%p incr_top:%p", msg.smi_addr, incr_top_addr), UVM_HIGH)
	       end else if ((mpf1_size < (2**(msg.smi_intfsize+3))) &&
                            (((msg.smi_addr%(2**(msg.smi_intfsize+3)))+mpf1_size) > (2**(msg.smi_intfsize+3)))) begin // narrow increment 
                  msg.smi_addr = ( msg.smi_addr - (msg.smi_addr%(2**(msg.smi_intfsize+3))) );
                  `uvm_info($sformatf("%m"), $sformatf("FIXADDR 2"), UVM_HIGH)
               end
            end
            `uvm_info($sformatf("%m"), $sformatf("addr=%p smi_size=%0h mpf1_asize=%0d mpf1_alen=%0d bt=%p ajusted=%p top_addr=%p",
                                                 msg.smi_addr, msg.smi_size, msg.smi_mpf1_asize, msg.smi_mpf1_alength, msg.smi_mpf1_burst_type,
                                                 msg.smi_addr % (2**msg.smi_size), incr_top_addr), UVM_HIGH)
	 end else begin // for modifiable the addr 
	    if ( (msg.smi_mpf1_burst_type == INCR) ) begin
	       if (msg.smi_size == $clog2(CACHELINESIZE)) begin
		  msg.smi_addr = msg.smi_addr & (~(CACHELINESIZE-1)) | (msg.smi_addr & 7);  // must start in DW0
		  `uvm_info($sformatf("%m"), $sformatf("FIXADDR 3"), UVM_HIGH)
	       end else if ( ((msg.smi_addr%CACHELINESIZE) + mpf1_size) > CACHELINESIZE ) begin
		  msg.smi_addr = ( msg.smi_addr - mpf1_size );
                  `uvm_info($sformatf("%m"), $sformatf("FIXADDR 4"), UVM_HIGH)
	       end
	    end begin
	       msg.smi_addr &= (~((2**(msg.smi_mpf1_asize))-1));
               `uvm_info($sformatf("%m"), $sformatf("FIXADDR 5"), UVM_HIGH)
	    end
         end // else: !if( msg.smi_st )
      end // else: !if(msg.smi_tof == SMI_TOF_CHI)
      if (stress_single_addr_enabled || performance_bw_test_enabled) begin
         msg.smi_addr &= ( ~((msg.smi_mpf1_burst_type == INCR) ? (CACHELINESIZE-1) : ((2**(msg.smi_mpf1_asize))-1)) );
      end
      //#Stimulus.DII.CMDreq.Excel.Addr
      if (msg.smi_es || stress_single_addr_enabled) begin  // address needs to be size aligned
         msg.smi_addr &= (~((2**msg.smi_size)-1));
      end
      `uvm_info($sformatf("%m"), $sformatf("FIXADDR: msg_type=%0h tof=%0d smi_st=%0d smi_size=%0h addr=%p: burst=%0d asize=%0d alen=%0d bytes=%0h",
					   msg.smi_msg_type, msg.smi_tof, msg.smi_st, msg.smi_size, msg.smi_addr,
					   msg.smi_mpf1_burst_type, msg.smi_mpf1_asize, msg.smi_mpf1_alength, axi_bytes(msg)), UVM_HIGH)
   endfunction : fixAddress
   //#Stimulus.DII.DTWreq.Double_word_id
   function void genDWID(smi_seq_item msg);
      int dwid_base;
      int dwid_incr;
      int dwid_beat;
      int addr_wrap_base, addr_wrap_top;
      int smi_size;
      
      smi_size  = (2**msg.smi_size);
      dwid_beat = ((smi_size/(wSmiDPdata/8) > 0) ? (smi_size/(wSmiDPdata/8)) : 1);
      
      addr_wrap_base = ((((msg.smi_tof == SMI_TOF_CHI) || (msg.smi_mpf1_burst_type != INCR))
                         ? ((msg.smi_addr/smi_size)*smi_size)%(CACHELINESIZE) : 0)) >> 3;
      addr_wrap_top  = ((((msg.smi_tof == SMI_TOF_CHI) || (msg.smi_mpf1_burst_type != INCR))
                         ? addr_wrap_base + $ceil(smi_size*1.0/8) : CACHELINESIZE/8));
      
      // Assuming DATA is always critical DWord first, and are present only if data is valid
      msg.smi_dp_dwid = new[dwid_beat];
      dwid_base = ((msg.smi_addr >> (3+msg.smi_intfsize)) << msg.smi_intfsize) & ((CACHELINESIZE/8)-1);
      for (int i=0; i<msg.smi_dp_dwid.size(); i++) begin
	 for (int j=0; j<wSmiDPdata/64; j++) begin
	    dwid_incr = i*(wSmiDPdata/64) + j;
	    msg.smi_dp_dwid[i][j*WSMIDPDWIDPERDW +: WSMIDPDWIDPERDW] = ((dwid_base + dwid_incr) < addr_wrap_top) ? dwid_base + dwid_incr : (dwid_base + dwid_incr) - addr_wrap_top + addr_wrap_base;
	    `uvm_info($sformatf("%m"), $sformatf("DWID: addr=%p smi_size=%0d size=%0d base=%0d incr=%0d wrap_base=%0h wrap_top=%0h i=%0d j=%0d dwid=%0d",
						 msg.smi_addr, msg.smi_size, msg.smi_dp_dwid.size(), dwid_base, dwid_incr, addr_wrap_base, addr_wrap_top, i, j, msg.smi_dp_dwid[i][j*WSMIDPDWIDPERDW +: WSMIDPDWIDPERDW]), UVM_DEBUG)
	 end
      end
   endfunction : genDWID
   
   function smi_ncore_unit_id_bit_t smi_targ_ncore_unit_id(common_knob_class wt_wrong_id);
       randcase
            (100 - wt_wrong_id.get_value()) :   return dut_ncore_unit_id;   //unit env contains exactly 1 dii
            wt_wrong_id.get_value()         :   begin
               smi_ncore_unit_id_bit_t  rdm_id;
               assert(std::randomize(rdm_id) with { rdm_id != dut_ncore_unit_id; });
               return rdm_id;
            end
        endcase
   endfunction : smi_targ_ncore_unit_id

    //#Stimulus.DII.CMDreq.Msg_type
   task genReqType(smi_seq_item msg);
      MsgType_t              smi_msg_type;


      if( read_cmd == 1) begin
          smi_msg_type = CMD_RD_NC; 
          read_cmd = 0;
      end else if (write_cmd == 1) begin
        int random_c = $urandom_range(1,0);
            case(random_c)
                0        :   smi_msg_type = CMD_WR_NC_FULL;
                1        :   smi_msg_type = CMD_WR_NC_PTL;
            endcase
            write_cmd = 0;

      end else if (read_cmo_cmd == 1) begin
        int random_cmo = $urandom_range(3,0);
          case(random_cmo)
              0   :   smi_msg_type = CMD_CLN_SH_PER;
              1   :   smi_msg_type = CMD_CLN_INV;
              2   :   smi_msg_type = CMD_MK_INV;
              3   :   smi_msg_type = CMD_CLN_VLD;
          endcase
          read_cmo_cmd = 0;
      end else if ( overflow_buffer == 1 ) begin 
        int random_choice = $urandom_range(1,0);
            case(random_choice)
                0        :   smi_msg_type = CMD_WR_NC_FULL;
                1        :   smi_msg_type = CMD_WR_NC_PTL;
            endcase
            `uvm_info("MSG_TYPE",$sformatf("Vyshak and is a read message"),UVM_HIGH);
      end else if ( new_scenario_var == 1 ) begin 
        int random_choice = $urandom_range(1,0);
            case(random_choice)
                0        :   smi_msg_type = CMD_WR_NC_FULL;
                1        :   smi_msg_type = CMD_WR_NC_PTL;
            endcase
       end else if ($test$plusargs("read_and_write") ) begin 
        int random_choice = $urandom_range(2,0);
            case(random_choice)
                0        :   smi_msg_type = CMD_WR_NC_FULL;
                1        :   smi_msg_type = CMD_RD_NC;
                2        :   smi_msg_type = CMD_WR_NC_PTL;
            endcase
      end else if ( new_scenario_var == 2 ) begin 
           smi_msg_type = CMD_RD_NC;          
      end else if ( read_after_read_scenario == 1 ) begin 
           smi_msg_type = CMD_RD_NC;          
      end  else if ( write_after_write_scenario == 1 || $test$plusargs("writes_only")) begin 
           smi_msg_type = CMD_WR_NC_FULL;          
      end
      else if ( k_32b_cmdset.get_value() ) begin 
            randcase
                wt_cmd_rd_nc.get_value()        :   smi_msg_type = CMD_RD_NC;
                wt_cmd_wr_nc_ptl.get_value()    :   smi_msg_type = CMD_WR_NC_PTL;
            endcase
     end else if (performance_bw_test_enabled) begin
         randcase
           wt_cmd_rd_nc.get_value()       : smi_msg_type = CMD_RD_NC;
           // whether partial or full depends on whether halfline or fullline
           wt_cmd_wr_nc_ptl.get_value()   : smi_msg_type = (request_32b_enabled ? CMD_WR_NC_PTL : CMD_WR_NC_FULL);
           wt_cmd_wr_nc_full.get_value()  : smi_msg_type = (request_32b_enabled ? CMD_WR_NC_PTL : CMD_WR_NC_FULL);
         endcase // randcase
      end else begin
         randcase
	   wt_cmd_rd_nc.get_value()          : smi_msg_type = CMD_RD_NC;
	   wt_cmd_wr_nc_ptl.get_value()      : smi_msg_type = (stress_single_addr_enabled ? CMD_WR_NC_FULL : CMD_WR_NC_PTL );
	   wt_cmd_wr_nc_full.get_value()     : smi_msg_type = CMD_WR_NC_FULL;
	   wt_cmd_cmo.get_value()            : //#Stimulus.DII.CMDreq.Cache_Maintenance_type
             begin
                randcase
                  1   :   smi_msg_type = CMD_CLN_SH_PER;
                  1   :   smi_msg_type = CMD_CLN_INV;
                  1   :   smi_msg_type = CMD_MK_INV;
                  1   :   smi_msg_type = CMD_CLN_VLD;
                endcase
	     end
          endcase // randcase
      end // else: !if($test$plusargs("performance_bw_test"))
      `uvm_info("MSG_TYPE",$sformatf("The smi_msg_type after genReqType is %p",smi_msg_type),UVM_HIGH);
      msg.smi_msg_type = smi_msg_type;
   endtask // genReqType


   //helper class jointly randomizing concerto asize and alen
   class asize_alength;    
        rand smi_mpf1_asize_t asize;
        rand smi_mpf1_alength_t alength;

        smi_intfsize_t intfsize;
        int maxbytes;
        
        constraint c_asize_alength {
                ( 
                    //no narrow axi of >1 beat 
                    (alength == 0)                              
                    || ( asize == (intfsize + 3) )    //intfsize in DWords
                )
                && ( ((alength + 1) * (2**asize)) <= maxbytes )
        ; }
        
        function new(smi_intfsize_t intfsize_in, int maxbytes_in);
            intfsize = intfsize_in; 
            maxbytes = maxbytes_in;
        endfunction : new
    endclass : asize_alength
   //#Stimulus.DII.CMDreq.Intfsize
   //#Stimulus.DII.CMDreq.Size
   //#Stimulus.DII.CMDreq.Mpf1.Asize
   //#Stimulus.DII.CMDreq.Mpf1.Alen
   function genSize(smi_seq_item msg);
        smi_size_t smi_size;
        smi_intfsize_t smi_intfsize;
 
        // increase width adaption
        if (WXDATA == 64) begin
            assert(std::randomize(smi_intfsize) with {  smi_intfsize inside {[0:2]};
                                                        smi_intfsize dist { 2 := 4, 1 := 4, 0 := 2}; });
        end else if (WXDATA == 128) begin
            assert(std::randomize(smi_intfsize) with {  smi_intfsize inside {[0:2]};
                                                        smi_intfsize dist { 2 := 4, 1 := 2, 0 := 4}; });
        end else begin
            assert(std::randomize(smi_intfsize) with {  smi_intfsize inside {[0:2]};
                                                        smi_intfsize dist { 2 := 2, 1 := 4, 0 := 4}; });
        end
        msg.smi_intfsize = smi_intfsize;
      
        // for CHI: smi_size does not depend on mpf1.
        // For AXI/ACE smi_size value depends on asize and alength, eventhough DII only pays attention to asize/alength when alength==0
        if ( msg.smi_tof == SMI_TOF_CHI )begin
	   msg.smi_mpf1_asize = $urandom();    //don't care for CHI
           msg.smi_mpf1_alength = $urandom();  //don't care for CHI
           if (performance_bw_test_enabled || stress_single_addr_enabled ) begin
              smi_size = request_32b_enabled ? 5 : 6;
           end else begin
              assert(std::randomize(smi_size) with { ((msg.smi_ca==1) || (msg.smi_ac==1))                                      -> smi_size inside {[0:6]};
                                                     ((msg.smi_msg_type != CMD_WR_NC_FULL) && (msg.smi_ca==0) && (msg.smi_st)) -> smi_size <= (msg.smi_intfsize+3);
                                                     (msg.smi_msg_type == CMD_WR_NC_FULL) -> smi_size == $clog2(CACHELINESIZE);
                                                     smi_size dist {6 := 3, 5 := 3, [0:4] :/ 4};
                                                     smi_size <= $clog2(CACHELINESIZE); });
           end
	   msg.smi_size = smi_size;
           `uvm_info($sformatf("%m"), $sformatf("GENSIZE: tof:%0d smi_size:%0h smi_st:%0d ADDR:%p intfsize:%0d bus:%0d",
                                                msg.smi_tof, msg.smi_size, msg.smi_st, msg.smi_addr, msg.smi_intfsize,<%=obj.DiiInfo[obj.Id].wData%>/8), UVM_HIGH)
	end else begin
	   smi_mpf1_asize_t   mpf1_asize;
	   smi_mpf1_alength_t mpf1_alen;
           int                total_size;

           if (performance_bw_test_enabled || stress_single_addr_enabled ) begin
              total_size = CACHELINESIZE/(request_32b_enabled ? 2 : 1);
              mpf1_asize = (msg.smi_intfsize + 3);
              msg.smi_mpf1_burst_type = INCR;
              mpf1_alen  = (total_size/(2**mpf1_asize)) - 1;
           end else begin  
	      assert(std::randomize(total_size) with { total_size inside {1, 2, 4, 8, 16, 32, 64};
                                                       (total_size <= CACHELINESIZE);
                                                       (msg.smi_msg_type == CMD_WR_NC_FULL) -> (total_size == CACHELINESIZE);
                                                       ((msg.smi_mpf1_burst_type == INCR) && (msg.smi_msg_type != CMD_WR_NC_FULL) && (msg.smi_st))
                                                                                              -> total_size <= (2**(msg.smi_intfsize+3));
                                                       ((msg.smi_mpf1_burst_type != INCR))    -> (total_size > (2**(msg.smi_intfsize+3)));
                                                     });

	      assert(std::randomize(mpf1_asize) with { mpf1_asize inside {[0:msg.smi_intfsize+3]};
                                                      (total_size == CACHELINESIZE)                    -> mpf1_asize == (msg.smi_intfsize+3);
                                                      (total_size < (2**(msg.smi_intfsize+3)))         -> mpf1_asize <= (msg.smi_intfsize+3);
                                                      (total_size < (2**(msg.smi_intfsize+3)))         -> mpf1_asize >= $clog2(total_size/8);
                                                      (total_size >= (2**(msg.smi_intfsize+3)))        -> mpf1_asize == (smi_intfsize + 3);
                                                     });

	      // alength distribution set depends on burst type: INCR favors small value; wrap allows larger ones
	      // If total size is less than smi interface size, the burst type needs to be converted to INCR
	      if ((msg.smi_tof != SMI_TOF_CHI) && (msg.smi_st == 0) && (total_size <= (msg.smi_intfsize+3))) begin
	         msg.smi_mpf1_burst_type = INCR;
	      end

	      if (msg.smi_mpf1_burst_type == INCR) begin
	         assert(std::randomize(mpf1_alen) with { mpf1_alen inside {[0:7]};
                                                        (total_size == CACHELINESIZE)          -> ((mpf1_alen+1)*(2**mpf1_asize)) == total_size;
                                                        (mpf1_asize < (msg.smi_intfsize+3)  )  ->                       mpf1_alen == 0;                                                  
					                (((mpf1_alen>0)?(mpf1_alen+1):0)*(2**mpf1_asize))                         <= total_size;
                                                        mpf1_alen dist { 0 := 3, 1 :=3, [2:7] :/ 4 };
                                                      });
	      end else begin
	         assert(std::randomize(mpf1_alen) with { (mpf1_alen inside {1,3,7});
                                                         (total_size == CACHELINESIZE)         -> ((mpf1_alen+1)*(2**mpf1_asize)) == CACHELINESIZE;
                                                         ((mpf1_alen+1)*(2**mpf1_asize))                                          <= CACHELINESIZE;
                                                       });
	      end
           end

	   msg.smi_mpf1_asize    = mpf1_asize;
           if (msg.smi_st == 1) begin
              // need to force BT==INCR, ALEN==0
              if (mpf1_asize < (msg.smi_intfsize+3)) begin
                 if (msg.smi_mpf1_burst_type != INCR) begin
                    msg.smi_mpf1_burst_type = INCR;
                 end
                 mpf1_alen = 0;
              end
           end
	   msg.smi_mpf1_alength  = mpf1_alen;

           //full type access shall always be a full cacheline in size
	   //
	   if(msg.smi_msg_type == CMD_WR_NC_FULL) begin
              msg.smi_size = $clog2(CACHELINESIZE) ;
	   end else begin
              if (performance_bw_test_enabled || stress_single_addr_enabled ) begin
                 msg.smi_size = (request_32b_enabled) ? 5 : 6;
              end else begin
                 if (msg.smi_tof != SMI_TOF_CHI) begin
                    if (msg.smi_st) begin
	               msg.smi_size = $clog2((msg.smi_mpf1_alength+1)*(2**msg.smi_mpf1_asize));
	            end else begin
                       msg.smi_size = $clog2(CACHELINESIZE);
                    end
                 end
              end // else: !if($test$plusargs("performance_bw_test"))
           end
           `uvm_info($sformatf("m"), $sformatf("GENSIZE: tof:%0d asize:%0d alength:%0d burst_type:%p smi_size:%0h smi_st:%0d SIZE:%p ADDR:%p (ID=%0d bus=%0d)",
					       msg.smi_tof, mpf1_asize, mpf1_alen, msg.smi_mpf1_burst_type, msg.smi_size, msg.smi_st, total_size, msg.smi_addr,
					       <%=obj.Id%>, <%=obj.DiiInfo[obj.Id].wData%>/8), UVM_HIGH)
	end // else: !if( msg.smi_tof == SMI_TOF_CHI )
	   
   endfunction : genSize


   //#Stimulus.DII.CMDreq.Order        
   function void genOrder(smi_seq_item msg);


        if($test$plusargs("only_write_ordered"))  msg.smi_order = SMI_ORDER_WRITE; //vyshak overwriting //vyshak require
        else if($test$plusargs("only_request_ordered")) msg.smi_order = SMI_ORDER_REQUEST_WR_OBS;
        else if($test$plusargs("only_endpoint_ordered")) msg.smi_order = SMI_ORDER_ENDPOINT;
        else if($test$plusargs("only_no_ordered")) msg.smi_order = SMI_ORDER_NONE;
        else if(overflow_buffer == 1)begin 
          int random_order_sel = $urandom_range(2,0);
            case(random_order_sel) //#Stimulus.DII.Concerto.v3.7.NonEOWrite
              0  : msg.smi_order = SMI_ORDER_REQUEST_WR_OBS ; //request order 
              1  : msg.smi_order = SMI_ORDER_NONE; //none order
              2  : msg.smi_order = SMI_ORDER_WRITE; //write order
            endcase
        end else if (new_scenario_var == 1) begin  
            //$display("Vyshak new and order is none (00)");
            msg.smi_order = SMI_ORDER_NONE; //none order
        end else if (read_after_read_scenario == 1 || write_after_write_scenario == 1) begin  
            msg.smi_order = SMI_ORDER_ENDPOINT; 
        end else if (new_scenario_var == 2 ||  $test$plusargs("only_eo_ordered")) begin 
            //$display("Vyshak new and order is endpoint ordered");
            msg.smi_order = SMI_ORDER_ENDPOINT; //none order
        end else if( (msg.isCmdNcRdMsg()) || (msg.isCmdNcWrMsg()) ) begin    //CHI 2.4.4. only a few msgtypes may have nonnone ordering
           if (msg.smi_es == 1) begin
              msg.smi_order = (msg.smi_st) ? SMI_ORDER_REQUEST_WR_OBS : SMI_ORDER_REQUEST_WR_OBS ;
           end else begin
              bit [WSMINCOREUNITID+WSMIMPF2-1:0] msg_sig;
              msg_sig = (msg.smi_ns<<(WSMINCOREUNITID+WSMIMPF2-1))|((msg.smi_src_ncore_unit_id)<<(WSMIMPF2-1))|(msg.smi_mpf2[WSMIMPF2-2:0]);
              if ((!overflow_buffer_test_2 && !new_scenario && !$test$plusargs("override") && !read_after_read_scenario && !write_after_write_scenario && !$test$plusargs("only_eo_ordered")) || ($test$plusargs("check_rq_ep_order") && rq_or_ep_order.exists(msg_sig))) begin
                 msg.smi_order = SMI_ORDER_NONE;
              end else begin
	         if (msg.smi_st == 1) begin
               if(msg.isCmdNcRdMsg() && overflow_buffer_test_2) begin
                 int random_order = $urandom_range(3,0);
                 `uvm_info("Vyshak","Vyshak and its a read so order will be anything",UVM_MEDIUM)
                 case(random_order)
                   0  : msg.smi_order = SMI_ORDER_REQUEST_WR_OBS;
                   1  : msg.smi_order = SMI_ORDER_NONE;
                   2  : msg.smi_order = SMI_ORDER_WRITE;
                   3  : msg.smi_order = SMI_ORDER_ENDPOINT;
                 endcase
               end else begin //if(msg.isCmdNcRdMsg() && overflow_buffer_test_2)
                 `uvm_info("Vyshak","Vyshak and is a write in genorder",UVM_MEDIUM);
                 randcase
                   wt_order_request.get_value()  : msg.smi_order = SMI_ORDER_REQUEST_WR_OBS ;
                   wt_order_endpoint.get_value() : msg.smi_order = SMI_ORDER_ENDPOINT;
                   wt_order_write.get_value()    : msg.smi_order = SMI_ORDER_WRITE;
                 endcase
               end
             end else begin
                randcase
                  wt_order_request.get_value()  : msg.smi_order = SMI_ORDER_REQUEST_WR_OBS ;
                  wt_order_write.get_value()    : msg.smi_order = SMI_ORDER_WRITE;
                  wt_order_none.get_value()     : msg.smi_order = SMI_ORDER_NONE;
                endcase
	         end // else: !if(msg.smi_st == 1)
          end // else: !if(rq_or_ep_order.exists(((msg.smi_src_id >> WSMINCOREPORTID)<<(WSMIMPF2-1))|(msg.smi_mpf2[WSMIMPF2-2:0])))
           end // else: !if(msg.smi_es == 1)
        end // if ( (msg.isCmdNcRdMsg()) || (msg.isCmdNcWrMsg()) )
        else 
            msg.smi_order = SMI_ORDER_NONE;
        
        

        `uvm_info("Vyshak",$sformatf("The msg.smi_order is %0d",msg.smi_order),UVM_MEDIUM);
   endfunction : genOrder


   function genConcMisc(smi_seq_item msg);
      smi_es_t         smi_es;
      smi_mpf2_t       mpf2;
      smi_vz_t         smi_vz;
    <% if(obj.testBench == 'dii') { %>
     `ifdef CDNS
      int    smi_tof_cdns;
     `endif 
    <% }  %>
      
      // generate mpf2 so ordering can be enforced
      if ($test$plusargs("pcie_test") && msg.isCmdNcWrMsg()) begin
         msg.smi_mpf2              = (1'b1 << (WSMIMPF2-1)) | posted_axid;
         msg.smi_mpf2_flowid_valid = 1'b1;
         msg.smi_mpf2_flowid       = posted_axid;
      end else begin
         assert(std::randomize(mpf2));                       // #Stimulus.DII.CMDreq.Mpf2    field occupies entire mpf2
         if($test$plusargs("same_mpf")) msg.smi_mpf2 = 8'b00000011;
         else begin
            msg.smi_mpf2              = (1'b1 << (WSMIMPF2-1)) | mpf2;   // set flowid_valid bit
            msg.smi_mpf2_flowid       = mpf2[WSMIMPF2-2:0];
         end
         msg.smi_mpf2_flowid_valid = 1'b1;
      end

      <% if(obj.testBench == 'dii') { %>
      `ifndef CDNS
      assert(std::randomize(msg.smi_tof) with {msg.smi_tof inside {SMI_TOF_CHI, SMI_TOF_AXI, SMI_TOF_ACE};});  
      `else // `ifndef CDNS
      assert(std::randomize(smi_tof_cdns) with {smi_tof_cdns inside {SMI_TOF_CHI, SMI_TOF_AXI, SMI_TOF_ACE};}); 
       msg.smi_tof=smi_tof_cdns;
      `endif // `ifndef CDNS ... `else ...
      <% } else {%>
      assert(std::randomize(msg.smi_tof) with {msg.smi_tof inside {SMI_TOF_CHI, SMI_TOF_AXI, SMI_TOF_ACE};}); 
      <% } %>

      if ( k_32b_cmdset.get_value() ) begin 
         msg.smi_st    = 1;
         msg.smi_ca    = $test$plusargs("force_dii_ca")?1:0;
         msg.smi_ac    = 0;
//         msg.smi_ch    = $test$plusargs("force_dii_ch")?1:0; // smi_ch will be random. CONC-7133
         if($test$plusargs("randomize_en")) msg.smi_en = $urandom_range(0,1);
         else msg.smi_en    = 0;
         if($test$plusargs("exclusive_txn")) msg.smi_es    = 1;
         else msg.smi_es    = 0;
         msg.smi_vz    = $test$plusargs("force_sys_dii_vs_error")?0:1;
      end else begin
           bit [WSMINCOREUNITID+WSMIMPF2-1:0] msg_sig;
           msg_sig = (msg.smi_ns<<(WSMINCOREUNITID+WSMIMPF2-1))|((msg.smi_src_ncore_unit_id)<<(WSMIMPF2-1))|(msg.smi_mpf2[WSMIMPF2-2:0]);
         if (rq_or_ep_order.exists(msg_sig)) begin
          `uvm_info($sformatf("%m"), $sformatf("ORDER DEBUG: UNQID=%p MsgType=%p Funit=%0d AXID=%0h Order=%0d Addr=%p ordered request exits",
                                                 {msg.smi_conc_msg_class, msg.smi_src_ncore_unit_id, msg.smi_msg_id},
                                                 msg.smi_msg_type, msg.smi_src_id >> WSMINCOREPORTID, msg.smi_mpf2[WSMIMPF2-2:0], msg.smi_order, msg.smi_addr), UVM_MEDIUM)
           smi_es = 0;
          // #Stimulus.DII.CMDreq.non_exclusive
         end else begin
            if ($test$plusargs("wt_cmd_exclusive")) begin
   
                  randcase
                  (100 - wt_cmd_exclusive.get_value()) :   smi_es = 0 ;  
                  wt_cmd_exclusive.get_value()         :   smi_es = 1 ;
                  endcase
            end
            else  assert(std::randomize(smi_es) with {smi_es dist { 0 := 90, 1 := 10 };});
         end
         msg.smi_es = performance_bw_test_enabled ? 0 : smi_es;  
         //#Stimulus.DII.CMDreq.Excel.CmType
         if(msg.smi_msg_type inside {CMD_CLN_VLD, CMD_CLN_SH_PER, CMD_CLN_INV, CMD_MK_INV}) begin
            msg.smi_es = 0;
         end                            
   
         if($value$plusargs("smi_storage_type=%0b", msg.smi_st))
             `uvm_info($sformatf("%m"), $sformatf("genConcMisc: SMI_STORAGE_TYPE = %b", msg.smi_st), UVM_MEDIUM)
         else 
             msg.smi_st = performance_bw_test_enabled ? 0 : (msg.smi_es ? 1'b1 : $urandom_range(0,1));  // #Stimulus.DII.CMDreq.Storage_type
         if($test$plusargs("es_disable_st_enable")) begin
            msg.smi_es = 0;
           msg.smi_st = 1;
         end
         if($test$plusargs("es_disable_st_disable")) begin
            msg.smi_es = 0;
           msg.smi_st = 0;
         end

         if(overflow_buffer_test_2 && !overflow_buffer && !new_scenario && !$test$plusargs("override") && !read_after_read_scenario && !write_after_write_scenario && !$test$plusargs("only_eo_ordered")) begin 
           msg.smi_es = 0;
           msg.smi_st = 1;

          if ($test$plusargs("wt_cmd_exclusive")) begin
                  randcase
                  (100 - wt_cmd_exclusive.get_value()) :   smi_es = 0 ;  
                  wt_cmd_exclusive.get_value()         :   smi_es = 1 ;
                  endcase
          end
            //$display("Vyshak and es bit is %0d",smi_es);
         end     
         msg.smi_ca = msg.smi_st ? 0 : (smi_es ? 1'b0 : $urandom_range(0,1));                                // #Stimulus.DII.CMDreq.Cacheable
//         msg.smi_ca = msg.smi_st ? 0 : $urandom_range(0,1);        // #Stimulus.DII.CMDreq.Cacheable
         msg.smi_ac = msg.smi_ca ? $urandom_range(0,1) : ((msg.smi_st == 0)&&(msg.smi_es == 0));   // #Stimulus.DII.CMDreq.Allocate
//         msg.smi_ch = $test$plusargs("force_dii_ch")?1:0;            // #Stimulus.DII.CMDreq.non_coherent. // CONC-7133. Not valid for NCORE 3.0,  3.1
         msg.smi_en = $urandom_range(0,1);                           // #Stimulus.DII.CMDreq.endian
         if($value$plusargs("smi_visibility=%0b", smi_vz)) begin
             msg.smi_vz = ((smi_vz == 0) && (smi_es == 0)) ? 0 : (smi_es ? 1'b1 : ((msg.smi_ac|msg.smi_ca)? 1'b0 : $urandom_range(0,1))); //#Stimulus.DII.CMDreq.Visibility
             if ((smi_vz == 0) && (smi_es == 1)) begin
                `uvm_info($sformatf("%m"), $sformatf("genConcMisc: SMI_VISIBILITY = %b. Did not use the smi_visibility plusarg", msg.smi_vz), UVM_MEDIUM)
             end else begin
             `uvm_info($sformatf("%m"), $sformatf("genConcMisc: SMI_VISIBILITY = %b", msg.smi_vz), UVM_MEDIUM)
             end
         end else begin
             msg.smi_vz = performance_bw_test_enabled ? 0 : (smi_es ? 1'b1 : ((msg.smi_ac|msg.smi_ca)? 1'b0 : $urandom_range(0,1))); //#Stimulus.DII.CMDreq.Visibility
         end
      end

      if(new_scenario_var == 1 || new_scenario_var == 2 ) msg.smi_vz = 0; 
      else if(read_after_read_scenario == 1 || write_after_write_scenario == 1 || $test$plusargs("only_eo_ordered")) msg.smi_vz = 1;
      else if ($test$plusargs("EWA_enable")) msg.smi_vz = 0;
      else if ($test$plusargs("VZ_enable")) msg.smi_vz = 1;
      
      if($test$plusargs("randomize_vz_st") ) begin
        msg.smi_vz = $urandom_range(0,1);
        msg.smi_st = $urandom_range(0,1);
      end

      `uvm_info("Vyshak",$sformatf("The msg.smi_vz is %0d", msg.smi_vz),UVM_HIGH); 

      if ( k_32b_cmdset.get_value() ) begin // vyshak check and remove for sys_dii
         msg.smi_st    = 1;
         msg.smi_ca    = $test$plusargs("force_dii_ca")?1:0;
         msg.smi_ac    = 0;
//         msg.smi_ch    = $test$plusargs("force_dii_ch")?1:0; // smi_ch will be random. CONC-7133
         if($test$plusargs("randomize_en")) msg.smi_en = $urandom_range(0,1);
         else msg.smi_en    = 0;
          if($test$plusargs("exclusive_txn")) msg.smi_es    = 1;
         else msg.smi_es    = 0;
         msg.smi_vz    = $test$plusargs("force_sys_dii_vs_error")?0:1;
      end 

      

      msg.smi_pr = $urandom ;                                   // #Stimulus.DII.CMDreq.Privilege
      // NOT order
      msg.smi_lk = SMI_LK_NOP ;                                 // #Stimulus.DII.CMDreq.lock
      msg.smi_rl = SMI_RL_TRANSPORT ;                           // #Stimulus.DII.CMDreq.Response_level
      msg.smi_tm = ($urandom_range(99,0) < k_dii_tm_weight_value) ? 1'b1 : 1'b0; // #Stimulus.DII.CMDreq.Trace_me

      //#Stimulus.DII.CMDreq.Non_secure
      msg.smi_ns      = $urandom;
      if($test$plusargs("same_ns_bit")) msg.smi_ns = 1;
      else if($test$plusargs("disable_ns")) msg.smi_ns = 0; 

      //msg.smi_mpf2_dtr_msg_id = $urandom ;                      // #Stimulus.DII.CMDreq.Mpf2    field occupies entire mpf2
      msg.smi_dest_id = $urandom ;                              // #Stimulus.DII.CMDreq.destination_id
    
     <% if(obj.testBench == 'dii') { %>
     `ifndef CDNS
      assert(std::randomize(msg.smi_tof) with {msg.smi_tof inside {SMI_TOF_CHI, SMI_TOF_AXI, SMI_TOF_ACE};});        // #Stimulus.DII.CMDreq.Tof
     `else // `ifndef CDNS
      assert(std::randomize(smi_tof_cdns) with {smi_tof_cdns inside {SMI_TOF_CHI, SMI_TOF_AXI, SMI_TOF_ACE};});        // #Stimulus.DII.CMDreq.Tof
       msg.smi_tof=smi_tof_cdns;
     `endif // `ifndef CDNS ... `else ...
      <% } else {%>
      assert(std::randomize(msg.smi_tof) with {msg.smi_tof inside {SMI_TOF_CHI, SMI_TOF_AXI, SMI_TOF_ACE};});        // #Stimulus.DII.CMDreq.Tof
      <% } %>

      //<% if (smiObj.WSMINDPAUX_EN) { %>
      //msg.smi_ndp_aux = $urandom ;                              // #Stimulus.DII.CMDreq.Ndp_user
      //<% } %>
      msg.smi_qos = $urandom ;                                  // #Stimulus.DII.CMDreq.Quality_of_service


   endfunction : genConcMisc

    //-------------------------------------------------------------
    //for writes

   function genDp(smi_seq_item msg);
       int intfsize;
       int smi_size;
       int upstream_beats;
       int numbeats;
       int  wSmiDPbe = (<%=obj.interfaces.smiTxInt[2].params.wSmiDPdata%>/64)*WSMIDPBEPERDW;
       //
       int smi_addr_size_offset;
       int smi_base_intfsize_offset;
       int smi_addr_intfsize_offset;
       //
       int min_content_byte;
       int max_content_byte;
       int be_counter;
       //
       smi_dp_protection_t prot;
       smi_dp_user_bit_t dp_user;   
       smi_dp_data_bit_t dp_data;
      
       //params to synthesize a concerto WRAP
       intfsize = (2**(msg.smi_intfsize + 3)) ;
       smi_size = (2**msg.smi_size);
       //
       upstream_beats = (((smi_size - 1) / intfsize) + 1);  //truncation
       numbeats = ((((upstream_beats * intfsize) - 1) / wSmiDPbe) + 1) ;     //a multiple of upstream intfsize
       //
       smi_addr_size_offset = (msg.smi_addr % smi_size) ;
       smi_base_intfsize_offset = ( (msg.smi_addr - smi_addr_size_offset) % intfsize ) ;
       smi_addr_intfsize_offset = (msg.smi_addr % intfsize) ;
       //
       if (msg.smi_tof == SMI_TOF_CHI) begin
          min_content_byte = ((msg.smi_st) ? smi_addr_intfsize_offset : (msg.smi_addr/smi_size)*smi_size) % intfsize;
       end else begin
          min_content_byte = ((msg.smi_mpf1_burst_type == INCR) ? smi_addr_intfsize_offset : (msg.smi_addr/smi_size)*smi_size) % intfsize;
       end
       if (explicit_incr(msg)) begin
	  max_content_byte = min_content_byte + axi_bytes_touched(msg) - 1;
       end else if (msg.smi_tof == SMI_TOF_CHI) begin
          if (msg.smi_st) begin
             max_content_byte = (((msg.smi_addr/smi_size)*smi_size)%intfsize) + (smi_size-min_content_byte) - 1;
          end else begin
	     max_content_byte = (((msg.smi_addr/smi_size)*smi_size)%intfsize) + smi_size - 1;
          end
       end else begin
	  max_content_byte = (min_content_byte + axi_bytes_touched(msg) - 1);
       end
       //
       msg.smi_dp_data       = new [numbeats];
       msg.smi_dp_be         = new [numbeats];
       msg.smi_dp_dbad       = new [numbeats];
       msg.smi_dp_protection = new [numbeats];
       msg.smi_dp_user       = new [numbeats];
      
       be_counter = (intfsize < (WXDATA/8)) ? (smi_addr_intfsize_offset&(~(intfsize-1))) : 0; //count bytes through all beats

       `uvm_info($sformatf("%m"), $sformatf("GENDP: addr: %p, intfsize: %0d, minbyte: %0h, maxbyte: %0h, numbeats: %0d, explicitIncr: %0d, st=%0d be_counter=%0d",
					    msg.smi_addr, intfsize, min_content_byte, max_content_byte, numbeats, explicit_incr(msg), msg.smi_st, be_counter), UVM_HIGH)

       for (int i = 0; i < numbeats  ; i++) begin  //each beat    
            assert(std::randomize(dp_data));       //#Stimulus.DII.DTWreq.Dp_data
            msg.smi_dp_data[i] = dp_data;
            msg.smi_dp_be[i]   = 'h0;  // clear BE by default
          
           //#Stimulus.DII.DTWreq.Byte_enable
           //full cacheline access => all bytes enabled
           if((msg.smi_msg_type inside {DTW_DATA_DTY}) && (msg.smi_st == 0)) 
               msg.smi_dp_be[i] = {((wSmiDPdata/64)*WSMIDPBEPERDW){1'b1}};    //all ones
           //Partial may have sparse enables among its bytes
           else begin
               for (int j=0; j < wSmiDPbe; j++) begin
                   if ((be_counter >= min_content_byte) && (be_counter <= max_content_byte)) begin 
                       if (k_alternate_be.get_value())    //deliberately sparse bes
                           msg.smi_dp_be[i][j] = (be_counter % 2);
                       else 
                           msg.smi_dp_be[i][j] = $urandom;
                   end else begin //byte is outside of the access here encoded 
                      msg.smi_dp_be[i][j] = 0;
		   end
                   be_counter = (be_counter+1)&((numbeats*(wSmiDPdata/64)*WSMIDPBEPERDW)-1);
               end
           end

           msg.smi_dp_last       = 1;
           //#Stimulus.DII.DTWreq.Poison
           //#Stimulus.DII.dbad.V3.dtwreq
           if( msg.smi_dp_be[i] != 0 ) begin    //may poison only when some byte enabled.
                randcase
                    (wt_dbad.get_value()) :         msg.smi_dp_dbad[i] = 1; 
                    (100 - wt_dbad.get_value()) :   msg.smi_dp_dbad[i] = 0;
                endcase
           end

	   // *** For NDP protection, any AIU's any NDP message should be OK ***
           <% if (obj.AiuInfo[0].concParams.cmdReqParams.wMProt > 0) { %>
           //#Stimulus.DII.DTWreq.Dp_protection
	   <% if (obj.AiuInfo[0].ResilienceInfo.fnResiliencyProtectionType == "ecc") { %>
                prot = SMI_NDP_PROTECTION_ECC ;
	   <% } else if (obj.AiuInfo[0].ResilienceInfo.fnResiliencyProtectionType == "parity") { %>
                prot = SMI_NDP_PROTECTION_PARITY ;
           <% } else { %>
                prot = SMI_NDP_PROTECTION_NONE ;
           <% } %>
           msg.smi_dp_protection[i] = prot;
           <% } %>

          //#Stimulus.DII.DTWreq.Dp_user
	  // dp_user will be set during pack
	   `uvm_info($sformatf("%m"), $sformatf("GENDP: num_beats=%0d, beat=%0d, BE=%p BAD=%p DATA=%p",
						numbeats, i, msg.smi_dp_be[i], msg.smi_dp_dbad[i], msg.smi_dp_data[i]), UVM_HIGH)
       end
   endfunction : genDp
   
    //--------------------------------------------------------------------


    task gen_smi__dtw(dii_txn txn, output smi_seq_item msg);
        bit gen_cmstatus_err; 
      <% if(obj.testBench == 'dii') { %>
       `ifdef CDNS
        int    smi_rl_cdns;
       `endif 
      <% }  %>
        msg = new();
        msg.do_copy(txn.smi_recd[eConcMsgCmdReq]);  //TODO constructed on base of cmd 'with everything'

        //dtw is rsp to cmd
        msg.smi_rmsg_id = txn.smi_recd[eConcMsgCmdReq].smi_msg_id;
        msg.smi_conc_rmsg_class = txn.smi_recd[eConcMsgCmdReq].smi_conc_msg_class;
        //(implicit: comes from same unit as cmd)
        msg.smi_targ_ncore_unit_id = smi_targ_ncore_unit_id(wt_wrong_dut_id_dtw);
        msg.smi_conc_msg_class = eConcMsgDtwReq;    //supply the msg class in order to generate the id
        if (msg.smi_targ_ncore_unit_id != dut_ncore_unit_id) begin
           `uvm_info($sformatf("%m"), $sformatf("Generated msg:%p wrong TARGID %p", msg.smi_conc_msg_class, msg.smi_targ_ncore_unit_id), UVM_LOW)
        end
        //#Stimulus.DII.DTWreq.MessageId
        gen_msg_id(msg);  //--pause here until dtw msgid available

        //#Stimulus.DII.DTWreq.Msg_type
        if(msg.smi_msg_type == CMD_WR_NC_FULL)begin
            randcase
            5 :     msg.smi_msg_type = DTW_DATA_DTY;
            4 :     msg.smi_msg_type = DTW_DATA_CLN ;
            1 :     msg.smi_msg_type = DTW_NO_DATA;
                endcase
        end
        else begin
            randcase
            9 :     msg.smi_msg_type = DTW_DATA_PTL;
            1 :     msg.smi_msg_type = DTW_NO_DATA;
                endcase
        end

     <% if(obj.testBench == 'dii') { %>
     `ifndef CDNS
        assert(std::randomize(msg.smi_rl) with { msg.smi_rl inside {SMI_RL_TRANSPORT, SMI_RL_COHERENCY}; }); //#Stimulus.DII.DTWreq.Response_level
     `else // `ifndef CDNS
        assert(std::randomize(smi_rl_cdns) with { smi_rl_cdns inside {SMI_RL_TRANSPORT, SMI_RL_COHERENCY}; }); //#Stimulus.DII.DTWreq.Response_level
      msg.smi_rl = smi_rl_cdns;
     `endif // `ifndef CDNS ... `else ...
      <% } else {%>
        assert(std::randomize(msg.smi_rl) with { msg.smi_rl inside {SMI_RL_TRANSPORT, SMI_RL_COHERENCY}; }); //#Stimulus.DII.DTWreq.Response_level
      <% } %>
       //#Stimulus.DII.DTWreq.Return_buffer_id
        msg.smi_rbid     = txn.smi_recd[eConcMsgStrReq].smi_rbid;
        //#Stimulus.DII.DTWreq.Primary_data
        msg.smi_prim     = 1;  

        assert(std::randomize(gen_cmstatus_err) with { gen_cmstatus_err dist {0 := 199, 1 := 1}; });
        if (gen_cmstatus_err) begin
           //#Stimulus.DII.DTWreq.CMStatus_error
           if ($urandom_range(0, 1) == 1) begin
              msg.smi_cmstatus = 8'h84;
           end else if ($urandom_range(0, 1) == 1) begin
              msg.smi_cmstatus = 8'h83;
           end
           `uvm_info($sformatf("%m"), $sformatf("Generating DTWReq with error cmstatus=%p", msg.smi_cmstatus), UVM_LOW)

           if (msg.smi_cmstatus == 8'h84) begin
              foreach (msg.smi_dp_dbad[i]) msg.smi_dp_dbad[i] = {wSmiDPdbad{1'b1}};
           end else begin
              bit dbad_seen = 0;
              foreach (msg.smi_dp_dbad[i]) begin
                 dbad_seen |= (msg.smi_dp_dbad[i] != 0);
              end
              if (dbad_seen == 0) begin
                 for (int i=0; i< msg.smi_dp_dbad.size(); i++) begin
                    if ((dbad_seen == 0) && (i == (msg.smi_dp_dbad.size() -1))) begin
                       msg.smi_dp_dbad[i] = {wSmiDPdbad{1'b1}};
                    end else begin
                       for (int j=0; j<wSmiDPdbad; j++) begin
                          msg.smi_dp_dbad[i] |= ($urandom_range(0, 1) << j);
                       end
                    end
                 end
              end
           end
        end
        msg.pack_smi_seq_item(.isRtl(0));
        msg.unpack_smi_unq_identifier();
       `uvm_info($sformatf("%m"), $sformatf("gen_smi__dtw done: %p", msg), UVM_HIGH)
    endtask : gen_smi__dtw


    task gen_smi__rsp(smi_seq_item cmd_msg, smi_seq_item msg, output smi_seq_item rsp_msg);
        rsp_msg = new();

        rsp_msg.smi_dp_present = 0;
        rsp_msg.smi_msg_tier = 0; 
        rsp_msg.smi_steer    = msg.smi_steer; 
        rsp_msg.smi_cmstatus = 0;  // TODO This needs to be driven to non-zero for error testing
        rsp_msg.smi_rmsg_id  = msg.smi_msg_id;
        rsp_msg.smi_msg_pri  = cmd_msg.smi_msg_pri;
       
        rsp_msg.smi_src_ncore_unit_id  = msg.smi_targ_ncore_unit_id;

        if(msg.isStrMsg()) begin
            rsp_msg.smi_msg_type           =  STR_RSP;
            rsp_msg.smi_targ_ncore_unit_id = smi_targ_ncore_unit_id(wt_wrong_dut_id_strrsp);
            rsp_msg.smi_tm                 = cmd_msg.smi_tm;
            rsp_msg.smi_rl       = SMI_RL_NONE; 
        end
        else if(msg.isDtrMsg()) begin
            rsp_msg.smi_msg_type =  DTR_RSP;
            rsp_msg.smi_targ_ncore_unit_id = smi_targ_ncore_unit_id(wt_wrong_dut_id_dtrrsp);
            rsp_msg.smi_tm                 = cmd_msg.smi_tm;
            rsp_msg.smi_rl       = SMI_RL_TRANSPORT; 
        end
        else if (msg.isDtwDbgReqMsg()) begin
            rsp_msg.smi_msg_type = DTW_DBG_RSP;
            rsp_msg.smi_targ_ncore_unit_id = smi_targ_ncore_unit_id(wt_wrong_dut_id_dtwdbgrsp);
            rsp_msg.smi_cmstatus = $urandom_range(0, 255);
            rsp_msg.smi_rl       = SMI_RL_NONE; 
        end
       //#Stimulus.DII.EventMsg
       else if(msg.isSysReqMsg()) begin
         smi_cmstatus_t cm_status;

         rsp_msg.smi_targ_ncore_unit_id = dut_ncore_unit_id;
         rsp_msg.smi_msg_type           = SYS_RSP;
         rsp_msg.smi_msg_qos            = cmd_msg.smi_msg_qos;
         rsp_msg.smi_tm                 = cmd_msg.smi_tm;
         void'(std::randomize(cm_status) with {cm_status dist {8'b0100_0000 :/ 50, 8'b0000_0011 :/ 50};});
         rsp_msg.smi_ndp_aux            = cmd_msg.smi_ndp_aux;
         rsp_msg.smi_cmstatus           = cm_status;

        end
        if (rsp_msg.smi_targ_ncore_unit_id != dut_ncore_unit_id) begin
           `uvm_info($sformatf("%m"), $sformatf("Generated msg:%p wrong TARGID %p", rsp_msg.smi_msg_type, rsp_msg.smi_targ_ncore_unit_id), UVM_LOW)
        end
        rsp_msg.unpack_smi_conc_msg_class();
        gen_msg_id(rsp_msg);

        rsp_msg.pack_smi_seq_item(.isRtl(0));
       `uvm_info($sformatf("%m"), $sformatf("gen_smi__rsp done: %p", rsp_msg), UVM_DEBUG)
    endtask : gen_smi__rsp


    /////////////////////////////////////////////////////////////////////////
    //       Produce and send txns
    //       == step through the state machine
    /////////////////////////////////////////////////////////////////////////
    task body;

        int txns_per_aiu;
        int extra_txns;
        smi_seq_item msg;
        dii_txn txn;

        s_txn = new(1);

     //index the constructs for these msgs.
     // must do in body , because (p_sequencer != null) only after this sequence has been start()ed
<% 
for (var i = 0; i < obj.nSmiTx; i++) { 
   for (var j = 0; j < obj.DiiInfo[0].smiPortParams.tx[i].params.fnMsgClass.length; j++) { 
%>
        s_msgid[str2class["<%=obj.DiiInfo[0].smiPortParams.tx[i].params.fnMsgClass[j]%>"]] = new(1) ;
        s_sending[str2class["<%=obj.DiiInfo[0].smiPortParams.tx[i].params.fnMsgClass[j]%>"]] = new(1) ;
        smi_seqs[str2class["<%=obj.DiiInfo[0].smiPortParams.tx[i].params.fnMsgClass[j]%>"]] = new() ;
        if(!$cast(smi_seqrs[str2class["<%=obj.DiiInfo[0].smiPortParams.tx[i].params.fnMsgClass[j]%>"]],p_sequencer.m_smi<%=i%>_rx_seqr))
            `uvm_error("dii_seq","p_sequencer.m_smi<%=i%>_rx_seqr type missmatch");
<% 
    } 
 }
%>
<% 
for (var i = 0; i < obj.nSmiRx; i++) { 
    for (var j = 0; j < obj.DiiInfo[0].smiPortParams.rx[i].params.fnMsgClass.length; j++) { 
%>
        s_msgid[str2class["<%=obj.DiiInfo[0].smiPortParams.rx[i].params.fnMsgClass[j]%>"]] = new(1) ;
        s_sending[str2class["<%=obj.DiiInfo[0].smiPortParams.rx[i].params.fnMsgClass[j]%>"]] = new(1) ;
        smi_seqs[str2class["<%=obj.DiiInfo[0].smiPortParams.rx[i].params.fnMsgClass[j]%>"]] = new() ;
        if(!$cast(smi_seqrs[str2class["<%=obj.DiiInfo[0].smiPortParams.rx[i].params.fnMsgClass[j]%>"]],p_sequencer.m_smi<%=i%>_tx_seqr))
            `uvm_error("dii_seq","p_sequencer.m_smi<%=i%>_tx_seqr type missmatch");
<% 
    } 
 }
%>


       //wait until after reset
       #10ns
       if (! $value$plusargs("DTW_REQ_MSG_Q_SIZE_LIMIT=%d",  dtw_req_msg_q_size_limit) ) begin
         dtw_req_msg_q_size_limit = 0;
      end
      `uvm_info($sformatf("%m"), $sformatf("DTW_REQ_MSG Q size limit is set to %0d", dtw_req_msg_q_size_limit), UVM_LOW)
      if (! $value$plusargs("DTW_REQ_MSG_Q_TIME_LIMIT=%d",  dtw_req_msg_q_time_limit) ) begin
         dtw_req_msg_q_time_limit = 0;
      end

       if (! $value$plusargs("DTR_RSP_MSG_Q_SIZE_LIMIT=%d",  dtr_rsp_msg_q_size_limit) ) begin
          dtr_rsp_msg_q_size_limit = 1;
       end
       `uvm_info($sformatf("%m"), $sformatf("DTR_RSP_MSG Q size limit is set to %0d", dtr_rsp_msg_q_size_limit), UVM_LOW)
       if (! $value$plusargs("DTR_RSP_MSG_Q_TIME_LIMIT=%d",  dtr_rsp_msg_q_time_limit) ) begin
          dtr_rsp_msg_q_time_limit = 10000;
       end

       if (! $value$plusargs("STR_RSP_MSG_Q_SIZE_LIMIT=%d",  str_rsp_msg_q_size_limit) ) begin
          str_rsp_msg_q_size_limit = 1;
       end
       if (! $value$plusargs("STR_RSP_MSG_Q_TIME_LIMIT=%d",  str_rsp_msg_q_time_limit) ) begin
          str_rsp_msg_q_time_limit = 10000;
       end
      

      if($test$plusargs("dii_sys_event_ev_timeout")) begin

      
         if (! $value$plusargs("k_ev_prot_timeout_val=%d",  sys_ev_prot_timeout_val) ) begin
          sys_ev_prot_timeout_val = 1;
         end
         sys_rsp_msg_q_time_limit = (sys_ev_prot_timeout_val* 4096 )+ $urandom_range(64,10);
         
         
      end else begin

         sys_rsp_msg_q_time_limit = $urandom_range(4000,0);

      end 

       `uvm_info($sformatf("%m"), $sformatf("DTR_RSP_MSG Q size limit is set to %0d", dtr_rsp_msg_q_size_limit), UVM_LOW)
       `uvm_info($sformatf("%m"), $sformatf("DTR_RSP_MSG Q time limit is set to %0d", dtr_rsp_msg_q_time_limit), UVM_LOW)
       `uvm_info($sformatf("%m"), $sformatf("STR_RSP_MSG Q size limit is set to %0d", str_rsp_msg_q_size_limit), UVM_LOW)
       `uvm_info($sformatf("%m"), $sformatf("STR_RSP_MSG Q time limit is set to %0d", str_rsp_msg_q_time_limit), UVM_LOW)

        //observe each bfm input interface
        if (! $value$plusargs("wait_cycles=%d", wait_cycle_step)) begin
           wait_cycle_step = 2000;
        end
        fork

            begin:wait_str_req_sys_req
               forever
               begin
                   smi_seq_item  msg;
                   dii_txn txn;
                   smi_seq_item  str_rsp_msg;          
                   smi_seq_item  dtw_msg;    
                   smi_seq_item  sys_rsp_msg;
                   int wt_wrong_dut_id_strrsp;
                  
                   smi_seqrs[eConcMsgStrReq].m_rx_analysis_fifo.get(msg); 
                   #0;	//ensure sequence gets the item after scb
                  if (msg.isStrMsg()) begin
                       s_txn.get(1);    //guard txn manipulation

                       txn = statemachine_q.get_txn(msg,seq_txn_id);
                       txn.add_msg(msg);

                       //generate all consequent msgs
                       gen_smi__rsp(txn.smi_recd[eConcMsgCmdReq], msg, str_rsp_msg);
                      `uvm_info($sformatf("%m"), $sformatf("pre-SEND str_rsp_msg: %p", str_rsp_msg), UVM_DEBUG)                   

                       //send all consequent msgs
                       txn.add_msg(str_rsp_msg);
                       tryRetire(txn, msg);  
                      `uvm_info($sformatf("%m"), $sformatf("SEND str_rsp_msg: %p", str_rsp_msg), UVM_HIGH)
                       str_rsp_msg_q.push_back(str_rsp_msg);//                   send(str_rsp_msg);
                       s_txn.put(1);

                       if(txn.smi_recd[eConcMsgCmdReq].isCmdNcWrMsg()) begin
                           //send all consequent msgs
                           s_txn.get(1);    //guard txn manipulation
                           gen_smi__dtw(txn, dtw_msg);  //shall not block <= dtw.msgid available <= cmd.msgid allocated
                           txn.add_msg(dtw_msg);
                           tryRetire(txn, msg);  
                           dtw_req_msg_q.push_back(dtw_msg);

                           s_txn.put(1);
                           //
                           //send(dtw_msg);
                       end
                  end
                  if (msg.isSysReqMsg()) begin

                      s_txn.get(1);
                      txn = statemachine_q.get_txn(msg,seq_txn_id);
                      txn.add_msg(msg);

                      // generate consequent msgs
                      gen_smi__rsp(msg, msg, sys_rsp_msg);
                      
                      txn.add_msg(sys_rsp_msg);
                      tryRetire(txn, msg);
                      
                      //send(sys_rsp_msg);
                      sys_rsp_msg_q.push_back(sys_rsp_msg);
                      
                      s_txn.put(1);
 
                  end
               
               end
           end:wait_str_req_sys_req

           begin:wait_dtr_req_dtw_dbg_req
               forever 
               begin
                   smi_seq_item msg;
                   dii_txn txn;
                   smi_seq_item dtr_rsp_msg;
                   smi_seq_item dtw_dbg_rsp_msg;
                  
                   smi_seqrs[eConcMsgDtrReq].m_rx_analysis_fifo.get(msg); 
                   #0;	//ensure sequence gets the item after scb
       
                   if (msg.isDtrMsg()) begin
                      s_txn.get(1);    //guard txn manipulation
                      //record this msg
                      txn = statemachine_q.get_txn(msg,seq_txn_id);
                      txn.add_msg(msg);

                      //generate all consequent msgs
                      gen_smi__rsp(txn.smi_recd[eConcMsgCmdReq], msg, dtr_rsp_msg);
                      
                      //send all consequent msgs
                      txn.add_msg(dtr_rsp_msg);
                      tryRetire(txn, msg);

                      //send(dtr_rsp_msg);
                      dtr_rsp_msg_q.push_back(dtr_rsp_msg);

                      s_txn.put(1);
                   end else if (msg.isDtwDbgReqMsg()) begin // if (msg.isDtrMsg())
                      s_txn.get(1);
                      txn = statemachine_q.get_txn(msg,seq_txn_id);
                      txn.add_msg(msg);

                      // generate consequent msgs
                      gen_smi__rsp(msg, msg, dtw_dbg_rsp_msg);
                      
                      txn.add_msg(dtw_dbg_rsp_msg);
                      tryRetire(txn, msg);
                      
                      // send(dtw_dbg_rsp_msg)
                      dtw_dbg_rsp_msg_q.push_back(dtw_dbg_rsp_msg);
                      
                      s_txn.put(1);
                   end
               end // forever begin
           end : wait_dtr_req_dtw_dbg_req

           begin:wait_tx_rsp    //also gets cmdrsps bcs on same channel
               forever
               begin
                   smi_seq_item msg;
                   dii_txn txn;

                   smi_seqrs[eConcMsgDtwRsp].m_rx_analysis_fifo.get(msg);
                   #0;	//ensure sequence gets the item after scb
                   
                   s_txn.get(1);    //guard txn manipulation
                   txn = statemachine_q.get_txn(msg,seq_txn_id);
                   txn.add_msg(msg);
                   tryRetire(txn, msg);
                   s_txn.put(1);
               end
           end: wait_tx_rsp

        join_none

        fork // handle message delay and out of order
           
         begin : CNT_DTW_WAIT_CYCLES
            smi_seq_item dtw_req_msg;

            forever begin
               ev_N_cycles.wait_trigger();
               dtw_req_msg_wait_cycles += ((dtw_req_msg_q.size() > 0) ? wait_cycle_step : 0);
               if ( (dtw_req_msg_q.size() > 0) && ((dtw_req_msg_wait_cycles%(16*wait_cycle_step)) == 1) ) begin
                  `uvm_info($sformatf("%m"), $sformatf("dtw_req_MSG_Q: size=%0d limit=%0d  wait cycles=%0d limit=%0d",
                                                       dtw_req_msg_q.size(), dtw_req_msg_q_size_limit, dtw_req_msg_wait_cycles, dtw_req_msg_q_time_limit), UVM_HIGH)
               end
            end
         end : CNT_DTW_WAIT_CYCLES

         begin : SEND_DTW_REQ
            smi_seq_item dtw_req_msg;
            forever begin
               ev_N_cycles.wait_trigger();
               if ((dtw_req_msg_q.size() > dtw_req_msg_q_size_limit) || (dtw_req_msg_wait_cycles > dtw_req_msg_q_time_limit)) begin
                  if (dtw_req_msg_q.size() > 0) begin
                     `uvm_info($sformatf("%m"), $sformatf("dtw_req_MSG_Q: Dispatching: size=%0d waited=%0d", dtw_req_msg_q.size(), dtw_req_msg_wait_cycles), UVM_MEDIUM)
                     for (int i=0; i<dtw_req_msg_q.size(); i++) begin
                        s_txn.get(1);  // guard txn manipulation
                        if ($test$plusargs("dtw_req_out_of_order")) begin
                           dtw_req_msg_q.shuffle();
                        end
                        dtw_req_msg = dtw_req_msg_q.pop_front();
                        s_txn.put(1);
                        send(dtw_req_msg);
                     end
                     dtw_req_msg_wait_cycles = 0;
                  end // if (dtw_req_msg_q.size() > 0)
               end // if ((dtw_req_msg_q.size() > dtw_req_msg_q_size_limit) || (dtw_req_msg_wait_cycles > dtw_req_msg_q_time_limit))
            end // forever begin
         end : SEND_DTW_REQ
         
         
   
         begin : CNT_DTR_WAIT_CYCLES
              smi_seq_item dtr_rsp_msg;

              forever begin
                 ev_N_cycles.wait_trigger();
                 dtr_rsp_msg_wait_cycles += ((dtr_rsp_msg_q.size() > 0) ? wait_cycle_step : 0);
                 if ( (dtr_rsp_msg_q.size() > 0) && ((dtr_rsp_msg_wait_cycles%(16*wait_cycle_step)) == 1) ) begin
                    `uvm_info($sformatf("%m"), $sformatf("DTR_RSP_MSG_Q: size=%0d limit=%0d  wait cycles=%0d limit=%0d",
                                                         dtr_rsp_msg_q.size(), dtr_rsp_msg_q_size_limit, dtr_rsp_msg_wait_cycles, dtr_rsp_msg_q_time_limit), UVM_HIGH)
                 end
              end
           end : CNT_DTR_WAIT_CYCLES

           begin : SEND_DTR
              smi_seq_item dtr_rsp_msg;
              forever begin
                 ev_N_cycles.wait_trigger();
                 if ((dtr_rsp_msg_q.size() > dtr_rsp_msg_q_size_limit) || (dtr_rsp_msg_wait_cycles > dtr_rsp_msg_q_time_limit)) begin
                    if (dtr_rsp_msg_q.size() > 0) begin
                       `uvm_info($sformatf("%m"), $sformatf("DTR_RSP_MSG_Q: Dispatching: size=%0d waited=%0d", dtr_rsp_msg_q.size(), str_rsp_msg_wait_cycles), UVM_HIGH)
                       for (int i=0; i<dtr_rsp_msg_q.size(); i++) begin
                          s_txn.get(1);  // guard txn manipulation
                          dtr_rsp_msg_q.shuffle();
                          dtr_rsp_msg = dtr_rsp_msg_q.pop_front();
                          s_txn.put(1);
                          send(dtr_rsp_msg);
                       end
                       dtr_rsp_msg_wait_cycles = 0;
                    end // if (dtr_rsp_msg_q.size() > 0)
                 end // if ((dtr_rsp_msg_q.size() > dtr_rsp_msg_q_size_limit) || (dtr_rsp_msg_wait_cycles > dtr_rsp_msg_q_time_limit))
              end // forever begin
           end : SEND_DTR

           begin : CNT_STR_WAIT_CYCLES
              forever begin
                 ev_N_cycles.wait_trigger();
                 str_rsp_msg_wait_cycles += ((str_rsp_msg_q.size() > 0) ? wait_cycle_step : 0);

                 if ( (str_rsp_msg_q.size() > 0) && ((str_rsp_msg_wait_cycles%(16*wait_cycle_step)) == 1) ) begin
                    `uvm_info($sformatf("%m"), $sformatf("STR_RSP_MSG_Q: size=%0d limit=%0d  wait cycles=%0d limit=%0d",
                                                      str_rsp_msg_q.size(), str_rsp_msg_q_size_limit,
                                                      str_rsp_msg_wait_cycles, str_rsp_msg_q_time_limit), UVM_HIGH)
                 end
              end
           end : CNT_STR_WAIT_CYCLES
           
           begin : SEND_STR                 
              smi_seq_item str_rsp_msg;
              forever begin
                 ev_N_cycles.wait_trigger();
                 if ((str_rsp_msg_q.size() > str_rsp_msg_q_size_limit) || (str_rsp_msg_wait_cycles > str_rsp_msg_q_time_limit)) begin
                    if (str_rsp_msg_q.size() > 0) begin
                       `uvm_info($sformatf("%m"), $sformatf("STR_RSP_MSG_Q: Dispatching: size=%0d waited=%0d",
                                                            str_rsp_msg_q.size(), str_rsp_msg_wait_cycles), UVM_HIGH)
                       for (int i=0; i<str_rsp_msg_q.size(); i++) begin
                          s_txn.get(1);  // guard txn manipulation
                          str_rsp_msg_q.shuffle();
                          str_rsp_msg = str_rsp_msg_q.pop_front();
                          s_txn.put(1);
                          send(str_rsp_msg);
                       end
                       str_rsp_msg_wait_cycles = 0;
                    end // if (str_rsp_msg_q.size() > 0)
                 end // if ((str_rsp_msg_q.size() > str_rsp_msg_q_size_limit) || (str_rsp_msg_wait_cycles > str_rsp_msg_q_time_limit))
              end // forever begin
           end : SEND_STR

           begin : CNT_DTW_DBG_WIAT_CYCLES
              forever begin
                 ev_N_cycles.wait_trigger();
                 dtw_dbg_rsp_msg_wait_cycles += ((dtw_dbg_rsp_msg_q.size() > 0) ? wait_cycle_step : 0);
              
                 if ( (dtw_dbg_rsp_msg_q.size() > 0) && ((dtw_dbg_rsp_msg_wait_cycles%(16*wait_cycle_step)) == 1) ) begin
                    `uvm_info($sformatf("%m"), $sformatf("DTW_DBG_RSP_MSG_Q: size=%0d wait cycles=%0d",
                                                      dtw_dbg_rsp_msg_q.size(), dtw_dbg_rsp_msg_wait_cycles), UVM_HIGH)
                 end
              end
           end : CNT_DTW_DBG_WIAT_CYCLES
           
           begin : SEND_DTW_DBG_RSP
              smi_seq_item dtw_dbg_rsp_msg;
              forever begin
              ev_N_cycles.wait_trigger();
                 // hard code q size_limit == 1, wait_cycles_limit == 200
                 if ((dtw_dbg_rsp_msg_q.size() > 1) || (dtw_dbg_rsp_msg_wait_cycles > 200)) begin
                    for (int i=0; i<dtw_dbg_rsp_msg_q.size(); i++) begin
                       `uvm_info($sformatf("%m"), $sformatf("DTW_DBG_RSP_MSG_Q: Dispatching: size%0d waited=%0d",
                                                            dtw_dbg_rsp_msg_q.size(), dtw_dbg_rsp_msg_wait_cycles), UVM_HIGH)
                       s_txn.get(1);
                       dtw_dbg_rsp_msg = dtw_dbg_rsp_msg_q.pop_front();
                       s_txn.put(1);
                       send(dtw_dbg_rsp_msg);
                    end
                 end // if ((dtw_dbg_rsp_msg_q.size() > 2) || (dtw_dbg_rsp_msg_wait_cycles > 200))
              end // forever begin
           end : SEND_DTW_DBG_RSP        

            begin : CNT_SYS_RSP_WIAT_CYCLES
              forever begin
                 ev_N_cycles.wait_trigger();
                 sys_rsp_msg_wait_cycles += ((sys_rsp_msg_q.size() > 0) ? wait_cycle_step : 0);
              
                 if ( (sys_rsp_msg_q.size() > 0) && ((sys_rsp_msg_wait_cycles%(16*wait_cycle_step)) == 1) ) begin
                    `uvm_info($sformatf("%m"), $sformatf("sys_RSP_MSG_Q: size=%0d wait cycles=%0d",
                                                      sys_rsp_msg_q.size(), sys_rsp_msg_wait_cycles), UVM_HIGH)
                 end
              end
           end : CNT_SYS_RSP_WIAT_CYCLES
           
           begin : SEND_SYS_RSP
              smi_seq_item sys_rsp_msg;
              forever begin
              ev_N_cycles.wait_trigger();
                 if ((sys_rsp_msg_q.size() > 0) && (sys_rsp_msg_wait_cycles > sys_rsp_msg_q_time_limit)) begin
                       `uvm_info($sformatf("%m"), $sformatf("SYS_RSP_MSG_Q: Dispatching: size%0d waited=%0d",
                                                            sys_rsp_msg_q.size(), sys_rsp_msg_wait_cycles), UVM_HIGH)
                       s_txn.get(1);
                       sys_rsp_msg = sys_rsp_msg_q.pop_front();
                       s_txn.put(1);
                       if(!$test$plusargs("dii_sys_event_ev_timeout")) begin
                        send(sys_rsp_msg);
                       end
                 end // if ((sys_rsp_msg_q.size() > 0) && (dtw_dbg_rsp_msg_wait_cycles > sys_rsp_msg_q_time_limit))
              end // forever begin
           end : SEND_SYS_RSP
        join_none
       
       //***************************************************************
       //model each aiu sending cmds.
       //***************************************************************
        if (pcie_test) begin
           txns_per_aiu = k_num_cmd.get_value();
        end else begin
           txns_per_aiu = ( k_num_cmd.get_value() / nAius ) ;
           extra_txns = ( k_num_cmd.get_value() % nAius ) ;
        end
       `uvm_info($sformatf("%m"), $sformatf("NAIUS=%0d Num CMDS=%0d CMS/AIU=%0d", nAius, k_num_cmd.get_value(), txns_per_aiu), UVM_LOW)

       fork
          begin: isolating_aiu_threads
             for(int i = 0; i < (pcie_test?1:nAius); i++) begin : aius_loop
                automatic int which_aiu = i;
                automatic int current_txns_per_aiu;
                fork
                   begin
                   <% if(obj.testBench == 'dii' || (obj.testBench == "fsys")) { %>
                   `ifdef VCS
                     inside_fork_join_none_vcs=1;    
                   `endif 
                   <% } %>

                      if(overflow_buffer_test ==1 && extra_txns != 0)begin
                        if(which_aiu == (nAius-1)) begin 
                          current_txns_per_aiu = txns_per_aiu + extra_txns;
                        end else begin
                          current_txns_per_aiu = txns_per_aiu;
                        end
                      end else  begin 
                        current_txns_per_aiu = txns_per_aiu;
                      end

                      for (int which_txn = 0; which_txn < current_txns_per_aiu; which_txn++) begin : txns
                         if (cmd_spacing > 0) begin
                            #(cmd_spacing*1ns);
                         end

                         if((which_aiu == (nAius-1)) && (which_txn == (current_txns_per_aiu-1)) && (overflow_buffer_test == 1)) begin
                           `uvm_info("Vyshak",$sformatf("Vyshak and value of which_aiu is %0d and which_txn is %0d",which_aiu,which_txn),UVM_MEDIUM);
                           overflow_buffer = 1;
                           `uvm_info("Vyshak",$sformatf("Vyshak and value of overflow_buffer is %0d",overflow_buffer),UVM_MEDIUM);
                           gen_smi__cmd(which_aiu,msg);
                           overflow_buffer = 0;
                           `uvm_info($sformatf("%m"), $sformatf("Vyshak and the write GEN_SMI__CMD: msg_type:%p order:%p alen:%p addr:%p unq_id:%p", msg.smi_msg_type, msg.smi_order, msg.smi_mpf1_alength, msg.smi_addr, msg.smi_unq_identifier), UVM_MEDIUM)
                         end    
                         else if (new_scenario == 1 || $test$plusargs("eo_wr_eo_rd")) begin 
                            if(which_txn == 1 || which_txn == 3 || which_txn == 5)begin

                                if(!$test$plusargs("eo_wr_eo_rd")) new_scenario_var = 2;
                                else if($test$plusargs("write_second")) write_cmd = 1;
                                else if($test$plusargs("read_second")) read_cmd = 1;
                                else if($test$plusargs("read_cmo_second")) read_cmo_cmd = 1;
                                
                                gen_smi__cmd(which_aiu,msg);
                            end else begin
                                
                              if(!$test$plusargs("eo_wr_eo_rd")) new_scenario_var = 1;
                              else if($test$plusargs("write_first")) write_cmd = 1;
                              else if($test$plusargs("read_first")) read_cmd = 1;

                              gen_smi__cmd(which_aiu,msg);
                            end
                          end 
                         else if(introduce_cmdreq_delay) begin 
                           if(which_txn % 2 !== 0) begin 
                             #(delay_time * 1ns);
                             gen_smi__cmd(which_aiu, msg);
                           end
                           else begin
                              gen_smi__cmd(which_aiu, msg);
                           end
                         end
                         else begin
                         gen_smi__cmd(which_aiu, msg);
                         end

                         `uvm_info($sformatf("%m"), $sformatf("GEN_SMI__CMD: aiu_id:%0d src_id:%p tof:%p msg_type:%p mpf2:%p st:%p order:%p alen:%p addr:%p unq_id:%p",
                                                              which_aiu, msg.smi_src_ncore_unit_id, msg.smi_tof, msg.smi_msg_type, msg.smi_mpf2, msg.smi_st,
                                                              msg.smi_order, msg.smi_mpf1_alength, msg.smi_addr, msg.smi_unq_identifier), UVM_LOW)
                                                               `uvm_info($sformatf("%m"), $sformatf("GEN_SMI__CMD : cmd_req = %p",  msg),UVM_LOW)
                         s_txn.get(1);    //guard txn manipulation
                         txn = statemachine_q.get_txn(msg, seq_txn_id); //creates a new txn
                          `uvm_info($sformatf("%m"), $sformatf("The SMICMD created in seq is : %p: cmd=%p unq_id=%p rsp_unq_id=%p  and corresponds to the txn %p \n with seq txn_id %p",
                                             msg.convert2string(), msg.smi_msg_type, msg.smi_unq_identifier, msg.smi_rsp_unq_identifier, txn, txn.txn_id), UVM_LOW)
                         txn.axi_expd.delete();
                         txn.add_msg(msg);
                         s_txn.put(1);
                         send(msg);
                        
                      end : txns
                      `uvm_info($sformatf("%m"), $sformatf("End seq for aiu %0d of %0d. Num Cmds:%0d", which_aiu, nAius, current_txns_per_aiu),UVM_MEDIUM)
        
                   end
                join_none
             end : aius_loop
              <% if(obj.testBench == 'dii' || (obj.testBench == "fsys")) { %>
            `ifndef VCS
             wait fork;
            `else // `ifndef VCS
             wait (inside_fork_join_none_vcs);
             `endif // `ifndef VCS ... `else ...
         <% } else {%>
             wait fork;
         <% } %>
          end : isolating_aiu_threads
       join
       
       `uvm_info($sformatf("%m"), "Waiting for all txns to retire ...",UVM_MEDIUM)
       wait(statemachine_q.txn_q.size() == 0);
       `uvm_info($sformatf("%m"), "Seq complete, exiting.",UVM_MEDIUM)

    endtask : body

    //release outgoing msg to interface.
    //threadsafe.  blocks iff driver not ready for next item.
    task send(smi_seq_item msg);
        smi_seq_item msg_copy;
        
        msg_copy = new();
        msg_copy.do_copy(msg);

        s_sending[msg_copy.smi_conc_msg_class].get(1); //critical region
        
        smi_seqs[msg_copy.smi_conc_msg_class].m_seq_item = msg_copy;
        smi_seqs[msg_copy.smi_conc_msg_class].return_response(smi_seqrs[msg_copy.smi_conc_msg_class]);
        `uvm_info($sformatf("%m"), $sformatf("released %p to smi... %p",
                                             msg_copy.smi_conc_msg_class, msg_copy), UVM_MEDIUM) 

        s_sending[msg_copy.smi_conc_msg_class].put(1); //critical region
    endtask : send
   

////////////////////////////////////////////////////////////////////////////////
endclass : dii_seq


`endif // DII_SEQ

