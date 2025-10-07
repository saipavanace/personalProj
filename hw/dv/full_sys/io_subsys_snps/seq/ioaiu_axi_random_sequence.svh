`ifndef GUARD_IOAIU_AXI_RANDOM_SEQUENCE_SVH
`define GUARD_IOAIU_AXI_RANDOM_SEQUENCE_SVH

/** 
 *  Sequence used in test - concerto_iosubsys_axi_random_snps 
*/
class ioaiu_axi_random_sequence extends svt_axi_master_random_sequence;


  `svt_xvm_object_utils(ioaiu_axi_random_sequence)

  conc_base_svt_axi_master_transaction req;
  int cnt;

  function new(string name = "ioaiu_axi_random_sequence");
    super.new(name);
  endfunction

  virtual task pre_body();
    bit status;
    super.pre_body();
    raise_phase_objection();
  endtask

  virtual task body();
    
    bit status;
    // Check for valid port type
    if (!is_applicable(cfg)) begin
      `svt_xvm_note("body", "The sequence cannot be run based on the current system configuration"); 
    end 
    else begin
      `uvm_info("body", $psprintf("Entered ...sequence_length:%0d", sequence_length), UVM_LOW)
      repeat (sequence_length) begin
         cnt++;
         //`uvm_info("body", $psprintf("cnt:%0d", cnt), UVM_LOW)
         `svt_xvm_do_with(req,
               {
                   xact_type == svt_axi_transaction::WRITE;
                   data_before_addr == 0;
               })
         `svt_xvm_do_with(req,
               {
                   xact_type == svt_axi_transaction::READ;
                   data_before_addr == 0;
               })
      end
      `uvm_info("body", "Exiting...", UVM_LOW)
    end
  endtask: body

 /** Drop objection */
  virtual task post_body();
    drop_phase_objection();
  endtask: post_body

endclass    
 

`endif // `ifndef GUARD_IOAIU_AXI_RANDOM_SEQUENCE_SVH 
