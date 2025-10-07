
<%if((obj.testBench !="io_aiu")) {%> 
class perf_cnt_test extends <%=`${(() => {
                                  if (obj.BlockId.includes("dmi")) {return "dmi_test";}
                                  if (obj.BlockId.includes("dve")) {return "dve_bringup_test";}
                                  if (obj.BlockId.includes("dce")) {return "dce_bringup_test";}

                                  if (obj.BlockId.includes("dii")) {return "dii_test";}

                                  if ((obj.AiuInfo[obj.Id].fnNativeInterface.includes('CHI'))) {
                                    return "chi_aiu_bringup_test";}
                                  if  (obj.oldBlockId.includes("ncaiu") || ( (obj.testBench == "fsys" || obj.testBench == "emu") && obj.AiuInfo[obj.Id].strRtlNamePrefix.includes("ncaiu"))){
                                    return "bring_up_test";} 
                                    return "bring_up_test"; // By default  
                                  })()}`%>;

  `uvm_component_utils(perf_cnt_test)

  //!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!                                  
  // !!! some declarations in the parent with the macro `perf_cnt_test_all_declarations in files perf_cnt_unit_defines!!!!
  //!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!                                  
                                  
  function new(string name = "perf_cnt_test", uvm_component parent=null);
    super.new(name,parent);
  endfunction: new

  // UVM PHASE
  extern function void build_phase(uvm_phase phase);
  extern task run_phase (uvm_phase phase);
//  extern task post_shutdown_phase (uvm_phase phase);

  // HOOK task call in the parent class
  extern virtual task main_seq_pre_hook(uvm_phase phase); // before the iteration (outside the iteration loop)
  extern virtual task main_seq_post_hook(uvm_phase phase); // after the iteration (outside the iteration loop)
  extern virtual task main_seq_iter_pre_hook(uvm_phase phase, uint64_type iter); // at the beginning of the iteration(inside the iteration loop)
  extern virtual task main_seq_iter_post_hook(uvm_phase phase, uint64_type iter);// at the end of the iteration (inside the iteration)
  extern virtual task main_seq_hook_end_run_phase(uvm_phase phase);// at the very end of the run_phase 
  extern         task perf_cnt_process_counter(uvm_phase phase); //Will do save,read,compare 
  extern         task check_ott_busy(); // Check that there is no more OTT ongoing

  // PERF CNT FUNCTION
  extern function void perf_counter_stalls(int cnt_id);
  extern function int  get_minimal_stall_count(int cnt_id);
  extern function bit  get_events(int cnt_id, e_count_event event_id);

  // Interfaces
    <%  if( (obj.oldBlockId.includes("ncaiu")) || (obj.BlockId.includes("caiu") && (obj[AgentInfoName][obj.Id].fnNativeInterface == "ACE")) || (obj.BlockId.includes("caiu")) ) { %>     
  virtual <%=obj.BlockId%>_stall_if sb_stall_if;
  <% } else if(obj.BlockId.includes("dii")) { %>
  virtual <%=obj.DiiInfo[obj.Id].strRtlNamePrefix%>_stall_if  sb_stall_if;
  <% } else { %>
  virtual <%=obj.BlockId%>_stall_if sb_stall_if;
  <% } %>
endclass: perf_cnt_test


//METHOD Definitions
///////////////////////////////////////////////////////////////////////////////// 
// #     #  #     #  #     #         ######   #     #     #      #####   #######  
// #     #  #     #  ##   ##         #     #  #     #    # #    #     #  #        
// #     #  #     #  # # # #         #     #  #     #   #   #   #        #        
// #     #  #     #  #  #  #         ######   #######  #     #   #####   #####    
// #     #   #   #   #     #         #        #     #  #######        #  #        
// #     #    # #    #     #         #        #     #  #     #  #     #  #        
//  #####      #     #     #  #####  #        #     #  #     #   #####   #######  
///////////////////////////////////////////////////////////////////////////////// 
function void perf_cnt_test::build_phase(uvm_phase phase);
    perfmon_test = 1'b1;
    super.build_phase(phase);
   
    perf_counters = <%=obj[obj.AgentInfoName][obj.Id].strRtlNamePrefix%>_perf_cnt_units::get_instance();
    uvm_config_db#(<%=obj[obj.AgentInfoName][obj.Id].strRtlNamePrefix%>_perf_cnt_units)::set(null, "", "<%=obj[obj.AgentInfoName][obj.Id].strRtlNamePrefix%>_m_perf_counters", perf_counters);
    m_perf_cnt_sb = <%=obj[obj.AgentInfoName][obj.Id].strRtlNamePrefix%>_perf_counters_scoreboard::type_id::create("<%=obj[obj.AgentInfoName][obj.Id].strRtlNamePrefix%>_m_perf_cnt_sb", this);
    //Pmon 3.4 latency
    <% if (obj.BlockId.includes("dii") || (obj.testBench =="io_aiu") || obj.BlockId.includes("dmi") || (obj.BlockId.includes("aiu") && obj.AiuInfo[obj.Id].fnNativeInterface.includes("CHI"))) {  %>
    m_latency_cnt_sb = <%=obj[obj.AgentInfoName][obj.Id].strRtlNamePrefix%>_latency_counters_scoreboard::type_id::create("<%=obj[obj.AgentInfoName][obj.Id].strRtlNamePrefix%>_m_latency_cnt_sb", this);
      // Bound Interface
    <% } %>
    <%if ((obj.testBench === "fsys" || obj.testBench == "emu") || (obj.AiuInfo[obj.Id].fnNativeInterface.includes('CHI'))){%>
        <%if( (obj.oldBlockId.includes("ncaiu")) ||(obj.oldBlockId.includes("caiu")) || (obj.BlockId.includes("caiu") && (obj[AgentInfoName][obj.Id].fnNativeInterface == "ACE")) || (obj.BlockId.includes("caiu")) ) { %>     
        if (!uvm_config_db#(virtual <%=obj.BlockId%>_stall_if)::get(null, "", "<%=obj.BlockId%>_0_m_top_stall_if", sb_stall_if)) begin
        <% } else if(obj.BlockId.includes("dii")) { %>
        if (!uvm_config_db#(virtual  <%=obj.DiiInfo[obj.Id].strRtlNamePrefix%>_stall_if)::get(null, "", "<%=obj.DiiInfo[obj.Id].strRtlNamePrefix%>_m_top_stall_if", sb_stall_if)) begin
        <% } else { %>
        if (!uvm_config_db#(virtual <%=obj.BlockId%>_stall_if)::get(null, "", "<%=obj.BlockId%>_m_top_stall_if", sb_stall_if)) begin
        <% } %>
            `uvm_fatal("Stall interface error", "virtual interface must be set for stall_if");
        end
    <%} else {%>
        <%if( (obj.oldBlockId.includes("ncaiu")) ||(obj.oldBlockId.includes("caiu")) || (obj.BlockId.includes("caiu") && (obj[AgentInfoName][obj.Id].fnNativeInterface == "ACE")) || (obj.BlockId.includes("caiu")) ) { %>     
          if (!uvm_config_db#(virtual <%=obj.BlockId%>_stall_if)::get(null, "", "<%=obj.BlockId%>_0_m_top_stall_if_0", sb_stall_if)) begin
        <% } else if(obj.BlockId.includes("dii")) { %>
        if (!uvm_config_db#(virtual  <%=obj.DiiInfo[obj.Id].strRtlNamePrefix%>_stall_if)::get(null, "", "<%=obj.DiiInfo[obj.Id].strRtlNamePrefix%>_m_top_stall_if", sb_stall_if)) begin
        <% } else { %>
        if (!uvm_config_db#(virtual <%=obj.BlockId%>_stall_if)::get(null, "", "<%=obj.BlockId%>_m_top_stall_if", sb_stall_if)) begin
        <% } %>
            `uvm_fatal("Stall interface error", "virtual interface must be set for stall_if");
        end
    <%}%>
    <%if (obj.BlockId.includes("dve")) {%>
    if($test$plusargs("captured_dropped_test")) 
      m_dve_env.is_dve_dtwdbg_reader = 1;
    else 
      m_dve_env.is_dve_dtwdbg_reader = 0;
    <%}%>

endfunction : build_phase

task perf_cnt_test::run_phase (uvm_phase phase); 
 // Before start the iteration create & setup all the attributs
  perf_counter_seq = <%=obj[obj.AgentInfoName][obj.Id].strRtlNamePrefix%>_perf_cnt_unit_cfg_seq::type_id::create("perf_cnt_unit_cfg_seq");
  perf_counter_seq.perf_counters = perf_counters;
  <% console.log("zied debgg"+obj.BlockId+"interface"+obj[AgentInfoName][obj.Id].fnNativeInterface)%>
  perf_counter_seq.m_regs = <%=`${(() => {
                                   if (obj.BlockId.includes("dmi")) {return "m_env.m_regs";} 
                                   if (obj.BlockId.includes("dve")) {return "m_dve_env.m_regs";}
                                   if (obj.BlockId.includes("dii")) {return "m_regs";} 
                                   if (obj.BlockId.includes("dce")) {return "m_env.m_regs";}
                                   if (obj.oldBlockId.includes("ncaiu") || (obj.oldBlockId.includes("caiu"))
                                   || (obj.BlockId.includes("caiu") && obj[AgentInfoName][obj.Id].fnNativeInterface == "ACE")
                                   || ( (obj.testBench == "fsys" || obj.testBench == "emu") && obj.AiuInfo[obj.Id].strRtlNamePrefix.includes("ncaiu"))) {
                                       return "mp_env.m_env[0].m_regs";}
                                    if (obj.BlockId.includes("caiu")) {return "m_env.m_regs";}
                               })()}`%>;
   <% if( obj.testBench == "dii") { %>
   perf_counter_enable_seq = <%=obj[obj.AgentInfoName][obj.Id].strRtlNamePrefix%>_perf_cnt_enable_cfg_seq::type_id::create("perf_cnt_enable_cfg_seq");
   perf_counter_enable_seq.perf_counters = perf_counters;
   perf_counter_enable_seq.m_regs = m_regs;
  
   perf_counter_overflow_seq = <%=obj[obj.AgentInfoName][obj.Id].strRtlNamePrefix%>_perf_cnt_overflow_cfg_seq::type_id::create("perf_cnt_overflow_cfg_seq");
   perf_counter_overflow_seq.perf_counters = perf_counters;
   perf_counter_overflow_seq.m_regs = m_regs;


   perf_counter_read_status_seq = <%=obj[obj.AgentInfoName][obj.Id].strRtlNamePrefix%>_perf_cnt_read_status_seq::type_id::create("perf_cnt_read_status_seq");
   perf_counter_read_status_seq.perf_counters = perf_counters;
   perf_counter_read_status_seq.m_regs = m_regs;
  <% } %>
  super.run_phase(phase);
endtask:run_phase

////////////////////////////////////////////////////////////////////////////////////////
// #     #  #######  #######  #    #         #######     #      #####   #    #   #####   
// #     #  #     #  #     #  #   #             #       # #    #     #  #   #   #     #  
// #     #  #     #  #     #  #  #              #      #   #   #        #  #    #        
// #######  #     #  #     #  ###               #     #     #   #####   ###      #####   
// #     #  #     #  #     #  #  #              #     #######        #  #  #          #  
// #     #  #     #  #     #  #   #             #     #     #  #     #  #   #   #     #  
// #     #  #######  #######  #    #  #####     #     #     #   #####   #    #   #####  
////////////////////////////////////////////////////////////////////////////////////////
//////////////////// PRE HOOK                   ////////////
task perf_cnt_test::main_seq_pre_hook(uvm_phase phase);
  `uvm_info(get_name(), "HOOK main_seq_pre_hook", UVM_NONE)
  
  if (! $value$plusargs("main_seq_iter=%d", main_seq_iter)) begin
    if($test$plusargs("overflow_test"))  begin
      main_seq_iter = nPerfCounters;
    end else begin
      main_seq_iter = 1;
    end
  end
endtask:main_seq_pre_hook

////////////////////////////////////////////////////////////
//////////////////// PRE HOOK in ITERATION loop ////////////
task perf_cnt_test::main_seq_iter_pre_hook(uvm_phase phase, uint64_type iter);
  
  `uvm_info(get_name(), "HOOK main_seq_iter_pre_hook", UVM_NONE)
  phase.raise_objection(this, "Start perf counter cfg sequence");
  `uvm_info(get_name(), "Perf counter cfg sequence started", UVM_NONE)
  perf_counter_seq.iteration = iter;
  <% if (obj.testBench == "dii") { %>
  `ifdef USE_VIP_SNPS_APB
  perf_counter_seq.start(m_env.amba_system_env.apb_system[0].master.sequencer);
  `else 
  perf_counter_seq.start(m_env.m_apb_agent.m_apb_sequencer);
  `endif
  
  <% } else { %>
  perf_counter_seq.start(<%=`${(() => { 

                         if (obj.BlockId.includes("dmi")||obj.BlockId.includes("dii")) {return "m_env.m_apb_agent.m_apb_sequencer";}
                         if (obj.BlockId.includes("dve")) {return "m_dve_env.m_apb_agent.m_apb_sequencer";}
                         if (obj.BlockId.includes("dce")) {return "m_env.m_apb_agent.m_apb_sequencer";}
                         if (obj.oldBlockId.includes("ncaiu") || (obj.oldBlockId.includes("caiu"))
                         || (obj.BlockId.includes("caiu") && obj[AgentInfoName][obj.Id].fnNativeInterface == "ACE")
                         || ( (obj.testBench == "fsys" || obj.testBench == "emu") && obj.AiuInfo[obj.Id].strRtlNamePrefix.includes("ncaiu"))){
                           return "mp_env.m_env[0].m_apb_agent.m_apb_sequencer";} 
                         if ((obj.AiuInfo[obj.Id].fnNativeInterface.includes('CHI'))) {
                           return "m_env.m_apb_agent.m_apb_sequencer";}
                           return "env.m_apb_agent.m_apb_sequencer"; // By default 
                          })()}`%>);
  <% } %>
  `uvm_info(get_name(), "Perf counter cfg sequence finished", UVM_NONE)
  phase.drop_objection(this, "Finish perf counter cfg sequence");

  //Update nb of ready cycle stall into VIPs ONLY if one of  stall events is selected
  for(int i=0;i<nPerfCounters ;i++) begin
    perf_counter_stalls(i);
  end
 //TRIG NEW CFG
  //Pmon 3.4 latency
  <% if (obj.BlockId.includes("dii")|| (obj.testBench =="io_aiu") || obj.BlockId.includes("dmi") || (obj.BlockId.includes("aiu") && obj.AiuInfo[obj.Id].fnNativeInterface.includes("CHI"))) {  %>
  m_latency_cnt_sb.set_new_config();
  <% } %>
  m_perf_cnt_sb.set_new_config();
  `uvm_info(get_name(), "Scoreboard counters cleared and New cfg triggered", UVM_NONE)
  if (!($test$plusargs("forced_stall"))) begin
  #1us;
  end
  <% if (obj.testBench == "dii") { %>
  perf_counter_enable_seq.enable_all_cnts = 1;
  `ifdef USE_VIP_SNPS_APB
  perf_counter_enable_seq.start(m_env.amba_system_env.apb_system[0].master.sequencer);
  `else 
    perf_counter_seq.enable_all_counters();
  `endif
  
  <% } else { %>
  perf_counter_seq.enable_all_counters();
  <% } %>
  
  
  
  if($test$plusargs("overflow_test")) begin
    counter_type counter_value_forced;
    int delay_div_16_duration;
    int cnt_value_before_max;

    if(!($value$plusargs("overflow_test=%d",cnt_value_before_max))) begin
      cnt_value_before_max = 2;
    end
    delay_div_16_duration = ((cnt_value_before_max+2)*16);

    if(perf_counters.cfg_reg[iter].ssr_count == CAPTURE ) begin
      counter_value_forced = {64{1'b1}} - cnt_value_before_max;
    end else begin
      counter_value_forced =  {32{1'b1}} - cnt_value_before_max;
    end

    m_perf_cnt_sb.force_counter_value(counter_value_forced,iter) ;
    <% if (obj.testBench == "dii") { %>
   
    `ifdef USE_VIP_SNPS_APB
      perf_counter_overflow_seq.counter = iter;
      perf_counter_overflow_seq.counter_value_forced = counter_value_forced;
      perf_counter_overflow_seq.start(m_env.amba_system_env.apb_system[0].master.sequencer);
    `else 
      perf_counter_seq.write_cnt_value_reg(iter,counter_value_forced[31:0]);
      if(perf_counters.cfg_reg[iter].ssr_count == CAPTURE ) begin
        perf_counter_seq.write_cnt_saturation_reg(iter,counter_value_forced[63:32]);
      end
      perf_counter_seq.read_cnt_value_reg(iter);
      perf_counter_seq.read_cnt_saturation_reg(iter);
    `endif
    <% } else { %>
    perf_counter_seq.write_cnt_value_reg(iter,counter_value_forced[31:0]);
    if(perf_counters.cfg_reg[iter].ssr_count == CAPTURE ) begin
      perf_counter_seq.write_cnt_saturation_reg(iter,counter_value_forced[63:32]);
    end
    perf_counter_seq.read_cnt_value_reg(iter);
    perf_counter_seq.read_cnt_saturation_reg(iter);
    <% } %>
    `uvm_info("run_main", "Printing SB counters values after force", UVM_NONE)
    m_perf_cnt_sb.print_full_counter();
    <% if (obj.testBench == "dii") { %>
    perf_counter_enable_seq.enable_all_cnts = 0;
    perf_counter_enable_seq.counter = iter;
    perf_counter_enable_seq.counter_enable = 1;
    `ifdef USE_VIP_SNPS_APB
      perf_counter_enable_seq.start(m_env.amba_system_env.apb_system[0].master.sequencer);
    `else 
      perf_counter_seq.write_count_enable(.id(iter), .counter_enable(1'b1));
    `endif
    <% } else { %>
    perf_counter_seq.write_count_enable(.id(iter), .counter_enable(1'b1));
    <% } %>
  end 
endtask:main_seq_iter_pre_hook

////////////////////////////////////////////////////////////
//////////////////// POST HOOK in ITERATION loop ///////////
task perf_cnt_test::main_seq_iter_post_hook(uvm_phase phase, uint64_type iter);
  
  `uvm_info(get_name(), "HOOK main_seq_iter_post_hook", UVM_NONE)
    // disable vif stall after sending above transactions
  for(int i=0;i<nPerfCounters ;i++) begin
    <%=`${(() => {
      if (obj.BlockId.includes("dve")) {
       return `m_env_cfg.m_smi0_tx_vif.smi_clear_stalls(i);
               m_env_cfg.m_smi1_tx_vif.smi_clear_stalls(i); 
               m_env_cfg.m_smi2_tx_vif.smi_clear_stalls(i);`;
      }  
      if (obj.BlockId.includes("dce")) {
       return `m_env_cfg.m_smi0_tx_vif.smi_clear_stalls(i);
               m_env_cfg.m_smi1_tx_vif.smi_clear_stalls(i); 
               m_env_cfg.m_smi2_tx_vif.smi_clear_stalls(i);`;
      }
      if (obj.BlockId.includes("dii")) {
        return `m_env_cfg.m_smi_agent_cfg.m_smi0_tx_port_config.m_vif.smi_clear_stalls(i);
                m_env_cfg.m_smi_agent_cfg.m_smi1_tx_port_config.m_vif.smi_clear_stalls(i); 
                m_env_cfg.m_smi_agent_cfg.m_smi2_tx_port_config.m_vif.smi_clear_stalls(i);`;
       }  
      if (obj.oldBlockId.includes("ncaiu") || (obj.oldBlockId.includes("caiu")) || ( (obj.testBench == "fsys" || obj.testBench == "emu") && obj.AiuInfo[obj.Id].strRtlNamePrefix.includes("ncaiu")) || (obj.BlockId.includes("caiu") && obj[AgentInfoName][obj.Id].fnNativeInterface == "ACE")) {
        return `m_smi0_rx_port_config.m_vif.smi_clear_stalls(i);
        m_smi1_rx_port_config.m_vif.smi_clear_stalls(i);
        m_smi2_rx_port_config.m_vif.smi_clear_stalls(i);`;
      }  
      if (obj.BlockId.includes("caiu")){
        return `m_env_cfg.m_smi_cfg.m_smi0_rx_port_config.m_vif.smi_clear_stalls(i);
        m_env_cfg.m_smi_cfg.m_smi1_rx_port_config.m_vif.smi_clear_stalls(i);
        m_env_cfg.m_smi_cfg.m_smi2_rx_port_config.m_vif.smi_clear_stalls(i);`;
      }  

      return `m_smi0_rx_port_config.m_vif.smi_clear_stalls(i);
              m_smi1_rx_port_config.m_vif.smi_clear_stalls(i);
              m_smi2_rx_port_config.m_vif.smi_clear_stalls(i);`;}

    )()}`%>

    <%=`${(() => {
      if (obj.oldBlockId.includes("ncaiu") || (obj.oldBlockId.includes("caiu")) || ( (obj.testBench == "fsys" || obj.testBench == "emu") && obj.AiuInfo[obj.Id].strRtlNamePrefix.includes("ncaiu"))){
        return "m_axi_master_cfg[0].m_vif.ace_clear_stalls(i);";} 
      return "";
    })()}`%>
   end
  `uvm_info(get_name(), "end clear stall and wait to clear scb counter", UVM_NONE)
  
  if($test$plusargs("overflow_test")) begin
    #40us
    if(perf_counters.cfg_reg[iter].interrupt_enable == 1) begin
      `uvm_info("perf_cnt_test",$sformatf("waiting for overflow interrupt for conuter %0d",iter),UVM_NONE);
      fork : irq_fork
        begin
           <% if((obj.testBench =="io_aiu")) { %>
          wait(u_csr_probe_vif[0].IRQ_C == 1) begin
         `uvm_info("perf_cnt_test",$sformatf("overflow interrupt was received for conuter %0d",iter),UVM_NONE);
          end
         <% } else { %>
           wait(u_csr_probe_vif.IRQ_C == 1) begin
           `uvm_info("perf_cnt_test",$sformatf("overflow interrupt was received for conuter %0d",iter),UVM_NONE);
           end
          <% } %>
        end
        begin
          #1ms 
          `uvm_error("perf_cnt_test",$sformatf("Timeout: Overflow inerrupt was not received for counter : %0d",iter));
        end
      join_any
      disable irq_fork;
    end
    <% if (obj.testBench == "dii") { %>
    perf_counter_enable_seq.enable_all_cnts = 0;
    perf_counter_enable_seq.counter = iter;
    perf_counter_enable_seq.counter_enable = 0;
    `ifdef USE_VIP_SNPS_APB
      perf_counter_enable_seq.start(m_env.amba_system_env.apb_system[0].master.sequencer);
    `else 
      perf_counter_seq.write_count_enable(.id(iter), .counter_enable(1'b0));
    `endif
    <% } else { %>
    perf_counter_seq.write_count_enable(.id(iter), .counter_enable(1'b0));
    <% } %>

  end

  if(iter != main_seq_iter-1) begin
    perf_cnt_process_counter(phase);
  end

 <% if (obj.BlockId.includes("dmi")) { %>
  if (main_seq_iter > 1) begin:if_iter // only in iteration case 
     if(iter == main_seq_iter-1) #2us;
    `uvm_info(get_name(), "Stop sequences to allow iterations", UVM_NONE)

    // clean the seq & disable all fork to allow iteration
    <% if(obj.testBench == 'dmi') { %>
   `ifndef VCS
    test_seq.wait_for_sequence_state(STOPPED|FINISHED);
   `else // `ifndef VCS
    test_seq.wait_for_sequence_state(UVM_STOPPED|UVM_FINISHED);
   `endif // `ifndef VCS ... `else ... 
    <% } else {%>
    test_seq.wait_for_sequence_state(STOPPED|FINISHED);
    <% } %>
	test_seq.disable_body;
    //disable test_seq.body;

<% if (!obj.USE_VIP_SNPS) { %>
    m_env.m_axi_slave_agent.m_write_resp_chnl_seqr.stop_sequences();
    m_env.m_axi_slave_agent.m_read_data_chnl_seqr.stop_sequences();

    $display("Stop sequences to allow iterations 1");
    // Clean driver to avoid item_done() => allow to kill sequence with fork inside
    m_env.m_axi_slave_agent.m_slave_read_addr_chnl_driver.m_vif.force_vif_rst_n();

    m_env.m_smi_agent.m_smi_virtual_seqr.stop_sequences();
    $display("Stop sequences to allow iterations 2");
    m_env.m_axi_slave_agent.m_read_addr_chnl_seqr.wait_for_item_done(m_slave_read_seq.m_read_addr_seq,-1);  //wait item done to allow a stop sequence
    $display("Stop sequences to allow iterations 3");
    disable m_slave_read_seq.body;
    disable m_slave_write_seq.body;
    $display("Stop sequences to allow iterations 4");
    m_env.m_axi_slave_agent.m_read_addr_chnl_seqr.stop_sequences();
    m_env.m_axi_slave_agent.m_read_data_chnl_seqr.stop_sequences();
    m_env.m_axi_slave_agent.m_write_addr_chnl_seqr.stop_sequences();
    m_env.m_axi_slave_agent.m_write_data_chnl_seqr.stop_sequences();
    m_env.m_axi_slave_agent.m_write_resp_chnl_seqr.stop_sequences();
<% } %>
    foreach(test_seq.m_smi_seqr_rx_hash[i])
        test_seq.m_smi_seqr_rx_hash[i].m_rx_analysis_fifo.flush();
    foreach(test_seq.m_smi_seqr_tx_hash[i])
        test_seq.m_smi_seqr_tx_hash[i].m_rx_analysis_fifo.flush();
    if (iter != main_seq_iter-1) m_env.m_sb.numCmd=0; 
  
    // Reset AXI4 assertion in case of  a new iteration
    //$signal_force("/tb_top/m_axi4_arm_sva/ARESETn", "0", , , 1, 1);  //$signal_force(<dest_object>, <value>, <rel_time>, <force_type>, <cancel_period>, <verbose>)
    #1;
<% if (!obj.USE_VIP_SNPS) { %>
    m_env.m_axi_slave_agent.m_slave_read_addr_chnl_driver.m_vif.release_vif_rst_n();
<% } %>
    #1;
  end:if_iter
  <%}%>
endtask:main_seq_iter_post_hook

////////////////////////////////////////////////////////////
////////////   HOOK END RUN PHASE       ///////////////
task perf_cnt_test::main_seq_hook_end_run_phase(uvm_phase phase);
  phase.raise_objection(this, "main_seq_hook_end_run_phase");
  `uvm_info(get_name(), "HOOK main_seq_hook_end_run_phase", UVM_NONE)
  <% if (obj.BlockId.includes("dce")){%>
   //add a delay as transaction ending from ATT takes time 
   #300us;
  <%}%>
  perf_cnt_process_counter(phase);
  
  m_perf_cnt_sb.disable_sb  = 1;

  `uvm_info(get_name(), "end of HOOK main_seq_hook_end_run_phase, perf_cnt_sb disabled!!", UVM_NONE)
   phase.drop_objection(this, "main_seq_hook_end_run_phase");

endtask:main_seq_hook_end_run_phase

////////////////////////////////////////////////////////////
//////////////////// POST HOOK              ///////////////
task perf_cnt_test::main_seq_post_hook(uvm_phase phase);
  `uvm_info(get_name(), "HOOK main_seq_post_hook", UVM_NONE)
  <%if (obj.testBench == "chi_aiu") {%> //CHI-AIU
  ev_main_seq_done.trigger();
  <%}%> 

endtask:main_seq_post_hook

////////////////////////////////////////////////////////////
///////////// PROCESS COUNTER              ///////////////
task perf_cnt_test::perf_cnt_process_counter(uvm_phase phase);
  int timeout_cnt_clk;
  int at_least_one_xtt_event = 0;
  <%if (obj.testBench == "chi_aiu") {%>
  check_ott_busy();
  <%} else {%>
  //add a delay as transaction processing take time in case of stall event testcase 
  #2us
  <%}%> 
  <%if (obj.BlockId.includes("dve")) {%>
  //add a delay as transaction processing take time in case of stall event testcase 
  #10us
  <%}%> 

  //add a delay as transaction processing take time in case of dropped SMI packets event testcase 
  if (perf_counters.check_is_capture_dropped_packets()) begin
    <%if ( ! obj.BlockId.includes("dii") && ! obj.BlockId.includes("dve")) {%>do begin
        timeout_cnt_clk = 500 ;
        wait(sb_stall_if.trace_capture_busy == 1'b0);
        while(sb_stall_if.trace_capture_busy == 1'b0 && timeout_cnt_clk > 0) begin
          timeout_cnt_clk--;
          #10ns; 
        end
      end while (timeout_cnt_clk!=0);<%}
    else if(obj.BlockId.includes("dve")){%>#1ms; <%}
    else {%>#50us; <%}%>
  end
  for (int i=0;i<nPerfCounters;i++) begin
    at_least_one_xtt_event = at_least_one_xtt_event+ m_perf_cnt_sb.check_is_xtt_entries_event(i);
  end
  if(at_least_one_xtt_event) #2us;
  // disable Counters
  //Pmon 3.4 feature
  <% if (obj.testBench == "dii") { %>
  perf_counter_enable_seq.enable_all_cnts = 0;
  perf_counter_enable_seq.counter_enable = 0;
  perf_counter_enable_seq.enable_one_counter = 0;
  `ifdef USE_VIP_SNPS_APB
  perf_counter_enable_seq.start(m_env.amba_system_env.apb_system[0].master.sequencer);
  `else 
  perf_counter_enable_seq.start(m_env.m_apb_agent.m_apb_sequencer);
  `endif
  <% } else { %>
  
  <% if (obj.BlockId.includes("dii")|| (obj.testBench =="io_aiu") || obj.BlockId.includes("dmi") || (obj.BlockId.includes("aiu") && obj.AiuInfo[obj.Id].fnNativeInterface.includes("CHI")) || obj.BlockId.includes("dve")) {  %>
      if (perf_counters.perfmon_local_count_enable) begin
          `uvm_info("run_main", "local count enable trigged to disable perf counters for <%=obj.BlockId%>", UVM_NONE)
        perf_counter_seq.write_local_count_enable(1'b0);
      end
      else begin
        for (int i=0;i<nPerfCounters;i++) begin
          perf_counter_seq.write_count_enable(.id(i), .counter_enable(1'b0));
        end
      end
  <% } else {  %>  
  for (int i=0;i<nPerfCounters;i++) begin
    perf_counter_seq.write_count_enable(.id(i), .counter_enable(1'b0));
  end
  <% }  %>
  <% } %>
  <% if(obj.BlockId.includes("dve")) { %>
      if (perf_counters.main_count_enable) begin
        `uvm_info("run_main", "master count enable trigged to disable perf counters for <%=obj.BlockId%>", UVM_NONE)
        perf_counter_seq.write_master_count_enable(1'b0);
      end
  <% } %>
  //print counter values and clean sb
  #2us
  //foce counter to save values
  m_perf_cnt_sb.set_save_counter();
  #5ns
  // read cnt_value and cnt_value_str from register
  <% if (obj.testBench == "dii") { %>
  `ifdef USE_VIP_SNPS_APB
  perf_counter_read_status_seq.start(m_env.amba_system_env.apb_system[0].master.sequencer);
  `else 
  perf_counter_seq.read_all_cnt_value_reg();
  perf_counter_seq.read_all_cnt_saturation_reg();
  perf_counter_seq.read_all_overflow_status();
  `endif
  <% } else { %>
  perf_counter_seq.read_all_cnt_value_reg();
  perf_counter_seq.read_all_cnt_saturation_reg();
  perf_counter_seq.read_all_overflow_status();
  <% } %>
  //Pmon 3.4 latency
  <% if (obj.BlockId.includes("dii")|| (obj.testBench =="io_aiu")|| obj.BlockId.includes("dmi") || (obj.BlockId.includes("aiu") && obj.AiuInfo[obj.Id].fnNativeInterface.includes("CHI"))) {  %>
  // printing latency scoreboard bins value
  if (m_perf_cnt_sb.pmon_latency_test) begin
    m_latency_cnt_sb.print_bins();
    m_latency_cnt_sb.compare_bins();
  end
  <% } %>
  `uvm_info(get_name(), "Start comparison between design and scoreboard for all counters", UVM_LOW)
  // Compare reg value and saturation value to sb value
  m_perf_cnt_sb.stall_counter_compare_all();
  // clear sb value and reg value
  `uvm_info(get_name(), "Printing SB counters values before clearing counters", UVM_NONE)
  m_perf_cnt_sb.print_full_counter();
  //#Check.DII.Pmon.v3.4.LocalClear 
  //#Check.DMI.Pmon.v3.4.LocalClear
  //#Check.CHIAIU.Pmon.v3.4.LocalClear
  //#Check.IOAIU.Pmon.v3.4.LocalClear
  m_perf_cnt_sb.clear_full_counter();

endtask:perf_cnt_process_counter

//task perf_cnt_test::post_shutdown_phase(uvm_phase phase);
//main_seq_hook_end_run_phase(phase);
//endtask:post_shutdown_phase


////////////////////////////////////////////////////////////////////
//#######  #     #  #     #   #####   #######  ###  #######  #     #  
//#        #     #  ##    #  #     #     #      #   #     #  ##    #  
//#        #     #  # #   #  #           #      #   #     #  # #   #  
//#####    #     #  #  #  #  #           #      #   #     #  #  #  #  
//#        #     #  #   # #  #           #      #   #     #  #   # #  
//#        #     #  #    ##  #     #     #      #   #     #  #    ##  
//#         #####   #     #   #####      #     ###  #######  #     #  
////////////////////////////////////////////////////////////////////
function void perf_cnt_test::perf_counter_stalls(int cnt_id);
   int minimum_stall = get_minimal_stall_count(cnt_id);
  //control SMI stall
  <%=obj.listEventArr.filter(e => e.vif).map(e =>
`       ${e.vif}.RDY_NOT_ASSERTED_DURATION = ${e.assert_duration};`).join("\n")%>

  <%=obj.listEventArr.filter(e => e.vif_en_stall_name).filter(e => e.vif_en_stall_name.match(/TX_Stall/i)).map(e =>
`       if (get_events(.cnt_id(cnt_id),.event_id(${e.name}))) begin
           ${e.vif}.${e.vif_en_stall_name} = 1;
           smi_rx_stall_en = 1;
        end`).join("\n")%>
        
  <%=obj.listEventArr.filter(e => e.vif_en_stall_name).filter(e => e.vif_en_stall_name.match(/RX_Stall/i)).map(e =>
`       if (get_events(.cnt_id(cnt_id),.event_id(${e.name}))) begin
           ${e.vif}.${e.vif_en_stall_name} = 1;
        end`).join("\n")%>

 
 <% if ((obj.BlockId.includes("dmi")) || (obj.BlockId.includes("dii"))) { %>
 <%=obj.listEventArr.filter(e => (e.vif_en_stall_name)).filter(e => (e.name.match(/AXI_B/i) || e.name.match(/AXI_R/i))).map(e =>
`       if (get_events(.cnt_id(cnt_id),.event_id(${e.name}))) begin
           ${e.vif}.${e.vif_en_stall_name} = 1;
           force_axi_stall_en = 1;
           ${(obj.BlockId.includes("dmi"))?`m_env.m_sb.force_axi_stall_en = 1;`:``}
        end`).join("\n")%>

 <%=obj.listEventArr.filter(e => (e.vif_en_stall_name)).filter(e => (e.name.match(/AXI_W/i) || e.name.match(/AXI_AW/i) || e.name.match(/AXI_AR/i))).map(e =>
`       if (get_events(.cnt_id(cnt_id),.event_id(${e.name}))) begin
           ${e.vif}.${e.vif_en_stall_name} = 1;
        end`).join("\n")%>

<%} else { %> 
  <%=obj.listEventArr.filter(e => (e.vif_en_stall_name && e.name.match(/A.*stall/i))).map(e =>
`       if (get_events(.cnt_id(cnt_id),.event_id(${e.name}))) begin
           ${e.vif}.${e.vif_en_stall_name} = 1;
        end`).join("\n")%>
<%}%> 

    <%=obj.listEventArr.filter(e => e.stall_period_name).map(e =>
`      ${e.vif}.${e.stall_period_name} = minimum_stall;`).join("\n")%>
endfunction: perf_counter_stalls

function int  perf_cnt_test::get_minimal_stall_count(int cnt_id);
  <%=obj[obj.AgentInfoName][obj.Id].strRtlNamePrefix%>_perf_cnt_units perf_counters = <%=obj[obj.AgentInfoName][obj.Id].strRtlNamePrefix%>_perf_cnt_units::get_instance();
  return 2**(perf_counters.cfg_reg[cnt_id].minimum_stall_period) + $urandom_range(0,16);
endfunction: get_minimal_stall_count

function bit  perf_cnt_test::get_events(int cnt_id, e_count_event  event_id);
  <%=obj[obj.AgentInfoName][obj.Id].strRtlNamePrefix%>_perf_cnt_units perf_counters = <%=obj[obj.AgentInfoName][obj.Id].strRtlNamePrefix%>_perf_cnt_units::get_instance();
  return (perf_counters.cfg_reg[cnt_id].count_event_first == event_id || perf_counters.cfg_reg[cnt_id].count_event_second == event_id);
endfunction: get_events


task perf_cnt_test::check_ott_busy(); 
  int timeout_cnt_clk;

  do begin
    <% if  (obj.testBench == "chi_aiu") { %>
    timeout_cnt_clk = 50 ;
    <%} else {%>
    timeout_cnt_clk = 400 ;
    <%}%>  
  
    wait(sb_stall_if.ott_busy == 1'b0);
    while(sb_stall_if.ott_busy == 1'b0 && timeout_cnt_clk > 0) begin
      timeout_cnt_clk--;
      #<%=obj.Clocks[0].params.period%>ps; //obj.Clocks[0].params.period
    end
  end while (timeout_cnt_clk != 0);
  
endtask : check_ott_busy


      <% } else { %>

class perf_cnt_test extends <%=`${(() => {
                                    return "bring_up_test"; // By default  
                                  })()}`%>;

  `uvm_component_utils(perf_cnt_test)

  //!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!                                  
  // !!! some declarations in the parent with the macro `perf_cnt_test_all_declarations in files perf_cnt_unit_defines!!!!
  //!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!                                  
                                  
  function new(string name = "perf_cnt_test", uvm_component parent=null);
    super.new(name,parent);
      <%for(var i = 0; i < obj.DutInfo.nNativeInterfacePorts; i++){%> 
         perf_counters[<%=i%>] = <%=obj[obj.AgentInfoName][obj.Id].strRtlNamePrefix%>_perf_cnt_units::get_instance();
         uvm_config_db#(<%=obj[obj.AgentInfoName][obj.Id].strRtlNamePrefix%>_perf_cnt_units)::set(null, "", "<%=obj[obj.AgentInfoName][obj.Id].strRtlNamePrefix%>_m_perf_counters<%=i%>", perf_counters[<%=i%>]);
         m_perf_cnt_sb[<%=i%>] = <%=obj[obj.AgentInfoName][obj.Id].strRtlNamePrefix%>_perf_counters_scoreboard::type_id::create("<%=obj[obj.AgentInfoName][obj.Id].strRtlNamePrefix%>_m_perf_cnt_sb[<%=i%>]", this);
         m_perf_cnt_sb[<%=i%>].core_no = <%=i%>;
         //Pmon 3.4 latency
         m_latency_cnt_sb[<%=i%>] = <%=obj[obj.AgentInfoName][obj.Id].strRtlNamePrefix%>_latency_counters_scoreboard::type_id::create("<%=obj[obj.AgentInfoName][obj.Id].strRtlNamePrefix%>_m_latency_cnt_sb<%=i%>", this);
         m_latency_cnt_sb[<%=i%>].core_no = <%=i%>;
        if (!uvm_config_db#(virtual <%=obj.BlockId%>_stall_if)::get(null, "", "<%=obj.BlockId%>_0_m_top_stall_if_<%=i%>", sb_stall_if_<%=i%>)) begin
            `uvm_fatal("Stall interface error", "virtual interface must be set for stall_if");
        end
      <% } %>
  endfunction: new

  // UVM PHASE
  extern function void build_phase(uvm_phase phase);
  extern task run_phase (uvm_phase phase);
//  extern task post_shutdown_phase (uvm_phase phase);

  // HOOK task call in the parent class
  extern virtual task main_seq_pre_hook(uvm_phase phase); // before the iteration (outside the iteration loop)
  extern virtual task main_seq_post_hook(uvm_phase phase); // after the iteration (outside the iteration loop)
  extern virtual task main_seq_iter_pre_hook(uvm_phase phase, uint64_type iter); // at the beginning of the iteration(inside the iteration loop)
  extern virtual task main_seq_iter_post_hook(uvm_phase phase, uint64_type iter);// at the end of the iteration (inside the iteration)
  extern virtual task main_seq_hook_end_run_phase(uvm_phase phase);// at the very end of the run_phase 
  extern         task perf_cnt_process_counter(uvm_phase phase); //Will do save,read,compare 

  // PERF CNT FUNCTION
  extern function void perf_counter_stalls(int cnt_id);
  extern function int  get_minimal_stall_count(int cnt_id, int core_no);
  extern function bit  get_events(int cnt_id, e_count_event event_id, int core_no);


  <%for(var i = 0; i < obj.DutInfo.nNativeInterfacePorts; i++){%> 
  virtual <%=obj.BlockId%>_stall_if sb_stall_if_<%=i%>;
  perf_cnt_unit_cfg_seq_<%=i%>     perf_counter_seq_<%=i%>;
  <% } %>
endclass: perf_cnt_test


//METHOD Definitions
///////////////////////////////////////////////////////////////////////////////// 
// #     #  #     #  #     #         ######   #     #     #      #####   #######  
// #     #  #     #  ##   ##         #     #  #     #    # #    #     #  #        
// #     #  #     #  # # # #         #     #  #     #   #   #   #        #        
// #     #  #     #  #  #  #         ######   #######  #     #   #####   #####    
// #     #   #   #   #     #         #        #     #  #######        #  #        
// #     #    # #    #     #         #        #     #  #     #  #     #  #        
//  #####      #     #     #  #####  #        #     #  #     #   #####   #######  
///////////////////////////////////////////////////////////////////////////////// 
function void perf_cnt_test::build_phase(uvm_phase phase);
    perfmon_test = 1'b1;
    super.build_phase(phase);
endfunction : build_phase

task perf_cnt_test::run_phase (uvm_phase phase); 
 // Before start the iteration create & setup all the attributs
      <%for(var i = 0; i < obj.DutInfo.nNativeInterfacePorts; i++){%> 
  perf_counter_seq_<%=i%> = perf_cnt_unit_cfg_seq_<%=i%>::type_id::create("perf_cnt_unit_cfg_seq[<%=i%>]");
  perf_counter_seq_<%=i%>.perf_counters = perf_counters[<%=i%>];
  perf_counter_seq_<%=i%>.m_regs = <%=`${(() => {
                                       return "mp_env.m_env[0].m_regs";
                               })()}`%>;
      <% } %>

  super.run_phase(phase);
endtask:run_phase

////////////////////////////////////////////////////////////////////////////////////////
// #     #  #######  #######  #    #         #######     #      #####   #    #   #####   
// #     #  #     #  #     #  #   #             #       # #    #     #  #   #   #     #  
// #     #  #     #  #     #  #  #              #      #   #   #        #  #    #        
// #######  #     #  #     #  ###               #     #     #   #####   ###      #####   
// #     #  #     #  #     #  #  #              #     #######        #  #  #          #  
// #     #  #     #  #     #  #   #             #     #     #  #     #  #   #   #     #  
// #     #  #######  #######  #    #  #####     #     #     #   #####   #    #   #####  
////////////////////////////////////////////////////////////////////////////////////////
//////////////////// PRE HOOK                   ////////////
task perf_cnt_test::main_seq_pre_hook(uvm_phase phase);
  `uvm_info(get_name(), "HOOK main_seq_pre_hook", UVM_NONE)
  
  if (! $value$plusargs("main_seq_iter=%d", main_seq_iter)) begin
    if($test$plusargs("overflow_test"))  begin
      main_seq_iter = nPerfCounters;
    end else begin
      main_seq_iter = 1;
    end
  end
endtask:main_seq_pre_hook

////////////////////////////////////////////////////////////
//////////////////// PRE HOOK in ITERATION loop ////////////
task perf_cnt_test::main_seq_iter_pre_hook(uvm_phase phase, uint64_type iter);
  
  `uvm_info(get_name(), "HOOK main_seq_iter_pre_hook", UVM_NONE)
  phase.raise_objection(this, "Start perf counter cfg sequence");
  `uvm_info(get_name(), "Perf counter cfg sequence started", UVM_NONE)
      <%for(var i = 0; i < obj.DutInfo.nNativeInterfacePorts; i++){%> 
      begin
          perf_counter_seq_<%=i%>.iteration = iter;
          perf_counter_seq_<%=i%>.start(<%=`${(() => { 

                           return "mp_env.m_env[0].m_apb_agent.m_apb_sequencer"; 
                          })()}`%>);
      end
      <% } %>
  `uvm_info(get_name(), "Perf counter cfg sequence finished", UVM_NONE)
  phase.drop_objection(this, "Finish perf counter cfg sequence");

  //Update nb of ready cycle stall into VIPs ONLY if one of  stall events is selected
  for(int i=0;i<nPerfCounters ;i++) begin
    perf_counter_stalls(i);
  end
 //TRIG NEW CFG
  //Pmon 3.4 latency
      <%for(var i = 0; i < obj.DutInfo.nNativeInterfacePorts; i++){%> 
          m_latency_cnt_sb[<%=i%>].set_new_config();
          m_perf_cnt_sb[<%=i%>].set_new_config();
      <% } %>

  `uvm_info(get_name(), "Scoreboard counters cleared and New cfg triggered", UVM_NONE)
  if (!($test$plusargs("forced_stall"))) begin
  #1us;
  end
      <%for(var i = 0; i < obj.DutInfo.nNativeInterfacePorts; i++){%> 
      begin
         perf_counter_seq_<%=i%>.enable_all_counters();
      end
      <% } %>

   fork
      <%for(var i = 0; i < obj.DutInfo.nNativeInterfacePorts; i++){%> 
          if($test$plusargs("overflow_test")) begin
            counter_type counter_value_forced;
            int delay_div_16_duration;
            int cnt_value_before_max;
        
            if(!($value$plusargs("overflow_test=%d",cnt_value_before_max))) begin
              cnt_value_before_max = 2;
            end
            delay_div_16_duration = ((cnt_value_before_max+2)*16);
        
            if(perf_counters[<%=i%>].cfg_reg[iter].ssr_count == CAPTURE ) begin
              counter_value_forced = {64{1'b1}} - cnt_value_before_max;
            end else begin
              counter_value_forced =  {32{1'b1}} - cnt_value_before_max;
            end
        
            m_perf_cnt_sb[<%=i%>].force_counter_value(counter_value_forced,iter) ;
        
            perf_counter_seq_<%=i%>.write_cnt_value_reg(iter,counter_value_forced[31:0]);
            if(perf_counters[<%=i%>].cfg_reg[iter].ssr_count == CAPTURE ) begin
              perf_counter_seq_<%=i%>.write_cnt_saturation_reg(iter,counter_value_forced[63:32]);
            end
            perf_counter_seq_<%=i%>.read_cnt_value_reg(iter);
            perf_counter_seq_<%=i%>.read_cnt_saturation_reg(iter);
        
            `uvm_info("run_main", "Printing SB counters values after force", UVM_NONE)
            m_perf_cnt_sb[<%=i%>].print_full_counter();
        
            perf_counter_seq_<%=i%>.write_count_enable(.id(iter), .counter_enable(1'b1));
          end 
      <% } %>
   join
endtask:main_seq_iter_pre_hook

////////////////////////////////////////////////////////////
//////////////////// POST HOOK in ITERATION loop ///////////
task perf_cnt_test::main_seq_iter_post_hook(uvm_phase phase, uint64_type iter);
  
  `uvm_info(get_name(), "HOOK main_seq_iter_post_hook", UVM_NONE)
    // disable vif stall after sending above transactions
  for(int i=0;i<nPerfCounters ;i++) begin
    <%=`${(() => {
      if (obj.oldBlockId.includes("ncaiu") || (obj.oldBlockId.includes("caiu")) || ( (obj.testBench == "fsys" || obj.testBench == "emu") && obj.AiuInfo[obj.Id].strRtlNamePrefix.includes("ncaiu")) || (obj.BlockId.includes("caiu") && obj[AgentInfoName][obj.Id].fnNativeInterface == "ACE")) {
        return `m_smi0_rx_port_config.m_vif.smi_clear_stalls(i);
        m_smi1_rx_port_config.m_vif.smi_clear_stalls(i);
        m_smi2_rx_port_config.m_vif.smi_clear_stalls(i);`;
      }  
      if (obj.BlockId.includes("caiu")){
        return `m_env_cfg.m_smi_cfg.m_smi0_rx_port_config.m_vif.smi_clear_stalls(i);
        m_env_cfg.m_smi_cfg.m_smi1_rx_port_config.m_vif.smi_clear_stalls(i);
        m_env_cfg.m_smi_cfg.m_smi2_rx_port_config.m_vif.smi_clear_stalls(i);`;
      }  

      return `m_smi0_rx_port_config.m_vif.smi_clear_stalls(i);
              m_smi1_rx_port_config.m_vif.smi_clear_stalls(i);
              m_smi2_rx_port_config.m_vif.smi_clear_stalls(i);`;}

    )()}`%>

   fork
      <%for(var k = 0; k < obj.DutInfo.nNativeInterfacePorts; k++){%> 
    <%=`${(() => {
      if (obj.oldBlockId.includes("ncaiu") || (obj.oldBlockId.includes("caiu")) || ( (obj.testBench == "fsys" || obj.testBench == "emu") && obj.AiuInfo[obj.Id].strRtlNamePrefix.includes("ncaiu"))){
        return "m_axi_master_cfg[0].m_vif.ace_clear_stalls(i);";} 
      return "";
    })()}`%>
      <% } %>
   join
   
   end
  `uvm_info(get_name(), "end clear stall and wait to clear scb counter", UVM_NONE)
  
   fork
      <%for(var i = 0; i < obj.DutInfo.nNativeInterfacePorts; i++){%> 
  if($test$plusargs("overflow_test")) begin
    #40us
    if(perf_counters[<%=i%>].cfg_reg[iter].interrupt_enable == 1) begin
      `uvm_info("perf_cnt_test",$sformatf("waiting for overflow interrupt for conuter %0d",iter),UVM_NONE);
      fork : irq_fork_<%=i%>
        begin
          //#Check.DII.Pmon.v3.2.Interrupt
          wait(u_csr_probe_vif[<%=i%>].IRQ_C == 1) begin
         `uvm_info("perf_cnt_test",$sformatf("overflow interrupt was received for conuter %0d",iter),UVM_NONE);
          end
        end
        begin
          #1ms 
          `uvm_error("perf_cnt_test",$sformatf("Timeout: Overflow inerrupt was not received for counter : %0d",iter));
        end
      join_any
      disable irq_fork_<%=i%>;
    end
    perf_counter_seq_<%=i%>.write_count_enable(.id(iter), .counter_enable(1'b0));

  end
      <% } %>
   join

  if(iter != main_seq_iter-1) begin
    perf_cnt_process_counter(phase);
  end

endtask:main_seq_iter_post_hook

////////////////////////////////////////////////////////////
////////////   HOOK END RUN PHASE       ///////////////
task perf_cnt_test::main_seq_hook_end_run_phase(uvm_phase phase);
  phase.raise_objection(this, "main_seq_hook_end_run_phase");
  `uvm_info(get_name(), "HOOK main_seq_hook_end_run_phase", UVM_NONE)
  perf_cnt_process_counter(phase);
  
      <%for(var i = 0; i < obj.DutInfo.nNativeInterfacePorts; i++){%> 
  m_perf_cnt_sb[<%=i%>].disable_sb  = 1;
      <% } %>

  `uvm_info(get_name(), "end of HOOK main_seq_hook_end_run_phase, perf_cnt_sb disabled!!", UVM_NONE)
   phase.drop_objection(this, "main_seq_hook_end_run_phase");

endtask:main_seq_hook_end_run_phase

////////////////////////////////////////////////////////////
//////////////////// POST HOOK              ///////////////
task perf_cnt_test::main_seq_post_hook(uvm_phase phase);
  `uvm_info(get_name(), "HOOK main_seq_post_hook", UVM_NONE)

endtask:main_seq_post_hook

////////////////////////////////////////////////////////////
///////////// PROCESS COUNTER              ///////////////
task perf_cnt_test::perf_cnt_process_counter(uvm_phase phase);
      <%for(var k = 0; k < obj.DutInfo.nNativeInterfacePorts; k++){%> 
  begin
  int timeout_cnt_clk;
  int at_least_one_xtt_event = 0;
  //add a delay as transaction processing take time in case of stall event testcase 
  #2us

  //add a delay as transaction processing take time in case of dropped SMI packets event testcase 
  if (perf_counters[<%=k%>].check_is_capture_dropped_packets()) begin
    do begin
        timeout_cnt_clk = 500 ;
        wait(sb_stall_if_<%=k%>.trace_capture_busy == 1'b0);
        while(sb_stall_if_<%=k%>.trace_capture_busy == 1'b0 && timeout_cnt_clk > 0) begin
          timeout_cnt_clk--;
          #10ns; 
        end
      end while (timeout_cnt_clk!=0);
  end
  for (int i=0;i<nPerfCounters;i++) begin
    at_least_one_xtt_event = at_least_one_xtt_event+ m_perf_cnt_sb[<%=k%>].check_is_xtt_entries_event(i);
  end
  if(at_least_one_xtt_event) #2us;
  // disable Counters
  //Pmon 3.4 feature
      if (perf_counters[<%=k%>].perfmon_local_count_enable) begin
          `uvm_info("run_main", "local count enable trigged to disable perf counters for <%=obj.BlockId%>", UVM_NONE)
        perf_counter_seq_<%=k%>.write_local_count_enable(1'b0);
      end
      else begin
        for (int i=0;i<nPerfCounters;i++) begin
          perf_counter_seq_<%=k%>.write_count_enable(.id(i), .counter_enable(1'b0));
        end
      end
  //print counter values and clean sb
  #2us
  //foce counter to save values
  m_perf_cnt_sb[<%=k%>].set_save_counter();
  #5ns
  // read cnt_value and cnt_value_str from register 
  perf_counter_seq_<%=k%>.read_all_cnt_value_reg();
  perf_counter_seq_<%=k%>.read_all_cnt_saturation_reg();
  perf_counter_seq_<%=k%>.read_all_overflow_status();
  //Pmon 3.4 latency
  if (m_perf_cnt_sb[<%=k%>].pmon_latency_test) begin
          m_latency_cnt_sb[<%=k%>].print_bins();
          m_latency_cnt_sb[<%=k%>].compare_bins();
  end
  `uvm_info(get_name(), "Start comparison between design and scoreboard for all counters", UVM_LOW)
  // Compare reg value and saturation value to sb value
  m_perf_cnt_sb[<%=k%>].stall_counter_compare_all();
  // clear sb value and reg value
  `uvm_info(get_name(), "Printing SB counters values before clearing counters", UVM_NONE)
  m_perf_cnt_sb[<%=k%>].print_full_counter();
  m_perf_cnt_sb[<%=k%>].clear_full_counter();

          end 
      <% } %>
endtask:perf_cnt_process_counter

//task perf_cnt_test::post_shutdown_phase(uvm_phase phase);
//main_seq_hook_end_run_phase(phase);
//endtask:post_shutdown_phase


////////////////////////////////////////////////////////////////////
//#######  #     #  #     #   #####   #######  ###  #######  #     #  
//#        #     #  ##    #  #     #     #      #   #     #  ##    #  
//#        #     #  # #   #  #           #      #   #     #  # #   #  
//#####    #     #  #  #  #  #           #      #   #     #  #  #  #  
//#        #     #  #   # #  #           #      #   #     #  #   # #  
//#        #     #  #    ##  #     #     #      #   #     #  #    ##  
//#         #####   #     #   #####      #     ###  #######  #     #  
////////////////////////////////////////////////////////////////////
function void perf_cnt_test::perf_counter_stalls(int cnt_id);
fork
 for(int k = 0; k < <%=obj.DutInfo.nNativeInterfacePorts%>; k++)
 begin
   int minimum_stall = get_minimal_stall_count(cnt_id, k);
  //control SMI stall
  <%=obj.listEventArr.filter(e => e.vif).map(e =>
`       ${e.vif}.RDY_NOT_ASSERTED_DURATION = ${e.assert_duration};`).join("\n")%>

     if(!$test$plusargs("pmon_latency_test")) begin
  <%=obj.listEventArr.filter(e => e.vif_en_stall_name).filter(e => e.vif_en_stall_name.match(/TX_Stall/i)).map(e =>
`       if (get_events(.cnt_id(cnt_id),.event_id(${e.name}),.core_no(k))) begin
           ${e.vif}.${e.vif_en_stall_name} = 1;
           smi_rx_stall_en = 1;
        end`).join("\n")%>
        
  <%=obj.listEventArr.filter(e => e.vif_en_stall_name).filter(e => e.vif_en_stall_name.match(/RX_Stall/i)).map(e =>
`       if (get_events(.cnt_id(cnt_id),.event_id(${e.name}),.core_no(k))) begin
           ${e.vif}.${e.vif_en_stall_name} = 1;
        end`).join("\n")%>

  <%=obj.listEventArr.filter(e => (e.vif_en_stall_name && e.name.match(/A.*stall/i))).map(e =>
`       if (get_events(.cnt_id(cnt_id),.event_id(${e.name}),.core_no(k))) begin
           ${e.vif}.${e.vif_en_stall_name} = 1;
        end`).join("\n")%>
      end
    <%=obj.listEventArr.filter(e => e.stall_period_name).map(e =>
`      ${e.vif}.${e.stall_period_name} = minimum_stall;`).join("\n")%>

  //`uvm_info("perf_cnt_test dbg",$sformatf("minimum_stall:%0d m_smi0_tx_port_config.m_vif.en_tx_stall:%0d m_smi1_tx_port_config.m_vif.en_tx_stall:%0d m_smi2_tx_port_config.m_vif.en_tx_stall:%0d m_smi0_rx_port_config.m_vif.en_rx_stall:%0d m_smi1_rx_port_config.m_vif.en_rx_stall:%0d m_smi2_rx_port_config.m_vif.en_rx_stall:%0d", minimum_stall, m_smi0_tx_port_config.m_vif.en_tx_stall, m_smi1_tx_port_config.m_vif.en_tx_stall, m_smi2_tx_port_config.m_vif.en_tx_stall, m_smi0_rx_port_config.m_vif.en_rx_stall, m_smi1_rx_port_config.m_vif.en_rx_stall, m_smi2_rx_port_config.m_vif.en_rx_stall),UVM_LOW);
 end 
<% if(obj.testBench == 'io_aiu') { %>
`ifndef VCS
join
`else // `ifndef VCS
join_none
`endif // `ifndef VCS ... `else ... 
<% } else {%>
join
<% } %>

endfunction: perf_counter_stalls

function int  perf_cnt_test::get_minimal_stall_count(int cnt_id, int core_no);
  return 2**(perf_counters[core_no].cfg_reg[cnt_id].minimum_stall_period) + $urandom_range(0,16);
endfunction: get_minimal_stall_count

function bit  perf_cnt_test::get_events(int cnt_id, e_count_event  event_id, int core_no);
  return (perf_counters[core_no].cfg_reg[cnt_id].count_event_first == event_id || perf_counters[core_no].cfg_reg[cnt_id].count_event_second == event_id);
endfunction: get_events


      <% } %>
