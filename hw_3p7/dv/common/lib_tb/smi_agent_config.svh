////////////////////////////////////////////////////////////////////////////////
//
// SMI Agent Configuration
<% if (1 == 0) { %>
// Author: Chirag Gandhi
<% } %>
//
////////////////////////////////////////////////////////////////////////////////
class smi_port_config extends uvm_object;
    `uvm_object_param_utils(smi_port_config)

    virtual <%=obj.BlockId + '_smi_if'%>  m_vif = null;
<%  if(obj.BlockId.match('chiaiu')) { %>
    `ifdef CHI_SUBSYS
    virtual <%=obj.BlockId + '_smi_force_if'%>  m_force_vif = null;
    `endif
<% } %>

    const int            m_weights_for_k_burst_pct[2]             = {20,80};
    const t_minmax_range m_minmax_for_k_burst_pct[2]              = '{'{m_min_range:100,m_max_range:100}, '{m_min_range:5,m_max_range:99}};
    const int            m_weights_for_k_slow_port[2]             = {85,15};
    const t_minmax_range m_minmax_for_k_slow_port[2]              = '{'{m_min_range:0,m_max_range:0},'{m_min_range:1,m_max_range:1}};
    const t_minmax_range m_minmax_for_k_delay_min[1]              = '{'{m_min_range:1,m_max_range:5}};
    const t_minmax_range m_minmax_for_k_delay_min_slow[1]         = '{'{m_min_range:10,m_max_range:20}};
    const t_minmax_range m_minmax_for_k_delay_max[1]              = '{'{m_min_range:5,m_max_range:50}};
    const t_minmax_range m_minmax_for_k_delay_max_slow[1]         = '{'{m_min_range:20,m_max_range:50}};
    const int            m_weights_for_change_delays_over_time[2] = {5,95};
    const t_minmax_range m_minmax_for_change_delays_over_time[2]  = '{'{m_min_range:1,m_max_range:1}, '{m_min_range:0,m_max_range:0}};
    const t_minmax_range m_minmax_for_k_burst_pct_slow[1]         = '{'{m_min_range:2,m_max_range:20}};
    // Knobs
    common_knob_class k_delay_min;
    common_knob_class k_delay_max;
    common_knob_class k_burst_pct;
    common_knob_class k_slow_port;
    common_knob_class change_delays_over_time;

    bit delay_export            = 0; 

    //-----------------------------------------------------------------------
    //params to control SMI readys for perf counter(stall events)
    //-----------------------------------------------------------------------
    bit en_rx_stall  = 0;// enable SMI Rx stall TO DO:this shald be fixed to 0 as defailt value 
    int stall_period = 0;//number of clk cycles during which ready shall be maintained to low when valid is high

    function new(string name = "smi_port_config");
        super.new(name);
        randomize_knobs();
    endfunction : new

    function void randomize_knobs();
        k_slow_port = new ("k_slow_port", this, m_weights_for_k_slow_port, m_minmax_for_k_slow_port);
        if (k_slow_port.get_value())  begin
            k_delay_min = new ("k_delay_min" , this , m_weights_for_percentage , m_minmax_for_k_delay_min_slow);
            k_delay_max = new ("k_delay_max" , this , m_weights_for_percentage , m_minmax_for_k_delay_max_slow);
            k_burst_pct = new ("k_burst_pct" , this , m_weights_for_percentage , m_minmax_for_k_burst_pct_slow);
        end
        else begin
            k_delay_min = new ("k_delay_min" , this , m_weights_for_percentage  , m_minmax_for_k_delay_min);
            k_delay_max = new ("k_delay_max" , this , m_weights_for_percentage  , m_minmax_for_k_delay_max);
            k_burst_pct = new ("k_burst_pct" , this , m_weights_for_k_burst_pct , m_minmax_for_k_burst_pct);
        end
        change_delays_over_time = new ("change_delays_over_time", this , m_weights_for_change_delays_over_time, m_minmax_for_change_delays_over_time);  
    endfunction : randomize_knobs
endclass : smi_port_config

class smi_agent_config extends uvm_object;

  `uvm_object_param_utils(smi_agent_config)

  uvm_active_passive_enum active = UVM_PASSIVE;
    
  // Configuration bit to have monitor analysis fifo connect to per beat (used by BFM connected to this)
  // Default is full beat
  bit bfm_connect_to_per_beat_rx = 0;
  `ifdef FSYS_COVER_ON
  bit cov_en=0;
  `else 
  bit cov_en=1;
  `endif
  <% var NSMIIFTX = obj.nSmiRx;
  for (var i = 0; i < NSMIIFTX; i++) { %>
      smi_port_config m_smi<%=i%>_tx_port_config;
  <% } %>
  <% var NSMIIFRX = obj.nSmiTx;
  for (var i = 0; i < NSMIIFRX; i++) { %>
      smi_port_config m_smi<%=i%>_rx_port_config;
  <% } %>
  
  function new(string name = "smi_agent_config");
      super.new(name);
  endfunction : new

endclass: smi_agent_config
