////////////////////////////////////////////////////////////////////////////////
//
// AXI Master Agent
//
////////////////////////////////////////////////////////////////////////////////
import common_knob_pkg::*;

class axi_master_agent extends uvm_component;

  `uvm_component_param_utils(axi_master_agent)

  axi_agent_config m_cfg;

  uvm_analysis_port #(axi4_read_addr_pkt_t)  read_addr_ap;
  uvm_analysis_port #(axi4_write_addr_pkt_t) write_addr_ap;
  uvm_analysis_port #(axi4_read_data_pkt_t)  read_data_ap;
  uvm_analysis_port #(axi4_read_data_pkt_t)  read_data_every_beat_ap;
  uvm_analysis_port #(axi4_read_data_pkt_t)  read_data_advance_copy_ap;
  uvm_analysis_port #(axi4_write_data_pkt_t) write_data_ap;
  uvm_analysis_port #(axi4_write_data_pkt_t) write_data_every_beat_ap;
  uvm_analysis_port #(axi4_write_resp_pkt_t) write_resp_ap;
  uvm_analysis_port #(axi4_write_resp_pkt_t) write_resp_advance_copy_ap;
  uvm_analysis_port #(ace_snoop_addr_pkt_t)  snoop_addr_ap;
  uvm_analysis_port #(ace_snoop_data_pkt_t)  snoop_data_ap;
  uvm_analysis_port #(ace_snoop_resp_pkt_t)  snoop_resp_ap;
 
  axi_master_monitor   m_monitor;
  axi_master_read_addr_chnl_driver  m_master_read_addr_chnl_driver;
  axi_master_read_data_chnl_driver  m_master_read_data_chnl_driver;
  axi_master_write_addr_chnl_driver m_master_write_addr_chnl_driver;
  axi_master_write_data_chnl_driver m_master_write_data_chnl_driver;
  axi_master_write_resp_chnl_driver m_master_write_resp_chnl_driver;
  axi_master_snoop_addr_chnl_driver m_master_snoop_addr_chnl_driver;
  axi_master_snoop_data_chnl_driver m_master_snoop_data_chnl_driver;
  axi_master_snoop_resp_chnl_driver m_master_snoop_resp_chnl_driver;
  axi_read_addr_chnl_sequencer      m_read_addr_chnl_seqr;
  axi_read_data_chnl_sequencer      m_read_data_chnl_seqr;
  axi_write_addr_chnl_sequencer     m_write_addr_chnl_seqr;
  axi_write_data_chnl_sequencer     m_write_data_chnl_seqr;
  axi_write_resp_chnl_sequencer     m_write_resp_chnl_seqr;
  axi_snoop_addr_chnl_sequencer     m_snoop_addr_chnl_seqr;
  axi_snoop_data_chnl_sequencer     m_snoop_data_chnl_seqr;
  axi_snoop_resp_chnl_sequencer     m_snoop_resp_chnl_seqr;

  axi_virtual_sequencer             m_axi_virtual_seqr;

  bit iocache_perf_test = 0;
  bit no_bfm_delays = 0;

  extern function new(string name = "axi_master_agent", uvm_component parent = null);
  extern function void build_phase(uvm_phase phase);
  extern function void connect_phase(uvm_phase phase);

endclass: axi_master_agent

//------------------------------------------------------------------------------
// Constructor
//------------------------------------------------------------------------------
function axi_master_agent::new(string name = "axi_master_agent", uvm_component parent = null);
    uvm_cmdline_processor clp;
    string arg_value; 
    super.new(name, parent);

    clp = uvm_cmdline_processor::get_inst();
    clp.get_arg_value("+UVM_TESTNAME=", arg_value);
    if (arg_value == "concerto_inhouse_iocache_perf_test") begin
        iocache_perf_test = 1;
    end
    else begin
        iocache_perf_test = 0;
    end
    no_bfm_delays = $test$plusargs("no_bfm_delays");
endfunction : new

//------------------------------------------------------------------------------
// Build Phase
//------------------------------------------------------------------------------
function void axi_master_agent::build_phase(uvm_phase phase);
    if (!uvm_config_db#(axi_agent_config)::get(.cntxt( this ), 
                .inst_name ( "" ), 
                .field_name( "axi_master_agent_config" ),
                .value( m_cfg ))) begin
        `uvm_error( "axi_master_agent", "axi_agent_config not found" )
    end


    m_monitor = axi_master_monitor::type_id::create("m_monitor", this);
    
    if(m_cfg.active == UVM_ACTIVE) begin
        m_master_read_addr_chnl_driver  = axi_master_read_addr_chnl_driver::type_id::create("m_master_read_addr_chnl_driver", this);
        m_master_read_data_chnl_driver  = axi_master_read_data_chnl_driver::type_id::create("m_master_read_data_chnl_driver", this);
        m_master_write_addr_chnl_driver = axi_master_write_addr_chnl_driver::type_id::create("m_master_write_addr_chnl_driver", this);
        m_master_write_data_chnl_driver = axi_master_write_data_chnl_driver::type_id::create("m_master_write_data_chnl_driver", this);
        m_master_write_resp_chnl_driver = axi_master_write_resp_chnl_driver::type_id::create("m_master_write_resp_chnl_driver", this);
        m_master_snoop_addr_chnl_driver = axi_master_snoop_addr_chnl_driver::type_id::create("m_master_snoop_addr_chnl_driver", this);
        m_master_snoop_data_chnl_driver = axi_master_snoop_data_chnl_driver::type_id::create("m_master_snoop_data_chnl_driver", this);
        m_master_snoop_resp_chnl_driver = axi_master_snoop_resp_chnl_driver::type_id::create("m_master_snoop_resp_chnl_driver", this);
        m_read_addr_chnl_seqr           = axi_read_addr_chnl_sequencer::type_id::create("m_read_addr_chnl_seqr", this);
        m_read_data_chnl_seqr           = axi_read_data_chnl_sequencer::type_id::create("m_read_data_chnl_seqr", this);
        m_write_addr_chnl_seqr          = axi_write_addr_chnl_sequencer::type_id::create("m_write_addr_chnl_seqr", this);
        m_write_data_chnl_seqr          = axi_write_data_chnl_sequencer::type_id::create("m_write_data_chnl_seqr", this);
        m_write_resp_chnl_seqr          = axi_write_resp_chnl_sequencer::type_id::create("m_write_resp_chnl_seqr", this);
        m_snoop_addr_chnl_seqr          = axi_snoop_addr_chnl_sequencer::type_id::create("m_snoop_addr_chnl_seqr", this);
        m_snoop_data_chnl_seqr          = axi_snoop_data_chnl_sequencer::type_id::create("m_snoop_data_chnl_seqr", this);
        m_snoop_resp_chnl_seqr          = axi_snoop_resp_chnl_sequencer::type_id::create("m_snoop_resp_chnl_seqr", this);
        m_axi_virtual_seqr              = axi_virtual_sequencer::type_id::create("m_axi_virtual_seqr", this);
    end // if (m_cfg.active == UVM_ACTIVE)
endfunction: build_phase

//------------------------------------------------------------------------------
// Connect Phase
//------------------------------------------------------------------------------
function void axi_master_agent::connect_phase(uvm_phase phase);
    m_monitor.m_vif               = m_cfg.m_vif;
    m_monitor.m_vif.IS_IF_A_SLAVE = 0;
    m_monitor.m_vif.IS_ACTIVE     = 0;
    m_monitor.m_intf_type         = m_cfg.m_intf_type;
    m_monitor.delay_export        = m_cfg.delay_export;
    read_addr_ap                  = m_monitor.read_addr_ap;
    write_addr_ap                 = m_monitor.write_addr_ap;
    read_data_ap                  = m_monitor.read_data_ap;
    read_data_every_beat_ap       = m_monitor.read_data_every_beat_ap;
    read_data_advance_copy_ap     = m_monitor.read_data_advance_copy_ap;
    write_data_ap                 = m_monitor.write_data_ap;
    write_data_every_beat_ap      = m_monitor.write_data_every_beat_ap;
    write_resp_ap                 = m_monitor.write_resp_ap;
    write_resp_advance_copy_ap    = m_monitor.write_resp_advance_copy_ap;
    if (m_cfg.m_intf_type == IS_ACE_INTF) begin
        snoop_addr_ap = m_monitor.snoop_addr_ap;
        snoop_resp_ap = m_monitor.snoop_resp_ap;
        snoop_data_ap = m_monitor.snoop_data_ap;
    end
    if(m_cfg.active == UVM_ACTIVE) begin
        m_monitor.m_vif.IS_ACTIVE = 1;
        //Setting up knobs inside axi_if
        if($test$plusargs("en_ace_read_data_chnl_wait_for_vld")) begin
            m_cfg.k_ace_master_read_data_chnl_wait_for_vld = 1;
        end else begin
            m_cfg.k_ace_master_read_data_chnl_wait_for_vld  = no_bfm_delays ? 0 : ($urandom_range(0,100) < 10) ? 1 : 0;
        end
        m_cfg.k_ace_master_write_resp_chnl_wait_for_vld = no_bfm_delays ? 0 : ($urandom_range(0,100) < 10) ? 1 : 0;
        m_cfg.k_ace_master_snoop_addr_chnl_wait_for_vld = no_bfm_delays ? 0 : ($urandom_range(0,100) < 10) ? 1 : 0;
        m_cfg.k_ace_slave_read_addr_chnl_wait_for_vld   = no_bfm_delays ? 0 : ($urandom_range(0,100) < 10) ? 1 : 0;
        //m_cfg.k_ace_slave_write_addr_chnl_wait_for_vld  = no_bfm_delays ? 0 : ($urandom_range(0,100) < 10) ? 1 : 0;
        //m_cfg.k_ace_slave_write_data_chnl_wait_for_vld  = no_bfm_delays ? 0 : ($urandom_range(0,100) < 10) ? 1 : 0;
/*        
        <%if(obj.isBridgeInterface){%>
        if (m_cfg.k_slow_agent) begin
            m_cfg.k_ace_master_read_data_chnl_delay_min  = $urandom_range(10, 20);
            m_cfg.k_ace_master_read_data_chnl_delay_max  = $urandom_range(20, 50);
            m_cfg.k_ace_master_read_data_chnl_burst_pct  = $urandom_range(2, 20);

            m_cfg.k_ace_master_write_data_chnl_delay_min = $urandom_range(10, 20);
            m_cfg.k_ace_master_write_data_chnl_delay_max = $urandom_range(20, 50);
            m_cfg.k_ace_master_write_data_chnl_burst_pct = $urandom_range(2, 20);

            m_cfg.k_ace_master_write_resp_chnl_delay_min = $urandom_range(10, 20);
            m_cfg.k_ace_master_write_resp_chnl_delay_max = $urandom_range(20, 50);
            m_cfg.k_ace_master_write_resp_chnl_burst_pct = $urandom_range(2, 20);

            m_cfg.k_ace_master_snoop_addr_chnl_delay_min = $urandom_range(10,20);
            m_cfg.k_ace_master_snoop_addr_chnl_delay_max = $urandom_range(20,50);
            m_cfg.k_ace_master_snoop_addr_chnl_burst_pct = $urandom_range(2, 20);

            m_cfg.k_ace_master_snoop_data_chnl_delay_min = $urandom_range(10,20);
            m_cfg.k_ace_master_snoop_data_chnl_delay_max = $urandom_range(20,50);
            m_cfg.k_ace_master_snoop_data_chnl_burst_pct = $urandom_range(2, 20);

            m_cfg.k_ace_master_snoop_resp_chnl_delay_min = $urandom_range(10,20);
            m_cfg.k_ace_master_snoop_resp_chnl_delay_max = $urandom_range(20,50);
            m_cfg.k_ace_master_snoop_resp_chnl_burst_pct = $urandom_range(2, 20);

            m_cfg.k_ace_slave_read_addr_chnl_delay_min   = $urandom_range(10,20);
            m_cfg.k_ace_slave_read_addr_chnl_delay_max   = $urandom_range(20,50);
            m_cfg.k_ace_slave_read_addr_chnl_burst_pct   = $urandom_range(2, 20);

            m_cfg.k_ace_slave_read_data_chnl_delay_min   = $urandom_range(10,20);
            m_cfg.k_ace_slave_read_data_chnl_delay_max   = $urandom_range(20,50);
            m_cfg.k_ace_slave_read_data_chnl_burst_pct   = $urandom_range(2, 20);
            m_cfg.k_ace_slave_read_data_reorder_size     = $urandom_range(2, 20);
            m_cfg.k_ace_slave_read_data_interleave_dis   = 0;

            m_cfg.k_ace_slave_write_addr_chnl_delay_min  = $urandom_range(10,20);
            m_cfg.k_ace_slave_write_addr_chnl_delay_max  = $urandom_range(20,50);
            m_cfg.k_ace_slave_write_addr_chnl_burst_pct  = $urandom_range(2, 20);

            m_cfg.k_ace_slave_write_data_chnl_delay_min  = $urandom_range(10,20);
            m_cfg.k_ace_slave_write_data_chnl_delay_max  = $urandom_range(20,50);
            m_cfg.k_ace_slave_write_data_chnl_burst_pct  = $urandom_range(2, 20);

            m_cfg.k_ace_slave_write_resp_chnl_delay_min  = $urandom_range(10,20);
            m_cfg.k_ace_slave_write_resp_chnl_delay_max  = $urandom_range(20,50);
            m_cfg.k_ace_slave_write_resp_chnl_burst_pct  = $urandom_range(2, 20);

            m_cfg.k_ace_slave_snoop_addr_chnl_delay_min  = $urandom_range(10,20);
            m_cfg.k_ace_slave_snoop_addr_chnl_delay_max  = $urandom_range(20,50);
            m_cfg.k_ace_slave_snoop_addr_chnl_burst_pct  = $urandom_range(2, 20);

            m_cfg.k_ace_slave_snoop_data_chnl_delay_min  = $urandom_range(10, 20);
            m_cfg.k_ace_slave_snoop_data_chnl_delay_max  = $urandom_range(20, 50);
            m_cfg.k_ace_slave_snoop_data_chnl_burst_pct  = $urandom_range(2, 20);

            m_cfg.k_ace_slave_snoop_resp_chnl_delay_min  = $urandom_range(10, 20);
            m_cfg.k_ace_slave_snoop_resp_chnl_delay_max  = $urandom_range(20, 50);
            m_cfg.k_ace_slave_snoop_resp_chnl_burst_pct  = $urandom_range(2, 20);
        end
        if (m_cfg.k_slow_read_agent) begin
            m_cfg.k_ace_master_read_data_chnl_delay_min  = $urandom_range(10, 20);
            m_cfg.k_ace_master_read_data_chnl_delay_max  = $urandom_range(20, 50);
            m_cfg.k_ace_master_read_data_chnl_burst_pct  = $urandom_range(2, 20);

            m_cfg.k_ace_slave_read_addr_chnl_delay_min   = $urandom_range(10, 20);
            m_cfg.k_ace_slave_read_addr_chnl_delay_max   = $urandom_range(20, 50);
            m_cfg.k_ace_slave_read_addr_chnl_burst_pct   = $urandom_range(2, 20);

            m_cfg.k_ace_slave_read_data_chnl_delay_min   = $urandom_range(10, 20);
            m_cfg.k_ace_slave_read_data_chnl_delay_max   = $urandom_range(20, 50);
            m_cfg.k_ace_slave_read_data_chnl_burst_pct   = $urandom_range(2, 20);
            m_cfg.k_ace_slave_read_data_reorder_size     = $urandom_range(2, 20);
            m_cfg.k_ace_slave_read_data_interleave_dis   = 0;
        end
        if (m_cfg.k_slow_write_agent) begin
            m_cfg.k_ace_master_write_data_chnl_delay_min = $urandom_range(10, 20);
            m_cfg.k_ace_master_write_data_chnl_delay_max = $urandom_range(20, 50);
            m_cfg.k_ace_master_write_data_chnl_burst_pct = $urandom_range(2, 20);

            m_cfg.k_ace_master_write_resp_chnl_delay_min = $urandom_range(10, 20);
            m_cfg.k_ace_master_write_resp_chnl_delay_max = $urandom_range(20, 50);
            m_cfg.k_ace_master_write_resp_chnl_burst_pct = $urandom_range(2, 20);

            m_cfg.k_ace_slave_write_addr_chnl_delay_min  = $urandom_range(10, 20);
            m_cfg.k_ace_slave_write_addr_chnl_delay_max  = $urandom_range(20, 50);
            m_cfg.k_ace_slave_write_addr_chnl_burst_pct  = $urandom_range(2, 20);

            m_cfg.k_ace_slave_write_data_chnl_delay_min  = $urandom_range(10, 20);
            m_cfg.k_ace_slave_write_data_chnl_delay_max  = $urandom_range(20, 50);
            m_cfg.k_ace_slave_write_data_chnl_burst_pct  = $urandom_range(2, 20);

            m_cfg.k_ace_slave_write_resp_chnl_delay_min  = $urandom_range(10, 20);
            m_cfg.k_ace_slave_write_resp_chnl_delay_max  = $urandom_range(20, 50);
            m_cfg.k_ace_slave_write_resp_chnl_burst_pct  = $urandom_range(2, 20);
        end
        if (m_cfg.k_slow_snoop_agent) begin
            m_cfg.k_ace_master_snoop_addr_chnl_delay_min = $urandom_range(10, 20);
            m_cfg.k_ace_master_snoop_addr_chnl_delay_max = $urandom_range(20, 50);
            m_cfg.k_ace_master_snoop_addr_chnl_burst_pct = $urandom_range(2, 20);

            m_cfg.k_ace_master_snoop_data_chnl_delay_min = $urandom_range(10, 20);
            m_cfg.k_ace_master_snoop_data_chnl_delay_max = $urandom_range(20, 50);
            m_cfg.k_ace_master_snoop_data_chnl_burst_pct = $urandom_range(2, 20);

            m_cfg.k_ace_master_snoop_resp_chnl_delay_min = $urandom_range(10, 20);
            m_cfg.k_ace_master_snoop_resp_chnl_delay_max = $urandom_range(20, 50);
            m_cfg.k_ace_master_snoop_resp_chnl_burst_pct = $urandom_range(2, 20);

            m_cfg.k_ace_slave_snoop_addr_chnl_delay_min  = $urandom_range(10, 20);
            m_cfg.k_ace_slave_snoop_addr_chnl_delay_max  = $urandom_range(20, 50);
            m_cfg.k_ace_slave_snoop_addr_chnl_burst_pct  = $urandom_range(2, 20);

            m_cfg.k_ace_slave_snoop_data_chnl_delay_min  = $urandom_range(10, 20);
            m_cfg.k_ace_slave_snoop_data_chnl_delay_max  = $urandom_range(20, 50);
            m_cfg.k_ace_slave_snoop_data_chnl_burst_pct  = $urandom_range(2, 20);

            m_cfg.k_ace_slave_snoop_resp_chnl_delay_min  = $urandom_range(10, 20);
            m_cfg.k_ace_slave_snoop_resp_chnl_delay_max  = $urandom_range(20, 50);
            m_cfg.k_ace_slave_snoop_resp_chnl_burst_pct  = $urandom_range(2, 20);
        end

        <%}else{%>
        if (m_cfg.k_slow_agent) begin
            m_cfg.k_ace_master_read_data_chnl_delay_min  = $urandom_range(80, 120);
            m_cfg.k_ace_master_read_data_chnl_delay_max  = $urandom_range(150, 200);
            m_cfg.k_ace_master_read_data_chnl_burst_pct  = $urandom_range(2, 20);

            m_cfg.k_ace_master_write_data_chnl_delay_min = $urandom_range(80, 120);
            m_cfg.k_ace_master_write_data_chnl_delay_max = $urandom_range(150, 200);
            m_cfg.k_ace_master_write_data_chnl_burst_pct = $urandom_range(2, 20);

            m_cfg.k_ace_master_write_resp_chnl_delay_min = $urandom_range(80, 120);
            m_cfg.k_ace_master_write_resp_chnl_delay_max = $urandom_range(150, 200);
            m_cfg.k_ace_master_write_resp_chnl_burst_pct = $urandom_range(2, 20);

            m_cfg.k_ace_master_snoop_addr_chnl_delay_min = $urandom_range(80, 120);
            m_cfg.k_ace_master_snoop_addr_chnl_delay_max = $urandom_range(150, 200);
            m_cfg.k_ace_master_snoop_addr_chnl_burst_pct = $urandom_range(2, 20);

            m_cfg.k_ace_master_snoop_data_chnl_delay_min = $urandom_range(80, 120);
            m_cfg.k_ace_master_snoop_data_chnl_delay_max = $urandom_range(150, 200);
            m_cfg.k_ace_master_snoop_data_chnl_burst_pct = $urandom_range(2, 20);

            m_cfg.k_ace_master_snoop_resp_chnl_delay_min = $urandom_range(80, 120);
            m_cfg.k_ace_master_snoop_resp_chnl_delay_max = $urandom_range(150, 200);
            m_cfg.k_ace_master_snoop_resp_chnl_burst_pct = $urandom_range(2, 20);

            m_cfg.k_ace_slave_read_addr_chnl_delay_min   = $urandom_range(80, 120);
            m_cfg.k_ace_slave_read_addr_chnl_delay_max   = $urandom_range(150, 200);
            m_cfg.k_ace_slave_read_addr_chnl_burst_pct   = $urandom_range(2, 20);

            m_cfg.k_ace_slave_read_data_chnl_delay_min   = $urandom_range(80, 120);
            m_cfg.k_ace_slave_read_data_chnl_delay_max   = $urandom_range(150, 200);
            m_cfg.k_ace_slave_read_data_chnl_burst_pct   = $urandom_range(2, 20);
            m_cfg.k_ace_slave_read_data_reorder_size     = $urandom_range(2, 20);
            m_cfg.k_ace_slave_read_data_interleave_dis   = 0;

            m_cfg.k_ace_slave_write_addr_chnl_delay_min  = $urandom_range(80, 120);
            m_cfg.k_ace_slave_write_addr_chnl_delay_max  = $urandom_range(150, 200);
            m_cfg.k_ace_slave_write_addr_chnl_burst_pct  = $urandom_range(2, 20);

            m_cfg.k_ace_slave_write_data_chnl_delay_min  = $urandom_range(80, 120);
            m_cfg.k_ace_slave_write_data_chnl_delay_max  = $urandom_range(150, 200);
            m_cfg.k_ace_slave_write_data_chnl_burst_pct  = $urandom_range(2, 20);

            m_cfg.k_ace_slave_write_resp_chnl_delay_min  = $urandom_range(80, 120);
            m_cfg.k_ace_slave_write_resp_chnl_delay_max  = $urandom_range(150, 200);
            m_cfg.k_ace_slave_write_resp_chnl_burst_pct  = $urandom_range(2, 20);

            m_cfg.k_ace_slave_snoop_addr_chnl_delay_min  = $urandom_range(80, 120);
            m_cfg.k_ace_slave_snoop_addr_chnl_delay_max  = $urandom_range(150, 200);
            m_cfg.k_ace_slave_snoop_addr_chnl_burst_pct  = $urandom_range(2, 20);

            m_cfg.k_ace_slave_snoop_data_chnl_delay_min  = $urandom_range(80, 120);
            m_cfg.k_ace_slave_snoop_data_chnl_delay_max  = $urandom_range(150, 200);
            m_cfg.k_ace_slave_snoop_data_chnl_burst_pct  = $urandom_range(2, 20);

            m_cfg.k_ace_slave_snoop_resp_chnl_delay_min  = $urandom_range(80, 120);
            m_cfg.k_ace_slave_snoop_resp_chnl_delay_max  = $urandom_range(150, 200);
            m_cfg.k_ace_slave_snoop_resp_chnl_burst_pct  = $urandom_range(2, 20);
        end
        if (m_cfg.k_slow_read_agent) begin
            m_cfg.k_ace_master_read_data_chnl_delay_min  = $urandom_range(80, 120);
            m_cfg.k_ace_master_read_data_chnl_delay_max  = $urandom_range(150, 200);
            m_cfg.k_ace_master_read_data_chnl_burst_pct  = $urandom_range(2, 20);

            m_cfg.k_ace_slave_read_addr_chnl_delay_min   = $urandom_range(80, 120);
            m_cfg.k_ace_slave_read_addr_chnl_delay_max   = $urandom_range(150, 200);
            m_cfg.k_ace_slave_read_addr_chnl_burst_pct   = $urandom_range(2, 20);

            m_cfg.k_ace_slave_read_data_chnl_delay_min   = $urandom_range(80, 120);
            m_cfg.k_ace_slave_read_data_chnl_delay_max   = $urandom_range(150, 200);
            m_cfg.k_ace_slave_read_data_chnl_burst_pct   = $urandom_range(2, 20);
            m_cfg.k_ace_slave_read_data_reorder_size     = $urandom_range(2, 20);
            m_cfg.k_ace_slave_read_data_interleave_dis   = 0;
        end
        if (m_cfg.k_slow_write_agent) begin
            m_cfg.k_ace_master_write_data_chnl_delay_min = $urandom_range(80, 120);
            m_cfg.k_ace_master_write_data_chnl_delay_max = $urandom_range(150, 200);
            m_cfg.k_ace_master_write_data_chnl_burst_pct = $urandom_range(2, 20);

            m_cfg.k_ace_master_write_resp_chnl_delay_min = $urandom_range(80, 120);
            m_cfg.k_ace_master_write_resp_chnl_delay_max = $urandom_range(150, 200);
            m_cfg.k_ace_master_write_resp_chnl_burst_pct = $urandom_range(2, 20);

            m_cfg.k_ace_slave_write_addr_chnl_delay_min  = $urandom_range(80, 120);
            m_cfg.k_ace_slave_write_addr_chnl_delay_max  = $urandom_range(150, 200);
            m_cfg.k_ace_slave_write_addr_chnl_burst_pct  = $urandom_range(2, 20);

            m_cfg.k_ace_slave_write_data_chnl_delay_min  = $urandom_range(80, 120);
            m_cfg.k_ace_slave_write_data_chnl_delay_max  = $urandom_range(150, 200);
            m_cfg.k_ace_slave_write_data_chnl_burst_pct  = $urandom_range(2, 20);

            m_cfg.k_ace_slave_write_resp_chnl_delay_min  = $urandom_range(80, 120);
            m_cfg.k_ace_slave_write_resp_chnl_delay_max  = $urandom_range(150, 200);
            m_cfg.k_ace_slave_write_resp_chnl_burst_pct  = $urandom_range(2, 20);
        end
        if (m_cfg.k_slow_snoop_agent) begin
            m_cfg.k_ace_master_snoop_addr_chnl_delay_min = $urandom_range(80, 120);
            m_cfg.k_ace_master_snoop_addr_chnl_delay_max = $urandom_range(150, 200);
            m_cfg.k_ace_master_snoop_addr_chnl_burst_pct = $urandom_range(2, 20);

            m_cfg.k_ace_master_snoop_data_chnl_delay_min = $urandom_range(80, 120);
            m_cfg.k_ace_master_snoop_data_chnl_delay_max = $urandom_range(150, 200);
            m_cfg.k_ace_master_snoop_data_chnl_burst_pct = $urandom_range(2, 20);

            m_cfg.k_ace_master_snoop_resp_chnl_delay_min = $urandom_range(80, 120);
            m_cfg.k_ace_master_snoop_resp_chnl_delay_max = $urandom_range(150, 200);
            m_cfg.k_ace_master_snoop_resp_chnl_burst_pct = $urandom_range(2, 20);

            m_cfg.k_ace_slave_snoop_addr_chnl_delay_min  = $urandom_range(80, 120);
            m_cfg.k_ace_slave_snoop_addr_chnl_delay_max  = $urandom_range(150, 200);
            m_cfg.k_ace_slave_snoop_addr_chnl_burst_pct  = $urandom_range(2, 20);

            m_cfg.k_ace_slave_snoop_data_chnl_delay_min  = $urandom_range(80, 120);
            m_cfg.k_ace_slave_snoop_data_chnl_delay_max  = $urandom_range(150, 200);
            m_cfg.k_ace_slave_snoop_data_chnl_burst_pct  = $urandom_range(2, 20);

            m_cfg.k_ace_slave_snoop_resp_chnl_delay_min  = $urandom_range(80, 120);
            m_cfg.k_ace_slave_snoop_resp_chnl_delay_max  = $urandom_range(150, 200);
            m_cfg.k_ace_slave_snoop_resp_chnl_burst_pct  = $urandom_range(2, 20);
        end
        <%}%>
*/
        m_cfg.m_vif.ACE_MASTER_READ_ADDR_CHANNEL_DELAY_MIN    = m_cfg.k_ace_master_read_addr_chnl_delay_min.get_value();
        m_cfg.m_vif.ACE_MASTER_READ_ADDR_CHANNEL_DELAY_MAX    = m_cfg.k_ace_master_read_addr_chnl_delay_max.get_value();
        m_cfg.m_vif.ACE_MASTER_READ_ADDR_CHANNEL_BURST_PCT    = m_cfg.k_ace_master_read_addr_chnl_burst_pct.get_value();

        m_cfg.m_vif.ACE_MASTER_READ_DATA_CHANNEL_DELAY_MIN    = m_cfg.k_ace_master_read_data_chnl_delay_min.get_value();
        m_cfg.m_vif.ACE_MASTER_READ_DATA_CHANNEL_DELAY_MAX    = m_cfg.k_ace_master_read_data_chnl_delay_max.get_value();
        m_cfg.m_vif.ACE_MASTER_READ_DATA_CHANNEL_BURST_PCT    = m_cfg.k_ace_master_read_data_chnl_burst_pct.get_value();
        m_cfg.m_vif.ACE_MASTER_READ_DATA_CHANNEL_WAIT_FOR_VLD = m_cfg.k_ace_master_read_data_chnl_wait_for_vld;

        m_cfg.m_vif.ACE_MASTER_WRITE_ADDR_CHANNEL_DELAY_MIN   = m_cfg.k_ace_master_write_addr_chnl_delay_min.get_value();
        m_cfg.m_vif.ACE_MASTER_WRITE_ADDR_CHANNEL_DELAY_MAX   = m_cfg.k_ace_master_write_addr_chnl_delay_max.get_value();
        m_cfg.m_vif.ACE_MASTER_WRITE_ADDR_CHANNEL_BURST_PCT   = m_cfg.k_ace_master_write_addr_chnl_burst_pct.get_value();

        m_cfg.m_vif.ACE_MASTER_WRITE_DATA_CHANNEL_DELAY_MIN = m_cfg.k_ace_master_write_data_chnl_delay_min.get_value();
        m_cfg.m_vif.ACE_MASTER_WRITE_DATA_CHANNEL_DELAY_MAX = m_cfg.k_ace_master_write_data_chnl_delay_max.get_value();
        m_cfg.m_vif.ACE_MASTER_WRITE_DATA_CHANNEL_BURST_PCT = m_cfg.k_ace_master_write_data_chnl_burst_pct.get_value();

        m_cfg.m_vif.ACE_MASTER_WRITE_RESP_CHANNEL_DELAY_MIN    = m_cfg.k_ace_master_write_resp_chnl_delay_min.get_value();
        m_cfg.m_vif.ACE_MASTER_WRITE_RESP_CHANNEL_DELAY_MAX    = m_cfg.k_ace_master_write_resp_chnl_delay_max.get_value();
        m_cfg.m_vif.ACE_MASTER_WRITE_RESP_CHANNEL_BURST_PCT    = m_cfg.k_ace_master_write_resp_chnl_burst_pct.get_value();
        m_cfg.m_vif.ACE_MASTER_WRITE_RESP_CHANNEL_WAIT_FOR_VLD = m_cfg.k_ace_master_write_resp_chnl_wait_for_vld;

        m_cfg.m_vif.ACE_MASTER_SNOOP_ADDR_CHANNEL_DELAY_MIN    = m_cfg.k_ace_master_snoop_addr_chnl_delay_min.get_value();
        m_cfg.m_vif.ACE_MASTER_SNOOP_ADDR_CHANNEL_DELAY_MAX    = m_cfg.k_ace_master_snoop_addr_chnl_delay_max.get_value();
        m_cfg.m_vif.ACE_MASTER_SNOOP_ADDR_CHANNEL_BURST_PCT    = m_cfg.k_ace_master_snoop_addr_chnl_burst_pct.get_value();
        m_cfg.m_vif.ACE_MASTER_SNOOP_ADDR_CHANNEL_WAIT_FOR_VLD = m_cfg.k_ace_master_snoop_addr_chnl_wait_for_vld;

        m_cfg.m_vif.ACE_MASTER_SNOOP_DATA_CHANNEL_DELAY_MIN = m_cfg.k_ace_master_snoop_data_chnl_delay_min.get_value();
        m_cfg.m_vif.ACE_MASTER_SNOOP_DATA_CHANNEL_DELAY_MAX = m_cfg.k_ace_master_snoop_data_chnl_delay_max.get_value();
        m_cfg.m_vif.ACE_MASTER_SNOOP_DATA_CHANNEL_BURST_PCT = m_cfg.k_ace_master_snoop_data_chnl_burst_pct.get_value();

        m_cfg.m_vif.ACE_MASTER_SNOOP_RESP_CHANNEL_DELAY_MIN = m_cfg.k_ace_master_snoop_resp_chnl_delay_min.get_value();
        m_cfg.m_vif.ACE_MASTER_SNOOP_RESP_CHANNEL_DELAY_MAX = m_cfg.k_ace_master_snoop_resp_chnl_delay_max.get_value();
        m_cfg.m_vif.ACE_MASTER_SNOOP_RESP_CHANNEL_BURST_PCT = m_cfg.k_ace_master_snoop_resp_chnl_burst_pct.get_value();
        
        m_cfg.m_vif.is_bfm_delay_changing                   = m_cfg.k_is_bfm_delay_changing;
        m_cfg.m_vif.delay_changing_time_period              = m_cfg.k_bfm_delay_changing_time;

        m_cfg.m_vif.ACE_SLAVE_READ_ADDR_CHANNEL_DELAY_MIN    = m_cfg.k_ace_slave_read_addr_chnl_delay_min.get_value();
        m_cfg.m_vif.ACE_SLAVE_READ_ADDR_CHANNEL_DELAY_MAX    = m_cfg.k_ace_slave_read_addr_chnl_delay_max.get_value();
        m_cfg.m_vif.ACE_SLAVE_READ_ADDR_CHANNEL_BURST_PCT    = m_cfg.k_ace_slave_read_addr_chnl_burst_pct.get_value();
        m_cfg.m_vif.ACE_SLAVE_READ_ADDR_CHANNEL_WAIT_FOR_VLD = m_cfg.k_ace_slave_read_addr_chnl_wait_for_vld;

        m_cfg.m_vif.ACE_SLAVE_READ_DATA_CHANNEL_STRICT_DLY  = m_cfg.k_ace_slave_read_data_chnl_strict_dly.get_value();
        m_cfg.m_vif.ACE_SLAVE_READ_DATA_CHANNEL_DELAY_MIN   = m_cfg.k_ace_slave_read_data_chnl_delay_min.get_value();
        m_cfg.m_vif.ACE_SLAVE_READ_DATA_CHANNEL_DELAY_MAX   = m_cfg.k_ace_slave_read_data_chnl_delay_max.get_value();
        m_cfg.m_vif.ACE_SLAVE_READ_DATA_CHANNEL_BURST_PCT   = m_cfg.k_ace_slave_read_data_chnl_burst_pct.get_value();
        if (iocache_perf_test) begin
            m_cfg.m_vif.ACE_SLAVE_READ_DATA_REORDER_SIZE    = 0;
            m_cfg.m_vif.ACE_SLAVE_READ_DATA_INTERLEAVE_DIS  = 1;
            m_cfg.m_vif.ACE_SLAVE_READ_DATA_DLY_AFTER_RLAST = 0;
        end
        else begin
            m_cfg.m_vif.ACE_SLAVE_READ_DATA_REORDER_SIZE        = m_cfg.k_ace_slave_read_data_reorder_size.get_value();
            m_cfg.m_vif.ACE_SLAVE_READ_DATA_INTERLEAVE_DIS      = m_cfg.k_ace_slave_read_data_interleave_dis.get_value();
            m_cfg.m_vif.ACE_SLAVE_READ_DATA_DLY_AFTER_RLAST     = m_cfg.k_ace_slave_read_data_dly_after_rlast.get_value();
        end
        m_cfg.m_vif.ACE_SLAVE_WRITE_ADDR_CHANNEL_DELAY_MIN    = m_cfg.k_ace_slave_write_addr_chnl_delay_min.get_value();
        m_cfg.m_vif.ACE_SLAVE_WRITE_ADDR_CHANNEL_DELAY_MAX    = m_cfg.k_ace_slave_write_addr_chnl_delay_max.get_value();
        m_cfg.m_vif.ACE_SLAVE_WRITE_ADDR_CHANNEL_BURST_PCT    = m_cfg.k_ace_slave_write_addr_chnl_burst_pct.get_value();
        m_cfg.m_vif.ACE_SLAVE_WRITE_ADDR_CHANNEL_WAIT_FOR_VLD = m_cfg.k_ace_slave_write_addr_chnl_wait_for_vld.get_value();

        m_cfg.m_vif.ACE_SLAVE_WRITE_DATA_CHANNEL_DELAY_MIN    = m_cfg.k_ace_slave_write_data_chnl_delay_min.get_value();
        m_cfg.m_vif.ACE_SLAVE_WRITE_DATA_CHANNEL_DELAY_MAX    = m_cfg.k_ace_slave_write_data_chnl_delay_max.get_value();
        m_cfg.m_vif.ACE_SLAVE_WRITE_DATA_CHANNEL_BURST_PCT    = m_cfg.k_ace_slave_write_data_chnl_burst_pct.get_value();
        m_cfg.m_vif.ACE_SLAVE_WRITE_DATA_CHANNEL_WAIT_FOR_VLD = m_cfg.k_ace_slave_write_data_chnl_wait_for_vld.get_value();

        m_cfg.m_vif.ACE_SLAVE_WRITE_RESP_CHANNEL_DELAY_MIN  = m_cfg.k_ace_slave_write_resp_chnl_delay_min.get_value();
        m_cfg.m_vif.ACE_SLAVE_WRITE_RESP_CHANNEL_DELAY_MAX  = m_cfg.k_ace_slave_write_resp_chnl_delay_max.get_value();
        m_cfg.m_vif.ACE_SLAVE_WRITE_RESP_CHANNEL_BURST_PCT  = m_cfg.k_ace_slave_write_resp_chnl_burst_pct.get_value();

        m_cfg.m_vif.ACE_SLAVE_SNOOP_ADDR_CHANNEL_DELAY_MIN  = m_cfg.k_ace_slave_snoop_addr_chnl_delay_min.get_value();
        m_cfg.m_vif.ACE_SLAVE_SNOOP_ADDR_CHANNEL_DELAY_MAX  = m_cfg.k_ace_slave_snoop_addr_chnl_delay_max.get_value();
        m_cfg.m_vif.ACE_SLAVE_SNOOP_ADDR_CHANNEL_BURST_PCT  = m_cfg.k_ace_slave_snoop_addr_chnl_burst_pct.get_value();

        m_cfg.m_vif.ACE_SLAVE_SNOOP_DATA_CHANNEL_DELAY_MIN  = m_cfg.k_ace_slave_snoop_data_chnl_delay_min.get_value();
        m_cfg.m_vif.ACE_SLAVE_SNOOP_DATA_CHANNEL_DELAY_MAX  = m_cfg.k_ace_slave_snoop_data_chnl_delay_max.get_value();
        m_cfg.m_vif.ACE_SLAVE_SNOOP_DATA_CHANNEL_BURST_PCT  = m_cfg.k_ace_slave_snoop_data_chnl_burst_pct.get_value();

        m_cfg.m_vif.ACE_SLAVE_SNOOP_RESP_CHANNEL_DELAY_MIN  = m_cfg.k_ace_slave_snoop_resp_chnl_delay_min.get_value();
        m_cfg.m_vif.ACE_SLAVE_SNOOP_RESP_CHANNEL_DELAY_MAX  = m_cfg.k_ace_slave_snoop_resp_chnl_delay_max.get_value();
        m_cfg.m_vif.ACE_SLAVE_SNOOP_RESP_CHANNEL_BURST_PCT  = m_cfg.k_ace_slave_snoop_resp_chnl_burst_pct.get_value();

        m_master_read_addr_chnl_driver.seq_item_port.connect(m_read_addr_chnl_seqr.seq_item_export);
        m_master_read_data_chnl_driver.seq_item_port.connect(m_read_data_chnl_seqr.seq_item_export);
        m_master_write_addr_chnl_driver.seq_item_port.connect(m_write_addr_chnl_seqr.seq_item_export);
        m_master_write_data_chnl_driver.seq_item_port.connect(m_write_data_chnl_seqr.seq_item_export);
        m_master_write_resp_chnl_driver.seq_item_port.connect(m_write_resp_chnl_seqr.seq_item_export);
        m_master_snoop_addr_chnl_driver.seq_item_port.connect(m_snoop_addr_chnl_seqr.seq_item_export);
        m_master_snoop_resp_chnl_driver.seq_item_port.connect(m_snoop_resp_chnl_seqr.seq_item_export);
        m_master_snoop_data_chnl_driver.seq_item_port.connect(m_snoop_data_chnl_seqr.seq_item_export);
        m_master_read_addr_chnl_driver.m_vif  = m_cfg.m_vif;
        m_master_read_data_chnl_driver.m_vif  = m_cfg.m_vif;
        m_master_write_addr_chnl_driver.m_vif = m_cfg.m_vif;
        m_master_write_data_chnl_driver.m_vif = m_cfg.m_vif;
        m_master_write_resp_chnl_driver.m_vif = m_cfg.m_vif;
        m_master_snoop_addr_chnl_driver.m_vif = m_cfg.m_vif;
        m_master_snoop_data_chnl_driver.m_vif = m_cfg.m_vif;
        m_master_snoop_resp_chnl_driver.m_vif = m_cfg.m_vif;
        m_axi_virtual_seqr.m_read_addr_chnl_seqr          =  m_read_addr_chnl_seqr ;
        m_axi_virtual_seqr.m_read_data_chnl_seqr          =  m_read_data_chnl_seqr ;
        m_axi_virtual_seqr.m_write_addr_chnl_seqr         =  m_write_addr_chnl_seqr;
        m_axi_virtual_seqr.m_write_data_chnl_seqr         =  m_write_data_chnl_seqr;
        m_axi_virtual_seqr.m_write_resp_chnl_seqr         =  m_write_resp_chnl_seqr;
        m_axi_virtual_seqr.m_snoop_addr_chnl_seqr         =  m_snoop_addr_chnl_seqr;
        m_axi_virtual_seqr.m_snoop_data_chnl_seqr         =  m_snoop_data_chnl_seqr;
        m_axi_virtual_seqr.m_snoop_resp_chnl_seqr         =  m_snoop_resp_chnl_seqr;
    end // if (m_cfg.active == UVM_ACTIVE)
endfunction: connect_phase


////////////////////////////////////////////////////////////////////////////////
//
// AXI Slave Agent
//
////////////////////////////////////////////////////////////////////////////////
class axi_slave_agent extends uvm_component;

  `uvm_component_param_utils(axi_slave_agent)

  axi_agent_config m_cfg;

  uvm_analysis_port #(axi4_read_addr_pkt_t)  read_addr_ap;
  uvm_analysis_port #(axi4_write_addr_pkt_t) write_addr_ap;
  uvm_analysis_port #(axi4_read_data_pkt_t)  read_data_ap;
  uvm_analysis_port #(axi4_write_data_pkt_t) write_data_ap;
  uvm_analysis_port #(axi4_write_resp_pkt_t) write_resp_ap;
  uvm_analysis_port #(ace_snoop_addr_pkt_t) snoop_addr_ap;
  uvm_analysis_port #(ace_snoop_data_pkt_t) snoop_data_ap;
  uvm_analysis_port #(ace_snoop_resp_pkt_t) snoop_resp_ap;
 
  axi_slave_monitor   m_monitor;
  axi_slave_read_addr_chnl_driver  m_slave_read_addr_chnl_driver;
  axi_slave_read_data_chnl_driver  m_slave_read_data_chnl_driver;
  axi_slave_write_addr_chnl_driver m_slave_write_addr_chnl_driver;
  axi_slave_write_data_chnl_driver m_slave_write_data_chnl_driver;
  axi_slave_write_resp_chnl_driver m_slave_write_resp_chnl_driver;
  //axi_slave_snoop_addr_chnl_driver m_slave_snoop_addr_chnl_driver;
  //axi_slave_snoop_data_chnl_driver m_slave_snoop_data_chnl_driver;
  //axi_slave_snoop_resp_chnl_driver m_slave_snoop_resp_chnl_driver;
  axi_read_addr_chnl_sequencer     m_read_addr_chnl_seqr;
  axi_read_data_chnl_sequencer     m_read_data_chnl_seqr;
  axi_write_addr_chnl_sequencer    m_write_addr_chnl_seqr;
  axi_write_data_chnl_sequencer    m_write_data_chnl_seqr;
  axi_write_resp_chnl_sequencer    m_write_resp_chnl_seqr;
  //axi_snoop_addr_chnl_sequencer    m_snoop_addr_chnl_seqr;
  //axi_snoop_data_chnl_sequencer    m_snoop_data_chnl_seqr;
  //axi_snoop_resp_chnl_sequencer    m_snoop_resp_chnl_seqr;

  bit iocache_perf_test = 0;

  extern function new(string name = "axi_slave_agent", uvm_component parent = null);
  extern function void build_phase(uvm_phase phase);
  extern function void connect_phase(uvm_phase phase);

endclass: axi_slave_agent

//------------------------------------------------------------------------------
// Constructor
//------------------------------------------------------------------------------
function axi_slave_agent::new(string name = "axi_slave_agent", uvm_component parent = null);
    uvm_cmdline_processor clp;
    string arg_value; 
    super.new(name, parent);

    clp = uvm_cmdline_processor::get_inst();
    clp.get_arg_value("+UVM_TESTNAME=", arg_value);
    if (arg_value == "concerto_inhouse_iocache_perf_test") begin
        iocache_perf_test = 1;
    end
    else begin
        iocache_perf_test = 0;
    end
endfunction : new

//------------------------------------------------------------------------------
// Build Phase
//------------------------------------------------------------------------------
function void axi_slave_agent::build_phase(uvm_phase phase);
    if (!uvm_config_db#(axi_agent_config)::get(.cntxt( this ), 
        .inst_name ( "" ), 
        .field_name( "axi_slave_agent_config" ),
        .value( m_cfg ))
    ) begin
        `uvm_error( "axi_slave_agent", "axi_agent_config not found" )
    end


    m_monitor = axi_slave_monitor::type_id::create("m_monitor", this);

    if(m_cfg.active == UVM_ACTIVE) begin
        m_slave_read_addr_chnl_driver  = axi_slave_read_addr_chnl_driver::type_id::create("m_slave_read_addr_chnl_driver", this);
        m_slave_read_data_chnl_driver  = axi_slave_read_data_chnl_driver::type_id::create("m_slave_read_data_chnl_driver", this);
        m_slave_write_addr_chnl_driver = axi_slave_write_addr_chnl_driver::type_id::create("m_slave_write_addr_chnl_driver", this);
        m_slave_write_data_chnl_driver = axi_slave_write_data_chnl_driver::type_id::create("m_slave_write_data_chnl_driver", this);
        m_slave_write_resp_chnl_driver = axi_slave_write_resp_chnl_driver::type_id::create("m_slave_write_resp_chnl_driver", this);
    end // if (m_cfg.active == UVM_ACTIVE)

   //m_slave_snoop_addr_chnl_driver = axi_slave_snoop_addr_chnl_driver::type_id::create("m_slave_snoop_addr_chnl_driver", this);
   //m_slave_snoop_data_chnl_driver = axi_slave_snoop_data_chnl_driver::type_id::create("m_slave_snoop_data_chnl_driver", this);
   //m_slave_snoop_resp_chnl_driver = axi_slave_snoop_resp_chnl_driver::type_id::create("m_slave_snoop_resp_chnl_driver", this);
   m_read_addr_chnl_seqr          = axi_read_addr_chnl_sequencer::type_id::create("m_read_addr_chnl_seqr", this);
   m_read_data_chnl_seqr          = axi_read_data_chnl_sequencer::type_id::create("m_read_data_chnl_seqr", this);
   m_write_addr_chnl_seqr         = axi_write_addr_chnl_sequencer::type_id::create("m_write_addr_chnl_seqr", this);
   m_write_data_chnl_seqr         = axi_write_data_chnl_sequencer::type_id::create("m_write_data_chnl_seqr", this);
   m_write_resp_chnl_seqr         = axi_write_resp_chnl_sequencer::type_id::create("m_write_resp_chnl_seqr", this);
   //m_snoop_addr_chnl_seqr         = axi_snoop_addr_chnl_sequencer::type_id::create("m_snoop_addr_chnl_seqr", this);
   //m_snoop_data_chnl_seqr         = axi_snoop_data_chnl_sequencer::type_id::create("m_snoop_data_chnl_seqr", this);
   //m_snoop_resp_chnl_seqr         = axi_snoop_resp_chnl_sequencer::type_id::create("m_snoop_resp_chnl_seqr", this);
endfunction: build_phase

//------------------------------------------------------------------------------
// Connect Phase
//------------------------------------------------------------------------------
function void axi_slave_agent::connect_phase(uvm_phase phase);
  m_monitor.m_vif               = m_cfg.m_vif;
  m_monitor.m_vif.IS_IF_A_SLAVE = 1;
  m_monitor.m_vif.IS_ACTIVE     = 0;
  m_monitor.m_intf_type         = m_cfg.m_intf_type;
  m_monitor.delay_export        = m_cfg.delay_export;
  read_addr_ap                  = m_monitor.read_addr_ap;
  write_addr_ap                 = m_monitor.write_addr_ap;
  read_data_ap                  = m_monitor.read_data_ap;
  write_data_ap                 = m_monitor.write_data_ap;
  write_resp_ap                 = m_monitor.write_resp_ap;
  if (m_cfg.m_intf_type == IS_ACE_INTF) begin
  end

   m_monitor.m_vif.IS_ACTIVE = 1;

  if(m_cfg.active == UVM_ACTIVE) begin
        //Setting up knobs inside axi_if
/*        
        if (m_cfg.k_slow_agent) begin
            m_cfg.k_ace_slave_read_data_chnl_delay_min  = $urandom_range(80, 120);
            m_cfg.k_ace_slave_read_data_chnl_delay_max  = $urandom_range(150, 200);
            m_cfg.k_ace_slave_read_data_chnl_burst_pct  = $urandom_range(2, 20);

            m_cfg.k_ace_slave_write_data_chnl_delay_min = $urandom_range(80, 120);
            m_cfg.k_ace_slave_write_data_chnl_delay_max = $urandom_range(150, 200);
            m_cfg.k_ace_slave_write_data_chnl_burst_pct = $urandom_range(2, 20);

            m_cfg.k_ace_slave_write_resp_chnl_delay_min = $urandom_range(80, 120);
            m_cfg.k_ace_slave_write_resp_chnl_delay_max = $urandom_range(150, 200);
            m_cfg.k_ace_slave_write_resp_chnl_burst_pct = $urandom_range(2, 20);

            m_cfg.k_ace_slave_snoop_addr_chnl_delay_min = $urandom_range(80, 120);
            m_cfg.k_ace_slave_snoop_addr_chnl_delay_max = $urandom_range(150, 200);
            m_cfg.k_ace_slave_snoop_addr_chnl_burst_pct = $urandom_range(2, 20);

            m_cfg.k_ace_slave_snoop_data_chnl_delay_min = $urandom_range(80, 120);
            m_cfg.k_ace_slave_snoop_data_chnl_delay_max = $urandom_range(150, 200);
            m_cfg.k_ace_slave_snoop_data_chnl_burst_pct = $urandom_range(2, 20);

            m_cfg.k_ace_slave_snoop_resp_chnl_delay_min = $urandom_range(80, 120);
            m_cfg.k_ace_slave_snoop_resp_chnl_delay_max = $urandom_range(150, 200);
            m_cfg.k_ace_slave_snoop_resp_chnl_burst_pct = $urandom_range(2, 20);

            m_cfg.k_ace_slave_read_addr_chnl_delay_min   = $urandom_range(80, 120);
            m_cfg.k_ace_slave_read_addr_chnl_delay_max   = $urandom_range(150, 200);
            m_cfg.k_ace_slave_read_addr_chnl_burst_pct   = $urandom_range(2, 20);

            m_cfg.k_ace_slave_read_data_chnl_delay_min   = $urandom_range(80, 120);
            m_cfg.k_ace_slave_read_data_chnl_delay_max   = $urandom_range(150, 200);
            m_cfg.k_ace_slave_read_data_chnl_burst_pct   = $urandom_range(2, 20);
            m_cfg.k_ace_slave_read_data_reorder_size     = $urandom_range(2, 20);
            m_cfg.k_ace_slave_read_data_interleave_dis   = 0;

            m_cfg.k_ace_slave_write_addr_chnl_delay_min  = $urandom_range(80, 120);
            m_cfg.k_ace_slave_write_addr_chnl_delay_max  = $urandom_range(150, 200);
            m_cfg.k_ace_slave_write_addr_chnl_burst_pct  = $urandom_range(2, 20);

            m_cfg.k_ace_slave_write_data_chnl_delay_min  = $urandom_range(80, 120);
            m_cfg.k_ace_slave_write_data_chnl_delay_max  = $urandom_range(150, 200);
            m_cfg.k_ace_slave_write_data_chnl_burst_pct  = $urandom_range(2, 20);

            m_cfg.k_ace_slave_write_resp_chnl_delay_min  = $urandom_range(80, 120);
            m_cfg.k_ace_slave_write_resp_chnl_delay_max  = $urandom_range(150, 200);
            m_cfg.k_ace_slave_write_resp_chnl_burst_pct  = $urandom_range(2, 20);

            m_cfg.k_ace_slave_snoop_addr_chnl_delay_min  = $urandom_range(80, 120);
            m_cfg.k_ace_slave_snoop_addr_chnl_delay_max  = $urandom_range(150, 200);
            m_cfg.k_ace_slave_snoop_addr_chnl_burst_pct  = $urandom_range(2, 20);

            m_cfg.k_ace_slave_snoop_data_chnl_delay_min  = $urandom_range(80, 120);
            m_cfg.k_ace_slave_snoop_data_chnl_delay_max  = $urandom_range(150, 200);
            m_cfg.k_ace_slave_snoop_data_chnl_burst_pct  = $urandom_range(2, 20);

            m_cfg.k_ace_slave_snoop_resp_chnl_delay_min  = $urandom_range(80, 120);
            m_cfg.k_ace_slave_snoop_resp_chnl_delay_max  = $urandom_range(150, 200);
            m_cfg.k_ace_slave_snoop_resp_chnl_burst_pct  = $urandom_range(2, 20);
        end
        if (m_cfg.k_slow_read_agent) begin
            m_cfg.k_ace_slave_read_data_chnl_delay_min  = $urandom_range(80, 120);
            m_cfg.k_ace_slave_read_data_chnl_delay_max  = $urandom_range(150, 200);
            m_cfg.k_ace_slave_read_data_chnl_burst_pct  = $urandom_range(2, 20);

            m_cfg.k_ace_slave_read_addr_chnl_delay_min   = $urandom_range(80, 120);
            m_cfg.k_ace_slave_read_addr_chnl_delay_max   = $urandom_range(150, 200);
            m_cfg.k_ace_slave_read_addr_chnl_burst_pct   = $urandom_range(2, 20);

            m_cfg.k_ace_slave_read_data_chnl_delay_min   = $urandom_range(80, 120);
            m_cfg.k_ace_slave_read_data_chnl_delay_max   = $urandom_range(150, 200);
            m_cfg.k_ace_slave_read_data_chnl_burst_pct   = $urandom_range(2, 20);
            m_cfg.k_ace_slave_read_data_reorder_size     = $urandom_range(2, 20);
            m_cfg.k_ace_slave_read_data_interleave_dis   = 0;
        end
        if (m_cfg.k_slow_write_agent) begin
            m_cfg.k_ace_slave_write_data_chnl_delay_min = $urandom_range(80, 120);
            m_cfg.k_ace_slave_write_data_chnl_delay_max = $urandom_range(150, 200);
            m_cfg.k_ace_slave_write_data_chnl_burst_pct = $urandom_range(2, 20);

            m_cfg.k_ace_slave_write_resp_chnl_delay_min = $urandom_range(80, 120);
            m_cfg.k_ace_slave_write_resp_chnl_delay_max = $urandom_range(150, 200);
            m_cfg.k_ace_slave_write_resp_chnl_burst_pct = $urandom_range(2, 20);

            m_cfg.k_ace_slave_write_addr_chnl_delay_min  = $urandom_range(80, 120);
            m_cfg.k_ace_slave_write_addr_chnl_delay_max  = $urandom_range(150, 200);
            m_cfg.k_ace_slave_write_addr_chnl_burst_pct  = $urandom_range(2, 20);

            m_cfg.k_ace_slave_write_data_chnl_delay_min  = $urandom_range(80, 120);
            m_cfg.k_ace_slave_write_data_chnl_delay_max  = $urandom_range(150, 200);
            m_cfg.k_ace_slave_write_data_chnl_burst_pct  = $urandom_range(2, 20);

            m_cfg.k_ace_slave_write_resp_chnl_delay_min  = $urandom_range(80, 120);
            m_cfg.k_ace_slave_write_resp_chnl_delay_max  = $urandom_range(150, 200);
            m_cfg.k_ace_slave_write_resp_chnl_burst_pct  = $urandom_range(2, 20);
        end
        if (m_cfg.k_slow_snoop_agent) begin
            m_cfg.k_ace_slave_snoop_addr_chnl_delay_min = $urandom_range(80, 120);
            m_cfg.k_ace_slave_snoop_addr_chnl_delay_max = $urandom_range(150, 200);
            m_cfg.k_ace_slave_snoop_addr_chnl_burst_pct = $urandom_range(2, 20);

            m_cfg.k_ace_slave_snoop_data_chnl_delay_min = $urandom_range(80, 120);
            m_cfg.k_ace_slave_snoop_data_chnl_delay_max = $urandom_range(150, 200);
            m_cfg.k_ace_slave_snoop_data_chnl_burst_pct = $urandom_range(2, 20);

            m_cfg.k_ace_slave_snoop_resp_chnl_delay_min = $urandom_range(80, 120);
            m_cfg.k_ace_slave_snoop_resp_chnl_delay_max = $urandom_range(150, 200);
            m_cfg.k_ace_slave_snoop_resp_chnl_burst_pct = $urandom_range(2, 20);

            m_cfg.k_ace_slave_snoop_addr_chnl_delay_min  = $urandom_range(80, 120);
            m_cfg.k_ace_slave_snoop_addr_chnl_delay_max  = $urandom_range(150, 200);
            m_cfg.k_ace_slave_snoop_addr_chnl_burst_pct  = $urandom_range(2, 20);

            m_cfg.k_ace_slave_snoop_data_chnl_delay_min  = $urandom_range(80, 120);
            m_cfg.k_ace_slave_snoop_data_chnl_delay_max  = $urandom_range(150, 200);
            m_cfg.k_ace_slave_snoop_data_chnl_burst_pct  = $urandom_range(2, 20);

            m_cfg.k_ace_slave_snoop_resp_chnl_delay_min  = $urandom_range(80, 120);
            m_cfg.k_ace_slave_snoop_resp_chnl_delay_max  = $urandom_range(150, 200);
            m_cfg.k_ace_slave_snoop_resp_chnl_burst_pct  = $urandom_range(2, 20);
        end
*/        
        m_cfg.m_vif.ACE_SLAVE_READ_DATA_CHANNEL_DELAY_MIN  = m_cfg.k_ace_slave_read_data_chnl_delay_min.get_value();
        m_cfg.m_vif.ACE_SLAVE_READ_DATA_CHANNEL_DELAY_MAX  = m_cfg.k_ace_slave_read_data_chnl_delay_max.get_value();
        m_cfg.m_vif.ACE_SLAVE_READ_DATA_CHANNEL_BURST_PCT  = m_cfg.k_ace_slave_read_data_chnl_burst_pct.get_value();

        m_cfg.m_vif.ACE_SLAVE_WRITE_DATA_CHANNEL_DELAY_MIN = m_cfg.k_ace_slave_write_data_chnl_delay_min.get_value();
        m_cfg.m_vif.ACE_SLAVE_WRITE_ADDR_CHANNEL_WAIT_FOR_VLD = m_cfg.k_ace_slave_write_addr_chnl_wait_for_vld.get_value();
        m_cfg.m_vif.ACE_SLAVE_WRITE_DATA_CHANNEL_DELAY_MAX = m_cfg.k_ace_slave_write_data_chnl_delay_max.get_value();
        m_cfg.m_vif.ACE_SLAVE_WRITE_DATA_CHANNEL_BURST_PCT = m_cfg.k_ace_slave_write_data_chnl_burst_pct.get_value();

        m_cfg.m_vif.ACE_SLAVE_WRITE_RESP_CHANNEL_DELAY_MIN = m_cfg.k_ace_slave_write_resp_chnl_delay_min.get_value();
        m_cfg.m_vif.ACE_SLAVE_WRITE_RESP_CHANNEL_DELAY_MAX = m_cfg.k_ace_slave_write_resp_chnl_delay_max.get_value();
        m_cfg.m_vif.ACE_SLAVE_WRITE_RESP_CHANNEL_BURST_PCT = m_cfg.k_ace_slave_write_resp_chnl_burst_pct.get_value();

        m_cfg.m_vif.ACE_SLAVE_SNOOP_ADDR_CHANNEL_DELAY_MIN = m_cfg.k_ace_slave_snoop_addr_chnl_delay_min.get_value();
        m_cfg.m_vif.ACE_SLAVE_SNOOP_ADDR_CHANNEL_DELAY_MAX = m_cfg.k_ace_slave_snoop_addr_chnl_delay_max.get_value();
        m_cfg.m_vif.ACE_SLAVE_SNOOP_ADDR_CHANNEL_BURST_PCT = m_cfg.k_ace_slave_snoop_addr_chnl_burst_pct.get_value();

        m_cfg.m_vif.ACE_SLAVE_SNOOP_DATA_CHANNEL_DELAY_MIN = m_cfg.k_ace_slave_snoop_data_chnl_delay_min.get_value();
        m_cfg.m_vif.ACE_SLAVE_SNOOP_DATA_CHANNEL_DELAY_MAX = m_cfg.k_ace_slave_snoop_data_chnl_delay_max.get_value();
        m_cfg.m_vif.ACE_SLAVE_SNOOP_DATA_CHANNEL_BURST_PCT = m_cfg.k_ace_slave_snoop_data_chnl_burst_pct.get_value();

        m_cfg.m_vif.ACE_SLAVE_SNOOP_RESP_CHANNEL_DELAY_MIN = m_cfg.k_ace_slave_snoop_resp_chnl_delay_min.get_value();
        m_cfg.m_vif.ACE_SLAVE_SNOOP_RESP_CHANNEL_DELAY_MAX = m_cfg.k_ace_slave_snoop_resp_chnl_delay_max.get_value();
        m_cfg.m_vif.ACE_SLAVE_SNOOP_RESP_CHANNEL_BURST_PCT = m_cfg.k_ace_slave_snoop_resp_chnl_burst_pct.get_value();

        m_cfg.m_vif.ACE_SLAVE_READ_ADDR_CHANNEL_DELAY_MIN   = m_cfg.k_ace_slave_read_addr_chnl_delay_min.get_value();
        m_cfg.m_vif.ACE_SLAVE_READ_ADDR_CHANNEL_DELAY_MAX   = m_cfg.k_ace_slave_read_addr_chnl_delay_max.get_value();
        m_cfg.m_vif.ACE_SLAVE_READ_ADDR_CHANNEL_BURST_PCT   = m_cfg.k_ace_slave_read_addr_chnl_burst_pct.get_value();

        m_cfg.m_vif.ACE_SLAVE_READ_DATA_CHANNEL_STRICT_DLY  = m_cfg.k_ace_slave_read_data_chnl_strict_dly.get_value();
        m_cfg.m_vif.ACE_SLAVE_READ_DATA_CHANNEL_DELAY_MIN   = m_cfg.k_ace_slave_read_data_chnl_delay_min.get_value();
        m_cfg.m_vif.ACE_SLAVE_READ_DATA_CHANNEL_DELAY_MAX   = m_cfg.k_ace_slave_read_data_chnl_delay_max.get_value();
        m_cfg.m_vif.ACE_SLAVE_READ_DATA_CHANNEL_BURST_PCT   = m_cfg.k_ace_slave_read_data_chnl_burst_pct.get_value();
        if (iocache_perf_test) begin
            m_cfg.m_vif.ACE_SLAVE_READ_DATA_REORDER_SIZE    = 1;
            m_cfg.m_vif.ACE_SLAVE_READ_DATA_INTERLEAVE_DIS  = 1;
            m_cfg.m_vif.ACE_SLAVE_READ_DATA_DLY_AFTER_RLAST = 0;
        end
        else begin
            m_cfg.m_vif.ACE_SLAVE_READ_DATA_REORDER_SIZE    = m_cfg.k_ace_slave_read_data_reorder_size.get_value();
            m_cfg.m_vif.ACE_SLAVE_READ_DATA_INTERLEAVE_DIS  = m_cfg.k_ace_slave_read_data_interleave_dis.get_value();
            m_cfg.m_vif.ACE_SLAVE_READ_DATA_DLY_AFTER_RLAST = m_cfg.k_ace_slave_read_data_dly_after_rlast.get_value();
        end
        m_cfg.m_vif.ACE_SLAVE_READ_DATA_INTERBEATDLY_DIS      = m_cfg.k_ace_slave_read_data_interbeatdly_dis.get_value();
        m_cfg.m_vif.ACE_SLAVE_RANDOM_DLY_DIS                  = m_cfg.k_ace_slave_random_dly_dis.get_value();

        m_cfg.m_vif.ACE_SLAVE_WRITE_ADDR_CHANNEL_DELAY_MIN  = m_cfg.k_ace_slave_write_addr_chnl_delay_min.get_value();
        m_cfg.m_vif.ACE_SLAVE_WRITE_ADDR_CHANNEL_DELAY_MAX  = m_cfg.k_ace_slave_write_addr_chnl_delay_max.get_value();
        m_cfg.m_vif.ACE_SLAVE_WRITE_ADDR_CHANNEL_BURST_PCT  = m_cfg.k_ace_slave_write_addr_chnl_burst_pct.get_value();

        m_cfg.m_vif.ACE_SLAVE_WRITE_DATA_CHANNEL_DELAY_MIN  = m_cfg.k_ace_slave_write_data_chnl_delay_min.get_value();
        m_cfg.m_vif.ACE_SLAVE_WRITE_DATA_CHANNEL_WAIT_FOR_VLD = m_cfg.k_ace_slave_write_data_chnl_wait_for_vld.get_value();
        m_cfg.m_vif.ACE_SLAVE_WRITE_DATA_CHANNEL_DELAY_MAX  = m_cfg.k_ace_slave_write_data_chnl_delay_max.get_value();
        m_cfg.m_vif.ACE_SLAVE_WRITE_DATA_CHANNEL_BURST_PCT  = m_cfg.k_ace_slave_write_data_chnl_burst_pct.get_value();

        m_cfg.m_vif.ACE_SLAVE_WRITE_RESP_CHANNEL_DELAY_MIN  = m_cfg.k_ace_slave_write_resp_chnl_delay_min.get_value();
        m_cfg.m_vif.ACE_SLAVE_WRITE_RESP_CHANNEL_DELAY_MAX  = m_cfg.k_ace_slave_write_resp_chnl_delay_max.get_value();
        m_cfg.m_vif.ACE_SLAVE_WRITE_RESP_CHANNEL_BURST_PCT  = m_cfg.k_ace_slave_write_resp_chnl_burst_pct.get_value();

        m_cfg.m_vif.ACE_SLAVE_SNOOP_ADDR_CHANNEL_DELAY_MIN  = m_cfg.k_ace_slave_snoop_addr_chnl_delay_min.get_value();
        m_cfg.m_vif.ACE_SLAVE_SNOOP_ADDR_CHANNEL_DELAY_MAX  = m_cfg.k_ace_slave_snoop_addr_chnl_delay_max.get_value();
        m_cfg.m_vif.ACE_SLAVE_SNOOP_ADDR_CHANNEL_BURST_PCT  = m_cfg.k_ace_slave_snoop_addr_chnl_burst_pct.get_value();

        m_cfg.m_vif.ACE_SLAVE_SNOOP_DATA_CHANNEL_DELAY_MIN  = m_cfg.k_ace_slave_snoop_data_chnl_delay_min.get_value();
        m_cfg.m_vif.ACE_SLAVE_SNOOP_DATA_CHANNEL_DELAY_MAX  = m_cfg.k_ace_slave_snoop_data_chnl_delay_max.get_value();
        m_cfg.m_vif.ACE_SLAVE_SNOOP_DATA_CHANNEL_BURST_PCT  = m_cfg.k_ace_slave_snoop_data_chnl_burst_pct.get_value();

        m_cfg.m_vif.ACE_SLAVE_SNOOP_RESP_CHANNEL_DELAY_MIN  = m_cfg.k_ace_slave_snoop_resp_chnl_delay_min.get_value();
        m_cfg.m_vif.ACE_SLAVE_SNOOP_RESP_CHANNEL_DELAY_MAX  = m_cfg.k_ace_slave_snoop_resp_chnl_delay_max.get_value();
        m_cfg.m_vif.ACE_SLAVE_SNOOP_RESP_CHANNEL_BURST_PCT  = m_cfg.k_ace_slave_snoop_resp_chnl_burst_pct.get_value();

        m_slave_read_addr_chnl_driver.m_vif  = m_cfg.m_vif;
        m_slave_read_data_chnl_driver.m_vif  = m_cfg.m_vif;
        m_slave_write_addr_chnl_driver.m_vif = m_cfg.m_vif;
        m_slave_write_data_chnl_driver.m_vif = m_cfg.m_vif;
        m_slave_write_resp_chnl_driver.m_vif = m_cfg.m_vif;

        m_slave_read_addr_chnl_driver.seq_item_port.connect(m_read_addr_chnl_seqr.seq_item_export);
        m_slave_read_data_chnl_driver.seq_item_port.connect(m_read_data_chnl_seqr.seq_item_export);
        m_slave_write_addr_chnl_driver.seq_item_port.connect(m_write_addr_chnl_seqr.seq_item_export);
        m_slave_write_data_chnl_driver.seq_item_port.connect(m_write_data_chnl_seqr.seq_item_export);
        m_slave_write_resp_chnl_driver.seq_item_port.connect(m_write_resp_chnl_seqr.seq_item_export);
  end // if (m_cfg.active == UVM_ACTIVE)

endfunction: connect_phase




