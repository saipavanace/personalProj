import <%=obj.BlockId%>_concerto_register_map_pkg::*;

class dve_env extends uvm_env;
  `uvm_component_utils(dve_env)

  smi_agent m_smi_agent;
  apb_agent m_apb_agent ;
  q_chnl_agent  m_q_chnl_agent;
  dve_sb m_dve_sb;
  dve_env_config m_env_cfg;
  dve_dtwdbg_reader m_dve_dtwdbg_reader;
  bit is_dve_dtwdbg_reader = 1'b1;
  <%=obj.BlockId%>_clock_counter_monitor m_clock_counter_mon; 

  <% if(obj.testBench == 'dve' || obj.testBench == 'cust_tb') { %>
  <%=obj.BlockId%>_concerto_register_map_pkg:: ral_sys_ncore m_regs;

  <% } else if(obj.testBench == 'fsys' || obj.testBench == 'emu' ) { %>
  concerto_register_map_pkg::ral_sys_ncore m_regs;
  <% } %>

  int time_bw_Q_chnl_req;

  function new(string name = "dve_env", uvm_component parent);
    super.new(name, parent);
  endfunction // new

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);

    if(!uvm_config_db#(dve_env_config)::get(
       .cntxt(this),
       .inst_name(""),
       .field_name("dve_env_config"),
       .value(m_env_cfg)
       )
      ) begin
      `uvm_fatal("dve_env", "dve_env_config not found")
    end

       <% if (obj.testBench == 'dve') { %>
    if (! m_env_cfg.m_apb_agent_cfg) `uvm_fatal( get_name(), "m_env_cfg.m_apb_agent_cfg not found" )
       <% } %>
       uvm_config_db#(apb_agent_config )::set(.cntxt( this ),
           .inst_name( "m_apb_agent" ),
           .field_name( "apb_agent_config" ),
           .value( m_env_cfg.m_apb_agent_cfg ));

   <% if (obj.testBench == 'dve') { %>
   if (! m_env_cfg.m_q_chnl_agent_cfg) `uvm_fatal( get_name(), "m_env_cfg.m_q_chnl_agent_cfg not found" )
   uvm_config_db#(q_chnl_agent_config )::set(.cntxt( this ),
       .inst_name( "m_q_chnl_agent" ),
       .field_name( "q_chnl_agent_config" ),
       .value( m_env_cfg.m_q_chnl_agent_cfg ));

   m_env_cfg.m_q_chnl_agent_cfg.time_bw_Q_chnl_req = time_bw_Q_chnl_req;
   m_q_chnl_agent = q_chnl_agent::type_id::create("m_q_chnl_agent", this);
   <% } %>

    m_smi_agent = smi_agent::type_id::create("m_smi_agent", this);
    m_smi_agent.m_cfg = m_env_cfg.m_smi_agent_cfg;
    <% if ((obj.testBench == 'dve') || (obj.testBench == 'fsys') || (obj.testBench == 'cust_tb')) { %>
        m_apb_agent = apb_agent::type_id::create("m_apb_agent", this);
    <% } %>

    m_clock_counter_mon = <%=obj.BlockId%>_clock_counter_monitor::type_id::create("m_clock_counter_mon", this);
    m_clock_counter_mon.m_vif = m_env_cfg.m_clock_counter_vif;
     
    if(m_env_cfg.has_sb) begin
      m_dve_sb = dve_sb::type_id::create("m_dve_sb", this);
    end

   <% if(obj.testBench == 'dve' || obj.testBench == 'cust_tb') { %>
   m_regs = <%=obj.BlockId%>_concerto_register_map_pkg:: ral_sys_ncore::type_id::create("m_regs", this);
   <% } else if(obj.testBench == 'fsys') { %>
    if(!(uvm_config_db #(concerto_register_map_pkg::ral_sys_ncore)::get(null, "","m_regs",m_regs)))  `uvm_fatal("Missing in DB::", "RAL m_regs not found");
    //m_regs = concerto_register_map_pkg::ral_sys_ncore::type_id::create("m_regs", this);
   <% } %>
   <% if (obj.testBench == 'dve' || obj.testBench == 'cust_tb') { %>
    m_regs.build();
    m_regs.lock_model();
     uvm_config_db #(<%=obj.BlockId%>_concerto_register_map_pkg:: ral_sys_ncore)::set(null, "", "m_regs", m_regs);
    <% } %>

    if($value$plusargs("is_dve_dtwdbg_reader=%0d", is_dve_dtwdbg_reader))
      `uvm_info(get_name, $sformatf("CMD_LINE: is_dve_dtwdbg_reader=%0d", is_dve_dtwdbg_reader), UVM_NONE);
    if(is_dve_dtwdbg_reader && m_env_cfg.has_sb) begin
      // set up CSR reader for pulling DtwDbgReqs out of the CSRs
      m_dve_dtwdbg_reader = dve_dtwdbg_reader::type_id::create("m_dve_reader", this);
      m_dve_dtwdbg_reader.m_regs = m_regs;
    end

  endfunction // build_phase

  function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    if(m_env_cfg.has_sb) begin
<% for (var i = 0; i < obj.nSmiRx; i++) { %>
      m_smi_agent.m_smi<%=i%>_tx_port_ap.connect(m_dve_sb.smi_port);
<% } %>
<% for (var i = 0; i < obj.nSmiTx; i++) { %>
      m_smi_agent.m_smi<%=i%>_rx_port_ap.connect(m_dve_sb.smi_port);
<% } %>
//      m_smi_agent.m_smi2_tx_every_beat_port_ap.connect(m_dve_sb.m_smi2_tx_every_beat_port);
   <% if (obj.testBench == 'dve') { %>
     m_q_chnl_agent.q_chnl_ap.connect(m_dve_sb.q_chnl_port);
   <% } %>
   <% if (obj.testBench == 'dve' || obj.testBench == 'fsys' || obj.testBench == 'cust_tb') { %>
      if(is_dve_dtwdbg_reader) begin
        m_dve_dtwdbg_reader.dbg_txn_ap.connect(m_dve_sb.dbg_txn_port);
      end
   <% } %>

    m_clock_counter_mon.clock_counter_ap.connect(m_dve_sb.m_clock_counter_port);
    end

   <% if (obj.testBench == 'dve' || obj.testBench == 'cust_tb') { %>
    m_regs.default_map.set_auto_predict(1);
    m_regs.default_map.set_sequencer(.sequencer(m_apb_agent.m_apb_sequencer),
                                     .adapter(m_apb_agent.m_apb_reg_adapter));
   <% } %>

  endfunction // connect_phase
endclass // dve_env
