

class dce_probe_agent extends uvm_agent;

    `uvm_component_utils(dce_probe_agent)

    virtual probe_if m_vif;
    dce_probe_monitor m_monitor;

    //uvm_analysis_port #(dirlookup_seq_item) dirlookup_ap;
    uvm_analysis_port #(dirm_req_item) dirm_req_ap;
    uvm_analysis_port #(dirm_rsp_item) dirm_rsp_ap;
    //uvm_analysis_port #(dirm_hw_status_seq_item) dirm_clk_ap;

    extern function new(string name = "dce_probe_agent", uvm_component parent = null);
    extern function void build_phase(uvm_phase phase);
    extern function void connect_phase(uvm_phase phase);

endclass: dce_probe_agent

function dce_probe_agent::new(string name = "dce_probe_agent", uvm_component parent = null);
    super.new(name, parent);
endfunction: new

function void dce_probe_agent::build_phase(uvm_phase phase);
    super.build_phase(phase);

    //dirlookup_ap = new("dirlookup_ap", this);
    dirm_req_ap  = new("dirm_req_ap", this);
    dirm_rsp_ap  = new("dirm_rsp_ap", this);
   // dirm_clk_ap  = new("dirm_clk_ap", this);

    m_monitor = dce_probe_monitor::type_id::create("dce_probe_monitor", this);

    if(!uvm_config_db #(virtual probe_if)::get(uvm_root::get(), "",
            "probe_vif", m_vif)) begin
        `uvm_fatal("DCE Probe Agent", "unable to find dce_probe_if")
    end
endfunction: build_phase

function void dce_probe_agent::connect_phase(uvm_phase phase);
    super.connect_phase(phase);

    m_monitor.m_vif = m_vif;
    //m_monitor.dirlookup_ap.connect(dirlookup_ap);
    m_monitor.dirm_req_ap.connect(dirm_req_ap);
    m_monitor.dirm_rsp_ap.connect(dirm_rsp_ap);
    //m_monitor.dirm_status_ap.connect(dirm_clk_ap);
        
endfunction: connect_phase
