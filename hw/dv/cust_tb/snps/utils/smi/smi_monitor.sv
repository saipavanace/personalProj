////////////////////////////////////////////////////////////////////////////////
// SMI Monitor
////////////////////////////////////////////////////////////////////////////////
class smi_monitor extends uvm_monitor;
    `uvm_component_param_utils(smi_monitor);
    virtual smi_if  m_vif;


    bit is_transmitter;

    uvm_analysis_port #(smi_seq_item) smi_ap;
    uvm_analysis_port #(smi_seq_item) every_beat_smi_ap;
    uvm_analysis_port #(smi_seq_item) smi_ndp_ap;

    //------------------------------------------------------------------------------
    // Constructor
    //------------------------------------------------------------------------------
    function new(string name = "smi_monitor", uvm_component parent = null);
        super.new(name, parent);
    endfunction : new

    function void build();
        smi_ap            = new("smi_ap", this);
        every_beat_smi_ap = new("every_beat_smi_ap", this);
        smi_ndp_ap        = new("smi_ndp_ap", this);

    endfunction : build

    //------------------------------------------------------------------------------
    // Run Task
    //------------------------------------------------------------------------------
    task run;
        mailbox #(smi_seq_item) m_ndp_items_mb    = new();
        mailbox #(smi_seq_item) m_dp_items_mb     = new();
        @(posedge m_vif.rst_n);
        fork
            begin
                // collect ndp packets
                forever begin
                    smi_seq_item m_ndp_item     = smi_seq_item::type_id::create("ndp_item");
                    m_vif.collect_ndp(m_ndp_item);
            
                    m_ndp_item.smi_transmitter = is_transmitter;
                
                    smi_ndp_ap.write(m_ndp_item);
                    m_ndp_items_mb.put(m_ndp_item);
                    `uvm_info("SMI_MONITOR: COLLECT_NDP", $sformatf("NDP_ITEM: %p", m_ndp_item.convert2string()), UVM_NONE)
                end
            end
            begin
                // collect dp packets
                forever begin
                    smi_seq_item m_dp_item = smi_seq_item::type_id::create("dp_item");
                    m_vif.collect_dp(m_dp_item);
                    m_dp_item.unpack_dp_smi_seq_item();
                    m_dp_item.smi_transmitter = is_transmitter;

                    m_dp_items_mb.put(m_dp_item);
                    `uvm_info("SMI_MONITOR: COLLECT_DP", $sformatf("DP_ITEM: %p", m_dp_item.convert2string()), UVM_NONE)
                end
            end
            begin : AP_WRITE
                // Analysis port writes
                forever begin
                    smi_seq_item m_item            = smi_seq_item::type_id::create("m_item");
                    smi_seq_item m_every_beat_item = smi_seq_item::type_id::create("m_every_beat_item");
                    smi_seq_item m_tmp_item        = smi_seq_item::type_id::create("m_tmp_item");
                    m_ndp_items_mb.get(m_tmp_item);
                    m_item.do_copy(m_tmp_item);
                  
                    `uvm_info(get_full_name(), $sformatf("ECC DEBUG M2: %p", m_item.convert2string()), UVM_HIGH)

                    if (m_item.hasDP()) begin
                        smi_seq_item m_tmp_data_item;
                        do begin
                            m_tmp_data_item = smi_seq_item::type_id::create("m_tmp_data_item");
                            m_dp_items_mb.get(m_tmp_data_item);
                            $cast(m_every_beat_item, m_item.clone());
                            m_every_beat_item.do_copy_one_beat_data_zero_out(m_tmp_data_item);
                            m_every_beat_item.smi_dp_present = 1;  // for debugging purposes
                            `uvm_info($sformatf("%m"), $sformatf("ECC DEBUG M3: every_beat_item %p", m_every_beat_item.convert2string()), UVM_HIGH) 
                            foreach(m_every_beat_item.smi_dp_user[i]) begin
                                m_item.do_copy_one_beat_data_only(m_every_beat_item);
                                m_item.unpack_dp_smi_seq_item();
                                
                                `uvm_info(get_full_name(), $sformatf("ECC DEBUG M4: every_beat_item %p m_item %p", m_every_beat_item.convert2string(), m_item.convert2string()), UVM_HIGH) 
                            end // foreach (m_every_beat_item.smi_dp_user[i])
                
                            m_every_beat_item.unpack_dp_smi_seq_item();
                            `uvm_info(get_full_name(), $sformatf("ECC DEBUG M10: Beat%0d %p", m_item.smi_dp_data.size(), m_item.convert2string()), UVM_HIGH)
                            every_beat_smi_ap.write(m_every_beat_item);
                        end while (m_every_beat_item.smi_dp_last == 0);
                    end // if (m_item.hasDP())

                    m_item.unpack_smi_seq_item();
                    smi_ap.write(m_item);
                    `uvm_info("SMI_MONITOR: AP_WROTE", $sformatf("AP_WRITE_M_ITEM: %p", m_item.convert2string()), UVM_NONE)
                    `uvm_info(get_full_name(),$sformatf("Wrote item to smi_ap in monitor"), UVM_HIGH);
                end // forever begin
            end : AP_WRITE
        join
    endtask: run

endclass: smi_monitor
