class chi_subsys_directed_atomic_test extends chi_subsys_base_test;

	`uvm_component_utils(chi_subsys_directed_atomic_test)
	chi_subsys_directed_atomic_vseq m_atomic_vseq;

	function new(string name ="chi_subsys_directed_atomic_test",uvm_component parent = null);
	super.new(name,parent);
	endfunction


	function void build_phase(uvm_phase phase);
	super.build_phase(phase);
	m_atomic_vseq = chi_subsys_directed_atomic_vseq::type_id::create("m_atomic_vseq");
	endfunction


	task start_sequence();
	fork
	<%for(let idx = 0; idx < obj.nCHIs; idx++) { %>
	m_atomic_vseq.rn_xact_seqr<%=idx%> = m_concerto_env.snps.svt.amba_system_env.chi_system[0].rn[<%=idx%>].rn_xact_seqr;
	<%}%>
	`uvm_info(get_name(), "Starting chi_subsys_directed_atomic_test", UVM_NONE)
	 m_atomic_vseq.start(m_concerto_env.snps.svt.amba_system_env.chi_system[0].virt_seqr);
	`uvm_info(get_name(), "Done chi_subsys_directed_atomic_test", UVM_NONE)
	join
	endtask 

	task run_phase(uvm_phase phase);
	super.run_phase(phase);
	endtask
endclass

