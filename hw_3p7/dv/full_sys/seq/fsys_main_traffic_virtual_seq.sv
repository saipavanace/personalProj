`ifdef CHI_UNITS_CNT_NON_ZERO
import chi_subsys_pkg::*;
`endif


class fsys_main_traffic_virtual_seq extends uvm_sequence;
`uvm_object_utils(fsys_main_traffic_virtual_seq)

  concerto_env  m_concerto_env;
  concerto_env_cfg m_concerto_env_cfg;
  concerto_test_cfg test_cfg;

  // CHI SNPS FSYS virtual sequence
  `ifdef CHI_UNITS_CNT_NON_ZERO
    chi_traffic_snps_virtual_seq chi_traffic_snps_vseq;
  `endif

  // IOAIU SUBSYSTEM VIRTUAL SEQUENCE
  `ifdef IO_UNITS_CNT_NON_ZERO
    io_subsys_vseq ioaiu_traffic_vseq;
  `endif

    //INHOUSE CHI SEQ
    <% var qidx=0; var idx=0; for(var pidx = 0 ; pidx < obj.nAIUs; pidx++) { %>
      <% if(obj.AiuInfo[pidx].fnNativeInterface.match("CHI")) { %>
           //sys_event agent seq
    <% if(obj.AiuInfo[pidx].interfaces.eventRequestOutInt._SKIP_ == false || obj.AiuInfo[pidx].interfaces.eventRequestInInt._SKIP_ == false) { %>
        chiaiu<%=idx%>_event_agent_pkg::event_seq  m_chi<%=idx%>_event_seq;
    <% } %>         
	   <%  idx++;   %>
       <% } else { %>
<%  qidx++; } %>
    <% } %>
    // END INHOUSE CHI SEQ 

  int no_snoop_seq;


function new(string name = "fsys_main_traffic_virtual_seq");

  super.new(name);
  if(!(uvm_config_db #(concerto_env)::get(uvm_root::get(), "", "m_env", m_concerto_env)))begin
       `uvm_fatal(get_full_name(), "Could not find concerto_env_cfg object in UVM Config DB");
  end

  if(!(uvm_config_db #(concerto_env_cfg)::get(uvm_root::get(), "", "m_cfg", m_concerto_env_cfg)))begin
      `uvm_fatal(get_full_name(), "Could not find concerto_env_cfg object in UVM Config DB");
  end   

  if(!(uvm_config_db #(concerto_test_cfg)::get(uvm_root::get(), "", "test_cfg", test_cfg)))begin
      `uvm_fatal(get_full_name(), "Could not find concerto_test_cfg object in UVM Config DB");
  end 

  `ifdef CHI_UNITS_CNT_NON_ZERO
    if (m_concerto_env_cfg.has_chi_vip_snps)begin:_chi_snps_vip
       chi_traffic_snps_vseq = chi_traffic_snps_virtual_seq::type_id::create("chi_traffic_snps_vseq");
       chi_traffic_snps_vseq.coh_vseqr = m_concerto_env.snps.coh_vseqr;
    end:_chi_snps_vip
  `endif

  `ifdef IO_UNITS_CNT_NON_ZERO
     ioaiu_traffic_vseq = io_subsys_vseq::type_id::create("ioaiu_traffic_vseq");
     ioaiu_traffic_vseq.init_vseq((m_concerto_env_cfg.has_axi_vip_snps == 1) ? m_concerto_env.snps.svt.amba_system_env.axi_system[0].sequencer : null);
  `endif

   //sys_event agent seq
    <% var idx=0; for(var pidx = 0; pidx < obj.nAIUs; pidx++) { %>
    <% if(obj.AiuInfo[pidx].fnNativeInterface.match("CHI")) { %>
         <% if(obj.AiuInfo[pidx].interfaces.eventRequestOutInt._SKIP_ == false || obj.AiuInfo[pidx].interfaces.eventRequestInInt._SKIP_ == false) { %>
         m_chi<%=idx%>_event_seq =  chiaiu<%=idx%>_event_agent_pkg::event_seq::type_id::create("m_chi<%=idx%>_event_seq");
        <% } %> 
    <% idx++;  %>
   <%} %>
   <%} %>


endfunction


task body();
      foreach(test_cfg.chiaiu_en[i]) begin
         `uvm_info("fsys_main_traffic_virtual_seq", $sformatf("test_cfg.chiaiu_en[%0d] = %0d", i, test_cfg.chiaiu_en[i]), UVM_MEDIUM)
      end
      foreach(test_cfg.ioaiu_en[i]) begin
         `uvm_info("fsys_main_traffic_virtual_seq", $sformatf("test_cfg.ioaiu_en[%0d] = %0d", i, test_cfg.ioaiu_en[i]), UVM_MEDIUM)
      end

      fork:_start_all_seq
        begin
          if (m_concerto_env_cfg.has_chi_vip_snps)begin:_chiaiu_vip
            `ifdef CHI_UNITS_CNT_NON_ZERO
              `uvm_info("FULLSYS_TEST", "START: chi_traffic_snps_vseq CHI Main Traffic FSYS Virtual Sequence", UVM_NONE)
              foreach (test_cfg.chiaiu_en[i]) begin
                 chi_traffic_snps_vseq.chiaiu_en[i] = test_cfg.chiaiu_en[i];
              end
              chi_traffic_snps_vseq.chi_num_trans = test_cfg.chi_num_trans;
              chi_traffic_snps_vseq.start(null);
              `uvm_info("FULLSYS_TEST", "END: chi_traffic_snps_vseq CHI Main Traffic FSYS Virtual Sequence", UVM_NONE)
            `endif
          end:_chiaiu_vip
        end

        <% var idx = 0; %>
        <% for(pidx = 0; pidx < obj.nAIUs; pidx++) { %>
          <% if(obj.AiuInfo[pidx].fnNativeInterface.match("CHI")) { %>
          begin
                    #10ns;
                     //sys_event agent seq
                    <% if(obj.AiuInfo[pidx].interfaces.eventRequestInInt._SKIP_ == false) { %>
                    `uvm_info(get_name(), "START chiaiu<%=idx%> EVENT SEQ ", UVM_LOW)
                      m_chi<%=idx%>_event_seq.start(m_concerto_env.inhouse.m_chiaiu<%=idx%>_env.m_event_agent.m_sequencer);
                     `uvm_info(get_name(), "END chiaiu<%=idx%> EVENT SEQ ", UVM_LOW)
                    <% } %> 
          end
          <% idx++; %>
          <%} %>
        <% } %>

        `ifdef IO_UNITS_CNT_NON_ZERO
            if (!m_concerto_env_cfg.has_axi_vip_snps ) begin
              ioaiu_traffic_vseq.inhouse_vseq.no_snoop_seq = no_snoop_seq;
            end
            `uvm_info(get_name(), "Starting IOAIU Traffic vseq", UVM_LOW)
            ioaiu_traffic_vseq.ioaiu_num_trans = test_cfg.ioaiu_num_trans;
            ioaiu_traffic_vseq.start(null);
            `uvm_info(get_name(), "Finished IOAIU Traffic vseq", UVM_LOW)
        `endif

      join:_start_all_seq

endtask: body

endclass: fsys_main_traffic_virtual_seq
