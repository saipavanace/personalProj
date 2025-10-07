`ifndef Q_CHANNEL_DII_TEST
`define Q_CHANNEL_DII_TEST



////////////////////////////////////////////////////////////////////////////////
//
// DII Test
//
////////////////////////////////////////////////////////////////////////////////

<%
    //all csr sequences
    var csr_seqs = [
        "dii_csr_id_reset_seq",
        "dii_csr_diicesar_seq",
        "dii_csr_diiuesar_seq",
        "dii_csr_diicecr_errDetEn_seq",
        "dii_csr_diicecr_errInt_seq",
        "dii_csr_diicecr_errThd_seq",
        "dii_csr_diicecr_sw_write_seq",
        "dii_csr_diicecr_noDetEn_seq",
        "dii_csr_diicecr_noIntEn_seq",
        "dii_csr_diicesr_rstNoVld_seq1",
        "dii_csr_diicesr_rstNoVld_seq2",
        "dii_csr_diicelr_address_seq",
        "dii_csr_diiuedr_MemErrDetEn_seq",
        "dii_csr_diiuedr_wrProtErrDetEn_seq",
        "dii_csr_diiuedr_rdProtErrDetEn_seq",
        "dii_csr_diiuedr_TransErrDetEn_seq",
        "dii_csr_diiueir_MemErrInt_seq",
        "dii_csr_diiueir_ProtErrInt_seq",
        "dii_csr_diiuedr_ProtErrThd_seq",
        "dii_csr_diiuecr_sw_write_seq",
        "dii_csr_diiuecr_noDetEn_seq",
        "dii_csr_diiuelr_seq1",
        "dii_csr_diiuelr_seq2",
        "dii_csr_diicelr_seq",
        "uvm_reg_hw_reset_seq",
        "uvm_reg_bit_bash_seq"
        //TODO seqs from dii_ral_csr_seq.sv
    ];
%>

//class dii_qchannel_test extends apb_base_test;
class dii_qchannel_test extends dii_base_test;

  `uvm_component_utils(dii_qchannel_test)

  uvm_event  forceClkgate;
  uvm_event  releaseClkgate;
  uvm_event toggle_rstn;
  virtual <%=obj.BlockId%>_q_chnl_if qc_if; 

<% if(obj.testBench == 'dii') { %>
 `ifdef VCS
  `define VCSorCDNS
 `elsif CDNS
  `define VCSorCDNS
 `endif 
<% }  %>
 <% if(obj.useResiliency) { %>
  // This event triggers if any request is killed when injecting errors
  // to drop all objections and get out of run_phase, resolves hanging tests issue
<% if(obj.testBench == 'dii') { %>
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

  uvm_object objectors_list[$];
  uvm_objection objection;
 <% } %>

  extern function new(string name = "dii_qchannel_test", uvm_component parent = null);
  extern function void build_phase(uvm_phase phase);
  extern virtual task run_phase(uvm_phase phase);

endclass: dii_qchannel_test

//------------------------------------------------------------------------------
// Constructor
//------------------------------------------------------------------------------
function dii_qchannel_test::new(string name = "dii_qchannel_test", uvm_component parent = null);
  super.new(name, parent);
  uvm_config_db#(virtual <%=obj.BlockId%>_q_chnl_if )::get(.cntxt(null),
                                        .inst_name( "" ),
                                        .field_name( "m_q_chnl_if" ),
                                        .value(qc_if ));
endfunction : new

function void dii_qchannel_test::build_phase(uvm_phase phase);
     super.build_phase(phase);
     toggle_rstn = new("toggle_rstn");
     if (!uvm_config_db#(uvm_event)::get( .cntxt(null),
                                     .inst_name(""),
                                     .field_name( "toggle_rstn" ),
                                     .value( toggle_rstn ))) begin
        `uvm_error("Q-chnl test", "Event toggle_rstn is not found")
     end
    m_env_cfg.m_axi_slave_agent_cfg.k_ace_slave_write_addr_chnl_delay_min.set_value(100);
    m_env_cfg.m_axi_slave_agent_cfg.k_ace_slave_write_addr_chnl_delay_max.set_value(500);
    m_env_cfg.m_axi_slave_agent_cfg.k_ace_slave_write_addr_chnl_burst_pct.set_value(100);
    m_env_cfg.m_axi_slave_agent_cfg.k_ace_slave_write_data_chnl_delay_min.set_value(100);
    m_env_cfg.m_axi_slave_agent_cfg.k_ace_slave_write_data_chnl_delay_max.set_value(500);
    m_env_cfg.m_axi_slave_agent_cfg.k_ace_slave_write_data_chnl_burst_pct.set_value(100);
    m_env_cfg.m_axi_slave_agent_cfg.k_ace_slave_write_resp_chnl_delay_min.set_value(100);
    m_env_cfg.m_axi_slave_agent_cfg.k_ace_slave_write_resp_chnl_delay_max.set_value(500);
    m_env_cfg.m_axi_slave_agent_cfg.k_ace_slave_write_resp_chnl_burst_pct.set_value(100);
    m_env_cfg.m_axi_slave_agent_cfg.k_ace_slave_read_addr_chnl_delay_min.set_value(100);
    m_env_cfg.m_axi_slave_agent_cfg.k_ace_slave_read_addr_chnl_delay_max.set_value(500);
    m_env_cfg.m_axi_slave_agent_cfg.k_ace_slave_read_addr_chnl_burst_pct.set_value(100);
    m_env_cfg.m_axi_slave_agent_cfg.k_ace_slave_read_data_chnl_delay_min.set_value(100);
    m_env_cfg.m_axi_slave_agent_cfg.k_ace_slave_read_data_chnl_delay_max.set_value(500);
    m_env_cfg.m_axi_slave_agent_cfg.k_ace_slave_read_data_chnl_burst_pct.set_value(100);
    m_env_cfg.m_axi_slave_agent_cfg.k_ace_slave_snoop_addr_chnl_delay_min.set_value(100);
    m_env_cfg.m_axi_slave_agent_cfg.k_ace_slave_snoop_addr_chnl_delay_max.set_value(500);
    m_env_cfg.m_axi_slave_agent_cfg.k_ace_slave_snoop_addr_chnl_burst_pct.set_value(100);
    m_env_cfg.m_axi_slave_agent_cfg.k_ace_slave_snoop_data_chnl_delay_min.set_value(100);
    m_env_cfg.m_axi_slave_agent_cfg.k_ace_slave_snoop_data_chnl_delay_max.set_value(500);
    m_env_cfg.m_axi_slave_agent_cfg.k_ace_slave_snoop_data_chnl_burst_pct.set_value(100);
    m_env_cfg.m_axi_slave_agent_cfg.k_ace_slave_snoop_resp_chnl_delay_min.set_value(100);
    m_env_cfg.m_axi_slave_agent_cfg.k_ace_slave_snoop_resp_chnl_delay_max.set_value(500);
    m_env_cfg.m_axi_slave_agent_cfg.k_ace_slave_snoop_resp_chnl_burst_pct.set_value(100);
    <%for (var i = 0; i < obj.DiiInfo[obj.Id].nSmiTx; i++) { %>
      m_env_cfg.m_smi_agent_cfg.m_smi<%=i%>_rx_port_config.k_delay_min.set_value(100);
      m_env_cfg.m_smi_agent_cfg.m_smi<%=i%>_rx_port_config.k_delay_max.set_value(500);
      m_env_cfg.m_smi_agent_cfg.m_smi<%=i%>_rx_port_config.k_burst_pct.set_value(100);
    <% } %>
    <%for (var i = 0; i < obj.DiiInfo[obj.Id].nSmiRx; i++) { %>
      m_env_cfg.m_smi_agent_cfg.m_smi<%=i%>_tx_port_config.k_delay_min.set_value(1000);
      m_env_cfg.m_smi_agent_cfg.m_smi<%=i%>_tx_port_config.k_delay_max.set_value(5000);
      m_env_cfg.m_smi_agent_cfg.m_smi<%=i%>_tx_port_config.k_burst_pct.set_value(100);
    <% } %>
      m_env_cfg.m_smi_agent_cfg.m_smi0_tx_port_config.k_burst_pct.set_value(50);

endfunction:build_phase

//------------------------------------------------------------------------------
// Run Phase
//------------------------------------------------------------------------------
task dii_qchannel_test::run_phase(uvm_phase phase);
  uvm_objection uvm_obj = phase.get_objection();
  
  common_knob_list m_common_knob_list = common_knob_list::get_instance();
  
  uvm_reg_sequence csr_seq;
  dii_seq  smi_seq = dii_seq::type_id::create("smi_seq");

  q_chnl_seq m_q_chnl_seq;
  int time_bw_Q_chnl_req = 100;

`ifndef USE_VIP_SNPS
  axi_slave_read_seq   m_slave_read_seq   = axi_slave_read_seq::type_id::create("slave_read_seq");
  axi_slave_write_seq  m_slave_write_seq  = axi_slave_write_seq::type_id::create("slave_write_seq");

  m_slave_read_seq.prob_ace_rd_resp_error = m_args.prob_ace_rd_resp_error;
  m_slave_write_seq.prob_ace_wr_resp_error = m_args.prob_ace_wr_resp_error;
`endif

  `ifdef USE_VIP_SNPS

  m_axi_slave_mem_response_sequence =  axi_slave_mem_response_sequence::type_id::create("m_axi_slave_mem_response_sequence");

  m_axi_slave_mem_response_sequence.prob_ace_rd_resp_error = m_args.prob_ace_rd_resp_error;
  m_axi_slave_mem_response_sequence.prob_ace_wr_resp_error = m_args.prob_ace_wr_resp_error;
  
  m_axi_slave_mem_response_sequence.user_delay_en = 1; 
  m_axi_slave_mem_response_sequence.slave_write_addr_chnl_delay_min = 100 ; 
  m_axi_slave_mem_response_sequence.slave_write_addr_chnl_delay_max = 500 ;
  m_axi_slave_mem_response_sequence.slave_write_data_chnl_delay_min = 100 ;
  m_axi_slave_mem_response_sequence.slave_write_data_chnl_delay_max = 500 ; 
  m_axi_slave_mem_response_sequence.slave_write_resp_chnl_delay_min = 100 ;
  m_axi_slave_mem_response_sequence.slave_write_resp_chnl_delay_max = 500 ;
  m_axi_slave_mem_response_sequence.slave_read_addr_chnl_delay_min  = 100 ;
  m_axi_slave_mem_response_sequence.slave_read_addr_chnl_delay_max  = 500 ;
  m_axi_slave_mem_response_sequence.slave_read_data_chnl_delay_min  = 100 ;
  m_axi_slave_mem_response_sequence.slave_read_data_chnl_delay_max  = 500 ;

`endif // `ifdef USE_VIP_SNPS
  if(!uvm_config_db#(uvm_event)::get(this,"*","forceClkgate",forceClkgate))begin
    `uvm_error("dii_qchannel_test","could not get event forceClkgate");
  end

  if(!uvm_config_db#(uvm_event)::get(this,"*","releaseClkgate",releaseClkgate))begin
    `uvm_error("dii_qchannel_test","could not get event releaseClkgate");
  end

`ifndef USE_VIP_SNPS
      m_slave_read_seq.m_read_addr_chnl_seqr   = m_env.m_axi_slave_agent.m_read_addr_chnl_seqr;
      m_slave_read_seq.m_read_data_chnl_seqr   = m_env.m_axi_slave_agent.m_read_data_chnl_seqr;
      m_slave_read_seq.m_memory_model          = m_axi_memory_model;  //not from cli
      m_slave_write_seq.m_write_addr_chnl_seqr = m_env.m_axi_slave_agent.m_write_addr_chnl_seqr;
      m_slave_write_seq.m_write_data_chnl_seqr = m_env.m_axi_slave_agent.m_write_data_chnl_seqr;
      m_slave_write_seq.m_write_resp_chnl_seqr = m_env.m_axi_slave_agent.m_write_resp_chnl_seqr;
      m_slave_write_seq.m_memory_model         = m_axi_memory_model;    //not from cli
`endif


    //instantiate the csr seq
<% if(obj.testBench == 'dii') { %>
`ifndef VCSorCDNS
    if (m_args.k_csr_seq) begin
`else // `ifndef VCSorCDNS
    if (m_args.k_csr_seq != "") begin
`endif // `ifndef VCSorCDNS ... `else ... 
<% } else {%>
    if (m_args.k_csr_seq) begin
<% } %>
    <% for (i in csr_seqs) { %>
        if (m_args.k_csr_seq == "<%=csr_seqs[i]%>")
            csr_seq = <%=csr_seqs[i]%>::type_id::create("csr_seq"); 
    <% } %>
        csr_seq.model = m_regs;
    end

    m_env.time_bw_Q_chnl_req = time_bw_Q_chnl_req;
    m_q_chnl_seq = q_chnl_seq::type_id::create("m_q_chnl_seq");
    `uvm_info($sformatf("%m"), $sformatf("Test Q-Channel objId=%0d, name=%s config=%0d",
                                         <%=obj.Id%>, "<%=obj.DiiInfo[obj.Id].strRtlNamePrefix%>", <%=obj.DiiInfo[obj.Id].configuration%>), UVM_LOW)
    <% console.log('ObjId= ' + ' ' + obj.Id + ' Name = ' + obj.DiiInfo[obj.Id].strRtlNamePrefix) %>

    uvm_resource_db#(bit)::set({"REG::",m_regs.<%=obj.DiiInfo[obj.Id].strRtlNamePrefix%>.DIIUIDR.get_full_name()}, "NO_REG_TESTS", 1,this);
    uvm_resource_db#(bit)::set({"REG::",m_regs.<%=obj.DiiInfo[obj.Id].strRtlNamePrefix%>.DIIUFUIDR.get_full_name()}, "NO_REG_TESTS", 1,this);

    //print all knobs
    m_common_knob_list.print();

    //execute test
    uvm_obj.set_drain_time(null, 10us);

   <% if(obj.useResiliency) { %>
<% if(obj.testBench == 'dii') { %>
`ifndef VCS
    if (!uvm_config_db#(event)::get(this,
                                   .inst_name ( "" ),
                                   .field_name( "kill_test" ),
                                   .value( kill_test ))) begin
       `uvm_error( "dii_qchannel_test run_phase", "kill_test event not found" )
    end

    if (!uvm_config_db#(event)::get(this,
                                   .inst_name ( "" ),
                                   .field_name( "raise_obj_for_resiliency_test" ),
                                   .value( raise_obj_for_resiliency_test ))) begin
       `uvm_error( "dii_qchannel_test run_phase", "raise_obj_for_resiliency_test event not found" )
    end

    if (!uvm_config_db#(event)::get(this,
                                   .inst_name ( "" ),
                                   .field_name( "drop_obj_for_resiliency_test" ),
                                   .value( drop_obj_for_resiliency_test ))) begin
       `uvm_error( "dii_qchannel_test run_phase", "drop_obj_for_resiliency_test event not found" )
    end
`else // `ifndef VCS
    if (!uvm_config_db#(uvm_event)::get(this,
                                   .inst_name ( "" ),
                                   .field_name( "kill_test" ),
                                   .value( kill_test ))) begin
       `uvm_error( "dii_qchannel_test run_phase", "kill_test event not found" )
    end else begin
       `uvm_info( "dii_qchannel_test run_phase", "kill_test event found",UVM_DEBUG)
       if(kill_test==null)
         `uvm_error( "dii_qchannel_test run_phase", "kill_test event is null" )
    end

    if (!uvm_config_db#(uvm_event)::get(this,
                                   .inst_name ( "" ),
                                   .field_name( "raise_obj_for_resiliency_test" ),
                                   .value( raise_obj_for_resiliency_test ))) begin
       `uvm_error( "dii_qchannel_test run_phase", "raise_obj_for_resiliency_test event not found" )
    end else begin
       `uvm_info( "dii_qchannel_test run_phase", "raise_obj_for_resiliency_test event found",UVM_DEBUG)
       if(raise_obj_for_resiliency_test==null)
         `uvm_error( "dii_qchannel_test run_phase", "raise_obj_for_resiliency_test event is null" )
    end

    if (!uvm_config_db#(uvm_event)::get(this,
                                   .inst_name ( "" ),
                                   .field_name( "drop_obj_for_resiliency_test" ),
                                   .value( drop_obj_for_resiliency_test ))) begin
       `uvm_error( "dii_qchannel_test run_phase", "drop_obj_for_resiliency_test event not found" )
    end else begin
       `uvm_info( "dii_qchannel_test run_phase", "drop_obj_for_resiliency_test event found",UVM_DEBUG)
       if(drop_obj_for_resiliency_test==null)
         `uvm_error( "dii_qchannel_test run_phase", "drop_obj_for_resiliency_test event is null" )
    end
`endif // `ifndef VCS ... `else ... 
<% } else {%>
    if (!uvm_config_db#(event)::get(this,
                                   .inst_name ( "" ),
                                   .field_name( "kill_test" ),
                                   .value( kill_test ))) begin
       `uvm_error( "dii_qchannel_test run_phase", "kill_test event not found" )
    end

    if (!uvm_config_db#(event)::get(this,
                                   .inst_name ( "" ),
                                   .field_name( "raise_obj_for_resiliency_test" ),
                                   .value( raise_obj_for_resiliency_test ))) begin
       `uvm_error( "dii_qchannel_test run_phase", "raise_obj_for_resiliency_test event not found" )
    end

    if (!uvm_config_db#(event)::get(this,
                                   .inst_name ( "" ),
                                   .field_name( "drop_obj_for_resiliency_test" ),
                                   .value( drop_obj_for_resiliency_test ))) begin
       `uvm_error( "dii_qchannel_test run_phase", "drop_obj_for_resiliency_test event not found" )
    end
<% } %>


    fork
       begin
          `uvm_info("run_main", "waiting for kill_test event to trigger",UVM_DEBUG)
<% if(obj.testBench == 'dii') { %>
`ifndef VCS
          @kill_test;
`else // `ifndef VCS
          kill_test.wait_trigger();
`endif // `ifndef VCS ... `else ... 
<% } else {%>
          @kill_test;
<% } %>

          `uvm_info("run_main", "kill_test event triggered",UVM_DEBUG)

          // Fetching the objection from current phase
          objection = phase.get_objection();
 
          // Collecting all the objectors which currently have objections raised
          objection.get_objectors(objectors_list);
 
          // Dropping the objections forcefully
          foreach(objectors_list[i]) begin
            `uvm_info("run_main", $sformatf("objection count %d", objection.get_objection_count(objectors_list[i])),UVM_DEBUG);
            while(objection.get_objection_count(objectors_list[i]) != 0) begin
              phase.drop_objection(objectors_list[i], "dropping objections to kill the test");
            end
          end
       end
       begin
<% if(obj.testBench == 'dii') { %>
`ifndef VCS
          `uvm_info("run_main", "waiting for raise_obj_for_resiliency_test event to trigger",UVM_DEBUG)
          @raise_obj_for_resiliency_test;
          `uvm_info("run_main", "raise_obj_for_resiliency_test event triggered",UVM_DEBUG)
          phase.raise_objection(this, "raising objection for resiliency test");
 
          @drop_obj_for_resiliency_test;
          phase.drop_objection(this, "dropping resiliency test objection");
`else // `ifndef VCS
          `uvm_info("run_main", "waiting for raise_obj_for_resiliency_test event to trigger",UVM_DEBUG)
          raise_obj_for_resiliency_test.wait_trigger();
          `uvm_info("run_main", "raise_obj_for_resiliency_test event triggered",UVM_DEBUG)
          phase.raise_objection(this, "raising objection for resiliency test");
 
          drop_obj_for_resiliency_test.wait_trigger();
          phase.drop_objection(this, "dropping resiliency test objection");
`endif // `ifndef VCS ... `else ... 
<% } else {%>
          `uvm_info("run_main", "waiting for raise_obj_for_resiliency_test event to trigger",UVM_DEBUG)
          @raise_obj_for_resiliency_test;
          `uvm_info("run_main", "raise_obj_for_resiliency_test event triggered",UVM_DEBUG)
          phase.raise_objection(this, "raising objection for resiliency test");
 
          @drop_obj_for_resiliency_test;
          phase.drop_objection(this, "dropping resiliency test objection");
<% } %>

       end
    join_none
   <% } %>

//Sanity test
if($test$plusargs("dii_qchannel_sanity_test"))begin
  //start passive seqs
  fork
  `ifndef USE_VIP_SNPS
     m_slave_read_seq.start(null);
     m_slave_write_seq.start(null);
  `endif
  `ifdef USE_VIP_SNPS
     m_axi_slave_mem_response_sequence.start(m_env.amba_system_env.axi_system[0].slave[0].sequencer);
 `endif // USE_VIP_SNPS
  join_none
  //start active seqs
  fork
  begin
    phase.raise_objection(this, "Start smi_seq");
    `uvm_info("dii_qchannel_sanity_test","test_seq started",UVM_DEBUG)
    smi_seq.start(m_env.m_smi_agent.m_smi_virtual_seqr);
    `uvm_info("dii_qchannel_sanity_test","test_seq ended",UVM_DEBUG)
    phase.drop_objection(this, "Finish smi_seq");
  end
  join
  `uvm_info("dii_qchannel_sanity_test","fork_join ended",UVM_DEBUG)
 <% if(obj.DiiInfo[obj.Id].usePma) { %>
  phase.raise_objection(this, $sformatf("Start q_cnl_seq"));
  #10ns;       
  `uvm_info("dii_qchannel_sanity_test", "Q_SEQ_START",UVM_DEBUG)
  m_q_chnl_seq.start(m_env.m_q_chnl_agent.m_q_chnl_seqr);
  `uvm_info("dii_qchannel_sanity_test", "Q_SEQ_END",UVM_DEBUG)
  phase.drop_objection(this, $sformatf("Finish q_cnl_seq"));
  `uvm_info("run_phase", "all active seqs completed",UVM_DEBUG)
 <% } %>
end

//dii_qchannel_req_during_cmd_test
if($test$plusargs("dii_qchannel_req_during_cmd_test"))begin
  //start passive seqs
  fork
  `ifndef USE_VIP_SNPS
    m_slave_read_seq.start(null);
    m_slave_write_seq.start(null);
  `endif
  `ifdef USE_VIP_SNPS
    m_axi_slave_mem_response_sequence.start(m_env.amba_system_env.axi_system[0].slave[0].sequencer);
  `endif // USE_VIP_SNPS
  join_none
  //start active seqs
  fork
     begin
         phase.raise_objection(this, "Start smi_seq");
         `uvm_info("dii_qchannel_req_during_cmd_test","test_seq started",UVM_DEBUG)
         smi_seq.start(m_env.m_smi_agent.m_smi_virtual_seqr);
         `uvm_info("dii_qchannel_req_during_cmd_test","test_seq ended",UVM_DEBUG)
         phase.drop_objection(this, "Finish smi_seq");
     end
     begin
 <% if(obj.DiiInfo[obj.Id].usePma) { %>
     #500ns;
     repeat(5) begin
          wait(qc_if.QACTIVE); 
      repeat(1)  @(posedge qc_if.clk); ///delay     
         phase.raise_objection(this, $sformatf("Start q_cnl_seq"));
         `uvm_info("dii_qchannel_req_during_cmd_test", "Q_SEQ_START",UVM_DEBUG)
          m_q_chnl_seq.start(m_env.m_q_chnl_agent.m_q_chnl_seqr);
          `uvm_info("dii_qchannel_req_during_cmd_test", "Q_SEQ_END",UVM_DEBUG)
          phase.drop_objection(this, $sformatf("Finish q_cnl_seq"));
      end
 <% } %>
     end
  join
  `uvm_info("dii_qchannel_req_during_cmd_test","fork_join ended",UVM_DEBUG)
  `uvm_info("run_phase", "all active seqs completed",UVM_DEBUG)
end
//dii_qchannel_req_between_cmd_test
if($test$plusargs("dii_qchannel_req_between_cmd_test"))begin
  //start passive seqs
  fork
  `ifndef USE_VIP_SNPS
     m_slave_read_seq.start(null);
     m_slave_write_seq.start(null);
  `endif
  `ifdef USE_VIP_SNPS
     m_axi_slave_mem_response_sequence.start(m_env.amba_system_env.axi_system[0].slave[0].sequencer);
 `endif // USE_VIP_SNPS
  join_none
  //start active seqs
  fork
  begin
    phase.raise_objection(this, "Start smi_seq");
    `uvm_info("dii_qchannel_req_between_cmd_test","test_seq started",UVM_DEBUG)
    smi_seq.start(m_env.m_smi_agent.m_smi_virtual_seqr);
    `uvm_info("dii_qchannel_req_between_cmd_test","test_seq ended",UVM_DEBUG)
    phase.drop_objection(this, "Finish smi_seq");
  end
  begin
 <% if(obj.DiiInfo[obj.Id].usePma) { %>
    #500ns;
    repeat(10) begin
        wait(!qc_if.QACTIVE);
        repeat(1)  @(posedge qc_if.clk); ///delay
        phase.raise_objection(this, $sformatf("Start q_cnl_seq"));
        `uvm_info("dii_qchannel_req_between_cmd_test", "Q_SEQ_START",UVM_DEBUG)
        m_q_chnl_seq.start(m_env.m_q_chnl_agent.m_q_chnl_seqr);
        `uvm_info("dii_qchannel_req_between_cmd_test", "Q_SEQ_END",UVM_DEBUG)
        phase.drop_objection(this, $sformatf("Finish q_cnl_seq"));
        wait(qc_if.QACTIVE);
     end
 <% } %>
  end
  join
  `uvm_info("dii_qchannel_req_between_cmd_test","fork_join ended",UVM_DEBUG)
  `uvm_info("run_phase", "all active seqs completed",UVM_DEBUG)
end
//dii_qchannel_multiple_request_test
if($test$plusargs("dii_qchannel_multiple_request_test"))begin
  //start passive seqs
  fork
  `ifndef USE_VIP_SNPS
     m_slave_read_seq.start(null);
     m_slave_write_seq.start(null);
  `endif
  `ifdef USE_VIP_SNPS
     m_axi_slave_mem_response_sequence.start(m_env.amba_system_env.axi_system[0].slave[0].sequencer);
 `endif // USE_VIP_SNPS
  join_none
  //start active seqs
  fork
  begin
    phase.raise_objection(this, "Start smi_seq");
    `uvm_info("dii_qchannel_multiple_request_test","test_seq started",UVM_DEBUG)
    smi_seq.start(m_env.m_smi_agent.m_smi_virtual_seqr);
    `uvm_info("dii_qchannel_multiple_request_test","test_seq ended",UVM_DEBUG)
    phase.drop_objection(this, "Finish smi_seq");
  end
  begin
 <% if(obj.DiiInfo[obj.Id].usePma) { %>
  #500ns;
  repeat(50) begin
       wait(!qc_if.QACTIVE);
      repeat(1)  @(posedge qc_if.clk); ///delay
      repeat($urandom_range(2,10)) begin
         phase.raise_objection(this, $sformatf("Start q_cnl_seq"));
         `uvm_info("dii_qchannel_multiple_request_test", "Q_SEQ_START",UVM_DEBUG)
         m_q_chnl_seq.start(m_env.m_q_chnl_agent.m_q_chnl_seqr);
         `uvm_info("dii_qchannel_multiple_request_test", "Q_SEQ_END",UVM_DEBUG)
         phase.drop_objection(this, $sformatf("Finish q_cnl_seq"));
      end
      wait(qc_if.QACTIVE);
  end
 <% } %>
  end
  join
  `uvm_info("dii_qchannel_multiple_request_test","fork_join ended",UVM_DEBUG)
  `uvm_info("run_phase", "all active seqs completed",UVM_DEBUG)
end

//dii_qchannel_reset_test
if($test$plusargs("dii_qchannel_reset_test"))begin
  //start passive seqs
  fork
  `ifndef USE_VIP_SNPS
     m_slave_read_seq.start(null);
     m_slave_write_seq.start(null);
  `endif
  `ifdef USE_VIP_SNPS
     m_axi_slave_mem_response_sequence.start(m_env.amba_system_env.axi_system[0].slave[0].sequencer);
 `endif // USE_VIP_SNPS
  join_none
  //start active seqs
  fork
  begin
    phase.raise_objection(this, "Start smi_seq");
    `uvm_info("dii_qchannel_reset_test","test_seq started",UVM_DEBUG)
    smi_seq.start(m_env.m_smi_agent.m_smi_virtual_seqr);
    `uvm_info("dii_qchannel_reset_test","test_seq ended",UVM_DEBUG)
    phase.drop_objection(this, "Finish smi_seq");
  end
  begin
 <% if(obj.DiiInfo[obj.Id].usePma) { %>
    #500ns;
    repeat(5) begin
        wait(!qc_if.QACTIVE);
        repeat(1)  @(posedge qc_if.clk); ///delay
        phase.raise_objection(this, $sformatf("Start q_cnl_seq"));
        `uvm_info("dii_qchannel_reset_test", "Q_SEQ_START",UVM_DEBUG)
        m_q_chnl_seq.start(m_env.m_q_chnl_agent.m_q_chnl_seqr);
        `uvm_info("dii_qchannel_reset_test", "Q_SEQ_END",UVM_DEBUG)
        phase.drop_objection(this, $sformatf("Finish q_cnl_seq"));
        wait(qc_if.QACTIVE);
     end
  end
  begin
    repeat(1) begin
        wait(!qc_if.QACCEPTn && !qc_if.QREQn && !qc_if.QACTIVE);
        repeat(2)@(posedge qc_if.clk); 
        toggle_rstn.trigger();
         #30ns;//repeat(3)@(posedge qc_if.clk); 
        toggle_rstn.trigger();
        wait(qc_if.QACTIVE);
    end
 <% } %>
  end
  join
  `uvm_info("dii_qchannel_reset_test","fork_join ended",UVM_DEBUG)
  `uvm_info("run_phase", "all active seqs completed",UVM_DEBUG)
end

endtask : run_phase

////////////////////////////////////////////////////////////////////////////////

`endif // Q_CHANNEL_DII_TEST
