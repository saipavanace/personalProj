
class dve_bringup_test extends dve_base_test;
  `uvm_component_utils(dve_bringup_test)
  //perf monitor
  `macro_perf_cnt_test_all_declarations

  dve_env_config m_env_cfg;
  dve_env m_dve_env;
//  dve_unit_args m_dve_unit_args;

  dve_csr_init_seq csr_init_seq;
  dve_seq m_dve_seq;

  string name = "dve_bringup_test";
  int m_timeout_us;
  bit k_smi_cov_en = 1;
  uvm_cmdline_processor clp = uvm_cmdline_processor::get_inst();
  virtual dve_csr_probe_if u_csr_probe_vif;
  <% if (obj.useResiliency) { %>
  <% if(obj.testBench == 'dve') { %>
   `ifndef VCS
    event kill_test;
   `else // `ifndef VCS
    uvm_event kill_test;
   `endif // `ifndef VCS ... `else ... 
   <% } else {%>
    event kill_test;
   <% } %>
    uvm_object objectors_list[$];
    uvm_objection objection;
    <% if(obj.testBench != "fsys") { %>
      /*
       *demote handle to suppress any error coming for the resiliency 
       *testing. error form the fault_injector_checker will show, but
       *others will be converted to info
       */
      report_catcher_demoter_base fault_injector_checker_demoter_h;
    <% } %>
  <% } %>

  function new(string _name = "dve_bringup_test", uvm_component parent = null);
    super.new(_name, parent);
     name = _name;
  endfunction // new

  function void build_phase(uvm_phase phase);
    string arg_value;
    <% if ((obj.useResiliency) && (obj.testBench != "fsys")) { %>
    if($test$plusargs("collect_resiliency_cov")) begin
      set_type_override_by_type(.original_type(<%=obj.BlockId%>_smi_agent_pkg::smi_coverage::get_type()), .override_type(smi_resiliency_coverage::get_type()), .replace(1));
    end
    <% } %>
    super.build_phase(phase);
    `uvm_info(name, "build_phase", UVM_NONE);

    if(clp.get_arg_value("+k_smi_cov_en=", arg_value)) begin
      k_smi_cov_en = arg_value.atoi();
    end

    // env config
    m_env_cfg = dve_env_config::type_id::create("m_env_cfg");

    if($test$plusargs("inject_smi_uncorr_error"))begin
      m_env_cfg.disable_sb();
    end
    // SMI agent config
    m_env_cfg.m_smi_agent_cfg = smi_agent_config::type_id::create("m_smi_agent_cfg");
    m_env_cfg.m_smi_agent_cfg.active = UVM_ACTIVE;
    m_env_cfg.m_smi_agent_cfg.cov_en = k_smi_cov_en;

    m_env_cfg.m_apb_agent_cfg = apb_agent_config::type_id::create("m_apb_agent_config",  this);

    m_env_cfg.m_q_chnl_agent_cfg = q_chnl_agent_config::type_id::create("m_q_chnl_agent_config",  this);
  
    if (!uvm_config_db#(virtual <%=obj.BlockId%>_q_chnl_if)::get(.cntxt( this ),
                                        .inst_name( "" ),
                                        .field_name( "m_q_chnl_if" ),
                                        .value(m_env_cfg.m_q_chnl_agent_cfg.m_vif ))) begin
        `uvm_error(get_name(), "m_q_chnl_if not found")
    end

    if (!uvm_config_db#(virtual <%=obj.BlockId%>_clock_counter_if)::get(.cntxt( this ),
                                        .inst_name( "" ),
                                        .field_name( "m_clock_counter_if" ),
                                        .value(m_env_cfg.m_clock_counter_vif ))) begin
        `uvm_error(get_name(), "m_clock_counter_if not found")
    end

    // SMI RX/TX interfaces from TB perspective
    <% for (var i = 0; i < obj.nSmiRx; i++) { %>
        if (!uvm_config_db #(virtual <%=obj.BlockId%>_smi_if)::get(
            .cntxt(this),
            .inst_name(""),
            .field_name("m_smi<%=i%>_tx_vif"),
        .value(m_env_cfg.m_smi<%=i%>_tx_vif))) begin

            `uvm_fatal(get_name(), "unable to find m_smi<%=i%>_tx_vif")
        end
    <% } %>

    //SMI RX interface
    <% for (var i = 0; i < obj.nSmiTx; i++) { %>
        if (!uvm_config_db #(virtual <%=obj.BlockId%>_smi_if)::get(
            .cntxt(this),
            .inst_name(""),
            .field_name("m_smi<%=i%>_rx_vif"),
        .value(m_env_cfg.m_smi<%=i%>_rx_vif))) begin

            `uvm_fatal(get_name(), "unable to find m_smi<%=i%>_rx_vif")
        end
    <% } %>

    if (!uvm_config_db#(virtual <%=obj.BlockId%>_apb_if)::get(.cntxt( this ),
                                        .inst_name( "" ),
                                        .field_name( "m_apb_if" ),
                                        .value(m_env_cfg.m_apb_agent_cfg.m_vif ))) begin
        `uvm_error("dve_ral_built_in_test", "m_apb_if not found")
    end

    //TX ports from TB presepctive
    <% for (var i = 0; i < obj.nSmiRx; i++) { %>
        m_env_cfg.m_smi_agent_cfg.m_smi<%=i%>_tx_port_config =
        smi_port_config::type_id::create("m_smi<%=i%>_tx_port_config");

        m_env_cfg.m_smi_agent_cfg.m_smi<%=i%>_tx_port_config.m_vif = m_env_cfg.m_smi<%=i%>_tx_vif;
    <% } %>

    //RX ports from TB presective
    <% for (var i = 0; i < obj.nSmiTx; i++) { %>
        m_env_cfg.m_smi_agent_cfg.m_smi<%=i%>_rx_port_config =
        smi_port_config::type_id::create("m_smi<%=i%>_rx_port_config");

        m_env_cfg.m_smi_agent_cfg.m_smi<%=i%>_rx_port_config.m_vif = m_env_cfg.m_smi<%=i%>_rx_vif;
    <% } %>

    uvm_config_db#(smi_agent_config)::set(
      .cntxt(null),
      .inst_name("*"),
      .field_name("smi_agent_config"),
      .value(m_env_cfg.m_smi_agent_cfg)
    );

    // Get command line args
//    m_dve_unit_args = dve_unit_args::type_id::create("m_dve_unit_args");

    // Put the env config object into configuration database.
    uvm_config_db#(dve_env_config)::set(
      .cntxt(null),
      .inst_name("*"),
      .field_name("dve_env_config"),
      .value(m_env_cfg)
    );
  
    //Create the env
    m_dve_env = dve_env::type_id::create("m_dve_env", this);

    if(!$value$plusargs("k_timeout_us=%0d", m_timeout_us))
        m_timeout_us = 1s; 

    if($test$plusargs("no_smi_delay")) begin
    <% for (var i = 0; i < obj.nSmiTx; i++) { %>
      m_env_cfg.m_smi_agent_cfg.m_smi<%=i%>_rx_port_config.k_delay_min.set_value(0);
      m_env_cfg.m_smi_agent_cfg.m_smi<%=i%>_rx_port_config.k_delay_max.set_value(0);
      m_env_cfg.m_smi_agent_cfg.m_smi<%=i%>_rx_port_config.k_burst_pct.set_value(100);
    <% } %>
    <% for (var i = 0; i < obj.nSmiRx; i++) { %>
      m_env_cfg.m_smi_agent_cfg.m_smi<%=i%>_tx_port_config.k_delay_min.set_value(0);
      m_env_cfg.m_smi_agent_cfg.m_smi<%=i%>_tx_port_config.k_delay_max.set_value(0);
      m_env_cfg.m_smi_agent_cfg.m_smi<%=i%>_tx_port_config.k_burst_pct.set_value(100);
    <% } %>
    end // if ($test$plusargs("no_smi_delay"))

    <% if (obj.useResiliency) { %>
      <% if (obj.testBench != "fsys") { %>
        if($test$plusargs("expect_mission_fault")) begin
          fault_injector_checker_demoter_h = report_catcher_demoter_base::type_id::create("fault_injector_checker_demoter_h");
          fault_injector_checker_demoter_h.exp_id = {"fault_injector_checker"};
          fault_injector_checker_demoter_h.not_of = 1;
          if($test$plusargs("expect_mission_fault_cov")) begin
            fault_injector_checker_demoter_h.demote_uvm_fatal = 1;
            m_env_cfg.disable_sb();
          end
          fault_injector_checker_demoter_h.build();
          `uvm_info(get_name(), $sformatf("Registering demoter class{%0s} for resiliency error ignore", fault_injector_checker_demoter_h.get_name()), UVM_LOW)
          uvm_report_cb::add(null, fault_injector_checker_demoter_h);
        end
      <% } %>
      // This event triggers if any request is killed when injecting errors
      // to drop all objections and get out of run_phase, resolves hanging tests issue
     <% if(obj.testBench == 'dve') { %>
     `ifdef VCS
      if (!uvm_config_db#(uvm_event)::get(this,.inst_name ( "" ),.field_name( "kill_test" ),.value( kill_test ))) begin
         `uvm_error( "dve_bringup_test run_phase", "kill_test event not found" )
      end else begin
         `uvm_info( "dve_bringup_test run_phase", "kill_test event found",UVM_DEBUG)
          if(kill_test==null)
            `uvm_error( "dve_bringup_test run_phase", "kill_test event is null" )
      end
     `endif 
     <% } %>  
    <% } %>
    if(!uvm_config_db#(virtual dve_csr_probe_if )::get(null, get_full_name(), "u_csr_probe_if",u_csr_probe_vif)) begin
    `uvm_error({"fault_injector_checker_", get_name()},{"virtual interface must be set  for :",get_full_name(),".vif"})
 end endfunction // build_phase

  function void check_phase(uvm_phase phase);
    int inj_cntl;
    super.check_phase(phase);
<%  if (obj.useResiliency) { %>
    if (!(inj_cntl > 1) && !($test$plusargs("inject_cmd_trgt_id_err") || $test$plusargs("inject_dtw_trgt_id_err") || $test$plusargs("inject_snp_trgt_id_err") || $test$plusargs("inject_str_trgt_id_err") ||  $test$plusargs("inject_sys_trgt_id_err")) && m_dve_env.m_dve_sb.num_smi_uncorr_err == 0 && m_dve_env.m_dve_sb.num_smi_parity_err == 0 && m_dve_env.m_dve_sb.seen_single_errors == 0 && m_dve_env.m_dve_sb.seen_double_errors == 0 && !($test$plusargs("uncorr_error_inj_pcnt") || $test$plusargs("parity_error_inj_pcnt") || $test$plusargs("test_unit_duplication") || $test$plusargs("enable_errors") || smi_rx_stall_en)) begin
      if (u_csr_probe_vif.fault_mission_fault !== 0) begin
        `uvm_error(get_full_name(),"mission fault should be zero at the end of the test for no error injection")
      end
      if (u_csr_probe_vif.fault_latent_fault !== 0) begin
        `uvm_error(get_full_name(),"latent fault should be zero at the end of the test for no error injection")
      end
    end
<% } %>
  endfunction

  function void end_of_elaboration_phase(uvm_phase phase);
    super.end_of_elaboration_phase(phase);
    uvm_top.set_timeout(m_timeout_us);
  endfunction // end_of_elaboration_phase

  task run_phase(uvm_phase phase);

    super.run_phase(phase);
    `uvm_info(name, "run_phase", UVM_NONE);

    csr_init_seq = dve_csr_init_seq::type_id::create("csr_init_seq");
    csr_init_seq.model = m_dve_env.m_regs;

    m_dve_seq = dve_seq::type_id::create("m_dve_seq");
    m_dve_seq.m_smi_virtual_seqr = m_dve_env.m_smi_agent.m_smi_virtual_seqr;
//    m_dve_seq.m_dve_unit_args = m_dve_unit_args;

   <% if(obj.useResiliency) { %>
     fork
       begin
         <% if((obj.testBench != "fsys") && (obj.INHOUSE_APB_VIP)) { %>
         if($test$plusargs("check_corr_error_cnt")) begin
           res_corr_err_threshold_seq res_crtr_seq = res_corr_err_threshold_seq::type_id::create("res_crtr_seq");
           res_crtr_seq.model = m_dve_env.m_regs;
           res_crtr_seq.start(m_dve_env.m_apb_agent.m_apb_sequencer);
         end
         <% } %>
       end
       if ($test$plusargs("expect_mission_fault")) begin
         if(!$test$plusargs("test_unit_duplication")) begin
           begin
             forever begin
               phase.raise_objection(this, "dve_uncorr_error_bringup_test");
               `uvm_info(get_name(),"raised_objection::uncorr", UVM_DEBUG);
               #(100*1ns);
               if (u_csr_probe_vif.fault_mission_fault == 0) begin
                  @u_csr_probe_vif.fault_mission_fault;
               end
               phase.drop_objection(this, "dve_uncorr_error_bringup_test");
               `uvm_info(get_name(),"dropped_objection::uncorr", UVM_DEBUG);
               if($test$plusargs("expect_mission_fault_cov"))begin
                 //repeat(10000) @(negedge u_csr_probe_vif.clk);
                 #1ms; // keep testcase timeout higher than this to avoid hearbeat failure
               end
               #(100*1ns);
               `uvm_info($sformatf("%m"), $sformatf("<%=obj.BlockId%> saw mission fault. Kill test"), UVM_NONE)
               <% if(obj.testBench == 'dve') { %>
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
       begin
          `uvm_info("run_main", "waiting for kill_test event to trigger",UVM_NONE)
        if(m_env_cfg.has_sb)
          @m_dve_env.m_dve_sb.kill_test;
        else
          <% if(obj.testBench == 'dve') { %>
          `ifndef VCS
           @kill_test;
          `else // `ifndef VCS
           kill_test.wait_trigger();
          `endif // `ifndef VCS ... `else ... 
          <% } else {%>
          @kill_test;
          <% } %>

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
     join_none
   <% } %>
      phase.raise_objection(this, "csr_init");
      `uvm_info(name, "Start CSR init", UVM_NONE)
      csr_init_seq.start(m_dve_env.m_apb_agent.m_apb_sequencer);
      phase.drop_objection(this, "csr_init");
    //Perf monitor
    main_seq_pre_hook(phase); // virtual task
    for(int i=0;i<main_seq_iter;i++) begin:forloop_main_seq_iter // by default main_seq_iter=1
      main_seq_iter_pre_hook(phase,i); // virtual task

      phase.raise_objection(this, "dve_bringup_test");
      `uvm_info(name, "Start DVE sequence", UVM_NONE)
        if (!smi_rx_stall_en) begin
          m_dve_seq.m_regs = m_dve_env.m_regs; 
          m_dve_seq.start(null);
        end 
      `uvm_info(name, "Done DVE sequence", UVM_NONE)

      phase.phase_done.set_drain_time(this,50us);
      phase.drop_objection(this, "dve_bringup_test");
      main_seq_iter_post_hook(phase,i); // virtual task
   end:forloop_main_seq_iter
   main_seq_post_hook(phase); // virtual task

   main_seq_hook_end_run_phase(phase);// virtual task
  endtask // run_phase


 
    



  function void report_phase(uvm_phase phase);
    uvm_report_server urs;
    int uvm_err_cnt, uvm_fatal_cnt;
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

      tb_res_smi_corr_err = m_dve_env.m_dve_sb.res_smi_corr_err;
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

    urs = uvm_report_server::get_server();
    uvm_err_cnt = urs.get_severity_count(UVM_ERROR);
    uvm_fatal_cnt = urs.get_severity_count(UVM_FATAL);

    if((uvm_err_cnt != 0) || (uvm_fatal_cnt != 0))
      `uvm_info(name, "\n ============ \n UVM FAILED!\n ============", UVM_NONE)
    else
      `uvm_info(name, "\n ============ \n UVM PASSED!\n ============", UVM_NONE)
  endfunction // report_phase
endclass // dve_bringup_test

/*
 *creating a stand alone testcase as testing for the features
 *related to unit duplication is done using force mechanism.
 */
class resiliency_unitduplication_test extends dve_bringup_test;

  `uvm_component_utils(resiliency_unitduplication_test)
 <% if(obj.testBench == 'dve') { %>
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
    m_env_cfg.disable_sb();
  endfunction : build_phase

  virtual task run_phase(uvm_phase phase);

 <% if(obj.testBench == 'dve') { %>
  `ifndef VCS
    if(!uvm_config_db#(event)::get(this, "", "raise_obj_for_resiliency_test", raise_obj_for_resiliency_test)) begin
      `uvm_error( "dve_test run_phase", "raise_obj_for_resiliency_test event not found" )
    end

    if(!uvm_config_db#(event)::get(this, "", "drop_obj_for_resiliency_test", drop_obj_for_resiliency_test)) begin
      `uvm_error( "dve_test run_phase", "drop_obj_for_resiliency_test event not found" )
    end
  `else // `ifndef VCS
    if(!uvm_config_db#(uvm_event)::get(this, "", "raise_obj_for_resiliency_test", raise_obj_for_resiliency_test)) begin
      `uvm_error( "dve_test run_phase", "raise_obj_for_resiliency_test event not found" )
    end

    if(!uvm_config_db#(uvm_event)::get(this, "", "drop_obj_for_resiliency_test", drop_obj_for_resiliency_test)) begin
      `uvm_error( "dve_test run_phase", "drop_obj_for_resiliency_test event not found" )
    end
  `endif // `ifndef VCS ... `else ... 
 <% } else {%>
    if(!uvm_config_db#(event)::get(this, "", "raise_obj_for_resiliency_test", raise_obj_for_resiliency_test)) begin
      `uvm_error( "dve_test run_phase", "raise_obj_for_resiliency_test event not found" )
    end

    if(!uvm_config_db#(event)::get(this, "", "drop_obj_for_resiliency_test", drop_obj_for_resiliency_test)) begin
      `uvm_error( "dve_test run_phase", "drop_obj_for_resiliency_test event not found" )
    end
 <% } %>

    phase.raise_objection(this, $sformatf("raise_objection from{%0s} in phase{%0s}",this.get_name(), phase.get_domain_name()));
    fork
      begin
        `uvm_info("run_main", "Waiting for random time units 2us", UVM_NONE)
        #2us;
      end
      begin
<% if(obj.testBench == 'dve') { %>
`ifndef VCS
         `uvm_info("run_main", "waiting for raise_obj_for_resiliency_test event to trigger",UVM_NONE)
         @raise_obj_for_resiliency_test;
         `uvm_info("run_main", "raise_obj_for_resiliency_test event triggered",UVM_NONE)
         phase.raise_objection(this, "raising objection for resiliency test");
 
         @drop_obj_for_resiliency_test;
         phase.drop_objection(this, "dropping resiliency test objection");
`else //`ifndef VCS
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

