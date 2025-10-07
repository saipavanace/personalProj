typedef class concerto_env;
class chi_coh_bringup_virtual_seqr extends uvm_sequencer #(uvm_sequence_item);
`uvm_component_utils(chi_coh_bringup_virtual_seqr)

  <% var idx = 0; %>
  <% for(pidx = 0; pidx < obj.nAIUs; pidx++) { %>
    <%if((obj.AiuInfo[pidx].fnNativeInterface == 'CHI-A')||(obj.AiuInfo[pidx].fnNativeInterface == 'CHI-B' || obj.AiuInfo[pidx].fnNativeInterface == 'CHI-E')) { %>
       svt_chi_link_service_sequencer  link_up_seqr<%=idx%>;
      <% if(obj.AiuInfo[pidx].interfaces.eventRequestOutInt._SKIP_ == false || obj.AiuInfo[pidx].interfaces.eventRequestInInt._SKIP_ == false) { %>
       chiaiu<%=idx%>_event_agent_pkg::event_sequencer event_seqr<%=idx%>;
      <% } %> 
    <% idx++; %>
    <%} %>
  <% } %>

  <% var idx = 0; %>
  <% for(pidx = 0; pidx < obj.nAIUs; pidx++) { %>
    <%if(obj.AiuInfo[pidx].fnNativeInterface.match("CHI")) { %>
      svt_chi_protocol_service_sequencer coh_entry_seqr<%=idx%>;
    <% idx++; %>
    <%} %>
  <% } %>

  <% var idx=0; %>
  <% for(pidx = 0; pidx < obj.nAIUs; pidx++) { %>
    <%if((obj.AiuInfo[pidx].fnNativeInterface == 'CHI-A')||(obj.AiuInfo[pidx].fnNativeInterface == 'CHI-B' || obj.AiuInfo[pidx].fnNativeInterface == 'CHI-E')) { %>
      <% if(obj.AiuInfo[pidx].fnNativeInterface == 'CHI-B' || obj.AiuInfo[pidx].fnNativeInterface == 'CHI-E') { %>
        svt_chi_node_configuration  node_cfg<%=idx%>;
      <% } %>
    <% idx++; %>
    <%} %>
    <%} %>

  <% var idx = 0; %>
  <% for(pidx = 0; pidx < obj.nAIUs; pidx++) { %>
    <%if((obj.AiuInfo[pidx].fnNativeInterface == 'CHI-A')||(obj.AiuInfo[pidx].fnNativeInterface == 'CHI-B' || obj.AiuInfo[pidx].fnNativeInterface == 'CHI-E')) { %>
       svt_chi_rn_transaction_sequencer rn_xact_seqr<%=idx%>;
       svt_axi_cache rn_cache<%=idx%>;
    <% idx++; %>
    <%} %>
  <% } %>

  svt_chi_system_virtual_sequencer svt_chi_system_vseqr;

  concerto_env	m_concerto_env;

function new(string name = "chi_coh_bringup_virtual_seqr", uvm_component parent);

  super.new(name, parent);

endfunction
  
endclass: chi_coh_bringup_virtual_seqr
