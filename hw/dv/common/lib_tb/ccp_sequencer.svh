
////////////////////////////////////////////////////////////////////////////////
//
// CSR MAINTENANCE Sequencer
//
////////////////////////////////////////////////////////////////////////////////
class ccp_csr_maint_sequencer extends uvm_sequencer #(ccp_csr_maint_seq_item);

  `uvm_component_param_utils(ccp_csr_maint_sequencer)

//------------------------------------------------------------------------------
// Constructor
//------------------------------------------------------------------------------
function new(string name="ccp_csr_maint_sequencer", uvm_component parent = null);
  super.new(name, parent);
endfunction : new

endclass: ccp_csr_maint_sequencer

////////////////////////////////////////////////////////////////////////////////
//
// CTRL AND STATUS Sequencer
//
////////////////////////////////////////////////////////////////////////////////
class ccp_ctrlstatus_sequencer extends uvm_sequencer #(ccp_ctrlstatus_seq_item);

  `uvm_component_param_utils(ccp_ctrlstatus_sequencer)

   uvm_analysis_export      #(fill_addr_inflight_t)      m_cachefillctrl_export;
   uvm_tlm_analysis_fifo    #(fill_addr_inflight_t)      m_cachefillctrl_fifo;
   uvm_analysis_export      #(ccp_ctrl_pkt_t)            m_cachectrlstatus_export;
   uvm_tlm_analysis_fifo    #(ccp_ctrl_pkt_t)            m_cachectrlstatus_fifo;
//------------------------------------------------------------------------------
// Constructor
//------------------------------------------------------------------------------
function new(string name="ccp_ctrlstatus_sequencer", uvm_component parent = null);
  super.new(name, parent);
     m_cachefillctrl_export   = new("m_cachefillctrl_export",this);
     m_cachefillctrl_fifo     = new("m_cachefillctrl_fifo",this);
     m_cachectrlstatus_export = new("m_cachectrlstatus_export",this);
     m_cachectrlstatus_fifo   = new("m_cachectrlstatus_fifo",this);
endfunction : new

function void connect_phase(uvm_phase phase);
   super.connect_phase(phase);
   m_cachefillctrl_export.connect(m_cachefillctrl_fifo.analysis_export);
   m_cachectrlstatus_export.connect(m_cachectrlstatus_fifo.analysis_export);
endfunction: connect_phase
endclass: ccp_ctrlstatus_sequencer


////////////////////////////////////////////////////////////////////////////////
//
// CACHE FILL Sequencer
//
////////////////////////////////////////////////////////////////////////////////
class ccp_cachefill_sequencer extends uvm_sequencer #(ccp_cachefill_seq_item);

  `uvm_component_param_utils(ccp_cachefill_sequencer)
  
   uvm_analysis_export      #(ccp_cachefill_seq_item)  m_cachefill_export;
   uvm_tlm_analysis_fifo    #(ccp_cachefill_seq_item)  m_cachefill_fifo;

//------------------------------------------------------------------------------
// Constructor
//------------------------------------------------------------------------------
function new(string name="ccp_cachefill_sequencer", uvm_component parent = null);
  super.new(name, parent);
     m_cachefill_export = new("m_cachefill_export",this);
     m_cachefill_fifo   = new("m_cachefill_fifo",this);
endfunction : new


function void connect_phase(uvm_phase phase);
   super.connect_phase(phase);
   m_cachefill_export.connect(m_cachefill_fifo.analysis_export);
endfunction: connect_phase
endclass: ccp_cachefill_sequencer

