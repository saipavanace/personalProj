////////////////////////////////////////////////////////////////////////////////
// 
// Author       : 
// Purpose      : File has Driver classes for all channel of CHI Master
// Revision     :
//
//
////////////////////////////////////////////////////////////////////////////////

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
  extern task drive_flit(logic val, logic [MAX_FW-1:0] data);
  extern task drive_flitpend(logic val);
  extern task drive_lcredit(logic val);
  extern task drive_txlink_actv(logic val);
  extern task drive_rxlink_actv(logic val);
  extern task drive_txsactive(logic val);
  extern task drive_sysco(logic val);

  //Monitoring tasks
  extern function bit montr_lcredit();
  extern task montr_flit(output logic vld, output logic [MAX_FW-1:0] data);
  extern function bit montr_txlink_actv();
  extern function bit montr_rxlink_actv();
  extern function bit montr_sysco();

  //Internal methods
  extern task drv_rn_flit(logic val,  logic [MAX_FW-1:0] data);
  extern task drv_sn_flit(logic val,  logic [MAX_FW-1:0] data);
  extern task drv_rni_flit(logic val, logic [MAX_FW-1:0] data);
  extern task drv_rn_fltpend(logic val);
  extern task drv_rni_fltpend(logic val);
  extern task drv_sn_fltpend(logic val);
  extern task drv_rn_lcredit(logic val);
  extern task drv_rni_lcredit(logic val);
  extern task drv_sn_lcredit(logic val);

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
endtask: wait4clk_event

task chi_chnl_base_driver::drive_flit(logic val, logic [MAX_FW-1:0] data);

  if (m_cfg.snp_chnl_exists()) begin
    drv_rn_flit(val, data);
  end else if (m_cfg.is_slave_node()) begin
    drv_sn_flit(val, data);
  end else if (m_cfg.is_requestor_node()) begin
    drv_rni_flit(val, data);
  end else begin
    `uvm_fatal(get_name(), "Unexpected chi node type")
  end

endtask: drive_flit

task chi_chnl_base_driver::drive_flitpend(logic val);

  if (m_cfg.snp_chnl_exists()) begin
    drv_rn_fltpend(val);
  end else if (m_cfg.is_slave_node()) begin
    drv_sn_fltpend(val);
  end else if (m_cfg.is_requestor_node()) begin
    drv_rni_fltpend(val);
  end else begin
    `uvm_fatal(get_name(), "Unexpected chi node type")
  end

endtask: drive_flitpend

task chi_chnl_base_driver::drive_lcredit(logic val);

  if (m_cfg.snp_chnl_exists()) begin
    drv_rn_lcredit(val);
  end else if (m_cfg.is_slave_node()) begin
    drv_sn_lcredit(val);
  end else if (m_cfg.is_requestor_node()) begin
    drv_rni_lcredit(val);
  end else begin
    `uvm_fatal(get_name(), "Unexpected chi node type")
  end

endtask: drive_lcredit

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
    m_cfg.m_rn_drv_vif.rn_drv_cb.tx_sactive   <= val;

  else if (m_cfg.is_slave_node()) 
    m_cfg.m_rni_drv_vif.rni_drv_cb.tx_sactive <= val;

  else if (m_cfg.is_requestor_node()) 
    m_cfg.m_sn_drv_vif.sn_drv_cb.tx_sactive   <= val;

  else
    `uvm_fatal(get_name(), "Unexpected chi node type")

endtask: drive_txsactive

task chi_chnl_base_driver::drive_sysco(logic val);

  if (m_chnl_func == CHI_ACTIVE) begin
    if (m_cfg.snp_chnl_exists())
      m_cfg.m_rn_drv_vif.rn_drv_cb.sysco_req   <= val;

    else if (m_cfg.is_requestor_node())
      m_cfg.m_rni_drv_vif.rni_drv_cb.sysco_req <= val;

    else if (m_cfg.is_slave_node())
      m_cfg.m_sn_drv_vif.sn_drv_cb.sysco_ack <= val;

    else
      `uvm_fatal(get_name(), "Unexpected chi node type")
  end else begin
    `uvm_fatal(get_name(), "Unexpected channel function")
  end

endtask: drive_sysco

task chi_chnl_base_driver::montr_flit(
  output logic vld, output logic [MAX_FW-1:0] data);

  if (m_cfg.snp_chnl_exists()) begin
    mon_rn_flit(vld, data);
  end else if (m_cfg.is_slave_node()) begin
    mon_sn_flit(vld, data);
  end else if (m_cfg.is_requestor_node()) begin
    mon_rni_flit(vld, data);
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

function bit chi_chnl_base_driver::montr_sysco();

  if (m_cfg.snp_chnl_exists()) begin
    return m_cfg.m_rn_drv_vif.rn_drv_cb.sysco_ack;
  end else if (m_cfg.is_requestor_node()) begin
    return m_cfg.m_rni_drv_vif.rni_drv_cb.sysco_ack;
  end else if (m_cfg.is_slave_node()) begin
    return m_cfg.m_sn_drv_vif.sn_drv_cb.sysco_req;
  end

  `uvm_fatal(get_name(), "Unexpected chi node type")
  return 0;
endfunction: montr_sysco

task chi_chnl_base_driver::drv_rn_flit(logic val, logic [MAX_FW-1:0] data);

  if (m_chnl_func == CHI_ACTIVE) begin

    if (m_chnl_type == CHI_REQ) begin
      m_cfg.m_rn_drv_vif.rn_drv_cb.tx_req_flitv <= val;
      m_cfg.m_rn_drv_vif.rn_drv_cb.tx_req_flit  <= data;

    end else if(m_chnl_type == CHI_RSP) begin
      m_cfg.m_rn_drv_vif.rn_drv_cb.tx_rsp_flitv <= val;
      m_cfg.m_rn_drv_vif.rn_drv_cb.tx_rsp_flit  <= data;

    end else if(m_chnl_type == CHI_DAT) begin
      m_cfg.m_rn_drv_vif.rn_drv_cb.tx_dat_flitv <= val;
      m_cfg.m_rn_drv_vif.rn_drv_cb.tx_dat_flit  <= data;
    end else begin
      `uvm_fatal(get_name(), "Unexpected channel type")
    end

  end else begin
    `uvm_fatal(get_name(), "Unexpected channel function")
  end
endtask: drv_rn_flit

task chi_chnl_base_driver::drv_sn_flit(logic val, logic [MAX_FW-1:0] data);

  if (m_chnl_func == CHI_ACTIVE) begin

    if(m_chnl_type == CHI_RSP) begin
      m_cfg.m_sn_drv_vif.sn_drv_cb.tx_rsp_flitv <= val;
      m_cfg.m_sn_drv_vif.sn_drv_cb.tx_rsp_flit  <= data;

    end else if(m_chnl_type == CHI_DAT) begin
      m_cfg.m_sn_drv_vif.sn_drv_cb.tx_dat_flitv <= val;
      m_cfg.m_sn_drv_vif.sn_drv_cb.tx_dat_flit  <= data;
    end else begin
      `uvm_fatal(get_name(), "Unexpected channel type")
    end

  end else begin
    `uvm_fatal(get_name(), "Unexpected channel function")
  end
endtask: drv_sn_flit

task chi_chnl_base_driver::drv_rni_flit(logic val, logic [MAX_FW-1:0] data);

  if (m_chnl_func == CHI_ACTIVE) begin

    if (m_chnl_type == CHI_REQ) begin
      m_cfg.m_rni_drv_vif.rni_drv_cb.tx_req_flitv <= val;
      m_cfg.m_rni_drv_vif.rni_drv_cb.tx_req_flit  <= data;

    end else if(m_chnl_type == CHI_RSP) begin
      m_cfg.m_rni_drv_vif.rni_drv_cb.tx_rsp_flitv <= val;
      m_cfg.m_rni_drv_vif.rni_drv_cb.tx_rsp_flit  <= data;

    end else if(m_chnl_type == CHI_DAT) begin
      m_cfg.m_rni_drv_vif.rni_drv_cb.tx_dat_flitv <= val;
      m_cfg.m_rni_drv_vif.rni_drv_cb.tx_dat_flit  <= data;
    end else begin
      `uvm_fatal(get_name(), "Unexpected channel type")
    end

  end else begin
    `uvm_fatal(get_name(), "Unexpected channel function")
  end
endtask: drv_rni_flit

task chi_chnl_base_driver::drv_rn_fltpend(logic val);

  if (m_chnl_func == CHI_ACTIVE) begin
    if (m_chnl_type == CHI_REQ)
      m_cfg.m_rn_drv_vif.rn_drv_cb.tx_req_flit_pend <= val;

    else if(m_chnl_type == CHI_RSP)
      m_cfg.m_rn_drv_vif.rn_drv_cb.tx_rsp_flit_pend <= val;

    else if(m_chnl_type == CHI_DAT)
      m_cfg.m_rn_drv_vif.rn_drv_cb.tx_dat_flit_pend <= val;

    else
      `uvm_fatal(get_name(), "Unexpected channel type")
  end else begin
    `uvm_fatal(get_name(), "Unexpected channel function")
  end
endtask: drv_rn_fltpend

task chi_chnl_base_driver::drv_rni_fltpend(logic val);

  if (m_chnl_func == CHI_ACTIVE) begin
    if (m_chnl_type == CHI_REQ)
      m_cfg.m_rni_drv_vif.rni_drv_cb.tx_req_flit_pend <= val;

    else if(m_chnl_type == CHI_RSP)
      m_cfg.m_rni_drv_vif.rni_drv_cb.tx_rsp_flit_pend <= val;

    else if(m_chnl_type == CHI_DAT)
      m_cfg.m_rni_drv_vif.rni_drv_cb.tx_dat_flit_pend <= val;

    else
      `uvm_fatal(get_name(), "Unexpected channel type")
  end else begin
    `uvm_fatal(get_name(), "Unexpected channel function")
  end
endtask: drv_rni_fltpend

task chi_chnl_base_driver::drv_sn_fltpend(logic val);

  if (m_chnl_func == CHI_ACTIVE) begin
    if(m_chnl_type == CHI_RSP)
      m_cfg.m_sn_drv_vif.sn_drv_cb.tx_rsp_flit_pend <= val;

    else if(m_chnl_type == CHI_DAT)
      m_cfg.m_sn_drv_vif.sn_drv_cb.tx_dat_flit_pend <= val;

    else
      `uvm_fatal(get_name(), "Unexpected channel type")
  end else begin
    `uvm_fatal(get_name(), "Unexpected channel function")
  end
endtask: drv_sn_fltpend

task chi_chnl_base_driver::drv_rn_lcredit(logic val);

  if (m_chnl_func == CHI_REACTIVE) begin
    if (m_chnl_type == CHI_RSP) 
      m_cfg.m_rn_drv_vif.rn_drv_cb.rx_rsp_lcrdv <= val;
    else if (m_chnl_type == CHI_DAT) 
      m_cfg.m_rn_drv_vif.rn_drv_cb.rx_dat_lcrdv <= val;
    else if (m_chnl_type == CHI_SNP)
      m_cfg.m_rn_drv_vif.rn_drv_cb.rx_snp_lcrdv <= val;
    else 
      `uvm_fatal(get_name(), "Unexpected channel type")
  end else begin
    `uvm_fatal(get_name(), "Unexpected channel function")
  end
endtask: drv_rn_lcredit

task chi_chnl_base_driver::drv_rni_lcredit(logic val);

  if (m_chnl_func == CHI_REACTIVE) begin
    if (m_chnl_type == CHI_RSP) 
      m_cfg.m_rni_drv_vif.rni_drv_cb.rx_rsp_lcrdv <= val;
    else if (m_chnl_type == CHI_DAT) 
      m_cfg.m_rni_drv_vif.rni_drv_cb.rx_dat_lcrdv <= val;
    else 
      `uvm_fatal(get_name(), "Unexpected channel type")
  end else begin
    `uvm_fatal(get_name(), "Unexpected channel function")
  end
endtask: drv_rni_lcredit

task chi_chnl_base_driver::drv_sn_lcredit(logic val);

  if (m_chnl_func == CHI_REACTIVE) begin
    if (m_chnl_type == CHI_RSP) 
    `ifndef VCS // rx_rsp_lcrdv is not defined in clocking block sn_drv_db
      m_cfg.m_sn_drv_vif.sn_drv_cb.rx_rsp_lcrdv <= val;
    `else
      ;
    `endif
    else if (m_chnl_type == CHI_DAT) 
      m_cfg.m_sn_drv_vif.sn_drv_cb.rx_dat_lcrdv <= val;
    else 
      `uvm_fatal(get_name(), "Unexpected channel type")
  end else begin
    `uvm_fatal(get_name(), "Unexpected channel function")
  end
endtask: drv_sn_lcredit

task chi_chnl_base_driver::mon_rn_flit(output logic vld, output logic [MAX_FW-1:0] data);

  if (m_chnl_func == CHI_REACTIVE) begin
    if (m_chnl_type == CHI_RSP) begin
      vld  = m_cfg.m_rn_drv_vif.rn_drv_cb.rx_rsp_flitv;
      data = m_cfg.m_rn_drv_vif.rn_drv_cb.rx_rsp_flit;

    end else if (m_chnl_type == CHI_DAT) begin
      vld  = m_cfg.m_rn_drv_vif.rn_drv_cb.rx_dat_flitv;
      data = m_cfg.m_rn_drv_vif.rn_drv_cb.rx_dat_flit;

    end else if (m_chnl_type == CHI_SNP) begin
      vld  = m_cfg.m_rn_drv_vif.rn_drv_cb.rx_snp_flitv;
      data = m_cfg.m_rn_drv_vif.rn_drv_cb.rx_snp_flit;

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
    `ifndef VCS // rx_rsp_flitv is not defined in clocking block sn_drv_db
      vld  = m_cfg.m_sn_drv_vif.sn_drv_cb.rx_rsp_flitv;
      data = m_cfg.m_sn_drv_vif.sn_drv_cb.rx_rsp_flit;
    `else
      ;
    `endif

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

endclass: chi_actv_chnl_driver

function chi_actv_chnl_driver::new(
  string name = "chi_actv_chnl_driver",
  uvm_component parent = null);

  super.new(name, parent);
  //We are using the Link state machine for FlitPendv signal interpretation
  //but valid states are: STOP, ACTIVE, RUN
  //INACTIVE is ILLEGAL
  m_flitpenv = new(name);
endfunction: new

function void chi_actv_chnl_driver::build_phase(uvm_phase phase);
  super.build_phase(phase);
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

  drive_flit(1'b0, 512'hx);
  drive_flitpend(1'b0);
  wait4clk_event();
  fork
    begin
      forever begin
        chi_link_state_t m_cur_link_st;
        wait4clk_event();
        m_cur_link_st = m_lnk.get_link_state();
        //Added m_cur_link_st != m_lnk.get_link_state() condition to ignore checks one cycle after state change.
        if ((m_cur_link_st != RUN) && montr_lcredit() && (m_cur_link_st != m_lnk.get_link_state())) begin
            `uvm_fatal(get_name(), $psprintf("CHI AIU must not send credits during %s state", m_cur_link_st))
        end
      end
    end

    //Accept Seq items and acknowlege them
    begin
      forever begin
        REQ t_txn;

        if (m_chi_flit.size() < m_cfg.k_max_pend_flits.get_value()) begin
          seq_item_port.get_next_item(t_txn);
          conv_txn2flit(t_txn);
          seq_item_port.item_done(t_txn);
        end
        wait4clk_event();
      end
    end

    //Drive Flits
    begin
      forever begin
        if (is_under_reset()) begin

          if (m_chi_flit.size())
            m_chi_flit.delete();
          drive_flit(1'b0, 512'hx);
          wait4clk_event();

        end else begin

           if (m_lnk.is_link_alive()) begin

             if (m_crd.peek_credits() > 0 && m_chi_flit.size() > 0) begin
               schedule_driving_flits();
             end else if (m_lnk.start_chnl_powdn()) begin
               schedule_driving_lcrds(m_cfg.k_chnl_powdn);
             end else begin
               drive_flit(1'b0, 512'hx);
               wait4clk_event();
             end  

           end else begin

             drive_flit(1'b0, 512'hx);
             wait4clk_event();
             if (m_lnk.get_link_state() == INACTIVE) begin
               schedule_driving_lcrds(m_cfg.k_chnl_powdn);
             end
           end
        end
      end
    end
  
    //Drive Flit pending signal
    begin
      forever begin
        if (is_under_reset()) begin
          drive_flitpend(1'b0);
          wait4clk_event();
        end else begin
          if (m_cfg.get_flitpend_st() == FLTPENDV_HIGH) begin
            drive_flitpend(1'b1);
            wait4clk_event();
            m_flitpenv.link_signal_value(1'b1, 1'b1);
          end
        end
      end
    end

    //Accept Credits
    begin
      forever begin
        wait4clk_event();
        if (montr_lcredit()) begin
          `ASSERT(!is_under_reset(), "L-Credit asserted while on reset");
          `ASSERT(m_lnk.get_link_state() != STOP, "Link is de-asserted.");
          m_crd.put_credit();
        end
      end
    end

    //Trigger clock event
    begin
      forever begin
        wait4clk_event();
        m_clk_trigger.trigger();
      end
    end
  join_none  
endtask: run_phase

//Drive flits
task chi_actv_chnl_driver::schedule_driving_flits();
  m_crd.get_credit(m_clk_trigger);
  repeat (m_chi_flit[0].dlyc) begin
    drive_flit(1'b0, 512'hx);
    wait4clk_event();
  end
  //Drive Reset values until FlitPenv was asserted in
  //previous cycle
  while (!m_flitpenv.is_link_alive()) begin
    drive_flit(1'b0, 512'hx);
    wait4clk_event();
  end
  //Driving actual value
  drive_flit(1'b1, m_chi_flit[0].data);
  wait4clk_event();
  void'(m_chi_flit.pop_front());
endtask: schedule_driving_flits

task chi_actv_chnl_driver::schedule_driving_lcrds(int k_timeout);
  int timeout = 0;

  while (m_crd.peek_credits() > 0 && timeout < k_timeout) begin
    chi_flit_t tmp_flit;

    m_crd.get_credit(m_clk_trigger);
    tmp_flit.data = construct_link_credit();
    drive_flit(1'b1, tmp_flit.data);
    wait4clk_event();
    timeout++;
  end

  `ASSERT(timeout <= k_timeout,
    $psprintf("Chnl %s was not powered down within specified time",
      get_name()));
   m_lnk.chnl_ready4shutdown();

endtask: schedule_driving_lcrds

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
// 
////////////////////////////////////////////////////////////////////////////////
class chi_pasv_chnl_driver #(type REQ = chi_base_seq_item)
   extends chi_chnl_base_driver #(REQ);

  `uvm_component_param_utils_begin(chi_pasv_chnl_driver#(REQ))
  `uvm_component_utils_end

  //Properties
  chi_flit_t                   m_chi_flit[$];
  chi_credit_txn               m_crd;
  chi_link_state               m_lnk;
  

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
endfunction: new

function void chi_pasv_chnl_driver::build_phase(uvm_phase phase);
  super.build_phase(phase);
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

  drive_lcredit(1'b0);
  wait4clk_event();
  fork

    begin
      forever begin
        chi_link_state_t m_cur_link_st;
        logic flit_vld;
        logic [MAX_FW-1:0] flit_data;

        wait4clk_event();
        montr_flit(flit_vld, flit_data);
        m_cur_link_st = m_lnk.get_link_state();
        if (((m_cur_link_st == STOP) || (m_cur_link_st == ACTIVE)) && flit_vld) begin
            `uvm_fatal(get_name(), $psprintf("CHI AIU must not send flits during %s state", m_cur_link_st))
        end
        if ((m_cur_link_st == INACTIVE) && flit_vld && (flit_data !== 'h0)) begin
            `uvm_fatal(get_name(), $psprintf("Flit data should be 0 during %s(DEACTIVE) state", m_cur_link_st))
        end
      end
    end
    
    //Accept Seq items and acknowlege them
    begin
      forever begin
        REQ t_txn;

        wait(m_chi_flit.size());       
        seq_item_port.get_next_item(t_txn);
        conv_flit2txn(t_txn);
        seq_item_port.item_done(t_txn);
        
        //Not waiting for clock to process the Respnse pkt on same cycle
        //it is received. Any-ways we will receive only one flit per cycle
        //wait4clk_event();
      end
    end

    //Read received flits
    begin
      forever begin
        if (is_under_reset()) begin
          logic vld;
          logic [MAX_FW-1:0] data;

          wait4clk_event();
          montr_flit(vld, data);
          `ASSERT((vld == 0), "vld must not be asserted while reset inprogress");
          
        end else if (m_lnk.is_link_alive()) begin
          read_flit();
        end else begin
          if (m_lnk.get_link_state() == INACTIVE) begin
            read_flit();
          end
          else begin
            logic              vld;
            logic [MAX_FW-1:0] data;

            wait4clk_event();
            montr_flit(vld, data);
            `ASSERT((vld == 0),
               $psprintf("vld must not be asserted in link state: %s",
                 m_lnk.get_link_state().name()));
          end
        end
      end
    end

    //Drive l-Credits
    begin
      forever begin
        if (m_lnk.is_link_alive()) begin
          case (m_cfg.get_rxcrd_mode())

            BURST_MODE: begin
              if (m_crd.peek_credits() > 0) begin
                m_crd.get_credit(m_clk_trigger);
                drive_lcredit(1'b1);
              end else begin
                drive_lcredit(1'b0);
              end
            end
            STRV_MODE: begin
              if (m_crd.peek_credits() == MAX_CREDITS) begin
                give_credits = 1;
              end
              if (m_crd.peek_credits() == 0) begin
                give_credits = 0;
                strv_count = $urandom_range(5000,1000);
              end
              if (give_credits && strv_count != 0) begin
                strv_count--;
              end
              if (give_credits && (strv_count == 0)) begin
                m_crd.get_credit(m_clk_trigger);
                drive_lcredit(1'b1);
              end else begin
                drive_lcredit(1'b0);
              end
            end
            default: `ASSERT(0, "Not yet implemented");
          endcase
          wait4clk_event();
        end else begin
          drive_lcredit(1'b0);
          wait4clk_event();
        end
      end
    end

    //Trigger clock event
    begin
      forever begin
        wait4clk_event();
        m_clk_trigger.trigger();
      end
    end
  join_none

endtask: run_phase


function void chi_pasv_chnl_driver::conv_flit2txn(ref REQ seq_item);
  packed_flit_t flit;

  flit.push_back(m_chi_flit[0].data);
  seq_item.unpack_flit(flit);
  void'(m_chi_flit.pop_front());
endfunction: conv_flit2txn

task chi_pasv_chnl_driver::read_flit();
  logic              vld;
  logic [MAX_FW-1:0] data;
  chi_flit_t         tmp_flit;

  wait4clk_event();
  montr_flit(vld, data);
  `ASSERT(!($isunknown(vld)),
     $psprintf("%s vld must not be x or z", get_name()));
  if (vld) begin
    m_crd.put_credit();
    tmp_flit.dlyc = 0;
    tmp_flit.data = data;          
    if (m_lnk.get_link_state() != INACTIVE) begin
      m_chi_flit.push_back(tmp_flit);
    end
  end
endtask: read_flit

////////////////////////////////////////////////////////////////////////////////
// 
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
endfunction: build_phase

function void chi_link_req_driver::connect_phase(uvm_phase phase);
  super.connect_phase(phase);
endfunction: connect_phase

task chi_link_req_driver::run_phase(uvm_phase phase);

  drive_txlink_actv(m_txsig_val);
  drive_rxlink_actv(m_rxsig_val);
  wait4clk_event();
  fork

    //Accept seq items to drive TX-req
    begin
      REQ t_txn;
      forever begin
        wait4clk_event();
        if (!is_under_reset()) begin
          seq_item_port.get_next_item(t_txn);
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
        drive_rxlink_actv(m_rxsig_val);
        wait4clk_event();
        m_rxlink.link_signal_value(montr_rxlink_actv(), m_rxsig_val);
      end
    end

    //Depending on RX-req drive RX-ACK
    begin
      forever begin
        if (m_rxlink.is_link_alive()) begin
          m_rxsig_val = 1;
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

  while (n > 0) begin
    wait4clk_event();
    n--;
  end 
  m_txsig_val = 1'b1;
  wait4txlink_ack();
endtask: pow_up_tx_ln

task chi_link_req_driver::wait_rx_ln_up(const ref REQ seq_item);
  int n = seq_item.n_cycles;

  wait4rxlink_req();
  while (n > 0) begin
    wait4clk_event();
    n--;
  end 
  m_txsig_val = 1'b1;
  wait4txlink_ack();
endtask: wait_rx_ln_up

task chi_link_req_driver::pow_dn_tx_ln(const ref REQ seq_item);
  int n = seq_item.n_cycles;

  while (n > 0) begin
    wait4clk_event();
    n--;
  end 
  m_txsig_val = 1'b0;
  wait4rxlink_ack_down();
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
// 
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
        m_sem.put(1);
      end
    end

    //de-assert txsactive if received seq_item for pow-Mgmt
    begin
      REQ t_txn;

      forever begin 
        wait4clk_event();
        seq_item_port.get_next_item(t_txn);
        m_sem.get(1);
        signal_val = t_txn.txsactv;
        m_sem.put(1);
        seq_item_port.item_done(t_txn);
      end
    end
  join_none
endtask: run_phase

////////////////////////////////////////////////////////////////////////////////
// 
////////////////////////////////////////////////////////////////////////////////

class chi_sysco_driver #(type REQ = chi_base_seq_item)
  extends chi_chnl_base_driver #(REQ);

  `uvm_component_param_utils_begin(chi_sysco_driver#(REQ))
  `uvm_component_utils_end

  chi_sysco_t signal_val_next;
  chi_sysco_t signal_val_prev;

  extern function new(
    string name = "chi_sysco_driver",
    uvm_component parent = null);
  extern function void build_phase(uvm_phase   phase);
  extern function void connect_phase(uvm_phase phase);
  extern task          run_phase(uvm_phase phase);
  //get req or ack based on the node type
  extern virtual function chi_sysco_t get_sysco_dat(REQ m_item);

endclass: chi_sysco_driver

function chi_sysco_driver::new(
  string name = "chi_sysco_driver",
  uvm_component parent = null);

  super.new(name, parent);
  signal_val_next = 1'b0;
  signal_val_prev = 1'b0;
endfunction: new

function void chi_sysco_driver::build_phase(uvm_phase   phase);
  super.build_phase(phase);
endfunction: build_phase

function void chi_sysco_driver::connect_phase(uvm_phase phase);
  super.connect_phase(phase);
endfunction: connect_phase

task chi_sysco_driver::run_phase(uvm_phase phase);
  semaphore m_sem;

  m_sem = new(1);
  signal_val_next = m_cfg.default_sysco;
  drive_sysco(signal_val_prev);
  wait4clk_event();
  fork
    //drive new sysco_req signal if sysco_req & sysco_ack both are stable
    begin
      forever begin
        if(!is_under_reset()) begin
          m_sem.get(1);
          if (montr_sysco() == signal_val_prev) begin
            drive_sysco(signal_val_next);
            signal_val_prev = signal_val_next;
          end else begin
            drive_sysco(signal_val_prev);
          end
          wait4clk_event();
          m_sem.put(1);
        end else begin
          signal_val_next = m_cfg.default_sysco;
          signal_val_prev = 1'b0;
          drive_sysco(signal_val_prev);
          wait4clk_event();
          wait4reset();
        end
      end
    end

    //de-assert sysco_req if received seq_item for non-coherent access
    begin
      REQ t_txn;

      forever begin
        if(!is_under_reset()) begin
          wait4clk_event();
          seq_item_port.get_next_item(t_txn);
          m_sem.get(1);
          signal_val_next = get_sysco_dat(t_txn);
          m_sem.put(1);
          seq_item_port.item_done(t_txn);
        end else begin
          wait4clk_event();
          wait4reset();
        end
      end
    end
  join_none
endtask: run_phase

function chi_sysco_t chi_sysco_driver::get_sysco_dat(REQ m_item);
  if (m_cfg.snp_chnl_exists()) begin
    return m_item.sysco_req;
  end else if (m_cfg.is_slave_node()) begin
    return m_item.sysco_ack;
  end else if (m_cfg.is_requestor_node()) begin
    return m_item.sysco_req;
  end else begin
    `uvm_fatal(get_name(), "Unexpected chi node type")
  end
endfunction: get_sysco_dat
