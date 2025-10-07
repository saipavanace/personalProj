//typedef class event_sequencer;

class chi_linkup_virtual_seq extends uvm_sequence;
`uvm_object_param_utils(chi_linkup_virtual_seq)

  <% var idx = 0; %>
  <% for(pidx = 0; pidx < obj.nAIUs; pidx++) { %>
    <%if (obj.AiuInfo[pidx].fnNativeInterface.match("CHI")) { %>
       svt_chi_link_service_sequencer  link_up_seqr<%=idx%>;
       svt_chi_link_service_activate_sequence svt_chi_link_up_seq_h<%=idx%>;
      <% if(obj.AiuInfo[pidx].interfaces.eventRequestOutInt._SKIP_ == false || obj.AiuInfo[pidx].interfaces.eventRequestInInt._SKIP_ == false) { %>
       chiaiu<%=idx%>_event_agent_pkg::event_sequencer event_seqr<%=idx%>;
       chiaiu<%=idx%>_event_agent_pkg::event_seq  m_chi<%=idx%>_event_seq;
      <% } %> 
    <% idx++; %>
    <%} %>
  <% } %>


function new(string name = "chi_linkup_virtual_seq");

    super.new(name);

endfunction


task body();

  <% var idx=0; %>
  <% for(pidx = 0; pidx < obj.nAIUs; pidx++) { %>
    <% if(obj.AiuInfo[pidx].fnNativeInterface.match("CHI")) { %>
     `uvm_info(get_name(), "USE_VIP_SNPS svt_chi_link_service_sequence::CREATE[<%=idx%>]", UVM_NONE)
      svt_chi_link_up_seq_h<%=idx%> = svt_chi_link_service_activate_sequence::type_id::create("svt_chi_link_up_seq_h<%=idx%>");
    <% if(obj.AiuInfo[pidx].interfaces.eventRequestOutInt._SKIP_ == false || obj.AiuInfo[pidx].interfaces.eventRequestInInt._SKIP_ == false) { %>
        m_chi<%=idx%>_event_seq =  chiaiu<%=idx%>_event_agent_pkg::event_seq::type_id::create("m_chi<%=idx%>_event_seq");
    <% } %> 
    <% idx++; %>
    <%} %>
    <%} %>

 fork
  <% var idx = 0; %>
  <% for(pidx = 0; pidx < obj.nAIUs; pidx++) { %>
    <% if(obj.AiuInfo[pidx].fnNativeInterface.match("CHI")) { %>
    begin
        `uvm_info(get_name(), "USE_VIP_SNPS svt_chi_link_UP_service_sequence::START[<%=idx%>]", UVM_LOW)
         svt_chi_link_up_seq_h<%=idx%>.start(link_up_seqr<%=idx%>) ;
        `uvm_info(get_name(), "USE_VIP_SNPS svt_chi_link_UP_service_sequence::END[<%=idx%>]", UVM_LOW)
    end
    <% idx++; %>
    <%} %>
  <% } %>
    join


endtask: body

endclass: chi_linkup_virtual_seq
