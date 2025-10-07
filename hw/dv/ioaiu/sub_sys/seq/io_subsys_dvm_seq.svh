//=====================================================================================================================================
// uvm_sequence <-- io_subsys_base_seq <-- io_subsys_axi_seq <-- io_subsys_axi_exclusive_seq
// svt_sequence <-- svt_axi_master_base_sequence <-- svt_axi_master_exclusive_test_sequence
/* 
/ *   This sequence performs Exclusive read transaction followed by Exclusive
 *   write transaction with same control fields as previous Exclusive read.
 *   Exclusive write commences only after response for Exclusive read is
 *   received by the master
 */
//====================================================================================================================================

class io_subsys_dvm_seq extends io_subsys_ace_seq;
  `uvm_object_utils(io_subsys_dvm_seq)
  `svt_xvm_declare_p_sequencer(svt_axi_master_sequencer)

  int sequence_length;
  int dvmsync;
  int dvmnonsync;
  string nativeif, dvm_enable;
  svt_axi_ace_master_dvm_base_sequence ace_mstr_seq[];

  function new(string name = "io_subsys_dvm_seq");
    super.new(name);
    sequence_length = 0;
  endfunction: new

  virtual task pre_body();
    super.pre_body();
  endtask:pre_body;

  virtual task body();

    `uvm_info(get_full_name(), $psprintf("Entered body ... dvmsync=%0d dvmnonsync%0d sequence_length=%0d nativeif=%s dvm_enable=%s", dvmsync, dvmnonsync, sequence_length, nativeif, dvm_enable), UVM_LOW)

    if (sequence_length == 0) begin
      ace_mstr_seq = new[mstr_cfg.num_txns];
    end else begin
      ace_mstr_seq = new[sequence_length];
    end

    //FIXME add guard for ace & ace-lite-e with dvm
    if (dvm_enable == 1) begin
    for(int j=0; j<ace_mstr_seq.size(); j++) begin
      automatic int i = j;
      fork
        ace_mstr_seq[i] = svt_axi_ace_master_dvm_base_sequence::type_id::create($psprintf("%0s_%0s_mstr_seq_p%0d", nativeif, instname, portid));
        ace_mstr_seq[i].seq_xact_type=svt_axi_transaction::DVMMESSAGE;
        init_seq(ace_mstr_seq[i]);
        randcase
            1 : ace_mstr_seq[i].dvm_message_type = 3'b000;  //NON-SYNC
            1 : ace_mstr_seq[i].dvm_message_type = 3'b001;  //NON-SYNC
            1 : ace_mstr_seq[i].dvm_message_type = 3'b010;  //NON-SYNC
            1 : ace_mstr_seq[i].dvm_message_type = 3'b011;  //NON-SYNC
            1 : ace_mstr_seq[i].dvm_message_type = 3'b100;  //SYNC
            //1 : ace_mstr_seq[i].dvm_message_type = 3'b110;  //NON-SYNC
        endcase
        `uvm_info(get_full_name(), $psprintf("Starting svt_axi_ace_master_dvm_base_sequence"), UVM_LOW)
        ace_mstr_seq[i].start(p_sequencer);
      join_none
    end
    wait fork;
    end

    `uvm_info(get_full_name(), $psprintf("Exited body ..."), UVM_LOW)

  endtask:body

endclass:io_subsys_dvm_seq
