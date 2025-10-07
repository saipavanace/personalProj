////////////////////////////////////////////////////////////////////////////////
//
// Clock Counter Package
//
////////////////////////////////////////////////////////////////////////////////
package <%=obj.BlockId%>_clock_counter_pkg;

import uvm_pkg::*;
`include "uvm_macros.svh"

`include "<%=obj.BlockId%>_clock_counter_seq_item.svh"
`include "<%=obj.BlockId%>_clock_counter_monitor.svh"

endpackage : <%=obj.BlockId%>_clock_counter_pkg
