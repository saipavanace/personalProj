class chi_subsys_directed_atomic_seq extends svt_chi_rn_coherent_transaction_base_sequence;

	`svt_xvm_object_utils(chi_subsys_directed_atomic_seq)
	`svt_xvm_declare_p_sequencer(svt_chi_rn_transaction_sequencer)
	 svt_chi_node_configuration cfg;
	
	function new(string name ="chi_subsys_directed_atomic_seq");
	super.new(name);
	use_directed_addr = 0;
	endfunction

	virtual task body();
	    svt_chi_rn_transaction txn;
	    svt_chi_rn_agent                         my_agent;
	    `SVT_XVM(component)                      my_component;
	    svt_axi_cache                            my_cache;
	    bit is_unique,is_clean;
	    int status;
	    svt_configuration get_cfg;
	    p_sequencer.get_cfg(get_cfg);
	
	    if (!$cast(cfg, get_cfg)) begin
	      `uvm_fatal("body", "Unable to $cast the configuration to a svt_chi_port_configuration class");
	    end
	    my_component = p_sequencer.get_parent();
	    void'($cast(my_agent,my_component));
	    if (my_agent != null)begin
	    my_cache = my_agent.rn_cache;
	    end 
	    super.body();
	    `uvm_create(txn)
	    `svt_xvm_do_with(txn,
	          {
	          xact_type inside {svt_chi_transaction::ATOMICSTORE_SET,svt_chi_transaction::ATOMICLOAD_UMAX,svt_chi_transaction::ATOMICLOAD_ADD};
	          mem_attr_is_cacheable == 1 ;
	          snp_attr_is_snoopable == 1 ;
	          snoopme == 1;
		  })
	endtask
endclass
 



        






