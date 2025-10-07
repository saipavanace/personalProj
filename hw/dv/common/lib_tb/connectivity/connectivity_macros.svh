
`define macro_connectivity_test_all_declarations \
      // typedef bit unsigned [63:0] uint64_type; // To be uncommented if macro use alone \
      bit test_connectivity_test=0;\
      uint64_type cfg_seq_iter=1;\
      virtual task csr_seq_pre_hook(uvm_phase phase);      endtask \
      virtual task csr_seq_post_hook(uvm_phase phase);     endtask \
      virtual task csr_seq_iter_pre_hook(uvm_phase phase, uint64_type iter);  endtask \
      virtual task csr_seq_iter_post_hook(uvm_phase phase, uint64_type iter); endtask 

//END MACRO
