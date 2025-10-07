/*
*
*
*/

class ioaiu_probe_agent extends uvm_agent;
    `uvm_component_param_utils(ioaiu_probe_agent)

    virtual <%=obj.BlockId%>_probe_if m_vif;
    ioaiu_probe_monitor m_monitor;
    int core_id;
    uvm_analysis_port #(ioaiu_probe_txn) probe_rtl_ap;
    uvm_analysis_port #(ioaiu_probe_txn) probe_ottvec_ap;
    uvm_analysis_port #(cycle_tracker_s) probe_cycle_tracker_ap;
    uvm_analysis_port #(ioaiu_probe_txn) probe_bypass_ap;
    uvm_analysis_port #(ioaiu_probe_txn) probe_owo_ap;

    extern function new(string name = "ioaiu_probe_agent", uvm_component parent = null);
    extern function void build_phase(uvm_phase phase);
    extern function void connect_phase(uvm_phase phase);
endclass : ioaiu_probe_agent

function ioaiu_probe_agent::new(string name = "ioaiu_probe_agent", uvm_component parent = null);
    super.new(name, parent);
endfunction: new

function void ioaiu_probe_agent::build_phase(uvm_phase phase);
    super.build_phase(phase);
    probe_rtl_ap               = new("probe_rtl_ap", this);
    probe_ottvec_ap            = new("probe_ottvec_ap", this);
    probe_cycle_tracker_ap     = new("probe_cycle_tracker_ap", this);
    probe_bypass_ap            = new("probe_bypass_ap", this);
    probe_owo_ap               = new("probe_owo_ap", this);
    m_monitor = ioaiu_probe_monitor::type_id::create("m_monitor",this);
    m_monitor.core_id = core_id;
endfunction: build_phase

function void ioaiu_probe_agent::connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    m_monitor.probe_rtl_ap.connect(probe_rtl_ap);
    m_monitor.probe_ottvec_ap.connect(probe_ottvec_ap);
    m_monitor.probe_owo_ap.connect(probe_owo_ap);

    if (probe_cycle_tracker_ap == null)
        `uvm_info("dbg", $psprintf("probe_cycle_tracker_ap is null"),UVM_LOW)
    if (m_monitor == null)
        `uvm_info("dbg", $psprintf("m_monitor is null"),UVM_LOW)
    if (m_monitor.probe_cycle_tracker_ap == null)
        `uvm_info("dbg", $psprintf("m_monitor.probe_cycle_tracker_ap is null"),UVM_LOW)


    m_monitor.probe_cycle_tracker_ap.connect(probe_cycle_tracker_ap);
    m_monitor.probe_bypass_ap.connect(probe_bypass_ap);
endfunction: connect_phase
