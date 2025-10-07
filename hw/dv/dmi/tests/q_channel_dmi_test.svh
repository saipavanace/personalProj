`ifndef Q_CHANNEL_DMI_TEST
`define Q_CHANNEL_DMI_TEST



////////////////////////////////////////////////////////////////////////////////
//
// DMI Test
//
////////////////////////////////////////////////////////////////////////////////

<%
    //all csr sequences
    var csr_seqs = [
        "dmi_csr_dmicecr_errThd_seq",
        "dmi_csr_dmicecr_errDetEn_seq",
        "dmi_csr_dmicecr_errInt_seq",
        "dmi_csr_dmicecr_sw_write_seq",
        "dmi_csr_dmicecr_noDetEn_seq",
        "dmi_csr_dmicecr_noIntEn_seq",
        "dmi_csr_dmicesr_rstNoVld_seq1",
        "dmi_csr_dmicesr_rstNoVld_seq2",
        "dmi_csr_elr_seq",
        "dmi_csr_dmiuuedr_MemErrDetEn_seq",
        "dmi_csr_dmiuuedr_wrProtErrDetEn_seq",
        "dmi_csr_dmiuuedr_rdProtErrDetEn_seq",
        "dmi_csr_dmiuecr_sw_write_seq",
        "dmi_csr_dmiuuedr_ProtErrThd_seq",
        "dmi_csr_dmiuecr_noDetEn_seq",
        "dmi_csr_dmiueir_ProtErrInt_seq",
        "dmi_csr_dmiueir_MemErrInt_seq",
        "dmi_csr_dmiuuedr_TransErrDetEn_seq",
        "dmi_csr_dmicesar_seq",
        "dmi_csr_dmiuesar_seq"
    ];
%>

class q_channel_dmi_test extends dmi_base_test;

  `uvm_component_utils(q_channel_dmi_test)

  uvm_event  forceClkgate;
  uvm_event  releaseClkgate;
  uvm_event toggle_rstn;
  dmi_seq    test_seq;
  virtual <%=obj.BlockId%>_q_chnl_if qc_if; 
  `ifdef USE_VIP_SNPS
  axi_slave_mem_response_sequence m_axi_slave_response_seq;
  uvm_event read_threshold_evnt=uvm_event_pool::get_global("read_threshold_evnt");
  `endif // USE_VIP_SNPS
  extern function new(string name = "q_channel_dmi_test", uvm_component parent = null);
  extern function void build_phase(uvm_phase phase);
  extern virtual task run_phase(uvm_phase phase);
  extern virtual task run_main(uvm_phase phase);

  virtual function void pre_abort();
    test_seq.print_pending_q();
  endfunction:pre_abort

endclass: q_channel_dmi_test

//------------------------------------------------------------------------------
// Constructor
//------------------------------------------------------------------------------
function q_channel_dmi_test::new(string name = "q_channel_dmi_test", uvm_component parent = null);
  super.new(name, parent);
 uvm_config_db#(virtual <%=obj.BlockId%>_q_chnl_if )::get(.cntxt(null),
                                        .inst_name( "" ),
                                        .field_name( "m_q_chnl_if" ),
                                        .value(qc_if ));

endfunction : new

function void q_channel_dmi_test::build_phase(uvm_phase phase);
     super.build_phase(phase);
     toggle_rstn = new("toggle_rstn");
     if (!uvm_config_db#(uvm_event)::get( .cntxt(null),
                                     .inst_name(""),
                                     .field_name( "toggle_rstn" ),
                                     .value( toggle_rstn ))) begin
        `uvm_error("Q-chnl test", "Event toggle_rstn is not found")
     end
endfunction:build_phase

//------------------------------------------------------------------------------
// Run Phase
//------------------------------------------------------------------------------

task q_channel_dmi_test::run_phase(uvm_phase phase);
    run_main(phase);
endtask : run_phase

task q_channel_dmi_test::run_main(uvm_phase phase);

  int   flush_count = 0;
  int   online_offline_count = 0;
  enum {CCP_OFFLINE, CCP_ONLINE, CCP_FLUSHING} ccp_state;
  semaphore ccp_control = new(1);
  uvm_objection uvm_obj = phase.get_objection();
  uvm_reg_sequence csr_seq;

  q_chnl_seq m_q_chnl_seq;
  int time_bw_Q_chnl_req = 100;

<% if (obj.INHOUSE_APB_VIP) { %>
  dmi_csr_init_seq csr_init_seq = dmi_csr_init_seq::type_id::create("csr_init_seq");
<% } %>

`ifdef INHOUSE_AXI
  axi_slave_read_seq   m_slave_read_seq   = axi_slave_read_seq::type_id::create("slave_read_seq");
  axi_slave_write_seq  m_slave_write_seq  = axi_slave_write_seq::type_id::create("slave_write_seq");

  m_slave_read_seq.prob_ace_rd_resp_error = prob_ace_rd_resp_error;
  m_slave_write_seq.prob_ace_wr_resp_error = prob_ace_wr_resp_error;

`endif
`ifdef USE_VIP_SNPS
  m_axi_slave_response_seq =  axi_slave_mem_response_sequence::type_id::create("m_axi_slave_response_seq");
  fork
    begin
      forever begin
        repeat(10) @(posedge u_csr_probe_vif.clk);
        if( (k_num_cmd > 10) && ( m_axi_slave_response_seq.axi_txn_count >= k_num_cmd-10) )begin
          repeat(4) @(posedge u_csr_probe_vif.clk);
          //End of test control for AXI VIP, modulo stall counters internal to VIP aren't aware of k_num_cmd value
          m_axi_slave_response_seq.eos_suspend_release  = 1;
          `uvm_info("run_main",$sformatf("Initiating end of simpulation :: Recorded axi_txn:%0d",m_axi_slave_response_seq.axi_txn_count),UVM_LOW)
          break;
        end
      end
    end
  join_none
  `endif // `ifdef USE_VIP_SNPS
  m_env.time_bw_Q_chnl_req = time_bw_Q_chnl_req;
  m_q_chnl_seq = q_chnl_seq::type_id::create("m_q_chnl_seq");

  test_seq = dmi_seq::type_id::create("test_seq");
  //instantiate the csr seq
  <% if (obj.INHOUSE_APB_VIP) { %>
     <% if(obj.testBench == 'dmi') { %>
     `ifndef VCS
       if (k_csr_seq) begin
     `else // `ifndef VCS
       if (k_csr_seq != "") begin
     `endif // `ifndef VCS ... `else ... 
     <% } else {%>
       if (k_csr_seq) begin
     <% } %>
    <% for (i in csr_seqs) { %>
        if (k_csr_seq == "<%=csr_seqs[i]%>")
            csr_seq = <%=csr_seqs[i]%>::type_id::create("csr_seq"); 
    <% } %>
    end
  <% } %>

<% if (obj.INHOUSE_APB_VIP) { %>
  csr_init_seq.model       = m_env.m_regs;
 <% if(obj.testBench == 'dmi') { %>
   `ifndef VCS
    if (k_csr_seq) begin
   `else // `ifndef VCS
    if (k_csr_seq != "") begin
   `endif // `ifndef VCS ... `else ... 
   <% } else {%>
    if (k_csr_seq) begin
   <% } %>
    csr_seq.model       = m_env.m_regs;
  end
<% } %>

  test_seq.k_atomic_opcode           = k_atomic_opcode ;
  test_seq.k_intfsize                = k_intfsize ;
  test_seq.k_back_to_back_types    = k_back_to_back_types;
  test_seq.k_back_to_back_chains   = k_back_to_back_chains;
  test_seq.k_force_allocate        = k_force_allocate;

  test_seq.use_last_dealloc        = use_last_dealloc;
  test_seq.use_adj_addr            = use_adj_addr;
  test_seq.mrd_use_last_mrd_pref        = mrd_use_last_mrd_pref;

  test_seq.k_num_cmd               = k_num_cmd;
  test_seq.k_num_addr              = k_num_addr;

  test_seq.k_min_reuse_q_size      = k_min_reuse_q_size;
  test_seq.k_max_reuse_q_size      = k_max_reuse_q_size;
  test_seq.k_reuse_q_pct           =  k_reuse_q_pct;

  test_seq.k_sp_base_addr          = k_sp_base_addr;
  test_seq.k_sp_max_addr           = k_sp_max_addr;
  test_seq.sp_ways                 = sp_ways;

  test_seq.k_full_cl_only          = k_full_cl_only;
  test_seq.k_force_size            = k_force_size;
  test_seq.k_force_mw              = k_force_mw;


  test_seq.n_pending_txn_mode      = n_pending_txn_mode;

  test_seq.tb_delay                = tb_delay;

`ifdef INHOUSE_AXI
      m_slave_read_seq.m_read_addr_chnl_seqr   = m_env.m_axi_slave_agent.m_read_addr_chnl_seqr;
      m_slave_read_seq.m_read_data_chnl_seqr   = m_env.m_axi_slave_agent.m_read_data_chnl_seqr;
      m_slave_read_seq.m_memory_model          = m_axi_memory_model;
      m_slave_write_seq.m_write_addr_chnl_seqr = m_env.m_axi_slave_agent.m_write_addr_chnl_seqr;
      m_slave_write_seq.m_write_data_chnl_seqr = m_env.m_axi_slave_agent.m_write_data_chnl_seqr;
      m_slave_write_seq.m_write_resp_chnl_seqr = m_env.m_axi_slave_agent.m_write_resp_chnl_seqr;
      m_slave_write_seq.m_memory_model         = m_axi_memory_model;
`endif

  uvm_config_db#(dmi_scoreboard)::set(uvm_root::get(), 
                                  "*", 
                                  "dmi_scb", 
                                  m_env.m_sb);

  fork
   uvm_obj.set_drain_time(null,1us);
`ifdef INHOUSE_AXI
   m_slave_read_seq.start(null);
   m_slave_write_seq.start(null);
`endif
`ifdef USE_VIP_SNPS
   m_axi_slave_response_seq.start(m_env.m_axi_system_env.slave[0].sequencer);
`endif // USE_VIP_SNPS
  join_none

 <% if(obj.INHOUSE_APB_VIP && obj.useCmc && obj.DmiInfo[obj.Id].ccpParams.useScratchPad) { %>
  csr_init_seq.ScPadEn       = sp_en;
  csr_init_seq.ScPadBaseAddr = ScPadBaseAddr;
  csr_init_seq.k_sp_base_addr= k_sp_base_addr;
  csr_init_seq.NumScPadWays  = NumScPadWays;
  csr_init_seq.ScPadSize     = sp_size;
<% if(obj.testBench == 'dmi') { %>
  `ifndef VCS
      if (k_csr_seq) begin
  `else // `ifndef VCS
      if (k_csr_seq != "") begin
  `endif // `ifndef VCS ... `else ... 
  <% } else {%>
      if (k_csr_seq) begin
  <% } %>
    csr_seq.ScPadEn       = sp_en;
    csr_seq.ScPadBaseAddr = ScPadBaseAddr;
    csr_seq.NumScPadWays  = NumScPadWays;
  end
 <% } %>
   csr_init_seq.cmc_policy = k_cmc_policy;

    <% if(obj.DmiInfo[0].useAtomic) { %>     
   if($test$plusargs("dmi_atomic_test_only") && k_cmc_policy[0] && k_cmc_policy[1] && !k_cmc_policy[4])begin
       test_seq.wt_mrd_rd_with_unq_cln.set_value(0);
       test_seq.wt_mrd_rd_with_shr_cln.set_value(0);
       test_seq.wt_mrd_rd_with_inv.set_value(0);
       test_seq.wt_mrd_rd_with_unq.set_value(0);
       test_seq.wt_mrd_flush.set_value(0); 
       test_seq.wt_mrd_cln.set_value(0); 
       test_seq.wt_mrd_inv.set_value(0); 
       test_seq.wt_mrd_pref.set_value(0); 
       test_seq.wt_dtw_no_dt.set_value(0);
       test_seq.wt_dtw_dt_ptl.set_value(0);
       test_seq.wt_dtw_dt_dty.set_value(0);
       test_seq.wt_dtw_dt_cln.set_value(0); 
       test_seq.wt_cmd_cln_inv.set_value(0); 
       test_seq.wt_cmd_cln_vld.set_value(0); 
       test_seq.wt_cmd_cln_ShPsist.set_value(0); 
       test_seq.wt_cmd_mk_inv.set_value(0); 
       test_seq.wt_cmd_pref.set_value(0); 
       test_seq.wt_cmd_rd_nc.set_value(0);
       test_seq.wt_cmd_wr_nc_ptl.set_value(0); 
       test_seq.wt_cmd_wr_nc_full.set_value(0);
       test_seq.wt_dtw_mrg_mrd_ucln.set_value(0);
       test_seq.wt_dtw_mrg_mrd_udty.set_value(0);
       test_seq.wt_dtw_mrg_mrd_inv.set_value(0);
    end
    else if(!$test$plusargs("add_atomic") || !(k_cmc_policy[0] && k_cmc_policy[1] && !k_cmc_policy[4]))begin
        test_seq.wt_cmd_rd_atm.set_value(0);
        test_seq.wt_cmd_wr_atm.set_value(0);
        test_seq.wt_cmd_swap_atm.set_value(0);
        test_seq.wt_cmd_cmp_atm.set_value(0);
   end
 <% } %>

 <% if(obj.INHOUSE_APB_VIP) { %>
  phase.raise_objection(this, "Start dmi_csr_init_seq");
  `uvm_info("run_main", "dmi_csr_init_seq started",UVM_DEBUG)
  csr_init_seq.start(m_env.m_apb_agent.m_apb_sequencer);
  `uvm_info("run_main", "dmi_csr_init_seq finished",UVM_DEBUG)
  #100ns;
  phase.drop_objection(this, "Finish dmi_csr_init_seq");
 <% } %>

//Sanity test
if($test$plusargs("dmi_qchannel_sanity_test"))begin
  fork
      begin
         phase.raise_objection(this, "Start dmi_qchannel_sanity_test run phase");
         `uvm_info("dmi_qchannel_sanity_test", "test_seq objection raised",UVM_DEBUG)
          <% if(obj.testBench == 'dmi') { %>
          `ifndef VCS
            if (k_csr_seq) begin
          `else // `ifndef VCS
            if (k_csr_seq != "") begin
          `endif // `ifndef VCS ... `else ... 
          <% } else {%>
            if (k_csr_seq) begin
          <% } %>
           `uvm_info("dmi_qchannel_sanity_test","Waiting for CSR seq to set the control register",UVM_DEBUG)
           ev.wait_ptrigger();
           `uvm_info("dmi_qchannel_sanity_test","Waiting Completed for CSR seq to set the control register",UVM_DEBUG)
         end
         `uvm_info("dmi_qchannel_sanity_test","test_seq started",UVM_DEBUG)
         test_seq.start(m_env.m_smi_agent.m_smi_virtual_seqr);
         this.cache_addr_list = test_seq.cache_addr_list;
         `uvm_info("dmi_qchannel_sanity_test","test_seq completed",UVM_DEBUG)
         `ifdef ATOMIC_BRINGUP
           #1ms;
         `endif
         phase.drop_objection(this, "Finish dmi_qchannel_sanity_test run phase");
         `uvm_info("dmi_qchannel_sanity_test", "test_seq objection dropped",UVM_DEBUG)
      end
      <% if (obj.INHOUSE_APB_VIP) { %>
         <% if(obj.testBench == 'dmi') { %>
          `ifndef VCS
            if (k_csr_seq) begin
          `else // `ifndef VCS
            if (k_csr_seq != "") begin
          `endif // `ifndef VCS ... `else ... 
          <% } else {%>
            if (k_csr_seq) begin
          <% } %>
            phase.raise_objection(this, "Start csr_seq run phase");
           `uvm_info("dmi_qchannel_sanity_test", "csr_seq started",UVM_DEBUG)
           //csr_seq.start(m_env.m_apb_agent.m_apb_sequencer);
           `uvm_info("dmi_qchannel_sanity_test", "csr_seq finished",UVM_DEBUG)
            phase.drop_objection(this, "Finish csr_seq run phase");
         end
      <% } %>
   join
  `uvm_info("dmi_qchannel_sanity_test", "fork join completed",UVM_DEBUG)
  
  <% if(obj.DmiInfo[obj.Id].usePma) { %>
    //Starting Q channel sequence
    phase.raise_objection(this, $sformatf("Start q_cnl_seq"));
    #10ns;       
    `uvm_info("dmi_qchannel_sanity_test", "Q_SEQ_START",UVM_DEBUG)
     m_q_chnl_seq.start(m_env.m_q_chnl_agent.m_q_chnl_seqr);
    `uvm_info("dmi_qchannel_sanity_test", "Q_SEQ_END",UVM_DEBUG)
     phase.drop_objection(this, $sformatf("Finish q_cnl_seq"));
  <% } %>
end

//dmi_qchannel_req_during_cmd_test 
if($test$plusargs("dmi_qchannel_req_during_cmd_test"))begin
int i;
  fork
    begin
       phase.raise_objection(this, "Start dmi_qchannel_req_during_cmd_test run phase");
       `uvm_info("dmi_qchannel_req_during_cmd_test", "test_seq objection raised",UVM_DEBUG)
       <% if(obj.testBench == 'dmi') { %>
          `ifndef VCS
           if (k_csr_seq) begin
          `else // `ifndef VCS
           if (k_csr_seq != "") begin
          `endif // `ifndef VCS ... `else ... 
          <% } else {%>
           if (k_csr_seq) begin
          <% } %>
         `uvm_info("dmi_qchannel_req_during_cmd_test","Waiting for CSR seq to set the control register",UVM_DEBUG)
         ev.wait_ptrigger();
         `uvm_info("dmi_qchannel_req_during_cmd_test","Waiting Completed for CSR seq to set the control register",UVM_DEBUG)
       end
       `uvm_info("dmi_qchannel_req_during_cmd_test","test_seq started",UVM_DEBUG)
       test_seq.start(m_env.m_smi_agent.m_smi_virtual_seqr);
       this.cache_addr_list = test_seq.cache_addr_list;
       `uvm_info("dmi_qchannel_req_during_cmd_test","test_seq completed",UVM_DEBUG)
       `ifdef ATOMIC_BRINGUP
         #1ms;
       `endif
       phase.drop_objection(this, "Finish dmi_qchannel_req_during_cmd_test run phase");
       `uvm_info("dmi_qchannel_req_during_cmd_test", "test_seq objection dropped",UVM_DEBUG)
    end
    begin
      <% if(obj.DmiInfo[obj.Id].usePma) { %>
       repeat(20)  @(posedge qc_if.clk); ///initial delay 
       repeat(5) begin
        wait(qc_if.QACTIVE); 
        repeat(5)  @(posedge qc_if.clk); ///delay
        //Starting Q channel sequence
        phase.raise_objection(this, $sformatf("Start q_cnl_seq"));
        #50ns;       
        `uvm_info("dmi_qchannel_req_during_cmd_test", "Q_SEQ_START",UVM_DEBUG)
         m_q_chnl_seq.start(m_env.m_q_chnl_agent.m_q_chnl_seqr);
        `uvm_info("dmi_qchannel_req_during_cmd_test", "Q_SEQ_END",UVM_DEBUG)
         phase.drop_objection(this, $sformatf("Finish q_cnl_seq"));
       end
      <% } %>
    end 
    <% if (obj.INHOUSE_APB_VIP) { %>
       <% if(obj.testBench == 'dmi') { %>
          `ifndef VCS
            if (k_csr_seq) begin
          `else // `ifndef VCS
            if (k_csr_seq != "") begin
          `endif // `ifndef VCS ... `else ... 
          <% } else {%>
            if (k_csr_seq) begin
          <% } %>
          phase.raise_objection(this, "Start csr_seq run phase");
         `uvm_info("dmi_qchannel_req_during_cmd_test", "csr_seq started",UVM_DEBUG)
         //csr_seq.start(m_env.m_apb_agent.m_apb_sequencer);
         `uvm_info("dmi_qchannel_req_during_cmd_test", "csr_seq finished",UVM_DEBUG)
          phase.drop_objection(this, "Finish csr_seq run phase");
       end
    <% } %>
   join
  `uvm_info("dmi_qchannel_req_during_cmd_test", "fork join completed",UVM_DEBUG)
  `uvm_info("dmi_qchannel_req_during_cmd_test", $sformatf("my_debug = %0d",++i),UVM_DEBUG)
end

//dmi_qchannel_req_between_cmd_test  //seed- 53220164
if($test$plusargs("dmi_qchannel_req_between_cmd_test"))begin
  int q_active;
  fork
  begin  //1st spawned process by fork
    phase.raise_objection(this, "Start dmi_qchannel_req_between_cmd_test run phase");
    `uvm_info("dmi_qchannel_req_between_cmd_test", "test_seq objection raised",UVM_DEBUG)
    <% if(obj.testBench == 'dmi') { %>
          `ifndef VCS
            if (k_csr_seq) begin
          `else // `ifndef VCS
            if (k_csr_seq != "") begin
          `endif // `ifndef VCS ... `else ... 
          <% } else {%>
            if (k_csr_seq) begin
          <% } %>
      `uvm_info("dmi_qchannel_req_between_cmd_test","Waiting for CSR seq to set the control register",UVM_DEBUG)
      ev.wait_ptrigger();
      `uvm_info("dmi_qchannel_req_between_cmd_test","Waiting Completed for CSR seq to set the control register",UVM_DEBUG)
    end
    `uvm_info("dmi_qchannel_req_between_cmd_test","test_seq started",UVM_DEBUG)
    test_seq.start(m_env.m_smi_agent.m_smi_virtual_seqr);
    this.cache_addr_list = test_seq.cache_addr_list;
    `uvm_info("dmi_qchannel_req_between_cmd_test","test_seq completed",UVM_DEBUG)
    `ifdef ATOMIC_BRINGUP
      #1ms;
    `endif
    // phase.phase_done.set_drain_time(this,2000);
    phase.drop_objection(this, "Finish dmi_qchannel_req_between_cmd_test run phase");
    `uvm_info("dmi_qchannel_req_between_cmd_test", "test_seq objection dropped",UVM_DEBUG)
  end  //end of 1st process 
  begin        //2nd spawned process by fork
     repeat(15) begin
        wait(!qc_if.QACTIVE); 
        repeat(2)  @(posedge qc_if.clk); ///delay
        <% if(obj.DmiInfo[obj.Id].usePma) { %>
          //Starting Q channel sequence
          phase.raise_objection(this, $sformatf("Start q_cnl_seq")); 
          //#5ns;       
          `uvm_info("dmi_qchannel_req_between_cmd_test", "Q_SEQ_START",UVM_DEBUG)
           m_q_chnl_seq.start(m_env.m_q_chnl_agent.m_q_chnl_seqr);
          `uvm_info("dmi_qchannel_req_between_cmd_test", "Q_SEQ_END",UVM_DEBUG)
           phase.drop_objection(this, $sformatf("Finish q_cnl_seq"));
         <% } %>
         wait(qc_if.QACTIVE);
         `uvm_info("q_active_transition_count",$sformatf("count = %0d",++q_active),UVM_DEBUG)
     end  
  end  //end of 2nd process
  `uvm_info("dmi_qchannel_req_between_cmd_test", "fork join completed",UVM_DEBUG)
  join
end 
 
 //dmi_qchannel_multiple_request_test  //seed- 53220164 //assert failed
if($test$plusargs("dmi_qchannel_multiple_request_test"))begin
 int q_active;
 fork
    begin  //1st spawned process by fork
      phase.raise_objection(this, "Start dmi_qchannel_multiple_request_test run phase");
      `uvm_info("dmi_qchannel_multiple_request_test", "test_seq objection raised",UVM_DEBUG)
      <% if(obj.testBench == 'dmi') { %>
        `ifndef VCS
          if (k_csr_seq) begin
        `else // `ifndef VCS
          if (k_csr_seq != "") begin
        `endif // `ifndef VCS ... `else ... 
        <% } else {%>
          if (k_csr_seq) begin
        <% } %>
        `uvm_info("dmi_qchannel_multiple_request_test","Waiting for CSR seq to set the control register",UVM_DEBUG)
        ev.wait_ptrigger();
        `uvm_info("dmi_qchannel_multiple_request_test","Waiting Completed for CSR seq to set the control register",UVM_DEBUG)
      end
      `uvm_info("dmi_qchannel_multiple_request_test","test_seq started",UVM_DEBUG)
      test_seq.start(m_env.m_smi_agent.m_smi_virtual_seqr);
      this.cache_addr_list = test_seq.cache_addr_list;
      `uvm_info("dmi_qchannel_multiple_request_test","test_seq completed",UVM_DEBUG)
      `ifdef ATOMIC_BRINGUP
        #1ms;
      `endif
      // phase.phase_done.set_drain_time(this,2000);
      phase.drop_objection(this, "Finish dmi_qchannel_multiple_request_test run phase");
      `uvm_info("dmi_qchannel_multiple_request_test", "test_seq objection dropped",UVM_DEBUG)
    end  //end of 1st process 
    begin      
       repeat(25) begin
          wait(!qc_if.QACTIVE);
          repeat(2)  @(posedge qc_if.clk); ///delay
          <% if(obj.DmiInfo[obj.Id].usePma) { %>
          //Starting Q channel sequence
          repeat($urandom_range(2,10)) begin
          phase.raise_objection(this, $sformatf("Start q_cnl_seq")); 
          //#5ns;       
          `uvm_info("dmi_qchannel_multiple_request_test", "Q_SEQ_START",UVM_DEBUG)
          m_q_chnl_seq.start(m_env.m_q_chnl_agent.m_q_chnl_seqr);
          `uvm_info("dmi_qchannel_multiple_request_test", "Q_SEQ_END",UVM_DEBUG)
          phase.drop_objection(this, $sformatf("Finish q_cnl_seq"));
          end
          <% } %>
          wait(qc_if.QACTIVE);
          `uvm_info("q_active_transition_count",$sformatf("count = %0d",++q_active),UVM_DEBUG)
       end 
    end  //end of 2nd process
  join
  `uvm_info("dmi_qchannel_multiple_request_test", "fork join completed",UVM_DEBUG)
end

//dmi_qchannel_reset_test  //seed- 53220164
if($test$plusargs("dmi_qchannel_reset_test"))begin
  int q_active;
  fork
  begin  //1st spawned process by fork
    phase.raise_objection(this, "Start dmi_qchannel_reset_test run phase");
    `uvm_info("dmi_qchannel_reset_test", "test_seq objection raised",UVM_DEBUG)
     <% if(obj.testBench == 'dmi') { %>
      `ifndef VCS
        if (k_csr_seq) begin
      `else // `ifndef VCS
        if (k_csr_seq != "") begin
      `endif // `ifndef VCS ... `else ... 
      <% } else {%>
        if (k_csr_seq) begin
      <% } %>
      `uvm_info("dmi_qchannel_reset_test","Waiting for CSR seq to set the control register",UVM_DEBUG)
      ev.wait_ptrigger();
      `uvm_info("dmi_qchannel_reset_test","Waiting Completed for CSR seq to set the control register",UVM_DEBUG)
    end
    `uvm_info("dmi_qchannel_reset_test","test_seq started",UVM_DEBUG)
<% if(obj.DmiInfo[obj.Id].usePma) { %>
    wait(!qc_if.QACTIVE); 
<% } %>
    test_seq.start(m_env.m_smi_agent.m_smi_virtual_seqr);
    this.cache_addr_list = test_seq.cache_addr_list;
    `uvm_info("dmi_qchannel_reset_test","test_seq completed",UVM_DEBUG)
    `ifdef ATOMIC_BRINGUP
      #1ms;
    `endif
    // phase.phase_done.set_drain_time(this,2000);
    phase.drop_objection(this, "Finish dmi_qchannel_reset_test run phase");
    `uvm_info("dmi_qchannel_reset_test", "test_seq objection dropped",UVM_DEBUG)
  end  //end of 1st process 
<% if(obj.DmiInfo[obj.Id].usePma) { %>
  begin        //2nd spawned process by fork
     repeat(1) begin
        wait(qc_if.QACTIVE); 
        wait(!qc_if.QACTIVE); 
        wait(qc_if.QACTIVE); 
        wait(!qc_if.QACTIVE); 
        repeat(2)  @(posedge qc_if.clk); ///delay
          //Starting Q channel sequence
          phase.raise_objection(this, $sformatf("Start q_cnl_seq")); 
          wait(m_env.m_sb.numCmd == k_num_cmd);
          <% if(!obj.USE_VIP_SNPS) { %>
          wait(!test_seq.aiu_txn_count)
          <% }%>
          `uvm_info("dmi_qchannel_reset_test", "Q_SEQ_START",UVM_DEBUG)
           m_q_chnl_seq.start(m_env.m_q_chnl_agent.m_q_chnl_seqr);
          `uvm_info("dmi_qchannel_reset_test", "Q_SEQ_END",UVM_DEBUG)
           phase.drop_objection(this, $sformatf("Finish q_cnl_seq"));
         `uvm_info("q_active_transition_count",$sformatf("count = %0d",++q_active),UVM_DEBUG)
     end  
  end  //end of 2nd process
  begin    
     repeat(1) begin
      wait(!qc_if.QACCEPTn && !qc_if.QREQn && !qc_if.QACTIVE);
       repeat(2)@(posedge qc_if.clk); 
       #30ns;//repeat(3)@(posedge qc_if.clk); 
       toggle_rstn.trigger();
       #30ns;//repeat(3)@(posedge qc_if.clk); 
       toggle_rstn.trigger();
       phase.raise_objection(this, "Start dmi_csr_init_seq");
       `uvm_info("run_main", "dmi_csr_init_seq started",UVM_DEBUG)
       repeat(2)@(posedge qc_if.clk); 
       test_seq.kill();
       m_env.m_smi_agent.m_smi_virtual_seqr.stop_sequences();
       csr_init_seq.start(m_env.m_apb_agent.m_apb_sequencer);
       `uvm_info("run_main", "dmi_csr_init_seq finished",UVM_DEBUG)
       #100ns;
       test_seq.start(m_env.m_smi_agent.m_smi_virtual_seqr);
       this.cache_addr_list = test_seq.cache_addr_list;
       phase.drop_objection(this, $sformatf("Finish q_cnl_seq"));
     end
  end
<% } %>
  join
  `uvm_info("dmi_qchannel_reset_test", "fork join completed",UVM_DEBUG)
end

endtask : run_main

////////////////////////////////////////////////////////////////////////////////

`endif // Q_CHANNEL_DMI_TEST


