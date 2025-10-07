<%
    //all csr sequences
    var csr_seqs = [
        "chi_aiu_csr_caiuuedr_TransErrDetEn_seq",
        "chi_aiu_csr_caiucecr_TransErrDetEn_seq",
        "chi_aiu_csr_caiuuedr_ProtErrDetEn_seq",
        "chi_aiu_csr_address_region_overlap_seq",
        "chi_aiu_csr_secure_access",
        "chi_aiu_csr_no_address_hit_seq",
        "chi_aiu_csr_time_out_error_seq",
        "chi_aiu_csr_uuecr_sw_write_seq",
        "chi_aiu_csr_trace_debug_seq",
        "csr_connectivity_seq",
        "chi_aiu_csr_scm_seq",
        "chi_aiu_ral_sysco_seq",
        "access_unmapped_csr_addr",
        "chiaiu_csr_sysreq_event_seq",
        "chi_aiu_illegal_csr_access",
        "chi_aiu_qossr_status"
    ];
%>

//******************************************************************************
// Class    : chi_aiu_csr_all_reg_rd_reset_val_test 
// Purpose  : Reads all register reset values and matched with testbench
//******************************************************************************

class chi_aiu_csr_all_reg_rd_reset_val_test extends chi_aiu_base_test;
  `uvm_component_utils(chi_aiu_csr_all_reg_rd_reset_val_test)
   uvm_reg_hw_reset_seq reg_hw_reset_seq;
   chi_aiu_csr_id_reset_seq id_reset_seq;

  function new(string name = "chi_aiu_csr_all_reg_rd_reset_val_test", uvm_component parent=null);
    super.new(name,parent);
  endfunction: new

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    uvm_config_db#(bit)::set(uvm_root::get(),"*", "include_coverage", 0);
  endfunction : build_phase

  task run_phase (uvm_phase phase);
      super.run_phase(phase);
      uvm_resource_db#(bit)::set({"REG::",m_env.m_regs.<%=obj.DutInfo.strRtlNamePrefix%>.CAIUIDR.get_full_name()}, "NO_REG_TESTS", 1,this);
      uvm_resource_db#(bit)::set({"REG::",m_env.m_regs.<%=obj.DutInfo.strRtlNamePrefix%>.CAIUFUIDR.get_full_name()}, "NO_REG_TESTS", 1,this);
      reg_hw_reset_seq       = uvm_reg_hw_reset_seq::type_id::create("reg_hw_reset_seq");
      id_reset_seq           = chi_aiu_csr_id_reset_seq::type_id::create("id_reset_seq");
      reg_hw_reset_seq.model = m_env.m_regs;
      id_reset_seq.model     = m_env.m_regs;

      fork 
        begin
            phase.raise_objection(this, "Start CHI_AIU CSR reset sequence");
            #100ns;
            `uvm_info("CHI_AIU CSR Seq", "Starting CHI_AIU CSR reset sequence",UVM_LOW)
            reg_hw_reset_seq.start(m_env.m_apb_agent.m_apb_sequencer);
            #100ns;
            `uvm_info("CHI_AIU CSR Seq", "Starting CHI_AIU CSR ID reset sequence",UVM_LOW)
            id_reset_seq.start(m_env.m_apb_agent.m_apb_sequencer);
            #100ns;
            phase.drop_objection(this, "Finish CHI_AIU CSR reset sequence");
        end
      join
    endtask : run_phase
endclass: chi_aiu_csr_all_reg_rd_reset_val_test

////////////////////////////////////////////////////////////////////////////////
//******************************************************************************
// Class    : chi_aiu_csr_bit_bash_test 
// Purpose  : Write and read all registers to see if they are correctly written
//******************************************************************************
class chi_aiu_csr_bit_bash_test extends chi_aiu_base_test;
  `uvm_component_utils(chi_aiu_csr_bit_bash_test)
   uvm_reg_bit_bash_seq reg_bit_bash_seq;

  function new(string name = "chi_aiu_csr_bit_bash_test", uvm_component parent=null);
    super.new(name,parent);
  endfunction: new

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    uvm_config_db#(bit)::set(uvm_root::get(),"*", "include_coverage", 0);
    m_env_cfg.disable_scoreboard();
  endfunction : build_phase

  task run_phase (uvm_phase phase); // #Stimulus.CHIAIU.v3.4.SCM.RegisterTest
      super.run_phase(phase);
      uvm_resource_db#(bit)::set({"REG::",m_env.m_regs.<%=obj.DutInfo.strRtlNamePrefix%>.CAIUIDR.get_full_name()}, "NO_REG_TESTS", 1,this);
      uvm_resource_db#(bit)::set({"REG::",m_env.m_regs.<%=obj.DutInfo.strRtlNamePrefix%>.CAIUFUIDR.get_full_name()}, "NO_REG_TESTS", 1,this);
`ifdef VCS
      uvm_resource_db#(bit)::set({"REG::",m_env.m_regs.<%=obj.DutInfo.strRtlNamePrefix%>.CAIUTAR.get_full_name()}, "NO_REG_TESTS", 1,this); //CONC-8858
      uvm_resource_db#(bit)::set({"REG::",m_env.m_regs.<%=obj.DutInfo.strRtlNamePrefix%>.NRSBLR.get_full_name()}, "NO_REG_TESTS",1,this);
`endif  
      `ifdef USE_VIP_SNPS
          uvm_resource_db#(bit)::set({"REG::",m_env.m_regs.<%=obj.DutInfo.strRtlNamePrefix%>.CAIUTCR.get_full_name()}, "NO_REG_TESTS", 1,this);
        `ifndef SVT_CHI_ISSUE_B_ENABLE
             uvm_resource_db#(bit)::set({"REG::",m_env.m_regs.<%=obj.DutInfo.strRtlNamePrefix%>.CAIUTAR.get_full_name()}, "NO_REG_TESTS", 1,this); //CONC-8858
        `endif  
      `endif  
      reg_bit_bash_seq       = uvm_reg_bit_bash_seq::type_id::create("reg_bit_bash_seq");
      reg_bit_bash_seq.model = m_env.m_regs;
      fork 
        begin
            phase.raise_objection(this, "Start CHI_AIU bit-bash sequence");
            #200ns;
            `uvm_info("CHI_AIU CSR Seq", "Starting CHI_AIU CSR bit-bash sequence",UVM_NONE)
            reg_bit_bash_seq.start(m_env.m_apb_agent.m_apb_sequencer);
            #200ns;
            phase.drop_objection(this, "Finish CHI_AIU bit-bash sequence");
        end
      join

    endtask : run_phase
endclass: chi_aiu_csr_bit_bash_test

class chi_aiu_bringup_test extends chi_aiu_base_test;

  `uvm_component_utils(chi_aiu_bringup_test)

  //properties
`ifdef USE_VIP_SNPS
  //snps_chi_aiu_vseq  snps_vseq; 
  virtual caiu<%=obj.Id%>_chi_if m_chi_if_caiu<%=obj.Id%>;
  <%=obj.BlockId%>_chi_aiu_vseq_pkg::snps_chi_aiu_vseq#(<%=obj.AiuInfo[obj.Id].FUnitId%>)   m_snps_chi<%=obj.Id%>_vseq;
  <%=obj.BlockId%>_chi_aiu_vseq_pkg::snps_chi_aiu_sysco_vseq#(<%=obj.AiuInfo[obj.Id].FUnitId%>)   m_sysco_snps_chi<%=obj.Id%>_vseq;
`else   
  chi_aiu_vseq#(<%=obj.AiuInfo[obj.Id].FUnitId%>)   m_vseq;
`endif  
  addr_trans_mgr     m_addr_mgr;
  chi_aiu_unit_args  m_args;
  chi_aiu_ral_addr_map_seq  addr_map_seq;
`ifdef USE_VIP_SNPS
  svt_chi_rn_transaction_random_sequence svt_chi_rn_transaction_random_seq;
  svt_chi_link_service_activate_sequence svt_chi_link_service_activate_seq;
  cust_svt_report_catcher syncdvmop_error_catcher;
  svt_chi_link_service link_svc_rx_snp_seq_item;
  svt_chi_link_service link_svc_rx_dat_seq_item;
  svt_chi_link_service link_svc_rx_rsp_seq_item;
  //svt_chi_link_service_random_sequence random_link_svc_req_seq;
  bit vip_snps_non_coherent_txn = 0;
  bit vip_snps_coherent_txn = 0;
  int vip_snps_seq_length = 5;
  bit [31:0] rx_rsp_dly;
  bit [31:0] rx_dat_dly;
  bit [31:0] rx_snp_dly;
  bit [31:0] MAX_CREDITS = 15;
`endif //USE_VIP_SNPS
  uvm_reg_sequence csr_seq;
  uvm_event_pool ev_pool = uvm_event_pool::get_global_pool();
  uvm_event ev = ev_pool.get("ev");
  uvm_event ev_vseq_done = ev_pool.get("chi_aiu_base_vseq");
  uvm_event ev_main_seq_done = ev_pool.get("ev_main_seq_done");
  uvm_event ev_toggle_sysco_<%=obj.BlockId%> = ev_pool.get("ev_toggle_sysco_<%=obj.BlockId%>");
  uvm_event ev_csr_sysco_toggle = ev_pool.get("ev_csr_sysco_toggle");
  uvm_object objectors_list[$];
  uvm_objection objection;
  `ifndef VCS
   event kill_test;
  `else // `ifndef VCS
   uvm_event kill_test;
  `endif // `ifndef VCS
  int num_trans;
  int k_num_snoop;
  int k_writedatacancel_pct;
  int boot_sysco_st; // 0-disabled, 1-connect, 2-enabled, 3-disconnect

  int clk_count_en;           // Use for CCTRLR update scenario

  //Interface Methods
  extern function new(
    string name = "chi_aiu_bringup_test",
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

endclass: chi_aiu_bringup_test

function chi_aiu_bringup_test::new(
  string name = "chi_aiu_bringup_test",
  uvm_component parent = null);

  super.new(name, parent);
   //User knobs for ADDRESS manager configuration
   m_addr_mgr = addr_trans_mgr::get_instance();
   m_addr_mgr.gen_memory_map();
   `ifndef USE_VIP_SNPS
   m_vseq = chi_aiu_vseq#(<%=obj.AiuInfo[obj.Id].FUnitId%>)::type_id::create("m_vseq");
   m_vseq.m_chi_container = m_chi_container;
   `endif
endfunction: new

function void chi_aiu_bringup_test::build_phase(uvm_phase phase);
`ifdef USE_VIP_SNPS
  svt_chi_item m_svt_chi_item;
`endif  

<% if ((obj.useResiliency) && (obj.testBench != "fsys")) { %>
    if($test$plusargs("collect_resiliency_cov")) begin
      set_type_override_by_type(.original_type(<%=obj.BlockId%>_smi_agent_pkg::smi_coverage::get_type()), .override_type(smi_resiliency_coverage::get_type()), .replace(1));
    end
<% } %>

  super.build_phase(phase);

   m_args = chi_aiu_unit_args::type_id::create(
     $psprintf("chi_aiu_unit_args[%0d]", 0));
   set_testplusargs();
`ifndef USE_VIP_SNPS
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
`else //USE_VIP_SNPS

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
    syncdvmop_error_catcher = new();

    /** Factory override of the master transaction object */
    if(vip_snps_non_coherent_txn) begin
      set_type_override_by_type(svt_chi_rn_transaction::get_type(),rn_noncoherent_transaction::get_type());
      `uvm_info(get_name(),$psprintf("Overrode svt_chi_rn_transaction by rn_noncoherent_transaction"),UVM_DEBUG)
    end
    else if(vip_snps_coherent_txn) begin
      set_type_override_by_type(svt_chi_rn_transaction::get_type(),rn_coherent_transaction::get_type());
      `uvm_info(get_name(),$psprintf("Overrode svt_chi_rn_transaction by rn_coherent_transaction"),UVM_DEBUG)
    end
    else begin
      set_type_override_by_type(svt_chi_rn_transaction::get_type(),svt_chi_item::get_type());
      set_type_override_by_type (svt_chi_rn_snoop_transaction::get_type(), chi_snoop_item::get_type());
      //set_type_override_by_type(svt_chi_rn_snoop_response_sequence::get_type(),cust_svt_chi_rn_directed_snoop_response_sequence::get_type());
      m_svt_chi_item = svt_chi_item::type_id::create("m_svt_chi_item");
      m_svt_chi_item.m_args = m_args;
      `uvm_info(get_name(),$psprintf("Overrode svt_chi_rn_transaction by svt_chi_item"),UVM_DEBUG)
    end
  //  if ($test$plusargs("demote_syncdvmop_error"))
  //  begin
        uvm_report_cb::add(null,syncdvmop_error_catcher); 
  //  end
    
    /** Apply the null sequence to the AMBA ENV virtual sequencer to override the default sequence. */
    uvm_config_db#(uvm_object_wrapper)::set(this, "env.amba_system_env.sequencer.main_phase", "default_sequence", null);

    //uvm_config_db#(uvm_object_wrapper)::set(this, "env.amba_system_env.chi_system[0].rn[0].rn_xact_seqr.main_phase", "default_sequence", svt_chi_rn_transaction_random_sequence::type_id::get());
    //uvm_config_db#(int unsigned)::set(this, "env.amba_system_env.chi_system[0].rn[0].rn_xact_seqr.svt_chi_rn_transaction_random_sequence", "sequence_length", vip_snps_seq_length);
    uvm_config_db#(int unsigned)::set(this, "env.amba_system_env.chi_system[0].rn[0].rn_xact_seqr.svt_chi_rn_transaction_random_sequence", "sequence_length", m_args.k_num_requests.get_value());
    uvm_config_db#(bit)::set(this, "env.amba_system_env.chi_system[0].rn[0].rn_xact_seqr.svt_chi_rn_transaction_random_sequence", "enable_non_blocking", 1);
 //     uvm_config_db#(int unsigned)::set(this, "env.amba_system_env.chi_system[0].rn[0].link_svc_seqr.svt_chi_link_service_random_sequence", "min_post_send_service_request_halt_cycles", 15);

  //    uvm_config_db#(int unsigned)::set(this, "env.amba_system_env.chi_system[0].rn[0].link_svc_seqr.svt_chi_link_service_random_sequence", "max_post_send_service_request_halt_cycles", 20);

      uvm_config_db #(virtual caiu<%=obj.Id%>_chi_if)::get(this,"","chi_rn_vif",m_chi_if_caiu<%=obj.Id%>);

`endif //USE_VIP_SNPS

endfunction: build_phase

function void chi_aiu_bringup_test::connect_phase(uvm_phase phase);
  super.connect_phase(phase);
endfunction: connect_phase

function void chi_aiu_bringup_test::report_phase(uvm_phase phase);
  super.report_phase(phase);
endfunction: report_phase

function void chi_aiu_bringup_test::check_phase(uvm_phase phase);
  super.check_phase(phase);
`ifndef USE_VIP_SNPS
  if (!($test$plusargs("check_error_test_pending_txn"))) begin
    if (m_vseq.m_chi_container.m_txnid_pool.size() != 256)
      `uvm_fatal(get_name(), "Test didnt end gracefully, CHI BFM has pending transactions")
   // if (m_system_bfm_seq.end_of_test_checks() && !smi_rx_stall_en)
   //   `uvm_fatal(get_name(), "Test didnt end gracefully, System BFM has pending transactions")
  end
`endif //USE_VIP_SNPS

  if (!($test$plusargs("check_error_test_pending_txn"))) begin
    if (m_system_bfm_seq.end_of_test_checks() && !smi_rx_stall_en)
      `uvm_fatal(get_name(), "Test didnt end gracefully, System BFM has pending transactions")
  end
endfunction: check_phase

task chi_aiu_bringup_test::run_phase(uvm_phase phase);
  bit timeout;
  int use_user_addrq;

super.run_phase(phase);

`ifndef USE_VIP_SNPS
$display("%0t DEBUG: Inhouse mode starting chi_aiu_bringup_test::run_phase",$realtime);
  //m_vseq = chi_aiu_vseq#(<%=obj.AiuInfo[obj.Id].FUnitId%>)::type_id::create("m_vseq");
  //m_vseq.m_chi_container = m_chi_container;
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
  //#Stimulus.CHIAIU.sysco.notrafficattach
  //#Stimulus.CHIAIU.sysco.notrafficdetach
  if ($value$plusargs("boot_sysco_st=%d",boot_sysco_st)) begin
      // default settings in vseq/testcase is ENABLED for sysco
      `uvm_info(get_name(), $psprintf("Setting Sysco State on boot-up as, boot_sysco_st=%0d", boot_sysco_st), UVM_NONE)
      m_vseq.set_boot_sysco_state(boot_sysco_st);
  end

  uvm_config_db#(chi_aiu_scb)::set(uvm_root::get(), 
                                  "*", 
                                  "chi_aiu_scb", 
                                  m_env.m_scb);

  phase.raise_objection(this, "bringup_test");
  
  //use forces for now
  `uvm_info(get_name(), "Start Address map sequence", UVM_NONE)
  addr_map_seq.start(m_env.m_apb_agent.m_apb_sequencer);
  `uvm_info(get_name(), "Done Address map sequence", UVM_NONE)

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
       bit is_CsrSeqObjn = 1;
       if(k_csr_seq == "chi_aiu_ral_sysco_seq") is_CsrSeqObjn = 0;

       if(is_CsrSeqObjn) phase.raise_objection(this, "objection raised by CSR seq");
       `uvm_info(get_name(), "csr_seq started",UVM_NONE)
       csr_seq_pre_hook(phase); // virtual task
       for(uint64_type i=0;i<cfg_seq_iter;i++) begin:forloop_cfg_seq_iter // by default cfg_seq_iter=1
          csr_seq_iter_pre_hook(phase,i); // virtual task
          csr_seq.start(m_env.m_apb_agent.m_apb_sequencer);
          csr_seq_iter_post_hook(phase,i); // virtual task
        end:forloop_cfg_seq_iter
        csr_seq_post_hook(phase); // virtual task
       `uvm_info(get_name(), "csr_seq finished",UVM_NONE)
       if(is_CsrSeqObjn) phase.drop_objection(this, "objection dropped by CSR seq");
     end

     // ------------------------------------------------------------------
     // Implementation for CONC-8509.
     // This block is added to help verifying SMI ports quiescing for
     // trace capture...
     // First pickOne value:: Time to TURN OFF all Trace regs.
     // Second pickOne value: Update all Trace Regs with new User Values
     // ------------------------------------------------------------------
     if ($test$plusargs("caiu_cctrlr_mod")) begin
        int pickOne, kcount;

        for(int k=1; k<3; ++k) begin
           pickOne = (k==1) ? $urandom_range(12000,8000) : $urandom_range(5000,3000);

           kcount=0;
           while(kcount < pickOne) begin
             @(negedge u_csr_probe_vif.clk);
             clk_count_en = (++kcount==pickOne) ?  k : 0;
           end
        end
     end


<% } %>


     //-------------------------------------------------------------------------------------
     // Special case:: Added for Trace Capture and Trigger. -- CONC-8509
     // - This thread will only be invoked, if and only if the user's intent is
     //   to modify the Trace Debug registers, in the middle of simulation
     //   registers such as:: CCTRLR,TCCTRLR,TBALR,GBAHR,TOPCR[0,1],TUBR,TUBMR.
     // - Use the UVM Factory to indicate when those changes had taken place.
     //   That will happen in the sequence..
     // Notes::
     //    There are three phases for this implementation::
     //    Phase   I._ Turn off all enablement bits and reset all the TCAP and
     //                TTrig registers -- (chi_aiu_cctrlr_phase=1)
     //    Phase  II._ Configure all the registers again with the user preferred
     //                values    -- (chi_aiu_cctrlr_phase=2)
     //    Phase III._ Start simulation with the new configuration. (chi_aiu_cctrlr_phase=3)
     //-------------------------------------------------------------------------------------
     begin
       if($test$plusargs("caiu_cctrlr_mod")) begin
          wait(clk_count_en==1);              // Turn off all the SMI Ports
          `uvm_info("TRACE Dbg Seq", "Phase I::About to reset all Trace Debug Regs.",UVM_NONE)
          uvm_config_db#(int)::set(null,"*","caiu_cctrlr_phase",1);
          csr_seq.start(m_env.m_apb_agent.m_apb_sequencer);

          wait(clk_count_en==2);              // Ready to load the new value.
          `uvm_info("TRACE Dbg Seq", "Phase II::About to restore all Trace Debug Regs with their new values.",UVM_NONE)
          uvm_config_db#(int)::set(null,"","caiu_cctrlr_phase",2);
          csr_seq.start(m_env.m_apb_agent.m_apb_sequencer);

          // --------------------------------------------------------------
          // We need to let the ioau_tb_top.sv initial block know that the
          // "chi_aiu_csr_trace_debug_seq" has completed. This is the reason
          // that we need to set it to "3"..... just for it to be aware.
          uvm_config_db#(int)::set(null,"*","caiu_cctrlr_phase",3);
          `uvm_info("TRACE Dbg Seq", "Phase III::Nullify chi_aiu_tb_top to release all force signals.",UVM_NONE)
       end
     end


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
        `uvm_info("run_main","Waiting for CSR seq to set the control register",UVM_NONE)
        ev.wait_ptrigger();
        if($test$plusargs("user_addr_for_csr")) begin
          m_vseq.m_chi_container.user_addrq[addrMgrConst::COH] = addrMgrConst::user_addrq[addrMgrConst::COH];
          m_vseq.m_chi_container.user_addrq[addrMgrConst::NONCOH] = addrMgrConst::user_addrq[addrMgrConst::NONCOH];
        end
        `uvm_info("run_main","Waiting Completed for CSR seq to set the control register",UVM_NONE)
      end
      if($value$plusargs("use_user_addrq=%d", use_user_addrq) && (!$test$plusargs("user_addr_for_csr"))) begin
          m_addr_mgr.gen_user_noncoh_addr(<%=obj.AiuInfo[obj.Id].FUnitId%>, use_user_addrq, m_vseq.m_chi_container.user_addrq[addrMgrConst::NONCOH]);
          m_addr_mgr.gen_user_coh_addr(<%=obj.AiuInfo[obj.Id].FUnitId%>, use_user_addrq, m_vseq.m_chi_container.user_addrq[addrMgrConst::COH]);
      end // if ($value$plusargs("use_user_addrq=%d", use_user_addrq))
        main_seq_pre_hook(phase); // virtual task
        for(uint64_type i=0;i<main_seq_iter;i++) begin:forloop_main_seq_iter // by default main_seq_iter=1
          main_seq_iter_pre_hook(phase,i); // virtual task
            if (!smi_rx_stall_en) begin
                //if($test$plusargs("csr_boot_sysco_st") && $test$plusargs("k_toggle_sysco")) 
                // begin
                //   ev_csr_sysco_toggle.wait_trigger();
                // end 
              m_vseq.seq_iter = i;
              `uvm_info(get_name(), "Start CHI AIU VSEQ", UVM_NONE)
              m_vseq.start(null);
	      if(main_seq_iter > 1) ev_vseq_done.wait_ptrigger();
              `uvm_info(get_name(), "Done CHI AIU VSEQ", UVM_NONE)
            end
          main_seq_iter_post_hook(phase,i); // virtual task
        end:forloop_main_seq_iter
        main_seq_post_hook(phase); // virtual task

    end
    //begin
    //  #1.5ms;
    //  //m_vseq.print_pending_txns();
    //  if (m_vseq.m_chi_container.m_txnid_pool.size() != 256)
    //    `uvm_fatal(get_name(), "Test Timeout")
    //end

    begin
      if (k_num_snoop >= 0)
          m_system_bfm_seq.k_num_snp.set_value(k_num_snoop); 
      if($test$plusargs("SNPrsp_time_out_test") || $test$plusargs("SNPrsp_with_data_error") || $test$plusargs("wrong_dtrrsp_target_id") || $test$plusargs("snp_srsp_delay")) begin //#Stimulus.CHIAIU.timeout.v3.snprsptimeout
          m_system_bfm_seq.wt_snp_cmd_req_addr.set_value(100);
      	  if ($test$plusargs("snp_srsp_delay")) begin 
	    m_system_bfm_seq.wt_snp_random_addr.set_value(100);
            m_system_bfm_seq.wt_snp_prev_addr.set_value(0);
      	  end else begin 
	    m_system_bfm_seq.wt_snp_random_addr.set_value(0);
            m_system_bfm_seq.wt_snp_prev_addr.set_value(100);
	  end
          m_system_bfm_seq.wt_snp_for_stash_random_addr.set_value(0);
      end
      if ($test$plusargs("stash_txn_test")) begin
          m_system_bfm_seq.wt_snp_inv_stsh.set_value(80);
          m_system_bfm_seq.wt_snp_unq_stsh.set_value(80);
          m_system_bfm_seq.wt_snp_stsh_sh.set_value(0);
          m_system_bfm_seq.wt_snp_stsh_unq.set_value(0);
          m_system_bfm_seq.wt_snp_inv.set_value(0); 
          m_system_bfm_seq.wt_snp_cln_dtr.set_value(0); 
          m_system_bfm_seq.wt_snp_vld_dtr.set_value(0); 
          m_system_bfm_seq.wt_snp_inv_dtr.set_value(0); 
          m_system_bfm_seq.wt_snp_cln_dtw.set_value(0); 
          m_system_bfm_seq.wt_snp_inv_dtw.set_value(0); 
          m_system_bfm_seq.wt_snp_nitc.set_value(0); 
          m_system_bfm_seq.wt_snp_nitcci.set_value(0); 
          m_system_bfm_seq.wt_snp_nitcmi.set_value(0); 
          m_system_bfm_seq.wt_snp_nosdint.set_value(0); 
      end else if ($test$plusargs("dataless_stash_txn_test")) begin
          m_system_bfm_seq.wt_snp_inv_stsh.set_value(0);
          m_system_bfm_seq.wt_snp_unq_stsh.set_value(0);
          m_system_bfm_seq.wt_snp_stsh_sh.set_value(90);
          m_system_bfm_seq.wt_snp_stsh_unq.set_value(90);
          m_system_bfm_seq.wt_snp_inv.set_value(0); 
          m_system_bfm_seq.wt_snp_cln_dtr.set_value(0); 
          m_system_bfm_seq.wt_snp_vld_dtr.set_value(0); 
          m_system_bfm_seq.wt_snp_inv_dtr.set_value(0); 
          m_system_bfm_seq.wt_snp_cln_dtw.set_value(0); 
          m_system_bfm_seq.wt_snp_inv_dtw.set_value(0); 
          m_system_bfm_seq.wt_snp_nitc.set_value(0); 
          m_system_bfm_seq.wt_snp_nitcci.set_value(0); 
          m_system_bfm_seq.wt_snp_nitcmi.set_value(0); 
          m_system_bfm_seq.wt_snp_nosdint.set_value(0); 
      end else if ($test$plusargs("no_stash_snoop_test")) begin
          m_system_bfm_seq.wt_snp_inv_stsh.set_value(0);
          m_system_bfm_seq.wt_snp_unq_stsh.set_value(0);
          m_system_bfm_seq.wt_snp_stsh_sh.set_value(0);
          m_system_bfm_seq.wt_snp_stsh_unq.set_value(0);
      end 
      if ($test$plusargs("k_en_dvm_snoops")) begin
          m_system_bfm_seq.wt_snp_dvm_msg.set_value(100);
          m_system_bfm_seq.wt_snp_inv_stsh.set_value(0);
          m_system_bfm_seq.wt_snp_unq_stsh.set_value(0);
          m_system_bfm_seq.wt_snp_stsh_sh.set_value(0);
          m_system_bfm_seq.wt_snp_stsh_unq.set_value(0);
          m_system_bfm_seq.wt_snp_inv.set_value(0); 
          m_system_bfm_seq.wt_snp_cln_dtr.set_value(0); 
          m_system_bfm_seq.wt_snp_vld_dtr.set_value(0); 
          m_system_bfm_seq.wt_snp_inv_dtr.set_value(0); 
          m_system_bfm_seq.wt_snp_cln_dtw.set_value(0); 
          m_system_bfm_seq.wt_snp_inv_dtw.set_value(0); 
          m_system_bfm_seq.wt_snp_nitc.set_value(0); 
          m_system_bfm_seq.wt_snp_nitcci.set_value(0); 
          m_system_bfm_seq.wt_snp_nitcmi.set_value(0); 
          m_system_bfm_seq.wt_snp_nosdint.set_value(0); 
      end else if ($test$plusargs("no_dvm_snoop_test")) begin
          m_system_bfm_seq.wt_snp_dvm_msg.set_value(0);
      end else begin
          m_system_bfm_seq.wt_snp_dvm_msg.set_value(20);
      end

      if ($test$plusargs("dis_delay_system_bfm")) begin
      	  m_system_bfm_seq.dis_delay_dtr_req              = 1;
      	  m_system_bfm_seq.dis_delay_str_req              = 1;
      	  m_system_bfm_seq.dis_delay_tx_resp              = 1;
      	  m_system_bfm_seq.dis_delay_cmd_resp             = 1;
      	  m_system_bfm_seq.dis_delay_dtw_resp             = 1;
      	  m_system_bfm_seq.dis_delay_upd_resp             = 1;
      	  m_system_bfm_seq.high_system_bfm_slv_rsp_delays = 0;
      end 

     <% if(obj.testBench == 'chi_aiu') { %>
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
      m_system_bfm_seq.start(null);
    end

    //#Stimulus.CHIAIU.sysco.toggle
    if($test$plusargs("k_toggle_sysco")) begin
      int unsigned toggle_count = $value$plusargs("toggle_count=%0d", toggle_count) ? toggle_count : (1<<12);
      chi_base_seq_item m_obj;
      `uvm_info(get_name(), $sformatf("toggle_count=%0d", toggle_count), UVM_DEBUG)
      if(csr_seq != null && k_csr_seq == "chi_aiu_ral_sysco_seq") begin
        m_obj = null;
      end
      else begin
        m_obj = new;
      end

      fork
        begin : th_main
          int random_time, time1, time2, time3, time4; bit en;
          realtime rtime1, rtime2;
          time1 = 800; time2 = 1000; time3 = 2500; time4 = 6000;
          rtime1 = (10**3)*1ns*(100); rtime2 = (10**3)*1ns*(30);
          random_time = $urandom_range(1000,1500);
          #(random_time*1ns);
          repeat(toggle_count) begin
            random_time = $realtime < rtime1 ? (($realtime < rtime2) ? $urandom_range(time1,time2) : $urandom_range(time2,time3)) : $urandom_range(time3,time4);
            `uvm_info(get_name(), "th1_outer::dbg_0", UVM_DEBUG)
            ev_toggle_sysco_<%=obj.BlockId%>.trigger(m_obj);
            `uvm_info(get_name(), "th1_outer::dbg_1", UVM_DEBUG)
            #1000ns; //make sure that txn got collected at SCB
            wait(m_env.m_scb.m_sysco_st inside {ENABLED, DISABLED});
            `uvm_info(get_name(), "th1_outer::dbg_2", UVM_DEBUG)
            #(random_time*1ns);
          end // repeat
        end // th_main
      join_none
    end
  join_any

  if($test$plusargs("main_seq_iter")) begin
    ev_main_seq_done.wait_ptrigger();
  end

  if ($test$plusargs("check4_attach") && (!$test$plusargs("resend_correct_target_id")) && (!$test$plusargs("SYSrsp_time_out_test"))) begin
  #250us;
  end
  else begin
    if (((!$test$plusargs("resend_correct_target_id")) && ($test$plusargs("wrong_snpreq_target_id") || $test$plusargs("wrong_sysrsp_target_id"))) || $test$plusargs("drop_smi_uce_pkt")) begin
    #1ms;
    end else begin
    #10us;
    m_env.m_scb.objection.wait_for_total_count(m_env.m_scb, 0);
    `uvm_info(get_name(), "Scoreboard uvm objection dropped", UVM_NONE)
    end
  end
  `uvm_info(get_name(), "Dropping objection for bringup_test", UVM_NONE)
  phase.phase_done.set_drain_time(this, 500ns);
  main_seq_hook_end_run_phase(phase); // virtual task
  phase.drop_objection(this, "bringup_test");
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

  phase.raise_objection(this, "bringup_test");
  //snps_vseq = snps_chi_aiu_vseq::type_id::create("snps_vseq");
  //snps_vseq.rn_xact_seqr = env.amba_system_env.chi_system[0].rn[0].rn_xact_seqr;
  //snps_vseq.rn_snp_xact_seqr = env.amba_system_env.chi_system[0].rn[0].rn_snp_xact_seqr; 
  //snps_vseq.vip_snps_seq_length = m_args.k_num_requests.get_value();
  //snps_vseq.set_unit_args(m_args);
  m_snps_chi<%=obj.Id%>_vseq = <%=obj.BlockId%>_chi_aiu_vseq_pkg::snps_chi_aiu_vseq#(<%=obj.AiuInfo[obj.Id].FUnitId%>)::type_id::create("m_chi<%=obj.Id%>_seq");
  m_sysco_snps_chi<%=obj.Id%>_vseq = <%=obj.BlockId%>_chi_aiu_vseq_pkg::snps_chi_aiu_sysco_vseq#(<%=obj.AiuInfo[obj.Id].FUnitId%>)::type_id::create("m_sysco_chi<%=obj.Id%>_seq");
  m_snps_chi<%=obj.Id%>_vseq.rn_xact_seqr = env.amba_system_env.chi_system[0].rn[<%=obj.Id%>].rn_xact_seqr;
  m_snps_chi<%=obj.Id%>_vseq.prot_svc_seqr = env.amba_system_env.chi_system[0].rn[<%=obj.Id%>].prot_svc_seqr;
  m_snps_chi<%=obj.Id%>_vseq.shared_status = env.amba_system_env.chi_system[0].rn[0].shared_status;
  m_sysco_snps_chi<%=obj.Id%>_vseq.prot_svc_seqr = env.amba_system_env.chi_system[0].rn[<%=obj.Id%>].prot_svc_seqr;
  m_sysco_snps_chi<%=obj.Id%>_vseq.shared_status = env.amba_system_env.chi_system[0].rn[0].shared_status;
  //m_snps_chi<%=obj.Id%>_vseq.rn_snp_xact_seqr = env.amba_system_env.chi_system[0].rn[<%=obj.Id%>].rn_snp_xact_seqr; 
  m_snps_chi<%=obj.Id%>_vseq.vip_snps_seq_length = m_args.k_num_requests.get_value();
  m_snps_chi<%=obj.Id%>_vseq.set_unit_args(m_args);
//$display("%0t DEBUG: SVT mode starting chi_aiu_bringup_test::run_phase",$realtime);
  addr_map_seq = chi_aiu_ral_addr_map_seq::type_id::create("addr_map_seq");
  addr_map_seq.model     = m_env.m_regs;
  `uvm_info(get_name(), "Start Address map sequence", UVM_NONE)
  addr_map_seq.start(m_env.m_apb_agent.m_apb_sequencer);
  `uvm_info(get_name(), "Done Address map sequence", UVM_NONE)

  `uvm_info(get_name(), "Start svt_chi_link_service_sequence", UVM_NONE)
  svt_chi_link_service_activate_seq = svt_chi_link_service_activate_sequence::type_id::create("svt_chi_link_service_activate_seq");
  `uvm_info(get_name(), "Start svt_chi_link_service_sequence", UVM_NONE)
 svt_chi_link_service_activate_seq.start(env.amba_system_env.chi_system[0].rn[0].link_svc_seqr) ;
  `uvm_info(get_name(), "Done svt_chi_link_service_sequence", UVM_NONE)

 fork

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
    /* //  phase.raise_objection(this, "objection raised by CSR seq");
       `uvm_info(get_name(), "csr_seq started",UVM_NONE)
       csr_seq.start(m_env.m_apb_agent.m_apb_sequencer);
       `uvm_info(get_name(), "csr_seq finished",UVM_NONE)
     //  phase.drop_objection(this, "objection dropped by CSR seq");
     end  */

       `uvm_info(get_name(), "csr_seq started",UVM_NONE)
       csr_seq_pre_hook(phase); // virtual task
       for(uint64_type i=0;i<cfg_seq_iter;i++) begin:forloop_cfg_seq_iter // by default cfg_seq_iter=1
          csr_seq_iter_pre_hook(phase,i); // virtual task
          csr_seq.start(m_env.m_apb_agent.m_apb_sequencer);
          csr_seq_iter_post_hook(phase,i); // virtual task
        end:forloop_cfg_seq_iter
        csr_seq_post_hook(phase); // virtual task
       `uvm_info(get_name(), "csr_seq finished",UVM_NONE)
     end

 <%if((obj.useResiliency) && (obj.testBench == 'chi_aiu')){%> 
              fork
                begin
                    `ifndef VCS
                     if(!uvm_config_db#(event)::get(this, "", "kill_test", kill_test)) begin
                         `uvm_error( "kill test run_phase", "kill test event not found" )
                     end
                    `else
                     if(!uvm_config_db#(uvm_event)::get(this, "", "kill_test", kill_test)) begin
                         `uvm_error( "kill test run_phase", "kill test event not found" )
                     end
                    `endif
                end 
                begin
                       if ($test$plusargs("inj_cntl") && $test$plusargs("expect_mission_fault")) begin
                        // Fetching the objection from current phase
                        objection = phase.get_objection();
                        // Collecting all the objectors which currently have objections raised
                        objection.get_objectors(objectors_list);
                        // Dropping the objections forcefully
                       if (!(($test$plusargs("dtw_dbg_rsp_err_inj")) || ($test$plusargs("dtr_req_err_inj")) || ($test$plusargs("snp_req_err_inj")) || ($test$plusargs("dtw_rsp_err_inj")) || ($test$plusargs("ccmd_rsp_err_inj")) || ($test$plusargs("str_req_err_inj")) || ($test$plusargs("dtr_rsp_err_inj")) || ($test$plusargs("ccmd_rsp_err_inj")) || ($test$plusargs("nccmd_rsp_err_inj")))) begin
                          foreach(objectors_list[i]) begin
                              uvm_report_info("run_main", $sformatf("objection count %d", objection.get_objection_count(objectors_list[i])),UVM_MEDIUM);
                              while(objection.get_objection_count(objectors_list[i]) != 0) begin
                                  phase.drop_objection(objectors_list[i], "dropping objections to kill the test");
                              end
                          end
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
                                        phase.raise_objection(this, "bringup_test");
                                        `uvm_info(get_name(),"raised_objection::uncorr", UVM_DEBUG);
                                        @u_csr_probe_vif.fault_mission_fault;
                                        phase.drop_objection(this, "bringup_test");
                                        `uvm_info(get_name(),"dropped_objection::uncorr", UVM_DEBUG);
                                    end
                                    if($test$plusargs("expect_mission_fault_cov"))begin
                                        //repeat(10000) @(negedge u_csr_probe_vif[0].clk);
                                        #1ms; // keep testcase timeout higher than this to avoid hearbeat failure
                                    end
                                    #(100*1ns);
                                    `uvm_info($sformatf("%m"), $sformatf("<%=obj.BlockId%> saw mission fault. Kill test"), UVM_NONE)
                                    `ifndef VCS
                                        -> kill_test;
                                    `else
                                        kill_test.trigger();
                                    `endif
		                  //endif
                                  //  -> kill_test;   // otherwise the test will hang and timeout
                                    `uvm_info($sformatf("%m"), $sformatf("<%=obj.BlockId%> saw mission fault. Jump to report phase"), UVM_NONE)
                                    phase.jump(uvm_report_phase::get());
                                end
                            end
                        end
                    end
                end
           join_none
 <%}%>
     // ------------------------------------------------------------------
     // Implementation for CONC-8509.
     // This block is added to help verifying SMI ports quiescing for
     // trace capture...
     // First pickOne value:: Time to TURN OFF all Trace regs.
     // Second pickOne value: Update all Trace Regs with new User Values
     // ------------------------------------------------------------------
     if ($test$plusargs("caiu_cctrlr_mod")) begin
        int pickOne, kcount;

        for(int k=1; k<3; ++k) begin
           pickOne = (k==1) ? $urandom_range(12000,8000) : $urandom_range(5000,3000);

           kcount=0;
           while(kcount < pickOne) begin
             @(negedge u_csr_probe_vif.clk);
             clk_count_en = (++kcount==pickOne) ?  k : 0;
           end
        end
     end
<% } %>


     //-------------------------------------------------------------------------------------
     // Special case:: Added for Trace Capture and Trigger. -- CONC-8509
     // - This thread will only be invoked, if and only if the user's intent is
     //   to modify the Trace Debug registers, in the middle of simulation
     //   registers such as:: CCTRLR,TCCTRLR,TBALR,GBAHR,TOPCR[0,1],TUBR,TUBMR.
     // - Use the UVM Factory to indicate when those changes had taken place.
     //   That will happen in the sequence..
     // Notes::
     //    There are three phases for this implementation::
     //    Phase   I._ Turn off all enablement bits and reset all the TCAP and
     //                TTrig registers -- (chi_aiu_cctrlr_phase=1)
     //    Phase  II._ Configure all the registers again with the user preferred
     //                values    -- (chi_aiu_cctrlr_phase=2)
     //    Phase III._ Start simulation with the new configuration. (chi_aiu_cctrlr_phase=3)
     //-------------------------------------------------------------------------------------
     begin
       if($test$plusargs("caiu_cctrlr_mod")) begin
          wait(clk_count_en==1);              // Turn off all the SMI Ports
          `uvm_info("TRACE Dbg Seq", "Phase I::About to reset all Trace Debug Regs.",UVM_NONE)
          uvm_config_db#(int)::set(null,"*","caiu_cctrlr_phase",1);
          csr_seq.start(m_env.m_apb_agent.m_apb_sequencer);

          wait(clk_count_en==2);              // Ready to load the new value.
          `uvm_info("TRACE Dbg Seq", "Phase II::About to restore all Trace Debug Regs with their new values.",UVM_NONE)
          uvm_config_db#(int)::set(null,"","caiu_cctrlr_phase",2);
          csr_seq.start(m_env.m_apb_agent.m_apb_sequencer);

          // --------------------------------------------------------------
          // We need to let the ioau_tb_top.sv initial block know that the
          // "chi_aiu_csr_trace_debug_seq" has completed. This is the reason
          // that we need to set it to "3"..... just for it to be aware.
          uvm_config_db#(int)::set(null,"*","caiu_cctrlr_phase",3);
          `uvm_info("TRACE Dbg Seq", "Phase III::Nullify chi_aiu_tb_top to release all force signals.",UVM_NONE)
       end
     end

 begin
    if(vip_snps_coherent_txn || vip_snps_non_coherent_txn) begin
     `uvm_info(get_name(), "Start svt_chi_rn_transaction_random_sequence", UVM_NONE)
      svt_chi_rn_transaction_random_seq = svt_chi_rn_transaction_random_sequence::type_id::create("svt_chi_rn_transaction_random_seq");
      svt_chi_rn_transaction_random_seq.start(env.amba_system_env.chi_system[0].rn[0].rn_xact_seqr) ;
      `uvm_info(get_name(), "Done svt_chi_rn_transaction_random_sequence", UVM_NONE)
    end
    else begin
  <% if(obj.testBench == 'chi_aiu') { %>
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
       // if($test$plusargs("user_addr_for_csr")) begin
       //   m_vseq.m_chi_container.user_addrq[addrMgrConst::COH] = addrMgrConst::user_addrq[addrMgrConst::COH];
       //   m_vseq.m_chi_container.user_addrq[addrMgrConst::NONCOH] = addrMgrConst::user_addrq[addrMgrConst::NONCOH];
       // end
        `uvm_info("run_main","Waiting Completed for CSR seq to set the control register",UVM_NONE)
      end

      `uvm_info(get_name(), "Start snps_vseq", UVM_NONE)
       //snps_vseq.start(null);
        main_seq_pre_hook(phase); // virtual task
        for(uint64_type i=0;i<main_seq_iter;i++) begin:forloop_main_seq_iter // by default main_seq_iter=1
          main_seq_iter_pre_hook(phase,i); // virtual task
            if (!smi_rx_stall_en) begin
                //if($test$plusargs("csr_boot_sysco_st") && $test$plusargs("k_toggle_sysco")) 
                // begin
                //   ev_csr_sysco_toggle.wait_trigger();
                // end 
                m_snps_chi<%=obj.Id%>_vseq.start(null);
            end
          main_seq_iter_post_hook(phase,i); // virtual task
        end:forloop_main_seq_iter
        main_seq_post_hook(phase); // virtual task
      `uvm_info(get_name(), "Done snps_vseq", UVM_NONE)
    end
 end


      begin
       if($test$plusargs("lnk_credit_strv_mode")) begin
         link_svc_rx_rsp_seq_item = svt_chi_link_service::type_id::create($sformatf("suspend_rsp_lcrd"), env.amba_system_env);
         link_svc_rx_rsp_seq_item.cfg = cfg.chi_sys_cfg[0].rn_cfg[0];
         link_svc_rx_rsp_seq_item.LINK_ACTIVATE_DEACTIVATE_SERVICE_wt = 0;
         link_svc_rx_rsp_seq_item.LCRD_SUSPEND_RESUME_SERVICE_wt = 100;
         if (link_svc_rx_rsp_seq_item.randomize() with { service_type == svt_chi_link_service::SUSPEND_RSP_LCRD; }) begin
             `uvm_info(get_name(), "Created SUSPEND_RSP_LCRD Link Svc Request", UVM_NONE)
              env.amba_system_env.chi_system[0].rn[0].link_svc_seqr.execute_item(link_svc_rx_rsp_seq_item);
           end

         forever begin
           wait(env.amba_system_env.chi_system[0].rn[0].shared_status.link_status.current_rxla_state == svt_chi_link_status::RXLA_RUN_STATE);
          
          /* do
           begin
               @ (posedge m_chi_if_caiu<%=obj.Id%>.clk);
          `uvm_info(get_name(),$psprintf("LINK_STARV_1 : link_rsp_counter %p",env.amba_system_env.chi_system[0].rn[0].shared_status.link_status.rx_rsp_vc_advertised_curr_l_credit_count),UVM_NONE)
           end
           while(int'(env.amba_system_env.chi_system[0].rn[0].shared_status.link_status.rx_rsp_vc_advertised_curr_l_credit_count) < MAX_CREDITS);
          `uvm_info(get_name(),$psprintf("LINK_STARV : link_rsp_counter %p",env.amba_system_env.chi_system[0].rn[0].shared_status.link_status.rx_rsp_vc_advertised_curr_l_credit_count),UVM_NONE)*/
           if (link_svc_rx_rsp_seq_item.randomize() with { service_type == svt_chi_link_service::SUSPEND_RSP_LCRD; }) begin
             `uvm_info(get_name(), "Created SUSPEND_RSP_LCRD Link Svc Request", UVM_NONE)
              env.amba_system_env.chi_system[0].rn[0].link_svc_seqr.execute_item(link_svc_rx_rsp_seq_item);
           end
           `uvm_info(get_name(), "wait_for_rxla_state_before", UVM_NONE)
            wait(env.amba_system_env.chi_system[0].rn[0].shared_status.link_status.current_rxla_state == svt_chi_link_status::RXLA_RUN_STATE);
           `uvm_info(get_name(), "wait_for_rxla_state_after", UVM_NONE)

         /*   rx_rsp_dly = $urandom_range(5000,10000);
            repeat (rx_rsp_dly) @ (posedge m_chi_if_caiu<%=obj.Id%>.clk);
            `uvm_info(get_name(),$psprintf("rx rsp credit count is %0h", env.amba_system_env.chi_system[0].rn[0].shared_status.link_status.rx_rsp_vc_advertised_curr_l_credit_count),UVM_NONE)*/

          do
           begin
               @ (posedge m_chi_if_caiu<%=obj.Id%>.clk);
           end
           while(int'(env.amba_system_env.chi_system[0].rn[0].shared_status.link_status.rx_rsp_vc_advertised_curr_l_credit_count) > 'h0);
           if (link_svc_rx_rsp_seq_item.randomize() with { service_type == svt_chi_link_service::RESUME_RSP_LCRD; }) begin
                `uvm_info(get_name(), "Created RESUME_RSP_LCRD Link Svc Request", UVM_NONE)
                env.amba_system_env.chi_system[0].rn[0].link_svc_seqr.execute_item(link_svc_rx_rsp_seq_item);
           end


           do
           begin
               @ (posedge m_chi_if_caiu<%=obj.Id%>.clk);
           end
           while(int'(env.amba_system_env.chi_system[0].rn[0].shared_status.link_status.rx_rsp_vc_advertised_curr_l_credit_count) < MAX_CREDITS);
          `uvm_info(get_name(),$psprintf("LINK_STARV : link_again_rsp_counter %0p",env.amba_system_env.chi_system[0].rn[0].shared_status.link_status.rx_rsp_vc_advertised_curr_l_credit_count),UVM_NONE)
           if (link_svc_rx_rsp_seq_item.randomize() with { service_type == svt_chi_link_service::SUSPEND_RSP_LCRD; }) begin
             `uvm_info(get_name(), "Created AGAIN_SUSPEND_RSP_LCRD Link Svc Request", UVM_NONE)
              env.amba_system_env.chi_system[0].rn[0].link_svc_seqr.execute_item(link_svc_rx_rsp_seq_item);
           end

            rx_rsp_dly = $urandom_range(5000,10000);
            repeat (rx_rsp_dly) @ (posedge m_chi_if_caiu<%=obj.Id%>.clk);
            `uvm_info(get_name(),$psprintf("rx rsp credit count is %p", env.amba_system_env.chi_system[0].rn[0].shared_status.link_status.rx_rsp_vc_advertised_curr_l_credit_count),UVM_NONE)
      end //forever
    end
end//if

    begin
      if($test$plusargs("lnk_credit_strv_mode")) begin
           link_svc_rx_dat_seq_item = svt_chi_link_service::type_id::create($sformatf("suspend_dat_lcrd"), env.amba_system_env);
           link_svc_rx_dat_seq_item.cfg = cfg.chi_sys_cfg[0].rn_cfg[0];
           link_svc_rx_dat_seq_item.LINK_ACTIVATE_DEACTIVATE_SERVICE_wt = 0;
           link_svc_rx_dat_seq_item.LCRD_SUSPEND_RESUME_SERVICE_wt = 100;
           do
           begin
              @ (posedge m_chi_if_caiu<%=obj.Id%>.clk);
           end
           while(int'(env.amba_system_env.chi_system[0].rn[0].shared_status.link_status.rx_dat_vc_advertised_curr_l_credit_count) < MAX_CREDITS);

          `uvm_info(get_name(),$psprintf("LINK_STARV : link_dat_counter %p",env.amba_system_env.chi_system[0].rn[0].shared_status.link_status.rx_dat_vc_advertised_curr_l_credit_count),UVM_NONE)
              if (link_svc_rx_dat_seq_item.randomize() with { service_type == svt_chi_link_service::SUSPEND_DAT_LCRD; }) begin
                    `uvm_info(get_name(), "Created SUSPEND_DAT_LCRD Link Svc Request", UVM_NONE)
                     env.amba_system_env.chi_system[0].rn[0].link_svc_seqr.execute_item(link_svc_rx_dat_seq_item);
              end

           forever begin
              wait(env.amba_system_env.chi_system[0].rn[0].shared_status.link_status.current_rxla_state == svt_chi_link_status::RXLA_RUN_STATE);
              /*do
              begin
                   @ (posedge m_chi_if_caiu<%=obj.Id%>.clk);
              `uvm_info(get_name(),$psprintf("LINK_STARV : link_while_dat_counter %p",env.amba_system_env.chi_system[0].rn[0].shared_status.link_status.rx_dat_vc_advertised_curr_l_credit_count),UVM_NONE)
              end
              while(int'(env.amba_system_env.chi_system[0].rn[0].shared_status.link_status.rx_dat_vc_advertised_curr_l_credit_count) < MAX_CREDITS);

              `uvm_info(get_name(),$psprintf("LINK_STARV : link_dat_counter %p",env.amba_system_env.chi_system[0].rn[0].shared_status.link_status.rx_dat_vc_advertised_curr_l_credit_count),UVM_NONE)*/
              if (link_svc_rx_dat_seq_item.randomize() with { service_type == svt_chi_link_service::SUSPEND_DAT_LCRD; }) begin
                    `uvm_info(get_name(), "Created SUSPEND_DAT_LCRD Link Svc Request", UVM_NONE)
                     env.amba_system_env.chi_system[0].rn[0].link_svc_seqr.execute_item(link_svc_rx_dat_seq_item);
              end
              `uvm_info(get_name(), "wait_for_rxla_state_before", UVM_NONE)
               wait(env.amba_system_env.chi_system[0].rn[0].shared_status.link_status.current_rxla_state == svt_chi_link_status::RXLA_RUN_STATE);
              `uvm_info(get_name(), "wait_for_rxla_state_after", UVM_NONE)

             //  rx_dat_dly = $urandom_range(5000,10000);
             //  repeat (rx_dat_dly) @ (posedge m_chi_if_caiu<%=obj.Id%>.clk);

               do
                begin
                   @ (posedge m_chi_if_caiu<%=obj.Id%>.clk);
               end
               while(int'(env.amba_system_env.chi_system[0].rn[0].shared_status.link_status.rx_dat_vc_advertised_curr_l_credit_count) > 'h0);

               if (link_svc_rx_dat_seq_item.randomize() with { service_type == svt_chi_link_service::RESUME_DAT_LCRD; }) begin
                    `uvm_info(get_name(), "Created RESUME_DAT_LCRD Link Svc Request", UVM_NONE)
                    env.amba_system_env.chi_system[0].rn[0].link_svc_seqr.execute_item(link_svc_rx_dat_seq_item);
               end

               do
               begin
                    @ (posedge m_chi_if_caiu<%=obj.Id%>.clk);
               `uvm_info(get_name(),$psprintf("LINK_STARV : link_again_while_dat_counter %p",env.amba_system_env.chi_system[0].rn[0].shared_status.link_status.rx_dat_vc_advertised_curr_l_credit_count),UVM_NONE)
               end
                while(int'(env.amba_system_env.chi_system[0].rn[0].shared_status.link_status.rx_dat_vc_advertised_curr_l_credit_count) < MAX_CREDITS);

          `uvm_info(get_name(),$psprintf("LINK_STARV : link_again_dat_counter %p",env.amba_system_env.chi_system[0].rn[0].shared_status.link_status.rx_dat_vc_advertised_curr_l_credit_count),UVM_NONE)
                if (link_svc_rx_dat_seq_item.randomize() with { service_type == svt_chi_link_service::SUSPEND_DAT_LCRD; }) begin
                  `uvm_info(get_name(), "Created AGAIN_SUSPEND_DAT_LCRD Link Svc Request", UVM_NONE)
                   env.amba_system_env.chi_system[0].rn[0].link_svc_seqr.execute_item(link_svc_rx_dat_seq_item);
                end
               rx_dat_dly = $urandom_range(5000,10000);
               repeat (rx_dat_dly) @ (posedge m_chi_if_caiu<%=obj.Id%>.clk);

           end //forever
  end // if
 end

       begin
        if($test$plusargs("lnk_credit_strv_mode")) begin
            link_svc_rx_snp_seq_item = svt_chi_link_service::type_id::create($sformatf("suspend_snp_lcrd"), env.amba_system_env);
            link_svc_rx_snp_seq_item.cfg = cfg.chi_sys_cfg[0].rn_cfg[0];
            link_svc_rx_snp_seq_item.LINK_ACTIVATE_DEACTIVATE_SERVICE_wt = 0;
            link_svc_rx_snp_seq_item.LCRD_SUSPEND_RESUME_SERVICE_wt = 100;
            forever begin
                wait(env.amba_system_env.chi_system[0].rn[0].shared_status.link_status.current_rxla_state == svt_chi_link_status::RXLA_RUN_STATE);

                do
                begin
                     @ (posedge m_chi_if_caiu<%=obj.Id%>.clk);
                end
                while(int'(env.amba_system_env.chi_system[0].rn[0].shared_status.link_status.snp_vc_advertised_curr_l_credit_count) < MAX_CREDITS);

                if (link_svc_rx_snp_seq_item.randomize() with { service_type == svt_chi_link_service::SUSPEND_SNP_LCRD; }) begin
                  `uvm_info(get_name(), "Created SUSPEND_SNP_LCRD Link Svc Request", UVM_NONE)
                   env.amba_system_env.chi_system[0].rn[0].link_svc_seqr.execute_item(link_svc_rx_snp_seq_item);
                end
                `uvm_info(get_name(), "wait_for_rxla_state_before", UVM_NONE)
                 wait(env.amba_system_env.chi_system[0].rn[0].shared_status.link_status.current_rxla_state == svt_chi_link_status::RXLA_RUN_STATE);
                `uvm_info(get_name(), "wait_for_rxla_state_after", UVM_NONE)

                 rx_snp_dly = $urandom_range(5000,10000);
                 repeat (rx_snp_dly) @ (posedge m_chi_if_caiu<%=obj.Id%>.clk);

                 do
                 begin
                   @ (posedge m_chi_if_caiu<%=obj.Id%>.clk);
                 end
                 while(int'(env.amba_system_env.chi_system[0].rn[0].shared_status.link_status.snp_vc_advertised_curr_l_credit_count) > 'h0);

                 if (link_svc_rx_snp_seq_item.randomize() with { service_type == svt_chi_link_service::RESUME_SNP_LCRD; }) begin
                      `uvm_info(get_name(), "Created RESUME_SNP_LCRD Link Svc Request", UVM_NONE)
                      env.amba_system_env.chi_system[0].rn[0].link_svc_seqr.execute_item(link_svc_rx_snp_seq_item);
                 end
             end //forever
          end //if
       end


 begin
      if(!(vip_snps_coherent_txn || vip_snps_non_coherent_txn)) begin
        if(k_num_snoop >= 0)
            m_system_bfm_seq.k_num_snp.set_value(k_num_snoop); 
      end
      if($test$plusargs("SNPrsp_time_out_test") || $test$plusargs("SNPrsp_with_data_error") || $test$plusargs("wrong_dtrrsp_target_id")) begin
          if($test$plusargs("wrong_dtrrsp_target_id")) begin
              m_system_bfm_seq.wt_snp_prev_addr.set_value(100);
	  end else begin
              m_system_bfm_seq.wt_snp_prev_addr.set_value(0);
          end
          m_system_bfm_seq.wt_snp_cmd_req_addr.set_value(100);
          m_system_bfm_seq.wt_snp_random_addr.set_value(100);
          m_system_bfm_seq.wt_snp_for_stash_random_addr.set_value(0);
      end
      if ($test$plusargs("stash_txn_test")) begin
      //    m_system_bfm_seq.wt_snp_inv_stsh.set_value(80);
      //    m_system_bfm_seq.wt_snp_unq_stsh.set_value(80);
      //    m_system_bfm_seq.wt_snp_stsh_sh.set_value(0);
      //    m_system_bfm_seq.wt_snp_stsh_unq.set_value(0);
      //    m_system_bfm_seq.wt_snp_inv.set_value(0); 
      //    m_system_bfm_seq.wt_snp_cln_dtr.set_value(0); 
      //    m_system_bfm_seq.wt_snp_vld_dtr.set_value(0); 
      //    m_system_bfm_seq.wt_snp_inv_dtr.set_value(0); 
      //    m_system_bfm_seq.wt_snp_cln_dtw.set_value(0); 
      //    m_system_bfm_seq.wt_snp_inv_dtw.set_value(0); 
      //    m_system_bfm_seq.wt_snp_nitc.set_value(0); 
      //    m_system_bfm_seq.wt_snp_nitcci.set_value(0); 
      //    m_system_bfm_seq.wt_snp_nitcmi.set_value(0); 
      //    m_system_bfm_seq.wt_snp_nosdint.set_value(0); 
      //end else if ($test$plusargs("dataless_stash_txn_test")) begin
      //    m_system_bfm_seq.wt_snp_inv_stsh.set_value(0);
      //    m_system_bfm_seq.wt_snp_unq_stsh.set_value(0);
      //    m_system_bfm_seq.wt_snp_stsh_sh.set_value(90);
      //    m_system_bfm_seq.wt_snp_stsh_unq.set_value(90);
      //    m_system_bfm_seq.wt_snp_inv.set_value(0); 
      //    m_system_bfm_seq.wt_snp_cln_dtr.set_value(0); 
      //    m_system_bfm_seq.wt_snp_vld_dtr.set_value(0); 
      //    m_system_bfm_seq.wt_snp_inv_dtr.set_value(0); 
      //    m_system_bfm_seq.wt_snp_cln_dtw.set_value(0); 
      //    m_system_bfm_seq.wt_snp_inv_dtw.set_value(0); 
      //    m_system_bfm_seq.wt_snp_nitc.set_value(0); 
      //    m_system_bfm_seq.wt_snp_nitcci.set_value(0); 
      //    m_system_bfm_seq.wt_snp_nitcmi.set_value(0); 
      //    m_system_bfm_seq.wt_snp_nosdint.set_value(0); 
      end else if ($test$plusargs("no_stash_snoop_test")) begin
          m_system_bfm_seq.wt_snp_inv_stsh.set_value(0);
          m_system_bfm_seq.wt_snp_unq_stsh.set_value(0);
          m_system_bfm_seq.wt_snp_stsh_sh.set_value(0);
          m_system_bfm_seq.wt_snp_stsh_unq.set_value(0);
      end 
      //if ($test$plusargs("k_en_dvm_snoops")) begin
      //    m_system_bfm_seq.wt_snp_dvm_msg.set_value(100);
      //    m_system_bfm_seq.wt_snp_inv_stsh.set_value(0);
      //    m_system_bfm_seq.wt_snp_unq_stsh.set_value(0);
      //    m_system_bfm_seq.wt_snp_stsh_sh.set_value(0);
      //    m_system_bfm_seq.wt_snp_stsh_unq.set_value(0);
      //    m_system_bfm_seq.wt_snp_inv.set_value(0); 
      //    m_system_bfm_seq.wt_snp_cln_dtr.set_value(0); 
      //    m_system_bfm_seq.wt_snp_vld_dtr.set_value(0); 
      //    m_system_bfm_seq.wt_snp_inv_dtr.set_value(0); 
      //    m_system_bfm_seq.wt_snp_cln_dtw.set_value(0); 
      //    m_system_bfm_seq.wt_snp_inv_dtw.set_value(0); 
      //    m_system_bfm_seq.wt_snp_nitc.set_value(0); 
      //    m_system_bfm_seq.wt_snp_nitcci.set_value(0); 
      //    m_system_bfm_seq.wt_snp_nitcmi.set_value(0); 
      //    m_system_bfm_seq.wt_snp_nosdint.set_value(0); 
      //end
      //m_system_bfm_seq.wt_snp_dvm_msg.set_value(20);
      //if (k_csr_seq) begin
      //  `uvm_info("run_main","Waiting for CSR seq to set the control register",UVM_NONE)
      //  ev.wait_ptrigger();
      //  `uvm_info("run_main","Waiting Completed for CSR seq to set the control register",UVM_NONE)
      //end

      if ($test$plusargs("dis_delay_system_bfm")) begin
      	  m_system_bfm_seq.dis_delay_dtr_req              = 1;
      	  m_system_bfm_seq.dis_delay_str_req              = 1;
      	  m_system_bfm_seq.dis_delay_tx_resp              = 1;
      	  m_system_bfm_seq.dis_delay_cmd_resp             = 1;
      	  m_system_bfm_seq.dis_delay_dtw_resp             = 1;
      	  m_system_bfm_seq.dis_delay_upd_resp             = 1;
      	  m_system_bfm_seq.high_system_bfm_slv_rsp_delays = 0;
      end 

  <% if(obj.testBench == 'chi_aiu') { %>
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
   `uvm_info(get_name(), "Start m_system_bfm_seq", UVM_NONE)
   m_system_bfm_seq.start(null);
   `uvm_info(get_name(), "Done m_system_bfm_seq", UVM_NONE)
 end
    if($test$plusargs("k_toggle_sysco")) begin
      int unsigned toggle_count = $value$plusargs("toggle_count=%0d", toggle_count) ? toggle_count : (1<<12);
      chi_base_seq_item m_obj;
      `uvm_info(get_name(), $sformatf("toggle_count=%0d", toggle_count), UVM_DEBUG)
      if(csr_seq != null && k_csr_seq == "chi_aiu_ral_sysco_seq") begin
        m_obj = null;
      end
      else begin
        m_obj = new;
      end

      fork
        begin : th_main
          int random_time, time1, time2, time3, time4; bit en;
          realtime rtime1, rtime2;
          time1 = 800; time2 = 1000; time3 = 2500; time4 = 6000;
          rtime1 = (10**3)*1ns*(100); rtime2 = (10**3)*1ns*(30);
          random_time = $urandom_range(1000,1500);
          #(random_time*1ns);
          repeat(toggle_count) begin
            random_time = $realtime < rtime1 ? (($realtime < rtime2) ? $urandom_range(time1,time2) : $urandom_range(time2,time3)) : $urandom_range(time3,time4);
            `uvm_info(get_name(), "th1_outer::dbg_0", UVM_DEBUG)
            ev_toggle_sysco_<%=obj.BlockId%>.trigger(m_obj);
            `uvm_info(get_name(), "th1_outer::dbg_1", UVM_DEBUG)
            #500ns; //make sure that txn got collected at SCB
            wait(m_env.m_scb.get_cur_sysco_state inside {ENABLED, DISABLED});
            `uvm_info(get_name(), "th1_outer::dbg_2", UVM_DEBUG)
            #(random_time*1ns);
          end // repeat
        end // th_main
      join_none
    end
 join_any

  if($test$plusargs("main_seq_iter")) begin
    ev_main_seq_done.wait_ptrigger();
  end
  if ($test$plusargs("check4_attach") && (!$test$plusargs("resend_correct_target_id")) && (!$test$plusargs("SYSrsp_time_out_test"))) begin
  #250us;
  end else begin
    if (((!$test$plusargs("resend_correct_target_id")) && ($test$plusargs("wrong_snpreq_target_id") || $test$plusargs("wrong_sysrsp_target_id"))) || $test$plusargs("drop_smi_uce_pkt")) begin
    #1ms;
    end else begin
    #10us;
    m_env.m_scb.objection.wait_for_total_count(m_env.m_scb, 0);
    `uvm_info(get_name(), "Scoreboard uvm objection dropped", UVM_NONE)
    end
  end
  `uvm_info(get_name(), "Dropping objection for bringup_test", UVM_NONE)
  phase.phase_done.set_drain_time(this, 500ns);
  main_seq_hook_end_run_phase(phase); // virtual task
  phase.drop_objection(this, "bringup_test");

`endif //USE_VIP_SNPS
endtask: run_phase

function void chi_aiu_bringup_test::set_testplusargs();
int arg_k_num_requests=500;
int arg_k_num_cmds;

    if($value$plusargs("k_num_cmd=%0d",arg_k_num_cmds)) begin 
        arg_k_num_requests = arg_k_num_cmds; 
        `uvm_info("CHI_BRINGUP", $psprintf("num_requests is set to %0d", arg_k_num_requests), UVM_HIGH)
    end

    if($value$plusargs("k_num_requests=%0d",arg_k_num_requests)) begin
      m_args.k_num_requests.set_value(arg_k_num_requests);
    end
    else begin
      m_args.k_num_requests.set_value(arg_k_num_requests);
    end

    m_args.k_txreq_hld_dly.set_value(1);
    m_args.k_txreq_dly_min.set_value(0);
    m_args.k_txreq_dly_max.set_value(5);
    m_args.k_txrsp_hld_dly.set_value(1);
    m_args.k_txrsp_dly_min.set_value(0);
    m_args.k_txrsp_dly_max.set_value(15);
    m_args.k_txdat_hld_dly.set_value(1);
    m_args.k_txdat_dly_min.set_value(0);
    m_args.k_txdat_dly_max.set_value(15);
 
    if($test$plusargs("SNPrsp_time_out_test")) begin
      m_args.k_txdat_dly_min.set_value(9000);
      m_args.k_txdat_dly_max.set_value(10000);
    end

    if($test$plusargs("chi_intf_b2b")) begin
        m_args.k_txreq_hld_dly.set_value(1);
        m_args.k_txreq_dly_min.set_value(0);
        m_args.k_txreq_dly_max.set_value(0);
        m_args.k_txrsp_hld_dly.set_value(1);
        m_args.k_txrsp_dly_min.set_value(0);
        m_args.k_txrsp_dly_max.set_value(0);
        m_args.k_txdat_hld_dly.set_value(1);
        m_args.k_txdat_dly_min.set_value(0);
        m_args.k_txdat_dly_max.set_value(0);
    end


    if($test$plusargs("non_coherent_test")) begin
        m_args.k_noncoh_addr_pct.set_value(100);
        m_args.k_coh_addr_pct.set_value(0);
    end else if($test$plusargs("coherent_test")) begin
        m_args.k_noncoh_addr_pct.set_value(0);
        m_args.k_coh_addr_pct.set_value(100);
    end else begin
        m_args.k_noncoh_addr_pct.set_value(50);
        m_args.k_coh_addr_pct.set_value(50);
    end

    if(!$test$plusargs("k_device_type_mem_pct")) begin
    	m_args.k_device_type_mem_pct.set_value($urandom_range(10,90));
    end

    if($test$plusargs("non_coherent_test")) begin
      m_args.k_rd_noncoh_pct.set_value(10);
      m_args.k_rd_rdonce_pct.set_value(0);
      m_args.k_rd_ldrstr_pct.set_value(0);
      m_args.k_dt_ls_upd_pct.set_value(0);
      m_args.k_dt_ls_cmo_pct.set_value(0);
      m_args.k_dt_ls_sth_pct.set_value(0);
      m_args.k_wr_noncoh_pct.set_value(10);
      m_args.k_wr_cohunq_pct.set_value(0);
      m_args.k_wr_cpybck_pct.set_value(0);
      m_args.k_rd_prfr_unq_pct.set_value(0);
      m_args.k_wr_nosnp_full_cmo.set_value(0);
      m_args.k_wr_evict_or_evict.set_value(0);
      m_args.k_wr_back_full_cmo.set_value(0);
      m_args.k_wr_cln_full_cmo.set_value(0);
      m_args.k_atomic_st_pct.set_value(10);
      m_args.k_atomic_ld_pct.set_value(10);
      m_args.k_atomic_sw_pct.set_value(10);
      m_args.k_atomic_cm_pct.set_value(10);
      m_args.k_dvm_opert_pct.set_value(0);
      m_args.k_pre_fetch_pct.set_value(0);
      m_args.k_unsupported_txn_pct.set_value(0);
    end else if($test$plusargs("coherent_test")) begin
      m_args.k_rd_noncoh_pct.set_value(0);
      m_args.k_rd_rdonce_pct.set_value(10);
      m_args.k_rd_ldrstr_pct.set_value(10);
      m_args.k_dt_ls_upd_pct.set_value(10);
      m_args.k_dt_ls_cmo_pct.set_value(10);
      m_args.k_dt_ls_sth_pct.set_value(10);
      m_args.k_wr_noncoh_pct.set_value(0);
      m_args.k_wr_cohunq_pct.set_value(10);
      m_args.k_wr_cpybck_pct.set_value(10);
      m_args.k_rd_prfr_unq_pct.set_value(0);
      m_args.k_wr_nosnp_full_cmo.set_value(0);
      m_args.k_wr_evict_or_evict.set_value(0);
      m_args.k_wr_back_full_cmo.set_value(0);
      m_args.k_wr_cln_full_cmo.set_value(0);
      m_args.k_atomic_st_pct.set_value(10);
      m_args.k_atomic_ld_pct.set_value(10);
      m_args.k_atomic_sw_pct.set_value(10);
      m_args.k_atomic_cm_pct.set_value(10);
      m_args.k_dvm_opert_pct.set_value(0);
      m_args.k_pre_fetch_pct.set_value(0);
      m_args.k_unsupported_txn_pct.set_value(0);
    end else if($test$plusargs("scm_bckpressure_test")) begin
      m_args.k_rd_noncoh_pct.set_value(0);
      m_args.k_rd_rdonce_pct.set_value(0);
      m_args.k_rd_ldrstr_pct.set_value(90);
      m_args.k_dt_ls_upd_pct.set_value(0);
      m_args.k_dt_ls_cmo_pct.set_value(0);
      m_args.k_dt_ls_sth_pct.set_value(0);
      m_args.k_wr_noncoh_pct.set_value(0);
      m_args.k_wr_cohunq_pct.set_value(90);
      m_args.k_wr_cpybck_pct.set_value(0);
      m_args.k_rd_prfr_unq_pct.set_value(0);
      m_args.k_wr_nosnp_full_cmo.set_value(0);
      m_args.k_wr_evict_or_evict.set_value(0);
      m_args.k_wr_back_full_cmo.set_value(0);
      m_args.k_wr_cln_full_cmo.set_value(0);
      m_args.k_atomic_st_pct.set_value(0);
      m_args.k_atomic_ld_pct.set_value(0);
      m_args.k_atomic_sw_pct.set_value(0);
      m_args.k_atomic_cm_pct.set_value(0);
      m_args.k_dvm_opert_pct.set_value(0);
      m_args.k_pre_fetch_pct.set_value(0);
      m_args.k_unsupported_txn_pct.set_value(0);
      m_args.k_rq_lcrdrt_pct.set_value(0);
    end else if($test$plusargs("read_txn_test")) begin
        m_args.k_rd_noncoh_pct.set_value(90);
        m_args.k_rd_rdonce_pct.set_value(90);
        m_args.k_rd_ldrstr_pct.set_value(90);
        m_args.k_dt_ls_upd_pct.set_value(0);
        m_args.k_dt_ls_cmo_pct.set_value(0);
        m_args.k_dt_ls_sth_pct.set_value(0);
        m_args.k_wr_noncoh_pct.set_value(0);
        m_args.k_wr_cohunq_pct.set_value(0);
        m_args.k_wr_cpybck_pct.set_value(0);
        `ifdef SVT_CHI_ISSUE_E_ENABLE
        m_args.k_rd_prfr_unq_pct.set_value(90);
        `else  
        m_args.k_rd_prfr_unq_pct.set_value(0);
	`endif
        m_args.k_wr_nosnp_full_cmo.set_value(0);
        m_args.k_wr_evict_or_evict.set_value(0);
        m_args.k_wr_back_full_cmo.set_value(0);
        m_args.k_wr_cln_full_cmo.set_value(0);
        m_args.k_atomic_st_pct.set_value(0);
        m_args.k_atomic_ld_pct.set_value(0);
        m_args.k_atomic_sw_pct.set_value(0);
        m_args.k_atomic_cm_pct.set_value(0);
        m_args.k_dvm_opert_pct.set_value(0);
        m_args.k_pre_fetch_pct.set_value(0);
        m_args.k_unsupported_txn_pct.set_value(0);
    end else if ($test$plusargs("read_noncoh_txn_test")) begin
        m_args.k_rd_noncoh_pct.set_value(90);
        m_args.k_device_type_mem_pct.set_value(90);
        m_args.k_noncoh_addr_pct.set_value(100);
        m_args.k_rd_rdonce_pct.set_value(0);
        m_args.k_rd_ldrstr_pct.set_value(0);
        m_args.k_dt_ls_upd_pct.set_value(0);
        m_args.k_dt_ls_cmo_pct.set_value(0);
        m_args.k_dt_ls_sth_pct.set_value(0);
        m_args.k_wr_noncoh_pct.set_value(0);
        m_args.k_wr_cohunq_pct.set_value(0);
        m_args.k_wr_cpybck_pct.set_value(0);
        m_args.k_rd_prfr_unq_pct.set_value(0);
        m_args.k_wr_nosnp_full_cmo.set_value(0);
        m_args.k_wr_evict_or_evict.set_value(0);
        m_args.k_wr_back_full_cmo.set_value(0);
        m_args.k_wr_cln_full_cmo.set_value(0);
        m_args.k_atomic_st_pct.set_value(0);
        m_args.k_atomic_ld_pct.set_value(0);
        m_args.k_atomic_sw_pct.set_value(0);
        m_args.k_atomic_cm_pct.set_value(0);
        m_args.k_dvm_opert_pct.set_value(0);
        m_args.k_pre_fetch_pct.set_value(0);
        m_args.k_unsupported_txn_pct.set_value(0);
        m_args.k_rq_lcrdrt_pct.set_value(0);
    end else if ($test$plusargs("dataless_txn_test")) begin
        m_args.k_rd_noncoh_pct.set_value(0);
        m_args.k_rd_rdonce_pct.set_value(0);
        m_args.k_rd_ldrstr_pct.set_value(0);
        m_args.k_dt_ls_upd_pct.set_value(90);
        m_args.k_dt_ls_cmo_pct.set_value(90);
        m_args.k_dt_ls_sth_pct.set_value(90);
        m_args.k_wr_noncoh_pct.set_value(0);
        m_args.k_wr_cohunq_pct.set_value(0);
        `ifdef USE_VIP_SNPS
        m_args.k_wr_cpybck_pct.set_value(10);
        `else  
        m_args.k_wr_cpybck_pct.set_value(0);
	`endif
        m_args.k_rd_prfr_unq_pct.set_value(0);
        m_args.k_wr_nosnp_full_cmo.set_value(0);
        m_args.k_wr_evict_or_evict.set_value(0);
        m_args.k_wr_back_full_cmo.set_value(0);
        m_args.k_wr_cln_full_cmo.set_value(0);
        m_args.k_atomic_st_pct.set_value(0);
        m_args.k_atomic_ld_pct.set_value(0);
        m_args.k_atomic_sw_pct.set_value(0);
        m_args.k_atomic_cm_pct.set_value(0);
        m_args.k_dvm_opert_pct.set_value(0);
        m_args.k_pre_fetch_pct.set_value(0);
        m_args.k_unsupported_txn_pct.set_value(0);
    end else if ($test$plusargs("write_txn_test")) begin
        m_args.k_rd_noncoh_pct.set_value(0);
        m_args.k_rd_rdonce_pct.set_value(0);
        m_args.k_rd_ldrstr_pct.set_value(0);
        m_args.k_dt_ls_upd_pct.set_value(0);
        m_args.k_dt_ls_cmo_pct.set_value(0);
        m_args.k_dt_ls_sth_pct.set_value(0);
        m_args.k_wr_noncoh_pct.set_value(90);
        m_args.k_wr_cohunq_pct.set_value(90);
        m_args.k_wr_cpybck_pct.set_value(90);
        m_args.k_rd_prfr_unq_pct.set_value(0);
        `ifdef SVT_CHI_ISSUE_E_ENABLE
        m_args.k_wr_nosnp_full_cmo.set_value(90);
        m_args.k_wr_evict_or_evict.set_value(90);
        m_args.k_wr_back_full_cmo.set_value(90);
        m_args.k_wr_cln_full_cmo.set_value(90);
        `else  
        m_args.k_wr_nosnp_full_cmo.set_value(0);
        m_args.k_wr_evict_or_evict.set_value(0);
        m_args.k_wr_back_full_cmo.set_value(0);
        m_args.k_wr_cln_full_cmo.set_value(0);
	`endif
        m_args.k_atomic_st_pct.set_value(0);
        m_args.k_atomic_ld_pct.set_value(0);
        m_args.k_atomic_sw_pct.set_value(0);
        m_args.k_atomic_cm_pct.set_value(0);
        m_args.k_dvm_opert_pct.set_value(0);
        m_args.k_pre_fetch_pct.set_value(0);
        m_args.k_unsupported_txn_pct.set_value(0);
    end else if ($test$plusargs("write_coh_noncoh_txn_test")) begin
        m_args.k_rd_noncoh_pct.set_value(0);
        m_args.k_rd_rdonce_pct.set_value(0);
        m_args.k_rd_ldrstr_pct.set_value(0);
        m_args.k_dt_ls_upd_pct.set_value(0);
        m_args.k_dt_ls_cmo_pct.set_value(0);
        m_args.k_dt_ls_sth_pct.set_value(0);
        m_args.k_wr_noncoh_pct.set_value(90);
        m_args.k_wr_cohunq_pct.set_value(90);
        m_args.k_wr_cpybck_pct.set_value(0);
        m_args.k_rd_prfr_unq_pct.set_value(0);
        m_args.k_wr_nosnp_full_cmo.set_value(0);
        m_args.k_wr_evict_or_evict.set_value(0);
        m_args.k_wr_back_full_cmo.set_value(0);
        m_args.k_wr_cln_full_cmo.set_value(0);
        m_args.k_atomic_st_pct.set_value(0);
        m_args.k_atomic_ld_pct.set_value(0);
        m_args.k_atomic_sw_pct.set_value(0);
        m_args.k_atomic_cm_pct.set_value(0);
        m_args.k_dvm_opert_pct.set_value(0);
        m_args.k_pre_fetch_pct.set_value(0);
        m_args.k_unsupported_txn_pct.set_value(0);
      end else if ($test$plusargs("write_noncoh_txn_test")) begin
        m_args.k_rd_noncoh_pct.set_value(0);
        m_args.k_rd_rdonce_pct.set_value(0);
        m_args.k_rd_ldrstr_pct.set_value(0);
        m_args.k_dt_ls_upd_pct.set_value(0);
        m_args.k_dt_ls_cmo_pct.set_value(0);
        m_args.k_dt_ls_sth_pct.set_value(0);
        m_args.k_wr_noncoh_pct.set_value(90);
        m_args.k_wr_cohunq_pct.set_value(0);
        m_args.k_wr_cpybck_pct.set_value(0);
        m_args.k_rd_prfr_unq_pct.set_value(0);
        m_args.k_wr_nosnp_full_cmo.set_value(0);
        m_args.k_wr_evict_or_evict.set_value(0);
        m_args.k_wr_back_full_cmo.set_value(0);
        m_args.k_wr_cln_full_cmo.set_value(0);
        m_args.k_atomic_st_pct.set_value(0);
        m_args.k_atomic_ld_pct.set_value(0);
        m_args.k_atomic_sw_pct.set_value(0);
        m_args.k_atomic_cm_pct.set_value(0);
        m_args.k_dvm_opert_pct.set_value(0);
        m_args.k_pre_fetch_pct.set_value(0);
        m_args.k_unsupported_txn_pct.set_value(0);
        m_args.k_rq_lcrdrt_pct.set_value(0);
    end else if ($test$plusargs("random_txn_test")) begin
        m_args.k_rd_noncoh_pct.set_value(90);
        m_args.k_rd_rdonce_pct.set_value(90);
        m_args.k_rd_ldrstr_pct.set_value(90);
        m_args.k_dt_ls_upd_pct.set_value(90);
        m_args.k_dt_ls_cmo_pct.set_value(90);
        m_args.k_dt_ls_sth_pct.set_value(90);
        m_args.k_wr_noncoh_pct.set_value(90);
        m_args.k_wr_cohunq_pct.set_value(90);
        m_args.k_wr_cpybck_pct.set_value(90);
        `ifdef SVT_CHI_ISSUE_E_ENABLE
        m_args.k_rd_prfr_unq_pct.set_value(90);
        m_args.k_wr_nosnp_full_cmo.set_value(90);
        m_args.k_wr_evict_or_evict.set_value(90);
        m_args.k_wr_back_full_cmo.set_value(90);
        m_args.k_wr_cln_full_cmo.set_value(90);
        `else
        m_args.k_rd_prfr_unq_pct.set_value(0);
        m_args.k_wr_nosnp_full_cmo.set_value(0);
        m_args.k_wr_evict_or_evict.set_value(0);
        m_args.k_wr_back_full_cmo.set_value(0);
        m_args.k_wr_cln_full_cmo.set_value(0);
	`endif  
        m_args.k_atomic_st_pct.set_value(70);
        m_args.k_atomic_ld_pct.set_value(70);
        m_args.k_atomic_sw_pct.set_value(70);
        m_args.k_atomic_cm_pct.set_value(70);
        m_args.k_dvm_opert_pct.set_value(40);
        m_args.k_pre_fetch_pct.set_value(40);
        m_args.k_unsupported_txn_pct.set_value(0);
       <% if((obj.testBench == 'chi_aiu')) { %>
       `ifdef VCS 
        if ($test$plusargs("cmp_rsp_err_inj") || $test$plusargs("snp_req_err_inj") || $test$plusargs("nccmd_rsp_err_inj")) begin
        m_args.k_dvm_opert_pct.set_value(90);
        end
        if ($test$plusargs("user_addr_for_csr") || $test$plusargs("use_user_addrq")) begin
        m_args.k_dvm_opert_pct.set_value(0);
        end
       `endif // `ifdef VCS
        <% } %>
    end else if ($test$plusargs("boundary_addr_txn_test")) begin
        m_args.k_rd_noncoh_pct.set_value(90);
        m_args.k_rd_rdonce_pct.set_value(90);
        m_args.k_rd_ldrstr_pct.set_value(0);
        m_args.k_dt_ls_upd_pct.set_value(0);
        m_args.k_dt_ls_cmo_pct.set_value(0);
        m_args.k_dt_ls_sth_pct.set_value(0);
        m_args.k_wr_noncoh_pct.set_value(90);
        m_args.k_wr_cohunq_pct.set_value(90);
        m_args.k_wr_cpybck_pct.set_value(90);
        m_args.k_rd_prfr_unq_pct.set_value(0);
        m_args.k_wr_nosnp_full_cmo.set_value(0);
        m_args.k_wr_evict_or_evict.set_value(0);
        m_args.k_wr_back_full_cmo.set_value(0);
        m_args.k_wr_cln_full_cmo.set_value(0);
        m_args.k_atomic_st_pct.set_value(0);
        m_args.k_atomic_ld_pct.set_value(0);
        m_args.k_atomic_sw_pct.set_value(0);
        m_args.k_atomic_cm_pct.set_value(0);
        m_args.k_dvm_opert_pct.set_value(0);
        m_args.k_pre_fetch_pct.set_value(40);
        m_args.k_unsupported_txn_pct.set_value(0);
    end else if ($test$plusargs("boundary_addr_txn_test_dtls")) begin
        m_args.k_rd_noncoh_pct.set_value(90);
        m_args.k_rd_rdonce_pct.set_value(90);
        m_args.k_rd_ldrstr_pct.set_value(0);
        m_args.k_dt_ls_upd_pct.set_value(0);
        m_args.k_dt_ls_cmo_pct.set_value(90);
        m_args.k_dt_ls_sth_pct.set_value(90);
        m_args.k_wr_noncoh_pct.set_value(90);
        m_args.k_wr_cohunq_pct.set_value(90);
        m_args.k_wr_cpybck_pct.set_value(90);
        m_args.k_rd_prfr_unq_pct.set_value(0);
        m_args.k_wr_nosnp_full_cmo.set_value(0);
        m_args.k_wr_evict_or_evict.set_value(0);
        m_args.k_wr_back_full_cmo.set_value(0);
        m_args.k_wr_cln_full_cmo.set_value(0);
        m_args.k_atomic_st_pct.set_value(0);
        m_args.k_atomic_ld_pct.set_value(0);
        m_args.k_atomic_sw_pct.set_value(0);
        m_args.k_atomic_cm_pct.set_value(0);
        m_args.k_dvm_opert_pct.set_value(0);
        m_args.k_pre_fetch_pct.set_value(40);
        m_args.k_unsupported_txn_pct.set_value(0);
    end else if ($test$plusargs("boundary_addr_txn_test_atm")) begin
        m_args.k_rd_noncoh_pct.set_value(90);
        m_args.k_rd_rdonce_pct.set_value(90);
        m_args.k_rd_ldrstr_pct.set_value(0);
        m_args.k_dt_ls_upd_pct.set_value(0);
        m_args.k_dt_ls_cmo_pct.set_value(0);
        m_args.k_dt_ls_sth_pct.set_value(0);
        m_args.k_wr_noncoh_pct.set_value(90);
        m_args.k_wr_cohunq_pct.set_value(90);
        m_args.k_wr_cpybck_pct.set_value(90);
        m_args.k_rd_prfr_unq_pct.set_value(0);
        m_args.k_wr_nosnp_full_cmo.set_value(0);
        m_args.k_wr_evict_or_evict.set_value(0);
        m_args.k_wr_back_full_cmo.set_value(0);
        m_args.k_wr_cln_full_cmo.set_value(0);
        m_args.k_atomic_st_pct.set_value(70);
        m_args.k_atomic_ld_pct.set_value(70);
        m_args.k_atomic_sw_pct.set_value(70);
        m_args.k_atomic_cm_pct.set_value(70);
        m_args.k_dvm_opert_pct.set_value(0);
        m_args.k_pre_fetch_pct.set_value(40);
        m_args.k_unsupported_txn_pct.set_value(0);
    end else if ($test$plusargs("atomic_txn_test") || $test$plusargs("atomic_err_txn_test")) begin
        m_args.k_rd_noncoh_pct.set_value(0);
        m_args.k_rd_rdonce_pct.set_value(0);
        m_args.k_rd_ldrstr_pct.set_value(0);
        m_args.k_dt_ls_upd_pct.set_value(0);
        m_args.k_dt_ls_cmo_pct.set_value(0);
        m_args.k_dt_ls_sth_pct.set_value(0);
        m_args.k_wr_noncoh_pct.set_value(0);
        m_args.k_wr_cohunq_pct.set_value(0);
        m_args.k_wr_cpybck_pct.set_value(0);
        m_args.k_rd_prfr_unq_pct.set_value(0);
        m_args.k_wr_nosnp_full_cmo.set_value(0);
        m_args.k_wr_evict_or_evict.set_value(0);
        m_args.k_wr_back_full_cmo.set_value(0);
        m_args.k_wr_cln_full_cmo.set_value(0);
        m_args.k_atomic_st_pct.set_value(80);
        m_args.k_atomic_ld_pct.set_value(80);
        m_args.k_atomic_sw_pct.set_value(80);
        m_args.k_atomic_cm_pct.set_value(80);
        m_args.k_dvm_opert_pct.set_value(0);
        m_args.k_pre_fetch_pct.set_value(0);
        m_args.k_rq_lcrdrt_pct.set_value(20);
        m_args.k_unsupported_txn_pct.set_value(0);
        `ifdef USE_VIP_SNPS
        if(!$test$plusargs("unsupported_atomic_txn_to_dii")) begin
          m_args.k_noncoh_addr_pct.set_value(0);
        end
        if($test$plusargs("unsupported_atomic_txn_to_dii")) begin
          m_args.k_noncoh_addr_pct.set_value(100);
         m_args.k_device_type_mem_pct.set_value(100);
          m_args.k_coh_addr_pct.set_value(0);
        end
        `endif
    end else if ($test$plusargs("dvm_op_test")) begin
        m_args.k_rd_noncoh_pct.set_value(0);
        m_args.k_rd_rdonce_pct.set_value(0);
        m_args.k_rd_ldrstr_pct.set_value(0);
        m_args.k_dt_ls_upd_pct.set_value(0);
        m_args.k_dt_ls_cmo_pct.set_value(0);
        m_args.k_dt_ls_sth_pct.set_value(0);
        m_args.k_wr_noncoh_pct.set_value(0);
        m_args.k_wr_cohunq_pct.set_value(0);
        m_args.k_wr_cpybck_pct.set_value(0);
        m_args.k_rd_prfr_unq_pct.set_value(0);
        m_args.k_wr_nosnp_full_cmo.set_value(0);
        m_args.k_wr_evict_or_evict.set_value(0);
        m_args.k_wr_back_full_cmo.set_value(0);
        m_args.k_wr_cln_full_cmo.set_value(0);
        m_args.k_atomic_st_pct.set_value(0);
        m_args.k_atomic_ld_pct.set_value(0);
        m_args.k_atomic_sw_pct.set_value(0);
        m_args.k_atomic_cm_pct.set_value(0);
        m_args.k_dvm_opert_pct.set_value(80);
        m_args.k_pre_fetch_pct.set_value(0);
        m_args.k_unsupported_txn_pct.set_value(0);
    end else if ($test$plusargs("reqlcrd_op_test")) begin
        m_args.k_rd_noncoh_pct.set_value(0);
        m_args.k_rd_rdonce_pct.set_value(0);
        m_args.k_rd_ldrstr_pct.set_value(0);
        m_args.k_dt_ls_upd_pct.set_value(0);
        m_args.k_dt_ls_cmo_pct.set_value(0);
        m_args.k_dt_ls_sth_pct.set_value(0);
        m_args.k_wr_noncoh_pct.set_value(0);
        m_args.k_wr_cohunq_pct.set_value(0);
        m_args.k_wr_cpybck_pct.set_value(0);
        m_args.k_rd_prfr_unq_pct.set_value(0);
        m_args.k_wr_nosnp_full_cmo.set_value(0);
        m_args.k_wr_evict_or_evict.set_value(0);
        m_args.k_wr_back_full_cmo.set_value(0);
        m_args.k_wr_cln_full_cmo.set_value(0);
        m_args.k_atomic_st_pct.set_value(0);
        m_args.k_atomic_ld_pct.set_value(0);
        m_args.k_atomic_sw_pct.set_value(0);
        m_args.k_atomic_cm_pct.set_value(0);
        m_args.k_dvm_opert_pct.set_value(0);
        m_args.k_pre_fetch_pct.set_value(0);
        m_args.k_rq_lcrdrt_pct.set_value(100);
        m_args.k_unsupported_txn_pct.set_value(0);
    end else if ($test$plusargs("unsupported_txn")) begin
        int wt_unsupported_txn;
        $value$plusargs("unsupported_txn=%d",wt_unsupported_txn);
        m_args.k_unsupported_txn_pct.set_value(wt_unsupported_txn);
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
	`ifdef SVT_CHI_ISSUE_E_ENABLE
        m_args.k_rd_prfr_unq_pct.set_value(90);
        m_args.k_wr_nosnp_full_cmo.set_value(90);
        m_args.k_wr_evict_or_evict.set_value(90);
        m_args.k_wr_back_full_cmo.set_value(90);
        m_args.k_wr_cln_full_cmo.set_value(90);
        `else  
        m_args.k_rd_prfr_unq_pct.set_value(0);
        m_args.k_wr_nosnp_full_cmo.set_value(0);
        m_args.k_wr_evict_or_evict.set_value(0);
        m_args.k_wr_back_full_cmo.set_value(0);
        m_args.k_wr_cln_full_cmo.set_value(0);
        `endif
    end else if ($test$plusargs("write_cmo_noncoh_txn_test")) begin
        m_args.k_rd_noncoh_pct.set_value(0);
        m_args.k_rd_rdonce_pct.set_value(0);
        m_args.k_rd_ldrstr_pct.set_value(0);
        m_args.k_dt_ls_upd_pct.set_value(0);
        m_args.k_dt_ls_cmo_pct.set_value(0);
        m_args.k_dt_ls_sth_pct.set_value(0);
        m_args.k_wr_noncoh_pct.set_value(0);
        m_args.k_wr_cohunq_pct.set_value(0);
        m_args.k_wr_cpybck_pct.set_value(0);
        m_args.k_rd_prfr_unq_pct.set_value(0);
        m_args.k_wr_evict_or_evict.set_value(0);
        m_args.k_wr_back_full_cmo.set_value(0);
        m_args.k_wr_cln_full_cmo.set_value(0);
        `ifdef SVT_CHI_ISSUE_E_ENABLE
        m_args.k_wr_nosnp_full_cmo.set_value(90);
        `else  
        m_args.k_wr_nosnp_full_cmo.set_value(0);
        `endif  
        m_args.k_atomic_st_pct.set_value(0);
        m_args.k_atomic_ld_pct.set_value(0);
        m_args.k_atomic_sw_pct.set_value(0);
        m_args.k_atomic_cm_pct.set_value(0);
        m_args.k_dvm_opert_pct.set_value(0);
        m_args.k_pre_fetch_pct.set_value(0);
        m_args.k_unsupported_txn_pct.set_value(0);
    end else if ($test$plusargs("write_cmo_copyback_txn_test")) begin
        m_args.k_rd_noncoh_pct.set_value(0);
        m_args.k_rd_rdonce_pct.set_value(0);
        m_args.k_rd_ldrstr_pct.set_value(0);
        m_args.k_dt_ls_upd_pct.set_value(50);
        m_args.k_dt_ls_cmo_pct.set_value(0);
        m_args.k_dt_ls_sth_pct.set_value(0);
        m_args.k_wr_noncoh_pct.set_value(0);
        m_args.k_wr_cohunq_pct.set_value(0);
        m_args.k_wr_cpybck_pct.set_value(0);
        m_args.k_rd_prfr_unq_pct.set_value(0);
        m_args.k_wr_nosnp_full_cmo.set_value(0);
        m_args.k_wr_evict_or_evict.set_value(0);
        `ifdef SVT_CHI_ISSUE_E_ENABLE
        m_args.k_wr_back_full_cmo.set_value(90);
        m_args.k_wr_cln_full_cmo.set_value(90);
        `else  
        m_args.k_wr_back_full_cmo.set_value(0);
        m_args.k_wr_cln_full_cmo.set_value(0);
        `endif  
        m_args.k_atomic_st_pct.set_value(0);
        m_args.k_atomic_ld_pct.set_value(0);
        m_args.k_atomic_sw_pct.set_value(0);
        m_args.k_atomic_cm_pct.set_value(0);
        m_args.k_dvm_opert_pct.set_value(0);
        m_args.k_pre_fetch_pct.set_value(0);
        m_args.k_unsupported_txn_pct.set_value(0);
    end else if ($test$plusargs("writeevictorevict_txn_test")) begin
        m_args.k_rd_noncoh_pct.set_value(0);
        m_args.k_rd_rdonce_pct.set_value(0);
        m_args.k_rd_ldrstr_pct.set_value(50);
        m_args.k_dt_ls_upd_pct.set_value(50);
        m_args.k_dt_ls_cmo_pct.set_value(0);
        m_args.k_dt_ls_sth_pct.set_value(0);
        m_args.k_wr_noncoh_pct.set_value(0);
        m_args.k_wr_cohunq_pct.set_value(0);
        m_args.k_wr_cpybck_pct.set_value(0);
        m_args.k_wr_nosnp_full_cmo.set_value(0);
        m_args.k_wr_back_full_cmo.set_value(0);
        m_args.k_wr_cln_full_cmo.set_value(0);
        `ifdef SVT_CHI_ISSUE_E_ENABLE
        m_args.k_rd_prfr_unq_pct.set_value(90);
        m_args.k_wr_evict_or_evict.set_value(90);
        `else  
        m_args.k_rd_prfr_unq_pct.set_value(0);
        m_args.k_wr_evict_or_evict.set_value(0);
        `endif  
        m_args.k_atomic_st_pct.set_value(0);
        m_args.k_atomic_ld_pct.set_value(0);
        m_args.k_atomic_sw_pct.set_value(0);
        m_args.k_atomic_cm_pct.set_value(0);
        m_args.k_dvm_opert_pct.set_value(0);
        m_args.k_pre_fetch_pct.set_value(0);
        m_args.k_unsupported_txn_pct.set_value(0);
    end

    m_args.k_alloc_hint_pct.set_value(90);
    m_args.k_cacheable_pct.set_value(90);
    m_args.k_wr_sthunq_pct.set_value(0); // Not supported in NCore3.0

    if (!$value$plusargs("k_num_snoop=%d",k_num_snoop)) begin
        k_num_snoop = -1;
    end 
  if (!$value$plusargs("wr_dat_cancel_pct=%d",k_writedatacancel_pct)) begin
      m_args.k_writedatacancel_pct.set_value(k_writedatacancel_pct);
  end 

  if($test$plusargs("STRreq_time_out_test") || $test$plusargs("CMDrsp_time_out_test")) begin
    //#Stimulus.CHIAIU.timeout.v3.cmdrsptimeout
    //#Stimulus.CHIAIU.timeout.v3.strreqtimeout
    m_args.k_rq_lcrdrt_pct.set_value(0);
  end
  if($test$plusargs("user_addr_for_csr")) begin
    m_args.k_device_type_mem_pct.set_value(0);
    m_args.k_wr_cpybck_pct.set_value(0);
    m_args.k_rd_prfr_unq_pct.set_value(0);
    m_args.k_wr_nosnp_full_cmo.set_value(0);
    m_args.k_wr_evict_or_evict.set_value(0);
    m_args.k_wr_back_full_cmo.set_value(0);
    m_args.k_wr_cln_full_cmo.set_value(0);
    m_args.k_rq_lcrdrt_pct.set_value(0);
  end
  `ifdef USE_VIP_SNPS
    if($test$plusargs("vip_snps_non_coherent_txn")) begin
      vip_snps_non_coherent_txn = 1;
    end
    else if($test$plusargs("vip_snps_coherent_txn")) begin
      vip_snps_coherent_txn = 1;
    end

    void'($value$plusargs("vip_snps_seq_length=%0d",vip_snps_seq_length));
    
  `endif

endfunction: set_testplusargs


//function void chi_aiu_bringup_test::construct_rd_seq(
//  ref chi_txn_seq#(chi_req_seq_item) m_req_seq);
//
//  chi_req_seq_item seq_item;
//
//  for (int i = 0; i < num_trans; i++) begin 
//    automatic int id = i;
//    seq_item = chi_req_seq_item::type_id::create("chi_req_seq_item");
//    seq_item.qos      = 1;
//    seq_item.tgtid    = 3;
//    seq_item.srcid    = 0;
//    seq_item.tracetag = 0;
//    seq_item.randomize(opcode) with {opcode inside {read_ops};};
//    //seq_item.opcode   = READNOSNP;
//    seq_item.size     = 'h6;
//    seq_item.txnid = id;
//    seq_item.addr = $urandom();
//    seq_item.addr[5:0] = 6'b0;
//    seq_item.returntxnid = id;
//    m_req_seq.push_back(seq_item);
//  end
//
//endfunction: construct_rd_seq
