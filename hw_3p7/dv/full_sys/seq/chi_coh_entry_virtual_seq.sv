class chi_coh_entry_virtual_seq extends uvm_sequence;
`uvm_object_param_utils(chi_coh_entry_virtual_seq)

  <% var idx = 0; %>
  <% for(pidx = 0; pidx < obj.nAIUs; pidx++) { %>
    <% if(obj.AiuInfo[pidx].fnNativeInterface.match("CHI")) { %>
      svt_chi_protocol_service_sequencer coh_entry_seqr<%=idx%>;
        svt_chi_node_configuration  node_cfg<%=idx%>;
        svt_chi_protocol_service_coherency_entry_sequence coherency_entry_seq<%=idx%>;
    <% idx++; %>
    <%} %>
  <% } %>

  concerto_env	m_concerto_env;

function new(string name = "chi_coh_entry_virtual_seq");

    super.new(name);

endfunction


task body();

//Create and Initialize Sequences
  <% var idx=0; %>
  <% for(pidx = 0; pidx < obj.nAIUs; pidx++) { %>
    <% if(obj.AiuInfo[pidx].fnNativeInterface.match("CHI")) { %>
        coherency_entry_seq<%=idx%> = svt_chi_protocol_service_coherency_entry_sequence::type_id::create("coherency_entry_seq<%=idx%>");
        coherency_entry_seq<%=idx%>.node_cfg = node_cfg<%=idx%>;
    <% idx++; %>
    <%} %>
    <%} %>

    fork
  <% var idx = 0; %>
  <% for(pidx = 0; pidx < obj.nAIUs; pidx++) { %>
    <% if(obj.AiuInfo[pidx].fnNativeInterface.match("CHI")) { %>
    begin
        `uvm_info(get_name(), "USE_VIP_SNPS coherency_entry_seq::START[<%=idx%>]", UVM_NONE)
        coherency_entry_seq<%=idx%>.randomize();
        begin
        wait (m_concerto_env.snps.svt.amba_system_env.chi_system[0].rn[<%=idx%>].shared_status.sysco_interface_state == svt_chi_status::COHERENCY_DISABLED_STATE);   
        `uvm_info(get_name(), "USE_VIP_SNPS coherency_entry_seq::ONGOING[<%=idx%>]", UVM_NONE)
        #50ns;// add time to avoid conflict with construct_lnk_seq & reset
        fork:entry_seq<%=idx%>
        coherency_entry_seq<%=idx%>.start(coh_entry_seqr<%=idx%>);
        join_none:entry_seq<%=idx%>
        end
         `uvm_info(get_name(), "USE_VIP_SNPS coherency_entry_seq::WAIT[<%=idx%>] COHERENCY_ENABLE", UVM_NONE)
         wait(m_concerto_env.snps.svt.amba_system_env.chi_system[0].rn[<%=idx%>].shared_status.sysco_interface_state == svt_chi_status::COHERENCY_ENABLED_STATE);
         `uvm_info(get_name(), "USE_VIP_SNPS coherency_entry_seq::END[<%=idx%>]", UVM_NONE)
         disable entry_seq<%=idx%>;// issue in the service sequencer 
        //#(coherency_entry_seq<%=idx%>.delay_in_ns*1ns);
        //csr_init_done.wait_trigger();
        //`uvm_info("TEST MAIN", "Done - waiting for csr_init_done trigger", UVM_NONE)
        //tb_top.release_sysco_req = 1;
    end
    <% idx++; %>
    <%} %>
  <% } %>
    join_none


endtask: body

endclass: chi_coh_entry_virtual_seq
