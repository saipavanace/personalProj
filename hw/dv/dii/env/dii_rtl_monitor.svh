////////////////////////////////////////////////////////////////////////////////
// DII RTL Monitor
////////////////////////////////////////////////////////////////////////////////
class dii_rtl_monitor extends uvm_component;

    `uvm_component_param_utils(dii_rtl_monitor);

    virtual <%=obj.BlockId%>_dii_rtl_if  m_vif; 
    bit      delay_export;

    uvm_analysis_port #(axi2cmd_t) axi2cmd_rtt_ap;
    uvm_analysis_port #(axi2cmd_t) axi2cmd_wtt_ap;
    uvm_analysis_port #(event_in_t) evt_ap;

    extern function new(string name = "dii_rtl_monitor", uvm_component parent = null);
    extern function void build();
    extern task run;

    extern task monitor_axi2cmd_rtt_loop;
    extern task monitor_axi2cmd_wtt_loop;
    extern task monitor_sys_event;

endclass : dii_rtl_monitor

//------------------------------------------------------------------------------
// Constructor
//------------------------------------------------------------------------------
function dii_rtl_monitor::new(string name = "dii_rtl_monitor", uvm_component parent = null);
    super.new(name, parent);
endfunction : new

function void dii_rtl_monitor::build();
    axi2cmd_rtt_ap = new("axi2cmd_rtt_ap", this);
    axi2cmd_wtt_ap = new("axi2cmd_wtt_ap", this);
    evt_ap	       = new("evt_ap", this);
endfunction : build

//------------------------------------------------------------------------------
// Run Task
//------------------------------------------------------------------------------
task dii_rtl_monitor::run;
    fork
        monitor_axi2cmd_rtt_loop();
        monitor_axi2cmd_wtt_loop();
        monitor_sys_event();
    join
endtask: run

//------------------------------------------------------------------------------
// Monitor Rtl Loop
//------------------------------------------------------------------------------
<% 
    var tts = ["rtt", "wtt"];
    for(i in tts){ 
        var tt = tts[i];
%>
task dii_rtl_monitor::monitor_axi2cmd_<%=tt%>_loop;
    smi_unq_identifier_bit_t unq_id;
    smi_addr_t cmd_addr;
    bit cmd_lock;
    axi2cmd_t axi_cmd_obj;
    forever begin
        m_vif.collect_axi2cmd_<%=tt%>(unq_id,cmd_addr,cmd_lock);
        #0;
        axi_cmd_obj.unq_id = unq_id;
        axi_cmd_obj.cmd_addr = cmd_addr;
        axi_cmd_obj.cmd_lock = cmd_lock;
        axi2cmd_<%=tt%>_ap.write(axi_cmd_obj);
        `uvm_info($sformatf("%m"), $sformatf("got tt entry: unqid %p for addr = 0x%h", unq_id,cmd_addr), UVM_MEDIUM)
    end // forever
endtask: monitor_axi2cmd_<%=tt%>_loop

<% } %>

task dii_rtl_monitor::monitor_sys_event();
	
    event_in_t sys_event;
	bit prev_ack,prev_req;
	
	forever begin
        @(m_vif.monitor_cb);
		if(m_vif.monitor_cb.event_in_req && !prev_req) begin
			sys_event = req;
			evt_ap.write(sys_event);
		end
		if(m_vif.monitor_cb.event_in_ack && !prev_ack) begin
			sys_event = ack;
			evt_ap.write(sys_event);
		end
		if(m_vif.monitor_cb.event_err_valid) begin
			sys_event = err;
			evt_ap.write(sys_event);
		end
	    prev_req = m_vif.monitor_cb.event_in_req;	
		prev_ack = m_vif.monitor_cb.event_in_ack;	
	end
endtask: monitor_sys_event
