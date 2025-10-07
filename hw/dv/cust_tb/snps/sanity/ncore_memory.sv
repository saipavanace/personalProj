import uvm_pkg::*;
`include "uvm_macros.svh"

class ncore_memory extends uvm_component;
   `uvm_component_utils(ncore_memory)

   extern function new(string name = "ncore_memory", uvm_component parent = null);

endclass : ncore_memory

function ncore_memory::new(string name = "ncore_memory", uvm_component parent = null);
   super.new(name,parent);
endfunction : new


