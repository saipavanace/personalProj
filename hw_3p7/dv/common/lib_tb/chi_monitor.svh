//////////////////////////////////////////////////////////////////////////////
// 
// Author       : 
// Purpose      : File has Monitor classes for all CHI channels
// Revision     :
//
//
//////////////////////////////////////////////////////////////////////////////

class chi_chnl_monitor#(type REQ = chi_base_seq_item) extends uvm_monitor;

  protected chi_channel_func_t m_chnl_func;
  protected chi_channel_t      m_chnl_type;
  local bit                    k_cfg_params_set;
  chi_agent_cfg                m_cfg;
  chi_credit_txn               m_crd;
  chi_link_state               m_lnk;

  `uvm_component_param_utils_begin(chi_chnl_monitor#(REQ))
      `uvm_field_enum(chi_channel_func_t, m_chnl_func, UVM_DEFAULT)
      `uvm_field_enum(chi_channel_t, m_chnl_type, UVM_DEFAULT)
  `uvm_component_utils_end

  //Analysis ports
  uvm_analysis_port #(REQ) chi_pkt_ap;
  uvm_analysis_port #(chi_credit_txn) chi_credit_ap;

  //Methods
  extern function new(
    string name = "chi_chnl_monitor",
    uvm_component parent = null);
  extern function void build_phase(uvm_phase phase);
  extern function void connect_phase(uvm_phase phase);
  extern task          run_phase(uvm_phase phase);
  extern function void assign_chnl_params(
    chi_channel_func_t chnl_func,
    chi_channel_t chnl_type);
  extern function void assign_link_params();

  //helper methods
  extern task wait4clk_event();
  extern function bit is_vld_asserted();
  extern function packed_flit_t get_data_flit();

  extern function bit is_rn_vld_asserted();
  extern function bit is_sn_vld_asserted();
  extern function bit is_rni_vld_asserted();
  extern function packed_flit_t get_rn_data_flit();
  extern function packed_flit_t get_sn_data_flit();
  extern function packed_flit_t get_rni_data_flit();

endclass: chi_chnl_monitor

//Constructor
function chi_chnl_monitor::new(
  string name="chi_chnl_monitor",
  uvm_component parent = null);

  super.new(name,parent);
  chi_pkt_ap    = new("chi_pkt_ap", this);
  chi_credit_ap = new("chi_credit_ap", this);
endfunction

function void chi_chnl_monitor::build_phase(uvm_phase phase);
  super.build_phase(phase);
endfunction: build_phase

function void chi_chnl_monitor::connect_phase(uvm_phase phase);
  super.connect_phase(phase);
  if (!k_cfg_params_set) begin
      `uvm_fatal(get_name(), "Unable to set config params to monitor")
  end
  if (m_cfg == null) begin
      `uvm_fatal(get_name(), "chi agent config object not assigned")
  end
endfunction: connect_phase

task chi_chnl_monitor::run_phase(uvm_phase phase);
  REQ m_txn;

  fork 
    begin
      forever begin
        wait4clk_event();
        if (is_vld_asserted()) begin
          packed_flit_t flit;
          m_txn = REQ::type_id::create("mon_txn");
          flit = get_data_flit();
          m_txn.unpack_flit(flit);
          if (m_chnl_func == CHI_ACTIVE && m_chnl_type == CHI_REQ)
            m_txn.lcrdv = m_cfg.m_rn_mon_vif.rn_mon_cb.tx_req_lcrdv;
          if (m_cfg.delay_export == 1
              && m_chnl_func == CHI_REACTIVE 
              && (m_chnl_type == CHI_DAT 
                || m_chnl_type == CHI_RSP)
              ) begin
            #0;
          end 
          <%if(obj.testBench == 'chi_aiu') {%>
          if (m_chnl_type == CHI_SNP) #300ps;
          <% } %>
          chi_pkt_ap.write(m_txn);
        end
      end
    end
  join_none
endtask: run_phase

function void chi_chnl_monitor::assign_chnl_params(
  chi_channel_func_t chnl_func,
  chi_channel_t chnl_type);

  m_chnl_func = chnl_func;
  m_chnl_type = chnl_type;
  k_cfg_params_set = 1'b1;
endfunction: assign_chnl_params

function void chi_chnl_monitor::assign_link_params();
  k_cfg_params_set = 1'b1;
endfunction: assign_link_params

task chi_chnl_monitor::wait4clk_event();
  m_cfg.wait4clk_event("monitor");
endtask: wait4clk_event

function bit chi_chnl_monitor::is_vld_asserted();

  if (m_cfg.snp_chnl_exists())
    return is_rn_vld_asserted();
  else if (m_cfg.is_slave_node())
    return is_sn_vld_asserted();
  else if (m_cfg.is_requestor_node())
    return is_rni_vld_asserted();

  //unepected line executed
  `ASSERT(0);
  return 0;
endfunction: is_vld_asserted

function bit chi_chnl_monitor::is_rn_vld_asserted();
  if (m_chnl_func == CHI_ACTIVE) begin
    if (m_chnl_type == CHI_REQ)
      return m_cfg.m_rn_mon_vif.rn_mon_cb.tx_req_flitv ? 1 : 0;

    else if (m_chnl_type == CHI_RSP) 
      return m_cfg.m_rn_mon_vif.rn_mon_cb.tx_rsp_flitv ? 1 : 0;
    
    else if (m_chnl_type == CHI_DAT)
      return m_cfg.m_rn_mon_vif.rn_mon_cb.tx_dat_flitv ? 1 : 0;

    else 
      `uvm_fatal(get_name(), "Unexpected channel type")
  end else begin
    if (m_chnl_type == CHI_RSP) 
      return m_cfg.m_rn_mon_vif.rn_mon_cb.rx_rsp_flitv ? 1 : 0;

    else if (m_chnl_type == CHI_DAT)
      return m_cfg.m_rn_mon_vif.rn_mon_cb.rx_dat_flitv ? 1 : 0;

    else if (m_chnl_type == CHI_SNP)
      return m_cfg.m_rn_mon_vif.rn_mon_cb.rx_snp_flitv ? 1 : 0;

    else
       `uvm_fatal(get_name(), "Unexpected channel type")
  end
endfunction: is_rn_vld_asserted

function bit chi_chnl_monitor::is_sn_vld_asserted();

endfunction: is_sn_vld_asserted

function bit chi_chnl_monitor::is_rni_vld_asserted();

endfunction: is_rni_vld_asserted

function packed_flit_t chi_chnl_monitor::get_data_flit();
  packed_flit_t data;

  if (m_cfg.snp_chnl_exists())
    return get_rn_data_flit();
  else if (m_cfg.is_slave_node())
    return get_sn_data_flit();
  else if (m_cfg.is_requestor_node())
    return get_rni_data_flit();
  
  //unepected line executed
  `ASSERT(0);
  return data;
endfunction: get_data_flit

function packed_flit_t chi_chnl_monitor::get_rn_data_flit();
  packed_flit_t data;

  if (m_chnl_func == CHI_ACTIVE) begin
    if (m_chnl_type == CHI_REQ)
      data.push_back(m_cfg.m_rn_mon_vif.rn_mon_cb.tx_req_flit);

    else if (m_chnl_type == CHI_RSP) 
      data.push_back(m_cfg.m_rn_mon_vif.rn_mon_cb.tx_rsp_flit);
    
    else if (m_chnl_type == CHI_DAT)
      data.push_back(m_cfg.m_rn_mon_vif.rn_mon_cb.tx_dat_flit);

    else 
      `uvm_fatal(get_name(), "Unexpected channel type")
  end else begin
    if (m_chnl_type == CHI_RSP) 
      data.push_back(m_cfg.m_rn_mon_vif.rn_mon_cb.rx_rsp_flit);

    else if (m_chnl_type == CHI_DAT)
      data.push_back(m_cfg.m_rn_mon_vif.rn_mon_cb.rx_dat_flit);

    else if (m_chnl_type == CHI_SNP)
      data.push_back(m_cfg.m_rn_mon_vif.rn_mon_cb.rx_snp_flit);

    else
       `uvm_fatal(get_name(), "Unexpected channel type")
  end
  return data;
endfunction: get_rn_data_flit

function packed_flit_t chi_chnl_monitor::get_sn_data_flit();

endfunction: get_sn_data_flit

function packed_flit_t chi_chnl_monitor::get_rni_data_flit();

endfunction: get_rni_data_flit

/**
  *Below is a base class to smaple the sysco_req, sysco_ack from the
  *respective interface. It must require to set the configuration for
  *monitor to work. Given a instance creation of any CHI_AGENT, either
  *it will be requestor or slave. So Single Sysco will workout.
  *FIX_ME: PASSIVE agent needs to see if works or not.
  */
class chi_sysco_monitor#(type REQ = chi_base_seq_item) extends uvm_monitor;

  `uvm_component_param_utils(chi_sysco_monitor#(REQ))
  chi_agent_cfg                m_cfg;

  //Analysis ports
  uvm_analysis_port #(REQ) chi_sysco_ap;

  //Methods/Constructor
  function new(
    string name="chi_chnl_monitor",
    uvm_component parent = null);

    super.new(name,parent);
    chi_sysco_ap = new("chi_sysco_ap", this);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
  endfunction: build_phase

  function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    if (m_cfg == null) begin
        `uvm_fatal(get_name(), "chi agent config object not assigned")
    end
  endfunction: connect_phase

  //helper methods
  extern virtual task waitNget_SyscoDat(ref REQ item);

  task run_phase(uvm_phase phase);
    REQ m_txn;

    fork
      begin
        forever begin
          if(m_cfg.is_under_reset("monitor")) begin
            m_cfg.wait4clk_event("monitor");
            m_cfg.wait4reset("monitor");
          end
          else begin
            m_txn = REQ::type_id::create("mon_txn");
            waitNget_SyscoDat(m_txn);
            chi_sysco_ap.write(m_txn);
          end
        end
      end
    join_none
  endtask: run_phase
endclass: chi_sysco_monitor

task chi_sysco_monitor::waitNget_SyscoDat(ref REQ item);
  chi_sysco_t sysco_req, sysco_ack;

  if (m_cfg.chi_node_type == RN_F || m_cfg.chi_node_type == RN_D) begin
    @(m_cfg.m_rn_mon_vif.rn_mon_cb.sysco_req or m_cfg.m_rn_mon_vif.rn_mon_cb.sysco_ack);
    sysco_req = m_cfg.m_rn_mon_vif.rn_mon_cb.sysco_req;
    sysco_ack = m_cfg.m_rn_mon_vif.rn_mon_cb.sysco_ack;
  end
  else if (m_cfg.chi_node_type == RN_I) begin
    @(m_cfg.m_rni_mon_vif.rni_mon_cb.sysco_req or m_cfg.m_rni_mon_vif.rni_mon_cb.sysco_ack);
    sysco_req = m_cfg.m_rni_mon_vif.rni_mon_cb.sysco_req;
    sysco_ack = m_cfg.m_rni_mon_vif.rni_mon_cb.sysco_ack;
  end
  else if (m_cfg.chi_node_type == SN_F || m_cfg.chi_node_type == SN_I) begin
    @(m_cfg.m_sn_mon_vif.sn_mon_cb.sysco_req or m_cfg.m_sn_mon_vif.sn_mon_cb.sysco_ack);
    sysco_req = m_cfg.m_sn_mon_vif.sn_mon_cb.sysco_req;
    sysco_ack = m_cfg.m_sn_mon_vif.sn_mon_cb.sysco_ack;
  end
  else begin
    `uvm_fatal(get_name(), "Unexpected channel function")
  end

  item.sysco_req = sysco_req;
  item.sysco_ack = sysco_ack;
endtask: waitNget_SyscoDat
