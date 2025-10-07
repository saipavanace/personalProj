class chi_subsys_snp_seq extends chi_subsys_base_seq;
	`svt_xvm_object_utils(chi_subsys_snp_seq)
    	`svt_xvm_declare_p_sequencer(svt_chi_rn_transaction_sequencer)

		function new(string name = "chi_subsys_snp_seq");
		   super.new(name);
		   use_directed_addr = 1;
		endfunction

		virtual task body();
        	         super.body();
    		endtask: body

endclass





