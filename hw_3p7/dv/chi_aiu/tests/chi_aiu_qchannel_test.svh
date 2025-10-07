<%
    //all csr sequences
    var csr_seqs = [
        "chi_aiu_csr_caiuuedr_TransErrDetEn_seq"
    ];
%>


class chi_aiu_qchannel_test extends chi_aiu_base_test;

  `uvm_component_utils(chi_aiu_qchannel_test)

  //properties
  addr_trans_mgr     m_addr_mgr;
  chi_aiu_unit_args  m_args;
  chi_aiu_ral_addr_map_seq  addr_map_seq;
  uvm_reg_sequence   csr_seq;
  q_chnl_seq         m_q_chnl_seq;
  virtual <%=obj.BlockId%>_q_chnl_if qc_if; 
  uvm_event_pool ev_pool = uvm_event_pool::get_global_pool();
  uvm_event ev = ev_pool.get("ev");
  uvm_event all_txn_done_ev = ev_pool.get("all_txn_done_ev");
  uvm_event toggle_rstn;
  <%if (obj.testBench != "fsys") { %>
  virtual chi_aiu_dut_probe_if u_dut_probe_vif;
  <% } %>
  int num_trans;
  int k_num_snoop;
  int k_writedatacancel_pct;
`ifdef USE_VIP_SNPS
  //snps_chi_aiu_vseq  snps_vseq; 
  <%=obj.BlockId%>_chi_aiu_vseq_pkg::snps_chi_aiu_vseq#(<%=obj.AiuInfo[obj.Id].FUnitId%>)   m_snps_chi<%=obj.Id%>_vseq;
`else   
  chi_aiu_vseq#(<%=obj.AiuInfo[obj.Id].FUnitId%>)   m_vseq;
`endif  


`ifdef USE_VIP_SNPS
  svt_chi_rn_transaction_random_sequence svt_chi_rn_transaction_random_seq;
  svt_chi_link_service_activate_sequence svt_chi_link_service_activate_seq;
  svt_chi_link_service_deactivate_sequence svt_chi_link_service_deactivate_seq;
  cust_svt_report_catcher syncdvmop_error_catcher;
   // `ifndef SVT_CHI_ISSUE_A_ENABLE
    `ifdef SVT_CHI_ISSUE_B_ENABLE
      svt_chi_protocol_service_coherency_entry_sequence coherency_entry_seq;
      svt_chi_protocol_service_coherency_exit_sequence coherency_exit_seq;
    `endif
    
  bit vip_snps_non_coherent_txn = 0;
  bit vip_snps_coherent_txn = 0;
  int vip_snps_seq_length = 5;
`endif //USE_VIP_SNPS




  //Interface Methods
  extern function new(
    string name = "chi_aiu_qchannel_test",
    uvm_component parent = null);
  extern function void build_phase(uvm_phase phase);
  extern function void connect_phase(uvm_phase phase);
  extern function void report_phase(uvm_phase phase);
  extern function void check_phase(uvm_phase phase);
  //Run task
  extern task run_phase(uvm_phase phase);

  //Helper methods
  extern function void set_testplusargs();

  virtual function void pre_abort();
`ifndef USE_VIP_SNPS
    m_vseq.print_pending_txns();
`endif
    m_system_bfm_seq.end_of_test_checks();
    extract_phase(null);
    report_phase(null);
  endfunction : pre_abort
`ifdef USE_VIP_SNPS
     extern task construct_lk_down_seq_snps();
     extern task construct_lk_seq_snps();
   // `ifndef SVT_CHI_ISSUE_A_ENABLE
    `ifdef SVT_CHI_ISSUE_B_ENABLE
        extern task construct_coherency_entry_snps();
        extern task construct_coherency_exit_snps();
    `endif
`else
     extern task construct_lk_down_seq(ref chi_txn_seq#(chi_lnk_seq_item) m_lnk_seq);
`endif

endclass: chi_aiu_qchannel_test

function chi_aiu_qchannel_test::new(
  string name = "chi_aiu_qchannel_test",
  uvm_component parent = null);
  super.new(name, parent);
  uvm_config_db#(virtual <%=obj.BlockId%>_q_chnl_if )::get(.cntxt(null),
                                        .inst_name( "" ),
                                        .field_name( "m_q_chnl_if" ),
                                        .value(qc_if ));
`ifdef USE_VIP_SNPS
   m_addr_mgr = addr_trans_mgr::get_instance();
   m_addr_mgr.gen_memory_map();
`endif  
        
endfunction: new

function void chi_aiu_qchannel_test::build_phase(uvm_phase phase);
`ifdef USE_VIP_SNPS
  svt_chi_item m_svt_chi_item;
`endif  
  super.build_phase(phase);
  //User knobs for ADDRESS manager configuration
`ifndef USE_VIP_SNPS
   m_addr_mgr = addr_trans_mgr::get_instance();
   m_addr_mgr.gen_memory_map();
`endif  
  m_args = chi_aiu_unit_args::type_id::create($psprintf("chi_aiu_unit_args[%0d]", 0));
  m_q_chnl_seq = q_chnl_seq::type_id::create("m_q_chnl_seq");
  set_testplusargs();
  //instantiate the csr seq
  <% if (obj.INHOUSE_APB_VIP) { %>
  <% if(obj.testBench == 'chi_aiu') { %>
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
  toggle_rstn = new("toggle_rstn");
  if (!uvm_config_db#(uvm_event)::get( .cntxt(null),
                                  .inst_name(""),
                                  .field_name( "toggle_rstn" ),
                                  .value( toggle_rstn ))) begin
     `uvm_error("Q-chnl test", "Event toggle_rstn is not found")
  end

  <%if (obj.testBench != "fsys") { %>
  if(!uvm_config_db#(virtual chi_aiu_dut_probe_if )::get(null, get_full_name(), "u_dut_probe_if",u_dut_probe_vif)) begin
      `uvm_error("NOVIF",{"virtual interface must be set  for :",get_full_name(),".vif"})
  end
  <% } %>
`ifdef USE_VIP_SNPS
      syncdvmop_error_catcher = new();
      set_type_override_by_type(svt_chi_rn_transaction::get_type(),svt_chi_item::get_type());
      set_type_override_by_type (svt_chi_rn_snoop_transaction::get_type(), chi_snoop_item::get_type());
      //set_type_override_by_type(svt_chi_rn_snoop_response_sequence::get_type(),cust_svt_chi_rn_directed_snoop_response_sequence::get_type());
      m_svt_chi_item = svt_chi_item::type_id::create("m_svt_chi_item");
      m_svt_chi_item.m_args = m_args;
      `uvm_info(get_name(),$psprintf("Overrode svt_chi_rn_transaction by svt_chi_item"),UVM_DEBUG)
    uvm_config_db#(uvm_object_wrapper)::set(this, "env.amba_system_env.sequencer.main_phase", "default_sequence", null);
    uvm_config_db#(int unsigned)::set(this, "env.amba_system_env.chi_system[0].rn[0].rn_xact_seqr.svt_chi_rn_transaction_random_sequence", "sequence_length", m_args.k_num_requests.get_value());
    uvm_config_db#(bit)::set(this, "env.amba_system_env.chi_system[0].rn[0].rn_xact_seqr.svt_chi_rn_transaction_random_sequence", "enable_non_blocking", 1);
     uvm_report_cb::add(null,syncdvmop_error_catcher); 

`endif  


endfunction: build_phase

function void chi_aiu_qchannel_test::connect_phase(uvm_phase phase);
  super.connect_phase(phase);
endfunction: connect_phase

function void chi_aiu_qchannel_test::report_phase(uvm_phase phase);
  super.report_phase(phase);
endfunction: report_phase

function void chi_aiu_qchannel_test::check_phase(uvm_phase phase);
  super.check_phase(phase);
endfunction: check_phase



`ifdef USE_VIP_SNPS
    task chi_aiu_qchannel_test::construct_lk_down_seq_snps();
       `uvm_info(get_name(), "Start svt_chi_link_deactivate_service_sequence", UVM_NONE)
        svt_chi_link_service_deactivate_seq = svt_chi_link_service_deactivate_sequence::type_id::create("svt_chi_link_service_deactivate_seq");
        svt_chi_link_service_deactivate_seq.min_cycles_in_deactive = 30;
        svt_chi_link_service_deactivate_seq.start(env.amba_system_env.chi_system[0].rn[0].link_svc_seqr) ;
       `uvm_info(get_name(), "Done svt_chi_link_deactivate_service_sequence", UVM_NONE)
    endtask: construct_lk_down_seq_snps


    task chi_aiu_qchannel_test::construct_lk_seq_snps();
       `uvm_info(get_name(), "Start svt_chi_link_activate_service_sequence", UVM_NONE)
        svt_chi_link_service_activate_seq = svt_chi_link_service_activate_sequence::type_id::create("svt_chi_link_service_deactivate_seq");
        svt_chi_link_service_activate_seq.start(env.amba_system_env.chi_system[0].rn[0].link_svc_seqr) ;
       `uvm_info(get_name(), "Done svt_chi_link_activate_service_sequence", UVM_NONE)
    endtask: construct_lk_seq_snps


// `ifndef SVT_CHI_ISSUE_A_ENABLE
    `ifdef SVT_CHI_ISSUE_B_ENABLE
    task chi_aiu_qchannel_test::construct_coherency_entry_snps();
       `uvm_info(get_name(), "Start svt_chi_coherency_entry_sequence", UVM_NONE)
        wait (env.amba_system_env.chi_system[0].rn[0].shared_status.sysco_interface_state == svt_chi_status::COHERENCY_DISABLED_STATE);
        coherency_entry_seq = new();
        coherency_entry_seq.randomize();
        coherency_entry_seq.start(env.amba_system_env.chi_system[0].rn[0].prot_svc_seqr);
       `uvm_info(get_name(), "Done svt_chi_coherency_entry_sequence", UVM_NONE)
        //wait (env.amba_system_env.chi_system[0].rn[0].shared_status.sysco_interface_state == svt_chi_status::COHERENCY_ENABLED_STATE);
    endtask: construct_coherency_entry_snps

    task chi_aiu_qchannel_test::construct_coherency_exit_snps();
       `uvm_info(get_name(), "Start svt_chi_coherency_exit_sequence", UVM_NONE)
        coherency_exit_seq = new();
        coherency_exit_seq.randomize();
        coherency_exit_seq.start(env.amba_system_env.chi_system[0].rn[0].prot_svc_seqr);
       // wait (env.amba_system_env.chi_system[0].rn[0].shared_status.sysco_interface_state == svt_chi_status::COHERENCY_DISCONNECT_STATE);     
       // wait (env.amba_system_env.chi_system[0].rn[0].shared_status.sysco_interface_state == svt_chi_status::COHERENCY_DISABLED_STATE);
       `uvm_info(get_name(), "Done svt_chi_coherency_exit_sequence", UVM_NONE)
    endtask: construct_coherency_exit_snps
`endif

`else
    task chi_aiu_qchannel_test::construct_lk_down_seq(
      ref chi_txn_seq#(chi_lnk_seq_item) m_lnk_seq);
    
      chi_lnk_seq_item seq_item;
    
      seq_item = chi_lnk_seq_item::type_id::create("chi_lnk_seq_item");
    
      seq_item.n_cycles = 30;
      seq_item.m_txactv_st = POWDN_TX_LN;
      m_lnk_seq.push_back(seq_item);
      `uvm_info(get_name(), "Power Down Link seq", UVM_NONE)
      m_lnk_seq.start(m_env.m_chi_agent.m_lnk_hske_seqr);
      `uvm_info(get_name(), "Done Powr Down Link seq", UVM_NONE)
    
    endtask: construct_lk_down_seq
`endif

task chi_aiu_qchannel_test::run_phase(uvm_phase phase);


`ifndef USE_VIP_SNPS
  bit timeout;
  chi_txn_seq#(chi_lnk_seq_item)  m_lnk_seq;
  
  super.run_phase(phase);

  m_lnk_seq = chi_txn_seq#(chi_lnk_seq_item)::type_id::create("m_lnk_seq");
  m_vseq = chi_aiu_vseq#(<%=obj.AiuInfo[obj.Id].FUnitId%>)::type_id::create("m_vseq");
  m_vseq.m_chi_container = m_chi_container;
  m_vseq.m_rn_tx_req_chnl_seqr = m_env.m_chi_agent.m_rn_tx_req_chnl_seqr;
  m_vseq.m_rn_tx_dat_chnl_seqr = m_env.m_chi_agent.m_rn_tx_dat_chnl_seqr;
  m_vseq.m_rn_tx_rsp_chnl_seqr = m_env.m_chi_agent.m_rn_tx_rsp_chnl_seqr;
  m_vseq.m_rn_rx_rsp_chnl_seqr = m_env.m_chi_agent.m_rn_rx_rsp_chnl_seqr;
  m_vseq.m_rn_rx_dat_chnl_seqr = m_env.m_chi_agent.m_rn_rx_dat_chnl_seqr;
  m_vseq.m_rn_rx_snp_chnl_seqr = m_env.m_chi_agent.m_rn_rx_snp_chnl_seqr;
  m_vseq.m_lnk_hske_seqr       = m_env.m_chi_agent.m_lnk_hske_seqr;
  m_vseq.m_txs_actv_seqr       = m_env.m_chi_agent.m_txs_actv_seqr;
  m_vseq.m_sysco_seqr          = m_env.m_chi_agent.m_sysco_seqr;
  m_vseq.set_unit_args(m_args);

  addr_map_seq = chi_aiu_ral_addr_map_seq::type_id::create("addr_map_seq");
  addr_map_seq.model     = m_env.m_regs;
<% if (obj.INHOUSE_APB_VIP) { %>
 <% if(obj.testBench == 'chi_aiu') { %>
 `ifndef VCS
  if (k_csr_seq) begin
 `else // `ifndef VCS
  if (k_csr_seq != "") begin
 `endif // `ifndef VCS ... `else ... 
  <% } else {%>
  if (k_csr_seq) begin
  <% } %>
      csr_seq.model = m_env.m_regs;
  end
<% } %>

  if (!$value$plusargs("num_trans=%d",num_trans)) begin
      num_trans = 1;
  end

  phase.raise_objection(this, "chi_aiu_qchannel_test");
  
  //use forces for now
  `uvm_info(get_name(), "Start Address map sequence", UVM_DEBUG)
  addr_map_seq.start(m_env.m_apb_agent.m_apb_sequencer);
  `uvm_info(get_name(), "Done Address map sequence", UVM_DEBUG)

  fork: tFrok
<% if (obj.INHOUSE_APB_VIP) { %>
    <% if(obj.testBench == 'chi_aiu') { %>
    `ifndef VCS
     if (k_csr_seq) begin
    `else // `ifndef VCS
     if (k_csr_seq != "") begin
    `endif // `ifndef VCS ... `else ... 
     <% } else {%>
     if (k_csr_seq) begin
     <% } %>
       `uvm_info(get_name(), "csr_seq started",UVM_DEBUG)
       csr_seq.start(m_env.m_apb_agent.m_apb_sequencer);
       `uvm_info(get_name(), "csr_seq finished",UVM_DEBUG)
     end
<% } %>

    begin
     <% if(obj.testBench == 'chi_aiu') { %>
     `ifndef VCS
      if (k_csr_seq) begin
     `else // `ifndef VCS
      if (k_csr_seq != "") begin
     `endif // `ifndef VCS ... `else ... 
      <% } else {%>
      if (k_csr_seq) begin
      <% } %>
        `uvm_info("run_main","Waiting for CSR seq to set the control register",UVM_DEBUG)
        ev.wait_ptrigger();
        `uvm_info("run_main","Waiting Completed for CSR seq to set the control register",UVM_DEBUG)
      end

      `uvm_info(get_name(), "Start CHI AIU VSEQ", UVM_DEBUG)
      //Test will send QREQ only once for sanity check of PMA  
      if($test$plusargs("chi_aiu_qchannel_sanity_test"))begin //#Stimulus.CHIAIU.v3.qchnlsanity
        `uvm_info(get_name(), "Start chi_aiu_qchannel_sanity_test", UVM_DEBUG)
        phase.raise_objection(this, "Start virtual sequence");
        m_vseq.start(null);
        #280000ns;
        phase.drop_objection(this, "Finish virtual sequence");
  <% if(obj.AiuInfo[obj.Id].usePma) { %>
        <%if (obj.testBench != "fsys") { %>
        `uvm_info(get_name(), "Start waiting for ott/stt to be idel", UVM_DEBUG)
        wait((u_dut_probe_vif.ott_entry_validvec === 'h0) && (u_dut_probe_vif.stt_entry_validvec === 'h0));
        `uvm_info(get_name(), "Done waiting for ott/stt to be idel", UVM_DEBUG)
        <% } %>
        construct_lk_down_seq(m_lnk_seq);
        phase.raise_objection(this, $sformatf("Start q_cnl_seq"));
        `uvm_info("chi_aiu_qchannel_sanity_test", "Q_SEQ_START",UVM_DEBUG)
          m_q_chnl_seq.start(m_env.m_q_chnl_agent.m_q_chnl_seqr);
        `uvm_info("chi_aiu_qchannel_sanity_test", "Q_SEQ_END",UVM_DEBUG)
         phase.drop_objection(this, $sformatf("Finish q_cnl_seq"));
  <% } %>
      end

      //Test will send QREQ during the transaction and wait for the completion and then expect the ACCENTn
      if($test$plusargs("chi_aiu_qchannel_req_during_cmd_test"))begin //#Stimulus.CHIAIU.v3.qchnlreqduringcmd
        `uvm_info(get_name(), "Start chi_aiu_qchannel_req_during_cmd_test", UVM_DEBUG)
      fork
        begin
          phase.raise_objection(this, "Start virtual sequence");
          m_vseq.start(null);
          phase.drop_objection(this, "Finish virtual sequence");
          repeat(1000)  @(posedge qc_if.clk); ///delay  
        end
        
         begin
  <% if(obj.AiuInfo[obj.Id].usePma) { %>
		#300000ns;
        <%if (obj.testBench != "fsys") { %>
        `uvm_info(get_name(), "Start waiting for ott/stt to be idel", UVM_DEBUG)
         wait((u_dut_probe_vif.ott_entry_validvec === 'h0) && (u_dut_probe_vif.stt_entry_validvec === 'h0)); //CONC-8769
        `uvm_info(get_name(), "Done waiting for ott/stt to be idel", UVM_DEBUG)
        <% } %>
        //repeat(1000)  @(posedge qc_if.clk); ///delay  
        construct_lk_down_seq(m_lnk_seq);
         repeat(10) begin
          wait(qc_if.QACTIVE);
           repeat(5)  @(posedge qc_if.clk); ///delay  
            phase.raise_objection(this, $sformatf("Start q_cnl_seq"));
            `uvm_info("chi_aiu_qchannel_req_during_cmd_test", "Q_SEQ_START",UVM_DEBUG)
              m_q_chnl_seq.start(m_env.m_q_chnl_agent.m_q_chnl_seqr);
            `uvm_info("chi_aiu_qchannel_req_during_cmd_test", "Q_SEQ_END",UVM_DEBUG)
            phase.drop_objection(this, $sformatf("Finish q_cnl_seq"));
            end
  <% } %>
          end
      join
        `uvm_info(get_name(), "Finish chi_aiu_qchannel_req_during_cmd_test", UVM_DEBUG)
      end

      //Test will send QREQ between the command execution and expect the ACCENPTn
      if($test$plusargs("chi_aiu_qchannel_req_between_cmd_test"))begin //#Stimulus.CHIAIU.v3.qchnlreqbetncmd
        `uvm_info(get_name(), "Start chi_aiu_qchannel_req_between_cmd_test", UVM_DEBUG)
        fork
        begin
        phase.raise_objection(this, "Start virtual sequence");
        m_vseq.start(null);
        phase.drop_objection(this, "Finish virtual sequence");
        end
        begin
  <% if(obj.AiuInfo[obj.Id].usePma) { %>
        #50ns;
        repeat(10) begin
          wait(!qc_if.QACTIVE);
           repeat(2)  @(posedge qc_if.clk); ///delay  
           phase.raise_objection(this, $sformatf("Start q_cnl_seq"));
           `uvm_info("chi_aiu_qchannel_req_between_cmd_test", "Q_SEQ_START",UVM_DEBUG)
             m_q_chnl_seq.start(m_env.m_q_chnl_agent.m_q_chnl_seqr);

           `uvm_info("chi_aiu_qchannel_req_between_cmd_test", "Q_SEQ_END",UVM_DEBUG)
           phase.drop_objection(this, $sformatf("Finish q_cnl_seq"));
          wait(qc_if.QACTIVE);
          end
  <% } %>
         end
      join
        `uvm_info(get_name(), "Finish chi_aiu_qchannel_req_between_cmd_test", UVM_DEBUG)
      end

      //Test will asseert QREQ many times randomaly when Chi transactions are happening
      if($test$plusargs("chi_aiu_qchannel_multiple_request_test"))begin //#Stimulus.CHIAIU.v3.qchnlmulreq
        `uvm_info(get_name(), "Start chi_aiu_qchannel_multiple_request_test", UVM_DEBUG)
        phase.raise_objection(this, "Start chi_aiu_qchannel_multiple_request_test");
      <% if(obj.AiuInfo[obj.Id].usePma) { %>
        repeat(3) begin
          `uvm_info(get_name(), "Starting main-1 loop again", UVM_DEBUG)
          begin
            `uvm_info("chi_aiu_qchannel_multiple_request_test", "M_VSEQ_START", UVM_DEBUG)
            m_vseq.start(null);
            `uvm_info("chi_aiu_qchannel_multiple_request_test", "M_VSEQ_END", UVM_DEBUG)
       <% } else {%>
          `uvm_info(get_name(), "Starting main-1 loop again", UVM_DEBUG)
          begin
            `uvm_info("chi_aiu_qchannel_multiple_request_test", "M_VSEQ_START", UVM_DEBUG)
            m_vseq.start(null);
            `uvm_info("chi_aiu_qchannel_multiple_request_test", "M_VSEQ_END", UVM_DEBUG)
            repeat(3) begin
       <% } %>
  <% if(obj.AiuInfo[obj.Id].usePma) { %>
            //repeat(50000)  @(posedge qc_if.clk);
             #225000ns;
            repeat(20) begin
              `uvm_info(get_name(), "Starting sub-1 loop again", UVM_DEBUG)
              <%if (obj.testBench != "fsys") { %>
              `uvm_info(get_name(), "Start waiting for ott/stt to be idel", UVM_DEBUG)
              wait((u_dut_probe_vif.ott_entry_validvec === 'h0) && (u_dut_probe_vif.stt_entry_validvec === 'h0));
              `uvm_info(get_name(), "Done waiting for ott/stt to be idel", UVM_DEBUG)
              <% } %>
              construct_lk_down_seq(m_lnk_seq);
              wait(!qc_if.QACTIVE);
              repeat(2)  @(posedge qc_if.clk);
              repeat($urandom_range(2,10)) begin
                `uvm_info(get_name(), "Starting sub-2 loop again", UVM_DEBUG)
                `uvm_info("chi_aiu_qchannel_multiple_request_test", "Q_SEQ_START",UVM_DEBUG)
                phase.raise_objection(this, $sformatf("Start q_cnl_seq"));
                m_q_chnl_seq.start(m_env.m_q_chnl_agent.m_q_chnl_seqr);
                phase.drop_objection(this, $sformatf("Finish q_cnl_seq"));
                `uvm_info("chi_aiu_qchannel_multiple_request_test", "Q_SEQ_END",UVM_DEBUG)
              end
            end
            repeat(1000)  @(posedge qc_if.clk);
  <% } %>
          end
        end
        phase.drop_objection(this, "Finish chi_aiu_qchannel_multiple_request_test");
        `uvm_info(get_name(), "Finish chi_aiu_qchannel_multiple_request_test", UVM_DEBUG)
      end
//Test will assert reset when Chi is in PMA
if($test$plusargs("chi_aiu_qchannel_reset_test"))begin //#Stimulus.CHIAIU.v3.qchnlreset
  int q_active;
  bit stop_seq = 0;  
  `uvm_info(get_name(), "Start chi_aiu_qchannel_reset_test", UVM_DEBUG)
  fork
  begin //1st spawned process by fork
    phase.raise_objection(this, "Start virtual sequence");
    begin    
      m_vseq.start(null);
    end
    phase.drop_objection(this, "Finish virtual sequence");
    `uvm_info(get_name(), "chi_aiu_qchannel_reset_test", UVM_DEBUG)
  <% if(obj.AiuInfo[obj.Id].usePma) { %>
      phase.raise_objection(this, $sformatf("Start q_cnl_seq"));
    `uvm_info(get_name(), "chi_aiu_qchannel_reset_test", UVM_DEBUG)
    #900000ns;
    repeat(1) begin
      wait((u_dut_probe_vif.ott_entry_validvec === 'h0) && (u_dut_probe_vif.stt_entry_validvec === 'h0));
      `uvm_info("chi_aiu_qchannel_reset_test", "disconnecting sysco", UVM_DEBUG)
      m_vseq.construct_sysco_seq(DISCONNECT);
      `uvm_info("chi_aiu_qchannel_reset_test", "disconencting link", UVM_DEBUG)
      construct_lk_down_seq(m_lnk_seq);

      repeat(10)  @(posedge qc_if.clk); ///delay  
      `uvm_info("chi_aiu_qchannel_reset_test", "Q_SEQ_START",UVM_DEBUG)
      m_q_chnl_seq.start(m_env.m_q_chnl_agent.m_q_chnl_seqr);
      `uvm_info("chi_aiu_qchannel_reset_test", "Q_SEQ_END",UVM_DEBUG)
      phase.drop_objection(this, $sformatf("Finish q_cnl_seq"));
    end
  end   //end of 2nd process
  begin //Reset assertion
    repeat(1) begin
      `uvm_info("chi_aiu_qchannel_reset_test", "Wait: reset thread", UVM_DEBUG)
      wait(!qc_if.QACCEPTn && !qc_if.QREQn && !qc_if.QACTIVE);
      `uvm_info("chi_aiu_qchannel_reset_test", "start: reset thread", UVM_DEBUG)
      phase.raise_objection(this, $sformatf("Start q_cnl_seq"));
      repeat(50)@(posedge qc_if.clk); 
      toggle_rstn.trigger();
      #350ns;//repeat(3)@(posedge qc_if.clk); 
      toggle_rstn.trigger();
      #10ns;
      stop_seq = 1;  
      m_vseq.construct_lnk_seq();
      m_vseq.construct_sysco_seq(CONNECT);
      `uvm_info("chi_aiu_qchannel_reset_test", "release end",UVM_DEBUG)
      addr_map_seq.start(m_env.m_apb_agent.m_apb_sequencer);
      phase.drop_objection(this, $sformatf("Finish q_cnl_seq"));
      `uvm_info("chi_aiu_qchannel_reset_test", "finish: reset thread", UVM_DEBUG)
    end
  <% } %>
  end
  join
  `uvm_info(get_name(), "Finish chi_aiu_qchannel_reset_test", UVM_DEBUG)
end
`uvm_info(get_name(), "Done CHI AIU VSEQ", UVM_DEBUG)
end
begin
  if (k_num_snoop >= 0)
      m_system_bfm_seq.k_num_snp.set_value(k_num_snoop); 
  m_system_bfm_seq.wt_snp_dvm_msg.set_value(20);
 <% if(obj.testBench == 'chi_aiu') { %>
 `ifndef VCS
  if (k_csr_seq) begin
 `else // `ifndef VCS
  if (k_csr_seq != "") begin
 `endif // `ifndef VCS ... `else ... 
  <% } else {%>
  if (k_csr_seq) begin
  <% } %>
    `uvm_info("run_main","Waiting for CSR seq to set the control register",UVM_DEBUG)
    ev.wait_ptrigger();
    `uvm_info("run_main","Waiting Completed for CSR seq to set the control register",UVM_DEBUG)
  end
  m_system_bfm_seq.start(null);
end
join_any

  #100000ns;
  phase.phase_done.set_drain_time(this, 500ns);

  `uvm_info(get_name(), "Dropping objection for chi_aiu_qchannel_test", UVM_DEBUG)
  phase.drop_objection(this, "chi_aiu_qchannel_test");
`else //USE_VIP_SNPS
  uvm_config_db#(chi_aiu_scb)::set(uvm_root::get(), 
                                  "*", 
                                  "chi_aiu_scb", 
                                  m_env.m_scb);

<% if (obj.INHOUSE_APB_VIP) { %>
  <% if(obj.testBench == 'chi_aiu') { %>
  `ifndef VCS
   if (k_csr_seq) begin
  `else // `ifndef VCS
   if (k_csr_seq != "") begin
  `endif // `ifndef VCS ... `else ... 
   <% } else {%>
   if (k_csr_seq) begin
   <% } %>
      csr_seq.model = m_env.m_regs;
  end
<% } %>
  
  m_snps_chi<%=obj.Id%>_vseq = <%=obj.BlockId%>_chi_aiu_vseq_pkg::snps_chi_aiu_vseq#(<%=obj.AiuInfo[obj.Id].FUnitId%>)::type_id::create("m_chi<%=obj.Id%>_seq");
  m_snps_chi<%=obj.Id%>_vseq.rn_xact_seqr = env.amba_system_env.chi_system[0].rn[<%=obj.Id%>].rn_xact_seqr;
  //m_snps_chi<%=obj.Id%>_vseq.rn_snp_xact_seqr = env.amba_system_env.chi_system[0].rn[<%=obj.Id%>].rn_snp_xact_seqr; 
  m_snps_chi<%=obj.Id%>_vseq.vip_snps_seq_length = m_args.k_num_requests.get_value();
  m_snps_chi<%=obj.Id%>_vseq.set_unit_args(m_args);



  if (!$value$plusargs("num_trans=%d",num_trans)) begin
      num_trans = 1;
  end


  phase.raise_objection(this, "chi_aiu_qchannel_test");
  addr_map_seq = chi_aiu_ral_addr_map_seq::type_id::create("addr_map_seq");
  addr_map_seq.model     = m_env.m_regs;
  `uvm_info(get_name(), "Start Address map sequence", UVM_DEBUG)
  addr_map_seq.start(m_env.m_apb_agent.m_apb_sequencer);
  `uvm_info(get_name(), "Done Address map sequence", UVM_DEBUG)

  `uvm_info(get_name(), "Start svt_chi_link_service_sequence", UVM_NONE)
   svt_chi_link_service_activate_seq = svt_chi_link_service_activate_sequence::type_id::create("svt_chi_link_service_activate_seq");
   svt_chi_link_service_activate_seq.start(env.amba_system_env.chi_system[0].rn[0].link_svc_seqr) ;
  `uvm_info(get_name(), "Done svt_chi_link_service_sequence", UVM_NONE)

  fork: tFrok
<% if (obj.INHOUSE_APB_VIP) { %>
  <% if(obj.testBench == 'chi_aiu') { %>
    `ifndef VCS
     if (k_csr_seq) begin
  `else // `ifndef VCS
     if (k_csr_seq != "") begin
    `endif // `ifndef VCS ... `else ... 
   <% } else {%>
     if (k_csr_seq) begin
   <% } %>
       `uvm_info(get_name(), "csr_seq started",UVM_DEBUG)
       csr_seq.start(m_env.m_apb_agent.m_apb_sequencer);
       `uvm_info(get_name(), "csr_seq finished",UVM_DEBUG)
     end
<% } %>


    begin
  <% if(obj.testBench == 'chi_aiu') { %>
    `ifndef VCS
     if (k_csr_seq) begin
  `else // `ifndef VCS
     if (k_csr_seq != "") begin
    `endif // `ifndef VCS ... `else ... 
   <% } else {%>
     if (k_csr_seq) begin
   <% } %>
        `uvm_info("run_main","Waiting for CSR seq to set the control register",UVM_DEBUG)
        ev.wait_ptrigger();
        `uvm_info("run_main","Waiting Completed for CSR seq to set the control register",UVM_DEBUG)
      end


      `uvm_info(get_name(), "Start CHI AIU VSEQ", UVM_DEBUG)
      //Test will send QREQ only once for sanity check of PMA  
      if($test$plusargs("chi_aiu_qchannel_sanity_test"))begin
        `uvm_info(get_name(), "Start chi_aiu_qchannel_sanity_test", UVM_DEBUG)
        phase.raise_objection(this, "Start virtual sequence");
        //m_vseq.start(null);
        m_snps_chi<%=obj.Id%>_vseq.start(null);
        phase.drop_objection(this, "Finish virtual sequence");
  <% if(obj.AiuInfo[obj.Id].usePma) { %>
        #1000ns;  
        <%if (obj.testBench != "fsys") { %>
        `uvm_info(get_name(), "Start waiting for ott/stt to be idel", UVM_DEBUG)
        wait((u_dut_probe_vif.ott_entry_validvec === 'h0) && (u_dut_probe_vif.stt_entry_validvec === 'h0));
        `uvm_info(get_name(), "Done waiting for ott/stt to be idel", UVM_DEBUG)
        <% } %>
       construct_lk_down_seq_snps();
        phase.raise_objection(this, $sformatf("Start q_cnl_seq"));
        `uvm_info("chi_aiu_qchannel_sanity_test", "Q_SEQ_START",UVM_DEBUG)
          m_q_chnl_seq.start(m_env.m_q_chnl_agent.m_q_chnl_seqr);
        `uvm_info("chi_aiu_qchannel_sanity_test", "Q_SEQ_END",UVM_DEBUG)
         phase.drop_objection(this, $sformatf("Finish q_cnl_seq"));
  <% } %>
      end



      //Test will send QREQ during the transaction and wait for the completion and then expect the ACCENTn
      if($test$plusargs("chi_aiu_qchannel_req_during_cmd_test"))begin
        `uvm_info(get_name(), "Start chi_aiu_qchannel_req_during_cmd_test", UVM_DEBUG)
      fork
        begin
          phase.raise_objection(this, "Start virtual sequence");
          //m_vseq.start(null);
          m_snps_chi<%=obj.Id%>_vseq.start(null);
             <%if (obj.testBench != "fsys") { %>
              `uvm_info(get_name(), "Start waiting for ott/stt to be idel", UVM_DEBUG)
               wait((u_dut_probe_vif.ott_entry_validvec === 'h0) && (u_dut_probe_vif.stt_entry_validvec === 'h0)); //CONC-8769
              `uvm_info(get_name(), "Done waiting for ott/stt to be idel", UVM_DEBUG)
              <% } %>
               repeat(1000)  @(posedge qc_if.clk); ///delay  
                construct_lk_down_seq_snps();
          phase.drop_objection(this, "Finish virtual sequence");
          repeat(1000)  @(posedge qc_if.clk); ///delay  
        end
        
         begin
  <% if(obj.AiuInfo[obj.Id].usePma) { %>
         repeat(10) begin
          wait(qc_if.QACTIVE);
           repeat(5)  @(posedge qc_if.clk); ///delay  
            phase.raise_objection(this, $sformatf("Start q_cnl_seq"));
            `uvm_info("chi_aiu_qchannel_req_during_cmd_test", "Q_SEQ_START",UVM_DEBUG)
              m_q_chnl_seq.start(m_env.m_q_chnl_agent.m_q_chnl_seqr);
            `uvm_info("chi_aiu_qchannel_req_during_cmd_test", "Q_SEQ_END",UVM_DEBUG)
            phase.drop_objection(this, $sformatf("Finish q_cnl_seq"));
            end
  <% } %>
          end
      join
        `uvm_info(get_name(), "Finish chi_aiu_qchannel_req_during_cmd_test", UVM_DEBUG)
      end

 //Test will send QREQ between the command execution and expect the ACCENPTn
      if($test$plusargs("chi_aiu_qchannel_req_between_cmd_test"))begin
        `uvm_info(get_name(), "Start chi_aiu_qchannel_req_between_cmd_test", UVM_DEBUG)
        fork
        begin
        phase.raise_objection(this, "Start virtual sequence");
        //m_vseq.start(null);
        m_snps_chi<%=obj.Id%>_vseq.start(null);
        phase.drop_objection(this, "Finish virtual sequence");
        end
        begin
  <% if(obj.AiuInfo[obj.Id].usePma) { %>
        #50ns;
        repeat(10) begin
          wait(!qc_if.QACTIVE);
           repeat(2)  @(posedge qc_if.clk); ///delay  
           phase.raise_objection(this, $sformatf("Start q_cnl_seq"));
           `uvm_info("chi_aiu_qchannel_req_between_cmd_test", "Q_SEQ_START",UVM_DEBUG)
             m_q_chnl_seq.start(m_env.m_q_chnl_agent.m_q_chnl_seqr);

           `uvm_info("chi_aiu_qchannel_req_between_cmd_test", "Q_SEQ_END",UVM_DEBUG)
           phase.drop_objection(this, $sformatf("Finish q_cnl_seq"));
          wait(qc_if.QACTIVE);
          end
  <% } %>
         end
      join
        `uvm_info(get_name(), "Finish chi_aiu_qchannel_req_between_cmd_test", UVM_DEBUG)
      end


      if($test$plusargs("chi_aiu_qchannel_multiple_request_test"))begin
        `uvm_info(get_name(), "Start chi_aiu_qchannel_multiple_request_test", UVM_DEBUG)
        phase.raise_objection(this, "Start chi_aiu_qchannel_multiple_request_test");
        repeat(3) begin
          `uvm_info(get_name(), "Starting main-1 loop again", UVM_DEBUG)
          begin
            `uvm_info("chi_aiu_qchannel_multiple_request_test", "M_VSEQ_START", UVM_DEBUG)
            //m_vseq.start(null);
            m_snps_chi<%=obj.Id%>_vseq.start(null);
            `uvm_info("chi_aiu_qchannel_multiple_request_test", "M_VSEQ_END", UVM_DEBUG)
  <% if(obj.AiuInfo[obj.Id].usePma) { %>
            repeat(50000)  @(posedge qc_if.clk);
            repeat(20) begin
              `uvm_info(get_name(), "Starting sub-1 loop again", UVM_DEBUG)
              <%if (obj.testBench != "fsys") { %>
              `uvm_info(get_name(), "Start waiting for ott/stt to be idel", UVM_DEBUG)
              wait((u_dut_probe_vif.ott_entry_validvec === 'h0) && (u_dut_probe_vif.stt_entry_validvec === 'h0));
              `uvm_info(get_name(), "Done waiting for ott/stt to be idel", UVM_DEBUG)
              <% } %>
              construct_lk_down_seq_snps();
              wait(!qc_if.QACTIVE);
              repeat(2)  @(posedge qc_if.clk);
              repeat($urandom_range(2,10)) begin
                `uvm_info(get_name(), "Starting sub-2 loop again", UVM_DEBUG)
                `uvm_info("chi_aiu_qchannel_multiple_request_test", "Q_SEQ_START",UVM_DEBUG)
                phase.raise_objection(this, $sformatf("Start q_cnl_seq"));
                m_q_chnl_seq.start(m_env.m_q_chnl_agent.m_q_chnl_seqr);
                phase.drop_objection(this, $sformatf("Finish q_cnl_seq"));
                `uvm_info("chi_aiu_qchannel_multiple_request_test", "Q_SEQ_END",UVM_DEBUG)
              end
            end
            repeat(1000)  @(posedge qc_if.clk);
  <% } %>
          end
        end
        phase.drop_objection(this, "Finish chi_aiu_qchannel_multiple_request_test");
        `uvm_info(get_name(), "Finish chi_aiu_qchannel_multiple_request_test", UVM_DEBUG)
      end
if($test$plusargs("chi_aiu_qchannel_reset_test"))begin
  int q_active;
  bit stop_seq = 0;  
  `uvm_info(get_name(), "Start chi_aiu_qchannel_reset_test", UVM_DEBUG)
  fork
  begin //1st spawned process by fork
    phase.raise_objection(this, "Start virtual sequence");
    begin    
      //m_vseq.start(null);
      m_snps_chi<%=obj.Id%>_vseq.start(null);
    end
    phase.drop_objection(this, "Finish virtual sequence");
  <% if(obj.AiuInfo[obj.Id].usePma) { %>
      phase.raise_objection(this, $sformatf("Start q_cnl_seq"));
    #3000ns;
    repeat(1) begin
      wait((u_dut_probe_vif.ott_entry_validvec === 'h0) && (u_dut_probe_vif.stt_entry_validvec === 'h0));
      `uvm_info("chi_aiu_qchannel_reset_test", "disconnecting sysco", UVM_DEBUG)
    
       //m_vseq.construct_sysco_seq(DISCONNECT);
   // `ifndef SVT_CHI_ISSUE_A_ENABLE
    `ifdef SVT_CHI_ISSUE_B_ENABLE
         if(env.amba_system_env.chi_system[0].rn[0].shared_status.sysco_interface_state == svt_chi_status::COHERENCY_ENABLED_STATE) begin
             `uvm_info("chi_aiu_qchannel_reset_test", "disconnecting sysco", UVM_DEBUG)
             construct_coherency_exit_snps();
         end
    `endif

       //construct_lk_down_seq(m_lnk_seq);
        all_txn_done_ev.wait_ptrigger();
      `uvm_info("chi_aiu_qchannel_reset_test", "disconencting link", UVM_DEBUG)
       construct_lk_down_seq_snps();

      repeat(10)  @(posedge qc_if.clk); ///delay  
      `uvm_info("chi_aiu_qchannel_reset_test", "Q_SEQ_START",UVM_DEBUG)
      m_q_chnl_seq.start(m_env.m_q_chnl_agent.m_q_chnl_seqr);
      `uvm_info("chi_aiu_qchannel_reset_test", "Q_SEQ_END",UVM_DEBUG)
      phase.drop_objection(this, $sformatf("Finish q_cnl_seq"));
    end
  end   //end of 2nd process
  begin //Reset assertion
    repeat(1) begin
      wait(!qc_if.QACCEPTn && !qc_if.QREQn && !qc_if.QACTIVE);
      phase.raise_objection(this, $sformatf("Start q_cnl_seq"));
      repeat(10)@(posedge qc_if.clk); 
      toggle_rstn.trigger();
      #30ns;//repeat(3)@(posedge qc_if.clk); 
      toggle_rstn.trigger();
      #10ns;
      stop_seq = 1;  
      construct_lk_seq_snps();
      //m_vseq.construct_lnk_seq();
      //m_vseq.construct_sysco_seq(CONNECT);
    //`ifndef SVT_CHI_ISSUE_A_ENABLE
    `ifdef SVT_CHI_ISSUE_B_ENABLE
      construct_coherency_entry_snps();//temp
    `endif
      `uvm_info("chi_aiu_qchannel_reset_test_7", "release end",UVM_DEBUG)
      addr_map_seq.start(m_env.m_apb_agent.m_apb_sequencer);
      phase.drop_objection(this, $sformatf("Finish q_cnl_seq"));
    end
  <% } %>
  end
  join
  `uvm_info(get_name(), "Finish chi_aiu_qchannel_reset_test", UVM_DEBUG)
  end
`uvm_info(get_name(), "Done CHI AIU VSEQ", UVM_DEBUG)

end //main fork end
begin
  if (k_num_snoop >= 0)
      m_system_bfm_seq.k_num_snp.set_value(k_num_snoop); 
  m_system_bfm_seq.wt_snp_dvm_msg.set_value(20);
<% if(obj.testBench == 'chi_aiu') { %>
 `ifndef VCS
  if (k_csr_seq) begin
`else // `ifndef VCS
  if (k_csr_seq != "") begin
 `endif // `ifndef VCS ... `else ... 
<% } else {%>
  if (k_csr_seq) begin
<% } %>
    `uvm_info("run_main","Waiting for CSR seq to set the control register",UVM_DEBUG)
    ev.wait_ptrigger();
    `uvm_info("run_main","Waiting Completed for CSR seq to set the control register",UVM_DEBUG)
  end
  m_system_bfm_seq.start(null);
end
join_any

  #100000ns;
  phase.phase_done.set_drain_time(this, 500ns);


  `uvm_info(get_name(), "Dropping objection for chi_aiu_qchannel_test", UVM_DEBUG)
  phase.drop_objection(this, "chi_aiu_qchannel_test");


`endif //USE_VIP_SNPS



endtask: run_phase

function void chi_aiu_qchannel_test::set_testplusargs();

    m_args.k_txreq_hld_dly.set_value(1);
    m_args.k_txreq_dly_min.set_value(100);
    m_args.k_txreq_dly_max.set_value(1000);
    m_args.k_txrsp_hld_dly.set_value(1);
    m_args.k_txrsp_dly_min.set_value(100);
    m_args.k_txrsp_dly_max.set_value(500);
    m_args.k_txdat_hld_dly.set_value(1);
    m_args.k_txdat_dly_min.set_value(100);
    m_args.k_txdat_dly_max.set_value(250);

    m_args.k_rd_noncoh_pct.set_value(90);
    m_args.k_rd_rdonce_pct.set_value(90);
    m_args.k_rd_ldrstr_pct.set_value(90);
    m_args.k_dt_ls_upd_pct.set_value(90);
    m_args.k_dt_ls_cmo_pct.set_value(90);
    m_args.k_dt_ls_sth_pct.set_value(90);
    m_args.k_wr_noncoh_pct.set_value(90);
    m_args.k_wr_cohunq_pct.set_value(90);
    m_args.k_wr_cpybck_pct.set_value(90);
    m_args.k_atomic_st_pct.set_value(70);
    m_args.k_atomic_ld_pct.set_value(70);
    m_args.k_atomic_sw_pct.set_value(70);
    m_args.k_atomic_cm_pct.set_value(70);
    m_args.k_dvm_opert_pct.set_value(40);
    m_args.k_pre_fetch_pct.set_value(40);
    m_args.k_unsupported_txn_pct.set_value(0);

    m_args.k_coh_addr_pct.set_value(100);
    m_args.k_alloc_hint_pct.set_value(90);
    m_args.k_cacheable_pct.set_value(90);
    m_args.k_wr_sthunq_pct.set_value(0); // Not supported in NCore3.0

    if (!$value$plusargs("k_num_snoop=%d",k_num_snoop)) begin
        k_num_snoop = -1;
    end 
  if (!$value$plusargs("wr_dat_cancel_pct=%d",k_writedatacancel_pct)) begin
      m_args.k_writedatacancel_pct.set_value(k_writedatacancel_pct);
  end 

endfunction: set_testplusargs
