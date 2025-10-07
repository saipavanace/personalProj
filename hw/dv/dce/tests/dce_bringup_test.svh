<%
    //all csr sequences
    var csr_seqs = [
        "dce_csr_dceuedr0_cfgctrl_disable_vbrecovery_seq",
        "dce_csr_diruuedr_TransErrDetEn_seq",
        "dce_csr_diruuedr_MemErrDetEn_seq",
        "dce_csr_dircecr_errInt_seq",
        "dce_csr_dirucecr_errDetEn_seq",
        "dce_csr_dirucecr_errThd_seq",
        "dce_csr_dirucecr_sw_write_seq",
        "dce_csr_diruuecr_sw_write_seq",
        "dce_csr_dirucecr_noDetEn_seq",
        "dce_csr_dirucecr_noIntEn_seq",
        "dce_csr_diruueir_MemErrInt_seq",
        "dce_csr_no_address_hit_seq",
        "dce_csr_address_region_overlap_seq",
        "dce_csr_mrd_zero_credits_seq",
        "dce_csr_mrd_scm_seq",
        "dce_csr_time_out_error_seq",
        "always_inject_error",
        "access_unmapped_csr_addr",
        "dce_corr_errint_check_through_dceucesar_seq",
        "dce_ucorr_errint_check_through_dceuuesar_seq",
        "dce_csr_dceucesar_seq",
        "dce_csr_dceuuesar_seq",
        "dce_sf_fix_index_seq",
        "dce_csr_dceueir_MemErrInt_skidbuf_seq",
        "dce_csr_dcececr_errThd_skidbuf_seq",
        "dce_csr_dcececr_noDetEn_skidbuf_seq",
        "set_max_errthd",
    ];
%>

//*************************************************
// DCE Random Traffic Test
// This is the main test, that will run different
// test sequences
//*************************************************

class dce_bringup_test extends dce_base_test;

 `uvm_component_utils(dce_bringup_test);
  uvm_reg_sequence csr_seq;
  uvm_reg_sequence trans_actv_seq;
  dce_csr_ev_msg_seq ev_msg_csr_seq;

  uvm_event_pool ev_pool = uvm_event_pool::get_global_pool();
  uvm_event ev = ev_pool.get("ev");
  dce_default_reset_seq default_seq;
  <% if(obj.useResiliency) { %>
   // This event triggers if any request is killed when injecting errors
   // to drop all objections and get out of run_phase, resolves hanging tests issue
  <% if(obj.testBench == 'dce') { %>
  `ifndef VCS
   event kill_test;
  `else // `ifndef VCS
   uvm_event kill_test;
  `endif // `ifndef VCS ... `else ... 
   uvm_event kill_test_1;
  <% } else {%>
    event kill_test;
    event kill_test_1;
  <% } %>
   uvm_object objectors_list[$];
   uvm_objection objection;
   virtual  <%=obj.BlockId%>_probe_if u_csr_probe_vif;
  <% } %>

  <% var filter_secded = 0; %>
  <% var filter_parity = 0; %>

  <% obj.SnoopFilterInfo.forEach(function sfways(item,index){ %>
    <%if(item.TagFilterErrorInfo.fnErrDetectCorrect === "SECDED") {%>
       <% filter_secded = 1; %>
  <% } %>
  <% }); %>

  <% obj.SnoopFilterInfo.forEach(function sfways(item,index){ %>
    <%if(item.TagFilterErrorInfo.fnErrDetectCorrect === "PARITY") {%>
      <% filter_parity = 1; %>
  <% } %>
  <% }); %>

  <% if (filter_secded == 1) { %>
    bit filter_secded = 1;
  <% } else { %>
    bit filter_secded = 0;
  <% } %>

  <% if (filter_parity == 1) { %>
     bit filter_parity = 1;
  <% } else { %>
     bit filter_parity = 0;
  <% } %>

  <% if ((obj.useResiliency) && (obj.testBench != "fsys")) { %>
  /*
   *demote handle to suppress any error coming for the resiliency 
   *testing. error form the fault_injector_checker will show, but
   *others will be converted to info
   */
  report_catcher_demoter_base fault_injector_checker_demoter_h;
  <% } %>

  extern function new(string name = "dce_bringup_test", uvm_component parent = null);
  extern function void build_phase(uvm_phase phase);
  extern function void start_of_simulation_phase(uvm_phase phase);
  extern task run_phase(uvm_phase phase);
  extern virtual function void report_phase(uvm_phase phase);

endclass: dce_bringup_test

//************************************
//  Default UVM Methods
//************************************
function dce_bringup_test::new( string name = "dce_bringup_test", uvm_component parent = null);
	super.new(name, parent);
endfunction: new

function void dce_bringup_test::build_phase(uvm_phase phase);
  <% if(obj.testBench == 'dce') { %>
   `ifdef VCS
    uvm_factory factory=uvm_factory::get();
   `endif  
  <% } %>
  <% if ((obj.useResiliency) && (obj.testBench != "fsys")) { %>
    if($test$plusargs("collect_resiliency_cov")) begin
      set_type_override_by_type(.original_type(<%=obj.BlockId%>_smi_agent_pkg::smi_coverage::get_type()), .override_type(smi_resiliency_coverage::get_type()), .replace(1));
    end
  <% } %>
	super.build_phase(phase);
    //`uvm_info("bringup_test",$sformatf("build_phase"),UVM_NONE);
    //instantiate the csr seq
   <% if (obj.INHOUSE_APB_VIP) { %>
    trans_actv_seq = dce_csr_trans_actv_seq::type_id::create("default_seq");
    ev_msg_csr_seq = dce_csr_ev_msg_seq::type_id::create("ev_msg_csr_seq");	
    default_seq = dce_default_reset_seq::type_id::create("default_seq");
    default_seq.m_env_cfg = m_env_cfg; 
    ev_msg_csr_seq.csr_ev_msg_env_cfg = m_env_cfg;
   <% if(obj.testBench == 'dce') { %>
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
   <% if(obj.useResiliency) { %>
   // This event triggers if any request is killed when injecting errors
   // to drop all objections and get out of run_phase, resolves hanging tests issue
  <% if(obj.testBench == 'dce') { %>
  `ifdef VCS
    if (!uvm_config_db#(uvm_event)::get(this,.inst_name ( "" ),.field_name( "kill_test" ),.value( kill_test ))) begin
       `uvm_error( "dce_bringup_test run_phase", "kill_test event not found" )
    end else begin
       `uvm_info( "dce_bringup_test run_phase", "kill_test event found",UVM_DEBUG)
       if(kill_test==null)
         `uvm_error( "dce_bringup_test run_phase", "kill_test event is null" )
    end
  `endif 
  <% } %> 
  <% } %> 
    if ($test$plusargs("cmdreq_burst_seq"))
    	factory.set_type_override_by_type(dce_default_mst_seq::get_type(), dce_cmdreq_burst_seq::get_type()); 
    if ($test$plusargs("updreq_burst_seq"))
    	factory.set_type_override_by_type(dce_default_mst_seq::get_type(), dce_updreq_burst_seq::get_type()); 
    if ($test$plusargs("allops_seq"))
    	factory.set_type_override_by_type(dce_default_mst_seq::get_type(), dce_allops_seq::get_type()); 
    if ($test$plusargs("alloc_ops_w_updreq_seq"))
    	factory.set_type_override_by_type(dce_default_mst_seq::get_type(), dce_alloc_ops_w_updreq_seq::get_type()); 
    if ($test$plusargs("snpreq_rbreq_seq"))
    	factory.set_type_override_by_type(dce_default_mst_seq::get_type(), dce_snpreq_rbreq_seq::get_type()); 
    if ($test$plusargs("ace_ro_seq"))
    	factory.set_type_override_by_type(dce_default_mst_seq::get_type(), dce_ace_ro_seq::get_type()); 
    if($test$plusargs("user_addr_for_csr"))
    	factory.set_type_override_by_type(dce_default_mst_seq::get_type(), dce_dm_recallreq_seq::get_type()); 
    if($test$plusargs("time_out_test"))
    	factory.set_type_override_by_type(dce_default_mst_seq::get_type(), dce_dm_recallreq_seq::get_type()); 
    if ($test$plusargs("mrd_credit_chk_seq"))
    	factory.set_type_override_by_type(dce_default_mst_seq::get_type(), dce_mrd_credit_chk_seq::get_type()); 
    if ($test$plusargs("rbid_rbuse_credit_chk_seq"))
    	factory.set_type_override_by_type(dce_default_mst_seq::get_type(), dce_rbid_rbuse_credit_chk_seq::get_type()); 
    if ($test$plusargs("rbid_rbrls_credit_chk_seq"))
    	factory.set_type_override_by_type(dce_default_mst_seq::get_type(), dce_rbid_rbrls_credit_chk_seq::get_type()); 
    if ($test$plusargs("snp_credit_chk_seq"))
    	factory.set_type_override_by_type(dce_default_mst_seq::get_type(), dce_snp_credit_chk_seq::get_type()); 
    if ($test$plusargs("directed_seq0")) begin
    	factory.set_type_override_by_type(dce_default_mst_seq::get_type(), dce_directed_seq0::get_type()); 
    	m_args.k_no_addr_conflicts.set_value(0);
    	m_args.k_max_num_addr.set_value(1);
    end

    if($test$plusargs("dce_snprsp_snarf1_error_seq")) begin
    	factory.set_type_override_by_type(dce_default_mst_seq::get_type(), dce_snprsp_snarf1_error_seq::get_type()); 
    	m_args.k_no_addr_conflicts.set_value(0);
    	m_args.k_max_num_addr.set_value(1);
    end 
    if($test$plusargs("dce_exc_ops_error_seq")) begin
    	factory.set_type_override_by_type(dce_default_mst_seq::get_type(), dce_exc_ops_error_seq::get_type()); 
    	m_args.k_no_addr_conflicts.set_value(0);
    	m_args.k_max_num_addr.set_value(1);
    end 

	if ($test$plusargs("snpreq_rdunq_rdvld_rdunq_seq")) begin
    	factory.set_type_override_by_type(dce_default_mst_seq::get_type(), dce_snpreq_rdunq_rdvld_rdunq_seq::get_type());
    	m_args.k_no_addr_conflicts.set_value(0);
    	`uvm_info(get_full_name(), "snpreq_rdunq_rdvld_rdunq_seq set",UVM_NONE)
    end
	if ($test$plusargs("dce_directed_wrunq_from_ace_seq")) begin
    	factory.set_type_override_by_type(dce_default_mst_seq::get_type(), dce_directed_wrunq_from_ace_seq::get_type());
    	`uvm_info(get_full_name(), "Running dce_directed_wrunq_from_ace_seq",UVM_NONE)
    	m_args.k_no_addr_conflicts.set_value(0);
    	m_args.k_max_num_addr.set_value(1);
	end
	if ($test$plusargs("dce_directed_cmd_upd_req_same_address_seq")) begin
    	factory.set_type_override_by_type(dce_default_mst_seq::get_type(), dce_directed_cmd_upd_req_same_address_seq::get_type());
    	`uvm_info(get_full_name(), "dce_directed_cmd_upd_req_same_address_seq",UVM_NONE)
    	m_args.k_no_addr_conflicts.set_value(0);
    	m_args.k_max_num_addr.set_value(2);
	end
	if ($test$plusargs("dce_directed_same_set_target_all_SF_seq")) begin
    	factory.set_type_override_by_type(dce_default_mst_seq::get_type(), dce_directed_same_set_target_all_SF_seq::get_type());
    	`uvm_info(get_full_name(), "dce_directed_same_set_target_all_SF_seq",UVM_NONE)
    	m_args.k_no_addr_conflicts.set_value(0);
    	m_args.k_max_num_addr.set_value(500);
	end
	if ($test$plusargs("dce_directed_same_set_writes_fast_ports_seq")) begin
    	factory.set_type_override_by_type(dce_default_mst_seq::get_type(), dce_directed_same_set_writes_fast_ports_seq::get_type());
    	`uvm_info(get_full_name(), "dce_directed_same_set_writes_fast_ports_seq",UVM_NONE)
    	m_args.k_no_addr_conflicts.set_value(0);
    	m_args.k_max_num_addr.set_value(500);
	end
	if ($test$plusargs("dce_directed_same_set_target_all_SF_seq_hw_cfg_41")) begin
    	factory.set_type_override_by_type(dce_default_mst_seq::get_type(), dce_directed_same_set_target_all_SF_seq_hw_cfg_41::get_type());
    	`uvm_info(get_full_name(), "dce_directed_same_set_target_all_SF_seq_hw_cfg_41",UVM_NONE)
    	m_args.k_no_addr_conflicts.set_value(0);
    	m_args.k_max_num_addr.set_value(2000);
	//m_args.k_max_num_setaddr.set_value(1);
	end
	if($test$plusargs("dce_addr_aliasing_seq")) begin
    		factory.set_type_override_by_type(dce_default_mst_seq::get_type(), dce_addr_aliasing_seq::get_type());
		`uvm_info(get_full_name(), "Running dce_aliasing_seq",UVM_NONE)
	end 
	if($test$plusargs("directed_wrclnptl_silent_seq")) begin
    		factory.set_type_override_by_type(dce_default_mst_seq::get_type(), dce_directed_wrclnptl_silent_seq::get_type());
		`uvm_info(get_full_name(), "Running dce_directed_wrclnptl_silent_seq",UVM_NONE)
    		m_args.k_max_num_addr.set_value(1);
    		m_args.k_no_addr_conflicts.set_value(0);
	end 
	if($test$plusargs("dce_directed_backpressure_seq")) begin
    		factory.set_type_override_by_type(dce_default_mst_seq::get_type(), dce_directed_backpressure_seq::get_type());
		`uvm_info(get_full_name(), "Running dce_directed_backpressure_seq",UVM_NONE)
    		m_args.k_max_num_addr.set_value(50);
    		m_args.k_no_addr_conflicts.set_value(0);
	end 
	if($test$plusargs("directed_attach_detach_seq")) begin
    		factory.set_type_override_by_type(dce_default_mst_seq::get_type(), dce_directed_attach_detach_seq::get_type());
		`uvm_info(get_full_name(), "Running dce_directed_attach_detach_seq",UVM_NONE)
    		m_args.k_max_num_addr.set_value(1);
    		m_args.k_no_addr_conflicts.set_value(0);
	end
	if($test$plusargs("directed_1_attach_detach_seq")) begin
    		factory.set_type_override_by_type(dce_default_mst_seq::get_type(), dce_directed_1_attach_detach_seq::get_type());
		`uvm_info(get_full_name(), "Running dce_directed_1_attach_detach_seq",UVM_NONE)
    		m_args.k_max_num_addr.set_value(1);
    		m_args.k_no_addr_conflicts.set_value(0);
	end
	if($test$plusargs("directed_2_attach_detach_seq")) begin
    		factory.set_type_override_by_type(dce_default_mst_seq::get_type(), dce_directed_2_attach_detach_seq::get_type());
		`uvm_info(get_full_name(), "Running dce_directed_2_attach_detach_seq",UVM_NONE)
    		m_args.k_max_num_addr.set_value(1);
    		m_args.k_no_addr_conflicts.set_value(0);
	end 
	if($test$plusargs("directed_3_attach_detach_seq")) begin
    		factory.set_type_override_by_type(dce_default_mst_seq::get_type(), dce_directed_3_attach_detach_seq::get_type());
		`uvm_info(get_full_name(), "Running dce_directed_3_attach_detach_seq",UVM_NONE)
    		m_args.k_max_num_addr.set_value(1);
    		m_args.k_no_addr_conflicts.set_value(0);
	end
	if($test$plusargs("directed_4_attach_detach_seq")) begin
    		factory.set_type_override_by_type(dce_default_mst_seq::get_type(), dce_directed_4_attach_detach_seq::get_type());
		`uvm_info(get_full_name(), "Running dce_directed_4_attach_detach_seq",UVM_NONE)
    		m_args.k_max_num_addr.set_value(1);
    		m_args.k_no_addr_conflicts.set_value(0);
	end  
	if($test$plusargs("dce_alloc_nonalloc_back_pressure_seq")) begin
    		factory.set_type_override_by_type(dce_default_mst_seq::get_type(), dce_alloc_nonalloc_back_pressure_seq::get_type());
		`uvm_info(get_full_name(), "dce_alloc_nonalloc_back_pressure_seq",UVM_NONE)
    		m_args.k_max_num_addr.set_value(15);
	end
    if ($test$plusargs("dce_dm_hit_target_as_sharer_seq")) begin
    	factory.set_type_override_by_type(dce_default_mst_seq::get_type(), dce_dm_hit_target_as_sharer_seq::get_type());
    	`uvm_info(get_full_name(), "dce_dm_hit_target_as_sharer_seq",UVM_NONE)
    	m_args.k_no_addr_conflicts.set_value(0);
    	m_args.k_max_num_addr.set_value(2);
	end

	//factory.print();
  <% if ((obj.useResiliency) && (obj.testBench != "fsys")) { %>
    if(!uvm_config_db#(virtual  <%=obj.BlockId%>_probe_if )::get(null, get_full_name(), "probe_vif",u_csr_probe_vif)) begin
        `uvm_error("NOVIF",{"virtual interface must be set  for :",get_full_name(),".vif"})
    end
    if($test$plusargs("expect_mission_fault")) begin
      fault_injector_checker_demoter_h = report_catcher_demoter_base::type_id::create("fault_injector_checker_demoter_h");
      fault_injector_checker_demoter_h.exp_id = {"fault_injector_checker"};
      fault_injector_checker_demoter_h.not_of = 1;
      fault_injector_checker_demoter_h.demote_uvm_fatal = 1; // to avoid credit_maint_pool error
      if($test$plusargs("expect_mission_fault_cov")) begin
        fault_injector_checker_demoter_h.demote_uvm_fatal = 1;
      end
      fault_injector_checker_demoter_h.build();
      `uvm_info(get_name(), $sformatf("Registering demoter class{%0s} for resiliency error ignore", fault_injector_checker_demoter_h.get_name()), UVM_LOW)
      uvm_report_cb::add(null, fault_injector_checker_demoter_h);
    end
  <% } %>

endfunction:build_phase

//*************************************
function void dce_bringup_test::start_of_simulation_phase(uvm_phase phase);
	super.start_of_simulation_phase(phase);

endfunction:start_of_simulation_phase

//*************************************
task dce_bringup_test::run_phase(uvm_phase phase);
      
    // YRAMASAMY: CONC-13141
    // Waiuting for bist sequence to complete before functional test starts!
    // Clean this up for 3.8 to ensure we run bist and functional test separately
    uvm_event ev_bist_reset_done = ev_pool.get("bist_reset_done");

    <% if(obj.useResiliency) { %>
    if(!$test$plusargs("xprop_test_enable")) begin
        phase.raise_objection(this, "bistSequenceStart");
       `uvm_info(get_full_name(), "Waiting for BIST sequence to complete", UVM_NONE)
        ev_bist_reset_done.wait_ptrigger();
       `uvm_info(get_full_name(), "BIST sequence completed", UVM_NONE)
        phase.drop_objection(this, "bistSequenceEnd");
    end
    <% } %>

	super.run_phase(phase);
    //`uvm_info("bringup_test",$sformatf("run_phase"),UVM_NONE);
    <% if (obj.INHOUSE_APB_VIP) { %>
      default_seq.model       = m_env.m_regs;
      trans_actv_seq.model 	  = m_env.m_regs;
      ev_msg_csr_seq.model 	  = m_env.m_regs;

      <% if(obj.testBench == 'dce') { %>
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
    
    if (m_env.m_dce_scb != null) 
    	phase.phase_done.set_drain_time(this, 1000ns);
    else 
    	phase.phase_done.set_drain_time(this, 50us);

    m_vseq = dce_virtual_seq::type_id::create("m_vseq");
    assign_sqr_and_misc_handles(phase);    

    uvm_config_db#(dce_scb)::set(uvm_root::get(), 
                                  "*", 
                                  "dce_sb", 
                                  m_env.m_dce_scb);

    <% if(obj.INHOUSE_APB_VIP) { %>
    phase.raise_objection(this, "Start default_seq");
    `uvm_info(get_full_name(), "default_seq started", UVM_NONE)
    default_seq.start(m_env.m_apb_agent.m_apb_sequencer);
    `uvm_info(get_full_name(), "default_seq finished",UVM_NONE)
    #100ns;
    phase.drop_objection(this, "Finish default_seq");
    <% } %>

   <% if(obj.useResiliency) { %>
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
        
        <%if(obj.DceInfo[obj.Id].CMDOverflowBufInSRAM == true) { %>
         if ($test$plusargs("inject_sram_skid_single_err") && filter_secded) begin 
           bit [7:0] errthd;
           errthd = $urandom_range(1,10); 
           `uvm_info("SKIDBUFERROR", $sformatf("errthd in run_phase of dce_test is  %0d", errthd), UVM_HIGH);
           `ifdef USE_VIP_SNPS
             uvm_config_db#(bit [7:0])::set(this,"m_env.amba_system_env.apb_system[0].master.sequencer","errthd",errthd);
           `else 
             uvm_config_db#(bit [7:0])::set(this,"m_env.m_apb_agent.m_apb_sequencer","errthd",errthd);
           `endif
            uvm_config_db#(bit [7:0])::set(this,"","errthd",errthd);

           for(int i=0; i<errthd +1; i++) begin //inject one more than errthd for interrupt and ErrVld
                
             `uvm_info("SKIDBUFERROR", $sformatf("Going to inject single corr err"), UVM_HIGH);
             @(negedge u_csr_probe_vif.clk);

             u_csr_probe_vif.inject_single_error();
                
             @(negedge u_csr_probe_vif.inject_cmd_data_single_next_1);
             `uvm_info("SKIDBUFERROR", $sformatf("Single bit error injection enabled in SRAM skid buffer with protection as SECDED and this is the %0d time ", i),UVM_HIGH);

           end 
                
           wait(u_csr_probe_vif.DCEUCESR_ErrVld)begin //to check ErrCountOverflow
             #130ns;
             `uvm_info("SKIDBUFERROR","Injecting the last single bit error",UVM_HIGH)
             u_csr_probe_vif.inject_single_error();
           end    

         end   
        <% } %>           

        if($test$plusargs("uncorr_skid_buffer_test"))begin 
          #500ns;
          if (!uvm_config_db#(uvm_event)::get(this, "", "kill_test_1", kill_test_1)) begin
            `uvm_error("TEST", "kill_test_1 not found in configuration database");
          end else begin
            `uvm_info( "SKIDBUFERROR", "kill_test_1 event found",UVM_HIGH);
          end

          `uvm_info("SKIDBUFERROR", "Waiting for kill_test_1 event to trigger",UVM_NONE)
          <% if(obj.testBench == 'dce') { %>
          `ifndef VCS
            @kill_test_1;   // otherwise the test will hang and timeout
          `else // `ifndef VCS
            kill_test_1.wait_trigger();  // otherwise the test will hang and timeout 
          `endif // `ifndef VCS ... `else ... 
          <% } else {%>
          @kill_test_1;   // otherwise the test will hang and timeout
          <% } %>
          m_env.m_dce_scb.jump_phase = 1;
          `uvm_info("run_main", "kill_test_1 event triggered",UVM_NONE);
          `uvm_info("SKIDBUFERROR", $sformatf("Saw uncorr fault in run phase of test and Jump to report phase"), UVM_HIGH);
          phase.jump(uvm_report_phase::get());
        end else begin
          `uvm_info("run_main", "waiting for kill_test event to trigger",UVM_NONE)
          if(m_env_cfg.has_scoreboard != 0)
            @m_env.m_dce_scb.kill_test;
          else
            <% if(obj.testBench == 'dce') { %>
            `ifndef VCS
            @kill_test;   // otherwise the test will hang and timeout
            `else // `ifndef VCS
             kill_test.wait_trigger();  // otherwise the test will hang and timeout 
             `endif // `ifndef VCS ... `else ... 
             <% } else {%>
            @kill_test;   // otherwise the test will hang and timeout
             <% } %>
        end
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
                     phase.raise_objection(this, "dce_uncorr_error_bringup_test");
                     `uvm_info(get_name(),"raised_objection::uncorr", UVM_DEBUG);
                     @u_csr_probe_vif.fault_mission_fault;
                     phase.drop_objection(this, "dce_uncorr_error_bringup_test");
                     `uvm_info(get_name(),"dropped_objection::uncorr", UVM_DEBUG);
                  end
                  if($test$plusargs("expect_mission_fault_cov"))begin
                    //repeat(10000) @(negedge u_csr_probe_vif.clk);
                    #1ms; // keep testcase timeout higher than this to avoid hearbeat failure
                  end
                  #(5*1ns);
                  `uvm_info($sformatf("%m"), $sformatf("<%=obj.BlockId%> saw mission fault. Kill test"), UVM_NONE)
                  <% if(obj.testBench == 'dce') { %>
                  `ifndef VCS
                  -> kill_test;   // otherwise the test will hang and timeout
                  `else // `ifndef VCS
                   kill_test.trigger();  // otherwise the test will hang and timeout 
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

    fork
      begin //Th1: dce_virtual_seq
        <% if(obj.testBench == 'dce') { %>
        `ifndef VCS
        if (k_csr_seq) begin
        `else // `ifndef VCS
         if (k_csr_seq != "") begin
        `endif // `ifndef VCS ... `else ... 
        <% } else {%>
         if (k_csr_seq) begin
        <% } %>
          `uvm_info(get_full_name(),"Waiting for CSR seq to set the control register",UVM_NONE)
          if(!$test$plusargs("uncorr_skid_buffer_test") && !$test$plusargs("inject_sram_skid_single_err") && !$test$plusargs("inject_sram_skid_double_err")) ev.wait_ptrigger();
          if($test$plusargs("user_addr_for_csr") ||
            (k_csr_seq == "dce_sf_fix_index_seq")) begin
          	`uvm_info(get_full_name(),"Test uses user_addrq",UVM_NONE)
            m_vseq.user_addr_q = ncoreConfigInfo::user_addrq[ncoreConfigInfo::COH];
          end
          `uvm_info(get_full_name(),"Waiting Completed for CSR seq to set the control register",UVM_NONE)
        end
      //Perf monitor
      main_seq_pre_hook(phase); // virtual task
      for(uint64_type i=0;i<main_seq_iter;i++) begin:forloop_main_seq_iter // by default main_seq_iter=1
        main_seq_iter_pre_hook(phase,i); // virtual task
  
          phase.raise_objection(this, "dce_bringup_test");
    	  `uvm_info(get_full_name(), "virtual_seq started",UVM_LOW)
        if (!smi_rx_stall_en) begin
          m_vseq.start(null);
        end
    	  `uvm_info(get_full_name(), "virtual_seq finished",UVM_LOW)
          phase.drop_objection(this, "dce_bringup_test");
        main_seq_iter_post_hook(phase,i); // virtual task
      end:forloop_main_seq_iter
      main_seq_post_hook(phase); // virtual task

      end
      begin //Th2: csr_seq
      	phase.raise_objection(this, "ev_msg_csr_seq");
      	`uvm_info(get_name(), "ev_msg_csr_seq started",UVM_NONE)
      	ev_msg_csr_seq.start(m_env.m_apb_agent.m_apb_sequencer);
      	phase.drop_objection(this, "ev_msg_csr_seq");
      	`uvm_info(get_name(), "ev_msg_csr_seq finished",UVM_NONE)

        <% if (obj.INHOUSE_APB_VIP) { %>
          <% if(obj.testBench == 'dce') { %>
          `ifndef VCS
          if (k_csr_seq) begin
          `else // `ifndef VCS
           if (k_csr_seq != "") begin
          `endif // `ifndef VCS ... `else ... 
          <% } else {%>
           if (k_csr_seq) begin
          <% } %>
            phase.raise_objection(this, "csr_seq");
            `uvm_info(get_name(), "csr_seq started",UVM_NONE)
            csr_seq.start(m_env.m_apb_agent.m_apb_sequencer);
            m_vseq.m_mst_seq.m_stop_cmd_issue = 1;
            `uvm_info(get_name(), "csr_seq finished",UVM_NONE)
            if(!$test$plusargs("uncorr_skid_buffer_test")) phase.drop_objection(this, "csr_seq");
          end
        <% } %>
      end
	  //#Check.DCE.TransActvSeq
	  if (!$test$plusargs("disable_dceutar_transactv_chk")) begin
		  begin //Th3: csr_seq checks TransActive CSR indicates busy in middle of simulation and then drops at EOT.
				<% if (obj.INHOUSE_APB_VIP) { %>
				phase.raise_objection(this, "csr_seq");
				`uvm_info(get_name(), "csr_seq started:check DCEUTAR.TransActv",UVM_NONE)
				trans_actv_seq.start(m_env.m_apb_agent.m_apb_sequencer);
				`uvm_info(get_name(), "csr_seq done:check DCEUTAR.TransActv",UVM_NONE)
				phase.drop_objection(this, "csr_seq");
			  <% } %>
		  end
 	  end
    join
    main_seq_hook_end_run_phase(phase); // virtual task
endtask: run_phase

function void dce_bringup_test::report_phase(uvm_phase phase);
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

    tb_res_smi_corr_err = m_env.m_dce_scb.res_smi_corr_err;
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
  super.report_phase(phase);
endfunction
/*
 *creating a stand alone testcase as testing for the features
 *related to unit duplication is done using force mechanism.
 */
class resiliency_unitduplication_test extends dce_bringup_test;

  `uvm_component_utils(resiliency_unitduplication_test)
 <% if(obj.testBench == 'dce') { %>
  `ifndef VCS
  event raise_obj_for_resiliency_test;
  event drop_obj_for_resiliency_test;
  `else // `ifndef VCS
  uvm_event raise_obj_for_resiliency_test;
  uvm_event drop_obj_for_resiliency_test;
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
    m_env_cfg.has_scoreboard = 0;
  endfunction : build_phase

  virtual task run_phase(uvm_phase phase);
    uvm_event_pool ev_pool = uvm_event_pool::get_global_pool();

    uvm_event ev_bist_reset_done = ev_pool.get("bist_reset_done");

    <% if(obj.testBench == 'dce') { %>
    `ifndef VCS
    if(!uvm_config_db#(event)::get(this, "", "raise_obj_for_resiliency_test", raise_obj_for_resiliency_test)) begin
      `uvm_error( "dce_test run_phase", "raise_obj_for_resiliency_test event not found" )
    end

    if(!uvm_config_db#(event)::get(this, "", "drop_obj_for_resiliency_test", drop_obj_for_resiliency_test)) begin
      `uvm_error( "dce_test run_phase", "drop_obj_for_resiliency_test event not found" )
    end
    `else // `ifndef VCS
    if(!uvm_config_db#(uvm_event)::get(this, "", "raise_obj_for_resiliency_test", raise_obj_for_resiliency_test)) begin
      `uvm_error( "dce_test run_phase", "raise_obj_for_resiliency_test event not found" )
    end

    if(!uvm_config_db#(uvm_event)::get(this, "", "drop_obj_for_resiliency_test", drop_obj_for_resiliency_test)) begin
      `uvm_error( "dce_test run_phase", "drop_obj_for_resiliency_test event not found" )
    end
    `endif // `ifndef VCS ... `else ... 
    <% } else {%>
    if(!uvm_config_db#(event)::get(this, "", "raise_obj_for_resiliency_test", raise_obj_for_resiliency_test)) begin
      `uvm_error( "dce_test run_phase", "raise_obj_for_resiliency_test event not found" )
    end

    if(!uvm_config_db#(event)::get(this, "", "drop_obj_for_resiliency_test", drop_obj_for_resiliency_test)) begin
      `uvm_error( "dce_test run_phase", "drop_obj_for_resiliency_test event not found" )
    end
      
    // YRAMASAMY: CONC-13141
    // Waiuting for bist sequence to complete before functional test starts!
    // Clean this up for 3.8 to ensure we run bist and functional test separately
    ev_bist_reset_done.wait_ptrigger();
    <% } %>

    phase.raise_objection(this, $sformatf("raise_objection from{%0s} in phase{%0s}",this.get_name(), phase.get_domain_name()));
    fork
      begin
        `uvm_info("run_main", "Waiting for random time units 2us", UVM_NONE)
        #2us;
      end
      begin
      <% if(obj.testBench == 'dce') { %>
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
      end
    join
    phase.drop_objection(this, $sformatf("drop_objection from{%0s} in phase{%0s}",this.get_name(), phase.get_domain_name()));

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

