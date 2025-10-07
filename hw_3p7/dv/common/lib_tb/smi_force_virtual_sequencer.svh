
<%  if(obj.BlockId.match('chiaiu')) { %>
`ifdef CHI_SUBSYS

class <%=obj.BlockId%>_smi_force_virtual_sequencer extends uvm_sequencer #(smi_seq_item);
    `uvm_component_param_utils(<%=obj.BlockId%>_smi_force_virtual_sequencer)

    <% var NSMIIFTX = obj.nSmiRx;
    for (var i = 0; i < NSMIIFTX; i++) { %>
         virtual <%=obj.BlockId + '_smi_if'%>     m_<%=i%>_vif;
         smi_sequencer                            m_smi<%=i%>_tx_seqr;
    <% } %>

    virtual chi_aiu_dut_probe_if m_<%=obj.BlockId%>_probe_vif;

    function new(string name="<%=obj.BlockId%>_smi_force_virtual_sequencer", uvm_component parent = null);
        super.new(name, parent);
    endfunction : new

   function void build_phase(uvm_phase phase);
        super.build_phase(phase);
            if (!uvm_config_db #(virtual chi_aiu_dut_probe_if)::get(
            .cntxt(this),
            .inst_name(""),
            .field_name("m_<%=obj.BlockId%>_chi_aiu_dut_probe_if"),
            .value(m_<%=obj.BlockId%>_probe_vif))) begin
            `uvm_fatal(get_name(), "unable to find probe chi vif in configuration db")
            end
    endfunction : build_phase

endclass: <%=obj.BlockId%>_smi_force_virtual_sequencer
`endif
<% } %>
