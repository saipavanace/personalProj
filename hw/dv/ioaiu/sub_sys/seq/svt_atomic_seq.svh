//=====================================================================================================================================
// uvm_sequence <-- svt_axi_master_base_sequence <-- svt_atomic_seq 
//This sequnce use to generate atomic txn 
//====================================================================================================================================
class svt_atomic_seq extends svt_axi_master_base_sequence;

 rand int unsigned sequence_length = 10;
 rand svt_axi_transaction::atomic_transaction_type_enum atomi_type;

  `svt_xvm_object_utils(svt_atomic_seq)
  `svt_xvm_declare_p_sequencer(svt_axi_master_sequencer)
  int atmstr_wt; 
  int atmld_wt; 
  int atmcmp_wt; 
  int atmswp_wt;  
  function new(string name = "svt_atomic_seq");
    super.new(name);
  endfunction: new

  virtual task body();
    `uvm_info(get_full_name(), $psprintf("Entered body ...atmstr_wt %0d,atmld_wt %0d,atmcmp_wt %0d,atmswp_wt %0d",atmstr_wt,atmld_wt,atmcmp_wt,atmswp_wt), UVM_LOW)
    
    super.body();
    sink_responses();
    repeat (sequence_length) begin
      randcase
        atmstr_wt: atomi_type = svt_axi_transaction::STORE;
        atmld_wt:  atomi_type = svt_axi_transaction::LOAD;
        atmcmp_wt: atomi_type = svt_axi_transaction::COMPARE;
        atmswp_wt: atomi_type = svt_axi_transaction::SWAP;
      endcase
     
    `svt_xvm_do_with(req, 
         { 
          xact_type == svt_axi_transaction::ATOMIC;
          atomic_transaction_type == atomi_type;
          
          })
    manage_active_txn_q(req);
    end
    
    // Wait for all transactions to end
    `svt_xvm_debug("body", "Waiting for end of all the generated transactions");
    wait(actv_txn_q.size() == 0);
    `svt_xvm_debug("body", "Completed waiting for end of all the generated transactions");             

    check_txn_counts();
  endtask:body

endclass:svt_atomic_seq
