////////////////////////////////////////////////////////////////////////////////
//
// SMI Virtual Sequencer
<% if (1 == 0) { %>
// Author: Chirag Gandhi
<% } %>
//
////////////////////////////////////////////////////////////////////////////////
class smi_virtual_sequencer extends uvm_sequencer #(smi_seq_item);

    `uvm_component_param_utils(smi_virtual_sequencer)

    <% var NSMIIFTX = obj.nSmiRx;
    for (var i = 0; i < NSMIIFTX; i++) { %>
        smi_sequencer m_smi<%=i%>_tx_seqr;
    <% } %>
    <% var NSMIIFRX = obj.nSmiTx;
    for (var i = 0; i < NSMIIFRX; i++) { %>
        smi_sequencer m_smi<%=i%>_rx_seqr;
    <% } %>

    function new(string name="smi_virtual_sequencer", uvm_component parent = null);
        super.new(name, parent);
    endfunction : new

endclass: smi_virtual_sequencer
