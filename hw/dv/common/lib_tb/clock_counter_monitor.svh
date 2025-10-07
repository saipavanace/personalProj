
class <%=obj.BlockId%>_clock_counter_monitor extends uvm_monitor;

    `uvm_component_param_utils(<%=obj.BlockId%>_clock_counter_monitor);

    virtual <%=obj.BlockId%>_clock_counter_if m_vif;

    uvm_analysis_port #(<%=obj.BlockId%>_clock_counter_seq_item) clock_counter_ap;

    function new(string name = "<%=obj.BlockId%>_clock_counter_monitor", uvm_component parent = null);
          super.new(name, parent);
    endfunction : new

    extern function void build_phase(uvm_phase phase);
    extern task run_phase(uvm_phase phase);
endclass //

function void <%=obj.BlockId%>_clock_counter_monitor::build_phase(uvm_phase phase);
    super.build_phase(phase);

    clock_counter_ap = new("clock_counter_ap", this);
endfunction : build_phase

//*****************************************************
task <%=obj.BlockId%>_clock_counter_monitor::run_phase(uvm_phase phase);
    <%=obj.BlockId%>_clock_counter_seq_item m_item     = <%=obj.BlockId%>_clock_counter_seq_item::type_id::create("m_item");
    forever begin
        @(m_vif.monitor_cb);
    	m_item.current_time   = m_vif.get_current_time();
        m_item.cycle_counter  = m_vif.get_cycle_count();
        m_item.probe_sig1     = m_vif.get_probe_sig1();
        clock_counter_ap.write(m_item);
    end
endtask: run_phase
