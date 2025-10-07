class chi_subsys_error_seq extends chi_subsys_base_seq;
	`svt_xvm_object_utils(chi_subsys_error_seq)
    	`svt_xvm_declare_p_sequencer(svt_chi_rn_transaction_sequencer)

		function new(string name = "chi_subsys_error_seq");
		   super.new(name);
		   use_directed_addr = 0;
        	   use_directed_mem_attr = 0;
       		   use_directed_non_secure_access = 0;
        	   use_directed_snp_attr = 0;
       		   use_seq_order_type = 0;
      		   if ($test$plusargs("en_ext_silent_txn")) blocking_mode = 1;
		endfunction

		virtual task body();
        		 enable_all_weights();
        	       	 reqlinkflit_wt = 0;
       			 disable_dvmop = 1;
        	    super.body();
    		endtask: body

               
endclass

