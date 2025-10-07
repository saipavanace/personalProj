////////////////////////////////////////////////////////////////////////////////
// 
// Author       : 
// Purpose      : File has Driver classes for all channel of CHI Master
// Revision     :
//
//
////////////////////////////////////////////////////////////////////////////////
<% if (obj.testBench == "emu" ) { %>
class chi_chnl_base_driver #(type REQ = chi_base_seq_item, type RSP = REQ)
    extends uvm_driver #(REQ, RSP);
     //parameters. Constrainted specific to CHI Spec
    parameter int MAX_CREDITS = 15;
    protected chi_channel_func_t m_chnl_func;
    protected chi_channel_t      m_chnl_type;
    local bit                    k_cfg_params_set;
    chi_agent_cfg                m_cfg;
    uvm_event                    m_clk_trigger;

   `uvm_component_param_utils_begin(chi_chnl_base_driver#(REQ, RSP))
       `uvm_field_enum(chi_channel_func_t, m_chnl_func, UVM_DEFAULT)
       `uvm_field_enum(chi_channel_t, m_chnl_type, UVM_DEFAULT)
   `uvm_component_utils_end

  //Interface Methods
    extern function new(
       string name = "chi_chnl_base_driver",
       uvm_component parent = null);
    extern function void build_phase(uvm_phase phase);
    extern function void connect_phase(uvm_phase phase);
    extern function void assign_chnl_params(
      chi_channel_func_t chnl_func,
      chi_channel_t chnl_type);
    extern function void assign_link_params();

  //Helper methods for derivied classes
    extern task wait4reset();
    extern function bit is_under_reset();
    extern task wait4clk_event();
  //Driving tasks
    extern task drive_txlink_actv(logic val);
    extern task drive_rxlink_actv(logic val);
    extern task drive_txsactive(logic val);
  //Monitoring tasks
    extern function bit montr_lcredit();
    extern task montr_flit(output logic vld, output logic [MAX_FW-1:0] data);
    extern function bit montr_txlink_actv();
    extern function bit montr_rxlink_actv();
  //Internal methods
    extern function bit mon_rn_lcredit();
    extern function bit mon_sn_lcredit();
    extern function bit mon_rni_lcredit();
    extern task mon_rn_flit(output logic vld, output logic [MAX_FW-1:0] data);
    extern task mon_rni_flit(output logic vld, output logic [MAX_FW-1:0] data);
    extern task mon_sn_flit(output logic vld, output logic [MAX_FW-1:0] data);
  
    //wait functions
    extern task wait4txlink_ack();
    extern task wait4rxlink_ack_down();
    extern task wait4rxlink_req();

endclass: chi_chnl_base_driver

//Constructor
function chi_chnl_base_driver::new(
    string name = "chi_chnl_base_driver",
    uvm_component parent = null);

    super.new(name, parent);
    m_clk_trigger = new("clk");
endfunction: new

function void chi_chnl_base_driver::build_phase(uvm_phase phase);
    super.build_phase(phase);
            $display("In_chnl_build_phase");
endfunction: build_phase

function void chi_chnl_base_driver::connect_phase(uvm_phase phase);
     super.connect_phase(phase);
     if(!k_cfg_params_set) begin
         `uvm_fatal(get_name(), "Unable to set config params to driver")
     end
    if(m_cfg == null) begin
      `uvm_fatal(get_name(), "chi agent config object not assigned")
    end
endfunction: connect_phase

function void chi_chnl_base_driver::assign_chnl_params(
    chi_channel_func_t chnl_func,
    chi_channel_t chnl_type);

    m_chnl_func = chnl_func;
    m_chnl_type = chnl_type;
    k_cfg_params_set = 1'b1;
endfunction: assign_chnl_params

function void chi_chnl_base_driver::assign_link_params();
    k_cfg_params_set = 1'b1;
endfunction: assign_link_params

task chi_chnl_base_driver::wait4reset();
    m_cfg.wait4reset("driver");
endtask: wait4reset

function bit chi_chnl_base_driver::is_under_reset();
    return m_cfg.is_under_reset("driver");
endfunction: is_under_reset

task chi_chnl_base_driver::wait4clk_event();
  m_cfg.wait4clk_event("driver");
  `uvm_info(get_name(), $psprintf("CHI_EMU_DRIVER : waitforclk_called"), UVM_LOW) //D
endtask: wait4clk_event


task chi_chnl_base_driver::drive_txlink_actv(logic val);
  
    if (m_cfg.snp_chnl_exists())
   // `uvm_info(get_name(), $psprintf("value: %b", val), UVM_NONE)
      m_cfg.m_rn_drv_vif.rn_drv_cb.tx_link_active_req   <= val;

    else if (m_cfg.is_slave_node()) 
      m_cfg.m_rni_drv_vif.rni_drv_cb.tx_link_active_req <= val;

    else if (m_cfg.is_requestor_node()) 
      m_cfg.m_sn_drv_vif.sn_drv_cb.tx_link_active_req   <= val;

    else
      `uvm_fatal(get_name(), "Unexpected chi node type")
   
endtask: drive_txlink_actv

task chi_chnl_base_driver::drive_rxlink_actv(logic val);

    if (m_cfg.snp_chnl_exists()) 
      m_cfg.m_rn_drv_vif.rn_drv_cb.rx_link_active_ack   <= val;

    else if (m_cfg.is_slave_node()) 
      m_cfg.m_rni_drv_vif.rni_drv_cb.rx_link_active_ack <= val;

    else if (m_cfg.is_requestor_node()) 
      m_cfg.m_sn_drv_vif.sn_drv_cb.rx_link_active_ack   <= val;

    else
    `uvm_fatal(get_name(), "Unexpected chi node type")

endtask: drive_rxlink_actv

task chi_chnl_base_driver::drive_txsactive(logic val);
    if (m_cfg.snp_chnl_exists()) 
      m_cfg.m_rn_drv_vif.rn_drv_cb.tx_s_active   <= val;
    else if (m_cfg.is_slave_node()) 
      m_cfg.m_rni_drv_vif.rni_drv_cb.tx_s_active <= val;
    else if (m_cfg.is_requestor_node()) 
      m_cfg.m_sn_drv_vif.sn_drv_cb.tx_s_active   <= val;
    else
      `uvm_fatal(get_name(), "Unexpected chi node type")
endtask: drive_txsactive

task chi_chnl_base_driver::montr_flit(
    output logic vld, output logic [MAX_FW-1:0] data);
    if (m_cfg.snp_chnl_exists()) begin
      mon_rn_flit(vld, data);
      `uvm_info(get_name,$psprintf("CHI_EMU_DRIVER : passv_driver_link_snp_node"),UVM_LOW);
    end else if (m_cfg.is_slave_node()) begin
      mon_sn_flit(vld, data);
      `uvm_info(get_name,$psprintf("CHI_EMU_DRIVER : passv_driver_link_slave_node"),UVM_LOW);
    end else if (m_cfg.is_requestor_node()) begin
            $display($time, " CHI_EMU_DRIVER : passv_driver_link_request_node1");
             mon_rni_flit(vld, data);
            $display($time, " CHI_EMU_DRIVER : passv_driver_link_request_node2");
    end else begin
      `uvm_fatal(get_name(), "Unexpected chi node type")
    end
endtask: montr_flit

function bit chi_chnl_base_driver::montr_lcredit();
    if (m_cfg.snp_chnl_exists()) begin
      return mon_rn_lcredit();
    end else if (m_cfg.is_slave_node()) begin
      return mon_sn_lcredit();
    end else if (m_cfg.is_requestor_node()) begin
      return mon_rni_lcredit();
    end
    `uvm_fatal(get_name(), "Unexpected chi node type")
    return 0;  
endfunction: montr_lcredit

function bit chi_chnl_base_driver::montr_txlink_actv();
    if (m_cfg.snp_chnl_exists()) begin
      return m_cfg.m_rn_drv_vif.rn_drv_cb.tx_link_active_ack;
    end else if (m_cfg.is_slave_node()) begin
      return m_cfg.m_rni_drv_vif.rni_drv_cb.tx_link_active_ack;
    end else if (m_cfg.is_requestor_node()) begin
      return m_cfg.m_sn_drv_vif.sn_drv_cb.tx_link_active_ack;
    end

    `uvm_fatal(get_name(), "Unexpected chi node type")
    return 0;  
endfunction: montr_txlink_actv

function bit chi_chnl_base_driver::montr_rxlink_actv();
    if (m_cfg.snp_chnl_exists()) begin
      return m_cfg.m_rn_drv_vif.rn_drv_cb.rx_link_active_req;
    end else if (m_cfg.is_slave_node()) begin
      return m_cfg.m_rni_drv_vif.rni_drv_cb.rx_link_active_req;
    end else if (m_cfg.is_requestor_node()) begin
      return m_cfg.m_sn_drv_vif.sn_drv_cb.rx_link_active_req;
    end

    `uvm_fatal(get_name(), "Unexpected chi node type")
    return 0;  
endfunction: montr_rxlink_actv

task chi_chnl_base_driver::mon_rn_flit(output logic vld, output logic [MAX_FW-1:0] data);

    if (m_chnl_func == CHI_REACTIVE) begin
      if (m_chnl_type == CHI_RSP) begin
        vld  = m_cfg.m_rn_drv_vif.rn_drv_cb.rx_rsp_flitv;
        data = m_cfg.m_rn_drv_vif.rn_drv_cb.rx_rsp_flit;
        $display($time, " CHI_EMU_DRIVER : passv_driver_mon_rn_rsp");

      end else if (m_chnl_type == CHI_DAT) begin
        vld  = m_cfg.m_rn_drv_vif.rn_drv_cb.rx_dat_flitv;
        data = m_cfg.m_rn_drv_vif.rn_drv_cb.rx_dat_flit;
        $display($time, " CHI_EMU_DRIVER : passv_driver_mon_rn_dat vld is %h dat is %h",vld,data);

      end else if (m_chnl_type == CHI_SNP) begin
        vld  = m_cfg.m_rn_drv_vif.rn_drv_cb.rx_snp_flitv;
        data = m_cfg.m_rn_drv_vif.rn_drv_cb.rx_snp_flit;
        `uvm_info(get_name,$psprintf("CHI_EMU_DRIVER : passv_driver_mon_rn_snp"),UVM_LOW);

      end else begin
        `uvm_fatal(get_name(), "Unexpected channel type")
      end
    end else begin
      `uvm_fatal(get_name(), "Unexpected channel function")
    end

endtask: mon_rn_flit

task chi_chnl_base_driver::mon_rni_flit(output logic vld, output logic [MAX_FW-1:0] data);

    if (m_chnl_func == CHI_REACTIVE) begin
        if (m_chnl_type == CHI_RSP) begin
            vld  = m_cfg.m_rni_drv_vif.rni_drv_cb.rx_rsp_flitv;
            data = m_cfg.m_rni_drv_vif.rni_drv_cb.rx_rsp_flit;
  
        end else if (m_chnl_type == CHI_DAT) begin
            vld  = m_cfg.m_rni_drv_vif.rni_drv_cb.rx_dat_flitv;
            data = m_cfg.m_rni_drv_vif.rni_drv_cb.rx_dat_flit;
            $display($time, " CHI_EMU_DRIVER : passv_driver_montr_chi_dat");
  
        end else begin
           `uvm_fatal(get_name(), "Unexpected channel type")
        end
        end else begin
      `uvm_fatal(get_name(), "Unexpected channel function")
    end
endtask: mon_rni_flit

task chi_chnl_base_driver::mon_sn_flit(output logic vld, output logic [MAX_FW-1:0] data);

    if (m_chnl_func == CHI_REACTIVE) begin
        if (m_chnl_type == CHI_RSP) begin
          vld  = m_cfg.m_sn_drv_vif.sn_drv_cb.rx_rsp_flitv;
          data = m_cfg.m_sn_drv_vif.sn_drv_cb.rx_rsp_flit;

        end else if (m_chnl_type == CHI_DAT) begin
          vld  = m_cfg.m_sn_drv_vif.sn_drv_cb.rx_dat_flitv;
          data = m_cfg.m_sn_drv_vif.sn_drv_cb.rx_dat_flit;

       end else begin
          `uvm_fatal(get_name(), "Unexpected channel type")
       end
       end else begin
         `uvm_fatal(get_name(), "Unexpected channel function")
    end
endtask: mon_sn_flit

function bit chi_chnl_base_driver::mon_rn_lcredit();
    if (m_chnl_func == CHI_ACTIVE) begin
  
          if (m_chnl_type == CHI_REQ) begin
                if (m_cfg.m_rn_drv_vif.rn_drv_cb.tx_req_lcrdv)
                  return 1;
          end else if (m_chnl_type == CHI_RSP) begin
                if (m_cfg.m_rn_drv_vif.rn_drv_cb.tx_rsp_lcrdv)
                  return 1;
          end else if (m_chnl_type == CHI_DAT) begin
            if (m_cfg.m_rn_drv_vif.rn_drv_cb.tx_dat_lcrdv)
              return 1;
          end else begin
            `uvm_fatal(get_name(), "Unexpected channel type")
      end
  
    end else begin
      `uvm_fatal(get_name(), "Unexpected chnnel function")
    end
    return 0;
endfunction: mon_rn_lcredit

function bit chi_chnl_base_driver::mon_sn_lcredit();
    if (m_chnl_func == CHI_ACTIVE) begin

        if (m_chnl_type == CHI_RSP) begin
            if (m_cfg.m_sn_drv_vif.sn_drv_cb.tx_rsp_lcrdv)
              return 1;
        end else if (m_chnl_type == CHI_DAT) begin
            if (m_cfg.m_sn_drv_vif.sn_drv_cb.tx_dat_lcrdv)
              return 1;
        end else begin
            `uvm_fatal(get_name(), "Unexpected channel type")
        end

    end else begin
       `uvm_fatal(get_name(), "Unexpected chnnel function")
    end
    return 0;
endfunction: mon_sn_lcredit

function bit chi_chnl_base_driver::mon_rni_lcredit();
    if (m_chnl_func == CHI_ACTIVE) begin

        if (m_chnl_type == CHI_REQ) begin
            if (m_cfg.m_rni_drv_vif.rni_drv_cb.tx_req_lcrdv)
              return 1;
        end else if (m_chnl_type == CHI_RSP) begin
            if (m_cfg.m_rni_drv_vif.rni_drv_cb.tx_rsp_lcrdv)
              return 1;
        end else if (m_chnl_type == CHI_DAT) begin
            if (m_cfg.m_rni_drv_vif.rni_drv_cb.tx_dat_lcrdv)
              return 1;
        end else begin
          `uvm_fatal(get_name(), "Unexpected channel type")
        end

    end else begin
      `uvm_fatal(get_name(), "Unexpected chnnel function")
    end
    return 0;
endfunction: mon_rni_lcredit
//
task chi_chnl_base_driver::wait4txlink_ack();
  int n = 0;
  bit t;

    fork: tx_t1
      begin
        if (m_cfg.snp_chnl_exists()) 
          wait (m_cfg.m_rn_drv_vif.rn_drv_cb.tx_link_active_ack);

        else if (m_cfg.is_slave_node()) 
          wait (m_cfg.m_rni_drv_vif.rni_drv_cb.tx_link_active_ack);

        else if (m_cfg.is_requestor_node()) 
          wait (m_cfg.m_sn_drv_vif.sn_drv_cb.tx_link_active_ack);

        else
          `uvm_fatal(get_name(), "Unexpected chi node type")

           t = 1;
      end

      //Time out thread
      begin
        while (n < m_cfg.k_wt4tx_ack_tmo) begin
          wait4clk_event();
          n++;
        end
      end
    join_any

    disable tx_t1; 
    if (!t)
      `uvm_fatal(get_name(), "Tx-ACK didn't arrive in timly manner")
endtask: wait4txlink_ack

task chi_chnl_base_driver::wait4rxlink_ack_down();
    int n = 0;
    bit t;

    fork: tx_t1
      begin
        if (m_cfg.snp_chnl_exists())
          wait (m_cfg.m_rn_drv_vif.rn_drv_cb.rx_link_active_ack == 0);

        else if (m_cfg.is_slave_node())
          wait (m_cfg.m_rni_drv_vif.rni_drv_cb.rx_link_active_ack == 0);

        else if (m_cfg.is_requestor_node())
          wait (m_cfg.m_sn_drv_vif.sn_drv_cb.rx_link_active_ack == 0);

        else
          `uvm_fatal(get_name(), "Unexpected chi node type")

        t = 1;
      end
      //Time out thread
      begin
        while (n < m_cfg.k_wt4tx_ack_tmo) begin
          wait4clk_event();
          n++;
        end
      end
    join_any
  
    disable tx_t1;
    if (!t)
      `uvm_fatal(get_name(), "Rx-ACK didn't deassert in timely manner")
endtask: wait4rxlink_ack_down

task chi_chnl_base_driver::wait4rxlink_req();
    int n = 0;
    bit t;

    fork: rx_t1
      begin
        if (m_cfg.snp_chnl_exists()) 
          wait (m_cfg.m_rn_drv_vif.rn_drv_cb.tx_link_active_ack);

        else if (m_cfg.is_slave_node()) 
          wait (m_cfg.m_rni_drv_vif.rni_drv_cb.tx_link_active_ack);

        else if (m_cfg.is_requestor_node()) 
          wait (m_cfg.m_sn_drv_vif.sn_drv_cb.tx_link_active_ack);

        else
          `uvm_fatal(get_name(), "Unexpected chi node type")

        t = 1;
      end

      //Time out thread
      begin
        while (n < m_cfg.k_wt4rx_req_tmo) begin
          wait4clk_event();
          n++;
        end
      end
    join_any

    disable rx_t1; 
    if (!t)
      `uvm_fatal(get_name(), "Rx-Req didn't arrive in timly manner")
endtask: wait4rxlink_req


////////////////////////////////////////////////////////////////////////////////
// 
////////////////////////////////////////////////////////////////////////////////
class chi_actv_chnl_driver #(type REQ = chi_base_seq_item)
    extends chi_chnl_base_driver #(REQ);
  
    `uvm_component_param_utils_begin(chi_actv_chnl_driver#(REQ))
    `uvm_component_utils_end
    //Properties
    chi_flit_t                   m_chi_flit[$];
    chi_link_state               m_flitpenv;
    chi_credit_txn               m_crd;
    chi_link_state               m_lnk;
    chi_num_flits                m_num_flits;
    uvm_analysis_port #(REQ) tx_req_port;
    uvm_analysis_port #(REQ) tx_dat_port;
    uvm_analysis_port #(REQ) tx_rsp_port;

  //Methods
    extern function new(
      string name = "chi_actv_chnl_driver",
      uvm_component parent = null);
    extern function void build_phase(uvm_phase phase);
    extern function void connect_phase(uvm_phase phase);
    extern task          run_phase(uvm_phase phase);

    //Helper methods
    extern function void conv_txn2flit(ref REQ seq_item);
    extern task schedule_driving_flits();
    extern function logic [MAX_FW-1:0] construct_link_credit();
    extern task schedule_driving_lcrds(int k_timeout);
    extern task send_mgc_txn(ref REQ seq_item);  // Added for emu
   
endclass: chi_actv_chnl_driver

function chi_actv_chnl_driver::new(
    string name = "chi_actv_chnl_driver",
    uvm_component parent = null);
  
    super.new(name, parent);
    //We are using the Link state machine for FlitPendv signal interpretation
    //but valid states are: STOP, ACTIVE, RUN
    //INACTIVE is ILLEGAL
    m_flitpenv = new(name);
   tx_req_port = new("tx_req_port", this);
   tx_dat_port = new("tx_dat_port", this);
   tx_rsp_port = new("tx_rsp_port", this);
endfunction: new

function void chi_actv_chnl_driver::build_phase(uvm_phase phase);
    super.build_phase(phase);
            $display("In_actv_chnl_build_phase");
endfunction: build_phase

function void chi_actv_chnl_driver::connect_phase(uvm_phase phase);
    super.connect_phase(phase);

    if (m_chnl_func == CHI_ACTIVE) begin
      m_crd.set_name({"TX- ", m_chnl_type.name()});
    end else begin
      m_crd.set_name({"RX- ", m_chnl_type.name()});
      m_crd.link_in_rx_mode();
    end
endfunction: connect_phase

task chi_actv_chnl_driver::run_phase(uvm_phase phase);

    bit reset_done;
    bit [15:0] pend_trans;
    fork
      //Accept Seq items and acknowlege them
      begin
        forever begin
          REQ t_txn = new();
            pend_trans = m_cfg.k_max_pend_flits.get_value(); 
            `uvm_info(get_name,$psprintf("CHI_EMU_DRIVER : pend trans is %0h chi_flit_size is %0h",pend_trans,m_chi_flit.size()),UVM_LOW);
  
            if (reset_done == 0) begin
            wait4reset();
            reset_done = 1;
            end
            wait4clk_event();
          if (m_chi_flit.size() < m_cfg.k_max_pend_flits.get_value()) begin
            `uvm_info(get_name,$psprintf("CHI_EMU_DRIVER : actv_seq_item_blocking"),UVM_LOW);
            seq_item_port.get_next_item(t_txn);
            `uvm_info(get_name,$psprintf("CHI_EMU_DRIVER : actv_seq_item"),UVM_LOW);
            `uvm_info(get_name,$psprintf("CHI_EMU_DRIVER : before_send_mgc"),UVM_LOW);
            send_mgc_txn(t_txn);
            `uvm_info(get_name,$psprintf("CHI_EMU_DRIVER : after_send_mgc"),UVM_LOW);
            seq_item_port.item_done(t_txn);
          end
        end
      end
    join_none  
endtask: run_phase

//Drive flits
task chi_actv_chnl_driver::schedule_driving_flits();
    m_crd.get_credit(m_clk_trigger);
    repeat (m_chi_flit[0].dlyc) begin
      //drive_flit(1'b0, 512'hx);
   //   wait4clk_event();
    end
    //Drive Reset values until FlitPenv was asserted in
    //previous cycle
    while (!m_flitpenv.is_link_alive()) begin
     // drive_flit(1'b0, 512'hx);
     // wait4clk_event();
    end
    //Driving actual value
    //drive_flit(1'b1, m_chi_flit[0].data);
    //wait4clk_event();
    void'(m_chi_flit.pop_front());
endtask: schedule_driving_flits

task chi_actv_chnl_driver::schedule_driving_lcrds(int k_timeout);
    int timeout = 0;
    while (m_crd.peek_credits() > 0 && timeout < k_timeout) begin
      chi_flit_t tmp_flit;
      m_crd.get_credit(m_clk_trigger);
      tmp_flit.data = construct_link_credit();
      timeout++;
    end

    `ASSERT(timeout <= k_timeout,
      $psprintf("Chnl %s was not powered down within specified time",
        get_name()));
     m_lnk.chnl_ready4shutdown();

endtask: schedule_driving_lcrds

task chi_actv_chnl_driver::send_mgc_txn(ref REQ seq_item);

    if (m_chnl_func == CHI_ACTIVE) begin
        if (m_chnl_type == CHI_REQ) begin
            tx_req_port.write(seq_item);
        end else if(m_chnl_type == CHI_RSP) begin
            tx_rsp_port.write(seq_item);
        end else if(m_chnl_type == CHI_DAT) begin
            tx_dat_port.write(seq_item);
        end else begin
          `uvm_fatal(get_name(), "Unexpected channel type")
        end
     end
endtask: send_mgc_txn
function void chi_actv_chnl_driver::conv_txn2flit(ref REQ seq_item);
    packed_flit_t flit;

    flit = seq_item.pack_flit();
    foreach (flit[i]) begin
      chi_flit_t tmp_flit;

      tmp_flit.dlyc  = seq_item.n_cycles;
      tmp_flit.data  = flit[i];
      m_chi_flit.push_back(tmp_flit);
    end
      m_num_flits.set_num_pending_flits(get_name(), m_chi_flit.size());
endfunction: conv_txn2flit

function logic [MAX_FW-1:0] chi_actv_chnl_driver::construct_link_credit();
    logic [MAX_FW-1:0] crd_flit;
    //TODO FIXME
    crd_flit = 0;
    return crd_flit;
endfunction: construct_link_credit
////////////////////////////////////////////////////////////////////////////////
class chi_pasv_chnl_driver #(type REQ = chi_base_seq_item)
     extends chi_chnl_base_driver #(REQ);
    `uvm_component_param_utils_begin(chi_pasv_chnl_driver#(REQ))
    `uvm_component_utils_end

    //Properties
    chi_flit_t                   m_chi_flit[$];
    chi_flit_t                   my_chi_flit[$];
    chi_credit_txn               m_crd;
    chi_link_state               m_lnk;
    bit chi_rd_data;   //DHARMESH

    uvm_analysis_port #(chi_rsp_seq_item) rx_req_port;
    uvm_analysis_port #(chi_dat_seq_item) rx_dat_port;
    uvm_analysis_port #(chi_snp_seq_item) rx_rsp_port;
    
  //Methods
    extern function new(
      string name = "chi_actv_chnl_driver",
      uvm_component parent = null);
    extern function void build_phase(uvm_phase phase);
    extern function void connect_phase(uvm_phase phase);
    extern task          run_phase(uvm_phase phase);

    //Internal Helper methods
    extern function void conv_flit2txn(ref REQ seq_item);
    extern task read_flit();

endclass: chi_pasv_chnl_driver

function chi_pasv_chnl_driver::new(
    string name = "chi_actv_chnl_driver",
    uvm_component parent = null);

    super.new(name, parent);
    rx_req_port = new("rx_req_port", this);
    rx_dat_port = new("rx_dat_port", this);
    rx_rsp_port = new("rx_rsp_port", this);
endfunction: new

function void chi_pasv_chnl_driver::build_phase(uvm_phase phase);
    super.build_phase(phase);
            $display("In_passv_chnl_build_phase");
endfunction: build_phase

function void chi_pasv_chnl_driver::connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    if (m_chnl_func == CHI_ACTIVE) begin
        m_crd.set_name({"TX- ", m_chnl_type.name()});
    end else begin
        m_crd.set_name({"RX- ", m_chnl_type.name()});
        m_crd.link_in_rx_mode();
    end
endfunction: connect_phase

task chi_pasv_chnl_driver::run_phase(uvm_phase phase);

    bit give_credits;
    int strv_count;
    wait4clk_event();
    fork
      //Accept Seq items and acknowlege them
      begin
        forever begin
          REQ t_txn;
             `uvm_info(get_name,$psprintf("CHI_EMU_DRIVER : passv_seq_item_before_wait size is %0h",m_chi_flit.size()),UVM_LOW);
             wait(m_chi_flit.size());       
             seq_item_port.get_next_item(t_txn);
             conv_flit2txn(t_txn);
             seq_item_port.item_done(t_txn);
             t_txn.print();
              wait4clk_event();
        end
      end

      begin
        forever begin
          if (is_under_reset()) begin
            logic vld;
            logic [MAX_FW-1:0] data;
            wait4clk_event();
            montr_flit(vld, data);
          end else if (m_lnk.is_link_alive()) begin
            read_flit();
            `uvm_info(get_name,$psprintf("CHI_EMU_DRIVER : passv_driver_link_active"),UVM_LOW);
          end else begin
            if (m_lnk.get_link_state() == INACTIVE) begin
              read_flit();
            end
            else begin
              logic              vld;
              logic [MAX_FW-1:0] data;

              wait4clk_event();
              montr_flit(vld, data);
              end
          end
        end
      end
   join_none

endtask: run_phase

function void chi_pasv_chnl_driver::conv_flit2txn(ref REQ seq_item);
    packed_flit_t flit;
    packed_flit_t my_flit;

    flit.push_back(m_chi_flit[0].data);
    `uvm_info(get_name,$psprintf("CHI_EMU_DRIVER : passv_seq_item_before_cnvflittxn_wait size is %0h data is %0h",m_chi_flit.size(),m_chi_flit[0].data),UVM_LOW);
    seq_item.unpack_flit(flit);
    void'(m_chi_flit.pop_front());
    `uvm_info(get_name,$psprintf("CHI_EMU_DRIVER : passv_seq_item_after_cnvflittxn_wait size is %0h",my_chi_flit.size()),UVM_LOW);
endfunction: conv_flit2txn

task chi_pasv_chnl_driver::read_flit();
  logic              vld;
  logic [MAX_FW-1:0] data;
  chi_flit_t         tmp_flit;

  wait4clk_event();
  montr_flit(vld, data);
  if (vld) begin
      `uvm_info(get_name,$psprintf("CHI_EMU_DRIVER : read_flit_called"),UVM_LOW);
      tmp_flit.dlyc = 0;
      tmp_flit.data = data;          
      chi_rd_data = 1;
      if (m_lnk.get_link_state() != INACTIVE) begin
          `uvm_info(get_name,$psprintf("CHI_EMU_DRIVER : read_flit_called_inside tmp_flit data is %0h chi_rdata is %0h",tmp_flit.data,chi_rd_data),UVM_LOW);
          m_chi_flit.push_back(tmp_flit);
         `uvm_info(get_name,$psprintf("CHI_EMU_DRIVER : read_flit_size is %0h data is %0h",m_chi_flit.size(),m_chi_flit[0].data),UVM_LOW);
       end
  end
endtask: read_flit
////////////////////////////////////////////////////////////////////////////////
class chi_link_req_driver #(type REQ = chi_base_seq_item) 
    extends chi_chnl_base_driver #(REQ);

    `uvm_component_param_utils_begin(chi_link_req_driver#(REQ))
    `uvm_component_utils_end

    logic m_txsig_val, m_rxsig_val;
    chi_link_state  m_txlink;
    chi_link_state  m_rxlink;

    //Methods
    extern function new(
      string name = "chi_link_req_driver",
      uvm_component parent = null);

    extern function void build_phase(uvm_phase   phase);
    extern function void connect_phase(uvm_phase phase);
    extern task          run_phase(uvm_phase phase);

    //Helper Methods
    extern task schedule_link_req(const ref REQ seq_item);
    extern task schedule_link_ack();
    extern task pow_up_tx_ln(const ref REQ seq_item);
    extern task wait_rx_ln_up(const ref REQ seq_item);
    extern task pow_dn_tx_ln(const ref REQ seq_item);

endclass: chi_link_req_driver

function chi_link_req_driver::new(
    string name = "chi_link_req_driver",
    uvm_component parent = null);

    super.new(name, parent);
    m_txsig_val = 0;
    m_rxsig_val = 0;
endfunction: new

function void chi_link_req_driver::build_phase(uvm_phase   phase);
    super.build_phase(phase);
            $display("In_link_build_phase");
endfunction: build_phase

function void chi_link_req_driver::connect_phase(uvm_phase phase);
    super.connect_phase(phase);
endfunction: connect_phase

task chi_link_req_driver::run_phase(uvm_phase phase);

    drive_txlink_actv(m_txsig_val);
    wait4clk_event();
    fork
      begin
        REQ t_txn;
        forever begin
          wait4clk_event();
          if (!is_under_reset()) begin
            seq_item_port.get_next_item(t_txn);
            $display($time, " CHI_EMU_DRIVER : link_seq_item");
            schedule_link_req(t_txn);
            seq_item_port.item_done(t_txn);
          end
        end
      end
    //Drive-Monitor TX-Link lane
     begin
       forever begin
         drive_txlink_actv(m_txsig_val);
        wait4clk_event();
         m_txlink.link_signal_value(m_txsig_val, montr_txlink_actv());
       end
     end
    //Drive-Monitor RX-Link lane
      begin
        forever begin
          //drive_rxlink_actv(m_rxsig_val);
          wait4clk_event();
          m_rxlink.link_signal_value(montr_rxlink_actv(), m_rxsig_val);
          $display($time, "CHI_EMU_DRIVER :: m_rxsig_val = %h", m_rxsig_val) ;
        end
      end
    //Depending on RX-req drive RX-ACK
      begin
        forever begin
          if (m_rxlink.is_link_alive()) begin
            m_rxsig_val = m_cfg.m_rn_drv_vif.rn_drv_cb.rx_link_active_ack;
           // m_rxsig_val = 1;
          $display($time, "CHI_EMU_DRIVER In forever:: m_rxsig_val = %h", m_rxsig_val) ;
            wait4clk_event();

          end else begin
            schedule_link_ack();
          end
        end
      end

  join_none  
endtask: run_phase

task chi_link_req_driver::schedule_link_req(const ref REQ seq_item);
    case(seq_item.m_txactv_st)
      POWUP_TX_LN:      pow_up_tx_ln(seq_item);
      WAIT4RX_LN2POWUP: wait_rx_ln_up(seq_item);
      POWDN_TX_LN:      pow_dn_tx_ln(seq_item);
    endcase
endtask: schedule_link_req

task chi_link_req_driver::pow_up_tx_ln(const ref REQ seq_item);
    int n = seq_item.n_cycles;
    $display($time, "CHI_EMU_DRIVER : pow_up_before");
    while (n > 0) begin
      wait4clk_event();
      n--;
    end 
    $display($time, "CHI_EMU_DRIVER : pow_up_middle");
    m_txsig_val = 1'b1;
    wait4txlink_ack();
    $display($time, "CHI_EMU_DRIVER : pow_up_after");
endtask: pow_up_tx_ln

task chi_link_req_driver::wait_rx_ln_up(const ref REQ seq_item);
    int n = seq_item.n_cycles;

    $display($time, "CHI_EMU_DRIVER : wait_rx_before");
    wait4rxlink_req();
    $display($time, "CHI_EMU_DRIVER : wait_rx_after");
    while (n > 0) begin
      wait4clk_event();
      n--;
    end 
    $display($time, "CHI_EMU_DRIVER : wait_rx_after1");
    m_txsig_val = 1'b1;
    wait4txlink_ack();
    $display($time, "CHI_EMU_DRIVER : wait_rx_after2");
endtask: wait_rx_ln_up

task chi_link_req_driver::pow_dn_tx_ln(const ref REQ seq_item);
    int n = seq_item.n_cycles;

    $display($time, "CHI_EMU_DRIVER : pow_dn_before");
    while (n > 0) begin
      wait4clk_event();
      n--;
    end 
    $display($time, "CHI_EMU_DRIVER : pow_dn_middle");
    m_txsig_val = 1'b0;
    wait4rxlink_ack_down();
    $display($time, "CHI_EMU_DRIVER : pow_dn_after");
endtask: pow_dn_tx_ln

task chi_link_req_driver::schedule_link_ack();
    int n;
    case(m_rxlink.get_link_state())
      STOP: begin
        m_rxsig_val = 0;
        wait4clk_event();
      end

      ACTIVE: begin
        n = m_cfg.k_rxack_rsp4rxreq.get_value();
        while (n > 0) begin
          m_rxsig_val = 0;
          wait4clk_event();
          n--;
        end
        m_rxsig_val = 1;
        wait4clk_event();
      end

      INACTIVE: begin
        n = 20;
        while (n > 0) begin //FIX ME Need to find a better way
          m_rxsig_val = 1;
          wait4clk_event();
          n--;
        end
        m_rxsig_val = 0;
        wait4clk_event();
      end

      default: `ASSERT(0, "Should not enter this loop");
    endcase
endtask: schedule_link_ack
////////////////////////////////////////////////////////////////////////////////

class chi_txs_actv_driver #(type REQ = chi_base_seq_item)
    extends chi_chnl_base_driver #(REQ);

    `uvm_component_param_utils_begin(chi_txs_actv_driver#(REQ))
    `uvm_component_utils_end

    chi_num_flits   m_num_flits;
    chi_link_state  m_lnk;
    bit signal_val;

    extern function new(
      string name = "chi_txs_actv_driver",
      uvm_component parent = null);
    extern function void build_phase(uvm_phase   phase);
    extern function void connect_phase(uvm_phase phase);
    extern task          run_phase(uvm_phase phase);

endclass: chi_txs_actv_driver

function chi_txs_actv_driver::new(
    string name = "chi_txs_actv_driver",
    uvm_component parent = null);
    super.new(name, parent);
    signal_val = 1'b0;
endfunction: new

function void chi_txs_actv_driver::build_phase(uvm_phase   phase);
    super.build_phase(phase);
            $display("In_txs_build_phase");
endfunction: build_phase

function void chi_txs_actv_driver::connect_phase(uvm_phase phase);
    super.connect_phase(phase);
endfunction: connect_phase

task chi_txs_actv_driver::run_phase(uvm_phase phase);
    semaphore m_sem;
    m_sem = new(1);
    drive_txsactive(1'b0);
    wait4clk_event();
    fork
      //drive txsactive signal
      begin
        forever begin 
          m_sem.get(1);
        if (m_lnk.get_link_state() == STOP)
            drive_txsactive(1'b0);
          else 
            drive_txsactive(signal_val);

          wait4clk_event();
         $display($time, " CHI_EMU_DRIVER : chi_txs_actv");
          m_sem.put(1);
        end
      end

      //de-assert txsactive if received seq_item for pow-Mgmt
      begin
        REQ t_txn;

        forever begin 
          wait4clk_event();
          seq_item_port.get_next_item(t_txn);
            $display($time, " CHI_EMU_DRIVER : txsactv_seq_item");
          m_sem.get(1);
          signal_val = t_txn.txsactv;
          m_sem.put(1);
          seq_item_port.item_done(t_txn);
        end
      end
    join_none
endtask: run_phase

 <% } %>
