import uvm_pkg::*;
`include "uvm_macros.svh"

class ncore_comparator extends uvm_component;
   `uvm_component_utils(ncore_comparator)

   extern function new(string name = "ncore_comparator", uvm_component parent = null);

endclass : ncore_comparator

function ncore_comparator::new(string name = "ncore_comparator", uvm_component parent = null);
   super.new(name,parent);
endfunction : new

