////////////////////////////////////////////////////////////////////////////////
// 
// Author       : Muffadal 
// Purpose      : CHI agent config
// Revision     :
//
//according to chi-spec max transaction-is = 256
////////////////////////////////////////////////////////////////////////////////

class chi_agent_cfg extends uvm_object;

  chi_node_t          chi_node_type;
  chi_uvm_agent_cfg_t agent_cfg;
  flit_pend_mode_t    m_flitpend_st;
  rxcrd_drv_mode_t    m_rxcrd_mode;

  ////////////////////////////////////////////////////////////////////////////
  //Virtual interface handles
  //typedefs defined in chi_agent_pkg
  //Requestor node virtual interface modports
  chi_rn_driver_vif    m_rn_drv_vif;
  chi_rn_monitor_vif   m_rn_mon_vif;
  chi_rni_driver_vif   m_rni_drv_vif;
  chi_rni_monitor_vif  m_rni_mon_vif;
  //Slave node virtual interface modports
  chi_sn_driver_vif    m_sn_drv_vif;
  chi_sn_monitor_vif   m_sn_mon_vif;
<% if(obj.testBench=="emu") { %>
  virtual <%=obj.BlockId%>_chi_emu_if m_chi_emu_vif; <% } %>
  ////////////////////////////////////////////////////////////////////////////

  ////////////////////////////////////////////////////////////////////////////
  //Properties to configure the the interface requirements
  const int            m_weights_for_k_rxack_rsp4rxreq[1] = {100};
<% if(obj.testBench == 'chi_aiu' || obj.testBench == 'fsys') { %>
`ifndef VCS
  const t_minmax_range m_minmax_for_k_rxack_rsp4rxreq[1]  = {{0,10}};
`else // `ifndef VCS
  const t_minmax_range m_minmax_for_k_rxack_rsp4rxreq[1]  = '{'{m_min_range:0,m_max_range:10}};
`endif // `ifndef VCS ... `else ... 
<% } else {%>
  const t_minmax_range m_minmax_for_k_rxack_rsp4rxreq[1]  = {{0,10}};
<% } %>
  const int            m_weights_for_k_max_pend_flits[1]  = {100};
<% if(obj.testBench == 'chi_aiu' || obj.testBench == 'fsys') { %>
`ifndef VCS
  const t_minmax_range m_minmax_for_k_max_pend_flits[1]   = {{4,16}};
`else // `ifndef VCS
  const t_minmax_range m_minmax_for_k_max_pend_flits[1]   = '{'{m_min_range:4,m_max_range:16}};
`endif // `ifndef VCS ... `else ... 
<% } else {%>
  const t_minmax_range m_minmax_for_k_max_pend_flits[1]   = {{4,16}};
<% } %>
  int k_chnl_powdn;
  int k_wt4tx_ack_tmo;
  int k_wt4rx_req_tmo;
  common_knob_class k_max_pend_flits = new("k_max_pend_flits", this, m_weights_for_k_max_pend_flits, m_minmax_for_k_max_pend_flits);
  common_knob_class k_rxack_rsp4rxreq = new("k_rxack_rsp4rxreq", this, m_weights_for_k_rxack_rsp4rxreq, m_minmax_for_k_rxack_rsp4rxreq);

  bit delay_export;
  bit default_sysco;

  `uvm_object_param_utils_begin(chi_agent_cfg)
      `uvm_field_enum(chi_node_t, chi_node_type, UVM_DEFAULT)
  `uvm_object_utils_end

  //Helper methods
  extern function new(string name = "chi_agent_cfg");
  extern function bit is_requestor_node();
  extern function bit is_slave_node();
  extern function bit snp_chnl_exists();
  extern function int get_num_links();
  extern function flit_pend_mode_t get_flitpend_st();
  extern function rxcrd_drv_mode_t get_rxcrd_mode();

  //interface to wait for reset
  extern task wait4reset(string cmp);
  extern function bit is_under_reset(string cmp);
  extern task wait4clk_event(string cmp);
  
endclass: chi_agent_cfg

function chi_agent_cfg::new(string name = "chi_agent_cfg");
  super.new(name);

  m_flitpend_st = FLTPENDV_HIGH;
  k_chnl_powdn      = 1000;
  k_wt4tx_ack_tmo   = 1000;
  k_wt4rx_req_tmo   = 1000;
endfunction: new

//Requestor node
function bit chi_agent_cfg::is_requestor_node();
    return(((chi_node_type == RN_F) || (chi_node_type == RN_I) || (chi_node_type == RN_D)) ?
        1'b1 : 1'b0);
endfunction: is_requestor_node

//Slave Node
function bit chi_agent_cfg::is_slave_node();
    return(((chi_node_type == SN_F) || (chi_node_type == SN_I)) ?
        1'b1 : 1'b0);
endfunction: is_slave_node

//Number of links for given agent
function int chi_agent_cfg::get_num_links();
  //TX-REQ + TX-RSP + TX-DAT + RX-RSP + RX-DAT + RX-SNP
  if (chi_node_type == RN_F || chi_node_type == RN_D)
      return 6; 
  else if (chi_node_type == RN_I) 
    return 5;
  else if (is_slave_node())
    return 4;

  `ASSERT(0, $psprintf("Unexpected knob passed: %s", chi_node_type.name()));
  return 0;
endfunction: get_num_links

function bit chi_agent_cfg::snp_chnl_exists();
  return (chi_node_type == RN_F || chi_node_type == RN_D ? 1'b1 : 1'b0);
endfunction: snp_chnl_exists

//Wait until reset is posedge of reset triggers.
//Method must be called only if it is known that reset 
//not yet asserted. Or else, blocks forever
task chi_agent_cfg::wait4reset(string cmp);
  
  if (cmp == "driver") begin

    if (chi_node_type == RN_F || chi_node_type == RN_D)
      @(posedge m_rn_drv_vif.reset_n);
    else if (chi_node_type == RN_I)
      @(posedge m_rni_drv_vif.reset_n);
    else if (chi_node_type == SN_F || chi_node_type == SN_I)
      @(posedge m_sn_drv_vif.reset_n);

  end else begin

    if (chi_node_type == RN_F || chi_node_type == RN_D)
      @(posedge m_rn_mon_vif.reset_n);
    else if (chi_node_type == RN_I)
      @(posedge m_rni_mon_vif.reset_n);
    else if (chi_node_type == SN_F || chi_node_type == SN_I)
      @(posedge m_sn_mon_vif.reset_n);

  end
endtask: wait4reset

function bit chi_agent_cfg::is_under_reset(string cmp);

  if (cmp == "driver") begin

    if (chi_node_type == RN_F || chi_node_type == RN_D) begin
      return m_rn_drv_vif.reset_n == 0 ? 1'b1 : 1'b0;
    end
    else if (chi_node_type == RN_I)
      return m_rni_drv_vif.reset_n == 0 ? 1'b1 : 1'b0;
    else if (chi_node_type == SN_F || chi_node_type == SN_I)
      return m_sn_drv_vif.reset_n == 0 ? 1'b1 : 1'b0;

  end else begin

    if (chi_node_type == RN_F || chi_node_type == RN_D)
      return m_rn_mon_vif.reset_n == 0 ? 1'b1 : 1'b0;
    else if (chi_node_type == RN_I)
      return m_rni_mon_vif.reset_n == 0 ? 1'b1 : 1'b0;
    else if (chi_node_type == SN_F || chi_node_type == SN_I)
      return m_sn_mon_vif.reset_n == 0 ? 1'b1 : 1'b0;

  end
  `ASSERT(0, "Entered unexpected execution");
  return 1'b0;
endfunction: is_under_reset

task chi_agent_cfg::wait4clk_event(string cmp);
  if (cmp == "driver") begin

    if (chi_node_type == RN_F || chi_node_type == RN_D)
      @(m_rn_drv_vif.rn_drv_cb);
    else if (chi_node_type == RN_D)
      @(m_rni_drv_vif.rni_drv_cb);
    else if (chi_node_type == SN_F || chi_node_type == SN_I)
      @(m_sn_drv_vif.sn_drv_cb);
<% if(obj.testBench=="emu"){ %>
  end else if (cmp == "chi_emu_drive_collect") begin

    if (chi_node_type == RN_F || chi_node_type == RN_D) begin
      @(m_rn_drv_vif.rn_drv_cb);
      //$display($time, " CHI_AGNT_CFG : RN_F_RN_D_node");
      `uvm_info(get_name,$psprintf("CHI_AGNT_CFG : EMU_RN_F_RN_D_node"),UVM_LOW);
    end else if (chi_node_type == RN_D) begin
      @(m_rni_drv_vif.rni_drv_cb);
      $display($time, " CHI_AGNT_CFG : EMU_RN_D_node");
    end else if (chi_node_type == SN_F || chi_node_type == SN_I)begin
      @(m_sn_drv_vif.sn_drv_cb);
    end
<% } %>

  end else begin

    if (chi_node_type == RN_F || chi_node_type == RN_D)
      @(m_rn_mon_vif.rn_mon_cb);
    else if (chi_node_type == RN_D)
      @(m_rni_mon_vif.rni_mon_cb);
    else if (chi_node_type == SN_F || chi_node_type == SN_I)
      @(m_sn_mon_vif.sn_mon_cb);

  end
endtask: wait4clk_event

function flit_pend_mode_t chi_agent_cfg::get_flitpend_st();
  return m_flitpend_st;
endfunction: get_flitpend_st

function rxcrd_drv_mode_t chi_agent_cfg::get_rxcrd_mode();
  return m_rxcrd_mode;
endfunction: get_rxcrd_mode
