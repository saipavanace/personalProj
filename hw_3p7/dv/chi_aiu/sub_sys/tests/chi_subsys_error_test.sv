//chi_subsys_error_injection_test

class chi_subsys_error_test extends chi_subsys_base_test;
	`uvm_component_utils(chi_subsys_error_test)

	chi_subsys_error_vseq m_error_vseq;

		function new(string name = "chi_subsys_error_test",uvm_component parent = null);
		super.new(name,parent);
		endfunction : new


		function void build_phase(uvm_phase phase);
		super.build_phase(phase);
		set_type_override_by_type(svt_chi_rn_transaction::get_type(),chi_subsys_force_error_item::get_type());//override seq_item
		set_type_override_by_type(svt_chi_rn_snoop_transaction::get_type(),chi_subsys_force_snoop_error_item::get_type());//override seq_item
		m_error_vseq = chi_subsys_error_vseq::type_id::create("m_error_vseq");
		endfunction: build_phase

		task start_sequence();
      		  fork
                     begin
                         <%for(let idx = 0; idx < obj.nCHIs; idx++) { %>
                    		m_error_vseq.rn_xact_seqr<%=idx%> = m_concerto_env.snps.svt.amba_system_env.chi_system[0].rn[<%=idx%>].rn_xact_seqr;
              		 <%}%>
                           `uvm_info(get_name(),"Starting chi_subsys_error_test",UVM_NONE)
                            m_error_vseq.start(m_concerto_env.snps.svt.amba_system_env.chi_system[0].virt_seqr);
                           `uvm_info(get_name(),"Done chi_subsys_error_test",UVM_NONE)
                     end
                  join
		endtask 

		task run_phase(uvm_phase phase);
		super.run_phase(phase);
		endtask:run_phase
endclass


