// The entire notice above must be reproduced on all authorized copies.
//----------------------------------------------------------------------------------------------------------------
// File     : snoop_filter_monitor.sv
// Author   : yramasamy
// Notes    : monitor for the snoop filter
//----------------------------------------------------------------------------------------------------------------

`ifndef __SNOOP_FILTER_MONITOR_SV__
`define __SNOOP_FILTER_MONITOR_SV__

class snoop_filter_monitor #(int NSETS=64, int NWAYS=1, int BYTES_PER_LINE=8) extends uvm_monitor;
    // members of the class
    //---------------------------------------------------------------------------------------------------------------
    semaphore                                                m_port_semaphore;   
    uvm_analysis_port #(snoop_filter_seq_item)               m_snoop_filter_port_out;
    virtual snoop_filter_if #(NSETS, NWAYS, BYTES_PER_LINE)  m_snoop_filter_if[NWAYS-1:0];

    // registering class to factory
    //---------------------------------------------------------------------------------------------------------------
   `uvm_component_param_utils(snoop_filter_monitor #(NSETS, NWAYS, BYTES_PER_LINE));

    // function: new
    //---------------------------------------------------------------------------------------------------------------
    function new(string name="sf_monitor", uvm_component parent);
        super.new(name, parent);
    endfunction

    // build_phase
    //---------------------------------------------------------------------------------------------------------------
    function void build_phase(uvm_phase phase);
        m_port_semaphore        = new(1);
        m_snoop_filter_port_out = new("snoop_filter_port_out", this);
    endfunction: build_phase

    // connect_phase
    //---------------------------------------------------------------------------------------------------------------
    function void connect_phase(uvm_phase phase);
        for(int i=0; i < NWAYS; i++) begin
            if(!uvm_config_db #(virtual snoop_filter_if #(NSETS, NWAYS, BYTES_PER_LINE))::get(this, "", $psprintf("%s.way%1d", get_name(), i), m_snoop_filter_if[i])) begin
               `uvm_fatal(get_name(), $psprintf("[%-35s] virtual interface %s.way%1d not set in config db! (sets=%1d, ways=%1d, bytesPerLine=%1d)", "snpFiltMonitor", get_name(), i, NSETS, NWAYS, BYTES_PER_LINE));
            end
        end
    endfunction: connect_phase

    // run_phase task
    //---------------------------------------------------------------------------------------------------------------
    task run_phase(uvm_phase phase);
        for(int i=0; i < NWAYS; i++) begin
            fork
                automatic int j = i;
                monitor_if(j);
            join_none
        end
    endtask: run_phase

    // monitor_if
    // this task monitors the snoop filter if and if it gets sempahore writes to the port
    //---------------------------------------------------------------------------------------------------------------
    task monitor_if(int id);
        snoop_filter_seq_item snoop_filter_item;

       `uvm_info(get_name(), $psprintf("[%-35s] initating snoop-filter-way[%2d]", "snpFiltMonitor-Init", id), UVM_NONE);
        forever begin
            @(m_snoop_filter_if[id].posedge_monitor_cb);
            if(m_snoop_filter_if[id].posedge_monitor_cb.cen === 1'b1) begin
                if(m_snoop_filter_if[id].posedge_monitor_cb.mnt_ops === 1'b0) begin
                    snoop_filter_item               = snoop_filter_seq_item::type_id::create($psprintf("%s {sf-item-%1d}", get_name(), id));
                    snoop_filter_item.m_set_index   = m_snoop_filter_if[id].posedge_monitor_cb.set_index;
                    snoop_filter_item.m_rd0_wr1     = m_snoop_filter_if[id].posedge_monitor_cb.wen;
                    snoop_filter_item.m_data        = m_snoop_filter_if[id].posedge_monitor_cb.wen ? m_snoop_filter_if[id].posedge_monitor_cb.data : 'bX; // reads not sampled at the moment!
                    snoop_filter_item.m_way         = id;

                    // writing the data to port
                    m_port_semaphore.get(1);
                   `uvm_info(get_name(), $psprintf("[%-35s] %s", "snpFiltMonitor", snoop_filter_item.convert2string()), UVM_DEBUG);
                    m_snoop_filter_port_out.write(snoop_filter_item);
                    m_port_semaphore.put(1);
                end
            end
        end
    endtask: monitor_if
endclass: snoop_filter_monitor

`endif
// is this working?
