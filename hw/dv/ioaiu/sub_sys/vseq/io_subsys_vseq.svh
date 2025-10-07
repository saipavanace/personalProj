// This vseq is like a parent vseq that has just one job to do 
// start inhouse_vseq or start snps_vseq based on en_snps_vip

class io_subsys_vseq extends uvm_sequence;
  `uvm_object_utils(io_subsys_vseq)
  io_subsys_snps_vseq      snps_vseq;
  io_subsys_inhouse_vseq   inhouse_vseq;
  svt_axi_system_sequencer snps_vseqr;
  int                      ioaiu_num_trans;

  function new(string name = "io_subsys_vseq");
    super.new(name);
  endfunction

  function void init_vseq(svt_axi_system_sequencer sqr);
     if (sqr != null) begin: _snps_
        snps_vseq  = io_subsys_snps_vseq::type_id::create("io_subsys_snps_vseq");
        snps_vseqr = sqr;
     end: _snps_
     else begin: _inhouse_
        inhouse_vseq = io_subsys_inhouse_vseq::type_id::create("io_subsys_inhouse_vseq");
     end: _inhouse_
  endfunction: init_vseq
  
  /**  Raise an objection if this is the parent sequence */
  virtual task pre_body();
    super.pre_body();
    if  (starting_phase!=null) begin
      starting_phase.raise_objection(this);
    end
  endtask: pre_body

  /**  Drop an objection if this is the parent sequence */
  virtual task post_body();
    super.post_body();
    if  (starting_phase!=null) begin
      starting_phase.drop_objection(this);
    end
  endtask: post_body
  
  task body();

     `uvm_info(get_full_name(), "Enter body ", UVM_LOW);
      
     `uvm_info(get_full_name(), $psprintf("Starting %0s", (snps_vseq != null) ? "io_subsys_snps_vseq" : "io_subsys_inhouse_vseq"), UVM_LOW);
     if (snps_vseq != null) begin: _snps_
        snps_vseq.ioaiu_num_trans = ioaiu_num_trans;
        snps_vseq.start(snps_vseqr);
     end: _snps_
     else begin: _inhouse_
        inhouse_vseq.start(null);
     end: _inhouse_

     `uvm_info(get_full_name(), "Exit body ", UVM_LOW);
  endtask:body
endclass: io_subsys_vseq
