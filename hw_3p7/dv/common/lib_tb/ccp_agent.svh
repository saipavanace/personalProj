///////////////////////////////////////////////////////////////////////////////
//                                                                           //  
// File         :   ccp_agent.sv                                             //
// Description  :   ccp agent                                                //
//                                                                           //
//                                                                           //
// Revision     :                                                            //
//                                                                           //
//                                                                           //
//                                                                           //
//                                                                           // 
///////////////////////////////////////////////////////////////////////////////
class ccp_agent extends uvm_component;

  `uvm_component_param_utils(ccp_agent)

  ccp_agent_config m_cfg;

  uvm_analysis_port #(ccp_wr_data_pkt_t )         ctrlwr_ap;
  uvm_analysis_port #(ccp_ctrl_pkt_t    )         ctrlstatus_ap;
  uvm_analysis_port #(ccp_ctrl_pkt_t    )         ctrlstatus_ap_p0;
  uvm_analysis_port #(ccp_filldata_pkt_t )        cachefilldata_ap;
  uvm_analysis_port #(ccp_filldata_pkt_t )        cachefilldata_before_done_ap;
  uvm_analysis_port #(ccp_fillctrl_pkt_t )        cachefillctrl_ap;
  uvm_analysis_port #(fill_addr_inflight_t )      cachefilldone_ap;
  uvm_analysis_port #(ccp_cachefill_seq_item)     cachefillmiss_ap;
  uvm_analysis_port #(ccp_evict_pkt_t   )         cacheevict_ap;
  uvm_analysis_port #(ccp_rd_rsp_pkt_t  )         cacherdrsp_ap;
  uvm_analysis_port #(ccp_rd_rsp_pkt_t  )         cacherdrsp_per_beat_ap;
  uvm_analysis_port #(ccp_csr_maint_pkt_t)        csr_maint_ap;
  uvm_analysis_port #(cache_rtl_pkt)              cbi_req_ap;

  uvm_analysis_port #(ccp_sp_ctrl_pkt_t)          sp_ctrlstatus_ap;
  uvm_analysis_port #(ccp_sp_wr_pkt_t)            sp_input_ap;
  uvm_analysis_port #(ccp_sp_output_pkt_t)        sp_output_ap;

  ccp_monitor                m_monitor;
/*
  ccp_ctrlstatus_driver      m_ctrlstatus_driver;
  ccp_cachefill_driver       m_cachefill_driver;
  ccp_csr_maint_driver       m_csr_maint_driver;

  ccp_ctrlstatus_sequencer   m_ctrlstatus_sqr;
  ccp_cachefill_sequencer    m_cachefill_sqr;
  ccp_csr_maint_sequencer    m_csr_maint_sqr;
*/
  extern function new(string name = "ccp_agent", uvm_component parent = null);
  extern function void build_phase(uvm_phase phase);
  extern function void connect_phase(uvm_phase phase);

endclass: ccp_agent

//------------------------------------------------------------------------------
// Constructor
//------------------------------------------------------------------------------
function ccp_agent::new(string name = "ccp_agent", uvm_component parent = null);
  super.new(name, parent);
endfunction : new

//------------------------------------------------------------------------------
// Build Phase
//------------------------------------------------------------------------------
function void ccp_agent::build_phase(uvm_phase phase);
  if (!uvm_config_db#(ccp_agent_config)::get(.cntxt( this ), 
                                             .inst_name ( "" ), 
                                             .field_name( "ccp_agent_config" ),
                                             .value( m_cfg ))) begin
    `uvm_error( "ccp_agent", "ccp_agent_config not found" )
  end

  m_monitor = ccp_monitor::type_id::create("m_monitor", this);
/*
  if(m_cfg.active == UVM_ACTIVE) begin
    m_ctrlstatus_driver = ccp_ctrlstatus_driver::type_id::create("m_ctrlstatus_driver",this);
    m_cachefill_driver  = ccp_cachefill_driver::type_id::create("m_cachefill_driver",this);
    m_csr_maint_driver  = ccp_csr_maint_driver::type_id::create("m_csr_maint_driver",this);

    m_ctrlstatus_sqr    = ccp_ctrlstatus_sequencer::type_id::create("m_ctrlstatus_sqr", this);
    m_cachefill_sqr     = ccp_cachefill_sequencer::type_id::create("m_cachefill_sqr", this);
    m_csr_maint_sqr     = ccp_csr_maint_sequencer::type_id::create("m_csr_maint_sqr", this);

  end
*/
endfunction: build_phase

//------------------------------------------------------------------------------
// Connect Phase
//------------------------------------------------------------------------------
function void ccp_agent::connect_phase(uvm_phase phase);
   super.connect_phase(phase);
   m_monitor.m_vif        = m_cfg.m_vif;
   m_monitor.delay_export = m_cfg.delay_export;

    ctrlwr_ap                    = m_monitor.ctrlwr_ap;
    ctrlstatus_ap                = m_monitor.ctrlstatus_ap;
    ctrlstatus_ap_p0             = m_monitor.ctrlstatus_ap_p0;
    cachefilldata_ap             = m_monitor.cachefilldata_ap ;
    cachefilldata_before_done_ap = m_monitor.cachefilldata_before_done_ap ;
    cachefillctrl_ap             = m_monitor.cachefillctrl_ap ;
    cachefilldone_ap             = m_monitor.cachefilldone_ap ;
    cachefillmiss_ap             = m_monitor.cachefillmiss_ap;
    cacheevict_ap                = m_monitor.cacheevict_ap;
    cacherdrsp_ap                = m_monitor.cacherdrsp_ap;
    cacherdrsp_per_beat_ap       = m_monitor.cacherdrsp_per_beat_ap;
    csr_maint_ap                 = m_monitor.csr_maint_ap;
    cbi_req_ap                   = m_monitor.cbi_req_ap;

    sp_ctrlstatus_ap             = m_monitor.sp_ctrlstatus_ap;
    sp_input_ap                  = m_monitor.sp_input_ap;
    sp_output_ap                 = m_monitor.sp_output_ap;

/*  
  if(m_cfg.active == UVM_ACTIVE) begin
    
    m_cfg.m_vif.FILL_IF_DELAY_MIN         = m_cfg.k_fill_if_delay_min;        
    m_cfg.m_vif.FILL_IF_DELAY_MAX         = m_cfg.k_fill_if_delay_max;        
    m_cfg.m_vif.FILL_IF_BURST_PCT         = m_cfg.k_fill_if_delay_pct;        

    m_ctrlstatus_driver.seq_item_port.connect(m_ctrlstatus_sqr.seq_item_export);
    m_ctrlstatus_driver.m_vif = m_cfg.m_vif;
    m_ctrlstatus_sqr.set_arbitration(SEQ_ARB_STRICT_RANDOM);

    m_cachefill_driver.seq_item_port.connect(m_cachefill_sqr.seq_item_export);
    m_cachefill_driver.m_vif = m_cfg.m_vif;
    m_cachefill_sqr.set_arbitration(SEQ_ARB_STRICT_RANDOM);
  
    m_csr_maint_driver.seq_item_port.connect(m_csr_maint_sqr.seq_item_export);
    m_csr_maint_driver.m_vif = m_cfg.m_vif;
    m_csr_maint_sqr.set_arbitration(SEQ_ARB_STRICT_RANDOM);

    m_monitor.cachefillmiss_ap.connect(m_cachefill_sqr.m_cachefill_export);
    m_monitor.cachefilldone_ap.connect( m_ctrlstatus_sqr.m_cachefillctrl_export);
    m_monitor.ctrlstatus_ap.connect( m_ctrlstatus_sqr.m_cachectrlstatus_export);
  end
*/
endfunction: connect_phase
