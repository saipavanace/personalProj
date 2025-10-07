`ifndef <%=obj.DiiInfo[obj.Id].strRtlNamePrefix%>_TEST
`define <%=obj.DiiInfo[obj.Id].strRtlNamePrefix%>_TEST
<% if(obj.testBench == "dii" || obj.testBench == "cust_tb") { %> 
import <%=obj.DiiInfo[obj.Id].strRtlNamePrefix%>_concerto_register_map_pkg::*; 
<% } %>



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
        "dii_csr_enable_err_detection_interrupts_resiliency_seq",
        "dii_csr_diiuelr_seq1",
        "dii_csr_diiuelr_seq2",
        "dii_csr_diicelr_seq",
        "uvm_reg_hw_reset_seq",
        "uvm_reg_bit_bash_seq",
        "access_unmapped_csr_addr",
        "dii_csr_diiueir_MemErrInt_skidbuf_seq",
        "dii_csr_diicecr_errThd_skidbuf_seq",
        "dii_csr_diicecr_noDetEn_skidbuf_seq",
        "dii_csr_diiengdbr_seq",
        //TODO seqs from dii_ral_csr_seq.sv
    ];
%>

//class dii_test extends apb_base_test;
class dii_test extends dii_base_test;

  `uvm_component_utils(dii_test)

  uvm_event  forceClkgate;
  uvm_event  releaseClkgate;
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
  uvm_event kill_test_1;
  event raise_obj_for_resiliency_test;
  event drop_obj_for_resiliency_test;
`else // `ifndef VCS
  uvm_event kill_test;
  uvm_event kill_test_1;
  uvm_event raise_obj_for_resiliency_test;
  uvm_event drop_obj_for_resiliency_test;
`endif // `ifndef VCS ... `else ... 
<% } else {%>
  event kill_test_1;
  event kill_test;
  event raise_obj_for_resiliency_test;
  event drop_obj_for_resiliency_test;
<% } %>

  uvm_object objectors_list[$];
  uvm_objection objection;
 <% } %>
 <% if ((obj.useResiliency) && (obj.testBench != "fsys")) { %>
 /*
  *demote handle to suppress any error coming for the resiliency
  *testing. error form the fault_injector_checker will show, but
  *others will be converted to info
  */
 report_catcher_demoter_base fault_injector_checker_demoter_h;
 <% } %>

  virtual <%=obj.DiiInfo[obj.Id].strRtlNamePrefix%>_axi_if m_<%=obj.DiiInfo[obj.Id].strRtlNamePrefix%>_axi_vif;
  int overflow_buffer_test;
  int new_scenario;
  int overflow_buffer_test_2;
  int unblock_if_after_delay;
  bit buffer_sel;


  extern function new(string name = "dii_test", uvm_component parent = null);
  extern virtual function void build_phase(uvm_phase phase);
  extern virtual task run_phase(uvm_phase phase);

  task main_seq_pre_hook(uvm_phase phase);
    //`uvm_info("Vyshak", "Vyshak STARTING main_seq_pre_hook", UVM_MEDIUM)
    if(!$value$plusargs("overflow_buffer_test=%d", overflow_buffer_test))begin
      overflow_buffer_test = 0;
    end
     if(!$value$plusargs("new_scenario=%d", new_scenario))begin
      new_scenario = 0;
    end
    if(!$value$plusargs("unblock_if_after_delay=%d", unblock_if_after_delay))begin
      unblock_if_after_delay = 0;
    end
    if(!$value$plusargs("overflow_buffer_test_2=%d", overflow_buffer_test_2))begin
      overflow_buffer_test_2 = 0;
    end

    if(overflow_buffer_test ||  new_scenario) begin 
      if(!uvm_config_db #(virtual <%=obj.DiiInfo[obj.Id].strRtlNamePrefix%>_axi_if)::get(this, "", "m_<%=obj.DiiInfo[obj.Id].strRtlNamePrefix%>_axi_slv_if",  m_<%=obj.DiiInfo[obj.Id].strRtlNamePrefix%>_axi_vif)) begin //vyshak
        `uvm_error(get_full_name(), $sformatf("Cannot find m_dii0_axi_slv_if in config db")); 
      end
    fork
      begin
        if(!new_scenario) begin
          `uvm_info("Vyshak", "Vyshak new and going to stall and make sure all reads are stalled ", UVM_MEDIUM)
          m_<%=obj.DiiInfo[obj.Id].strRtlNamePrefix%>_axi_vif.en_ar_stall = 1;
          m_<%=obj.DiiInfo[obj.Id].strRtlNamePrefix%>_axi_vif.enable_r_stall  = 1;
          m_<%=obj.DiiInfo[obj.Id].strRtlNamePrefix%>_axi_vif.stall_ar_chnl_till_en_ar_stall_deassrt = 1;
        end

          if(overflow_buffer_test_2 || new_scenario)begin
            `uvm_info("Vyshak","Vyshak and blocking write axi interface for some delay of 30000ns in test", UVM_MEDIUM)
            m_<%=obj.DiiInfo[obj.Id].strRtlNamePrefix%>_axi_vif.en_aw_stall = 1;
            m_<%=obj.DiiInfo[obj.Id].strRtlNamePrefix%>_axi_vif.en_w_stall = 1;
            m_<%=obj.DiiInfo[obj.Id].strRtlNamePrefix%>_axi_vif.enable_b_stall = 1;
            m_<%=obj.DiiInfo[obj.Id].strRtlNamePrefix%>_axi_vif.stall_aw_chnl_till_en_aw_stall_deassrt = 1;
            m_<%=obj.DiiInfo[obj.Id].strRtlNamePrefix%>_axi_vif.stall_w_chnl_till_en_w_stall_deassrt = 1;
          end
         if(unblock_if_after_delay)begin
           #30000ns
           if(!new_scenario) begin
             `uvm_info("Vyshak","Vyshak and unblocking read axi interface after some delay in test", UVM_MEDIUM)
              m_<%=obj.DiiInfo[obj.Id].strRtlNamePrefix%>_axi_vif.en_ar_stall = 0;
              m_<%=obj.DiiInfo[obj.Id].strRtlNamePrefix%>_axi_vif.enable_r_stall  = 0;
              m_<%=obj.DiiInfo[obj.Id].strRtlNamePrefix%>_axi_vif.stall_ar_chnl_till_en_ar_stall_deassrt = 0;
           end

            if(overflow_buffer_test_2 || new_scenario)begin
              `uvm_info("Vyshak","Vyshak and unblocking write axi interface after some delay in test", UVM_MEDIUM)
              m_<%=obj.DiiInfo[obj.Id].strRtlNamePrefix%>_axi_vif.en_aw_stall = 0;
              m_<%=obj.DiiInfo[obj.Id].strRtlNamePrefix%>_axi_vif.en_w_stall = 0;
              m_<%=obj.DiiInfo[obj.Id].strRtlNamePrefix%>_axi_vif.enable_b_stall = 0;
              m_<%=obj.DiiInfo[obj.Id].strRtlNamePrefix%>_axi_vif.stall_aw_chnl_till_en_aw_stall_deassrt = 0;
              m_<%=obj.DiiInfo[obj.Id].strRtlNamePrefix%>_axi_vif.stall_w_chnl_till_en_w_stall_deassrt = 0;
            end // if(overflow_buffer_test_2)
         end // if(unblock_if_delay)
      end
    join_none
   end //if(overflow_buffer_test)

  endtask


endclass: dii_test

//------------------------------------------------------------------------------
// Constructor
//------------------------------------------------------------------------------
function dii_test::new(string name = "dii_test", uvm_component parent = null);
  super.new(name, parent);
endfunction : new

function void dii_test::build_phase(uvm_phase phase);
  <% if ((obj.useResiliency) && (obj.testBench != "fsys")) { %>
  if($test$plusargs("collect_resiliency_cov")) begin
    set_type_override_by_type(.original_type(<%=obj.DiiInfo[obj.Id].strRtlNamePrefix%>_smi_agent_pkg::smi_coverage::get_type()), .override_type(smi_resiliency_coverage::get_type()), .replace(1));
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
      fault_injector_checker_demoter_h.demote_uvm_fatal = 1;
      fault_injector_checker_demoter_h.not_of = 1;
      fault_injector_checker_demoter_h.build();
      `uvm_info(get_name(), $sformatf("Registering demoter class{%0s} for resiliency error ignore", fault_injector_checker_demoter_h.get_name()), UVM_LOW)
      uvm_report_cb::add(null, fault_injector_checker_demoter_h);
    end
  <% } %>
endfunction: build_phase

//------------------------------------------------------------------------------
// Run Phase
//------------------------------------------------------------------------------
task dii_test::run_phase(uvm_phase phase);
  uvm_objection uvm_obj = phase.get_objection();
  
  common_knob_list m_common_knob_list = common_knob_list::get_instance();
  uvm_event_pool ev_pool = uvm_event_pool::get_global_pool();

<% if (obj.useResiliency) { %>
   uvm_event ev_bist_reset_done = ev_pool.get("bist_reset_done");
<% } %>

  uvm_reg_sequence csr_seq;

  dii_seq  smi_seq = dii_seq::type_id::create("smi_seq");

<% if (obj.DiiInfo[obj.Id].nAddrTransRegisters > 0) { %>
  dii_csr_addr_trans_seq m_addr_trans_seq;
<% } %>

  dii_csr_cctrlr_seq      m_cctrlr_seq;
  <% if (obj.DiiInfo[obj.Id].nExclusiveEntries  > 0) { %>
  dii_csr_sys_event_seq   m_sys_event_seq;
  <% } %>
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


`endif // `ifdef USE_VIP_SNPS
  if(!uvm_config_db#(uvm_event)::get(this,"*","forceClkgate",forceClkgate))begin
    `uvm_error("dii_test","could not get event forceClkgate");
  end

  if(!uvm_config_db#(uvm_event)::get(this,"*","releaseClkgate",releaseClkgate))begin
    `uvm_error("dii_test","could not get event releaseClkgate");
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

    //exclude from automated register testing unit ids, which are passed from tb_top 
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
       `uvm_error( "dii_test run_phase", "kill_test event not found" )
    end

    if (!uvm_config_db#(event)::get(this,
                                   .inst_name ( "" ),
                                   .field_name( "raise_obj_for_resiliency_test" ),
                                   .value( raise_obj_for_resiliency_test ))) begin
       `uvm_error( "dii_test run_phase", "raise_obj_for_resiliency_test event not found" )
    end

    if (!uvm_config_db#(event)::get(this,
                                   .inst_name ( "" ),
                                   .field_name( "drop_obj_for_resiliency_test" ),
                                   .value( drop_obj_for_resiliency_test ))) begin
       `uvm_error( "dii_test run_phase", "drop_obj_for_resiliency_test event not found" )
    end
`else // `ifndef VCS
    if (!uvm_config_db#(uvm_event)::get(this,
                                   .inst_name ( "" ),
                                   .field_name( "kill_test" ),
                                   .value( kill_test ))) begin
       `uvm_error( "dii_test run_phase", "kill_test event not found" )
    end  else begin
       `uvm_info( "dii_test run_phase", "kill_test event found",UVM_DEBUG)
       if(kill_test==null)
         `uvm_error( "dii_test run_phase", "kill_test event is null" )
    end
    
    if($test$plusargs("uncorr_skid_buffer_test"))begin
      if (!uvm_config_db#(uvm_event)::get(this, "", "kill_test_1", kill_test_1)) begin
        `uvm_error("TEST", "kill_test_1 not found in configuration database");
      end else begin
        `uvm_info( "SKIDBUFERROR", "kill_test_1 event found",UVM_HIGH);
      end
    end


    if (!uvm_config_db#(uvm_event)::get(this,
                                   .inst_name ( "" ),
                                   .field_name( "raise_obj_for_resiliency_test" ),
                                   .value( raise_obj_for_resiliency_test ))) begin
       `uvm_error( "dii_test run_phase", "raise_obj_for_resiliency_test event not found" )
    end  else begin
       `uvm_info( "dii_test run_phase", "raise_obj_for_resiliency_test event found",UVM_DEBUG)
       if(raise_obj_for_resiliency_test==null)
         `uvm_error( "dii_test run_phase", "raise_obj_for_resiliency_test event is null" )
    end

    if (!uvm_config_db#(uvm_event)::get(this,
                                   .inst_name ( "" ),
                                   .field_name( "drop_obj_for_resiliency_test" ),
                                   .value( drop_obj_for_resiliency_test ))) begin
       `uvm_error( "dii_test run_phase", "drop_obj_for_resiliency_test event not found" )
    end  else begin
       `uvm_info( "dii_test run_phase", "drop_obj_for_resiliency_test event found",UVM_DEBUG)
       if(drop_obj_for_resiliency_test==null)
         `uvm_error( "dii_test run_phase", "drop_obj_for_resiliency_test event is null" )
    end
`endif // `ifndef VCS ... `else ... 
<% } else {%>
    if (!uvm_config_db#(event)::get(this,
                                   .inst_name ( "" ),
                                   .field_name( "kill_test" ),
                                   .value( kill_test ))) begin
       `uvm_error( "dii_test run_phase", "kill_test event not found" )
    end

    if (!uvm_config_db#(event)::get(this,
                                   .inst_name ( "" ),
                                   .field_name( "raise_obj_for_resiliency_test" ),
                                   .value( raise_obj_for_resiliency_test ))) begin
       `uvm_error( "dii_test run_phase", "raise_obj_for_resiliency_test event not found" )
    end

    if (!uvm_config_db#(event)::get(this,
                                   .inst_name ( "" ),
                                   .field_name( "drop_obj_for_resiliency_test" ),
                                   .value( drop_obj_for_resiliency_test ))) begin
       `uvm_error( "dii_test run_phase", "drop_obj_for_resiliency_test event not found" )
    end
<% } %>

    fork
       begin
         <% if((obj.testBench != "fsys")) { %>
         if($test$plusargs("check_corr_error_cnt")) begin
           res_corr_err_threshold_seq res_crtr_seq = res_corr_err_threshold_seq::type_id::create("res_crtr_seq");
           res_crtr_seq.model = m_regs;
           `ifdef USE_VIP_SNPS_APB
            res_crtr_seq.start(m_env.amba_system_env.apb_system[0].master.sequencer);
           `else 
           res_crtr_seq.start(m_env.m_apb_agent.m_apb_sequencer);
           `endif
         end
         <% } %>
       end
       begin
          int scb_en;
          if (! $value$plusargs("dii_scb_en=%d", scb_en)) begin
             scb_en = 1;
          end
          <% if((obj.testBench != "fsys")) { %>
            <% if (obj.useResiliency) { %>
              if($test$plusargs("check_corr_error_cnt")) begin
                res_corr_err_threshold_seq res_crtr_seq = res_corr_err_threshold_seq::type_id::create("res_crtr_seq");
                res_crtr_seq.model = m_regs;
               `ifdef USE_VIP_SNPS_APB
               res_crtr_seq.start(m_env.amba_system_env.apb_system[0].master.sequencer);
              `else 
              res_crtr_seq.start(m_env.m_apb_agent.m_apb_sequencer);
              `endif
              end
            <% } %>
          <% } %>

          if (scb_en) begin

            <% if((obj.DiiInfo[obj.Id].fnErrDetectCorrect.substring(0,6) == "SECDED")) { %>

            if ($test$plusargs("inject_sram_skid_single_err")) begin 
              bit [7:0] errthd;
              errthd = $urandom_range(1,20); 
              buffer_sel = $urandom_range(0,1);
              `uvm_info("SKIDBUFERROR", $sformatf("Random buffer_sel in run_phase of dii_test: %0d", buffer_sel), UVM_HIGH);
              `uvm_info("SKIDBUFERROR", $sformatf("errthd in run_phase of dii_test is  %0d", errthd), UVM_HIGH);
              `ifdef USE_VIP_SNPS
                 uvm_config_db#(bit [7:0])::set(this,"m_env.amba_system_env.apb_system[0].master.sequencer","errthd",errthd);
              `else 
                 uvm_config_db#(bit [7:0])::set(this,"m_env.m_apb_agent.m_apb_sequencer","errthd",errthd);
              `endif
                uvm_config_db#(bit [7:0])::set(this,"","errthd",errthd);

              #100ns; // waiting for smi seq to start
              for(int i=0; i<errthd +1; i++) begin //inject one more than errthd for interrupt and ErrVld

                u_csr_probe_vif.inject_single_error(buffer_sel); //#Stimulus.DII.Concerto.v3.7.CorrectableError

                `uvm_info("SKIDBUFERROR", $sformatf("u_csr_probe_vif.buffer_sel in dii_test is %0d ", u_csr_probe_vif.buffer_sel_probe), UVM_HIGH);
                 @(negedge u_csr_probe_vif.clk); 
                if(buffer_sel == 0) @(negedge u_csr_probe_vif.inject_cmd_data_single_next_0);
                else @(negedge u_csr_probe_vif.inject_cmd_data_single_next_1);
                `uvm_info("SKIDBUFERROR", $sformatf("Single bit error injection enabled in SRAM skid buffer with protection as SECDED and this is the %0d time ", i),UVM_HIGH);
               // @(negedge u_csr_probe_vif.clk);

              end
                

              wait(u_csr_probe_vif.DIIUCESR_ErrVld)begin //to check ErrCountOverflow
                #130ns;
                `uvm_info("SKIDBUFERROR","Injecting the last single bit error",UVM_HIGH)
                 u_csr_probe_vif.inject_single_error(buffer_sel);
              end    

            end  

            <% } %> 

           /* if ($test$plusargs("inject_sram_skid_double_err")) begin
              buffer_sel = $urandom_range(0,1);
              #250ns;
              u_csr_probe_vif.inject_double_error(buffer_sel);
              $display("Vyshak Double bit error injection enabled in SRAM skid buffer");
             end  */
 

            if($test$plusargs("uncorr_skid_buffer_test"))begin
              `uvm_info("run_main", "Vyshak waiting for kill_test_1 event to trigger",UVM_NONE)
              //kill_test_1.wait_trigger();
              `ifndef VCS
                  @kill_test_1;   // otherwise the test will hang and timeout
              `else // `ifndef VCS
                  kill_test_1.wait_trigger();   // otherwise the test will hang and timeout
              `endif // `ifndef VCS ... `else ... 
              `uvm_info("run_main", "kill_test_1 event triggered",UVM_NONE)
            end else begin
              `uvm_info("run_main", "waiting for kill_test event to trigger",UVM_NONE)
              @m_env.m_scb.kill_test;
            end
       
            
          end else begin
             `uvm_info("run_main", "scoreboard disabled. Wait 5000ns to trigger kill_test",UVM_NONE)
             #(5000*1ns);
          end
          `uvm_info("run_main", "kill_test event triggered",UVM_NONE)

          // Fetching the objection from current phase
          objection = phase.get_objection();
 
          // Collecting all the objectors which currently have objections raised
          objection.get_objectors(objectors_list);
 
          // Dropping the objections forcefully
          foreach(objectors_list[i]) begin
            `uvm_info("run_main", $sformatf("kill_test: objection count %d", objection.get_objection_count(objectors_list[i])),UVM_NONE);
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
                     @u_csr_probe_vif.fault_mission_fault;
                  end
                  if($test$plusargs("expect_mission_fault_cov") || $test$plusargs("multiple_mission_faults"))begin
                    #10us; // keep testcase timeout higher than this to avoid hearbeat failure
                  end
                  #(100*1ns);
                  `uvm_info($sformatf("%m"), $sformatf("<%=obj.DiiInfo[obj.Id].strRtlNamePrefix%> saw mission fault. Kill test"), UVM_NONE)
<% if(obj.testBench == 'dii') { %>
`ifndef VCS
                  -> kill_test;   // otherwise the test will hang and timeout
`else // `ifndef VCS
                  kill_test.trigger();   // otherwise the test will hang and timeout
`endif // `ifndef VCS ... `else ... 
<% } else {%>
                  -> kill_test;   // otherwise the test will hang and timeout
<% } %>

                  `uvm_info($sformatf("%m"), $sformatf("<%=obj.DiiInfo[obj.Id].strRtlNamePrefix%> saw mission fault. Jump to report phase"), UVM_NONE)
                  phase.jump(uvm_report_phase::get());
               end
             end
           end
         end
       end
// TODO as per Q_Chnl Vplan    m_q_chnl_seq.start(m_env.m_q_chnl_agent.m_q_chnl_seqr);
    join_none
   <% } %>
  fork
      begin
<% if (obj.useResiliency) { %>
        phase.raise_objection(this, "raising FSC reset done objection");
        // do not start FSC is reset
        ev_bist_reset_done.wait_ptrigger();
        `uvm_info($sformatf("%m"), $sformatf("BIST RESET DONE!"), UVM_NONE)
        phase.drop_objection(this, "droping FSC reset done objection");
<% } %>
      end
   join
   
    // configure Address Translation Registers if needed
    // This is done before traffic starts
    fork
<% if(obj.testBench == 'dii') { %>
`ifndef VCSorCDNS
    if (m_args.k_csr_seq) begin
`else // `ifndef VCSorCDNS
    if (m_args.k_csr_seq != "") begin
`endif // `ifndef VCSorCDNS ... `else ... 
<% } else {%>
    if (m_args.k_csr_seq) begin
<% } %>
       `uvm_info($sformatf("%m"), $sformatf("AddrTrans: skip test since other csr sequences are enabled"), UVM_NONE)
    end else begin
       phase.raise_objection(this, "Start addr_trans_seq");
<% if (obj.DiiInfo[obj.Id].nAddrTransRegisters > 0) { %>
       #1ps;
       m_addr_trans_seq = dii_csr_addr_trans_seq::type_id::create("m_addr_trans_seq");
       m_addr_trans_seq.m_regs = m_regs;

       if (! m_regs) begin
          `uvm_error("AddrTrans", $sformatf("m_regs is NULL"))
       end
       if (! m_addr_trans_seq.m_regs) begin
          `uvm_error("AddrTrans", $sformatf("addr_trans_seq m_regs is NULL"))
       end else begin
          `uvm_info($sformatf("%m"), $sformatf("AddrTrans: Staring sequence with m_regs=%p", m_addr_trans_seq.m_regs), UVM_LOW)
       end
      `ifdef USE_VIP_SNPS_APB
       m_addr_trans_seq.start(m_env.amba_system_env.apb_system[0].master.sequencer);
      `else 
      m_addr_trans_seq.start(m_env.m_apb_agent.m_apb_sequencer);
      `endif
       
<%  } %>
       phase.drop_objection(this, "Finished addr_trans_seq");
    end // else: !if(m_args.k_csr_seq)
    join

<% if(obj.testBench == 'dii') { %>
`ifndef VCSorCDNS
    if (m_args.k_csr_seq) begin
`else // `ifndef VCSorCDNS
    if (m_args.k_csr_seq != "") begin
`endif // `ifndef VCSorCDNS ... `else ... 
<% } else {%>
    if (m_args.k_csr_seq) begin
<% } %>

       // do nothing
    end else begin : CTRLR
       phase.raise_objection(this, "Start Trace Capture Configuration Sequence");
       m_cctrlr_seq = dii_csr_cctrlr_seq::type_id::create("m_cctrlr_seq");
       m_cctrlr_seq.m_regs = m_regs;
       if ((! m_regs) || (! m_cctrlr_seq.m_regs)) begin
          `uvm_error("CTRLR", $sformatf("m_regs is NULL"))
       end
       `uvm_info($sformatf("%m"), $sformatf("CCTRLR: Staring sequence with m_regs=%p", m_cctrlr_seq.m_regs), UVM_LOW)
       
    
      `ifdef USE_VIP_SNPS_APB
       m_cctrlr_seq.start(m_env.amba_system_env.apb_system[0].master.sequencer);
      `else 
      m_cctrlr_seq.start(m_env.m_apb_agent.m_apb_sequencer);
      `endif
       $stacktrace;
       phase.drop_objection(this, "Finished Trace Capture Configuration Sequence");

    end : CTRLR

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
  main_seq_pre_hook(phase); // virtual task
  for(int i=0;i<main_seq_iter;i++) begin:forloop_main_seq_iter // by default main_seq_iter=1
  main_seq_iter_pre_hook(phase,i); // virtual task
    //start active seqs
    fork
       begin
           phase.raise_objection(this, "Start smi_seq");
           if ((!smi_rx_stall_en) && (!force_axi_stall_en)) begin
            smi_seq.start(m_env.m_smi_agent.m_smi_virtual_seqr);
           end
           phase.drop_objection(this, "Finish smi_seq");
       end
       <% if (obj.DiiInfo[obj.Id].nExclusiveEntries  > 0) { %>
       begin

       phase.raise_objection(this, "Start Sys Event Configuration Sequence");
       m_sys_event_seq = dii_csr_sys_event_seq::type_id::create("m_sys_event_seq");
       m_sys_event_seq.model = m_regs;
       if ((! m_regs) || (! m_sys_event_seq.model)) begin
          `uvm_error("SysEvent", $sformatf("m_regs is NULL"))
       end
       `uvm_info($sformatf("%m"), $sformatf("SysEvent: Staring sequence with m_regs=%p", m_sys_event_seq.model), UVM_LOW)
	`ifdef USE_VIP_SNPS_APB 
	 m_sys_event_seq.start(m_env.amba_system_env.apb_system[0].master.sequencer);
	`else       
	m_sys_event_seq.start(m_env.m_apb_agent.m_apb_sequencer);
	`endif
       phase.drop_objection(this, "Finished  Sys Event Configuration Sequence");

       end
       <% } %>
<% if(obj.testBench == 'dii') { %>
`ifndef VCSorCDNS
       if (m_args.k_csr_seq) begin
        `uvm_info("SKIDBUFERROR",$sformatf("m_args.k_csr_seq is in 582 %p",m_args.k_csr_seq),UVM_HIGH);
`else // `ifndef VCSorCDNS
    if (csr_seq != null) begin
         `uvm_info("SKIDBUFERROR",$sformatf("Vyshak and csr_seq is in 588 %p",csr_seq),UVM_HIGH);
`endif // `ifndef VCSorCDNS ... `else ... 
<% } else {%>
       if (m_args.k_csr_seq) begin
<% } %>

           phase.raise_objection(this, $sformatf("Start %s", m_args.k_csr_seq));
           //note: inheritance => get child seq behavior without casting back to child type.
           #(1 * 1ns);
           
          `ifdef USE_VIP_SNPS
           csr_seq.start(m_env.amba_system_env.apb_system[0].master.sequencer);
          `else 
          csr_seq.start(m_env.m_apb_agent.m_apb_sequencer);
          `endif
               $stacktrace;
          if(!$test$plusargs("uncorr_skid_buffer_test")) phase.drop_objection(this, $sformatf("Finish %s", m_args.k_csr_seq)); //vyshak
       end
    join
    `uvm_info("run_phase", "all active seqs completed",UVM_MEDIUM)
    main_seq_iter_post_hook(phase,i); // virtual task
  end:forloop_main_seq_iter
  main_seq_post_hook(phase); // virtual task
  main_seq_hook_end_run_phase(phase); // virtual task
  #5000ns

  if (m_env.m_scb) begin
    while(m_env.m_scb.statemachine_q.txn_q.size()>0 || m_env.m_scb.last_statemachine_q_size !=0 || m_env.m_scb.axi_w_q.size()>0 || m_env.m_scb.last_axi_w_q_size !=0)begin
      `uvm_info("SCOREBOARD_MONITOR", "Waiting for the scoreboard to process all transactions to do register checks", UVM_MEDIUM);
      m_env.m_scb.statemachine_q.print();
      #2000ns;
    end
  end
  `uvm_info("REG_CHECK","Scb is done processing all transactions count",UVM_MEDIUM);
  #600ns
  check_register(); 

endtask : run_phase


////////////////////////////////////////////////////////////////////////////////

`endif // DII_TEST

/*
 *creating a stand alone testcase as testing for the features
 *related to unit duplication is done using force mechanism.
 */
class resiliency_unitduplication_test extends dii_test; //uvm_test;

  `uvm_component_utils(resiliency_unitduplication_test)

  <% if(obj.testBench == 'dii') { %>
`ifdef VCSorCDNS
  uvm_event raise_obj_for_resiliency_test;
  uvm_event drop_obj_for_resiliency_test;
`else    
  event raise_obj_for_resiliency_test;
  event drop_obj_for_resiliency_test;
`endif // `ifndef VCSorCDNS ... `else ... 
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

<% if(obj.testBench == 'dii') { %>
`ifdef VCSorCDNS
    if(!uvm_config_db#(uvm_event)::get(this, "", "raise_obj_for_resiliency_test", raise_obj_for_resiliency_test)) begin
      `uvm_error( "dii_test run_phase", "raise_obj_for_resiliency_test event not found" )
    end

    if(!uvm_config_db#(uvm_event)::get(this, "", "drop_obj_for_resiliency_test", drop_obj_for_resiliency_test)) begin
      `uvm_error( "dii_test run_phase", "drop_obj_for_resiliency_test event not found" )
    end
`else
    if(!uvm_config_db#(event)::get(this, "", "raise_obj_for_resiliency_test", raise_obj_for_resiliency_test)) begin
      `uvm_error( "dii_test run_phase", "raise_obj_for_resiliency_test event not found" )
    end

    if(!uvm_config_db#(event)::get(this, "", "drop_obj_for_resiliency_test", drop_obj_for_resiliency_test)) begin
      `uvm_error( "dii_test run_phase", "drop_obj_for_resiliency_test event not found" )
    end
`endif // `ifndef VCSorCDNS
<% } else {%>
    if(!uvm_config_db#(event)::get(this, "", "raise_obj_for_resiliency_test", raise_obj_for_resiliency_test)) begin
      `uvm_error( "dii_test run_phase", "raise_obj_for_resiliency_test event not found" )
    end

    if(!uvm_config_db#(event)::get(this, "", "drop_obj_for_resiliency_test", drop_obj_for_resiliency_test)) begin
      `uvm_error( "dii_test run_phase", "drop_obj_for_resiliency_test event not found" )
    end
<% } %>

    phase.raise_objection(this, $sformatf("raise_objection from{%0s} in phase{%0s}",this.get_name(), phase.get_domain_name()));
    fork
      begin
        `uvm_info("run_main", "Waiting for random time units 2us", UVM_NONE)
        #2us;
      end
      begin
        phase.raise_objection(this, "raising FSC reset done objection");
        // do not start FSC is reset
        ev_bist_reset_done.wait_ptrigger();
        `uvm_info($sformatf("%m"), $sformatf("BIST RESET DONE!"), UVM_NONE)
        phase.drop_objection(this, "droping FSC reset done objection");
      end
      begin
<% if(obj.testBench == 'dii') { %>
`ifdef VCSorCDNS
         `uvm_info("run_main", "waiting for raise_obj_for_resiliency_test event to trigger",UVM_NONE)
         raise_obj_for_resiliency_test.wait_trigger();
         `uvm_info("run_main", "raise_obj_for_resiliency_test event triggered",UVM_NONE)
         phase.raise_objection(this, "raising objection for resiliency test");
 
         drop_obj_for_resiliency_test.wait_trigger();
         phase.drop_objection(this, "dropping resiliency test objection");
`else
         `uvm_info("run_main", "waiting for raise_obj_for_resiliency_test event to trigger",UVM_NONE)
         @raise_obj_for_resiliency_test;
         `uvm_info("run_main", "raise_obj_for_resiliency_test event triggered",UVM_NONE)
         phase.raise_objection(this, "raising objection for resiliency test");
 
         @drop_obj_for_resiliency_test;
         phase.drop_objection(this, "dropping resiliency test objection");
`endif // `ifndef VCSorCDNS ... `else ... 
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
