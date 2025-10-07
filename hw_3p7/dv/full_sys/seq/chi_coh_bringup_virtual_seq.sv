class chi_coh_bringup_virtual_seq extends uvm_sequence;
`uvm_object_param_utils(chi_coh_bringup_virtual_seq)

  chi_linkup_virtual_seq	chi_linkup_vseq;
  chi_coh_entry_virtual_seq	chi_coh_entry_vseq;

  chi_coh_bringup_virtual_seqr coh_vseqr;


function new(string name = "chi_coh_bringup_virtual_seq");

  super.new(name);

  //Create Virtual sequences
  chi_linkup_vseq = chi_linkup_virtual_seq::type_id::create("chi_linkup_vseq");
  chi_coh_entry_vseq = chi_coh_entry_virtual_seq::type_id::create("chi_coh_entry_vseq");

endfunction
  

task body();


//Initialize 

  <% var idx = 0; %>
  <% for(pidx = 0; pidx < obj.nAIUs; pidx++) { %>
    <% if(obj.AiuInfo[pidx].fnNativeInterface.match("CHI")) { %>
      `uvm_info(get_name(), "USE_VIP_SNPS Initialise chi_linkup_vseq.link_up_seqr<%=idx%>", UVM_LOW)
       chi_linkup_vseq.link_up_seqr<%=idx%> = coh_vseqr.link_up_seqr<%=idx%>;
      <% if(obj.AiuInfo[pidx].interfaces.eventRequestOutInt._SKIP_ == false || obj.AiuInfo[pidx].interfaces.eventRequestInInt._SKIP_ == false) { %>
      `uvm_info(get_name(), "USE_VIP_SNPS INIT chi_linkup_vseq.event_seqr<%=idx%> ", UVM_LOW)
       chi_linkup_vseq.event_seqr<%=idx%> = coh_vseqr.event_seqr<%=idx%>;
      <% } %> 
      `uvm_info(get_name(), "USE_VIP_SNPS INIT chi_coh_entry_vseq.coh_entry_seqr<%=idx%>", UVM_NONE)
      chi_coh_entry_vseq.coh_entry_seqr<%=idx%> = coh_vseqr.coh_entry_seqr<%=idx%>;
      chi_coh_entry_vseq.node_cfg<%=idx%> = coh_vseqr.node_cfg<%=idx%>;
    <% idx++; %>
    <%} %>
  <% } %>


chi_coh_entry_vseq.m_concerto_env = coh_vseqr.m_concerto_env;

//Starting Virtual Sequences
chi_linkup_vseq.start(null);
chi_coh_entry_vseq.start(null);


endtask: body

endclass: chi_coh_bringup_virtual_seq
