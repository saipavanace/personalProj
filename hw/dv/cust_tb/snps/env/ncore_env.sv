<%const chipletObj = obj.lib.getAllChipletRefs();%>
`include "reg2axi_adapter.sv"
`include "reg2chi_adapter.sv"

<%if(process.env.MAESTRO_SERVER_DEBUG_MODE){%>
    `include "smi_widths.sv"
    `include "smi_types.sv"
    `include "smi_seq_item.sv"
    `include "smi_if.sv"
    `include "smi_monitor.sv"
    `include "ncore_perf_analyzer.sv"
    `include "ncore_base_scoreboard.sv"
<%}%>

<%if(chipletObj[0].useResiliency == 1){%>
    `include "ncore_fsc_system_register_map.sv"
<%}%>
<%if((chipletObj[0].useResiliency == 1) || (chipletObj[0].DebugApbInfo.length > 0)){%>
    `include "reg2apb_adapter.sv"
<%}%>
<%if(chipletObj[0].useResiliency == 1){%>
    parameter integer apb_dbg_id = 1;
<%}else{%>
    parameter integer apb_dbg_id = 0;
<%}%>

class ncore_env extends uvm_env;
    // AMBA System ENV 
    svt_amba_system_env m_amba_env;

    // Configuration class which is extended from AMBA System Configuration class.
    ncore_vip_configuration cfg;

    //address manager
    // addr_trans_mgr m_addr_mgr;

    //RAL model
    ral_sys_ncore regmodel;
    

    <%if(chipletObj[0].enInternalCode){%>
        bit perf_analyzer_en;
        bit base_scoreboard_en;
        ncore_perf_analyzer     m_perf_analyzer;
        ncore_base_scoreboard   m_base_scb;

        //AIU
        <%for(var idx = 0; idx < chipletObj[0].AiuInfo.length; idx++) {%>
            <%for (var i = 0; i < chipletObj[0].AiuInfo[idx].smiPortParams.tx.length; i++) { %>
                virtual smi_if  <%=chipletObj[0].AiuInfo[idx].strRtlNamePrefix%>_smi<%=i%>_tx_port_if;
                smi_monitor     m_<%=chipletObj[0].AiuInfo[idx].strRtlNamePrefix%>_smi<%=i%>_tx_monitor;
            <% } %>
            <%for (var i = 0; i < chipletObj[0].AiuInfo[idx].smiPortParams.rx.length; i++) { %>
                virtual smi_if  <%=chipletObj[0].AiuInfo[idx].strRtlNamePrefix%>_smi<%=i%>_rx_port_if;
                smi_monitor     m_<%=chipletObj[0].AiuInfo[idx].strRtlNamePrefix%>_smi<%=i%>_rx_monitor;
            <% } %>
        <% } %>

        // DMI
        <%for(var pidx = 0; pidx < chipletObj[0].nDMIs; pidx++) { %>
            <%for (var i = 0; i < chipletObj[0].DmiInfo[pidx].smiPortParams.tx.length; i++) { %>
                virtual smi_if  dmi<%=pidx%>_smi<%=i%>_tx_port_if;
                smi_monitor     m_dmi<%=pidx%>_smi<%=i%>_tx_monitor;
            <% } %>
            <%for (var i = 0; i < chipletObj[0].DmiInfo[pidx].smiPortParams.rx.length; i++) { %>
                virtual smi_if  dmi<%=pidx%>_smi<%=i%>_rx_port_if;
                smi_monitor     m_dmi<%=pidx%>_smi<%=i%>_rx_monitor;
            <% } %>
        <% } %>

        // DCE
        <%for(var pidx = 0; pidx < chipletObj[0].nDCEs; pidx++) { %>
            <%for (var i = 0; i < chipletObj[0].DceInfo[pidx].smiPortParams.tx.length; i++) { %>
                virtual smi_if  dce<%=pidx%>_smi<%=i%>_tx_port_if;
                smi_monitor     m_dce<%=pidx%>_smi<%=i%>_tx_monitor;
            <% } %>
            <%for (var i = 0; i < chipletObj[0].DceInfo[pidx].smiPortParams.rx.length; i++) { %>
                virtual smi_if  dce<%=pidx%>_smi<%=i%>_rx_port_if;
                smi_monitor     m_dce<%=pidx%>_smi<%=i%>_rx_monitor;
            <% } %>
        <% } %>

        // DII
        <%for(var pidx = 0; pidx < chipletObj[0].nDIIs; pidx++) { %>
            <%for (var i = 0; i < chipletObj[0].DiiInfo[pidx].smiPortParams.tx.length; i++) { %>
                virtual smi_if  dii<%=pidx%>_smi<%=i%>_tx_port_if;
                smi_monitor     m_dii<%=pidx%>_smi<%=i%>_tx_monitor;
            <% } %>
            <%for (var i = 0; i < chipletObj[0].DiiInfo[pidx].smiPortParams.rx.length; i++) { %>
                virtual smi_if  dii<%=pidx%>_smi<%=i%>_rx_port_if;
                smi_monitor     m_dii<%=pidx%>_smi<%=i%>_rx_monitor;
            <% } %>
        <% } %>
     <% } %>

    <%if(chipletObj[0].useResiliency == 1){%>
        ral_sys_resiliency resiliency_m_regs;
    <%}%>
    <% if(chipletObj[0].DebugApbInfo.length > 0){ %>
        ral_sys_ncore debug_m_regs;
    <% } %>
    // UVM Component Utility macro 
    `uvm_component_utils(ncore_env)

    // Class Constructor 
    function new (string name="ncore_env", uvm_component parent=null);
        super.new (name, parent);
    endfunction

    // Build and configure the AMBA System ENV 
    virtual function void build_phase(uvm_phase phase);
        `uvm_info("build_phase", "Entered...",UVM_LOW)

        super.build_phase(phase);
      
        if (!uvm_config_db#(ncore_vip_configuration)::get(this, "", "cfg", cfg)) begin
            cfg = ncore_vip_configuration::type_id::create("cfg");
            cfg.set_amba_sys_config();
        end

        <%if(chipletObj[0].enInternalCode){%>
            if (!$value$plusargs("perf_analyzer_en=%0d",perf_analyzer_en)) begin
                perf_analyzer_en = 0;
            end
            if (!$value$plusargs("base_scoreboard_en=%0d",base_scoreboard_en)) begin
                base_scoreboard_en = 0;
            end
            //AIU
            <%for(var idx = 0; idx < chipletObj[0].AiuInfo.length; idx++) {%>
                <%for (var i = 0; i < chipletObj[0].AiuInfo[idx].smiPortParams.tx.length; i++) { %>
                    if(!uvm_config_db #(virtual smi_if)::get(this,
                                                             "",
                                                             "<%=chipletObj[0].AiuInfo[idx].strRtlNamePrefix%>_smi<%=i%>_tx_port_if",
                                                             <%=chipletObj[0].AiuInfo[idx].strRtlNamePrefix%>_smi<%=i%>_tx_port_if)) begin
                        `uvm_fatal("Environment Build_phase", "Couldn't get the <%=chipletObj[0].AiuInfo[idx].strRtlNamePrefix%>_smi<%=i%>_tx_port_if");
                    end
                <%}%>
                <%for (var i = 0; i < chipletObj[0].AiuInfo[idx].smiPortParams.rx.length; i++) { %>
                    if(!uvm_config_db #(virtual smi_if)::get(this,
                                                             "",
                                                             "<%=chipletObj[0].AiuInfo[idx].strRtlNamePrefix%>_smi<%=i%>_rx_port_if",
                                                             <%=chipletObj[0].AiuInfo[idx].strRtlNamePrefix%>_smi<%=i%>_rx_port_if)) begin
                        `uvm_fatal("Environment Build_phase", "Couldn't get the <%=chipletObj[0].AiuInfo[idx].strRtlNamePrefix%>_smi<%=i%>_rx_port_if");
                    end
                <%}%>
            <%}%>

            // DMI
            <%for(var pidx = 0; pidx < chipletObj[0].nDMIs; pidx++) { %>
                <%for (var i = 0; i < chipletObj[0].DmiInfo[pidx].smiPortParams.tx.length; i++) { %>
                    if(!uvm_config_db #(virtual smi_if)::get(this,
                                                             "",
                                                             "dmi<%=pidx%>_smi<%=i%>_tx_port_if",
                                                             dmi<%=pidx%>_smi<%=i%>_tx_port_if)) begin
                        `uvm_fatal("Environment Build_phase", "Couldn't get the dmi<%=pidx%>_smi<%=i%>_tx_port_if");
                    end
                <%}%>
                <%for (var i = 0; i < chipletObj[0].DmiInfo[pidx].smiPortParams.rx.length; i++) { %>
                    if(!uvm_config_db #(virtual smi_if)::get(this,
                                                             "",
                                                             "dmi<%=pidx%>_smi<%=i%>_rx_port_if",
                                                             dmi<%=pidx%>_smi<%=i%>_rx_port_if))begin
                        `uvm_fatal("Environment Build_phase", "Couldn't get the dmi<%=pidx%>_smi<%=i%>_rx_port_if");
                    end
                <%}%>
            <%}%>

            // DCE
            <%for(var pidx = 0; pidx < chipletObj[0].nDCEs; pidx++) { %>
                <%for (var i = 0; i < chipletObj[0].DceInfo[pidx].smiPortParams.tx.length; i++) { %>
                    if(!uvm_config_db #(virtual smi_if)::get(this,
                                                             "",
                                                             "dce<%=pidx%>_smi<%=i%>_tx_port_if",
                                                             dce<%=pidx%>_smi<%=i%>_tx_port_if))begin
                        `uvm_fatal("Environment Build_phase", "Couldn't get the dce<%=pidx%>_smi<%=i%>_tx_port_if");
                    end
                <%}%>
                <%for (var i = 0; i < chipletObj[0].DceInfo[pidx].smiPortParams.rx.length; i++) { %>
                    if(!uvm_config_db #(virtual smi_if)::get(this,
                                                             "",
                                                             "dce<%=pidx%>_smi<%=i%>_rx_port_if",
                                                             dce<%=pidx%>_smi<%=i%>_rx_port_if)) begin
                        `uvm_fatal("Environment Build_phase", "Couldn't get the dce<%=pidx%>_smi<%=i%>_rx_port_if");
                    end
                <%}%>
            <%}%>

            // DII
            <%for(var pidx = 0; pidx < chipletObj[0].nDIIs; pidx++) { %>
                <%for (var i = 0; i < chipletObj[0].DiiInfo[pidx].smiPortParams.tx.length; i++) { %>
                    if(!uvm_config_db #(virtual smi_if)::get(this,
                                                             "",
                                                             "dii<%=pidx%>_smi<%=i%>_tx_port_if",
                                                             dii<%=pidx%>_smi<%=i%>_tx_port_if))begin
                        `uvm_fatal("Environment Build_phase", "Couldn't get the dii<%=pidx%>_smi<%=i%>_tx_port_if");
                    end
                <%}%>
                <%for (var i = 0; i < chipletObj[0].DiiInfo[pidx].smiPortParams.rx.length; i++) { %>
                    if(!uvm_config_db #(virtual smi_if)::get(this,
                                                             "",
                                                             "dii<%=pidx%>_smi<%=i%>_rx_port_if",
                                                             dii<%=pidx%>_smi<%=i%>_rx_port_if))begin
                        `uvm_fatal("Environment Build_phase", "Couldn't get the dii<%=pidx%>_smi<%=i%>_rx_port_if");
                    end
                <%}%>
            <%}%>
        <%}%>

        // Apply the configuration to the AMBA System ENV 
        uvm_config_db#(svt_amba_system_configuration)::set(this, "m_amba_env", "cfg", cfg);

        // Construct the AMBA system ENV 
        m_amba_env = svt_amba_system_env::type_id::create("m_amba_env", this);

        <%if(chipletObj[0].enInternalCode){%>
            if(perf_analyzer_en)begin
                m_perf_analyzer = ncore_perf_analyzer::type_id::create("m_perf_analyzer", this);
            end
            if(base_scoreboard_en)begin
                m_base_scb = ncore_base_scoreboard::type_id::create("m_base_scb",this);
            end
            //AIU
            <%for(var idx = 0; idx < chipletObj[0].AiuInfo.length; idx++) {%>
                <%for (var i = 0; i < chipletObj[0].AiuInfo[idx].smiPortParams.tx.length; i++) { %>
                    m_<%=chipletObj[0].AiuInfo[idx].strRtlNamePrefix%>_smi<%=i%>_tx_monitor = smi_monitor#(SMI_TRANSMITTER, <%=i%>)::type_id::create("m_<%=chipletObj[0].AiuInfo[idx].strRtlNamePrefix%>_smi<%=i%>_tx_monitor", this);
                    m_<%=chipletObj[0].AiuInfo[idx].strRtlNamePrefix%>_smi<%=i%>_tx_monitor.m_vif = <%=chipletObj[0].AiuInfo[idx].strRtlNamePrefix%>_smi<%=i%>_tx_port_if;
                <%}%>
                <%for (var i = 0; i < chipletObj[0].AiuInfo[idx].smiPortParams.rx.length; i++) { %>
                    m_<%=chipletObj[0].AiuInfo[idx].strRtlNamePrefix%>_smi<%=i%>_rx_monitor = smi_monitor#(SMI_RECEIVER, <%=i%>)::type_id::create("m_<%=chipletObj[0].AiuInfo[idx].strRtlNamePrefix%>_smi<%=i%>_rx_monitor", this);
                    m_<%=chipletObj[0].AiuInfo[idx].strRtlNamePrefix%>_smi<%=i%>_rx_monitor.m_vif = <%=chipletObj[0].AiuInfo[idx].strRtlNamePrefix%>_smi<%=i%>_rx_port_if;
                <%}%>
            <%}%>

            // DMI
            <%for(var pidx = 0; pidx < chipletObj[0].nDMIs; pidx++) { %>
                <%for (var i = 0; i < chipletObj[0].DmiInfo[pidx].smiPortParams.tx.length; i++) { %>
                    m_dmi<%=pidx%>_smi<%=i%>_tx_monitor = smi_monitor#(SMI_TRANSMITTER, <%=i%>)::type_id::create("m_dmi<%=pidx%>_smi<%=i%>_tx_monitor", this);
                    m_dmi<%=pidx%>_smi<%=i%>_tx_monitor.m_vif = dmi<%=pidx%>_smi<%=i%>_tx_port_if;
                <%}%>
                <%for (var i = 0; i < chipletObj[0].DmiInfo[pidx].smiPortParams.rx.length; i++) { %>
                    m_dmi<%=pidx%>_smi<%=i%>_rx_monitor = smi_monitor#(SMI_RECEIVER, <%=i%>)::type_id::create("m_dmi<%=pidx%>_smi<%=i%>_rx_monitor", this);
                    m_dmi<%=pidx%>_smi<%=i%>_rx_monitor.m_vif = dmi<%=pidx%>_smi<%=i%>_rx_port_if;
                <%}%>
            <%}%>

            // DCE
            <%for(var pidx = 0; pidx < chipletObj[0].nDCEs; pidx++) { %>
                <%for (var i = 0; i < chipletObj[0].DceInfo[pidx].smiPortParams.tx.length; i++) { %>
                    m_dce<%=pidx%>_smi<%=i%>_tx_monitor = smi_monitor#(SMI_TRANSMITTER, <%=i%>)::type_id::create("m_dce<%=pidx%>_smi<%=i%>_tx_monitor", this);
                    m_dce<%=pidx%>_smi<%=i%>_tx_monitor.m_vif = dce<%=pidx%>_smi<%=i%>_tx_port_if;
                <%}%>
                <%for (var i = 0; i < chipletObj[0].DceInfo[pidx].smiPortParams.rx.length; i++) { %>
                    m_dce<%=pidx%>_smi<%=i%>_rx_monitor = smi_monitor#(SMI_RECEIVER, <%=i%>)::type_id::create("m_dce<%=pidx%>_smi<%=i%>_rx_monitor", this);
                    m_dce<%=pidx%>_smi<%=i%>_rx_monitor.m_vif = dce<%=pidx%>_smi<%=i%>_rx_port_if;
                <%}%>
            <%}%>

            // DII
            <%for(var pidx = 0; pidx < chipletObj[0].nDIIs; pidx++) { %>
                <%for (var i = 0; i < chipletObj[0].DiiInfo[pidx].smiPortParams.tx.length; i++) { %>
                    m_dii<%=pidx%>_smi<%=i%>_tx_monitor = smi_monitor#(SMI_TRANSMITTER, <%=i%>)::type_id::create("m_dii<%=pidx%>_smi<%=i%>_tx_monitor", this);
                    m_dii<%=pidx%>_smi<%=i%>_tx_monitor.m_vif = dii<%=pidx%>_smi<%=i%>_tx_port_if;
                <%}%>
                <%for (var i = 0; i < chipletObj[0].DiiInfo[pidx].smiPortParams.rx.length; i++) { %>
                    m_dii<%=pidx%>_smi<%=i%>_rx_monitor = smi_monitor#(SMI_RECEIVER, <%=i%>)::type_id::create("m_dii<%=pidx%>_smi<%=i%>_rx_monitor", this);
                    m_dii<%=pidx%>_smi<%=i%>_rx_monitor.m_vif = dii<%=pidx%>_smi<%=i%>_rx_port_if;
                <%}%>
            <%}%>
        <%}%>

        // Check if regmodel is passed to env if not then create and lock it
        if (regmodel == null) begin
            regmodel = ral_sys_ncore::type_id::create("regmodel");
            regmodel.build();
            `uvm_info("build_phase", "Reg Model created", UVM_LOW)
            //FIXME : 
            //uvm_config_db#(uvm_reg_block)::set(this, "m_amba_env.apb_system[0].master", "apb_regmodel", regmodel); //TODO
            //uvm_config_db#(uvm_reg_block)::set(this, "m_amba_env.apb_system[1].master", "apb_regmodel", regmodel); //TODO
            regmodel.lock_model();
            regmodel.reset();
        end

        <% if(chipletObj[0].useResiliency == 1){ %>
            if (resiliency_m_regs == null) begin
                resiliency_m_regs = ral_sys_resiliency::type_id::create("ral_sys_resiliency", this);
                resiliency_m_regs.build();
                `uvm_info("build_phase", "resiliency_m_regs Reg Model created", UVM_LOW)
                //FIXME : 
                //uvm_config_db#(uvm_reg_block)::set(this, "m_amba_env.apb_system[1].master", "apb_regmodel", resiliency_m_regs); //TODO
                resiliency_m_regs.lock_model();
                resiliency_m_regs.reset();
            end
        <%}%>

        <% if(chipletObj[0].DebugApbInfo.length > 0){ %>
            if (debug_m_regs == null) begin
              debug_m_regs = ral_sys_ncore::type_id::create("debug_m_regs", this);
              debug_m_regs.build();
              `uvm_info("build_phase", "debug_m_regs Reg Model created", UVM_LOW)
              debug_m_regs.lock_model();
              debug_m_regs.reset();
            end
        <% } %>

//-----
        <% var apb_sys = 0%>
        <% for (let i = 0; i < chipletObj.length; i++) { %>
            <%if(chipletObj[i].useResiliency == 1){%>
                uvm_config_db#(uvm_reg_block)::set(this, "m_amba_env.apb_system[<%=apb_sys%>].master", "apb_regmodel", resiliency_m_regs);
                <%apb_sys++%>
            <%} if(chipletObj[i].DebugApbInfo.length>0){%>
                uvm_config_db#(uvm_reg_block)::set(this, "m_amba_env.apb_system[<%=apb_sys%>].master", "apb_regmodel", regmodel);
                <%apb_sys++%>
            <%}%>
        <%}%>

//----
        // build address manager
        // m_addr_mgr = addr_trans_mgr::get_instance();
        // m_addr_mgr.gen_memory_map(); //FIXME: This is being done in ncore_system_tb_top. Is it better to move it here?

        if($test$plusargs("performance_test"))begin
            // set_type_override_by_type (svt_chi_rn_transaction::get_type(),cust_svt_chi_rn_transaction::get_type());
            // set_type_override_by_type (svt_chi_rn_snoop_transaction::get_type(),cust_svt_chi_rn_snoop_transaction::get_type());
        end
        // set_type_override_by_type (svt_axi_master_snoop_transaction::get_type(),cust_svt_axi_snoop_transaction::get_type());

        `uvm_info("build_phase", "Exiting...", UVM_LOW)
    endfunction

    function void connect_phase(uvm_phase phase);
        <%if(chipletObj[0].useResiliency == 1){ %>
            if (resiliency_m_regs.get_parent() == null) begin
                reg2apb_adapter reg2apb = new();
                reg2apb.p_cfg =  this.cfg.apb_sys_cfg[0];
                resiliency_m_regs.default_map.set_sequencer(m_amba_env.apb_system[0].master.sequencer,reg2apb);
                resiliency_m_regs.default_map.set_auto_predict(1);
            end
        <%}%>
        <%if(chipletObj[0].DebugApbInfo.length > 0){%>
            if (debug_m_regs.get_parent() == null) begin
                reg2apb_adapter reg2apb_dbg = new();
                reg2apb_dbg.p_cfg =  this.cfg.apb_sys_cfg[0];
                debug_m_regs.default_map.set_sequencer(m_amba_env.apb_system[apb_dbg_id].master.sequencer,reg2apb_dbg); //FIX ME : For multi apb system
                debug_m_regs.default_map.set_auto_predict(1);
            end
        <%}%>
        `uvm_info("connect_phase", "Entered...",UVM_LOW)

        <%if(chipletObj[0].enInternalCode){%>
            if(perf_analyzer_en) begin
                //AIU
                <%for(var idx = 0; idx < chipletObj[0].AiuInfo.length; idx++) {%>
                    <%for (var i = 0; i < chipletObj[0].AiuInfo[idx].smiPortParams.tx.length; i++) { %>
                        m_<%=chipletObj[0].AiuInfo[idx].strRtlNamePrefix%>_smi<%=i%>_tx_monitor.smi_ap.connect(m_perf_analyzer.smi_<%=chipletObj[0].AiuInfo[idx].strRtlNamePrefix%>_port);
                    <%}%>
                    <%for (var i = 0; i < chipletObj[0].AiuInfo[idx].smiPortParams.rx.length; i++) { %>
                        m_<%=chipletObj[0].AiuInfo[idx].strRtlNamePrefix%>_smi<%=i%>_rx_monitor.smi_ap.connect(m_perf_analyzer.smi_<%=chipletObj[0].AiuInfo[idx].strRtlNamePrefix%>_port);
                    <%}%>
                <%}%>

                // DMI
                <%for(var pidx = 0; pidx < chipletObj[0].nDMIs; pidx++) { %>
                    <%for (var i = 0; i < chipletObj[0].DmiInfo[pidx].smiPortParams.tx.length; i++) { %>
                        m_dmi<%=pidx%>_smi<%=i%>_tx_monitor.smi_ap.connect(m_perf_analyzer.smi_dmi<%=pidx%>_port);
                    <%}%>
                    <%for (var i = 0; i < chipletObj[0].DmiInfo[pidx].smiPortParams.rx.length; i++) { %>
                        m_dmi<%=pidx%>_smi<%=i%>_rx_monitor.smi_ap.connect(m_perf_analyzer.smi_dmi<%=pidx%>_port);
                    <%}%>
                <%}%>

                // DCE
                <%for(var pidx = 0; pidx < chipletObj[0].nDCEs; pidx++) { %>
                    <%for (var i = 0; i < chipletObj[0].DceInfo[pidx].smiPortParams.tx.length; i++) { %>
                        m_dce<%=pidx%>_smi<%=i%>_tx_monitor.smi_ap.connect(m_perf_analyzer.smi_dce<%=pidx%>_port);
                    <%}%>
                    <%for (var i = 0; i < chipletObj[0].DceInfo[pidx].smiPortParams.rx.length; i++) { %>
                        m_dce<%=pidx%>_smi<%=i%>_rx_monitor.smi_ap.connect(m_perf_analyzer.smi_dce<%=pidx%>_port);
                    <%}%>
                <%}%>

                // DII
                <%for(var pidx = 0; pidx < chipletObj[0].nDIIs; pidx++) { %>
                    <%for (var i = 0; i < chipletObj[0].DiiInfo[pidx].smiPortParams.tx.length; i++) { %>
                        m_dii<%=pidx%>_smi<%=i%>_tx_monitor.smi_ap.connect(m_perf_analyzer.smi_dii<%=pidx%>_port);
                    <%}%>
                    <%for (var i = 0; i < chipletObj[0].DiiInfo[pidx].smiPortParams.rx.length; i++) { %>
                        m_dii<%=pidx%>_smi<%=i%>_rx_monitor.smi_ap.connect(m_perf_analyzer.smi_dii<%=pidx%>_port);
                    <%}%>
                <%}%>
            end
        <%}%>

        <%if(chipletObj[0].enInternalCode){%>
            if(perf_analyzer_en) begin
                <%let chiIdx=0;%>
                <%let axiIdx=0;%>
                <% for(let idx = 0; idx < chipletObj[0].nAIUs; idx++) {%>
                     <%if(chipletObj[0].AiuInfo[idx].fnNativeInterface.includes('CHI')){%>
                        m_amba_env.chi_system[0].rn[<%=chiIdx%>].prot_mon.item_observed_port.connect(m_perf_analyzer.<%=chipletObj[0].AiuInfo[idx].strRtlNamePrefix%>_port);// CHI 
                        <%chiIdx++;%>
                    <%} else {%>
                        m_amba_env.axi_system[0].master[<%=axiIdx%>].monitor.item_observed_port.connect(m_perf_analyzer.<%=chipletObj[0].AiuInfo[idx].strRtlNamePrefix%>_port); //IOAIU
                        <%axiIdx++;%>
                    <%}%>
                <%}%>

                <%let slv_pidx=0;%>
                <%for(pidx = 0; pidx < chipletObj[0].nDMIs; pidx++) { %>
                    m_amba_env.axi_system[0].slave[<%=slv_pidx%>].monitor.item_observed_port.connect(m_perf_analyzer.<%=chipletObj[0].DmiInfo[pidx].strRtlNamePrefix%>_port); //DMI
                    <%slv_pidx++;%>
                <%}%>
                <%for(pidx = 0; pidx < chipletObj[0].nDIIs; pidx++) { %>
                    <%if(chipletObj[0].DiiInfo[pidx].configuration == 0) { %>
                        m_amba_env.axi_system[0].slave[<%=slv_pidx%>].monitor.item_observed_port.connect(m_perf_analyzer.<%=chipletObj[0].DiiInfo[pidx].strRtlNamePrefix%>_port); //DII
                        <%slv_pidx++;%>
                    <%}%>
                <%}%>
            end
        <%}%>
        
        // Connect Regmodel to adapter to send transaction to driver.
        if (regmodel.get_parent() == null) begin
            if (nCHIs>0 && chi_has_csr_access) begin
                reg2chi_adapter reg2chi = new();
                regmodel.default_map.set_sequencer(m_amba_env.chi_system[0].rn[chi_id_with_csr_access].rn_xact_seqr,reg2chi);
                reg2chi.p_cfg = this.cfg.chi_sys_cfg[0].rn_cfg[chi_id_with_csr_access]; // Set the register config to be the same as the rn[0]
            end else begin
                reg2axi_adapter reg2axi = new();
                reg2axi.p_cfg =  this.cfg.axi_sys_cfg[0].master_cfg[ioaiu_id_with_csr_access];
                regmodel.default_map.set_sequencer(m_amba_env.axi_system[0].master[ioaiu_id_with_csr_access].sequencer,reg2axi);
            end
            `uvm_info("connect_phase", "Reg Model connected to adapter", UVM_LOW)
        end
        regmodel.default_map.set_auto_predict(1);
        <%if(chipletObj[0].useResiliency == 1){ %>
            resiliency_m_regs.default_map.set_auto_predict(1);
        <%}%>

        `uvm_info("connect_phase", "Exiting...", UVM_LOW)
    endfunction : connect_phase

    // Reset the register model
    task reset_phase(uvm_phase phase);
        phase.raise_objection(this, "Resetting regmodel");
        regmodel.reset();
        <%if(chipletObj[0].useResiliency == 1){%>
            resiliency_m_regs.reset();
        <%}%>
        phase.drop_objection(this);
    endtask

endclass


