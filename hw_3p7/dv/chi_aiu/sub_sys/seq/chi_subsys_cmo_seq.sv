class chi_subsys_cmo_seq extends svt_chi_rn_transaction_base_sequence;

  local svt_chi_rn_agent my_agent;

   /** UVM Object Utility macro */
  `uvm_object_utils(chi_subsys_cmo_seq)

    /** Class Constructor */
  extern function new(string name="chi_subsys_cmo_seq");

  /** Node configuration obtained from the sequencer */
  svt_chi_node_configuration cfg;

  /** Parameter that controls the number of transactions that will be generated */
  rand int unsigned sequence_length;


  /** Constrain the sequence length to a reasonable value */
  constraint reasonable_sequence_length {
    sequence_length <= 1000;
  }
  
 // ncore_system_env env;

  `svt_xvm_declare_p_sequencer(svt_chi_rn_transaction_sequencer)

  virtual task body();
    svt_chi_rn_transaction read_tran;
    svt_chi_rn_transaction write_tran;
    svt_chi_rn_agent                         my_agent;
    `SVT_XVM(component)                      my_component;
    svt_axi_cache                            my_cache;
    bit is_unique,is_clean;

    super.body();

  for (int i=0; i < 10; i++) begin
      
         my_component = p_sequencer.get_parent();
         void'($cast(my_agent,my_component));
        if (my_agent != null)begin
          my_cache = my_agent.rn_cache;
        end 

       /** Set up the mkuniq transaction */
       `uvm_create(read_tran)
        read_tran.cfg = this.cfg;
       `svt_xvm_do_with(read_tran,
          {
       	   xact_type			 	== svt_chi_rn_transaction::MAKEUNIQUE; 
           data_size                     	== svt_chi_rn_transaction::SIZE_64BYTE;
           exp_comp_ack                  	== 1'b1;
           snp_attr_is_snoopable         	== 1'b1;
           mem_attr_is_cacheable         	== 1'b1;
           snp_attr_snp_domain_type      	== svt_chi_transaction::INNER;
	   is_non_secure_access	         	== 0;
           mem_attr_is_early_wr_ack_allowed     == 1'b1;
           mem_attr_mem_type             	== svt_chi_transaction::NORMAL;
	 })

       /* Wait for the read transaction to complete */
       read_tran.wait_end();
$display("TRANSACTION_ENDED");

      /* Set up the cpback transaction */
       `uvm_create(write_tran)
       write_tran.cfg = this.cfg;
       `svt_xvm_do_with(write_tran,
          {
           addr					== read_tran.addr;
           data_size 				== svt_chi_rn_transaction::SIZE_64BYTE;
	   <% if (obj.AiuInfo[obj.Id].fnNativeInterface == 'CHI-E') { %>
           xact_type inside			{  svt_chi_rn_transaction::WRITEBACKFULL_CLEANSHARED,
						   svt_chi_rn_transaction::WRITEBACKFULL_CLEANINVALID,
						   svt_chi_rn_transaction::WRITEBACKFULL_CLEANSHAREDPERSISTSEP,
           					   svt_chi_rn_transaction::WRITECLEANFULL_CLEANSHARED,
						   svt_chi_rn_transaction::WRITECLEANFULL_CLEANSHAREDPERSISTSEP };
	   <% } else { %>
           xact_type inside			{  svt_chi_rn_transaction::WRITEBACKFULL,
						   svt_chi_rn_transaction::WRITECLEANFULL };

	   <% } %>
      	   exp_comp_ack 			== 1'b0;
      	   is_non_secure_access	       		== 0;
      	   snp_attr_is_snoopable 		== 1'b1;
      	   mem_attr_is_cacheable 		== 1'b1;
      	   snp_attr_snp_domain_type 		== svt_chi_transaction::INNER;
      	   mem_attr_is_early_wr_ack_allowed 	== 1'b1;
      	   mem_attr_mem_type 			== svt_chi_transaction::NORMAL;
          })

       /** Wait for the write transaction to complete */
       write_tran.wait_end();

  end

  `uvm_info("body", $sformatf("TEST Results"), UVM_NONE);
    //uvm_wait_for_nba_region();

   `uvm_info("body", "Exiting...", UVM_LOW)
  endtask: body

endclass: chi_subsys_cmo_seq

function chi_subsys_cmo_seq::new(string name="chi_subsys_cmo_seq");
  super.new(name);
  this.set_response_queue_depth(-1);
endfunction




