`ifndef dii_targt_id_err_test
`define dii_targt_id_err_test



////////////////////////////////////////////////////////////////////////////////
//
// DII Test
//
////////////////////////////////////////////////////////////////////////////////

<%
    //all csr sequences
    var csr_seqs = [
        "dii_csr_diiuedr_TransErrDetEn_seq"
        //TODO seqs from dii_ral_csr_seq.sv
    ];
%>

//class dii_targt_id_err_test extends apb_base_test;
class dii_targt_id_err_test extends dii_base_test;

  `uvm_component_utils(dii_targt_id_err_test)

<% if(obj.testBench == 'dii') { %>
 `ifdef VCS
  `define VCSorCDNS
 `elsif CDNS
  `define VCSorCDNS
 `endif 
<% }  %>
  extern function new(string name = "dii_targt_id_err_test", uvm_component parent = null);
  extern virtual task run_phase(uvm_phase phase);
  extern virtual function void report_phase (uvm_phase phase);

endclass: dii_targt_id_err_test

//------------------------------------------------------------------------------
// Constructor
//------------------------------------------------------------------------------
function dii_targt_id_err_test::new(string name = "dii_targt_id_err_test", uvm_component parent = null);
  super.new(name, parent);
endfunction : new

//------------------------------------------------------------------------------
// Run Phase
//------------------------------------------------------------------------------
task dii_targt_id_err_test::run_phase(uvm_phase phase);
  uvm_objection uvm_obj = phase.get_objection();
  
  common_knob_list m_common_knob_list = common_knob_list::get_instance();
  
  uvm_reg_sequence csr_seq;
  dii_seq  smi_seq = dii_seq::type_id::create("smi_seq");

  dii_csr_cctrlr_seq      m_cctrlr_seq;

  q_chnl_seq m_q_chnl_seq;
  int time_bw_Q_chnl_req = 100;

  uvm_event_pool ev_pool = uvm_event_pool::get_global_pool();
  uvm_event ev_irq_uc_en = ev_pool.get("ev_<%=obj.DiiInfo[obj.Id].strRtlNamePrefix%>_irq_uc_en");
  <% if (obj.useResiliency) { %>
  uvm_event ev_bist_reset_done = ev_pool.get("bist_reset_done");
  <% } %>
   
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
    <% if (obj.DiiInfo[obj.Id].configuration == 0) { %>
    uvm_resource_db#(bit)::set({"REG::",m_regs.<%=obj.DiiInfo[obj.Id].strRtlNamePrefix%>.DIIUIDR.get_full_name()}, "NO_REG_TESTS", 1,this);
    uvm_resource_db#(bit)::set({"REG::",m_regs.<%=obj.DiiInfo[obj.Id].strRtlNamePrefix%>.DIIUFUIDR.get_full_name()}, "NO_REG_TESTS", 1,this);
    <% } else { %>
    `uvm_error($sformatf("%m"), $sformatf("DII objId=%0d (%s) is configured with automated register test. Can not proceed",
                                          <%=obj.Id%>, "%<=obj.DiiInfo[obj.Id].strRtlNamePrefix%>"))
    <% } %>

    //print all knobs
    m_common_knob_list.print();

    //execute test
    uvm_obj.set_drain_time(null, 10us);

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
    phase.raise_objection(this, "Start tagrt id test");
    
    <% if (obj.useResiliency) { %>
    ev_bist_reset_done.wait_ptrigger();
    `uvm_info($sformatf("%m"), $sformatf("BIST RESET DONE!"), UVM_NONE)
    <% } %>

<% if(obj.testBench == 'dii') { %>
`ifndef VCSorCDNS
    if (m_args.k_csr_seq) begin : CTRLR
`else // `ifndef VCSorCDNS
    if (m_args.k_csr_seq != "") begin  : CTRLR
`endif // `ifndef VCSorCDNS ... `else ... 
<% } else {%>
    if (m_args.k_csr_seq) begin : CTRLR
<% } %>
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
       phase.drop_objection(this, "Finished Trace Capture Configuration Sequence");
    end : CTRLR

    fork
       begin
           ev_irq_uc_en.wait_trigger();
           `uvm_info($sformatf("%m"), $sformatf("TARGET ID ERROR: IRQ_UC enabled"), UVM_NONE)
           smi_seq.start(m_env.m_smi_agent.m_smi_virtual_seqr);
       end
<% if(obj.testBench == 'dii') { %>
`ifndef VCSorCDNS
       if (m_args.k_csr_seq) begin
`else // `ifndef VCSorCDNS
    if (m_args.k_csr_seq != "") begin 
`endif // `ifndef VCSorCDNS ... `else ... 
<% } else {%>
       if (m_args.k_csr_seq) begin
<% } %>

        `ifdef USE_VIP_SNPS_APB
        csr_seq.start(m_env.amba_system_env.apb_system[0].master.sequencer);
        `else 
        csr_seq.start(m_env.m_apb_agent.m_apb_sequencer);
        `endif
       end
    join_any
    phase.drop_objection(this, $sformatf("Finish targt id test"));
    `uvm_info("run_phase", "test completed. Jump to report_phase", UVM_NONE)

    phase.jump(uvm_report_phase::get());
endtask : run_phase

function void dii_targt_id_err_test::report_phase(uvm_phase phase);
  <% if(obj.useResiliency) { %>
  bit targ_id_err;

  //To check mission fault for wrong_target_id/memory uncorrectable error injection(Ncore3.0/section 5.4)
  //#Stimulus.DII.tagiderr.V3.cmdreq
  //#Stimulus.DII.tagiderr.V3.dtwreq
  //#Stimulus.DII.tagiderr.V3.dtrrsp
  //#Stimulus.DII.tagiderr.V3.strrsp
  //#Stimulus.DII.tagiderr.V3.dtwdbgrsp
  if($test$plusargs("wt_wrong_dut_id_cmd") || $test$plusargs("wt_wrong_dut_id_dtw") || $test$plusargs("wt_wrong_dut_id_strrsp") ||
     $test$plusargs("wt_wrong_dut_id_dtrrsp") || $test$plusargs("wt_wrong_dut_Id_dtwdbgrsp")) begin
    targ_id_err = m_env.m_scb.targ_id_err;
  end
  if(targ_id_err) begin
    string log_s = "wrong traget ID error injection";

    if (u_csr_probe_vif.fault_mission_fault === 0) begin
      `uvm_error(get_full_name(),$sformatf("mission fault should be asserted for %0s", log_s))
    end else if (u_csr_probe_vif.fault_mission_fault === 1) begin
      `uvm_info(get_full_name(),$sformatf("mission fault asserted due to %0s", log_s), UVM_NONE)
    end else if (u_csr_probe_vif.fault_mission_fault === 'hx) begin
      `uvm_error(get_full_name(),$sformatf("mission fault goes unknown for %0s", log_s))
    end
  end

  <% } %>
  super.report_phase(phase);
endfunction: report_phase

////////////////////////////////////////////////////////////////////////////////

`endif // dii_targt_id_err_test
