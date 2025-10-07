
`ifndef <%=obj.BlockId%>_BASE_TEST
`define <%=obj.BlockId%>_BASE_TEST

import common_knob_pkg::*;

<% if(obj.testBench == 'dii') { %>
 `ifdef VCS 
// Add for UVM-1.2 compatibility
class dii_report_server extends uvm_default_report_server;

   function new(string name = "dii_report_server");
    super.new();
   endfunction
 
   virtual function void report_summarize(UVM_FILE file = 0);
   uvm_report_server svr;
    string id;
    string name;
    string output_str;
    string q[$],q2[$];
    int m_max_quit_count,m_quit_count;
    int m_severity_count[uvm_severity];
    int m_id_count[string];
    bit enable_report_id_count_summary =1 ;
    uvm_severity q1[$];

    svr = uvm_report_server::get_server();
    m_max_quit_count = get_max_quit_count();
    m_quit_count = get_quit_count();

    svr.get_id_set(q2);
    foreach(q2[s])
      m_id_count[q2[s]] = svr.get_id_count(q2[s]);

    svr.get_severity_set(q1);
    foreach(q1[s])
      m_severity_count[q1[s]] = svr.get_severity_count(q1[s]);


    uvm_report_catcher::summarize();
    q.push_back("\n--- UVM Report Summary ---\n\n");

    if(m_max_quit_count != 0) begin
      if ( m_quit_count >= m_max_quit_count )
        q.push_back("Quit count reached!\n");
      q.push_back($sformatf("Quit count : %5d of %5d\n",m_quit_count, m_max_quit_count));
    end

    q.push_back("** Report counts by severity\n");
    foreach(m_severity_count[s]) begin
      q.push_back($sformatf("%s :%5d\n", s.name(), m_severity_count[s]));
    end

    if (enable_report_id_count_summary) begin
      q.push_back("** Report counts by id\n");
      foreach(m_id_count[id])
        q.push_back($sformatf("[%s] %5d\n", id, m_id_count[id]));
    end

    `uvm_info("UVM/REPORT/SERVER",`UVM_STRING_QUEUE_STREAMING_PACK(q),UVM_NONE)

  endfunction


endclass
`endif 
<% }  %>


//Display outstanding objections upon hbfail.
class timeout_catcher extends uvm_report_catcher;
    uvm_phase phase;

    `uvm_object_utils(timeout_catcher)

<% if(obj.testBench == 'dii') { %>
 `ifdef CDNS
    function new(string name = "timeout_catcher");
        super.new(name);
    endfunction: new
 `endif 
<% }  %>
    function action_e catch();
        if(get_severity() == UVM_FATAL && get_id() == "HBFAIL") begin
            uvm_objection obj = phase.get_objection();
            `uvm_info("HBFAIL","HBFAIL : objections : ",UVM_NONE)
            obj.display_objections();
            `uvm_error("HBFAIL", $psprintf("Heartbeat failure!"));
        end
        return THROW;
    endfunction

endclass


////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////
//
// DII Test Base
//
////////////////////////////////////////////////////////////////////////////////
class dii_base_test extends uvm_test;

  `macro_perf_cnt_test_all_declarations

`ifdef INHOUSE_AXI
   axi_memory_model m_axi_memory_model;
`endif

  addr_trans_mgr    m_addr_mgr ;
  
  dii_env           m_env;
  dii_env_config    m_env_cfg;
  dii_args          m_args;

 <% if(obj.testBench == "dii" || obj.testBench == "cust_tb") { %> 
   <%=obj.DiiInfo[obj.Id].strRtlNamePrefix%>_concerto_register_map_pkg::ral_sys_ncore m_regs;
<%} else if(obj.testBench == "fsys" || obj.testBench == "emu") { %>
   concerto_register_map_pkg::ral_sys_ncore m_regs;
<% } %>


  uvm_report_server urs;
  int               error_count;
  int               fatal_count;
  bit               buffer_sel;
<%//if (obj.useResiliency) { %>
  virtual <%=obj.DiiInfo[obj.Id].strRtlNamePrefix%>_dii_csr_probe_if u_csr_probe_vif;
<% //} %>
`ifdef USE_VIP_SNPS
axi_slave_mem_response_sequence m_axi_slave_mem_response_sequence;
`endif // USE_VIP_SNPS

////////////////////////////////////////////////////////////////////////
//
// Functions
//
////////////////////////////////////////////////////////////////////////

  extern function new(string name = "dii_base_test", uvm_component parent = null);
  extern virtual function void build_phase(uvm_phase phase);
  extern virtual function void connect_phase(uvm_phase phase);
  extern virtual function void start_of_simulation_phase(uvm_phase phase);
  extern virtual function void check_phase(uvm_phase phase);
  extern virtual function void report_phase(uvm_phase phase);
  extern virtual function void run_report(uvm_phase phase);

  extern virtual task reset_phase(uvm_phase phase);
  extern virtual task check_register();

  //the heartbeat monitor watches for scoreboard activity which toggles an objection.
  function void heartbeat(uvm_phase phase, int k_timeout, bit dii_scb_en);
    uvm_phase run_phase;
    uvm_event e;
    timeout_catcher catcher;
    uvm_callbacks_objection cb;
    uvm_component comp_q[$];
    uvm_heartbeat hb;

    e = new("e");
    run_phase = phase.find_by_name("run", 0);
    catcher            = timeout_catcher::type_id::create("catcher", this);
    catcher.phase      = run_phase;
    uvm_report_cb::add(null, catcher);
    
    if(!$cast(cb, run_phase.get_objection()))
        `uvm_fatal("Run", "run phase objection type isn't of type uvm_callbacks_objection. you need to define UVM_USE_CALLBACKS_OBJECTION_FOR_TEST_DONE!");

    hb = new("activity_heartbeat", this, cb);
    uvm_top.find_all("*", comp_q, this);
    hb.set_mode(UVM_ANY_ACTIVE);
    hb.set_heartbeat(e, comp_q);

    fork begin
        forever
            #(k_timeout*1ns) e.trigger();
    end
    join_none
  endfunction: heartbeat


endclass: dii_base_test



//------------------------------------------------------------------------------
// Constructor
//------------------------------------------------------------------------------
function dii_base_test::new(string name = "dii_base_test", uvm_component parent = null);
  super.new(name, parent);
endfunction : new

//------------------------------------------------------------------------------
// Build Phase
//------------------------------------------------------------------------------

function void dii_base_test::build_phase(uvm_phase phase);
    string arg_value;
    bit reuse_q_flag = 0;
    bit flag = 0;
    bit useMemRspIntrlv = 0;

    super.build_phase(phase);

    //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    //construct configs in hier

    //construct the toplevel cfg
    m_env_cfg = dii_env_config::type_id::create("m_env_cfg", this);
    m_env = dii_env::type_id::create("m_env", this);
    this.m_regs = m_env.m_regs; 
    //put in cfg db
    uvm_config_db#(dii_env_config)::set(
        .cntxt( this ),
        .inst_name( "*" ),
        .field_name( "dii_env_config" ),
        .value( m_env_cfg ) 
    ); 

    //construct sub configs in a hier
    m_env_cfg.m_smi_agent_cfg      = smi_agent_config::type_id::create("m_smi_agent_cfg",  this);

<%for (var i = 0; i < obj.DiiInfo[obj.Id].nSmiRx; i++) { %>
        m_env_cfg.m_smi_agent_cfg.m_smi<%=i%>_tx_port_config = smi_port_config::type_id::create("m_smi<%=i%>_tx_port_config",this); ;
        m_env_cfg.m_smi_agent_cfg.m_smi<%=i%>_tx_port_config.delay_export  = 0;
<% } %>

<%for (var i = 0; i < obj.DiiInfo[obj.Id].nSmiTx; i++) { %>
        m_env_cfg.m_smi_agent_cfg.m_smi<%=i%>_rx_port_config = smi_port_config::type_id::create("m_smi<%=i%>_rx_port_config",this); ;
<% } %>

        m_env_cfg.m_axi_slave_agent_cfg      = axi_agent_config::type_id::create("m_axi_slave_agent_cfg",  this);

        m_env_cfg.m_dii_rtl_agent_cfg      = dii_rtl_agent_config::type_id::create("m_dii_rtl_agent_config",  this);
       `ifndef USE_VIP_SNPS_APB
        m_env_cfg.m_apb_agent_cfg      = apb_agent_config::type_id::create("m_apb_agent_config",  this);
       `endif
        m_env_cfg.m_q_chnl_agent_cfg      = q_chnl_agent_config::type_id::create("m_q_chnl_agent_config",  this);
    
            //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    //construct dv components
    m_addr_mgr = addr_trans_mgr::get_instance();
    m_addr_mgr.gen_memory_map();

    `ifdef INHOUSE_AXI
    m_axi_memory_model = new();
    `endif
    
   // m_regs = ral_sys_ncore::type_id::create("ral_sys_ncore", this);
   // m_regs.build(); 
   // m_regs.lock_model();

 `ifdef USE_VIP_SNPS

  m_env_cfg.m_dii_amba_env_config = dii_amba_env_config::type_id::create("m_dii_amba_env_config");
  m_env_cfg.m_dii_amba_env_config.set_amba_env_config();


  // Apply the configuration to the AMBA System ENV 
uvm_config_db#(svt_amba_system_configuration)::set(this, "m_env.amba_system_env", "cfg",  m_env_cfg.m_dii_amba_env_config);


`endif // !`ifdef USE_VIP_SNPS    
`ifdef USE_VIP_SNPS_APB
uvm_config_db#(uvm_reg_block)::set(this, "m_env.amba_system_env.apb_system[0].master", "apb_regmodel", m_regs);
`endif 
    
    //associate interfaces with configs
    <%for (var i = 0; i < obj.DiiInfo[obj.Id].nSmiRx; i++) { %>
    if (!uvm_config_db#(virtual <%=obj.DiiInfo[obj.Id].strRtlNamePrefix%>_smi_if)::get(.cntxt( this ),
                                            .inst_name( "" ),
                                            .field_name( "m_smi<%=i%>_tx_smi_if" ),
                                            .value( m_env_cfg.m_smi_agent_cfg.m_smi<%=i%>_tx_port_config.m_vif ))) begin
        `uvm_error($sformatf("%m"), "m_smi<%=i%>_tx_port_if not found")
    end
    <% } %>
    
    <%for (var i = 0; i < obj.DiiInfo[obj.Id].nSmiTx; i++) { %>
    if (!uvm_config_db#(virtual <%=obj.DiiInfo[obj.Id].strRtlNamePrefix%>_smi_if)::get(.cntxt( this ),
                                            .inst_name( "" ),
                                            .field_name( "m_smi<%=i%>_rx_smi_if" ),
                                            .value( m_env_cfg.m_smi_agent_cfg.m_smi<%=i%>_rx_port_config.m_vif ))) begin
        `uvm_error($sformatf("%m"), "m_smi<%=i%>_rx_port_if not found")
    end
    <% } %>



    if (!uvm_config_db#(virtual <%=obj.DiiInfo[obj.Id].strRtlNamePrefix%>_axi_if)::get(.cntxt( this ),
                                        .inst_name( "" ),
                                        .field_name( "m_<%=obj.DiiInfo[obj.Id].strRtlNamePrefix%>_axi_slv_if" ),
                                        .value(m_env_cfg.m_axi_slave_agent_cfg.m_vif ))) begin
        `uvm_error("dii_env", "m_<%=obj.BlockId%>_axi_slv_if not found")
    end



    if (!uvm_config_db#(virtual <%=obj.DiiInfo[obj.Id].strRtlNamePrefix%>_dii_rtl_if)::get(.cntxt( this ),
                                        .inst_name( "" ),
                                        .field_name( "m_dii_rtl_if" ),
                                        .value(m_env_cfg.m_dii_rtl_agent_cfg.m_vif ))) begin
        `uvm_error("dii_env", "m_dii_rtl_if not found")
    end
    `ifndef USE_VIP_SNPS_APB
    if (!uvm_config_db#(virtual <%=obj.DiiInfo[obj.Id].strRtlNamePrefix%>_apb_if)::get(.cntxt( this ),
                                        .inst_name( "" ),
                                        .field_name( "m_apb_if" ),
                                        .value(m_env_cfg.m_apb_agent_cfg.m_vif ))) begin
        `uvm_error("dii_env", "m_apb_if not found")
    end
    `endif
    if (!uvm_config_db#(virtual <%=obj.BlockId%>_q_chnl_if)::get(.cntxt( this ),
                                        .inst_name( "" ),
                                        .field_name( "m_q_chnl_if" ),
                                        .value(m_env_cfg.m_q_chnl_agent_cfg.m_vif ))) begin
        `uvm_error("dii_env", "m_q_chnl_if not found")
    end

    //Get command-line args
    m_args = dii_args::type_id::create("m_args");
    m_args.grab_and_parse_args_from_cmdline(m_env_cfg);

    //configure smi
    m_env_cfg.m_smi_agent_cfg.active = UVM_ACTIVE;
    m_env_cfg.m_smi_agent_cfg.cov_en = m_args.k_smi_cov_en;

    <%for (var i = 0; i < obj.DiiInfo[obj.Id].nSmiRx; i++) { %>
    m_env_cfg.m_smi_agent_cfg.m_smi<%=i%>_tx_port_config.delay_export  = 0;
    <% } %>
    <%for (var i = 0; i < obj.DiiInfo[obj.Id].nSmiTx; i++) { %>
    m_env_cfg.m_smi_agent_cfg.m_smi<%=i%>_rx_port_config.delay_export  = 0;
    <% } %>

    m_env_cfg.m_axi_slave_agent_cfg.delay_export = 1;

`ifdef USE_VIP_SNPS
    m_env_cfg.m_axi_slave_agent_cfg.active  = UVM_PASSIVE;
`else
   m_env_cfg.m_axi_slave_agent_cfg.active  = UVM_ACTIVE;
 `endif

<%//if (obj.useResiliency) { %>
    if(!uvm_config_db#(virtual <%=obj.DiiInfo[obj.Id].strRtlNamePrefix%>_dii_csr_probe_if )::get(null, get_full_name(), "u_csr_probe_if",u_csr_probe_vif)) begin
        `uvm_error("NOVIF",{"virtual interface must be set  for :",get_full_name(),".vif"})
    end
<% //} %>


endfunction : build_phase


function void dii_base_test::connect_phase(uvm_phase phase);
   super.connect_phase(phase);

   /* m_regs.default_map.set_auto_predict(0);
    `ifndef USE_VIP_SNPS_APB
    m_regs.default_map.set_sequencer(.sequencer(m_env.m_apb_agent.m_apb_sequencer), .adapter(m_env.m_apb_agent.m_apb_reg_adapter));
   `endif */
endfunction : connect_phase




//------------------------------------------------------------------------------
// Start Of Simulation Phase
//------------------------------------------------------------------------------
function void dii_base_test::start_of_simulation_phase(uvm_phase phase);
    
  <% if(obj.testBench == 'dii') { %>
  `ifdef VCS 
  dii_report_server my_server = new();
   `endif
  <% } %>
  
    super.start_of_simulation_phase(phase);

    <% if(obj.testBench == 'dii') { %>
  `ifdef VCS 
    uvm_report_server::set_server( my_server );
  `endif
  <% } %>
    
    heartbeat(phase,m_args.k_timeout,m_args.dii_scb_en);

    if (this.get_report_verbosity_level() > UVM_LOW) begin
        uvm_top.print_topology();
    end

    $display("$get_initial_random_seed()=%0d", $get_initial_random_seed());
    
   
    //Read data buffer error injection
<% 
if (obj.useExternalMemoryFifo) {
    if(obj.fnErrDetectCorrect != "NONE") {
%>
<%  } else { //if(obj.fnErrDetectCorrect != "NONE")  %>
    `uvm_warning($sformatf("%m"), "read data buffer error injection Ignored.  Protection is disabled on ext ram.")
<%  
    } 
} else { //if (obj.useExternalMemoryFifo)
%>
    `uvm_warning($sformatf("%m"), "read data buffer error injection Ignored.  Protection unsupported on int ram.")
<% } %>
    

endfunction : start_of_simulation_phase

task dii_base_test::reset_phase(uvm_phase phase);
    super.reset_phase(phase);
<% 
    if (obj.DiiInfo[obj.Id].useExternalMemory) {
        if(obj.DiiInfo[obj.Id].fnErrDetectCorrect.substring(0,6) != "NONE") {
    %>
           if ($test$plusargs("inject_sram_single_err")) begin
               tb_top.dut.u_readDataMem.internal_mem_inst.inject_errors(m_args.k_sram_single_err_pct.get_value(),0,0);
               tb_top.dut.u_readDataMem.internal_mem_inst.inject_single_error();
               $display("Single bit error injection enabled in SRAM");
           end
            if ($test$plusargs("inject_sram_double_err")) begin
               tb_top.dut.u_readDataMem.internal_mem_inst.inject_errors(0,m_args.k_sram_double_err_pct.get_value(),0);
               tb_top.dut.u_readDataMem.internal_mem_inst.inject_double_error();
               $display("Double bit error injection enabled in SRAM");
           end    
           if ($test$plusargs("inject_sram_multi_blk_single_double_error")) begin
               tb_top.dut.u_readDataMem.internal_mem_inst.inject_errors(m_args.k_sram_single_err_pct.get_value(),m_args.k_sram_double_err_pct.get_value(),1);
               tb_top.dut.u_readDataMem.internal_mem_inst.inject_multi_blk_single_double_error();
               $display("inject_multi_blk_single_double_error");
           end

           if ($test$plusargs("inject_sram_multi_blk_double_error")) begin
               tb_top.dut.u_readDataMem.internal_mem_inst.inject_errors(0,m_args.k_sram_double_err_pct.get_value(),1);
               tb_top.dut.u_readDataMem.internal_mem_inst.inject_multi_blk_double_error();
               $display("inject_multi_blk_double_error");
           end


           if ($test$plusargs("inject_sram_multi_blk_single_error")) begin
               tb_top.dut.u_readDataMem.internal_mem_inst.inject_errors(m_args.k_sram_single_err_pct.get_value(),0,1);
               tb_top.dut.u_readDataMem.internal_mem_inst.inject_multi_blk_single_error();
               $display("inject_multi_blk_single_error");
           end
    
    <%  } else { //if(obj.fnErrDetectCorrect != "NONE")  %>
        `uvm_warning($sformatf("%m"), "read data buffer error injection Ignored.  Protection is disabled on ext ram.")
    <%  
        } 
    } else { //if (obj.useExternalMemoryFifo)
    %>
        `uvm_warning($sformatf("%m"), "read data buffer error injection Ignored.  Protection unsupported on int ram.")
    <% } %>


    <% if((obj.DiiInfo[obj.Id].CMDOverflowBufInSRAM == true) &&  (obj.DiiInfo[obj.Id].fnErrDetectCorrect.substring(0,6) != "NONE")) { %>

         if ($test$plusargs("inject_sram_skid_double_err")) begin
           buffer_sel = $urandom_range(0,1);
           u_csr_probe_vif.inject_double_error(buffer_sel); //#Stimulus.DII.Concerto.v3.7.UncorrectableError
           `uvm_info("SKIDBUFERROR","Double bit error injection enabled in SRAM skid buffer from reset_phase",UVM_HIGH);
         end  
     
         if ($test$plusargs("inject_sram_skid_addr_err")) begin
           buffer_sel = $urandom_range(0,1);
           u_csr_probe_vif.inject_addr_error(buffer_sel);
           `uvm_info("SKIDBUFERROR","Address error injection enabled in SRAM skid buffer from reset_phase",UVM_HIGH);
         end  

        <% if((obj.DiiInfo[obj.Id].fnErrDetectCorrect.substring(0,6) == "PARITY")) { %>

          if ($test$plusargs("inject_sram_skid_single_err")) begin
            buffer_sel = $urandom_range(0,1);
            u_csr_probe_vif.inject_single_error(buffer_sel);
            `uvm_info("SKIDBUFERROR","Single bit error injection enabled in SRAM skid buffer with PARITY protection from reset_phase",UVM_HIGH);
          end

        <% } %>

    <% } %> 
    
endtask : reset_phase

//------------------------------------------------------------------------------
// check Phase
//------------------------------------------------------------------------------
function void dii_base_test::check_phase(uvm_phase phase);
  <% if(obj.useResiliency) { %>
  int scb_en;
  int inj_cntl;
  int res_corr_err_threshold;
  bit patch_conc_7033, patch_conc_7597;
  int tolerance_range_low_val, tolerance_range_high_val, res_corr_err_tolerance_cnt;
  int tb_res_smi_corr_err, rtl_res_smi_corr_err, mod_res_smi_corr_err, rtl_res_smi_corr_thresh;

  if (! $value$plusargs("dii_scb_en=%d", scb_en)) begin
     scb_en = 1;
  end
  if (scb_en == 0) return;

  if (!(inj_cntl > 1) && m_env.m_scb.num_smi_uncorr_err == 0 && m_env.m_scb.num_smi_parity_err == 0 && !($test$plusargs("wt_wrong_dut_id_cmd") || $test$plusargs("wt_wrong_dut_id_dtw") || $test$plusargs("wt_wrong_dut_id_strrsp") || $test$plusargs("wt_wrong_dut_id_dtrrsp")) && !($test$plusargs("uncorr_error_inj_pcnt") || $test$plusargs("parity_error_inj_pcnt") || $test$plusargs("test_unit_duplication") || $test$plusargs("uncorr_skid_buffer_test"))) begin
    if (u_csr_probe_vif.fault_mission_fault !== 0) begin
      `uvm_error(get_full_name(),"mission fault should be zero for no error injection")
    end
    if (u_csr_probe_vif.fault_latent_fault !== 0) begin
      `uvm_error(get_full_name(),"latent fault should be zero for no error injection")
    end
  end
  <% if ((obj.testBench != "fsys")) { %>
  if(($test$plusargs("inj_cntl")) && 
     ($test$plusargs("smi_ndp_err_inj") ||
      $test$plusargs("smi_hdr_err_inj") ||
      $test$plusargs("smi_dp_ecc_inj")) &&
      $test$plusargs("check_corr_error_cnt")
    )
  begin
    patch_conc_7033 = 1; // TODO: disabled if CONC-7033 decides to stop counter at threshold+1

    tb_res_smi_corr_err = m_env.m_scb.res_smi_corr_err;
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
  <% } %>
endfunction: check_phase

//------------------------------------------------------------------------------
// Report Phase
//------------------------------------------------------------------------------
function void dii_base_test::report_phase(uvm_phase phase);
  run_report(phase);
  urs = uvm_report_server::get_server();
  error_count = urs.get_severity_count(UVM_ERROR);
  fatal_count = urs.get_severity_count(UVM_FATAL);
  if ((error_count != 0) | (fatal_count != 0)) begin
    `uvm_info("TEST", "\n===========\nUVM FAILED!\n===========", UVM_NONE);
  end else begin
    `uvm_info("TEST", "\n===========\nUVM PASSED!\n===========", UVM_NONE);
  end
endfunction : report_phase

//------------------------------------------------------------------------------
// Run Report
//------------------------------------------------------------------------------
function void dii_base_test::run_report(uvm_phase phase);
  <% if ((obj.useResiliency) && (obj.testBench != "fsys")) { %>
  int inj_cntl;
  int scb_en;

  if (! $value$plusargs("dii_scb_en=%d", scb_en)) begin
     scb_en = 1;
  end

  if (!$value$plusargs("inj_cntl=%d", inj_cntl) ) begin
     inj_cntl = 0;
  end
  <% if (obj.AiuInfo[0].ResilienceInfo.fnResiliencyProtectionType == "none") { %>
     inj_cntl = 0;
  <% } else { %>
  <%   if (obj.AiuInfo[0].ResilienceInfo.fnResiliencyProtectionType == "parity") { %>
     inj_cntl = inj_cntl & 3'h100;
  <%   } else { %>
     inj_cntl = inj_cntl & 3'h011;
  <%   } %>
  <% } %>
  if($test$plusargs("expect_mission_fault")) begin
    <% if (AiuInfo[0].ResilienceInfo.fnResiliencyProtectionType == "ecc") { %>
    if(inj_cntl ==2) begin
    if (u_csr_probe_vif.fault_mission_fault == 0) begin
      `uvm_error({"fault_injector_checker_",get_name()}, $sformatf({"expect_mission_fault argument is passed from command line & observed mission_fault=%0d"}, u_csr_probe_vif.fault_mission_fault))
    end else begin
      `uvm_info(get_name(), $sformatf({"expect_mission_fault argument is passed from command line & observed mission_fault=%0d"}, u_csr_probe_vif.fault_mission_fault), UVM_LOW)
    end
    end
    <% } else if (AiuInfo[0].ResilienceInfo.fnResiliencyProtectionType == "parity") { %>
    if(inj_cntl == 4) begin
    if (u_csr_probe_vif.fault_mission_fault == 0) begin
      `uvm_error({"fault_injector_checker_",get_name()}, $sformatf({"expect_mission_fault argument is passed from command line & observed mission_fault=%0d"}, u_csr_probe_vif.fault_mission_fault))
    end else if (scb_en == 1) begin
      `uvm_info(get_name(), $sformatf({"expect_mission_fault argument is passed from command line & observed mission_fault=%0d"}, u_csr_probe_vif.fault_mission_fault), UVM_LOW)
    end
    end
    <% } %>
  end
  <% } %>
endfunction : run_report


task dii_base_test::check_register(); 
  uvm_status_e status;
  uvm_reg_data_t actual_value;
  uvm_reg my_register;
  var error_test = 0;
  int scb_en;
  string plusargs[] = {"smi_ndp_err_inj","smi_hdr_err_inj","smi_dp_ecc_inj","inj_cntl","corr_error_inj_pcnt","has_ucerr","inject_smi_uncorr_error","uncorr_error_inj_pcnt","parity_error_inj_pcnt","str_rsp_err_inj","dtr_rsp_err_inj","dtw_req_err_inj","dtw_dbg_rsp_err_inj","res_corr_err_threshold",
  "inject_sram_single_err","k_sram_single_err_pct","k_sram_double_err_pct","native_read_error","native_write_error","32b_asize_err","32b_align_err"};


  <% var has_cerr = 0; // find configs with cerr enabled
  if ((obj.DiiInfo[obj.Id].useExternalMemory == 1 && obj.DiiInfo[obj.Id].fnErrDetectCorrect.substring(0,6) == "SECDED")) {   
    has_cerr = 1;
  }
  %>
  <% var has_ucerr = 0; //  // find configs with ucerr enabled
  if(obj.DiiInfo[obj.Id].fnErrDetectCorrect.substring(0,6) === "SECDED" || obj.DiiInfo[obj.Id].fnErrDetectCorrect.substring(0,6) === "PARITY") { 
    has_ucerr = 1;
  }
  %>

  for(int i=0; i<plusargs.size(); i++) begin
    if($test$plusargs(plusargs[i]))begin
      error_test =1;
      break;
    end
  end

  if (! $value$plusargs("dii_scb_en=%d", scb_en)) begin
    scb_en = 1;
  end

  if(!error_test)begin //check error registers

    <% if(has_cerr || (obj.DiiInfo[obj.Id].ResilienceInfo.fnResiliencyProtectionType === "ecc")) { %> //check correctable error register
      my_register = m_regs.get_reg_by_name("DIIUCESR");

      if (my_register == null) begin
        `uvm_info("REG_CHECK", "DIIUCESR register not found in block",UVM_MEDIUM);
      end else begin

      my_register.read(status, actual_value);
      if (status == UVM_IS_OK && actual_value[0] == 0) begin
        `uvm_info("FIELD_CHECK", $sformatf("DIIUCESR's 'ErrVld' has right value of: %0h", actual_value[0]), UVM_MEDIUM);
      end else begin
        `uvm_error("FIELD_CHECK", "Failed to read DIIUCESR's field 'ErrVld'");
      end
      end
    
    <% } %>

    <% if(has_ucerr || (obj.DiiInfo[obj.Id].ResilienceInfo.fnResiliencyProtectionType === "ecc") || //check uncorrectable error register
          (obj.DiiInfo[obj.Id].ResilienceInfo.fnResiliencyProtectionType === "parity")) { %>
      my_register = m_regs.get_reg_by_name("DIIUUESR");

      if (my_register == null) begin
        `uvm_info("REG_CHECK", "DIIUUESR register not found in block",UVM_MEDIUM);
      end else begin

      my_register.read(status, actual_value);
      if (status == UVM_IS_OK && actual_value[0] == 0) begin
        `uvm_info("FIELD_CHECK", $sformatf("DIIUUESR's 'ErrVld' has right value of: %0h", actual_value[0]), UVM_MEDIUM);
      end else begin
        `uvm_error("FIELD_CHECK", "Failed to read DIIUUESR's field 'ErrVld'");
      end
      end
    
    <% } %>
  end

  if(scb_en) begin  
    if(!$test$plusargs("cmd_throttle")) begin
      my_register = m_regs.get_reg_by_name("DIIUTAR"); // check activity register

      if (my_register == null) begin
        `uvm_info("REG_CHECK", "DIIUTAR register not found in block",UVM_MEDIUM);
      end else begin
        my_register.read(status, actual_value);
          if (status == UVM_IS_OK && actual_value == 0) begin
            `uvm_info("FIELD_CHECK", $sformatf("DIIUTAR had right value of: %0h", actual_value), UVM_MEDIUM);
          end else begin
            `uvm_error("FIELD_CHECK", $sformatf("DIIUTAR mismatched with value had actual value of: %0h", actual_value));
          end
      end
    end
  end
  
endtask : check_register




//------------------------------------------------------------------------------
// Run Watchdog Timer
//------------------------------------------------------------------------------
/*task dii_base_test::run_watchdog_timer(uvm_phase phase);
  #(k_timeout*100ns)
  //if (m_env.m_csm.transactionPending()) begin
  //  m_env.m_csm.printPendingTransactions();
  //  `uvm_error("WATCHDOG TIMER", "Some transactions are still pending!!!");
  //end
  run_report(phase);
  `uvm_error("WATCHDOG TIMER", "Test times out!!! Something went wrong!!!");
  `uvm_fatal("WATCHDOG TIMER", "Test times out!!! Something went wrong!!!");
endtask : run_watchdog_timer*/

`endif // DII_BASE_TEST







