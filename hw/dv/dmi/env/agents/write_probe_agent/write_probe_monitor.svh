////////////////////////////////////////////////////////////////////////////////
// DMI Write Prot Arbiter Monitor
////////////////////////////////////////////////////////////////////////////////
class <%=obj.BlockId%>_write_probe_monitor extends uvm_component;

  `uvm_component_utils(<%=obj.BlockId%>_write_probe_monitor);

  virtual <%=obj.BlockId%>_write_probe_if  m_vif; 
  bit      delay_export;

  uvm_analysis_port #(<%=obj.BlockId%>_write_probe_txn) ap;

  extern function new(string name = "<%=obj.BlockId%>_write_probe_monitor", uvm_component parent = null);
  extern function void build();
  extern task run;

  extern task monitor_nc_write_loop;
  extern task monitor_write_rsp_loop;

endclass : <%=obj.BlockId%>_write_probe_monitor

//------------------------------------------------------------------------------
// Constructor
//------------------------------------------------------------------------------
function <%=obj.BlockId%>_write_probe_monitor::new(string name = "<%=obj.BlockId%>_write_probe_monitor", uvm_component parent = null);
  super.new(name, parent);
endfunction : new

function void <%=obj.BlockId%>_write_probe_monitor::build();
  ap = new("ap", this);

endfunction : build

//------------------------------------------------------------------------------
// Run Task
//------------------------------------------------------------------------------
task <%=obj.BlockId%>_write_probe_monitor::run;
  fork
     monitor_nc_write_loop();
     monitor_write_rsp_loop();
  join
endtask: run

//------------------------------------------------------------------------------
// Monitor Rtl Loop
//------------------------------------------------------------------------------
task <%=obj.BlockId%>_write_probe_monitor::monitor_nc_write_loop;
   <%=obj.BlockId%>_write_probe_txn   pkt;

   pkt = <%=obj.BlockId%>_write_probe_txn::type_id::create("pkt");
  forever begin
     m_vif.collect_nc_write_packet(pkt);
     #1;
     if(pkt.valid)begin
       `uvm_info("DMI_WRITE_MON", $sformatf("%s",pkt.sprint_pkt()), UVM_LOW)
       ap.write(pkt);
	   end
  end // forever
endtask: monitor_nc_write_loop
//------------------------------------------------------------------------------
// Monitor Rtl Loop
//------------------------------------------------------------------------------
task <%=obj.BlockId%>_write_probe_monitor::monitor_write_rsp_loop;
   <%=obj.BlockId%>_write_probe_txn   pkt;

   pkt = new();
  forever begin
     m_vif.collect_coh_write_packet(pkt);
     #1;
     if(pkt.valid)begin
       `uvm_info("DMI_WRITE_MON", $sformatf("%s",pkt.sprint_pkt()), UVM_LOW)
       ap.write(pkt);
	   end
  end // forever
endtask: monitor_write_rsp_loop

