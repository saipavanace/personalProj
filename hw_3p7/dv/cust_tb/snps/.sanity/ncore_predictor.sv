import uvm_pkg::*;
`include "uvm_macros.svh"

class ncore_predictor extends uvm_component;
   `uvm_component_utils(ncore_predictor)

   extern function new(string name = "ncore_predictor", uvm_component parent = null);

endclass : ncore_predictor

function ncore_predictor::new(string name = "ncore_predictor", uvm_component parent = null);
   super.new(name,parent);
endfunction : new
