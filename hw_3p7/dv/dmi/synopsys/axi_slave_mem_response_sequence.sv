//=======================================================================
// COPYRIGHT (C) 2011, 2012, 2013 Synopsys Inc.
// This software and the associated documentation are confidential and
// proprietary to Synopsys, Inc. Your use or disclosure of this software
// is subject to the terms and conditions of a written license agreement
// between you, or your company, and Synopsys, Inc. In the event of
// publications, the following notice is applicable:
//
// ALL RIGHTS RESERVED
//
// The entire notice above must be reproduced on all authorized copies.
//-----------------------------------------------------------------------

/**
 * Abstract:
 * Class axi_slave_mem_response_sequence defines a sequence class that
 * the testbench uses to provide slave response to the Slave agent present in
 * the System agent. The sequence receives a response object of type
 * svt_axi_slave_transaction from slave sequencer. The sequence class then
 * randomizes the response with constraints and provides it to the slave driver
 * within the slave agent. The sequence also instantiates the slave built-in
 * memory, and writes into or reads from the slave memory.
 *
 * Execution phase: main_phase
 * Sequencer: Slave agent sequencer
 */

`ifndef GUARD_AXI_SLAVE_MEM_RESPONSE_SEQUENCE_SV
`define GUARD_AXI_SLAVE_MEM_RESPONSE_SEQUENCE_SV

class axi_slave_mem_response_sequence extends svt_axi_slave_base_sequence;

  svt_axi_slave_transaction req_resp;
  svt_axi_transaction::resp_type_enum ovr_bresp, ovr_rresp[];
  uvm_event read_threshold;
  uvm_event read_threshold_evnt=uvm_event_pool::get_global("read_threshold_evnt");

  int timeout_threshold;
  bit inject_wready_dly, inject_wresp_dly, inject_rvalid_dly;
  //AXI Delay control
  bit eos_suspend_release;
  int wresp_stall_count, rresp_stall_count;
  int axi_txn_count, axi_read_txn_count, axi_write_txn_count;
  //Synopsys Overrides
  int ZERO_DELAY_wt;
  int SHORT_DELAY_wt;
  int LONG_DELAY_wt;

  virtual dmi_csr_probe_if u_csr_probe_vif;
  uvm_cmdline_processor clp = uvm_cmdline_processor::get_inst();
  dmi_env_config m_cfg;
  /** UVM Object Utility macro */
  `uvm_object_utils_begin(axi_slave_mem_response_sequence)
  `uvm_component_utils_end

  /** Class Constructor */
  function new(string name="axi_slave_mem_response_sequence");
    super.new(name);
  endfunction

  extern function long_delay_R(ref svt_axi_slave_transaction m_req);
  extern function default_R(ref svt_axi_slave_transaction m_req);
  extern function backpressure_R(ref svt_axi_slave_transaction m_req);
  extern function response_errors_R(ref svt_axi_slave_transaction m_req,svt_axi_transaction::resp_type_enum m_rresp[],svt_axi_transaction::resp_type_enum m_bresp);
  extern function ABD(ref svt_axi_slave_transaction m_req);
  extern function ABE(ref svt_axi_slave_transaction m_req);

  function void get_args();
    string arg_value;
    if(!uvm_config_db#(dmi_env_config)::get(.cntxt( null ),
                                       .inst_name( get_full_name() ),
                                       .field_name( "dmi_env_config" ),
                                       .value( m_cfg ))) begin
      `uvm_error("axi_slave_mem_response_sequence", "dmi_env_config handle not found")
    end
    if(m_cfg.m_args.k_smc_timeout_error_test) begin
      inject_wready_dly = 1;
    end
    if(m_cfg.m_args.k_wtt_timeout_error_test) begin
      inject_wresp_dly = 1;
    end
    if(m_cfg.m_args.k_rtt_timeout_error_test) begin
      inject_rvalid_dly = 1;
    end
    set_delays();
    if(!uvm_config_db#(virtual dmi_csr_probe_if )::get(null, get_full_name(), "u_csr_probe_if",u_csr_probe_vif)) begin
        `uvm_error({"fault_injector_checker_",get_name()}, {"virtual interface must be set  for :",get_full_name(),".vif"})
    end
  endfunction

  function void set_delays();
    if(m_cfg.m_args.k_axi_zero_delay) begin
      ZERO_DELAY_wt  = 100;
      SHORT_DELAY_wt = 0;
      LONG_DELAY_wt  = 0;
    end
    else if(m_cfg.m_args.k_axi_long_delay)begin
      ZERO_DELAY_wt  = 0;
      SHORT_DELAY_wt = 0;
      LONG_DELAY_wt  = 100;
    end
    else begin
      ZERO_DELAY_wt  = 200;
      SHORT_DELAY_wt = 300;
      LONG_DELAY_wt  = 50;
    end
  endfunction

  virtual task body();
    integer status, m_delay[];
    svt_configuration get_cfg;
    
    `uvm_info(get_type_name(), "Starting AXI SLAVE TXN.", UVM_DEBUG)
    get_args();
    p_sequencer.get_cfg(get_cfg);
    if (!$cast(cfg, get_cfg)) begin
      `uvm_fatal(get_type_name(), "Unable to $cast the configuration to a svt_axi_port_configuration class");
    end

    instantiate_axi_slave_mem();
    sink_responses();

    forever begin
      bit rd_error_injected, wr_error_injected;
      p_sequencer.response_request_port.peek(req_resp);
      //Counters for flow control////////////////////////////////////////////////////////////////////////////////////////////////
      axi_txn_count++;
      `uvm_guarded_info(m_cfg.m_args.k_axi_debug,get_type_name(),$sformatf("Received axi txn:%0d",axi_txn_count),UVM_DEBUG)
      if(req_resp.xact_type == svt_axi_transaction::WRITE) begin
        axi_write_txn_count++;
      end
      if(req_resp.xact_type == svt_axi_transaction::READ) begin
        axi_read_txn_count++;
      end
      //Randomize response errors for overrides//////////////////////////////////////////////////////////////////////////////////
      if($urandom_range(1,100) < m_cfg.m_args.prob_ace_wr_resp_error && req_resp.xact_type == svt_axi_transaction::WRITE) begin
        wr_error_injected = 1;
        std::randomize(ovr_bresp) with { ovr_bresp inside {svt_axi_transaction::SLVERR,svt_axi_transaction::DECERR};};
      end
    
      ovr_rresp = new[req_resp.rresp.size()];

      foreach(ovr_rresp[itr]) begin
        if($urandom_range(1,100) < m_cfg.m_args.prob_ace_rd_resp_error && req_resp.xact_type == svt_axi_transaction::READ ) begin
          rd_error_injected = 1;
          std::randomize(ovr_rresp[itr]) with { ovr_rresp[itr] inside {svt_axi_transaction::SLVERR,svt_axi_transaction::DECERR};};
        end
      end

      //Assign delay weights pre-hooks for delay control//////////////////////////////////////////////////////////////////////////

      if(!inject_wready_dly && !inject_wresp_dly && !inject_rvalid_dly) begin
        req_resp.ZERO_DELAY_wt  = ZERO_DELAY_wt;
        req_resp.SHORT_DELAY_wt = SHORT_DELAY_wt;
        req_resp.LONG_DELAY_wt  = LONG_DELAY_wt;
      end
      else begin
        //Disable reasonable constraints for abnormal timeout cases, override manually
        req_resp.reasonable_constraint_mode(0); 
      end
              
      if(rd_error_injected| wr_error_injected) begin 
        response_errors_R(req_resp,ovr_rresp,ovr_bresp);
      end
      else if (m_cfg.m_args.k_axi_long_delay) begin
        req_resp.reasonable_constraint_mode(0); 
        long_delay_R(req_resp);
      end
      else if(m_cfg.enable_axi_backpressure) begin
        req_resp.reasonable_constraint_mode(0); 
        backpressure_R(req_resp);
      end
      else begin //default mode
        default_R(req_resp);
      end

      //Extreme AXI delays for timeout cases//////////////////////////////////////////////////////////////////////////////////////////
      
      if(timeout_threshold == 0) begin
        if(uvm_config_db#(int)::get(null,"uvm_test_top","timeout_threshold",timeout_threshold)) begin
          `uvm_info(get_type_name(),$sformatf("Received programmed CSR timeout threshold value:%0d",timeout_threshold),UVM_LOW)
        end
      end

      if(inject_wready_dly && timeout_threshold !=0) begin
        foreach (req_resp.wready_delay[index]) begin
          req_resp.wready_delay[index] = `SVT_AXI_MAX_WREADY_DELAY;
        end
      end
      if(inject_rvalid_dly && timeout_threshold !=0) begin
        foreach (req_resp.rvalid_delay[index]) begin
          req_resp.rvalid_delay[index] = `SVT_AXI_MAX_RVALID_DELAY;
        end
      end
      if(inject_wresp_dly && timeout_threshold !=0) begin
        req_resp.bvalid_delay =`SVT_AXI_MAX_BVALID_DELAY;
      end

      //Suspend responses until certain conditions are met////////////////////////////////////////////////////////////////////////////
      if(m_cfg.m_args.axi_suspend_resp) begin
        snps_suspend_all_resp(req_resp);
      end
      if(m_cfg.enable_suspend_axi && m_cfg.axi_suspend_W_resp)begin
        snps_suspend_wresp(req_resp);
      end
      if(m_cfg.enable_suspend_axi && m_cfg.axi_suspend_R_resp)begin
        snps_suspend_rresp(req_resp);
      end

      //If write transaction, write data into slave built-in memory, else get data from slave built-in memory/////////////////////////
      if(req_resp.xact_type == svt_axi_transaction::WRITE) begin
        put_write_transaction_data_to_mem(req_resp);
      end
      else begin
        get_read_data_from_mem_to_transaction(req_resp); 
      end

      $cast(req,req_resp);
      `uvm_guarded_info(m_cfg.m_args.k_axi_debug,get_type_name(),$sformatf("Sending axi txn:%0d",axi_txn_count),UVM_DEBUG)
      `uvm_send(req)

    end
    `uvm_info(get_type_name(), "Finished AXI Slave TXN.", UVM_DEBUG)
  endtask: body

  task snps_suspend_all_resp(svt_axi_slave_transaction slv_xact);
    slv_xact.suspend_response = 1;
  endtask

  //Suspend task to fill WTT, appropriate traffic and not CMOs should be streamed on the SMI I/F//////////////////////////////////////
  task snps_suspend_wresp(svt_axi_slave_transaction slv_xact);
    slv_xact.suspend_response = 1;
    `uvm_guarded_info(m_cfg.m_args.k_axi_debug,get_type_name(),$sformatf("::snps_suspend_wresp:: total_count:%0d write_count:%0d",axi_txn_count,axi_write_txn_count),UVM_DEBUG)
    fork
      begin
        wait(axi_write_txn_count % WTT_SIZE == 0 || eos_suspend_release == 1) begin
          slv_xact.suspend_response=0;
          wresp_stall_count++;
          `uvm_guarded_info(m_cfg.m_args.k_axi_debug,get_type_name(),$sformatf("::snps_suspend_wresp:: released_count:%0d",wresp_stall_count),UVM_DEBUG)
        end
      end
    join_none
  endtask

  //Suspend task to fill RTT, appropriate traffic and not CMOs should be streamed on the SMI I/F//////////////////////////////////////
  task snps_suspend_rresp(svt_axi_slave_transaction slv_xact);
    slv_xact.suspend_response = 1;
    `uvm_guarded_info(m_cfg.m_args.k_axi_debug,get_type_name(),$sformatf("::snps_suspend_rresp:: total_count:%0d read_count:%0d",axi_txn_count,axi_read_txn_count),UVM_DEBUG)
    fork
      begin
        wait(axi_read_txn_count % RTT_SIZE == 0 || eos_suspend_release == 1) begin
          //Wait for an arbitrary amount of time?? TODO will this actually achieve something other than increasing sim time?
          slv_xact.suspend_response=0;
          rresp_stall_count++;
          `uvm_guarded_info(m_cfg.m_args.k_axi_debug,get_type_name(),$sformatf("::snps_suspend_rresp:: released_count:%0d",rresp_stall_count),UVM_DEBUG)
        end
      end
    join_none
  endtask
endclass: axi_slave_mem_response_sequence

//Randomization function/////////////////////////////////////////////////////////////////////BEGIN///////////////////////////////////
function axi_slave_mem_response_sequence::default_R(ref svt_axi_slave_transaction m_req);
  bit status = 0;
  //Constrain reasonable delay values just in-case, unsure if VIP uses defines or hardcoded values internally.
  status = m_req.randomize with {
                                      bvalid_delay <=`SVT_AXI_MAX_AXI3_GENERIC_DELAY;
                                      foreach(rvalid_delay[index]) {rvalid_delay[index] <= `SVT_AXI_MAX_AXI3_GENERIC_DELAY;}
                                      addr_ready_delay <= `SVT_AXI_MAX_AXI3_GENERIC_DELAY;
                                      foreach(wready_delay[index]) {wready_delay[index] <= `SVT_AXI_MAX_AXI3_GENERIC_DELAY;}
                                      foreach(rready_delay[index]) {rready_delay[index] <= `SVT_AXI_MAX_AXI3_GENERIC_DELAY;}
                                      if(m_cfg.m_args.k_read_data_interleaving || m_cfg.read_data_interleaving) {
                                        enable_interleave == 1;
                                        interleave_pattern == RANDOM_BLOCK;
                                      } else {
                                        enable_interleave == 0;
                                      }
                                    };
  if(!status) begin
   `uvm_fatal(get_type_name(),"::default_R:: Unable to randomize a response")
  end
endfunction

function axi_slave_mem_response_sequence::response_errors_R(ref svt_axi_slave_transaction m_req, svt_axi_transaction::resp_type_enum m_rresp[], svt_axi_transaction::resp_type_enum m_bresp);
  bit status = 0;
  status = m_req.randomize with {
                                      foreach (rresp[index])  { rresp[index] == m_rresp[index];}
                                      bresp == m_bresp;
                                      bvalid_delay <= `SVT_AXI_MAX_AXI3_GENERIC_DELAY;
                                      foreach(rvalid_delay[index]) {rvalid_delay[index] <= `SVT_AXI_MAX_AXI3_GENERIC_DELAY;}
                                      foreach(wready_delay[index]) {wready_delay[index] <= `SVT_AXI_MAX_AXI3_GENERIC_DELAY;}
                                      if(m_cfg.m_args.k_read_data_interleaving || m_cfg.read_data_interleaving) {
                                        enable_interleave == 1;
                                        interleave_pattern == RANDOM_BLOCK;
                                      } else {
                                        enable_interleave == 0;
                                      }
                                   };
  if(!status) begin
   `uvm_fatal(get_type_name(),"::response_errors_R:: Unable to randomize a response")
  end
endfunction

function axi_slave_mem_response_sequence::long_delay_R(ref svt_axi_slave_transaction m_req);
  bit status = 0;
  int read_delay[min_max_t],write_delay[min_max_t];
  read_delay[MIN] = 16; read_delay[MAX] = 32;
  write_delay[MIN] = 16; write_delay[MAX] = 32;
  case(m_cfg.long_delay_mode)
    FLOW_CONTROL: begin
      read_delay[MIN]  = RTT_SIZE; read_delay[MAX]  = RTT_SIZE+4;
      write_delay[MIN] = WTT_SIZE; write_delay[MAX] = WTT_SIZE+4;
    end
    BELOW_LIMIT: begin
      read_delay[MIN]  = RTT_SIZE-5; read_delay[MAX]  = RTT_SIZE-4;
      write_delay[MIN] = WTT_SIZE-5; write_delay[MAX] = WTT_SIZE-4;
    end
    ARBITRARY_SLOW: begin
      read_delay[MIN]   = `SVT_LONG_DELAY_MIN; read_delay[MAX]  = `SVT_LONG_DELAY_MAX;
      write_delay[MIN]  = `SVT_LONG_DELAY_MIN; write_delay[MAX] = `SVT_LONG_DELAY_MAX;
    end
    default: begin
      `uvm_error(get_type_name(),$sformatf("Incorrect long_delay_mode:%0s set, check randomization",m_cfg.long_delay_mode.name))
    end
  endcase

  status = m_req.randomize with {
                                  bvalid_delay <= write_delay[MAX];
                                  bvalid_delay dist {
                                    [write_delay[MIN]      :write_delay[MAX]/2] :/4,
                                    [(write_delay[MAX]/2)+1:write_delay[MAX]]   :/6
                                  };
                                  foreach(rvalid_delay[index]) {
                                    rvalid_delay[index] <= read_delay[MAX];
                                    rvalid_delay[index] dist{
                                      [read_delay[MIN]      :read_delay[MAX]/2] :/4,
                                      [(read_delay[MAX]/2)+1:read_delay[MAX]]   :/6
                                    };
                                  }
                                  addr_ready_delay <= `SVT_AXI_MAX_AXI3_GENERIC_DELAY;
                                  foreach(wready_delay[index]) {wready_delay[index] <= `SVT_AXI_MAX_AXI3_GENERIC_DELAY;}
                                  foreach(rready_delay[index]) {rready_delay[index] <= `SVT_AXI_MAX_AXI3_GENERIC_DELAY;}
                                  if(m_cfg.m_args.k_read_data_interleaving || m_cfg.read_data_interleaving) {
                                    enable_interleave == 1;
                                    interleave_pattern == RANDOM_BLOCK;
                                  } else {
                                    enable_interleave == 0;
                                  }
                                };
  if(!status) begin
   `uvm_fatal(get_type_name(),"::long_delay_R:: Unable to randomize a response")
  end
endfunction

function axi_slave_mem_response_sequence::backpressure_R(ref svt_axi_slave_transaction m_req);
  bit status = 0;
  int addr_ready_dly[min_max_t];
  int wready_dly[min_max_t], bvalid_dly[min_max_t];
  int rready_dly[min_max_t], rvalid_dly[min_max_t];
  addr_ready_dly[MIN] = 8; addr_ready_dly[MAX] = 16;  
  wready_dly[MIN]     = 8; wready_dly[MAX]     = 16;
  bvalid_dly[MIN]     = 8; bvalid_dly[MAX]     = 16;
  rvalid_dly[MIN]     = 8; rvalid_dly[MAX]     = 16;
  if(m_cfg.axi_rw_address_chnl_backpressure) begin
    addr_ready_dly[MIN] = `SVT_BACKPRESSURE_DELAY_MIN; addr_ready_dly[MAX] = `SVT_BACKPRESSURE_DELAY_MAX;
  end
  if(m_cfg.axi_wr_data_chnl_backpressure) begin
    wready_dly[MIN]     = `SVT_BACKPRESSURE_DELAY_MIN; wready_dly[MAX]     = `SVT_BACKPRESSURE_DELAY_MAX;
  end
  if(m_cfg.axi_wr_resp_chnl_backpressure) begin
    bvalid_dly[MIN]     = `SVT_BACKPRESSURE_DELAY_MIN; bvalid_dly[MAX]     = `SVT_BACKPRESSURE_DELAY_MAX;
  end
  if(m_cfg.axi_rd_data_chnl_backpressure) begin
    rready_dly[MIN]     = `SVT_BACKPRESSURE_DELAY_MIN; rready_dly[MAX]     = `SVT_BACKPRESSURE_DELAY_MAX;
  end
  if(m_cfg.axi_rd_resp_chnl_backpressure) begin
    rvalid_dly[MIN]     = `SVT_BACKPRESSURE_DELAY_MIN; rvalid_dly[MAX]     = `SVT_BACKPRESSURE_DELAY_MAX;
  end
  status = m_req.randomize with {     //Read and Write Address Channel
                                  addr_ready_delay <= addr_ready_dly[MAX];
                                  addr_ready_delay dist {
                                    [ addr_ready_dly[MIN]      :addr_ready_dly[MAX]/2]  :/4,
                                    [(addr_ready_dly[MAX]/2)+1 :addr_ready_dly[MAX]]    :/6
                                  };
                                  //Write Data Channel
                                  foreach(wready_delay[index]) {
                                    wready_delay[index] <= wready_dly[MAX];
                                    wready_delay[index] dist{
                                      [ wready_dly[MIN]     :wready_dly[MAX]/2] :/4,
                                      [(wready_dly[MAX]/2)+1:wready_dly[MAX]]   :/6
                                    };
                                  }
                                  //Write Response Channel
                                  bvalid_delay <= bvalid_dly[MAX];
                                  bvalid_delay dist {
                                    [ bvalid_dly[MIN]     :bvalid_dly[MAX]/2] :/4,
                                    [(bvalid_dly[MAX]/2)+1:bvalid_dly[MAX]]   :/6
                                  };
                                  foreach(rready_delay[index]) {
                                    rready_delay[index] <= rready_dly[MAX];
                                    rready_delay[index] dist{
                                      [ rready_dly[MIN]    :rready_dly[MAX]/2] :/4,
                                      [(rready_dly[MAX]/2)+1:rready_dly[MAX]]  :/6
                                    };
                                  }
                                  //Read Response Channel
                                  foreach(rvalid_delay[index]) {
                                    rvalid_delay[index] <= rvalid_dly[MAX];
                                    rvalid_delay[index] dist{
                                      [ rvalid_dly[MIN]    :rvalid_dly[MAX]/2] :/4,
                                      [(rvalid_dly[MAX]/2)+1:rvalid_dly[MAX]]  :/6
                                    };
                                  }
                                  if(m_cfg.m_args.k_read_data_interleaving || m_cfg.read_data_interleaving) {
                                    enable_interleave == 1;
                                    interleave_pattern == RANDOM_BLOCK;
                                  } else {
                                    enable_interleave == 0;
                                  }
                                };
  if(!status) begin
   `uvm_fatal(get_type_name(),"::backpressure_R:: Unable to randomize a response")
  end
endfunction
//Randomization function///////////////////////////////////////////////////////////////////////END///////////////////////////////////

`endif // GUARD_AXI_SLAVE_MEM_RESPONSE_SEQUENCE_SV
