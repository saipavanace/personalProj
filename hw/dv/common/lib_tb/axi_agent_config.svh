
////////////////////////////////////////////////////////////////////////////////
//
// AXI Agent Configuration
//
////////////////////////////////////////////////////////////////////////////////
import common_knob_pkg::*;

typedef enum {IS_AXI4_INTF, IS_ACE_LITE_INTF, IS_ACE_INTF} e_axi_interface_type;
class axi_agent_config extends uvm_object;

  `uvm_object_param_utils(axi_agent_config)

  virtual <%=obj.BlockId + '_axi_if'%>  m_vif;
<% if(obj.testBench=="emu") { %>
   virtual <%=obj.BlockId%>_ace_emu_if m_ace_vif ;
   virtual mgc_axi_master_if mgc_ace_vif ;

 <% } %>


  uvm_active_passive_enum active      = UVM_PASSIVE;
  e_axi_interface_type    m_intf_type = IS_ACE_INTF;
  bit delay_export                    = 0;

<%if(obj.isBridgeInterface){%>
  const int            m_weights_for_k_ace_master_read_data_chnl_delay_min[1]             = {100};
  const t_minmax_range m_minmax_for_k_ace_master_read_data_chnl_delay_min[1]              = '{'{m_min_range:10,m_max_range:20}};
  const int            m_weights_for_k_ace_master_read_data_chnl_delay_max[1]             = {100};
  const t_minmax_range m_minmax_for_k_ace_master_read_data_chnl_delay_max[1]              = '{'{m_min_range:20,m_max_range:50}};
  const int            m_weights_for_k_ace_master_read_data_chnl_burst_pct[1]             = {100};
  const t_minmax_range m_minmax_for_k_ace_master_read_data_chnl_burst_pct[1]              = '{'{m_min_range:2,m_max_range:20}};

  const int            m_weights_for_k_ace_master_read_addr_chnl_delay_min[1]             = {100};
  const t_minmax_range m_minmax_for_k_ace_master_read_addr_chnl_delay_min[1]              = '{'{m_min_range:10,m_max_range:20}};
  const int            m_weights_for_k_ace_master_read_addr_chnl_delay_max[1]             = {100};
  const t_minmax_range m_minmax_for_k_ace_master_read_addr_chnl_delay_max[1]              = '{'{m_min_range:20,m_max_range:50}};
  const int            m_weights_for_k_ace_master_read_addr_chnl_burst_pct[1]             = {100};
  const t_minmax_range m_minmax_for_k_ace_master_read_addr_chnl_burst_pct[1]              = '{'{m_min_range:2,m_max_range:20}};

  const int            m_weights_for_k_ace_master_write_data_chnl_delay_min[1]             = {100};
  const t_minmax_range m_minmax_for_k_ace_master_write_data_chnl_delay_min[1]              = '{'{m_min_range:10,m_max_range:20}};
  const int            m_weights_for_k_ace_master_write_data_chnl_delay_max[1]             = {100};
  const t_minmax_range m_minmax_for_k_ace_master_write_data_chnl_delay_max[1]              = '{'{m_min_range:20,m_max_range:50}};
  const int            m_weights_for_k_ace_master_write_data_chnl_burst_pct[1]             = {100};
  const t_minmax_range m_minmax_for_k_ace_master_write_data_chnl_burst_pct[1]              = '{'{m_min_range:2,m_max_range:20}};

  const int            m_weights_for_k_ace_master_write_addr_chnl_delay_min[1]             = {100};
  const t_minmax_range m_minmax_for_k_ace_master_write_addr_chnl_delay_min[1]              = '{'{m_min_range:10,m_max_range:20}};
  const int            m_weights_for_k_ace_master_write_addr_chnl_delay_max[1]             = {100};
  const t_minmax_range m_minmax_for_k_ace_master_write_addr_chnl_delay_max[1]              = '{'{m_min_range:20,m_max_range:50}};
  const int            m_weights_for_k_ace_master_write_addr_chnl_burst_pct[1]             = {100};
  const t_minmax_range m_minmax_for_k_ace_master_write_addr_chnl_burst_pct[1]              = '{'{m_min_range:2,m_max_range:20}};

  const int            m_weights_for_k_ace_master_write_resp_chnl_delay_min[1]             = {100};
  const t_minmax_range m_minmax_for_k_ace_master_write_resp_chnl_delay_min[1]              = '{'{m_min_range:10,m_max_range:20}};
  const int            m_weights_for_k_ace_master_write_resp_chnl_delay_max[1]             = {100};
  const t_minmax_range m_minmax_for_k_ace_master_write_resp_chnl_delay_max[1]              = '{'{m_min_range:20,m_max_range:50}};
  const int            m_weights_for_k_ace_master_write_resp_chnl_burst_pct[1]             = {100};
  const t_minmax_range m_minmax_for_k_ace_master_write_resp_chnl_burst_pct[1]              = '{'{m_min_range:2,m_max_range:20}};

  const int            m_weights_for_k_ace_master_snoop_addr_chnl_delay_min[1]             = {100};
  const t_minmax_range m_minmax_for_k_ace_master_snoop_addr_chnl_delay_min[1]              = '{'{m_min_range:10,m_max_range:20}};
  const int            m_weights_for_k_ace_master_snoop_addr_chnl_delay_max[1]             = {100};
  const t_minmax_range m_minmax_for_k_ace_master_snoop_addr_chnl_delay_max[1]              = '{'{m_min_range:20,m_max_range:50}};
  const int            m_weights_for_k_ace_master_snoop_addr_chnl_burst_pct[1]             = {100};
  const t_minmax_range m_minmax_for_k_ace_master_snoop_addr_chnl_burst_pct[1]              = '{'{m_min_range:2,m_max_range:20}};

  const int            m_weights_for_k_ace_master_snoop_data_chnl_delay_min[1]             = {100};
  const t_minmax_range m_minmax_for_k_ace_master_snoop_data_chnl_delay_min[1]              = '{'{m_min_range:10,m_max_range:20}};
  const int            m_weights_for_k_ace_master_snoop_data_chnl_delay_max[1]             = {100};
  const t_minmax_range m_minmax_for_k_ace_master_snoop_data_chnl_delay_max[1]              = '{'{m_min_range:20,m_max_range:50}};
  const int            m_weights_for_k_ace_master_snoop_data_chnl_burst_pct[1]             = {100};
  const t_minmax_range m_minmax_for_k_ace_master_snoop_data_chnl_burst_pct[1]              = '{'{m_min_range:2,m_max_range:20}};

  const int            m_weights_for_k_ace_master_snoop_resp_chnl_delay_min[1]             = {100};
  const t_minmax_range m_minmax_for_k_ace_master_snoop_resp_chnl_delay_min[1]              = '{'{m_min_range:10,m_max_range:20}};
  const int            m_weights_for_k_ace_master_snoop_resp_chnl_delay_max[1]             = {100};
  const t_minmax_range m_minmax_for_k_ace_master_snoop_resp_chnl_delay_max[1]              = '{'{m_min_range:20,m_max_range:50}};
  const int            m_weights_for_k_ace_master_snoop_resp_chnl_burst_pct[1]             = {100};
  const t_minmax_range m_minmax_for_k_ace_master_snoop_resp_chnl_burst_pct[1]              = '{'{m_min_range:2,m_max_range:20}};

  const int            m_weights_for_k_ace_slave_read_data_chnl_strict_dly[1]             = {100};
  const t_minmax_range m_minmax_for_k_ace_slave_read_data_chnl_strict_dly[1]              = '{'{m_min_range:0,m_max_range:0}};
  const int            m_weights_for_k_ace_slave_read_data_chnl_delay_min[1]             = {100};
  const t_minmax_range m_minmax_for_k_ace_slave_read_data_chnl_delay_min[1]              = '{'{m_min_range:10,m_max_range:20}};
  const int            m_weights_for_k_ace_slave_read_data_chnl_delay_max[1]             = {100};
  const t_minmax_range m_minmax_for_k_ace_slave_read_data_chnl_delay_max[1]              = '{'{m_min_range:20,m_max_range:50}};
  const int            m_weights_for_k_ace_slave_read_data_chnl_burst_pct[1]             = {100};
  const t_minmax_range m_minmax_for_k_ace_slave_read_data_chnl_burst_pct[1]              = '{'{m_min_range:2,m_max_range:20}};
  const int            m_weights_for_k_ace_master_snoop_resp_chnl_long_delay_min[1]             = {1000};
  const t_minmax_range m_minmax_for_k_ace_master_snoop_resp_chnl_long_delay_min[1]              = '{'{m_min_range:800,m_max_range:1000}};
  const int            m_weights_for_k_ace_master_snoop_resp_chnl_long_delay_max[1]             = {1500};
  const t_minmax_range m_minmax_for_k_ace_master_snoop_resp_chnl_long_delay_max[1]              = '{'{m_min_range:1000,m_max_range:1500}};
  const int            m_weights_for_k_ace_master_snoop_resp_chnl_long_delay_burst_pct[1]       = {0};
  const t_minmax_range m_minmax_for_k_ace_master_snoop_resp_chnl_long_delay_burst_pct[1]        = '{'{m_min_range:0,m_max_range:2}};

  const int            m_weights_for_k_ace_slave_read_data_chnl_long_delay_min[1]             = {1000};
  const t_minmax_range m_minmax_for_k_ace_slave_read_data_chnl_long_delay_min[1]              = '{'{m_min_range:800,m_max_range:1000}};
  const int            m_weights_for_k_ace_slave_read_data_chnl_long_delay_max[1]             = {1500};
  const t_minmax_range m_minmax_for_k_ace_slave_read_data_chnl_long_delay_max[1]              = '{'{m_min_range:1000,m_max_range:1500}};
  const int            m_weights_for_k_ace_slave_read_data_chnl_long_delay_burst_pct[1]       = {0};
  const t_minmax_range m_minmax_for_k_ace_slave_read_data_chnl_long_delay_burst_pct[1]        = '{'{m_min_range:0,m_max_range:2}};
  const int            m_weights_for_k_ace_slave_read_data_reorder_size[1]               = {100};
  const t_minmax_range m_minmax_for_k_ace_slave_read_data_reorder_size[1]              = '{'{m_min_range:2,m_max_range:20}};
  const int            m_weights_for_k_ace_slave_read_data_interleave_dis[1]               = {100};
  const t_minmax_range m_minmax_for_k_ace_slave_read_data_interleave_dis[1]              = '{'{m_min_range:0,m_max_range:1}};
  const int            m_weights_for_k_ace_slave_read_data_interbeatdly_dis[1]           = {100};
  const t_minmax_range m_minmax_for_k_ace_slave_read_data_interbeatdly_dis[1]            = '{'{m_min_range:0,m_max_range:0}};
  const int            m_weights_for_k_ace_slave_read_data_dly_after_rlast[1]             = {100};
  const t_minmax_range m_minmax_for_k_ace_slave_read_data_dly_after_rlast[1]              = '{'{m_min_range:0,m_max_range:0}};
  const int            m_weights_for_k_ace_slave_random_dly_dis[1]           = {100};
  const t_minmax_range m_minmax_for_k_ace_slave_random_dly_dis[1]            = '{'{m_min_range:0,m_max_range:0}};

  const int            m_weights_for_k_ace_slave_read_addr_chnl_delay_min[1]             = {100};
  const t_minmax_range m_minmax_for_k_ace_slave_read_addr_chnl_delay_min[1]              = '{'{m_min_range:10,m_max_range:20}};
  const int            m_weights_for_k_ace_slave_read_addr_chnl_delay_max[1]             = {100};
  const t_minmax_range m_minmax_for_k_ace_slave_read_addr_chnl_delay_max[1]              = '{'{m_min_range:20,m_max_range:50}};
  const int            m_weights_for_k_ace_slave_read_addr_chnl_burst_pct[1]             = {100};
  const t_minmax_range m_minmax_for_k_ace_slave_read_addr_chnl_burst_pct[1]              = '{'{m_min_range:2,m_max_range:20}};
  const int            m_weights_for_k_ace_slave_read_addr_chnl_long_delay_min[1]             = {1000};
  const t_minmax_range m_minmax_for_k_ace_slave_read_addr_chnl_long_delay_min[1]              = '{'{m_min_range:800,m_max_range:1000}};
  const int            m_weights_for_k_ace_slave_read_addr_chnl_long_delay_max[1]             = {1500};
  const t_minmax_range m_minmax_for_k_ace_slave_read_addr_chnl_long_delay_max[1]              = '{'{m_min_range:1000,m_max_range:1500}};
  const int            m_weights_for_k_ace_slave_read_addr_chnl_long_delay_burst_pct[1]       = {0};
  const t_minmax_range m_minmax_for_k_ace_slave_read_addr_chnl_long_delay_burst_pct[1]        = '{'{m_min_range:0,m_max_range:2}};

  const int            m_weights_for_k_ace_slave_write_addr_chnl_delay_min[1]             = {100};
  const t_minmax_range m_minmax_for_k_ace_slave_write_addr_chnl_delay_min[1]              = '{'{m_min_range:10,m_max_range:20}};
  const int            m_weights_for_k_ace_slave_write_addr_chnl_delay_max[1]             = {100};
  const t_minmax_range m_minmax_for_k_ace_slave_write_addr_chnl_delay_max[1]              = '{'{m_min_range:20,m_max_range:50}};
  const int            m_weights_for_k_ace_slave_write_addr_chnl_burst_pct[1]             = {100};
  const t_minmax_range m_minmax_for_k_ace_slave_write_addr_chnl_burst_pct[1]              = '{'{m_min_range:2,m_max_range:20}};
  const int            m_weights_for_k_ace_slave_write_addr_chnl_long_delay_burst_pct[1]  = {0};
  const t_minmax_range m_minmax_for_k_ace_slave_write_addr_chnl_long_delay_burst_pct[1]   = '{'{m_min_range:0,m_max_range:2}};
  const int            m_weights_for_k_ace_slave_write_addr_chnl_wait_for_vld[1]          = {100};
  const t_minmax_range m_minmax_for_k_ace_slave_write_addr_chnl_wait_for_vld[1]           = '{'{m_min_range:0,m_max_range:1}};

  const int            m_weights_for_k_ace_slave_write_data_chnl_delay_min[1]             = {100};
  const t_minmax_range m_minmax_for_k_ace_slave_write_data_chnl_delay_min[1]              = '{'{m_min_range:10,m_max_range:20}};
  const int            m_weights_for_k_ace_slave_write_data_chnl_delay_max[1]             = {100};
  const t_minmax_range m_minmax_for_k_ace_slave_write_data_chnl_delay_max[1]              = '{'{m_min_range:20,m_max_range:50}};
  const int            m_weights_for_k_ace_slave_write_data_chnl_burst_pct[1]             = {100};
  const t_minmax_range m_minmax_for_k_ace_slave_write_data_chnl_burst_pct[1]              = '{'{m_min_range:2,m_max_range:20}};
  const int            m_weights_for_k_ace_slave_write_data_chnl_long_delay_burst_pct[1]  = {0};
  const t_minmax_range m_minmax_for_k_ace_slave_write_data_chnl_long_delay_burst_pct[1]   = '{'{m_min_range:0,m_max_range:2}};
  const int            m_weights_for_k_ace_slave_write_data_chnl_wait_for_vld[1]          = {100};
  const t_minmax_range m_minmax_for_k_ace_slave_write_data_chnl_wait_for_vld[1]           = '{'{m_min_range:0,m_max_range:1}};

  const int            m_weights_for_k_ace_slave_write_resp_chnl_delay_min[1]             = {100};
  const t_minmax_range m_minmax_for_k_ace_slave_write_resp_chnl_delay_min[1]              = '{'{m_min_range:10,m_max_range:20}};
  const int            m_weights_for_k_ace_slave_write_resp_chnl_delay_max[1]             = {100};
  const t_minmax_range m_minmax_for_k_ace_slave_write_resp_chnl_delay_max[1]              = '{'{m_min_range:20,m_max_range:50}};
  const int            m_weights_for_k_ace_slave_write_resp_chnl_burst_pct[1]             = {100};
  const t_minmax_range m_minmax_for_k_ace_slave_write_resp_chnl_burst_pct[1]              = '{'{m_min_range:2,m_max_range:20}};
  const int            m_weights_for_k_ace_slave_write_resp_chnl_long_delay_burst_pct[1]  = {0};
  const t_minmax_range m_minmax_for_k_ace_slave_write_resp_chnl_long_delay_burst_pct[1]   = '{'{m_min_range:0,m_max_range:2}};

  const int            m_weights_for_k_ace_slave_snoop_addr_chnl_delay_min[1]             = {100};
  const t_minmax_range m_minmax_for_k_ace_slave_snoop_addr_chnl_delay_min[1]              = '{'{m_min_range:10,m_max_range:20}};
  const int            m_weights_for_k_ace_slave_snoop_addr_chnl_delay_max[1]             = {100};
  const t_minmax_range m_minmax_for_k_ace_slave_snoop_addr_chnl_delay_max[1]              = '{'{m_min_range:20,m_max_range:50}};
  const int            m_weights_for_k_ace_slave_snoop_addr_chnl_burst_pct[1]             = {100};
  const t_minmax_range m_minmax_for_k_ace_slave_snoop_addr_chnl_burst_pct[1]              = '{'{m_min_range:2,m_max_range:20}};

  const int            m_weights_for_k_ace_slave_snoop_data_chnl_delay_min[1]             = {100};
  const t_minmax_range m_minmax_for_k_ace_slave_snoop_data_chnl_delay_min[1]              = '{'{m_min_range:10,m_max_range:20}};
  const int            m_weights_for_k_ace_slave_snoop_data_chnl_delay_max[1]             = {100};
  const t_minmax_range m_minmax_for_k_ace_slave_snoop_data_chnl_delay_max[1]              = '{'{m_min_range:20,m_max_range:50}};
  const int            m_weights_for_k_ace_slave_snoop_data_chnl_burst_pct[1]             = {100};
  const t_minmax_range m_minmax_for_k_ace_slave_snoop_data_chnl_burst_pct[1]              = '{'{m_min_range:2,m_max_range:20}};

  const int            m_weights_for_k_ace_slave_snoop_resp_chnl_delay_min[1]             = {100};
  const t_minmax_range m_minmax_for_k_ace_slave_snoop_resp_chnl_delay_min[1]              = '{'{m_min_range:10,m_max_range:20}};
  const int            m_weights_for_k_ace_slave_snoop_resp_chnl_delay_max[1]             = {100};
  const t_minmax_range m_minmax_for_k_ace_slave_snoop_resp_chnl_delay_max[1]              = '{'{m_min_range:20,m_max_range:50}};
  const int            m_weights_for_k_ace_slave_snoop_resp_chnl_burst_pct[1]             = {100};
  const t_minmax_range m_minmax_for_k_ace_slave_snoop_resp_chnl_burst_pct[1]              = '{'{m_min_range:2,m_max_range:20}};

<%}else{%>

  const int            m_weights_for_k_ace_master_read_data_chnl_delay_min[1]             = {100};
  const t_minmax_range m_minmax_for_k_ace_master_read_data_chnl_delay_min[1]              = '{'{m_min_range:80,m_max_range:120}};
  const int            m_weights_for_k_ace_master_read_data_chnl_delay_max[1]             = {100};
  const t_minmax_range m_minmax_for_k_ace_master_read_data_chnl_delay_max[1]              = '{'{m_min_range:150,m_max_range:200}};
  const int            m_weights_for_k_ace_master_read_data_chnl_burst_pct[1]             = {100};
  const t_minmax_range m_minmax_for_k_ace_master_read_data_chnl_burst_pct[1]              = '{'{m_min_range:2,m_max_range:20}};

  const int            m_weights_for_k_ace_master_read_addr_chnl_delay_min[1]             = {100};
  const t_minmax_range m_minmax_for_k_ace_master_read_addr_chnl_delay_min[1]              = '{'{m_min_range:80,m_max_range:120}};
  const int            m_weights_for_k_ace_master_read_addr_chnl_delay_max[1]             = {100};
  const t_minmax_range m_minmax_for_k_ace_master_read_addr_chnl_delay_max[1]              = '{'{m_min_range:150,m_max_range:200}};
  const int            m_weights_for_k_ace_master_read_addr_chnl_burst_pct[1]             = {100};
  const t_minmax_range m_minmax_for_k_ace_master_read_addr_chnl_burst_pct[1]              = '{'{m_min_range:2,m_max_range:20}};

  const int            m_weights_for_k_ace_master_write_data_chnl_delay_min[1]             = {100};
  const t_minmax_range m_minmax_for_k_ace_master_write_data_chnl_delay_min[1]              = '{'{m_min_range:80,m_max_range:120}};
  const int            m_weights_for_k_ace_master_write_data_chnl_delay_max[1]             = {100};
  const t_minmax_range m_minmax_for_k_ace_master_write_data_chnl_delay_max[1]              = '{'{m_min_range:150,m_max_range:200}};
  const int            m_weights_for_k_ace_master_write_data_chnl_burst_pct[1]             = {100};
  const t_minmax_range m_minmax_for_k_ace_master_write_data_chnl_burst_pct[1]              = '{'{m_min_range:2,m_max_range:20}};

  const int            m_weights_for_k_ace_master_write_addr_chnl_delay_min[1]             = {100};
  const t_minmax_range m_minmax_for_k_ace_master_write_addr_chnl_delay_min[1]              = '{'{m_min_range:10,m_max_range:20}};
  const int            m_weights_for_k_ace_master_write_addr_chnl_delay_max[1]             = {100};
  const t_minmax_range m_minmax_for_k_ace_master_write_addr_chnl_delay_max[1]              = '{'{m_min_range:20,m_max_range:50}};
  const int            m_weights_for_k_ace_master_write_addr_chnl_burst_pct[1]             = {100};
  const t_minmax_range m_minmax_for_k_ace_master_write_addr_chnl_burst_pct[1]              = '{'{m_min_range:2,m_max_range:20}};

  const int            m_weights_for_k_ace_master_write_resp_chnl_delay_min[1]             = {100};
  const t_minmax_range m_minmax_for_k_ace_master_write_resp_chnl_delay_min[1]              = '{'{m_min_range:80,m_max_range:120}};
  const int            m_weights_for_k_ace_master_write_resp_chnl_delay_max[1]             = {100};
  const t_minmax_range m_minmax_for_k_ace_master_write_resp_chnl_delay_max[1]              = '{'{m_min_range:150,m_max_range:200}};
  const int            m_weights_for_k_ace_master_write_resp_chnl_burst_pct[1]             = {100};
  const t_minmax_range m_minmax_for_k_ace_master_write_resp_chnl_burst_pct[1]              = '{'{m_min_range:2,m_max_range:20}};

  const int            m_weights_for_k_ace_master_snoop_addr_chnl_delay_min[1]             = {100};
  const t_minmax_range m_minmax_for_k_ace_master_snoop_addr_chnl_delay_min[1]              = '{'{m_min_range:80,m_max_range:120}};
  const int            m_weights_for_k_ace_master_snoop_addr_chnl_delay_max[1]             = {100};
  const t_minmax_range m_minmax_for_k_ace_master_snoop_addr_chnl_delay_max[1]              = '{'{m_min_range:150,m_max_range:200}};
  const int            m_weights_for_k_ace_master_snoop_addr_chnl_burst_pct[1]             = {100};
  const t_minmax_range m_minmax_for_k_ace_master_snoop_addr_chnl_burst_pct[1]              = '{'{m_min_range:2,m_max_range:20}};

  const int            m_weights_for_k_ace_master_snoop_data_chnl_delay_min[1]             = {100};
  const t_minmax_range m_minmax_for_k_ace_master_snoop_data_chnl_delay_min[1]              = '{'{m_min_range:80,m_max_range:120}};
  const int            m_weights_for_k_ace_master_snoop_data_chnl_delay_max[1]             = {100};
  const t_minmax_range m_minmax_for_k_ace_master_snoop_data_chnl_delay_max[1]              = '{'{m_min_range:150,m_max_range:200}};
  const int            m_weights_for_k_ace_master_snoop_data_chnl_burst_pct[1]             = {100};
  const t_minmax_range m_minmax_for_k_ace_master_snoop_data_chnl_burst_pct[1]              = '{'{m_min_range:2,m_max_range:20}};

  const int            m_weights_for_k_ace_master_snoop_resp_chnl_delay_min[1]             = {100};
  const t_minmax_range m_minmax_for_k_ace_master_snoop_resp_chnl_delay_min[1]              = '{'{m_min_range:80,m_max_range:120}};
  const int            m_weights_for_k_ace_master_snoop_resp_chnl_delay_max[1]             = {100};
  const t_minmax_range m_minmax_for_k_ace_master_snoop_resp_chnl_delay_max[1]              = '{'{m_min_range:150,m_max_range:200}};
  const int            m_weights_for_k_ace_master_snoop_resp_chnl_burst_pct[1]             = {100};
  const t_minmax_range m_minmax_for_k_ace_master_snoop_resp_chnl_burst_pct[1]              = '{'{m_min_range:2,m_max_range:20}};
  const int            m_weights_for_k_ace_master_snoop_resp_chnl_long_delay_min[1]             = {1000};
  const t_minmax_range m_minmax_for_k_ace_master_snoop_resp_chnl_long_delay_min[1]              = '{'{m_min_range:800,m_max_range:1000}};
  const int            m_weights_for_k_ace_master_snoop_resp_chnl_long_delay_max[1]             = {1500};
  const t_minmax_range m_minmax_for_k_ace_master_snoop_resp_chnl_long_delay_max[1]              = '{'{m_min_range:1000,m_max_range:1500}};
  const int            m_weights_for_k_ace_master_snoop_resp_chnl_long_delay_burst_pct[1]       = {0};
  const t_minmax_range m_minmax_for_k_ace_master_snoop_resp_chnl_long_delay_burst_pct[1]        = '{'{m_min_range:0,m_max_range:2}};

  const int            m_weights_for_k_ace_slave_read_data_chnl_strict_dly[1]             = {100};
  const t_minmax_range m_minmax_for_k_ace_slave_read_data_chnl_strict_dly[1]              = '{'{m_min_range:0,m_max_range:0}};
  const int            m_weights_for_k_ace_slave_read_data_chnl_delay_min[1]             = {100};
  const t_minmax_range m_minmax_for_k_ace_slave_read_data_chnl_delay_min[1]              = '{'{m_min_range:80,m_max_range:120}};
  const int            m_weights_for_k_ace_slave_read_data_chnl_delay_max[1]             = {100};
  const t_minmax_range m_minmax_for_k_ace_slave_read_data_chnl_delay_max[1]              = '{'{m_min_range:150,m_max_range:200}};
  const int            m_weights_for_k_ace_slave_read_data_chnl_burst_pct[1]             = {100};
  const t_minmax_range m_minmax_for_k_ace_slave_read_data_chnl_burst_pct[1]              = '{'{m_min_range:2,m_max_range:20}};
  const int            m_weights_for_k_ace_slave_read_data_chnl_long_delay_min[1]             = {1000};
  const t_minmax_range m_minmax_for_k_ace_slave_read_data_chnl_long_delay_min[1]              = '{'{m_min_range:800,m_max_range:1000}};
  const int            m_weights_for_k_ace_slave_read_data_chnl_long_delay_max[1]             = {1500};
  const t_minmax_range m_minmax_for_k_ace_slave_read_data_chnl_long_delay_max[1]              = '{'{m_min_range:1000,m_max_range:1500}};
  const int            m_weights_for_k_ace_slave_read_data_chnl_long_delay_burst_pct[1]       = {0};
  const t_minmax_range m_minmax_for_k_ace_slave_read_data_chnl_long_delay_burst_pct[1]        = '{'{m_min_range:0,m_max_range:2}};
  const int            m_weights_for_k_ace_slave_read_data_reorder_size[1]             = {100};
  const t_minmax_range m_minmax_for_k_ace_slave_read_data_reorder_size[1]              = '{'{m_min_range:2,m_max_range:20}};
  const int            m_weights_for_k_ace_slave_read_data_interleave_dis[1]             = {100};
  const t_minmax_range m_minmax_for_k_ace_slave_read_data_interleave_dis[1]              = '{'{m_min_range:0,m_max_range:1}};
  const int            m_weights_for_k_ace_slave_read_data_interbeatdly_dis[1]           = {100};
  const t_minmax_range m_minmax_for_k_ace_slave_read_data_interbeatdly_dis[1]            = '{'{m_min_range:0,m_max_range:0}};
  const int            m_weights_for_k_ace_slave_read_data_dly_after_rlast[1]             = {100};
  const t_minmax_range m_minmax_for_k_ace_slave_read_data_dly_after_rlast[1]              = '{'{m_min_range:0,m_max_range:0}};
  const int            m_weights_for_k_ace_slave_random_dly_dis[1]           = {100};
  const t_minmax_range m_minmax_for_k_ace_slave_random_dly_dis[1]            = '{'{m_min_range:0,m_max_range:0}};

  const int            m_weights_for_k_ace_slave_read_addr_chnl_delay_min[1]             = {100};
  const t_minmax_range m_minmax_for_k_ace_slave_read_addr_chnl_delay_min[1]              = '{'{m_min_range:80,m_max_range:120}};
  const int            m_weights_for_k_ace_slave_read_addr_chnl_delay_max[1]             = {100};
  const t_minmax_range m_minmax_for_k_ace_slave_read_addr_chnl_delay_max[1]              = '{'{m_min_range:150,m_max_range:200}};
  const int            m_weights_for_k_ace_slave_read_addr_chnl_burst_pct[1]             = {100};
  const t_minmax_range m_minmax_for_k_ace_slave_read_addr_chnl_burst_pct[1]              = '{'{m_min_range:2,m_max_range:20}};
  const int            m_weights_for_k_ace_slave_read_addr_chnl_long_delay_min[1]             = {1000};
  const t_minmax_range m_minmax_for_k_ace_slave_read_addr_chnl_long_delay_min[1]              = '{'{m_min_range:800,m_max_range:1000}};
  const int            m_weights_for_k_ace_slave_read_addr_chnl_long_delay_max[1]             = {1500};
  const t_minmax_range m_minmax_for_k_ace_slave_read_addr_chnl_long_delay_max[1]              = '{'{m_min_range:1000,m_max_range:1500}};
  const int            m_weights_for_k_ace_slave_read_addr_chnl_long_delay_burst_pct[1]       = {0};
  const t_minmax_range m_minmax_for_k_ace_slave_read_addr_chnl_long_delay_burst_pct[1]        = '{'{m_min_range:0,m_max_range:2}};

  const int            m_weights_for_k_ace_slave_write_addr_chnl_delay_min[1]             = {100};
  const t_minmax_range m_minmax_for_k_ace_slave_write_addr_chnl_delay_min[1]              = '{'{m_min_range:80,m_max_range:120}};
  const int            m_weights_for_k_ace_slave_write_addr_chnl_delay_max[1]             = {100};
  const t_minmax_range m_minmax_for_k_ace_slave_write_addr_chnl_delay_max[1]              = '{'{m_min_range:150,m_max_range:200}};
  const int            m_weights_for_k_ace_slave_write_addr_chnl_burst_pct[1]             = {100};
  const t_minmax_range m_minmax_for_k_ace_slave_write_addr_chnl_burst_pct[1]              = '{'{m_min_range:2,m_max_range:20}};
  const int            m_weights_for_k_ace_slave_write_addr_chnl_long_delay_burst_pct[1]  = {0};
  const t_minmax_range m_minmax_for_k_ace_slave_write_addr_chnl_long_delay_burst_pct[1]   = '{'{m_min_range:0,m_max_range:2}};
  const int            m_weights_for_k_ace_slave_write_addr_chnl_wait_for_vld[1]          = {100};
  const t_minmax_range m_minmax_for_k_ace_slave_write_addr_chnl_wait_for_vld[1]           = '{'{m_min_range:0,m_max_range:1}};

  const int            m_weights_for_k_ace_slave_write_data_chnl_delay_min[1]             = {100};
  const t_minmax_range m_minmax_for_k_ace_slave_write_data_chnl_delay_min[1]              = '{'{m_min_range:80,m_max_range:120}};
  const int            m_weights_for_k_ace_slave_write_data_chnl_delay_max[1]             = {100};
  const t_minmax_range m_minmax_for_k_ace_slave_write_data_chnl_delay_max[1]              = '{'{m_min_range:150,m_max_range:200}};
  const int            m_weights_for_k_ace_slave_write_data_chnl_burst_pct[1]             = {100};
  const t_minmax_range m_minmax_for_k_ace_slave_write_data_chnl_burst_pct[1]              = '{'{m_min_range:2,m_max_range:20}};
  const int            m_weights_for_k_ace_slave_write_data_chnl_long_delay_burst_pct[1]  = {0};
  const t_minmax_range m_minmax_for_k_ace_slave_write_data_chnl_long_delay_burst_pct[1]   = '{'{m_min_range:0,m_max_range:2}};
  const int            m_weights_for_k_ace_slave_write_data_chnl_wait_for_vld[1]          = {100};
  const t_minmax_range m_minmax_for_k_ace_slave_write_data_chnl_wait_for_vld[1]           = '{'{m_min_range:0,m_max_range:1}};

  const int            m_weights_for_k_ace_slave_write_resp_chnl_delay_min[1]             = {100};
  const t_minmax_range m_minmax_for_k_ace_slave_write_resp_chnl_delay_min[1]              = '{'{m_min_range:80,m_max_range:120}};
  const int            m_weights_for_k_ace_slave_write_resp_chnl_delay_max[1]             = {100};
  const t_minmax_range m_minmax_for_k_ace_slave_write_resp_chnl_delay_max[1]              = '{'{m_min_range:150,m_max_range:200}};
  const int            m_weights_for_k_ace_slave_write_resp_chnl_burst_pct[1]             = {100};
  const t_minmax_range m_minmax_for_k_ace_slave_write_resp_chnl_burst_pct[1]              = '{'{m_min_range:2,m_max_range:20}};
  const int            m_weights_for_k_ace_slave_write_resp_chnl_long_delay_burst_pct[1]  = {0};
  const t_minmax_range m_minmax_for_k_ace_slave_write_resp_chnl_long_delay_burst_pct[1]   = '{'{m_min_range:0,m_max_range:2}};

  const int            m_weights_for_k_ace_slave_snoop_addr_chnl_delay_min[1]             = {100};
  const t_minmax_range m_minmax_for_k_ace_slave_snoop_addr_chnl_delay_min[1]              = '{'{m_min_range:80,m_max_range:120}};
  const int            m_weights_for_k_ace_slave_snoop_addr_chnl_delay_max[1]             = {100};
  const t_minmax_range m_minmax_for_k_ace_slave_snoop_addr_chnl_delay_max[1]              = '{'{m_min_range:150,m_max_range:200}};
  const int            m_weights_for_k_ace_slave_snoop_addr_chnl_burst_pct[1]             = {100};
  const t_minmax_range m_minmax_for_k_ace_slave_snoop_addr_chnl_burst_pct[1]              = '{'{m_min_range:2,m_max_range:20}};

  const int            m_weights_for_k_ace_slave_snoop_data_chnl_delay_min[1]             = {100};
  const t_minmax_range m_minmax_for_k_ace_slave_snoop_data_chnl_delay_min[1]              = '{'{m_min_range:80,m_max_range:120}};
  const int            m_weights_for_k_ace_slave_snoop_data_chnl_delay_max[1]             = {100};
  const t_minmax_range m_minmax_for_k_ace_slave_snoop_data_chnl_delay_max[1]              = '{'{m_min_range:150,m_max_range:200}};
  const int            m_weights_for_k_ace_slave_snoop_data_chnl_burst_pct[1]             = {100};
  const t_minmax_range m_minmax_for_k_ace_slave_snoop_data_chnl_burst_pct[1]              = '{'{m_min_range:2,m_max_range:20}};

  const int            m_weights_for_k_ace_slave_snoop_resp_chnl_delay_min[1]             = {100};
  const t_minmax_range m_minmax_for_k_ace_slave_snoop_resp_chnl_delay_min[1]              = '{'{m_min_range:80,m_max_range:120}};
  const int            m_weights_for_k_ace_slave_snoop_resp_chnl_delay_max[1]             = {100};
  const t_minmax_range m_minmax_for_k_ace_slave_snoop_resp_chnl_delay_max[1]              = '{'{m_min_range:150,m_max_range:200}};
  const int            m_weights_for_k_ace_slave_snoop_resp_chnl_burst_pct[1]             = {100};
  const t_minmax_range m_minmax_for_k_ace_slave_snoop_resp_chnl_burst_pct[1]              = '{'{m_min_range:2,m_max_range:20}};

<%}%>

  common_knob_class k_ace_master_read_addr_chnl_delay_min  ;
  common_knob_class k_ace_master_read_addr_chnl_delay_max  ;
  common_knob_class k_ace_master_read_addr_chnl_burst_pct  ;
  
  common_knob_class k_ace_master_read_data_chnl_delay_min    ;
  common_knob_class k_ace_master_read_data_chnl_delay_max    ;
  common_knob_class k_ace_master_read_data_chnl_burst_pct    ;
  int k_ace_master_read_data_chnl_wait_for_vld ;
  
  common_knob_class k_ace_master_write_addr_chnl_delay_min ;
  common_knob_class k_ace_master_write_addr_chnl_delay_max ;
  common_knob_class k_ace_master_write_addr_chnl_burst_pct ;
  
  common_knob_class k_ace_master_write_data_chnl_delay_min    ;
  common_knob_class k_ace_master_write_data_chnl_delay_max    ;
  common_knob_class k_ace_master_write_data_chnl_burst_pct    ;
  
  common_knob_class k_ace_master_write_resp_chnl_delay_min    ;
  common_knob_class k_ace_master_write_resp_chnl_delay_max    ;
  common_knob_class k_ace_master_write_resp_chnl_burst_pct    ;
  int k_ace_master_write_resp_chnl_wait_for_vld ;
  
  common_knob_class k_ace_master_snoop_addr_chnl_delay_min    ;
  common_knob_class k_ace_master_snoop_addr_chnl_delay_max    ;
  common_knob_class k_ace_master_snoop_addr_chnl_burst_pct    ;
  int k_ace_master_snoop_addr_chnl_wait_for_vld ;
  
  common_knob_class k_ace_master_snoop_data_chnl_delay_min ;
  common_knob_class k_ace_master_snoop_data_chnl_delay_max ;
  common_knob_class k_ace_master_snoop_data_chnl_burst_pct ;
  
  common_knob_class k_ace_master_snoop_resp_chnl_delay_min ;
  common_knob_class k_ace_master_snoop_resp_chnl_delay_max ;
  common_knob_class k_ace_master_snoop_resp_chnl_burst_pct ;
  
  common_knob_class k_ace_slave_read_addr_chnl_delay_min    ;
  common_knob_class k_ace_slave_read_addr_chnl_delay_max    ;
  common_knob_class k_ace_slave_read_addr_chnl_burst_pct    ;
  int k_ace_slave_read_addr_chnl_wait_for_vld ;
  
  common_knob_class k_ace_slave_read_data_chnl_strict_dly  ;
  common_knob_class k_ace_slave_read_data_chnl_delay_min   ;
  common_knob_class k_ace_slave_read_data_chnl_delay_max   ;
  common_knob_class k_ace_slave_read_data_chnl_burst_pct   ;
  common_knob_class k_ace_slave_read_data_reorder_size     ;
  <% if((obj.Block === "dmi")&&(obj.useRttDataEntries)&&(obj.useMemRspIntrlv)) { %>
  common_knob_class k_ace_slave_read_data_interleave_dis   ;
  <% } else { %>
  common_knob_class k_ace_slave_read_data_interleave_dis   ;
  <% } %>
  
  common_knob_class k_ace_slave_read_data_dly_after_rlast    ;
  common_knob_class k_ace_slave_read_data_interbeatdly_dis   ;
  common_knob_class k_ace_slave_random_dly_dis;

  common_knob_class k_ace_slave_write_addr_chnl_delay_min    ;
  common_knob_class k_ace_slave_write_addr_chnl_delay_max    ;
  common_knob_class k_ace_slave_write_addr_chnl_burst_pct    ;
  common_knob_class k_ace_slave_write_addr_chnl_wait_for_vld ;
  
  common_knob_class k_ace_slave_write_data_chnl_delay_min    ;
  common_knob_class k_ace_slave_write_data_chnl_delay_max    ;
  common_knob_class k_ace_slave_write_data_chnl_burst_pct    ;
  common_knob_class k_ace_slave_write_data_chnl_wait_for_vld    ;
  
  common_knob_class k_ace_slave_write_resp_chnl_delay_min  ;
  common_knob_class k_ace_slave_write_resp_chnl_delay_max  ;
  common_knob_class k_ace_slave_write_resp_chnl_burst_pct  ;
  
  common_knob_class k_ace_slave_snoop_addr_chnl_delay_min  ;
  common_knob_class k_ace_slave_snoop_addr_chnl_delay_max  ;
  common_knob_class k_ace_slave_snoop_addr_chnl_burst_pct  ;
  
  common_knob_class k_ace_slave_snoop_data_chnl_delay_min  ;
  common_knob_class k_ace_slave_snoop_data_chnl_delay_max  ;
  common_knob_class k_ace_slave_snoop_data_chnl_burst_pct  ;
  
  common_knob_class k_ace_slave_snoop_resp_chnl_delay_min  ;
  common_knob_class k_ace_slave_snoop_resp_chnl_delay_max  ;
  common_knob_class k_ace_slave_snoop_resp_chnl_burst_pct  ;
  
  int k_is_bfm_delay_changing                ;
  int k_bfm_delay_changing_time              ;
  int k_slow_agent                           ;
  int k_slow_read_agent                      ;
  int k_slow_write_agent                     ;
  int k_slow_snoop_agent                     ;
  int prob_ace_snp_resp_error                ;
  int prob_ace_rd_resp_error                 ;
  int prob_ace_wr_resp_error                 ;
  int prob_ace_coh_win_error                 ;
  int k_num_read_req                         ;
  int k_num_write_req                        ;
  int k_num_eviction_req                        ;
  int k_num_exclusive_req                    ;
  int k_num_snp                              ;
  int num_sets                              ;

  int wt_ace_rd_data_err_pct                 = 0;
  int wt_ace_wr_resp_err_pct                 = 0;
  int wt_ace_rdnosnp                         = 5;
  int wt_ace_rdonce                          = 5;
<% if ((obj.fnNativeInterface == "ACE-LITE") || (obj.fnNativeInterface == "ACELITE-E")) { %>    
  int wt_ace_rdshrd                          = 0;
  int wt_ace_rdcln                           = 0;
  int wt_ace_rdnotshrddty                    = 0;
  int wt_ace_rdunq                           = 0;
  int wt_ace_clnunq                          = 0;
  int wt_ace_mkunq                           = 0;
  int wt_ace_dvm_msg                         = 0;
  int wt_ace_dvm_sync                        = 0;
<% }  
else { %>    
  int wt_ace_rdshrd                          = 5;
  int wt_ace_rdcln                           = 5;
  int wt_ace_rdnotshrddty                    = 5;
  int wt_ace_rdunq                           = 5;
  int wt_ace_clnunq                          = 0;
  int wt_ace_mkunq                           = 0;
  int wt_ace_dvm_msg                         = 0;
  int wt_ace_dvm_sync                        = 0;
<% } %>      
  int wt_ace_clnshrd                         = 0;
  int wt_ace_clninvl                         = 0;
  int wt_ace_mkinvl                          = 0;
  int wt_ace_rd_bar                          = 0;
  int wt_ace_wrnosnp                         = 5;
  int wt_ace_wrunq                           = 0;
  int wt_ace_wrlnunq                         = 5;
<% if ((obj.fnNativeInterface == "ACE-LITE") || (obj.fnNativeInterface == "ACELITE-E")) { %>    
  int wt_ace_wrcln                           = 0;
  int wt_ace_wrbk                            = 0;
  int wt_ace_wrevct                          = 0;
  int wt_ace_evct                            = 0;
<% }  
else { %>    
  int wt_ace_wrcln                           = 5;
  int wt_ace_wrbk                            = 5;
  int wt_ace_wrevct                          = 5;
  int wt_ace_evct                            = 5;
<% } %>      
<% if (obj.fnNativeInterface == "ACELITE-E" || obj.fnNativeInterface == "AXI5") { %>    
  int wt_ace_atm_str                         = 5;
  int wt_ace_atm_ld                          = 5;
  int wt_ace_atm_swap                        = 5;
  int wt_ace_atm_comp                        = 5;
  int wt_ace_ptl_stash                       = 5;
  int wt_ace_full_stash                      = 5;
  int wt_ace_shared_stash                    = 5;
  int wt_ace_unq_stash                       = 5;
  int wt_ace_stash_trans                     = 5;
						       
<% } else {%>
  int wt_ace_atm_str                         = 0;
  int wt_ace_atm_ld                          = 0;
  int wt_ace_atm_swap                        = 0;
  int wt_ace_atm_comp                        = 0;
  int wt_ace_ptl_stash                       = 0;
  int wt_ace_full_stash                      = 0;
  int wt_ace_shared_stash                    = 0;
  int wt_ace_unq_stash                       = 0;
  int wt_ace_stash_trans                     = 0;
<% } %>

  int wt_ace_wr_bar                          = 0;

  int wt_ace_rd_cln_invld  = 0;
  int wt_ace_rd_make_invld = 0;
  int wt_ace_clnshrd_pers  = 0;

  int wt_expected_end_state                  = 60; 
  int wt_legal_end_state_with_sf             = 25; 
  int wt_legal_end_state_without_sf          = 15; 
  int wt_expected_start_state                = 60; 
  int wt_legal_start_state                   = 40; 
  int wt_lose_cache_line_on_snps             = 30; 
  int wt_keep_drty_cache_line_on_snps        = 50; 
  int prob_respond_to_snoop_coll_with_wr     = 50; 
  int prob_was_unique_snp_resp               = 50; 
  int prob_was_unique_always0_snp_resp       = 25; 
  int prob_dataxfer_snp_resp_on_clean_hit    = 50; 
  int prob_ace_wr_ix_start_state             = 50; 
  int prob_ace_rd_ix_start_state             = 50; 
  int prob_cache_flush_mode_per_1k           = 100; 
  bit no_updates                             = 0; 
 
  extern function new(string name = "axi_agent_config");
  extern function void randomize_knobs();

endclass: axi_agent_config

//------------------------------------------------------------------------------
// Constructor
//------------------------------------------------------------------------------
function axi_agent_config::new(string name = "axi_agent_config");
  super.new(name);
  randomize_knobs();
endfunction : new

////////////////////////////////////////////////////////////////////////////////

function void axi_agent_config::randomize_knobs();

  k_ace_master_read_addr_chnl_delay_min     = new ("k_ace_master_read_addr_chnl_delay_min"   , this , m_weights_for_k_ace_master_read_addr_chnl_delay_min  , m_minmax_for_k_ace_master_read_addr_chnl_delay_min    );
  k_ace_master_read_addr_chnl_delay_max     = new ("k_ace_master_read_addr_chnl_delay_max"   , this , m_weights_for_k_ace_master_read_addr_chnl_delay_max  , m_minmax_for_k_ace_master_read_addr_chnl_delay_max    );
  k_ace_master_read_addr_chnl_burst_pct     = new ("k_ace_master_read_addr_chnl_burst_pct"   , this , m_weights_for_k_ace_master_read_addr_chnl_burst_pct  , m_minmax_for_k_ace_master_read_addr_chnl_burst_pct    );

  k_ace_master_read_data_chnl_delay_min     = new ("k_ace_master_read_data_chnl_delay_min"   , this , m_weights_for_k_ace_master_read_data_chnl_delay_min  , m_minmax_for_k_ace_master_read_data_chnl_delay_min    );
  k_ace_master_read_data_chnl_delay_max     = new ("k_ace_master_read_data_chnl_delay_max"   , this , m_weights_for_k_ace_master_read_data_chnl_delay_max  , m_minmax_for_k_ace_master_read_data_chnl_delay_max    );
  k_ace_master_read_data_chnl_burst_pct     = new ("k_ace_master_read_data_chnl_burst_pct"   , this , m_weights_for_k_ace_master_read_data_chnl_burst_pct  , m_minmax_for_k_ace_master_read_data_chnl_burst_pct    );

  k_ace_master_write_addr_chnl_delay_min  = new ("k_ace_master_write_addr_chnl_delay_min"    , this , m_weights_for_k_ace_master_write_addr_chnl_delay_min , m_minmax_for_k_ace_master_write_addr_chnl_delay_min );
  k_ace_master_write_addr_chnl_delay_max  = new ("k_ace_master_write_addr_chnl_delay_max"    , this , m_weights_for_k_ace_master_write_addr_chnl_delay_max , m_minmax_for_k_ace_master_write_addr_chnl_delay_max );
  k_ace_master_write_addr_chnl_burst_pct  = new ("k_ace_master_write_addr_chnl_burst_pct"    , this , m_weights_for_k_ace_master_write_addr_chnl_burst_pct , m_minmax_for_k_ace_master_write_addr_chnl_burst_pct );

  k_ace_master_write_data_chnl_delay_min     = new ("k_ace_master_write_data_chnl_delay_min" , this , m_weights_for_k_ace_master_write_data_chnl_delay_min , m_minmax_for_k_ace_master_write_data_chnl_delay_min    );
  k_ace_master_write_data_chnl_delay_max     = new ("k_ace_master_write_data_chnl_delay_max" , this , m_weights_for_k_ace_master_write_data_chnl_delay_max , m_minmax_for_k_ace_master_write_data_chnl_delay_max    );
  k_ace_master_write_data_chnl_burst_pct     = new ("k_ace_master_write_data_chnl_burst_pct" , this , m_weights_for_k_ace_master_write_data_chnl_burst_pct , m_minmax_for_k_ace_master_write_data_chnl_burst_pct    );

  k_ace_master_write_resp_chnl_delay_min     = new ("k_ace_master_write_resp_chnl_delay_min" , this , m_weights_for_k_ace_master_write_resp_chnl_delay_min , m_minmax_for_k_ace_master_write_resp_chnl_delay_min    );
  k_ace_master_write_resp_chnl_delay_max     = new ("k_ace_master_write_resp_chnl_delay_max" , this , m_weights_for_k_ace_master_write_resp_chnl_delay_max , m_minmax_for_k_ace_master_write_resp_chnl_delay_max    );
  k_ace_master_write_resp_chnl_burst_pct     = new ("k_ace_master_write_resp_chnl_burst_pct" , this , m_weights_for_k_ace_master_write_resp_chnl_burst_pct , m_minmax_for_k_ace_master_write_resp_chnl_burst_pct    );

  k_ace_master_snoop_addr_chnl_delay_min     = new ("k_ace_master_snoop_addr_chnl_delay_min" , this , m_weights_for_k_ace_master_snoop_addr_chnl_delay_min , m_minmax_for_k_ace_master_snoop_addr_chnl_delay_min    );
  k_ace_master_snoop_addr_chnl_delay_max     = new ("k_ace_master_snoop_addr_chnl_delay_max" , this , m_weights_for_k_ace_master_snoop_addr_chnl_delay_max , m_minmax_for_k_ace_master_snoop_addr_chnl_delay_max    );
  k_ace_master_snoop_addr_chnl_burst_pct     = new ("k_ace_master_snoop_addr_chnl_burst_pct" , this , m_weights_for_k_ace_master_snoop_addr_chnl_burst_pct , m_minmax_for_k_ace_master_snoop_addr_chnl_burst_pct    );

  k_ace_master_snoop_data_chnl_delay_min  = new ("k_ace_master_snoop_data_chnl_delay_min"    , this , m_weights_for_k_ace_master_snoop_data_chnl_delay_min , m_minmax_for_k_ace_master_snoop_data_chnl_delay_min );
  k_ace_master_snoop_data_chnl_delay_max  = new ("k_ace_master_snoop_data_chnl_delay_max"    , this , m_weights_for_k_ace_master_snoop_data_chnl_delay_max , m_minmax_for_k_ace_master_snoop_data_chnl_delay_max );
  k_ace_master_snoop_data_chnl_burst_pct  = new ("k_ace_master_snoop_data_chnl_burst_pct"    , this , m_weights_for_k_ace_master_snoop_data_chnl_burst_pct , m_minmax_for_k_ace_master_snoop_data_chnl_burst_pct );
  k_ace_slave_read_data_chnl_strict_dly    = new ("k_ace_slave_read_data_chnl_strict_dly"    , this , m_weights_for_k_ace_slave_read_data_chnl_strict_dly  , m_minmax_for_k_ace_slave_read_data_chnl_strict_dly   );

  if( $test$plusargs("ac_snoop_bkp")) begin
  k_ace_master_snoop_resp_chnl_delay_min  = new ("k_ace_master_snoop_resp_chnl_delay_min"    , this , m_weights_for_k_ace_master_snoop_resp_chnl_long_delay_min , m_minmax_for_k_ace_master_snoop_resp_chnl_long_delay_min );
  k_ace_master_snoop_resp_chnl_delay_max  = new ("k_ace_master_snoop_resp_chnl_delay_max"    , this , m_weights_for_k_ace_master_snoop_resp_chnl_long_delay_max , m_minmax_for_k_ace_master_snoop_resp_chnl_long_delay_max );
  k_ace_master_snoop_resp_chnl_burst_pct  = new ("k_ace_master_snoop_resp_chnl_burst_pct"    , this , m_weights_for_k_ace_master_snoop_resp_chnl_long_delay_burst_pct , m_minmax_for_k_ace_master_snoop_resp_chnl_long_delay_burst_pct );
  end else begin
  k_ace_master_snoop_resp_chnl_delay_min  = new ("k_ace_master_snoop_resp_chnl_delay_min"    , this , m_weights_for_k_ace_master_snoop_resp_chnl_delay_min , m_minmax_for_k_ace_master_snoop_resp_chnl_delay_min );
  k_ace_master_snoop_resp_chnl_delay_max  = new ("k_ace_master_snoop_resp_chnl_delay_max"    , this , m_weights_for_k_ace_master_snoop_resp_chnl_delay_max , m_minmax_for_k_ace_master_snoop_resp_chnl_delay_max );
  k_ace_master_snoop_resp_chnl_burst_pct  = new ("k_ace_master_snoop_resp_chnl_burst_pct"    , this , m_weights_for_k_ace_master_snoop_resp_chnl_burst_pct , m_minmax_for_k_ace_master_snoop_resp_chnl_burst_pct );
  end

  if( $test$plusargs("long_delay")) begin
  k_ace_slave_read_addr_chnl_delay_min     = new ("k_ace_slave_read_addr_chnl_delay_min"     , this , m_weights_for_k_ace_slave_read_addr_chnl_long_delay_min   , m_minmax_for_k_ace_slave_read_addr_chnl_long_delay_min    );
  k_ace_slave_read_addr_chnl_delay_max     = new ("k_ace_slave_read_addr_chnl_delay_max"     , this , m_weights_for_k_ace_slave_read_addr_chnl_long_delay_max   , m_minmax_for_k_ace_slave_read_addr_chnl_long_delay_max    );
  k_ace_slave_read_addr_chnl_burst_pct     = new ("k_ace_slave_read_addr_chnl_burst_pct"     , this , m_weights_for_k_ace_slave_read_addr_chnl_long_delay_burst_pct   , m_minmax_for_k_ace_slave_read_addr_chnl_long_delay_burst_pct    );
  k_ace_slave_read_data_chnl_delay_min    = new ("k_ace_slave_read_data_chnl_delay_min"      , this , m_weights_for_k_ace_slave_read_data_chnl_long_delay_min   , m_minmax_for_k_ace_slave_read_data_chnl_long_delay_min   );
  k_ace_slave_read_data_chnl_delay_max    = new ("k_ace_slave_read_data_chnl_delay_max"      , this , m_weights_for_k_ace_slave_read_data_chnl_long_delay_max   , m_minmax_for_k_ace_slave_read_data_chnl_long_delay_max   );
  k_ace_slave_read_data_chnl_burst_pct    = new ("k_ace_slave_read_data_chnl_burst_pct"      , this , m_weights_for_k_ace_slave_read_data_chnl_long_delay_burst_pct   , m_minmax_for_k_ace_slave_read_data_chnl_long_delay_burst_pct   );
  k_ace_slave_write_addr_chnl_burst_pct     = new ("k_ace_slave_write_addr_chnl_burst_pct"   , this , m_weights_for_k_ace_slave_write_addr_chnl_long_delay_burst_pct  , m_minmax_for_k_ace_slave_write_addr_chnl_long_delay_burst_pct    );
  k_ace_slave_write_data_chnl_burst_pct     = new ("k_ace_slave_write_data_chnl_burst_pct"   , this , m_weights_for_k_ace_slave_write_data_chnl_long_delay_burst_pct  , m_minmax_for_k_ace_slave_write_data_chnl_long_delay_burst_pct    );
  k_ace_slave_write_resp_chnl_burst_pct   = new ("k_ace_slave_write_resp_chnl_burst_pct"     , this , m_weights_for_k_ace_slave_write_resp_chnl_long_delay_burst_pct  , m_minmax_for_k_ace_slave_write_resp_chnl_long_delay_burst_pct  );
  end else begin
  k_ace_slave_read_addr_chnl_delay_min     = new ("k_ace_slave_read_addr_chnl_delay_min"     , this , m_weights_for_k_ace_slave_read_addr_chnl_delay_min   , m_minmax_for_k_ace_slave_read_addr_chnl_delay_min    );
  k_ace_slave_read_addr_chnl_delay_max     = new ("k_ace_slave_read_addr_chnl_delay_max"     , this , m_weights_for_k_ace_slave_read_addr_chnl_delay_max   , m_minmax_for_k_ace_slave_read_addr_chnl_delay_max    );
  k_ace_slave_read_addr_chnl_burst_pct     = new ("k_ace_slave_read_addr_chnl_burst_pct"     , this , m_weights_for_k_ace_slave_read_addr_chnl_burst_pct   , m_minmax_for_k_ace_slave_read_addr_chnl_burst_pct    );
  k_ace_slave_read_data_chnl_delay_min    = new ("k_ace_slave_read_data_chnl_delay_min"      , this , m_weights_for_k_ace_slave_read_data_chnl_delay_min   , m_minmax_for_k_ace_slave_read_data_chnl_delay_min   );
  k_ace_slave_read_data_chnl_delay_max    = new ("k_ace_slave_read_data_chnl_delay_max"      , this , m_weights_for_k_ace_slave_read_data_chnl_delay_max   , m_minmax_for_k_ace_slave_read_data_chnl_delay_max   );
  k_ace_slave_read_data_chnl_burst_pct    = new ("k_ace_slave_read_data_chnl_burst_pct"      , this , m_weights_for_k_ace_slave_read_data_chnl_burst_pct   , m_minmax_for_k_ace_slave_read_data_chnl_burst_pct   );
  k_ace_slave_write_addr_chnl_burst_pct     = new ("k_ace_slave_write_addr_chnl_burst_pct"   , this , m_weights_for_k_ace_slave_write_addr_chnl_burst_pct  , m_minmax_for_k_ace_slave_write_addr_chnl_burst_pct    );
  k_ace_slave_write_data_chnl_burst_pct     = new ("k_ace_slave_write_data_chnl_burst_pct"   , this , m_weights_for_k_ace_slave_write_data_chnl_burst_pct  , m_minmax_for_k_ace_slave_write_data_chnl_burst_pct    );
  k_ace_slave_write_resp_chnl_burst_pct   = new ("k_ace_slave_write_resp_chnl_burst_pct"     , this , m_weights_for_k_ace_slave_write_resp_chnl_burst_pct  , m_minmax_for_k_ace_slave_write_resp_chnl_burst_pct  );
  end
  k_ace_slave_read_data_reorder_size      = new ("k_ace_slave_read_data_reorder_size"        , this , m_weights_for_k_ace_slave_read_data_reorder_size     , m_minmax_for_k_ace_slave_read_data_reorder_size     );
  k_ace_slave_read_data_interleave_dis    = new ("k_ace_slave_read_data_interleave_dis"    , this , m_weights_for_k_ace_slave_read_data_interleave_dis   , m_minmax_for_k_ace_slave_read_data_interleave_dis     );
  k_ace_slave_read_data_dly_after_rlast   = new ("k_ace_slave_read_data_dly_after_rlast"   , this , m_weights_for_k_ace_slave_read_data_dly_after_rlast  , m_minmax_for_k_ace_slave_read_data_dly_after_rlast    );
  k_ace_slave_read_data_interbeatdly_dis  = new ("k_ace_slave_read_data_interbeatdly_dis"    , this , m_weights_for_k_ace_slave_read_data_interbeatdly_dis   , m_minmax_for_k_ace_slave_read_data_interbeatdly_dis     );
  k_ace_slave_random_dly_dis  = new ("k_ace_slave_random_dly_dis"    , this , m_weights_for_k_ace_slave_random_dly_dis   , m_minmax_for_k_ace_slave_random_dly_dis     );

  k_ace_slave_write_addr_chnl_delay_min     = new ("k_ace_slave_write_addr_chnl_delay_min"   , this , m_weights_for_k_ace_slave_write_addr_chnl_delay_min  , m_minmax_for_k_ace_slave_write_addr_chnl_delay_min    );
  k_ace_slave_write_addr_chnl_delay_max     = new ("k_ace_slave_write_addr_chnl_delay_max"   , this , m_weights_for_k_ace_slave_write_addr_chnl_delay_max  , m_minmax_for_k_ace_slave_write_addr_chnl_delay_max    );
  k_ace_slave_write_addr_chnl_wait_for_vld     = new ("k_ace_slave_write_addr_chnl_wait_for_vld"   , this , m_weights_for_k_ace_slave_write_addr_chnl_wait_for_vld  , m_minmax_for_k_ace_slave_write_addr_chnl_wait_for_vld    );

  k_ace_slave_write_data_chnl_delay_min     = new ("k_ace_slave_write_data_chnl_delay_min"   , this , m_weights_for_k_ace_slave_write_data_chnl_delay_min  , m_minmax_for_k_ace_slave_write_data_chnl_delay_min    );
  k_ace_slave_write_data_chnl_delay_max     = new ("k_ace_slave_write_data_chnl_delay_max"   , this , m_weights_for_k_ace_slave_write_data_chnl_delay_max  , m_minmax_for_k_ace_slave_write_data_chnl_delay_max    );
  k_ace_slave_write_data_chnl_wait_for_vld     = new ("k_ace_slave_write_data_chnl_wait_for_vld"   , this , m_weights_for_k_ace_slave_write_data_chnl_wait_for_vld  , m_minmax_for_k_ace_slave_write_data_chnl_wait_for_vld    );

  k_ace_slave_write_resp_chnl_delay_min   = new ("k_ace_slave_write_resp_chnl_delay_min"     , this , m_weights_for_k_ace_slave_write_resp_chnl_delay_min  , m_minmax_for_k_ace_slave_write_resp_chnl_delay_min  );
  k_ace_slave_write_resp_chnl_delay_max   = new ("k_ace_slave_write_resp_chnl_delay_max"     , this , m_weights_for_k_ace_slave_write_resp_chnl_delay_max  , m_minmax_for_k_ace_slave_write_resp_chnl_delay_max  );

  k_ace_slave_snoop_addr_chnl_delay_min   = new ("k_ace_slave_snoop_addr_chnl_delay_min"     , this , m_weights_for_k_ace_slave_snoop_addr_chnl_delay_min  , m_minmax_for_k_ace_slave_snoop_addr_chnl_delay_min  );
  k_ace_slave_snoop_addr_chnl_delay_max   = new ("k_ace_slave_snoop_addr_chnl_delay_max"     , this , m_weights_for_k_ace_slave_snoop_addr_chnl_delay_max  , m_minmax_for_k_ace_slave_snoop_addr_chnl_delay_max  );
  k_ace_slave_snoop_addr_chnl_burst_pct   = new ("k_ace_slave_snoop_addr_chnl_burst_pct"     , this , m_weights_for_k_ace_slave_snoop_addr_chnl_burst_pct  , m_minmax_for_k_ace_slave_snoop_addr_chnl_burst_pct  );

  k_ace_slave_snoop_data_chnl_delay_min   = new ("k_ace_slave_snoop_data_chnl_delay_min"     , this , m_weights_for_k_ace_slave_snoop_data_chnl_delay_min  , m_minmax_for_k_ace_slave_snoop_data_chnl_delay_min  );
  k_ace_slave_snoop_data_chnl_delay_max   = new ("k_ace_slave_snoop_data_chnl_delay_max"     , this , m_weights_for_k_ace_slave_snoop_data_chnl_delay_max  , m_minmax_for_k_ace_slave_snoop_data_chnl_delay_max  );
  k_ace_slave_snoop_data_chnl_burst_pct   = new ("k_ace_slave_snoop_data_chnl_burst_pct"     , this , m_weights_for_k_ace_slave_snoop_data_chnl_burst_pct  , m_minmax_for_k_ace_slave_snoop_data_chnl_burst_pct  );

  k_ace_slave_snoop_resp_chnl_delay_min   = new ("k_ace_slave_snoop_resp_chnl_delay_min"     , this , m_weights_for_k_ace_slave_snoop_resp_chnl_delay_min  , m_minmax_for_k_ace_slave_snoop_resp_chnl_delay_min  );
  k_ace_slave_snoop_resp_chnl_delay_max   = new ("k_ace_slave_snoop_resp_chnl_delay_max"     , this , m_weights_for_k_ace_slave_snoop_resp_chnl_delay_max  , m_minmax_for_k_ace_slave_snoop_resp_chnl_delay_max  );
  k_ace_slave_snoop_resp_chnl_burst_pct   = new ("k_ace_slave_snoop_resp_chnl_burst_pct"     , this , m_weights_for_k_ace_slave_snoop_resp_chnl_burst_pct  , m_minmax_for_k_ace_slave_snoop_resp_chnl_burst_pct  );
  
endfunction : randomize_knobs

////////////////////////////////////////////////////////////////////////////////
