class packet_generator_seq extends packet_generator_base_seq;

  `uvm_object_utils(packet_generator_seq)

  extern function new(string name="packet_generator_seq");
  //extern task pre_body();
  extern task body();
endclass

function packet_generator_seq::new(string name="packet_generator_seq");
  super.new(name);
endfunction

task packet_generator_seq::body();
  super.body();
endtask