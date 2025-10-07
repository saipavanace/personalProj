//*************************************************
// DCE Random Traffic Test
// This is the main test, that will run different
// test sequences
//*************************************************

class dce_qchannel_test extends dce_base_test;

 `uvm_component_utils(dce_qchannel_test);
  dce_default_reset_seq default_seq;
  uvm_event toggle_rst;

  uvm_event_pool ev_pool = uvm_event_pool::get_global_pool();
  uvm_event ev = ev_pool.get("ev");

  extern function new(string name = "dce_qchannel_test", uvm_component parent = null);
  extern function void build_phase(uvm_phase phase);
  extern function void start_of_simulation_phase(uvm_phase phase);
  extern task run_phase(uvm_phase phase);
  q_chnl_seq m_q_chnl_seq;
  virtual <%=obj.BlockId%>_q_chnl_if qc_if;
  virtual <%=obj.BlockId%>_smi_if smi_if;
endclass: dce_qchannel_test

//************************************
//  Default UVM Methods
//************************************
function dce_qchannel_test::new( string name = "dce_qchannel_test", uvm_component parent = null);
    super.new(name, parent);
        uvm_config_db#(virtual <%=obj.BlockId%>_q_chnl_if )::get(.cntxt(null),
                                        .inst_name( "" ),
                                        .field_name( "m_q_chnl_if" ),
                                        .value(qc_if ));
endfunction: new

function void dce_qchannel_test::build_phase(uvm_phase phase);
    super.build_phase(phase);
    //`uvm_info("bringup_test",$sformatf("build_phase"),UVM_DEBUG);
        m_q_chnl_seq = q_chnl_seq::type_id::create("m_q_chnl_seq");
        <% if (obj.INHOUSE_APB_VIP) { %>
         default_seq = dce_default_reset_seq::type_id::create("default_seq");
         default_seq.m_env_cfg = m_env_cfg; 
        <% } %>
     toggle_rst = new("toggle_rst");
     if (!uvm_config_db#(uvm_event)::get( .cntxt(null),
                                     .inst_name(""),
                                     .field_name( "toggle_rst" ),
                                     .value( toggle_rst ))) begin
        `uvm_error("Q-chnl test", "Event toggle_rst is not found")
     end
endfunction:build_phase

//*************************************
function void dce_qchannel_test::start_of_simulation_phase(uvm_phase phase);
    super.start_of_simulation_phase(phase);

    //`uvm_info("bringup_test",$sformatf("start_of_simulation_phase"),UVM_DEBUG);
endfunction:start_of_simulation_phase

//*************************************
task dce_qchannel_test::run_phase(uvm_phase phase);
      
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
    //`uvm_info("bringup_test",$sformatf("run_phase"),UVM_DEBUG);
    <% if (obj.INHOUSE_APB_VIP) { %>
      default_seq.model       = m_env.m_regs;
    <% } %>
    
    if (m_env.m_dce_scb != null) 
        phase.phase_done.set_drain_time(this, 1000ns);
    else 
        phase.phase_done.set_drain_time(this, 50us);

    m_vseq = dce_virtual_seq::type_id::create("m_vseq");
    assign_sqr_and_misc_handles(phase);    

    <% if(obj.INHOUSE_APB_VIP) { %>
    phase.raise_objection(this, "Start default_seq");
    `uvm_info(get_full_name(), "default_seq started",UVM_NONE)
    default_seq.start(m_env.m_apb_agent.m_apb_sequencer);
    `uvm_info(get_full_name(), "default_seq finished",UVM_NONE)
    #100ns;
    phase.drop_objection(this, "Finish default_seq");
    <% } %>

//Sanity test
if($test$plusargs("dce_qchannel_sanity_test"))begin
        
    phase.raise_objection(this, "dce_qchannel_test");
    `uvm_info("dce_qchannel_sanity_test","virtual_seq started",UVM_DEBUG)
    m_vseq.start(null);
    `uvm_info("dce_qchannel_sanity_test","virtual_seq completed",UVM_DEBUG)
    phase.drop_objection(this, "dce_qchannel_test");
    
  <% if(obj.DceInfo[obj.Id].usePma) { %>
    phase.raise_objection(this, $sformatf("Start q_cnl_seq"));
    #1000ns;       
    `uvm_info("dce_qchannel_sanity_test", "Q_SEQ_START",UVM_DEBUG)
     m_q_chnl_seq.start(m_env.m_q_chnl_agent.m_q_chnl_seqr);
    `uvm_info("dce_qchannel_sanity_test", "Q_SEQ_END",UVM_DEBUG)
     phase.drop_objection(this, $sformatf("Finish q_cnl_seq"));
  <% } %>
           
end

//dce_qchannel_req_during_cmd_test
if($test$plusargs("dce_qchannel_req_during_cmd_test"))begin
  fork
  begin        
    phase.raise_objection(this, "dce_qchannel_test");
    `uvm_info("dce_qchannel_req_during_cmd_test","virtual_seq started",UVM_DEBUG)
    m_vseq.start(null);
    `uvm_info("dce_qchannel_req_during_cmd_test","virtual_seq completed",UVM_DEBUG)
    phase.drop_objection(this, "dce_qchannel_test");
  end
  begin
  <% if(obj.DceInfo[obj.Id].usePma) { %>
    repeat(5) begin
        wait(qc_if.QACTIVE);
        repeat(2)  @(posedge qc_if.clk); ///delay
        phase.raise_objection(this, $sformatf("Start q_cnl_seq"));
        `uvm_info("dce_qchannel_req_during_cmd_test", "Q_SEQ_START",UVM_DEBUG)
        m_q_chnl_seq.start(m_env.m_q_chnl_agent.m_q_chnl_seqr);
        `uvm_info("dce_qchannel_req_during_cmd_test", "Q_SEQ_END",UVM_DEBUG)
        phase.drop_objection(this, $sformatf("Finish q_cnl_seq"));
    end
  <% } %>
  end
  join
end

//dce_qchannel_req_between_cmd_test
if($test$plusargs("dce_qchannel_req_between_cmd_test"))begin
  fork
  begin        
    phase.raise_objection(this, "dce_qchannel_test");
    `uvm_info("dce_qchannel_req_between_cmd_test","virtual_seq started",UVM_DEBUG)
    m_vseq.start(null);
    `uvm_info("dce_qchannel_req_between_cmd_test","virtual_seq completed",UVM_DEBUG)
    phase.drop_objection(this, "dce_qchannel_test");
  end
  begin
  <% if(obj.DceInfo[obj.Id].usePma) { %>
    wait(qc_if.QACTIVE);
    repeat(5) begin
        wait(!qc_if.QACTIVE);
        <% if(obj.testBench == 'dce') { %>
        `ifndef VCS
        repeat(1)  @(posedge qc_if.clk); ///delay
        `else // `ifndef VCS
        repeat(2)  @(posedge qc_if.clk); ///delay
        `endif // `ifndef VCS ... `else ... 
        <% } else {%>
        repeat(1)  @(posedge qc_if.clk); ///delay
        <% } %>
        phase.raise_objection(this, $sformatf("Start q_cnl_seq"));
        //#300ns;       
        `uvm_info("dce_qchannel_req_between_cmd_test", "Q_SEQ_START",UVM_DEBUG)
        m_q_chnl_seq.start(m_env.m_q_chnl_agent.m_q_chnl_seqr);
        `uvm_info("dce_qchannel_req_between_cmd_test", "Q_SEQ_END",UVM_DEBUG)
        phase.drop_objection(this, $sformatf("Finish q_cnl_seq"));
        wait(qc_if.QACTIVE);
    end
  <% } %>
  end
  join
end

//dce_qchannel_multiple_request_test
if($test$plusargs("dce_qchannel_multiple_request_test"))begin
  fork
  begin        
    phase.raise_objection(this, "dce_qchannel_test");
    `uvm_info("dce_qchannel_multiple_request_test","virtual_seq started",UVM_DEBUG)
    m_vseq.start(null);
    `uvm_info("dce_qchannel_multiple_request_test","virtual_seq completed",UVM_DEBUG)
    phase.drop_objection(this, "dce_qchannel_test");
  end

  begin
  <% if(obj.DceInfo[obj.Id].usePma) { %>
    #1000ns;
    repeat(5) begin
        wait(!qc_if.QACTIVE);
        repeat(1)  @(posedge qc_if.clk); ///delay
        repeat($urandom_range(2,10)) begin
          phase.raise_objection(this, $sformatf("Start q_cnl_seq"));
          //#300ns;       
          `uvm_info("dce_qchannel_multiple_request_test", "Q_SEQ_START",UVM_DEBUG)
          m_q_chnl_seq.start(m_env.m_q_chnl_agent.m_q_chnl_seqr);
          `uvm_info("dce_qchannel_multiple_request_test", "Q_SEQ_END",UVM_DEBUG)
          phase.drop_objection(this, $sformatf("Finish q_cnl_seq"));
        end
        wait(qc_if.QACTIVE);
     end
  <% } %>
  end
  join
end

//dce_qchannel_reset_test
if($test$plusargs("dce_qchannel_reset_test"))begin
  fork
  begin        
    phase.raise_objection(this, "dce_qchannel_test");
    `uvm_info("dce_qchannel_reset_test","virtual_seq started",UVM_LOW)
    m_vseq.start(null);
    `uvm_info("dce_qchannel_reset_test","virtual_seq completed",UVM_LOW)
    phase.drop_objection(this, "dce_qchannel_test");
  end
  begin
  <% if(obj.DceInfo[obj.Id].usePma) { %>
    repeat(1) begin
        //to make sure there was already activity in DCE block
        wait(m_env_cfg.m_smi_agent_cfg.m_smi0_tx_port_config.m_vif.smi_msg_valid && m_env_cfg.m_smi_agent_cfg.m_smi0_tx_port_config.m_vif.smi_msg_ready);         
        
        //delay to make sure request to go into Q-state was when DCE was active and busy processing ops.
        repeat(3)  @(posedge qc_if.clk); 

        phase.raise_objection(this, $sformatf("Start q_cnl_seq"));
        `uvm_info("dce_qchannel_reset_test", "Q_SEQ_START",UVM_LOW)
        
        //start qchnl seq with QREQn = 0 to request to take the block into Q-state
        m_q_chnl_seq.start(m_env.m_q_chnl_agent.m_q_chnl_seqr);

        `uvm_info("dce_qchannel_reset_test", "Q_SEQ_END",UVM_LOW)
        phase.drop_objection(this, $sformatf("Finish q_cnl_seq"));
    end
  end
  begin
    repeat(1) begin
        //wait until DCE-block has entered into Q-state
        wait(!qc_if.QACCEPTn && !qc_if.QREQn && !qc_if.QACTIVE); 
        `uvm_info("dce_qchannel_reset_test", "DCE block entered Q-state",UVM_LOW)

        //give couple of cycles delay before asserting reset
        repeat(2)@(posedge qc_if.clk); 

        //toggle reset to get issue reset
        `uvm_info("dce_qchannel_reset_test", "Assert reset DCE block is in Q-state",UVM_LOW)
        toggle_rst.trigger();
        
        //be in reset for about 10 cycles
        repeat(10)@(posedge qc_if.clk); 
        
        //toggle reset to get out of reset
        `uvm_info("dce_qchannel_reset_test", "De-assert reset DCE block is in Q-state",UVM_LOW)
        toggle_rst.trigger();

        //once block is out of reset, QACTIVE will be asserted since DM starts some memory initialization sequence automatically after reset is deasserted.
        wait(qc_if.QACTIVE);
    end
  <% } %>
  end
  join
end


endtask: run_phase
