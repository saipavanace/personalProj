////////////////////////////////////////////////////////////////////////////////
//
// SMI Sequencer
<% if (1 == 0) { %>
// Author: Chirag Gandhi
<% } %>
//
////////////////////////////////////////////////////////////////////////////////
class smi_sequencer extends uvm_sequencer #(smi_seq_item);

    `uvm_component_param_utils(smi_sequencer)

    //uvm_analysis_export   #(smi_seq_item) m_rx_analysis_port;
    uvm_tlm_analysis_fifo #(smi_seq_item) m_rx_analysis_fifo;

    function new(string name="smi_sequencer", uvm_component parent = null);
        super.new(name, parent);
        //m_rx_analysis_port = new("m_rx_analysis_port", this);
        m_rx_analysis_fifo = new("m_rx_analysis_fifo", this);
    endfunction : new

    function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);
        //m_rx_analysis_port.connect(m_rx_analysis_fifo.analysis_export);
    endfunction : connect_phase
endclass: smi_sequencer
