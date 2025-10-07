`ifndef DMI_TEST
`define DMI_TEST



////////////////////////////////////////////////////////////////////////////////
//
// DMI Test
//
////////////////////////////////////////////////////////////////////////////////

<%
    var SMC_mntop_seqs = [
        "dmi_csr_flush_by_addr_range_seq",
        "dmi_csr_flush_by_addr_seq",
        "dmi_csr_flush_by_index_way_range_seq",
        "dmi_csr_flush_by_index_way_seq",
        "dmi_ccp_offline_seq",
        "dmi_csr_rand_all_type_flush_seq"
    ];
    var SMC_mntop_seqs_for_error = [
        "dmi_csr_elr_seq",
        "dmi_csr_time_out_error_seq",
        "dmi_csr_CMO_test_seq"
    ];
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
        "dmi_csr_elr_seq_trans_err",
        "dmi_csr_dmiuuedr_MemErrDetEn_seq",
        "dmi_csr_dmiuuedr_wrProtErrDetEn_seq",
        "dmi_csr_dmiuuedr_rdProtErrDetEn_seq",
        "dmi_csr_dmiuecr_sw_write_seq",
        "dmi_csr_dmiuuedr_ProtErrThd_seq",
        "dmi_csr_dmiuecr_noDetEn_seq",
        "dmi_csr_dmiueir_ProtErrInt_seq",
        "dmi_csr_dmiuesar_ProtErrInt_seq",
        "dmi_csr_dmiueir_MemErrInt_seq",
        "dmi_csr_dmiuuedr_TransErrDetEn_seq",
        "dmi_csr_dmicesar_seq",
        "dmi_csr_dmiuesar_seq",
        "always_inject_error",
        "dmi_corr_errint_check_through_dmicesar_seq",
        "dmi_csr_error_detect_off_seq",
        "dmi_csr_CorrErr_with_ProtErr_seq",
        "access_unmapped_csr_addr",
        "dmi_csr_time_out_error_seq",
        "dmi_csr_time_out_error_seq_no_checks",
        "dmi_csr_dmiuesar_TimeOutErrInt_seq",
        "dmi_SMC_init_done_check_csr_seq",
        "dmi_csr_dmiuesar_MemErrInt_seq",
        "dmi_trans_actv_high_seq",
        "dmi_sram_corr_err_seq",
        "dmi_sram_uncorr_err_seq",
        "plru_error_injection_seq",
        "dmi_csr_mnt_CMO_RAW_seq",
        "set_max_errthd"
    ];
%>

class dmi_test extends dmi_base_test;

  `uvm_component_utils(dmi_test)

  uvm_event  forceClkgate;
  uvm_event  releaseClkgate;
// Sequence declaration
  dmi_base_seq test_seq;
  dmi_vseq     test_vseq;


  int      clk_count_en;     // Use for CCTRLR update scenario
  int      cctrlr_mod = 0;   // Use for CCTRLR update scenario

  `ifdef INHOUSE_AXI
  axi_slave_read_seq   m_slave_read_seq;
  axi_slave_write_seq  m_slave_write_seq;
  `endif
  `ifdef USE_VIP_SNPS
  axi_slave_mem_response_sequence m_axi_slave_response_seq;
  uvm_event read_threshold_evnt=uvm_event_pool::get_global("read_threshold_evnt");
  `endif // USE_VIP_SNPS
  
  uvm_reg_sequence csr_seq;
  uvm_reg_sequence smc_mntop_csr_seq;
  uvm_reg_sequence smc_mntop_csr_seq_for_error;

  q_chnl_seq m_q_chnl_seq;
  dmi_cctrlr_csr_seq cctrlr_csr_seq;  

  dmi_csr_qos_ctrl_reg_seq qos_ctrl_reg_seq;

  <% if (obj.DmiInfo[obj.Id].nAddrTransRegisters > 0) { %>
  dmi_csr_addr_trans_seq m_addr_trans_seq;
<% } %>
<% if (obj.INHOUSE_APB_VIP) { %>
  dmi_csr_init_seq csr_init_seq;
<% } %>
// end Sequence declaration

  <% if(obj.useResiliency) { %>
   // This event triggers if any request is killed when injecting errors
   // to drop all objections and get out of run_phase, resolves hanging tests issue
<% if(obj.testBench == 'dmi') { %>
`ifndef VCS
  event kill_test;
  event raise_obj_for_resiliency_test;
  event drop_obj_for_resiliency_test;
`else // `ifndef VCS
  uvm_event kill_test;
  uvm_event raise_obj_for_resiliency_test;
  uvm_event drop_obj_for_resiliency_test;
`endif // `ifndef VCS ... `else ... 
<% } else {%>
  event kill_test;
  event raise_obj_for_resiliency_test;
  event drop_obj_for_resiliency_test;
<% } %>
   uvm_event ev_uesr_error = ev_pool.get("ev_uesr_error");
   uvm_object objectors_list[$];
   uvm_objection objection;
   virtual dmi_csr_probe_if u_csr_probe_vif;
    <% if (obj.testBench != "fsys") { %>
    /*
     *demote handle to suppress any error coming for the resiliency 
     *testing. error form the fault_injector_checker will show, but
     *others will be converted to info
     */
    report_catcher_demoter_base fault_injector_checker_demoter_h;
    <% } %>
  <% } %>

  //sequence to enable/disable sys_event
  dmi_csr_sys_event_seq sys_event_csr_seq;

  //Sequence to poll error status for atomic uncorrectable error
  dmi_csr_poll_error_status_seq uesr_poll_seq_for_error;

  extern function new(string name = "dmi_test", uvm_component parent = null);
  extern virtual function void build_phase(uvm_phase phase);
  extern virtual task run_phase(uvm_phase phase);
  extern virtual task run_main(uvm_phase phase);
  extern virtual function void report_phase(uvm_phase phase);

  virtual function void pre_abort();
    if(!EN_DMI_VSEQ) begin
      test_seq.print_pending_q();
    end
    if(EN_DMI_VSEQ) begin
      test_vseq.print_abort();
    end
  endfunction:pre_abort

endclass: dmi_test

//------------------------------------------------------------------------------
// Constructor
//------------------------------------------------------------------------------
function dmi_test::new(string name = "dmi_test", uvm_component parent = null);
  super.new(name, parent);
endfunction : new

function void dmi_test::build_phase(uvm_phase phase);
  <% if ((obj.useResiliency) && (obj.testBench != "fsys")) { %>
  if($test$plusargs("collect_resiliency_cov")) begin
    set_type_override_by_type(.original_type(<%=obj.BlockId%>_smi_agent_pkg::smi_coverage::get_type()), .override_type(smi_resiliency_coverage::get_type()), .replace(1));
  end
  <% } %>
  super.build_phase(phase);

  <% if ((obj.useResiliency) && (obj.testBench != "fsys")) { %>
    if($test$plusargs("expect_mission_fault")) begin
      fault_injector_checker_demoter_h = report_catcher_demoter_base::type_id::create("fault_injector_checker_demoter_h");
      fault_injector_checker_demoter_h.exp_id = {"fault_injector_checker"};
      if($test$plusargs("test_placeholder_connectivity")) begin
        fault_injector_checker_demoter_h.exp_id.push_back("placeholder_connectivity_checker");
      end
      fault_injector_checker_demoter_h.not_of = 1;
      if($test$plusargs("expect_mission_fault_cov")) begin
        fault_injector_checker_demoter_h.demote_uvm_fatal = 1;
      end
      fault_injector_checker_demoter_h.build();
      `uvm_info(get_name(), $sformatf("Registering demoter class{%0s} for resiliency error ignore", fault_injector_checker_demoter_h.get_name()), UVM_LOW)
      uvm_report_cb::add(null, fault_injector_checker_demoter_h);
    end
  <% } %>
    if(!uvm_config_db#(virtual dmi_csr_probe_if )::get(null, get_full_name(), "u_csr_probe_if",u_csr_probe_vif)) begin
        `uvm_error({"fault_injector_checker_",get_name()}, {"virtual interface must be set  for :",get_full_name(),".vif"})
    end
endfunction: build_phase

//------------------------------------------------------------------------------
// Run Phase
//------------------------------------------------------------------------------

task dmi_test::run_phase(uvm_phase phase);
  <% if(obj.DmiInfo[obj.Id].ccpParams.useScratchpad) { %>
  initialize_scratchpad();
  <% } else {%>
  randomize_config(EN_DMI_VSEQ);
  <% } %>
  run_main(phase);
endtask : run_phase

task dmi_test::run_main(uvm_phase phase);

// BEGIN DECLARATION
  int   flush_count = 0;
  int   online_offline_count = 0;
  enum {CCP_OFFLINE, CCP_ONLINE, CCP_FLUSHING} ccp_state;
  semaphore ccp_control = new(1);
  uvm_objection uvm_obj = phase.get_objection();
  int time_bw_Q_chnl_req = 100;
// END DECLARATION

  main_seq_pre_hook(phase); // virtual task
  for (int perf_mon_iter=0; perf_mon_iter<main_seq_iter; perf_mon_iter++) begin:forloop_main_seq_iter //by default main_seq_iter=1

    cctrlr_csr_seq = dmi_cctrlr_csr_seq::type_id::create("cctrlr_csr_seq");

    sys_event_csr_seq = dmi_csr_sys_event_seq::type_id::create("sys_event_csr_seq");
    
    uesr_poll_seq_for_error = dmi_csr_poll_error_status_seq::type_id::create("uesr_poll_seq_for_error");
   <%if(obj.DmiInfo[obj.Id].fnEnableQos) {%> 
      qos_ctrl_reg_seq = dmi_csr_qos_ctrl_reg_seq::type_id::create("qos_ctrl_reg_seq");
   <% } %>

    <% if (obj.INHOUSE_APB_VIP) { %>
       csr_init_seq = dmi_csr_init_seq::type_id::create("csr_init_seq");
    <% } %>

`ifdef INHOUSE_AXI
  m_slave_read_seq   = axi_slave_read_seq::type_id::create("slave_read_seq");
  m_slave_write_seq  = axi_slave_write_seq::type_id::create("slave_write_seq");

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
  if($test$plusargs("saturate_rbs_test")) begin
    test_seq = dmi_rb_seq::type_id::create("test_seq");
    test_seq.m_scb = m_env.m_sb;
  end
  else begin
    test_seq = dmi_seq::type_id::create("test_seq");
    test_seq.m_scb = m_env.m_sb;
  end
  
  test_vseq = dmi_vseq::type_id::create("test_vseq");
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

<% if(obj.useCmc) { %>
  <% if(obj.testBench == 'dmi') { %>
`ifndef VCS
    if (k_csr_SMC_mntop_seq) begin
`else // `ifndef VCS
    if (k_csr_SMC_mntop_seq != "") begin
`endif // `ifndef VCS ... `else ... 
<% } else {%>
    if (k_csr_SMC_mntop_seq) begin
<% } %>
    <% for (i in SMC_mntop_seqs) { %>
        if (k_csr_SMC_mntop_seq == "<%=SMC_mntop_seqs[i]%>")
            smc_mntop_csr_seq = <%=SMC_mntop_seqs[i]%>::type_id::create("smc_mntop_csr_seq"); 
    <% } %>
    end
<% } %>
<% if(obj.useCmc) { %>
 <% if(obj.testBench == 'dmi') { %>
`ifndef VCS
    if (k_csr_SMC_mntop_seq_for_error) begin
`else // `ifndef VCS
    if (k_csr_SMC_mntop_seq_for_error != "") begin
`endif // `ifndef VCS ... `else ... 
<% } else {%>
    if (k_csr_SMC_mntop_seq_for_error) begin
<% } %>
    <% for (i in SMC_mntop_seqs_for_error) { %>
        if (k_csr_SMC_mntop_seq_for_error == "<%=SMC_mntop_seqs_for_error[i]%>")
            smc_mntop_csr_seq_for_error = <%=SMC_mntop_seqs_for_error[i]%>::type_id::create("smc_mntop_csr_seq_for_error"); 
    <% } %>
    end
<% } %>
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
  cctrlr_csr_seq.model   = m_env.m_regs;
  sys_event_csr_seq.model = m_env.m_regs;
<% if(obj.DmiInfo[obj.Id].fnEnableQos) { %>
  qos_ctrl_reg_seq.model = m_env.m_regs;
<% } %>

<% if(obj.useCmc) { %>
 <% if(obj.testBench == 'dmi') { %>
`ifndef VCS
    if (k_csr_SMC_mntop_seq) begin
`else // `ifndef VCS
    if (k_csr_SMC_mntop_seq != "") begin
`endif // `ifndef VCS ... `else ... 
<% } else {%>
    if (k_csr_SMC_mntop_seq) begin
<% } %>
    smc_mntop_csr_seq.model       = m_env.m_regs;
  end
   <% if(obj.testBench == 'dmi') { %>
`ifndef VCS
    if (k_csr_SMC_mntop_seq_for_error) begin
`else // `ifndef VCS
    if (k_csr_SMC_mntop_seq_for_error != "") begin
`endif // `ifndef VCS ... `else ... 
<% } else {%>
    if (k_csr_SMC_mntop_seq_for_error) begin
<% } %>
    smc_mntop_csr_seq_for_error.model       = m_env.m_regs;
  end
<% } %>

    // configure Address Translation Registers if needed
    // This is done before traffic starts
    fork
<% if(obj.testBench == 'dmi') { %>
`ifndef VCS
    if (k_csr_seq) begin
`else // `ifndef VCS
    if (k_csr_seq != "") begin
`endif // `ifndef VCS ... `else ... 
<% } else {%>
    if (k_csr_seq) begin
<% } %>
       `uvm_info($sformatf("%m"), $sformatf("AddrTrans: skip test since other csr sequences are enabled"), UVM_NONE)
    end else begin
       phase.raise_objection(this, "Start addr_trans_seq");
<% if (obj.DmiInfo[obj.Id].nAddrTransRegisters > 0) { %>
       #1ps;
       m_addr_trans_seq = dmi_csr_addr_trans_seq::type_id::create("m_addr_trans_seq");
       m_addr_trans_seq.m_regs = m_env.m_regs;

       if (! m_env.m_regs) begin
          `uvm_error("AddrTrans", $sformatf("m_regs is NULL"))
       end
       if (! m_addr_trans_seq.m_regs) begin
          `uvm_error("AddrTrans", $sformatf("addr_trans_seq m_regs is NULL"))
       end else begin
          `uvm_info($sformatf("%m"), $sformatf("AddrTrans: Staring sequence with m_regs=%p", m_addr_trans_seq.m_regs), UVM_LOW)
       end
       m_addr_trans_seq.start(m_env.m_apb_agent.m_apb_sequencer);
<%  } %>
       phase.drop_objection(this, "Finished addr_trans_seq");
    end
    join

 
<% } %>
   if($test$plusargs("directed_err_test "))begin
       test_seq.wt_cmd_cln_inv.set_value(0); 
       test_seq.wt_cmd_cln_vld.set_value(0); 
       test_seq.wt_cmd_cln_ShPsist.set_value(0); 
       test_seq.wt_cmd_mk_inv.set_value(0); 
       test_seq.wt_dtw_no_dt.set_value(0);
       test_seq.wt_dtw_dt_ptl.set_value(0);
       test_seq.wt_dtw_dt_dty.set_value(0);
       test_seq.wt_dtw_dt_cln.set_value(0); 
       test_seq.wt_cmd_wr_nc_ptl.set_value(0); 
       test_seq.wt_cmd_wr_nc_full.set_value(0);
       test_seq.wt_dtw_mrg_mrd_ucln.set_value(0);
       test_seq.wt_dtw_mrg_mrd_udty.set_value(0);
       test_seq.wt_dtw_mrg_mrd_inv.set_value(0);
       test_seq.wt_cmd_rd_atm.set_value(0);
       test_seq.wt_cmd_wr_atm.set_value(0);
       test_seq.wt_cmd_swap_atm.set_value(0);
       test_seq.wt_cmd_cmp_atm.set_value(0);
       test_seq.wt_mrd_flush.set_value(0); 
       test_seq.wt_mrd_cln.set_value(0); 
       test_seq.wt_mrd_inv.set_value(0); 
   end
   if($test$plusargs("cmd_mrd_traffic"))begin
       
       test_seq.wt_dtw_intervention.set_value(0);
       test_seq.wt_dtw_no_dt.set_value(0);
       test_seq.wt_dtw_dt_ptl.set_value(0);
       test_seq.wt_dtw_dt_dty.set_value(0);
       test_seq.wt_dtw_dt_cln.set_value(0); 
       test_seq.wt_dtw_mrg_mrd_ucln.set_value(0);
       test_seq.wt_dtw_mrg_mrd_udty.set_value(0);
       test_seq.wt_dtw_mrg_mrd_inv.set_value(0);
       test_seq.wt_cmd_rd_atm.set_value(50);
       test_seq.wt_cmd_wr_atm.set_value(50);
       test_seq.wt_cmd_swap_atm.set_value(50);
       test_seq.wt_cmd_cmp_atm.set_value(50);
       test_seq.wt_mrd_rd_with_unq_cln.set_value(100);
       test_seq.wt_mrd_rd_with_shr_cln.set_value(100);
       test_seq.wt_mrd_rd_with_inv.set_value(100);
       test_seq.wt_mrd_rd_with_unq.set_value(100);
       test_seq.wt_mrd_flush.set_value(100); 
       test_seq.wt_mrd_cln.set_value(100); 
       test_seq.wt_mrd_inv.set_value(100);
       test_seq.wt_cmd_pref.set_value(10); 
       test_seq.wt_cmd_cln_inv.set_value(10); 
       test_seq.wt_cmd_cln_vld.set_value(10); 
       test_seq.wt_cmd_cln_ShPsist.set_value(10); 
       test_seq.wt_cmd_mk_inv.set_value(10); 
       test_seq.wt_cmd_rd_nc.set_value(100);
       test_seq.wt_cmd_wr_nc_ptl.set_value(100); 
       test_seq.wt_cmd_wr_nc_full.set_value(100);
   end
   if($test$plusargs("dmi_mrd_only"))begin
       test_seq.wt_cmd_cln_inv.set_value(0); 
       test_seq.wt_cmd_cln_vld.set_value(0); 
       test_seq.wt_cmd_cln_ShPsist.set_value(0); 
       test_seq.wt_cmd_mk_inv.set_value(0); 
       test_seq.wt_cmd_pref.set_value(0); 
       test_seq.wt_dtw_no_dt.set_value(0);
       test_seq.wt_dtw_dt_ptl.set_value(0);
       test_seq.wt_dtw_dt_dty.set_value(0);
       test_seq.wt_dtw_dt_cln.set_value(0); 
       test_seq.wt_cmd_rd_nc.set_value(0);
       test_seq.wt_cmd_wr_nc_ptl.set_value(0); 
       test_seq.wt_cmd_wr_nc_full.set_value(0);
       test_seq.wt_dtw_mrg_mrd_ucln.set_value(0);
       test_seq.wt_dtw_mrg_mrd_udty.set_value(0);
       test_seq.wt_dtw_mrg_mrd_inv.set_value(0);
       test_seq.wt_cmd_rd_atm.set_value(0);
       test_seq.wt_cmd_wr_atm.set_value(0);
       test_seq.wt_cmd_swap_atm.set_value(0);
       test_seq.wt_cmd_cmp_atm.set_value(0);
    end
   if($test$plusargs("dmi_cmo_only"))begin
       test_seq.wt_cmd_pref.set_value(0); 
       test_seq.wt_mrd_pref.set_value(0); 
       test_seq.wt_dtw_no_dt.set_value(0);
       test_seq.wt_dtw_dt_ptl.set_value(0);
       test_seq.wt_dtw_dt_dty.set_value(0);
       test_seq.wt_dtw_dt_cln.set_value(0); 
       test_seq.wt_cmd_rd_nc.set_value(0);
       test_seq.wt_cmd_wr_nc_ptl.set_value(0); 
       test_seq.wt_cmd_wr_nc_full.set_value(0);
       test_seq.wt_dtw_mrg_mrd_ucln.set_value(0);
       test_seq.wt_dtw_mrg_mrd_udty.set_value(0);
       test_seq.wt_dtw_mrg_mrd_inv.set_value(0);
       test_seq.wt_cmd_rd_atm.set_value(0);
       test_seq.wt_cmd_wr_atm.set_value(0);
       test_seq.wt_cmd_swap_atm.set_value(0);
       test_seq.wt_cmd_cmp_atm.set_value(0);
       test_seq.wt_mrd_rd_with_unq_cln.set_value(0);
       test_seq.wt_mrd_rd_with_shr_cln.set_value(0);
       test_seq.wt_mrd_rd_with_inv.set_value(0);
       test_seq.wt_mrd_rd_with_unq.set_value(0);
    end
   if($test$plusargs("dmi_rd_only"))begin
       test_seq.wt_cmd_cln_inv.set_value(0); 
       test_seq.wt_cmd_cln_vld.set_value(0); 
       test_seq.wt_cmd_cln_ShPsist.set_value(0); 
       test_seq.wt_cmd_mk_inv.set_value(0); 
       test_seq.wt_cmd_pref.set_value(0); 
       test_seq.wt_dtw_no_dt.set_value(0);
       test_seq.wt_dtw_dt_ptl.set_value(0);
       test_seq.wt_dtw_dt_dty.set_value(0);
       test_seq.wt_dtw_dt_cln.set_value(0); 
       test_seq.wt_cmd_wr_nc_ptl.set_value(0); 
       test_seq.wt_cmd_wr_nc_full.set_value(0);
       test_seq.wt_dtw_mrg_mrd_ucln.set_value(0);
       test_seq.wt_dtw_mrg_mrd_udty.set_value(0);
       test_seq.wt_dtw_mrg_mrd_inv.set_value(0);
       test_seq.wt_cmd_rd_atm.set_value(0);
       test_seq.wt_cmd_wr_atm.set_value(0);
       test_seq.wt_cmd_swap_atm.set_value(0);
       test_seq.wt_cmd_cmp_atm.set_value(0);
    end
    if($test$plusargs("dmi_mrd_dtwmrgmrd_only"))begin
       test_seq.wt_cmd_cln_inv.set_value(0); 
       test_seq.wt_cmd_cln_vld.set_value(0); 
       test_seq.wt_cmd_cln_ShPsist.set_value(0); 
       test_seq.wt_cmd_mk_inv.set_value(0); 
       test_seq.wt_cmd_pref.set_value(0); 
       test_seq.wt_dtw_no_dt.set_value(0);
       test_seq.wt_dtw_dt_ptl.set_value(0);
       test_seq.wt_dtw_dt_dty.set_value(0);
       test_seq.wt_dtw_dt_cln.set_value(0); 
       test_seq.wt_cmd_wr_nc_ptl.set_value(0); 
       test_seq.wt_cmd_wr_nc_full.set_value(0);
       test_seq.wt_cmd_rd_atm.set_value(0);
       test_seq.wt_cmd_wr_atm.set_value(0);
       test_seq.wt_cmd_swap_atm.set_value(0);
       test_seq.wt_cmd_cmp_atm.set_value(0);
    end
   if($test$plusargs("dmi_cohwr_only"))begin
       test_seq.wt_mrd_rd_with_unq_cln.set_value(0);
       test_seq.wt_mrd_rd_with_shr_cln.set_value(0);
       test_seq.wt_mrd_rd_with_inv.set_value(0);
       test_seq.wt_mrd_rd_with_unq.set_value(0);
       test_seq.wt_mrd_flush.set_value(0); 
       test_seq.wt_mrd_cln.set_value(0); 
       test_seq.wt_mrd_inv.set_value(0); 
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
       test_seq.wt_cmd_rd_atm.set_value(0);
       test_seq.wt_cmd_wr_atm.set_value(0);
       test_seq.wt_cmd_swap_atm.set_value(0);
       test_seq.wt_cmd_cmp_atm.set_value(0);
    end
   if($test$plusargs("dmi_ncrd_only"))begin
       test_seq.wt_mrd_rd_with_unq_cln.set_value(0);
       test_seq.wt_mrd_rd_with_shr_cln.set_value(0);
       test_seq.wt_mrd_rd_with_inv.set_value(0);
       test_seq.wt_mrd_rd_with_unq.set_value(0);
       test_seq.wt_mrd_flush.set_value(0); 
       test_seq.wt_mrd_cln.set_value(0); 
       test_seq.wt_mrd_inv.set_value(0); 
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
       test_seq.wt_cmd_wr_nc_ptl.set_value(0); 
       test_seq.wt_cmd_wr_nc_full.set_value(0);
       test_seq.wt_dtw_mrg_mrd_ucln.set_value(0);
       test_seq.wt_dtw_mrg_mrd_udty.set_value(0);
       test_seq.wt_dtw_mrg_mrd_inv.set_value(0);
       test_seq.wt_cmd_rd_atm.set_value(0);
       test_seq.wt_cmd_wr_atm.set_value(0);
       test_seq.wt_cmd_swap_atm.set_value(0);
       test_seq.wt_cmd_cmp_atm.set_value(0);
       test_seq.wt_cmd_rd_nc.set_value(100);
    end
   if($test$plusargs("dmi_ncwr_only"))begin
       test_seq.wt_cmd_wr_nc_ptl.set_value(50); 
       test_seq.wt_cmd_wr_nc_full.set_value(50);
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
       test_seq.wt_cmd_rd_nc.set_value(0);
       test_seq.wt_cmd_cln_inv.set_value(0); 
       test_seq.wt_cmd_cln_vld.set_value(0); 
       test_seq.wt_cmd_cln_ShPsist.set_value(0); 
       test_seq.wt_cmd_mk_inv.set_value(0); 
       test_seq.wt_cmd_pref.set_value(0); 
       test_seq.wt_dtw_mrg_mrd_ucln.set_value(0);
       test_seq.wt_dtw_mrg_mrd_udty.set_value(0);
       test_seq.wt_dtw_mrg_mrd_inv.set_value(0);
       test_seq.wt_cmd_rd_atm.set_value(0);
       test_seq.wt_cmd_wr_atm.set_value(0);
       test_seq.wt_cmd_swap_atm.set_value(0);
       test_seq.wt_cmd_cmp_atm.set_value(0);
    end
   if($test$plusargs("dmi_wr_only"))begin
       test_seq.wt_mrd_rd_with_unq_cln.set_value(0);
       test_seq.wt_mrd_rd_with_shr_cln.set_value(0);
       test_seq.wt_mrd_rd_with_inv.set_value(0);
       test_seq.wt_mrd_rd_with_unq.set_value(0);
       test_seq.wt_mrd_flush.set_value(0); 
       test_seq.wt_mrd_cln.set_value(0); 
       test_seq.wt_mrd_inv.set_value(0); 
       test_seq.wt_mrd_pref.set_value(0); 
       test_seq.wt_dtw_no_dt.set_value(0);
       test_seq.wt_cmd_rd_nc.set_value(0);
       test_seq.wt_cmd_cln_inv.set_value(0); 
       test_seq.wt_cmd_cln_vld.set_value(0); 
       test_seq.wt_cmd_cln_ShPsist.set_value(0); 
       test_seq.wt_cmd_mk_inv.set_value(0); 
       test_seq.wt_cmd_pref.set_value(0); 
       test_seq.wt_dtw_mrg_mrd_ucln.set_value(0);
       test_seq.wt_dtw_mrg_mrd_udty.set_value(0);
       test_seq.wt_dtw_mrg_mrd_inv.set_value(0);
       test_seq.wt_cmd_rd_atm.set_value(0);
       test_seq.wt_cmd_wr_atm.set_value(0);
       test_seq.wt_cmd_swap_atm.set_value(0);
       test_seq.wt_cmd_cmp_atm.set_value(0);
    end
   if($test$plusargs("dmi_Rdwr_only"))begin
       test_seq.wt_mrd_flush.set_value(0); 
       test_seq.wt_mrd_cln.set_value(0); 
       test_seq.wt_mrd_inv.set_value(0); 
       test_seq.wt_dtw_no_dt.set_value(0);
       test_seq.wt_cmd_cln_inv.set_value(0); 
       test_seq.wt_cmd_cln_vld.set_value(0); 
       test_seq.wt_cmd_cln_ShPsist.set_value(0); 
       test_seq.wt_cmd_mk_inv.set_value(0); 
       test_seq.wt_cmd_rd_atm.set_value(0);
       test_seq.wt_cmd_wr_atm.set_value(0);
       test_seq.wt_cmd_swap_atm.set_value(0);
       test_seq.wt_cmd_cmp_atm.set_value(0);
    end
//Remove the dependency of Atomic Ops on RdAllocDisable CONC-10837
  <% if(obj.DmiInfo[0].useAtomic) { %>     
   if($test$plusargs("dmi_atomic_test_only") && k_cmc_policy[0] && k_cmc_policy[1])begin
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
    else if(!$test$plusargs("add_atomic") || !(k_cmc_policy[0] && k_cmc_policy[1]))begin
        test_seq.wt_cmd_rd_atm.set_value(0);
        test_seq.wt_cmd_wr_atm.set_value(0);
        test_seq.wt_cmd_swap_atm.set_value(0);
        test_seq.wt_cmd_cmp_atm.set_value(0);
   end
 <% } %>
   if($test$plusargs("dmi_dtw_mrg_mrd_test_only"))begin
       test_seq.wt_mrd_rd_with_unq_cln.set_value(0);
       test_seq.wt_mrd_rd_with_shr_cln.set_value(0);
       test_seq.wt_mrd_rd_with_inv.set_value(0);
       test_seq.wt_mrd_rd_with_unq.set_value(0);
       test_seq.wt_mrd_flush.set_value(0); 
       test_seq.wt_mrd_cln.set_value(0); 
       test_seq.wt_mrd_inv.set_value(0); 
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
   end
   else if(!$test$plusargs("add_dtwMrgMrd")) begin
       test_seq.wt_dtw_mrg_mrd_ucln.set_value(0);
       test_seq.wt_dtw_mrg_mrd_udty.set_value(0);
       test_seq.wt_dtw_mrg_mrd_inv.set_value(0);
   end
   if($test$plusargs("dmi_2dtw_intervention_only"))begin
       test_seq.wt_dtw_intervention.set_value(100);
       test_seq.wt_dtw_dt_ptl.set_value(100);
   end
   else if (!$test$plusargs("add_2dtw_intervention")) begin
       test_seq.wt_dtw_intervention.set_value(0);
   end
<% if(!obj.useCmc) { %>
       test_seq.wt_cmd_rd_atm.set_value(0);
       test_seq.wt_cmd_wr_atm.set_value(0);
       test_seq.wt_cmd_swap_atm.set_value(0);
       test_seq.wt_cmd_cmp_atm.set_value(0);
<% } else { %>
     if(!(k_cmc_policy[0] && k_cmc_policy[1]))begin
       test_seq.wt_cmd_rd_atm.set_value(0);
       test_seq.wt_cmd_wr_atm.set_value(0);
       test_seq.wt_cmd_swap_atm.set_value(0);
       test_seq.wt_cmd_cmp_atm.set_value(0);
     end
<% } %>
     if(!$test$plusargs("enable_mrd_pref")) begin
       test_seq.wt_mrd_pref.set_value(0);
     end
     if($test$plusargs("enable_only_atomics")) begin
       test_seq.wt_cmd_rd_atm.set_value(100);
       test_seq.wt_cmd_wr_atm.set_value(100);
       test_seq.wt_cmd_swap_atm.set_value(100);
       test_seq.wt_cmd_cmp_atm.set_value(100);
     end

  test_seq.k_atomic_opcode           = k_atomic_opcode ;
  test_seq.k_intfsize                = k_intfsize ;
  test_seq.k_back_to_back_types    = k_back_to_back_types;
  test_seq.k_back_to_back_chains   = k_back_to_back_chains;
  test_seq.k_force_allocate        = k_force_allocate;
  test_seq.k_addr_trans_hit        = k_addr_trans_hit;
  test_seq.use_last_dealloc        = use_last_dealloc;
  test_seq.use_adj_addr            = use_adj_addr;
  test_seq.mrd_use_last_mrd_pref        = mrd_use_last_mrd_pref;

  test_seq.k_num_cmd               = k_num_cmd;
  test_seq.k_num_addr              = k_num_addr;

  test_seq.k_min_reuse_q_size      = k_min_reuse_q_size;
  test_seq.k_max_reuse_q_size      = k_max_reuse_q_size;
  test_seq.k_reuse_q_pct           =  k_reuse_q_pct;

  test_seq.k_sp_ns                 = k_sp_ns;
  if(m_env.m_cfg.has_scoreboard) begin
    m_env.m_sb.cov.k_sp_base_addr  = k_sp_base_addr;
    m_env.m_sb.cov.k_sp_max_addr   = k_sp_max_addr;
  end
  test_seq.sp_ways                 = sp_ways;
  test_seq.sp_enabled              = sp_en;

  test_seq.k_full_cl_only          = k_full_cl_only;
  test_seq.k_force_size            = k_force_size;
  test_seq.k_force_mw              = k_force_mw;
    
  test_seq.k_use_all_str_msg_id    = k_use_all_str_msg_id;
  test_seq.k_atomic_directed       = k_atomic_directed;

  test_seq.n_pending_txn_mode      = n_pending_txn_mode;

  test_seq.lookup_en               = k_cmc_policy[0];
  test_seq.alloc_en                = k_cmc_policy[1];
  test_seq.ClnWrAllocDisable       = k_cmc_policy[2];
  test_seq.DtyWrAllocDisable       = k_cmc_policy[3];
  test_seq.RdAllocDisable          = k_cmc_policy[4];
  test_seq.WrAllocDisable          = k_cmc_policy[5];
  test_seq.uncorr_wrbuffer_err     = uncorr_wrbuffer_err;
`ifdef INHOUSE_AXI
      m_slave_read_seq.m_read_addr_chnl_seqr   = m_env.m_axi_slave_agent.m_read_addr_chnl_seqr;
      m_slave_read_seq.m_read_data_chnl_seqr   = m_env.m_axi_slave_agent.m_read_data_chnl_seqr;
      m_slave_read_seq.m_memory_model          = m_axi_memory_model;
      m_slave_write_seq.m_write_addr_chnl_seqr = m_env.m_axi_slave_agent.m_write_addr_chnl_seqr;
      m_slave_write_seq.m_write_data_chnl_seqr = m_env.m_axi_slave_agent.m_write_data_chnl_seqr;
      m_slave_write_seq.m_write_resp_chnl_seqr = m_env.m_axi_slave_agent.m_write_resp_chnl_seqr;
      m_slave_write_seq.m_memory_model         = m_axi_memory_model;
      test_seq.m_axi_memory_model              = m_axi_memory_model;
      
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

// TODO as per Q_Chnl Vplan    m_q_chnl_seq.start(m_env.m_q_chnl_agent.m_q_chnl_seqr);

 <% if(obj.INHOUSE_APB_VIP && obj.useCmc && obj.DmiInfo[obj.Id].ccpParams.useScratchpad) { %>
  csr_init_seq.ScPadEn        = sp_en;
  csr_init_seq.ScPadBaseAddr  = ScPadBaseAddr;
  csr_init_seq.ScPadBaseAddr_i= m_env_cfg.sp_base_addr_i;
  csr_init_seq.sp_ns          = k_sp_ns;
  csr_init_seq.k_sp_base_addr = k_sp_base_addr;
  csr_init_seq.NumScPadWays   = NumScPadWays;
  csr_init_seq.ScPadSize      = sp_size;
  if(sp_en) begin
    csr_init_seq.AMIG_valid    = m_env_cfg.amig_valid;
    if(csr_init_seq.AMIG_valid) begin
      csr_init_seq.AMIG_set      = m_env_cfg.amig_set;
      csr_init_seq.AMIF_way      = m_env_cfg.amif_way;
      csr_init_seq.AMIF_function = m_env_cfg.amif_func;
    end
  end
 <% if(obj.testBench == 'dmi') { %>
`ifndef VCS
    if (k_csr_seq) begin
`else // `ifndef VCS
    if (k_csr_seq != "") begin
`endif // `ifndef VCS ... `else ... 
<% } else {%>
    if (k_csr_seq) begin
<% } %>
  end
 <% } %>
  
   csr_init_seq.cmc_policy          = k_cmc_policy;
   csr_init_seq.uncorr_wrbuffer_err = uncorr_wrbuffer_err;
   csr_init_seq.WrDataClnPropagateEn= k_WrDataClnPropagateEn;
<% if(obj.useCmc) { %>
   if (perfmon_test) begin
     // when perf_mon the cache tag is already iniialized (ISR_value=1) because the pef monitor register are set first
     csr_init_seq.perfmon_test = 1; 
   end
<% } %>
  if(m_env.m_cfg.has_scoreboard) begin
    m_env.m_sb.k_intfsize            = EN_DMI_VSEQ ? m_env_cfg.m_args.k_intfsize : k_intfsize;
    m_env.m_sb.WrDataClnPropagateEn  = EN_DMI_VSEQ ? m_env_cfg.csr_wr_data_cln_prop_en: k_WrDataClnPropagateEn;
    m_env.m_sb.SysEventDisable       = EN_DMI_VSEQ ? m_env_cfg.m_args.k_sys_event_disable : k_SysEventDisable;
  end

 <% if(obj.INHOUSE_APB_VIP) { %>
  if(!$test$plusargs("boot_region_access"))begin
  phase.raise_objection(this, "Start dmi_csr_init_seq");
  `uvm_info("run_main", "dmi_csr_init_seq started",UVM_NONE)
  csr_init_seq.start(m_env.m_apb_agent.m_apb_sequencer);
  `uvm_info("run_main", "dmi_csr_init_seq finished",UVM_NONE)
  #100ns;
  end
  phase.drop_objection(this, "Finish dmi_csr_init_seq");
 <% } %>
    
  main_seq_iter_pre_hook(phase,perf_mon_iter); // virtual task  !!! after csr_init !!!

  //Trace capture csr seq
  cctrlr_csr_seq.cctrlr_value     = cctrlr_value;
  `uvm_info("run_main", "dmi_cctrlr_csr_seq started",UVM_NONE)
  cctrlr_csr_seq.start(m_env.m_apb_agent.m_apb_sequencer);
  if ($test$plusargs("tcap_scb_en")) begin
    m_env.m_trace_debug_scb.port_capture_en = cctrlr_csr_seq.set_port_capture_en ;
    m_env.m_trace_debug_scb.gain = cctrlr_csr_seq.set_gain ;
    m_env.m_trace_debug_scb.inc = cctrlr_csr_seq.set_inc ;
  end
  `uvm_info("run_main", "dmi_cctrlr_csr_seq finished",UVM_NONE)

  //sys_event csr seq :
  if(!($test$plusargs("ex_sys_evt"))) begin
  `uvm_info("run_main", "dmi_sys_event_csr_seq started",UVM_NONE)
  sys_event_csr_seq.start(m_env.m_apb_agent.m_apb_sequencer);
  `uvm_info("run_main", "dmi_sys_event_csr_seq finished",UVM_NONE)
  end 
  #10ns;

  // DMIUTQOSCR - QOS Threshold register programming sequence
  <% if(obj.DmiInfo[obj.Id].fnEnableQos) { %>
     if($test$plusargs("prog_dmi_qos_th_csr")) begin
         `uvm_info("run_main", "dmi_csr_qos_ctrl_reg_seq started", UVM_NONE)
         qos_ctrl_reg_seq.start(m_env.m_apb_agent.m_apb_sequencer);
         `uvm_info("run_main", "dmi_csr_qos_ctrl_reg_seq finished", UVM_NONE)
     end
  <% } %>

   <% if(obj.useResiliency) { %>
<% if(obj.testBench == 'dmi') { %>
`ifndef VCS
    if (!uvm_config_db#(event)::get(this,
                                   .inst_name ( "" ),
                                   .field_name( "kill_test" ),
                                   .value( kill_test ))) begin
       `uvm_error( "dmi_test run_phase", "kill_test event not found" )
    end

    if (!uvm_config_db#(event)::get(this,
                                   .inst_name ( "" ),
                                   .field_name( "raise_obj_for_resiliency_test" ),
                                   .value( raise_obj_for_resiliency_test ))) begin
       `uvm_error( "dmi_test run_phase", "raise_obj_for_resiliency_test event not found" )
    end

    if (!uvm_config_db#(event)::get(this,
                                   .inst_name ( "" ),
                                   .field_name( "drop_obj_for_resiliency_test" ),
                                   .value( drop_obj_for_resiliency_test ))) begin
       `uvm_error( "dmi_test run_phase", "drop_obj_for_resiliency_test event not found" )
    end

`else // `ifndef VCS
    if (!uvm_config_db#(uvm_event)::get(this,
                                   .inst_name ( "" ),
                                   .field_name( "kill_test" ),
                                   .value( kill_test ))) begin
       `uvm_error( "dmi_test run_phase", "kill_test event not found" )
    end  else begin
       `uvm_info( "dmi_test run_phase", "kill_test event found",UVM_DEBUG)
       if(kill_test==null)
         `uvm_error( "dmi_test run_phase", "kill_test event is null" )
    end

    if (!uvm_config_db#(uvm_event)::get(this,
                                   .inst_name ( "" ),
                                   .field_name( "raise_obj_for_resiliency_test" ),
                                   .value( raise_obj_for_resiliency_test ))) begin
       `uvm_error( "dmi_test run_phase", "raise_obj_for_resiliency_test event not found" )
    end  else begin
       `uvm_info( "dmi_test run_phase", "raise_obj_for_resiliency_test event found",UVM_DEBUG)
       if(raise_obj_for_resiliency_test==null)
         `uvm_error( "dmi_test run_phase", "raise_obj_for_resiliency_test event is null" )
    end

    if (!uvm_config_db#(uvm_event)::get(this,
                                   .inst_name ( "" ),
                                   .field_name( "drop_obj_for_resiliency_test" ),
                                   .value( drop_obj_for_resiliency_test ))) begin
       `uvm_error( "dmi_test run_phase", "drop_obj_for_resiliency_test event not found" )
    end  else begin
       `uvm_info( "dmi_test run_phase", "drop_obj_for_resiliency_test event found",UVM_DEBUG)
       if(drop_obj_for_resiliency_test==null)
         `uvm_error( "dmi_test run_phase", "drop_obj_for_resiliency_test event is null" )
    end

`endif // `ifndef VCS ... `else ... 
<% } else {%>
    if (!uvm_config_db#(event)::get(this,
                                   .inst_name ( "" ),
                                   .field_name( "kill_test" ),
                                   .value( kill_test ))) begin
       `uvm_error( "dmi_test run_phase", "kill_test event not found" )
    end

    if (!uvm_config_db#(event)::get(this,
                                   .inst_name ( "" ),
                                   .field_name( "raise_obj_for_resiliency_test" ),
                                   .value( raise_obj_for_resiliency_test ))) begin
       `uvm_error( "dmi_test run_phase", "raise_obj_for_resiliency_test event not found" )
    end

    if (!uvm_config_db#(event)::get(this,
                                   .inst_name ( "" ),
                                   .field_name( "drop_obj_for_resiliency_test" ),
                                   .value( drop_obj_for_resiliency_test ))) begin
       `uvm_error( "dmi_test run_phase", "drop_obj_for_resiliency_test event not found" )
    end
<% } %>

    fork
       begin
         <% if((obj.testBench != "fsys") && (obj.INHOUSE_APB_VIP)) { %>
         if($test$plusargs("check_corr_error_cnt")) begin
           res_corr_err_threshold_seq res_crtr_seq = res_corr_err_threshold_seq::type_id::create("res_crtr_seq");
           res_crtr_seq.model = m_env.m_regs;
           res_crtr_seq.start(m_env.m_apb_agent.m_apb_sequencer);
         end
         <% } %>
       end
       begin
          `uvm_info("run_main", "waiting for kill_test event to trigger",UVM_NONE)
        if(m_env.m_cfg.has_scoreboard)
          @m_env.m_sb.kill_test;
        else
          @kill_test;

          `uvm_info("run_main", "kill_test event triggered",UVM_NONE)

          // Fetching the objection from current phase
          objection = phase.get_objection();
 
          // Collecting all the objectors which currently have objections raised
          objection.get_objectors(objectors_list);
 
          // Dropping the objections forcefully
          foreach(objectors_list[i]) begin
            uvm_report_info("run_main", $sformatf("objection count %d", objection.get_objection_count(objectors_list[i])),UVM_MEDIUM);
            while(objection.get_objection_count(objectors_list[i]) != 0) begin
              phase.drop_objection(objectors_list[i], "dropping objections to kill the test");
            end
          end
       end
       begin
         if ($test$plusargs("expect_mission_fault")) begin
           if(!$test$plusargs("test_unit_duplication")) begin
             begin
               forever begin
                  #(100*1ns);
                  if (u_csr_probe_vif.fault_mission_fault == 0) begin
                     phase.raise_objection(this, "dmi_uncorr_error_bringup_test");
                     `uvm_info(get_name(),"raised_objection::uncorr", UVM_DEBUG);
                     @u_csr_probe_vif.fault_mission_fault;
                     phase.drop_objection(this, "dmi_uncorr_error_bringup_test");
                     `uvm_info(get_name(),"dropped_objection::uncorr", UVM_DEBUG);
                  end
                  if($test$plusargs("expect_mission_fault_cov"))begin
                    //repeat(10000) @(negedge u_csr_probe_vif.clk);
                    #1ms; // keep testcase timeout higher than this to avoid hearbeat failure
                  end
                  #(100*1ns);
                  `uvm_info($sformatf("%m"), $sformatf("<%=obj.BlockId%> saw mission fault. Kill test"), UVM_NONE)
                   <% if(obj.testBench == 'dmi') { %>
                   `ifndef VCS
                     -> kill_test;   // otherwise the test will hang and timeout
                   `else // `ifndef VCS
                        kill_test.trigger();   // otherwise the test will hang and timeout
                   `endif // `ifndef VCS ... `else ... 
                   <% } else {%>
                     -> kill_test;   // otherwise the test will hang and timeout
                   <% } %>
                  `uvm_info($sformatf("%m"), $sformatf("<%=obj.BlockId%> saw mission fault. Jump to report phase"), UVM_NONE)
                  phase.jump(uvm_report_phase::get());
               end
             end
           end
         end
       end
    join_none
   <% } %>


  //#Test.DMI.DetectEnNotSetNoErrorsInjected
  fork
      begin
         phase.raise_objection(this, "Start dmi_test run phase");
         `uvm_info("run_main", "test_seq objection raised",UVM_NONE)
         if ($test$plusargs("performance_test")) begin
            #3us;
         end
         <% if(obj.testBench == 'dmi') { %>
          `ifndef VCS
              if (k_csr_seq) begin
          `else // `ifndef VCS
              if (k_csr_seq != "") begin
          `endif // `ifndef VCS ... `else ... 
          <% } else {%>
              if (k_csr_seq) begin
          <% } %>
           `uvm_info("run_main","Waiting for CSR seq to set the control register",UVM_NONE)
           ev.wait_ptrigger();
           `uvm_info("run_main","Waiting Completed for CSR seq to set the control register",UVM_NONE)
         end
         `uvm_info("run_main","test_seq started",UVM_NONE)
           
         if(!$test$plusargs("uesr_poll_err_test"))begin
           if ((!smi_rx_stall_en) && (!force_axi_stall_en)) begin// disable main seq in a specific perf mon test case
             if(EN_DMI_VSEQ) begin
              test_vseq.start(m_env.m_smi_agent.m_smi_virtual_seqr);
             end
             else begin
              test_seq.start(m_env.m_smi_agent.m_smi_virtual_seqr);
             end
           end
         end
         else begin
           fork
             begin
               `uvm_info("run_main","dmi_csr_poll_error_status_seq started",UVM_NONE)
               uesr_poll_seq_for_error.model = m_env.m_regs;
               uesr_poll_seq_for_error.timeout_threshold = timeout_threshold;
               uesr_poll_seq_for_error.start(m_env.m_apb_agent.m_apb_sequencer);  
               `uvm_info("run_main","dmi_csr_poll_error_status_seq completed",UVM_NONE)
             end
             begin
               test_seq.start(m_env.m_smi_agent.m_smi_virtual_seqr);
             end
           join_any
         end
         if(!EN_DMI_VSEQ) begin
           this.cache_addr_list     = test_seq.cache_addr_list;
           this.bfm_pending_wr_txn  = test_seq.aiu_txn_count;
         end
         `uvm_info("run_main","test_seq completed",UVM_NONE)
         if (!$test$plusargs("inject_smi_uncorr_error") && !$test$plusargs("targ_id_error_test") && !EN_DMI_VSEQ) begin
           `uvm_info("run_main","test_seq legacy delay begin",UVM_NONE)
           #10us;
           `uvm_info("run_main","test_seq legacy delay end",UVM_NONE)
         end
         if($test$plusargs("wait_for_empty_tt")) begin
           wait(m_env.m_sb.wtt_q.size()+m_env.m_sb.rtt_q.size() == 0);
         end
      <% if(obj.INHOUSE_APB_VIP) { %>
      <% if(obj.useCmc) { %>
      <% if(obj.testBench == 'dmi') { %>
         `ifndef VCS
          if (k_csr_SMC_mntop_seq_for_error) begin
         `else // `ifndef VCS
          if (k_csr_SMC_mntop_seq_for_error != "") begin
         `endif // `ifndef VCS ... `else ... 
         <% } else {%>
          if (k_csr_SMC_mntop_seq_for_error) begin
         <% } %>
        `uvm_info("run_main", "smc_mntop_csr_seq_for_error started",UVM_NONE)
        smc_mntop_csr_seq_for_error.start(m_env.m_apb_agent.m_apb_sequencer);
        `uvm_info("run_main", "smc_mntop_csr_seq_for_error finished",UVM_NONE)
        if(!EN_DMI_VSEQ) begin
          #250us;
        end
      end
      <% } %>
      <% } %>
         if($test$plusargs("saturate_rbs_test")) begin
            k_num_cmd = test_seq.k_num_cmd;
            if(test_seq.rb_release_scenario)  begin
              test_seq.clear_pending_rb_release();
              m_env.m_sb.clear_pending_rb_release();
            end
         end
         phase.drop_objection(this, "Finish dmi_test run phase");
         `uvm_info("run_main", "test_seq objection dropped",UVM_NONE)
      end
<% if(obj.INHOUSE_APB_VIP) { %>
<% if(obj.useCmc) { %>
      <% if(obj.testBench == 'dmi') { %>
        `ifndef VCS
            if (k_csr_SMC_mntop_seq) begin
        `else // `ifndef VCS
            if (k_csr_SMC_mntop_seq != "") begin
        `endif // `ifndef VCS ... `else ... 
        <% } else {%>
            if (k_csr_SMC_mntop_seq) begin
        <% } %>
         phase.raise_objection(this, "Start smc_mntop_csr_seq run phase");
        `uvm_info("run_main", "smc_mntop_csr_seq started",UVM_NONE)
        smc_mntop_csr_seq.start(m_env.m_apb_agent.m_apb_sequencer);
        `uvm_info("run_main", "smc_mntop_csr_seq finished",UVM_NONE)
        #250us;
         phase.drop_objection(this, "Finish smc_mntop_csr_seq run phase");
      end
<% } %>
<% } %>
<% if (obj.INHOUSE_APB_VIP) { %>
      // ---------------------------------------------------
      // This block is added to help verifying SMI ports 
      // quiescing for trace capture...
      if ($value$plusargs("cctrlr_mod=%0d",cctrlr_mod)) begin
         int pickOne, kcount;

         for(int k=1; k<3; ++k) begin
            pickOne = (k==1) ? $urandom_range(50000,10000) : $urandom_range(3000,1000);

            kcount=0;
            while(kcount < pickOne) begin
              @(negedge u_csr_probe_vif.clk);
              clk_count_en = (++kcount==pickOne) ?  k : 0;
            end
         end
      end

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
        if (k_csr_seq == "dmi_trans_actv_high_seq") begin
           int count;
           ev.trigger();
           repeat(50) @(negedge u_csr_probe_vif.clk);
           `uvm_info("DMI CSR Seq", "Reading TransActv register",UVM_LOW)
           do begin
              @(negedge u_csr_probe_vif.clk);
              count++;
              if (count > 1000) begin
                 `uvm_error("dmi_trans_actv_test", "No enries in wtt/rtt queues for a long time")
              end
           end while ((m_env.m_sb.rtt_q.size() + m_env.m_sb.wtt_q.size()) == 0);
        end
        repeat(10) @(posedge u_csr_probe_vif.clk);
        `uvm_info("run_main", "csr_seq started",UVM_NONE)
        csr_seq.start(m_env.m_apb_agent.m_apb_sequencer);
        `uvm_info("run_main", "csr_seq finished",UVM_NONE)
        phase.drop_objection(this, "Finish csr_seq run phase");
      end

    // ------------------------------------------------------------------------
    // Special case:: Added for Trace Capture.
    // This thread will only be invoked, if and only if the user's intent is 
    // to modify the Trace Capture register CCTRLR in the middle of simulation
    begin
      if($value$plusargs("cctrlr_mod=%0d",cctrlr_mod)) begin
         wait(clk_count_en==1);                            // Turn off all the SMI Ports
         cctrlr_csr_seq.cctrlr_value &= 32'hffff_ff00;
         cctrlr_csr_seq.start(m_env.m_apb_agent.m_apb_sequencer);

         wait(clk_count_en==2);                            // Ready to load the new value. 
         cctrlr_csr_seq.cctrlr_value = $urandom | 32'h1;   // At least, 1 port will be set.
         cctrlr_csr_seq.start(m_env.m_apb_agent.m_apb_sequencer);
      end
    end

   //-------------------------------------------------------------------------------------
   //This thread will be invoked in the user wants to program  the QOS threshold control
   //register dynamically in middle of the simulation
   //-------------------------------------------------------------------------------------
 
   begin
      <% if(obj.DmiInfo[obj.Id].fnEnableQos) { %>  // Only execute for configs with QOS enabled
      if($test$plusargs("upd_dmi_qos_th_csr")) begin
         #($urandom_range(500,4000)*1ns);  //insert random delay to execute the sequence
         `uvm_info("run_main", "Updating dmi_csr_qos_ctrl_reg_seq started", UVM_NONE)
         m_env_cfg.qos_mode = QOS_UPDATE;
         qos_ctrl_reg_seq.start(m_env.m_apb_agent.m_apb_sequencer);
         `uvm_info("run_main", "Updating dmi_csr_qos_ctrl_reg_seq finished", UVM_NONE)
      end
      <% } %>
   end

<% } %>
      begin
        if (k_csr_seq == "dmi_trans_actv_high_seq") begin
          `uvm_info("DMI CSR Seq", "Starting to check TransActv register every cycle",UVM_LOW)
          forever begin
             @(negedge u_csr_probe_vif.clk);
                #2;                                                     //sampling rtt and wtt size after scoreboard settles down
                u_csr_probe_vif.rtt_size = m_env.m_sb.rtt_q.size();
                u_csr_probe_vif.wtt_size = m_env.m_sb.wtt_q.size();
                #5;                        
             if (u_csr_probe_vif.check_valid && ((((m_env.m_sb.rtt_q.size() + m_env.m_sb.wtt_q.size()) == 0) && (u_csr_probe_vif.TransActv !== 0)) ||
                 (((m_env.m_sb.rtt_q.size() + m_env.m_sb.wtt_q.size()) != 0) && (u_csr_probe_vif.TransActv !== 1)))) begin
                 if(((m_env.m_sb.rtt_q.size() + m_env.m_sb.wtt_q.size()) != 0) && (u_csr_probe_vif.TransActv !== 1)) begin
                   m_env.m_sb.compute_pma_exceptions($time);
                   if(m_env.m_sb.wtt_q.size !=0) begin
                     if(m_env.m_sb.wtt_q.size != m_env.m_sb.num_rb_waiting_on_dtw && m_env.m_sb.wtt_q.size != m_env.m_sb.num_dtws_early_transactv && m_env.m_sb.wtt_q.size != (m_env.m_sb.num_rb_waiting_on_dtw+m_env.m_sb.num_dtws_early_transactv) )
                       `uvm_error("dmi_trans_actv_test", $sformatf("WTT queue is not empty and dmi hasn't asserted TransActv. Wtt_size:%0d != %0d,%0d", m_env.m_sb.wtt_q.size, m_env.m_sb.num_rb_waiting_on_dtw,m_env.m_sb.num_dtws_early_transactv))
                     else
                       `uvm_info("dmi_trans_actv_test", $sformatf("WTT has %0d pending entries but they're marked as Dtw received, this should toggle the transactv high one cycle after DTW last", m_env.m_sb.wtt_q.size), UVM_MEDIUM)
                   end
                   if(m_env.m_sb.rtt_q.size !=0) begin
                     if(m_env.m_sb.num_dtws_early_transactv != m_env.m_sb.num_dtwmrgmrd)
                       `uvm_error("dmi_trans_actv_test", $sformatf("RTT queue has pending entries and dmi hasn't asserted TransActv but they are due to pending DTWs created on a DTWMrgMrd %0d != %0d", m_env.m_sb.num_dtwmrgmrd, m_env.m_sb.num_dtws_early_transactv))
                     else
                       `uvm_info("dmi_trans_actv_test", $sformatf("RTT queue has %0d pending entries when dmi asserted TransActv but they are due to pending DTWs created on a DTWMrgMrd", m_env.m_sb.rtt_q.size), UVM_MEDIUM)
                   end
                 end
                 else begin   
                   `uvm_error("dmi_trans_actv_test", $sformatf("TransActv is not correct TransActv %0b rtt_q size %0d wtt_q size %0d",
                                                             u_csr_probe_vif.TransActv, m_env.m_sb.rtt_q.size(), m_env.m_sb.wtt_q.size()))
                 end
             end else begin
                `uvm_info("dmi_trans_actv_test", $sformatf("TransActv register matched TransActv %0b rtt_q size %0d wtt_q size %0d",
                                                           u_csr_probe_vif.TransActv, m_env.m_sb.rtt_q.size(), m_env.m_sb.wtt_q.size()),UVM_HIGH)
             end
          end
        end
      end
   join
  `uvm_info("run_main", "fork join completed",UVM_NONE)
  main_seq_iter_post_hook(phase,perf_mon_iter); // virtual task
  end:forloop_main_seq_iter
  main_seq_post_hook(phase); // virtual task
    
  main_seq_hook_end_run_phase(phase); // virtual task
endtask : run_main

function void dmi_test::report_phase(uvm_phase phase);

  <% if ((obj.useResiliency) && (obj.testBench != "fsys")) { %>
  int res_corr_err_threshold;
  bit patch_conc_7033, patch_conc_7597;
  int tolerance_range_low_val, tolerance_range_high_val, res_corr_err_tolerance_cnt;
  int tb_res_smi_corr_err, rtl_res_smi_corr_err, mod_res_smi_corr_err, rtl_res_smi_corr_thresh;
  if($test$plusargs("expect_mission_fault")) begin
    if (u_csr_probe_vif.fault_mission_fault == 0) begin
      `uvm_error({"fault_injector_checker_",get_name()}, $sformatf({"expect_mission_fault argument is passed from command line & observed mission_fault=%0d"}, u_csr_probe_vif.fault_mission_fault))
    end else begin
      `uvm_info(get_name(), $sformatf({"expect_mission_fault argument is passed from command line & observed mission_fault=%0d"}, u_csr_probe_vif.fault_mission_fault), UVM_LOW)
    end
  end
  if(($test$plusargs("inj_cntl")) &&
     ($test$plusargs("smi_ndp_err_inj") ||
      $test$plusargs("smi_hdr_err_inj") ||
      $test$plusargs("smi_dp_ecc_inj")) &&
      $test$plusargs("check_corr_error_cnt")
    )
  begin
    patch_conc_7033 = 1; // TODO: disabled if CONC-7033 decides to stop counter at threshold+1

    tb_res_smi_corr_err = m_env.m_sb.res_smi_corr_err;
    rtl_res_smi_corr_err = u_csr_probe_vif.cerr_counter;
    rtl_res_smi_corr_thresh = u_csr_probe_vif.cerr_threshold;

    patch_conc_7597 = (tb_res_smi_corr_err > rtl_res_smi_corr_thresh) ? 0 : 1; // already hit threshold so no tolerance required
    if(patch_conc_7597) res_corr_err_tolerance_cnt = 1; // CONC-7597. 1 count tolerance added

    mod_res_smi_corr_err = (tb_res_smi_corr_err > rtl_res_smi_corr_thresh) ? (rtl_res_smi_corr_thresh + 1) : tb_res_smi_corr_err;
    tolerance_range_low_val = mod_res_smi_corr_err-res_corr_err_tolerance_cnt;
    tolerance_range_high_val = mod_res_smi_corr_err+res_corr_err_tolerance_cnt + patch_conc_7033;
    `uvm_info(get_full_name(), $sformatf({"tolerance_range=[%0d:%0d]"}, tolerance_range_low_val, tolerance_range_high_val), UVM_DEBUG)

    if(!(rtl_res_smi_corr_err inside {[tolerance_range_low_val : tolerance_range_high_val]})) begin
      `uvm_error(get_full_name(), $sformatf("CORR_ERR:: No of error injection(TB) Vs detection(RTL) counter mismatch {TB_raw=%0d|TB_adj=%0d|RTL=%0d}", tb_res_smi_corr_err, mod_res_smi_corr_err, rtl_res_smi_corr_err))
    end else begin
      `uvm_info(get_full_name(), $sformatf("CORR_ERR:: No of error injection(TB) Vs detection(RTL) counter match {TB_raw=%0d|TB_adj=%0d|RTL=%0d}", tb_res_smi_corr_err, mod_res_smi_corr_err, rtl_res_smi_corr_err), UVM_MEDIUM)
    end

		if(u_csr_probe_vif.cerr_counter > u_csr_probe_vif.cerr_threshold) begin
      if(u_csr_probe_vif.cerr_over_thres_fault !== 1) begin
        `uvm_error(get_full_name(), $sformatf("CORR_ERR:: counter value{%0d} is higher than threshold{%0d} but cerr_over_thres_fault{%0d} didn't triggered", u_csr_probe_vif.cerr_counter, u_csr_probe_vif.cerr_threshold, u_csr_probe_vif.cerr_over_thres_fault))
      end else begin
        `uvm_info(get_full_name(), $sformatf("CORR_ERR:: counter value{%0d} is higher than threshold{%0d} so cerr_over_thres_fault{%0d} triggered", u_csr_probe_vif.cerr_counter, u_csr_probe_vif.cerr_threshold, u_csr_probe_vif.cerr_over_thres_fault), UVM_MEDIUM)
      end
    end else begin
      if(u_csr_probe_vif.cerr_over_thres_fault === 1) begin
        `uvm_error(get_full_name(), $sformatf("CORR_ERR:: counter value{%0d} is lower than threshold{%0d} but cerr_over_thres_fault{%0d} triggered", u_csr_probe_vif.cerr_counter, u_csr_probe_vif.cerr_threshold, u_csr_probe_vif.cerr_over_thres_fault))
      end else begin
        `uvm_info(get_full_name(), $sformatf("CORR_ERR:: counter value{%0d} is lower than threshold{%0d} so cerr_over_thres_fault{%0d} didn't triggered", u_csr_probe_vif.cerr_counter, u_csr_probe_vif.cerr_threshold, u_csr_probe_vif.cerr_over_thres_fault), UVM_MEDIUM)
      end
    end
    if($value$plusargs("res_corr_err_threshold=%0d", res_corr_err_threshold)) begin
      if(u_csr_probe_vif.cerr_threshold != res_corr_err_threshold) begin
        `uvm_error(get_full_name(), $sformatf("CORR_ERR:: threshold value mis-match{RTL=%0d|TB=%0d}", u_csr_probe_vif.cerr_threshold, res_corr_err_threshold))
      end else begin
        `uvm_info(get_full_name(), $sformatf("CORR_ERR:: threshold value match{RTL=%0d|TB=%0d}", u_csr_probe_vif.cerr_threshold, res_corr_err_threshold), UVM_LOW)
      end
    end
  end
  <% } %>
  if($test$plusargs("uesr_poll_err_test") && m_env_cfg.has_scoreboard) begin
    if(ev_uesr_error.is_off() && m_env.m_sb.expectSysEvtTimeout) begin
      `uvm_error(get_name(), "Failed to trigger an expected error on UESR. Check dmi_csr_poll_error_status_seq")
    end
  end
  super.report_phase(phase);
endfunction

////////////////////////////////////////////////////////////////////////////////

`endif // DMI_TEST

/*
 *creating a stand alone testcase as testing for the features
 *related to unit duplication is done using force mechanism.
 */
class resiliency_unitduplication_test extends dmi_test;

  `uvm_component_utils(resiliency_unitduplication_test)

 <% if(obj.testBench == 'dmi') { %>
`ifndef VCS
  event raise_obj_for_resiliency_test;
  event drop_obj_for_resiliency_test;
`else // `ifndef VCS
  uvm_event raise_obj_for_resiliency_test;
  uvm_event drop_obj_for_resiliency_test;
  uvm_event_pool ev_pool = uvm_event_pool::get_global_pool();
  uvm_event dmi_reset_event = ev_pool.get("dmi_reset_event");
  uvm_event dmi_reset_event_complete = ev_pool.get("dmi_reset_event_complete");
`endif // `ifndef VCS ... `else ... 
<% } else {%>
  event raise_obj_for_resiliency_test;
  event drop_obj_for_resiliency_test;
<% } %>

  function new(string name = "resiliency_unitduplication_test", uvm_component parent = null);
    super.new(name, parent);
  endfunction : new

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
  <% if ((obj.useResiliency) && (obj.testBench != "fsys")) { %>
    if($test$plusargs("expect_mission_fault")) begin
      fault_injector_checker_demoter_h.demote_uvm_fatal = 1;
    end
  <% } %>
    m_env_cfg.has_scoreboard = 0;
  endfunction : build_phase
  
  virtual task run_phase(uvm_phase phase);
  
<% if(obj.testBench == 'dmi') { %>
`ifndef VCS
    if(!uvm_config_db#(event)::get(this, "", "raise_obj_for_resiliency_test", raise_obj_for_resiliency_test)) begin
      `uvm_error( "dmi_test run_phase", "raise_obj_for_resiliency_test event not found" )
    end

    if(!uvm_config_db#(event)::get(this, "", "drop_obj_for_resiliency_test", drop_obj_for_resiliency_test)) begin
      `uvm_error( "dmi_test run_phase", "drop_obj_for_resiliency_test event not found" )
    end

`else
    if(!uvm_config_db#(uvm_event)::get(this, "", "raise_obj_for_resiliency_test", raise_obj_for_resiliency_test)) begin
      `uvm_error( "dmi_test run_phase", "raise_obj_for_resiliency_test event not found" )
    end

    if(!uvm_config_db#(uvm_event)::get(this, "", "drop_obj_for_resiliency_test", drop_obj_for_resiliency_test)) begin
      `uvm_error( "dmi_test run_phase", "drop_obj_for_resiliency_test event not found" )
    end

`endif // `ifndef VCS
<% } else {%>
    if(!uvm_config_db#(event)::get(this, "", "raise_obj_for_resiliency_test", raise_obj_for_resiliency_test)) begin
      `uvm_error( "dmi_test run_phase", "raise_obj_for_resiliency_test event not found" )
    end

    if(!uvm_config_db#(event)::get(this, "", "drop_obj_for_resiliency_test", drop_obj_for_resiliency_test)) begin
      `uvm_error( "dmi_test run_phase", "drop_obj_for_resiliency_test event not found" )
    end
<% } %>
    phase.raise_objection(this, $sformatf("raise_objection from{%0s} in phase{%0s}",this.get_name(), phase.get_domain_name()));
    fork
      begin
        `uvm_info("run_main", "Waiting for random time units 2us", UVM_NONE)
        #2us;
      end
      begin
      <% if(obj.testBench == 'dmi') { %>
       `ifndef VCS
         `uvm_info("run_main", "waiting for raise_obj_for_resiliency_test event to trigger",UVM_NONE)
         @raise_obj_for_resiliency_test;
         `uvm_info("run_main", "raise_obj_for_resiliency_test event triggered",UVM_NONE)
         phase.raise_objection(this, "raising objection for resiliency test");
 
         @drop_obj_for_resiliency_test;
         phase.drop_objection(this, "dropping resiliency test objection");
       `else // `ifndef VCS
         `uvm_info("run_main", "waiting for raise_obj_for_resiliency_test event to trigger",UVM_NONE)
         raise_obj_for_resiliency_test.wait_trigger();
         `uvm_info("run_main", "raise_obj_for_resiliency_test event triggered",UVM_NONE)
         phase.raise_objection(this, "raising objection for resiliency test");
 
         drop_obj_for_resiliency_test.wait_trigger();
         phase.drop_objection(this, "dropping resiliency test objection");
       `endif // `ifndef VCS ... `else ... 
      <% } else {%>
         `uvm_info("run_main", "waiting for raise_obj_for_resiliency_test event to trigger",UVM_NONE)
         @raise_obj_for_resiliency_test;
         `uvm_info("run_main", "raise_obj_for_resiliency_test event triggered",UVM_NONE)
         phase.raise_objection(this, "raising objection for resiliency test");
 
         @drop_obj_for_resiliency_test;
         phase.drop_objection(this, "dropping resiliency test objection");
     <% } %>
        `uvm_info("run_main","Resiliency test objection dropped",UVM_NONE)
      end
      begin
        int reset_count = 0;
        fork
          begin
            forever begin
              `uvm_info("run_main",$sformatf("Waiting on dmi_reset_event to execute system reset| Count:%0d",reset_count),UVM_NONE)
              dmi_reset_event.wait_trigger();
              `uvm_info("run_main",$sformatf("Received a dmi_reset_event executing system reset| Count:%0d",reset_count),UVM_NONE)
              reset_system();
              `ifdef VCS
              dmi_reset_event_complete.trigger();
              `endif
              `uvm_info("run_main",$sformatf("dmi_reset_event system reset finished| Count:%0d",reset_count),UVM_NONE)
              reset_count++;
            end
          end
          begin
           `uvm_info("run_main","Resiliency test objection dropped, waiting on fork task",UVM_NONE)
           `ifndef VCS
             @drop_obj_for_resiliency_test;
           `else
             drop_obj_for_resiliency_test.wait_trigger();
           `endif
           `uvm_info("run_main","Resiliency test objection dropped, ending reset sequence",UVM_NONE)
          end
        join_any
      end
    join
    disable fork;
    phase.drop_objection(this, $sformatf("drop_objection from{%0s} in phase{%0s}",this.get_name(), phase.get_domain_name()));
    `uvm_info("run_main","resiliency_unitduplication_test finished",UVM_NONE)

  endtask : run_phase
  

  // avoiding any logic in the base class for the clean-up phase
  virtual function void pre_abort();
  endfunction
  virtual function void extract_phase(uvm_phase phase);
  endfunction
  virtual function void check_phase(uvm_phase phase);
  endfunction
  virtual function void report_phase(uvm_phase phase);
  endfunction

endclass : resiliency_unitduplication_test
