////////////////////////////////////////////////////////////////////////////////
// DMI RTL Monitor
////////////////////////////////////////////////////////////////////////////////
class <%=obj.BlockId%>_rtl_monitor extends uvm_component;

  `uvm_component_utils(<%=obj.BlockId%>_rtl_monitor);

  virtual <%=obj.BlockId%>_rtl_if  m_vif; 
  bit      delay_export;

  uvm_analysis_port #(<%=obj.BlockId%>_rtl_cmd_rsp_pkt) cmd_rsp_ap;

  extern function new(string name = "<%=obj.BlockId%>_rtl_monitor", uvm_component parent = null);
  extern function void build();
  extern task run;

  extern task monitor_cmd_rsp_loop;
  extern task monitor_mrd_pop_loop;

endclass : <%=obj.BlockId%>_rtl_monitor

//------------------------------------------------------------------------------
// Constructor
//------------------------------------------------------------------------------
function <%=obj.BlockId%>_rtl_monitor::new(string name = "<%=obj.BlockId%>_rtl_monitor", uvm_component parent = null);
  super.new(name, parent);
endfunction : new

function void <%=obj.BlockId%>_rtl_monitor::build();
  cmd_rsp_ap = new("cmd_rsp_ap", this);

endfunction : build

//------------------------------------------------------------------------------
// Run Task
//------------------------------------------------------------------------------
task <%=obj.BlockId%>_rtl_monitor::run;
  fork
     monitor_cmd_rsp_loop();
     monitor_mrd_pop_loop();
  join
endtask: run

//------------------------------------------------------------------------------
// Monitor Rtl Loop
//------------------------------------------------------------------------------
task <%=obj.BlockId%>_rtl_monitor::monitor_cmd_rsp_loop;
   <%=obj.BlockId%>_rtl_cmd_rsp_pkt   pkt;

   pkt = new();
  forever begin
     m_vif.collect_cmd_rsp_packet(pkt);
     #1;
     if(pkt.cmd_rsp_push_valid)begin
       cmd_rsp_ap.write(pkt);
	  `uvm_info("DMI_RTT_MONITOR", pkt.convert2string(), UVM_DEBUG)
	 end
  end // forever
endtask: monitor_cmd_rsp_loop
//------------------------------------------------------------------------------
// Monitor Rtl Loop
//------------------------------------------------------------------------------
task <%=obj.BlockId%>_rtl_monitor::monitor_mrd_pop_loop;
   <%=obj.BlockId%>_rtl_cmd_rsp_pkt   pkt;

   pkt = new();
  forever begin
     m_vif.collect_mrd_pop_packet(pkt);
     #1;
     if(pkt.mrd_pop_valid)begin
       cmd_rsp_ap.write(pkt);
	  `uvm_info("DMI_RTT_MONITOR", pkt.convert2string(), UVM_DEBUG)
	 end
  end // forever
endtask: monitor_mrd_pop_loop

