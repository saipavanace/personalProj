class chi_subsys_directed_atomic_vseq extends chi_subsys_random_vseq;

`uvm_object_utils(chi_subsys_directed_atomic_vseq)

	<%for(let idx = 0; idx < obj.nCHIs; idx++) { %>
	chi_subsys_directed_atomic_seq m_atomic_seq<%=idx%>;
	<%}%>
	
	function new(string name = "chi_subsys_directed_atomic_vseq");
	super.new(name);
	<%for(let idx = 0; idx < obj.nCHIs; idx++) { %>
	  m_atomic_seq<%=idx%> = chi_subsys_directed_atomic_seq::type_id::create("m_atomic_seq<%=idx%>");
	<%}%>
	to_execute_body_method_of_chi_subsys_random_vseq = 0;
	endfunction 
	
	virtual task body();
	super.body();
	fork
	<%for(let idx = 0; idx < obj.nCHIs; idx++) { %>
	begin
	   repeat(chi_num_trans) begin
		m_atomic_seq<%=idx%>.disable_all_weights();
		m_atomic_seq<%=idx%>.atomicstore_set_wt = 1;
		m_atomic_seq<%=idx%>.atomicload_umax_wt = 1;
		m_atomic_seq<%=idx%>.atomicload_add_wt = 1;
		m_atomic_seq<%=idx%>.start(rn_xact_seqr<%=idx%>);
 	   end
	end
	<%}%>
	join
	endtask
endclass

