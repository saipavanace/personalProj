class chi_subsys_snp_test extends chi_subsys_base_test;	
	`uvm_component_utils(chi_subsys_snp_test)
	chi_subsys_snp_vseq m_snp_vseq;

		function new(string name = "chi_subsys_snp_test",uvm_component parent = null);
		super.new(name,parent);
		endfunction : new


		function void build_phase(uvm_phase phase);
		super.build_phase(phase);
		m_snp_vseq = chi_subsys_snp_vseq::type_id::create("m_error_vseq");
                set_type_override_by_type (svt_chi_rn_snoop_transaction::get_type(), chi_subsys_force_snoop_error_item::get_type());
		endfunction: build_phase

		task start_sequence();
      		  fork
                     begin
                         <%for(let idx = 0; idx < obj.nCHIs; idx++) { %>
                    		m_snp_vseq.rn_xact_seqr<%=idx%> = m_concerto_env.snps.svt.amba_system_env.chi_system[0].rn[<%=idx%>].rn_xact_seqr;
              		 <%}%>
                           `uvm_info(get_name(),"Starting chi_subsys_snp_test",UVM_NONE)
                            m_snp_vseq.start(m_concerto_env.snps.svt.amba_system_env.chi_system[0].virt_seqr);
                           `uvm_info(get_name(),"Done chi_subsys_snp_test",UVM_NONE)
                     end
                  join
		endtask 

		task run_phase(uvm_phase phase);
		super.run_phase(phase);
		endtask:run_phase
endclass






