// The entire notice above must be reproduced on all authorized copies.
//----------------------------------------------------------------------------------------------------------------
// File     : snoop_filter_pkg.sv
// Author   : yramasamy
// Notes    : package for the snoop filter
//----------------------------------------------------------------------------------------------------------------

`ifndef __SNOOP_FILTER_PKG_SV__
`define __SNOOP_FILTER_PKG_SV__


package snoop_filter_pkg;
    import  uvm_pkg::*;
   `include "uvm_macros.svh"
    
   `include "plru_model.sv"
   `include "snoop_filter_seq_item.sv"
   `include "snoop_filter_monitor.sv"
endpackage: snoop_filter_pkg

`endif
