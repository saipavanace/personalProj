////////////////////////////////////////////////////////////////////////////////
// DMI TT Monitor
////////////////////////////////////////////////////////////////////////////////
class <%=obj.BlockId%>_tt_alloc_monitor extends uvm_component;

  `uvm_component_utils(<%=obj.BlockId%>_tt_alloc_monitor);

  virtual <%=obj.BlockId%>_tt_if  m_vif; 
  bit      delay_export;

  uvm_analysis_port #(<%=obj.BlockId%>_tt_alloc_pkt) tt_alloc_ap;

  extern function new(string name = "<%=obj.BlockId%>_tt_alloc_monitor", uvm_component parent = null);
  extern function void build();
  extern task run;

  extern task monitor_rtt_alloc_loop;
  extern task monitor_wtt_alloc_loop;

endclass : <%=obj.BlockId%>_tt_alloc_monitor

//------------------------------------------------------------------------------
// Constructor
//------------------------------------------------------------------------------
function <%=obj.BlockId%>_tt_alloc_monitor::new(string name = "<%=obj.BlockId%>_tt_alloc_monitor", uvm_component parent = null);
  super.new(name, parent);
endfunction : new

function void <%=obj.BlockId%>_tt_alloc_monitor::build();
  tt_alloc_ap = new("tt_alloc_ap", this);

endfunction : build

//------------------------------------------------------------------------------
// Run Task
//------------------------------------------------------------------------------
task <%=obj.BlockId%>_tt_alloc_monitor::run;
  fork
     monitor_rtt_alloc_loop();
     monitor_wtt_alloc_loop();
  join
endtask: run

//------------------------------------------------------------------------------
// Monitor TT Loop
//------------------------------------------------------------------------------
task <%=obj.BlockId%>_tt_alloc_monitor::monitor_rtt_alloc_loop;
   <%=obj.BlockId%>_tt_alloc_pkt   pkt;

   pkt = new();
  forever begin
     m_vif.collect_rtt_alloc_packet(pkt);
     #1;
     //if(pkt.alloc_valid)begin
       tt_alloc_ap.write(pkt);
	   `uvm_info("DMI_TT_MONITOR", $sformatf("%s", pkt.sprint_pkt()), UVM_DEBUG)
	 //end
  end // forever
endtask: monitor_rtt_alloc_loop
//------------------------------------------------------------------------------
// Monitor TT Loop
//------------------------------------------------------------------------------
task <%=obj.BlockId%>_tt_alloc_monitor::monitor_wtt_alloc_loop;
   <%=obj.BlockId%>_tt_alloc_pkt   pkt;

   pkt = new();
  forever begin
     m_vif.collect_wtt_alloc_packet(pkt);
     #1;
     //if(pkt.alloc_valid)begin
       tt_alloc_ap.write(pkt);
	   `uvm_info("DMI_TT_MONITOR", $sformatf("%s", pkt.sprint_pkt()), UVM_DEBUG)
	 //end
  end // forever
endtask: monitor_wtt_alloc_loop
