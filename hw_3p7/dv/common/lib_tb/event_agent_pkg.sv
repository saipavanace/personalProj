///////////////////////////////
// EVent Agent Package
// Author: Abdelaziz EL HAMADI
//////////////////////////////
package <%=obj.BlockId%>_event_agent_pkg;

import uvm_pkg::*;
`include "uvm_macros.svh"
`include "<%=obj.BlockId%>_event_pkt.svh"
`include "<%=obj.BlockId%>_event_signals.svh"
`include "<%=obj.BlockId%>_event_driver.svh"
`include "<%=obj.BlockId%>_event_seq.svh"
`include "<%=obj.BlockId%>_event_monitor.svh"
`include "<%=obj.BlockId%>_event_sequencer.svh"
`include "<%=obj.BlockId%>_event_agent_config.svh"
`include "<%=obj.BlockId%>_event_agent.svh"

endpackage : <%=obj.BlockId%>_event_agent_pkg
