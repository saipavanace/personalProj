//----------------------------------------------------------------------- 
// AXI Master Monitor
//----------------------------------------------------------------------- 

class axi_master_monitor extends uvm_component;

    `uvm_component_param_utils(axi_master_monitor);

    virtual <%=obj.BlockId + '_axi_if'%>       m_vif;
    e_axi_interface_type m_intf_type;
    bit                  delay_export;
    int                  file_handle;

    uvm_analysis_port #(axi4_read_addr_pkt_t)  read_addr_ap;
    uvm_analysis_port #(axi4_write_addr_pkt_t) write_addr_ap;
    uvm_analysis_port #(axi4_read_data_pkt_t)  read_data_ap;
    uvm_analysis_port #(axi4_read_data_pkt_t)  read_data_every_beat_ap;
    uvm_analysis_port #(axi4_read_data_pkt_t)  read_data_advance_copy_ap;
    uvm_analysis_port #(axi4_write_data_pkt_t) write_data_ap;
    uvm_analysis_port #(axi4_write_data_pkt_t) write_data_every_beat_ap;
    uvm_analysis_port #(axi4_write_resp_pkt_t) write_resp_ap;
    uvm_analysis_port #(axi4_write_resp_pkt_t) write_resp_advance_copy_ap;
    uvm_analysis_port #(ace_snoop_addr_pkt_t)  snoop_addr_ap;
    uvm_analysis_port #(ace_snoop_data_pkt_t)  snoop_data_ap;
    uvm_analysis_port #(ace_snoop_resp_pkt_t)  snoop_resp_ap;
    
    //----------------------------------------------------------------------- 
    // New
    //----------------------------------------------------------------------- 

    function new(string name = "axi_master_monitor", uvm_component parent = null);
        super.new(name,parent);
    endfunction : new

    //----------------------------------------------------------------------- 
    // Build phase
    //----------------------------------------------------------------------- 
    
    function void build_phase(uvm_phase phase);
        read_addr_ap               = new("read_addr_ap", this);
        write_addr_ap              = new("write_addr_ap", this);
        read_data_ap               = new("read_data_ap", this);
        read_data_every_beat_ap    = new("read_data_every_beat_ap", this);
        read_data_advance_copy_ap  = new("read_data_advance_copy_ap", this);
        write_data_ap              = new("write_data_ap", this);
        write_data_every_beat_ap   = new("write_data_every_beat_ap", this);
        write_resp_ap              = new("write_resp_ap", this);
        write_resp_advance_copy_ap = new("write_resp_advance_copy_ap", this);
        snoop_addr_ap              = new("snoop_addr_ap", this);
        snoop_data_ap              = new("snoop_data_ap", this);
        snoop_resp_ap              = new("snoop_resp_ap", this);
    endfunction : build_phase

    //----------------------------------------------------------------------- 
    // Connect phase
    //----------------------------------------------------------------------- 

    function void connect_phase(uvm_phase phase);
    endfunction : connect_phase

    //-----------------------------------------------------------------------
    // Run phase
    //----------------------------------------------------------------------- 

    task run_phase(uvm_phase phase);
        wait(m_vif.rst_n == 1); 
        fork 
            monitor_read_addr_loop();
            monitor_write_addr_loop();
            monitor_read_data_loop();
            monitor_write_data_loop();
            monitor_write_data_every_beat_loop();
            monitor_read_data_every_beat_loop();
            monitor_write_resp_loop();
            if (m_intf_type == IS_ACE_INTF) begin
                fork
                    monitor_snoop_addr_loop();
                    monitor_snoop_resp_loop();
                    monitor_snoop_data_loop();
                join
            end
        join
    endtask : run_phase

    //-----------------------------------------------------------------------
    // Monitor read address loop
    //----------------------------------------------------------------------- 

    task monitor_read_addr_loop;
        ace_read_addr_pkt_t pkt;
        pkt = new();

        forever begin
            m_vif.collect_ace_master_read_addr_channel(pkt);
            if ((m_vif.rst_n == 0) ||(m_vif.vif_rst_n == 0)) begin
                continue;
            end
            read_addr_ap.write(pkt);
            if (m_intf_type == IS_ACE_INTF) begin
                `uvm_info(get_full_name(), pkt.sprint_pkt(), UVM_HIGH);
                if($test$plusargs("en_perf_trace")) begin
                    $fdisplay(file_handle, "REQ=ACE_AR %s", pkt.sprint_pkt());
                end
            end
            else if (m_intf_type == IS_AXI4_INTF) begin
                axi4_read_addr_pkt_t m_temp_pkt;
                m_temp_pkt = axi4_read_addr_pkt_t'(pkt);
                `uvm_info(get_full_name(), m_temp_pkt.sprint_pkt(), UVM_HIGH);
                if($test$plusargs("en_perf_trace")) begin
                    $fdisplay(file_handle, "REQ=AXI_AR %s", pkt.sprint_pkt());
                end
            end
        end
    endtask : monitor_read_addr_loop

    //-----------------------------------------------------------------------
    // Monitor write address loop
    //----------------------------------------------------------------------- 

    task monitor_write_addr_loop;
        ace_write_addr_pkt_t pkt;
        pkt = new();

        forever begin
            m_vif.collect_ace_master_write_addr_channel(pkt);
            if ((m_vif.rst_n == 0) ||(m_vif.vif_rst_n == 0)) begin
                continue;
            end
            write_addr_ap.write(pkt);
            if (m_intf_type == IS_ACE_INTF) begin
                `uvm_info(get_full_name(), pkt.sprint_pkt(), UVM_HIGH);
                $fdisplay(file_handle, "REQ=ACE_AW %s", pkt.sprint_pkt());
            end
            else if (m_intf_type == IS_AXI4_INTF) begin
                axi4_write_addr_pkt_t m_temp_pkt;
                m_temp_pkt = axi4_write_addr_pkt_t'(pkt);
                `uvm_info(get_full_name(), m_temp_pkt.sprint_pkt(), UVM_HIGH);
                if($test$plusargs("en_perf_trace")) begin
                    $fdisplay(file_handle, "REQ=AXI_AW %s", m_temp_pkt.sprint_pkt());
                end
            end
        end
    endtask : monitor_write_addr_loop

    //-----------------------------------------------------------------------
    // Monitor read data loop
    //----------------------------------------------------------------------- 

    task monitor_read_data_loop;
        ace_read_data_pkt_t pkt;
        semaphore           s_read_data = new(1);;
        pkt = new();

        forever begin
            m_vif.collect_ace_master_read_data_channel(pkt);
            if ((m_vif.rst_n == 0) ||(m_vif.vif_rst_n == 0)) begin
                continue;
            end
            fork 
                begin
                    ace_read_data_pkt_t pkt_tmp;
                    pkt_tmp = new();
                    pkt_tmp.copy(pkt);
                    read_data_advance_copy_ap.write(pkt_tmp);
                    <% if (obj.fnNativeInterface == "ACE" || obj.fnNativeInterface == "ACE5") { %>    
                        s_read_data.get();
                        m_vif.collect_ace_master_read_data_channel_rack();
                        s_read_data.put();
                    <%}%> 
                    if (delay_export == 1) begin
                        #0;
                    end
                    if (m_intf_type == IS_ACE_INTF) begin
                        `uvm_info(get_full_name(), pkt_tmp.sprint_pkt(), UVM_HIGH);
                        if($test$plusargs("en_perf_trace")) begin
                            $fdisplay(file_handle, "REQ=ACE_R %s", pkt_tmp.sprint_pkt());
                        end
                    end
                    else if (m_intf_type == IS_AXI4_INTF) begin
                        axi4_read_data_pkt_t m_temp_pkt;
                        m_temp_pkt = axi4_read_data_pkt_t'(pkt_tmp);
                        `uvm_info(get_full_name(), m_temp_pkt.sprint_pkt(), UVM_HIGH);
                        if($test$plusargs("en_perf_trace")) begin
                            $fdisplay(file_handle, "REQ=AXI_R %s", m_temp_pkt.sprint_pkt());
                        end
                    end
                    read_data_ap.write(pkt_tmp);
                end
            join_none
        end
    endtask : monitor_read_data_loop

    task monitor_read_data_every_beat_loop;
        ace_read_data_pkt_t pkt;
        pkt = new();

        forever begin
            m_vif.collect_ace_master_read_data_channel_every_beat(pkt);
            if ((m_vif.rst_n == 0) ||(m_vif.vif_rst_n == 0)) begin
                continue;
            end
            fork 
                begin
                    ace_read_data_pkt_t pkt_tmp;
                    pkt_tmp = new();
                    pkt_tmp.copy(pkt);
                    if (m_intf_type == IS_ACE_INTF) begin
                        `uvm_info(get_full_name(), pkt_tmp.sprint_pkt(), UVM_HIGH);
                    end
                    else if (m_intf_type == IS_AXI4_INTF) begin
                        axi4_read_data_pkt_t m_temp_pkt;
                        m_temp_pkt = axi4_read_data_pkt_t'(pkt_tmp);
                        `uvm_info(get_full_name(), m_temp_pkt.sprint_pkt(), UVM_HIGH);
                    end
                    read_data_every_beat_ap.write(pkt);
                end
            join
        end
    endtask : monitor_read_data_every_beat_loop

    //-----------------------------------------------------------------------
    // Monitor write data loop
    //----------------------------------------------------------------------- 

    task monitor_write_data_loop;
        ace_write_data_pkt_t pkt;
        pkt = new();

        forever begin
            m_vif.collect_ace_master_write_data_channel(pkt);
            if ((m_vif.rst_n == 0) ||(m_vif.vif_rst_n == 0)) begin
                continue;
            end
            write_data_ap.write(pkt);
            if (m_intf_type == IS_ACE_INTF) begin
                `uvm_info(get_full_name(), pkt.sprint_pkt(), UVM_HIGH);
                if($test$plusargs("en_perf_trace")) begin
                    $fdisplay(file_handle, "REQ=ACE_W %s", pkt.sprint_pkt());
                end
            end
            else if (m_intf_type == IS_AXI4_INTF) begin
                axi4_write_data_pkt_t m_temp_pkt;
                m_temp_pkt = axi4_write_data_pkt_t'(pkt);
                `uvm_info(get_full_name(), m_temp_pkt.sprint_pkt(), UVM_HIGH);
                $fdisplay(file_handle, "REQ=AXI_W %s", m_temp_pkt.sprint_pkt());
            end
        end
    endtask : monitor_write_data_loop

    task monitor_write_data_every_beat_loop;
        ace_write_data_pkt_t pkt;
        pkt = new();

        forever begin
            m_vif.collect_ace_master_write_data_channel_every_beat(pkt);
            `ifdef QUESTA
            #0; //QUESTA
            `endif
<% if(obj.testBench == 'dii' || obj.testBench == 'fsys') { %>
`ifdef VCS
              #0;
`endif // `ifdef VCS 
<% } %>

            if ((m_vif.rst_n == 0) ||(m_vif.vif_rst_n == 0)) begin
                continue;
            end
            write_data_every_beat_ap.write(pkt);
            if (m_intf_type == IS_ACE_INTF) begin
                `uvm_info(get_full_name(), pkt.sprint_pkt(), UVM_HIGH);
            end
            else if (m_intf_type == IS_AXI4_INTF) begin
                axi4_write_data_pkt_t m_temp_pkt;
                m_temp_pkt = axi4_write_data_pkt_t'(pkt);
                uvm_report_info(get_full_name(), m_temp_pkt.sprint_pkt(), UVM_HIGH);
            end
        end
    endtask : monitor_write_data_every_beat_loop

    //-----------------------------------------------------------------------
    // Monitor write resp loop
    //----------------------------------------------------------------------- 

    task monitor_write_resp_loop;
        ace_write_resp_pkt_t pkt;
        semaphore            s_write_resp = new(1);
        pkt = new();

        forever begin
            m_vif.collect_ace_master_write_resp_channel(pkt);
            if ((m_vif.rst_n == 0) ||(m_vif.vif_rst_n == 0)) begin
                continue;
            end
            fork 
                begin
                    ace_write_resp_pkt_t pkt_tmp;
                    pkt_tmp = new();
                    pkt_tmp.copy(pkt);
                    write_resp_advance_copy_ap.write(pkt_tmp);
<% if (obj.fnNativeInterface == "ACE" || obj.fnNativeInterface == "ACE5") { %>    
                    s_write_resp.get();
                    m_vif.collect_ace_master_write_resp_channel_wack();
                    s_write_resp.put();
<% } %> 
                    if (delay_export == 1) begin
                        #0;
                    end
                    if (m_intf_type == IS_ACE_INTF) begin
                        `uvm_info(get_full_name(), pkt_tmp.sprint_pkt(), UVM_HIGH);
                        if($test$plusargs("en_perf_trace")) begin
                            $fdisplay(file_handle, "REQ=ACE_B %s", pkt_tmp.sprint_pkt());
                        end
                    end
                    else if (m_intf_type == IS_AXI4_INTF) begin
                        axi4_write_resp_pkt_t m_temp_pkt;
                        m_temp_pkt = axi4_write_resp_pkt_t'(pkt_tmp);
                        `uvm_info(get_full_name(), m_temp_pkt.sprint_pkt(), UVM_HIGH);
                        if($test$plusargs("en_perf_trace")) begin
                            $fdisplay(file_handle, "REQ=AXI_B %s", m_temp_pkt.sprint_pkt());
                        end
                    end
                    write_resp_ap.write(pkt_tmp);
                end
            join_none
        end
    endtask : monitor_write_resp_loop

    //-----------------------------------------------------------------------
    // Monitor snoop address loop
    //----------------------------------------------------------------------- 

    task monitor_snoop_addr_loop;
        ace_snoop_addr_pkt_t pkt;
        pkt = new();

        forever begin
            m_vif.collect_ace_master_snoop_addr_channel(pkt);
            if ((m_vif.rst_n == 0) ||(m_vif.vif_rst_n == 0)) begin
                continue;
            end
            if (delay_export == 1) begin
                #0;
            end
            snoop_addr_ap.write(pkt);
            `uvm_info(get_full_name(), pkt.sprint_pkt(), UVM_HIGH);
            if($test$plusargs("en_perf_trace")) begin
                $fdisplay(file_handle, "REQ=ACE_SNP_ADDR %s", pkt.sprint_pkt());
            end
        end
    endtask : monitor_snoop_addr_loop

    //-----------------------------------------------------------------------
    // Monitor snoop resp loop
    //----------------------------------------------------------------------- 

    task monitor_snoop_resp_loop;
        ace_snoop_resp_pkt_t pkt;
        pkt = new();

        forever begin
            m_vif.collect_ace_master_snoop_resp_channel(pkt);
            if ((m_vif.rst_n == 0) ||(m_vif.vif_rst_n == 0)) begin
                continue;
            end
            snoop_resp_ap.write(pkt);
            `uvm_info(get_full_name(), pkt.sprint_pkt(), UVM_HIGH);
            if($test$plusargs("en_perf_trace")) begin
                $fdisplay(file_handle, "REQ=ACE_SNP_RSP %s", pkt.sprint_pkt());
            end
        end
    endtask : monitor_snoop_resp_loop

    //-----------------------------------------------------------------------
    // Monitor snoop data loop
    //----------------------------------------------------------------------- 

    task monitor_snoop_data_loop;
        ace_snoop_data_pkt_t pkt;
        pkt = new();

        forever begin
            m_vif.collect_ace_master_snoop_data_channel(pkt);
            if ((m_vif.rst_n == 0) ||(m_vif.vif_rst_n == 0)) begin
                continue;
            end
            snoop_data_ap.write(pkt);
            `uvm_info(get_full_name(), pkt.sprint_pkt(), UVM_HIGH);
            if($test$plusargs("en_perf_trace")) begin
                $fdisplay(file_handle, "REQ=ACE_SNP_DATA %s", pkt.sprint_pkt());
            end
        end
    endtask : monitor_snoop_data_loop

endclass : axi_master_monitor

//----------------------------------------------------------------------- 
// AXI Slave Monitor
//----------------------------------------------------------------------- 

class axi_slave_monitor extends uvm_component;

    `uvm_component_param_utils(axi_slave_monitor);

    virtual <%=obj.BlockId + '_axi_if'%>       m_vif;
    e_axi_interface_type m_intf_type;
    bit                  delay_export;

    uvm_analysis_port #(axi4_read_addr_pkt_t) read_addr_ap;
    uvm_analysis_port #(axi4_write_addr_pkt_t) write_addr_ap;
    uvm_analysis_port #(axi4_read_data_pkt_t) read_data_ap;
    uvm_analysis_port #(axi4_write_data_pkt_t) write_data_ap;
    uvm_analysis_port #(axi4_write_resp_pkt_t) write_resp_ap;
    uvm_analysis_port #(ace_snoop_addr_pkt_t) snoop_addr_ap;
    uvm_analysis_port #(ace_snoop_data_pkt_t) snoop_data_ap;
    uvm_analysis_port #(ace_snoop_resp_pkt_t) snoop_resp_ap;
    
    //----------------------------------------------------------------------- 
    // New
    //----------------------------------------------------------------------- 

    function new(string name = "axi_slave_monitor", uvm_component parent = null);
        super.new(name,parent);
    endfunction : new

    //----------------------------------------------------------------------- 
    // Build phase
    //----------------------------------------------------------------------- 
    
    function void build_phase(uvm_phase phase);
        read_addr_ap = new("read_addr_ap", this);
        write_addr_ap = new("write_addr_ap", this);
        read_data_ap = new("read_data_ap", this);
        write_data_ap = new("write_data_ap", this);
        write_resp_ap = new("write_resp_ap", this);
        snoop_addr_ap = new("snoop_addr_ap", this);
        snoop_data_ap = new("snoop_data_ap", this);
        snoop_resp_ap = new("snoop_resp_ap", this);
    endfunction : build_phase

    //----------------------------------------------------------------------- 
    // Connect phase
    //----------------------------------------------------------------------- 

    function void connect_phase(uvm_phase phase);
        if(!uvm_config_db #(virtual <%=obj.BlockId + '_axi_if'%>)::get(this, "", "m_<%=obj.BlockId%>_axi_slv_if", m_vif)) begin
            `uvm_error(get_full_name(), $sformatf("Cannot find m_<%=obj.BlockId + '_axi_slv_if'%> in config db")); 
        end
    endfunction : connect_phase

    //-----------------------------------------------------------------------
    // Run phase
    //----------------------------------------------------------------------- 

    task run_phase(uvm_phase phase);
        wait(m_vif.rst_n == 1); 
        fork 
            monitor_read_addr_loop();
            monitor_write_addr_loop();
            monitor_read_data_loop();
            monitor_write_data_loop();
            monitor_write_resp_loop();
            if (m_intf_type == IS_ACE_INTF) begin
                fork
                    monitor_snoop_addr_loop();
                    monitor_snoop_resp_loop();
                    monitor_snoop_data_loop();
                join
            end
        join 
    endtask : run_phase

    //-----------------------------------------------------------------------
    // Monitor read address loop
    //----------------------------------------------------------------------- 

    task monitor_read_addr_loop;
        ace_read_addr_pkt_t pkt;
        pkt = new();

        forever begin
            m_vif.collect_ace_slave_read_addr_channel(pkt);
            if ((m_vif.rst_n == 0) ||(m_vif.vif_rst_n == 0)) begin
                continue;
            end
            if (delay_export == 1) begin
               `uvm_info("AXI_MONITOR", "ace slv ar delay_export", UVM_HIGH)
                #0;
            end
            read_addr_ap.write(pkt);
            if (m_intf_type == IS_ACE_INTF) begin
                `uvm_info(get_full_name(), pkt.sprint_pkt(), UVM_HIGH);
            end
            else if (m_intf_type == IS_AXI4_INTF) begin
                axi4_read_addr_pkt_t m_temp_pkt;
                m_temp_pkt = axi4_read_addr_pkt_t'(pkt);
                `uvm_info(get_full_name(), m_temp_pkt.sprint_pkt(), UVM_HIGH);
            end
        end
    endtask : monitor_read_addr_loop

    //-----------------------------------------------------------------------
    // Monitor write address loop
    //----------------------------------------------------------------------- 

    task monitor_write_addr_loop;
        ace_write_addr_pkt_t pkt;
        pkt = new();

        forever begin
            m_vif.collect_ace_slave_write_addr_channel(pkt);
            if ((m_vif.rst_n == 0) ||(m_vif.vif_rst_n == 0)) begin
                continue;
            end
            if (delay_export == 1) begin
               `uvm_info("AXI_MONITOR", "ace slv aw delay_export", UVM_HIGH)
                #0;
            end
            write_addr_ap.write(pkt);
            if (m_intf_type == IS_ACE_INTF) begin
                `uvm_info(get_full_name(), pkt.sprint_pkt(), UVM_HIGH);
            end
            else if (m_intf_type == IS_AXI4_INTF) begin
                axi4_write_addr_pkt_t m_temp_pkt;
                m_temp_pkt = axi4_write_addr_pkt_t'(pkt);
                `uvm_info(get_full_name(), m_temp_pkt.sprint_pkt(), UVM_HIGH);
            end
        end
    endtask : monitor_write_addr_loop

    //-----------------------------------------------------------------------
    // Monitor read data loop
    //----------------------------------------------------------------------- 

    task monitor_read_data_loop;
        ace_read_data_pkt_t pkt;
        pkt = new();

        forever begin
            m_vif.collect_ace_slave_read_data_channel(pkt);
            if ((m_vif.rst_n == 0) ||(m_vif.vif_rst_n == 0)) begin
                continue;
            end
            read_data_ap.write(pkt);
            if (m_intf_type == IS_ACE_INTF) begin
                `uvm_info(get_full_name(), pkt.sprint_pkt(), UVM_HIGH);
            end
            else if (m_intf_type == IS_AXI4_INTF) begin
                axi4_read_data_pkt_t m_temp_pkt;
                m_temp_pkt = axi4_read_data_pkt_t'(pkt);
                `uvm_info(get_full_name(), m_temp_pkt.sprint_pkt(), UVM_HIGH);
            end
        end
    endtask : monitor_read_data_loop

    //-----------------------------------------------------------------------
    // Monitor write data loop
    //----------------------------------------------------------------------- 

    task monitor_write_data_loop;
        ace_write_data_pkt_t pkt;
        pkt = new();

        forever begin
            m_vif.collect_ace_slave_write_data_channel(pkt);
            if ((m_vif.rst_n == 0) ||(m_vif.vif_rst_n == 0)) begin
                continue;
            end
            if (delay_export == 1) begin
               `uvm_info("AXI_MONITOR", "ace slv w delay_export", UVM_HIGH)
                #0;
            end
            write_data_ap.write(pkt);
            if (m_intf_type == IS_ACE_INTF) begin
                `uvm_info(get_full_name(), pkt.sprint_pkt(), UVM_HIGH);
            end
            else if (m_intf_type == IS_AXI4_INTF) begin
                axi4_write_data_pkt_t m_temp_pkt;
                m_temp_pkt = axi4_write_data_pkt_t'(pkt);
                `uvm_info(get_full_name(), m_temp_pkt.sprint_pkt(), UVM_HIGH);
            end
        end
    endtask : monitor_write_data_loop

    //-----------------------------------------------------------------------
    // Monitor write resp loop
    //----------------------------------------------------------------------- 

    task monitor_write_resp_loop;
        ace_write_resp_pkt_t pkt;
        pkt = new();

        forever begin
            m_vif.collect_ace_slave_write_resp_channel(pkt);
            if ((m_vif.rst_n == 0) ||(m_vif.vif_rst_n == 0)) begin
                continue;
            end
            write_resp_ap.write(pkt);
            if (m_intf_type == IS_ACE_INTF) begin
                `uvm_info(get_full_name(), pkt.sprint_pkt(), UVM_HIGH);
            end
            else if (m_intf_type == IS_AXI4_INTF) begin
                axi4_write_resp_pkt_t m_temp_pkt;
                m_temp_pkt = axi4_write_resp_pkt_t'(pkt);
                `uvm_info(get_full_name(), m_temp_pkt.sprint_pkt(), UVM_HIGH);
            end
        end
    endtask : monitor_write_resp_loop

    //-----------------------------------------------------------------------
    // Monitor snoop address loop
    //----------------------------------------------------------------------- 

    task monitor_snoop_addr_loop;
        ace_snoop_addr_pkt_t pkt;
        pkt = new();

        forever begin
            m_vif.collect_ace_slave_snoop_addr_channel(pkt);
            if ((m_vif.rst_n == 0) ||(m_vif.vif_rst_n == 0)) begin
                continue;
            end
            snoop_addr_ap.write(pkt);
            `uvm_info(get_full_name(), pkt.sprint_pkt(), UVM_HIGH);
        end
    endtask : monitor_snoop_addr_loop

    //-----------------------------------------------------------------------
    // Monitor snoop resp loop
    //----------------------------------------------------------------------- 

    task monitor_snoop_resp_loop;
        ace_snoop_resp_pkt_t pkt;
        pkt = new();

        forever begin
            m_vif.collect_ace_slave_snoop_resp_channel(pkt);
            if ((m_vif.rst_n == 0) ||(m_vif.vif_rst_n == 0)) begin
                continue;
            end
            if (delay_export == 1) begin
                #0;
            end
            snoop_resp_ap.write(pkt);
            `uvm_info(get_full_name(), pkt.sprint_pkt(), UVM_HIGH);
        end
    endtask : monitor_snoop_resp_loop

    //-----------------------------------------------------------------------
    // Monitor snoop data loop
    //----------------------------------------------------------------------- 

    task monitor_snoop_data_loop;
        ace_snoop_data_pkt_t pkt;
        pkt = new();

        forever begin
            m_vif.collect_ace_slave_snoop_data_channel(pkt);
            if ((m_vif.rst_n == 0) ||(m_vif.vif_rst_n == 0)) begin
                continue;
            end
            if (delay_export == 1) begin
                #0;
            end
            snoop_data_ap.write(pkt);
            `uvm_info(get_full_name(), pkt.sprint_pkt(), UVM_HIGH);
        end
    endtask : monitor_snoop_data_loop

endclass : axi_slave_monitor

