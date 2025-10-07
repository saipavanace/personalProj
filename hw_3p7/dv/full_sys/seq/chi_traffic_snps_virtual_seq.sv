`ifdef CHI_UNITS_CNT_NON_ZERO
import chi_subsys_pkg::*;
`endif


class chi_traffic_snps_virtual_seq extends uvm_sequence;
`uvm_object_param_utils(chi_traffic_snps_virtual_seq)

  `ifdef CHI_UNITS_CNT_NON_ZERO
    // CHI subsys virtual sequence
    chi_subsys_random_vseq svt_chi_rn_seq;
    int chi_num_trans;
    int init_all_cache;
    int init_from_chiaiu_idx = 0;
    int chiaiu_en[int];
  `endif

  chi_coh_bringup_virtual_seqr coh_vseqr;

  static uvm_event_pool ev_pool  = uvm_event_pool::get_global_pool();

  <% var qidx=0;var idx=0; for(var pidx = 0; pidx < obj.nAIUs; pidx++) { %>
    <% if(obj.AiuInfo[pidx].fnNativeInterface.match("CHI")) { %>
    static uvm_event done_svt_chi_rn_seq_h<%=idx%> = ev_pool.get("done_svt_chi_rn_seq_h<%=idx%>");
  <% idx++; } else {%>
  <% qidx++; } } %>



function new(string name = "chi_traffic_snps_virtual_seq");

  super.new(name);
  `ifdef CHI_UNITS_CNT_NON_ZERO
    svt_chi_rn_seq = chi_subsys_random_vseq::type_id::create("svt_chi_rn_seq");
  `endif

endfunction


task body();

  `ifdef CHI_UNITS_CNT_NON_ZERO
    <% var cidx = 0; %>
    <% for(var idx = 0; idx < obj.nAIUs; idx++) {
     if(obj.AiuInfo[idx].fnNativeInterface.match('CHI')) { %>
    svt_chi_rn_seq.m_random_seq<%=cidx%>.rn_cache = coh_vseqr.rn_cache<%=cidx%>;
    <%cidx++;}}%>
  
    svt_chi_rn_seq.set_txn_count(chi_num_trans);
    svt_chi_rn_seq.init_all_cache = init_all_cache;
    foreach (chiaiu_en[i]) begin
        svt_chi_rn_seq.chiaiu_en[i] = chiaiu_en[i];
    end
    
    <%for(let idx = 0; idx < obj.nCHIs; idx++) { %>
       svt_chi_rn_seq.rn_xact_seqr<%=idx%> = coh_vseqr.rn_xact_seqr<%=idx%>;
    <%}%>

    // start the CHI subsys virtual sequence
    chi_ss_helper_pkg::k_disable_boot_addr = 1;
    //chi_ss_helper_pkg::k_directed_lpid = 0;

    if(!($test$plusargs("use_dvm"))) begin
      svt_chi_rn_seq.disable_dvmop = 1;
    end

    `uvm_info("FULLSYS_TEST", "Start CHIAIU VSEQ", UVM_NONE)
    svt_chi_rn_seq.start(coh_vseqr.svt_chi_system_vseqr);
    `uvm_info("FULLSYS_TEST", "End of CHIAIU VSEQ", UVM_NONE)
  `endif

  <%for(let idx = 0; idx < obj.nCHIs; idx++) { %>
      done_svt_chi_rn_seq_h<%=idx%>.trigger(null);
  <%}%>
  
  <%if(obj.nCHIs > 0) { %>
  if( init_all_cache > 0 ) begin
    done_svt_chi_rn_seq_h0.reset();
  end
  <%}%>

endtask: body

endclass: chi_traffic_snps_virtual_seq
