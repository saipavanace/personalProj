`include "reg2axi_adapter.sv"
`include "reg2chi_adapter.sv"
<%if(obj.enInternalCode){%>
    `include "ncore_perf_analyzer.sv"
<%}%>
<%if(obj.useResiliency == 1){%>
    `include "ncore_fsc_system_register_map.sv"
<%}%>
<%if((obj.useResiliency == 1) || (obj.DebugApbInfo.length > 0)){%>
    `include "reg2apb_adapter.sv"
<%}%>
<%if(obj.useResiliency == 1){%>
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
    addr_trans_mgr m_addr_mgr;

    //RAL model
    ral_sys_ncore regmodel;
    <%if(obj.enInternalCode){%>
        ncore_perf_analyzer m_perf_analyzer;
    <%}%>

    <%if(obj.useResiliency == 1){%>
        ral_sys_resiliency resiliency_m_regs;
    <%}%>
    <% if(obj.DebugApbInfo.length > 0){ %>
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
    
        // Apply the configuration to the AMBA System ENV 
        uvm_config_db#(svt_amba_system_configuration)::set(this, "m_amba_env", "cfg", cfg);

        // Construct the AMBA system ENV 
        m_amba_env = svt_amba_system_env::type_id::create("m_amba_env", this);
        <%if(obj.enInternalCode){%>
            m_perf_analyzer = ncore_perf_analyzer::type_id::create("m_perf_analyzer", this);
        <%}%>
   
        // Check if regmodel is passed to env if not then create and lock it
        if (regmodel == null) begin
            regmodel = ral_sys_ncore::type_id::create("regmodel");
            regmodel.build();
            `uvm_info("build_phase", "Reg Model created", UVM_LOW)
            uvm_config_db#(uvm_reg_block)::set(this, "m_amba_env.apb_system[0].master", "apb_regmodel", regmodel);
            regmodel.lock_model();
            regmodel.reset();
        end

        <% if(obj.useResiliency == 1){ %>
            if (resiliency_m_regs == null) begin
                resiliency_m_regs = ral_sys_resiliency::type_id::create("ral_sys_resiliency", this);
                resiliency_m_regs.build();
                `uvm_info("build_phase", "resiliency_m_regs Reg Model created", UVM_LOW)
                uvm_config_db#(uvm_reg_block)::set(this, "m_amba_env.apb_system[1].master", "apb_regmodel", resiliency_m_regs);
                resiliency_m_regs.lock_model();
                resiliency_m_regs.reset();
            end
        <%}%>

        <% if(obj.DebugApbInfo.length > 0){ %>
            if (debug_m_regs == null) begin
              debug_m_regs = ral_sys_ncore::type_id::create("debug_m_regs", this);
              debug_m_regs.build();
              `uvm_info("build_phase", "debug_m_regs Reg Model created", UVM_LOW)
              debug_m_regs.lock_model();
              debug_m_regs.reset();
            end
        <% } %>

        // build address manager
        m_addr_mgr = addr_trans_mgr::get_instance();
        m_addr_mgr.gen_memory_map();

        if($test$plusargs("performance_test"))begin
            // set_type_override_by_type (svt_chi_rn_transaction::get_type(),cust_svt_chi_rn_transaction::get_type());
            // set_type_override_by_type (svt_chi_rn_snoop_transaction::get_type(),cust_svt_chi_rn_snoop_transaction::get_type());
        end
        // set_type_override_by_type (svt_axi_master_snoop_transaction::get_type(),cust_svt_axi_snoop_transaction::get_type());

        `uvm_info("build_phase", "Exiting...", UVM_LOW)
    endfunction

    function void connect_phase(uvm_phase phase);
        <%if(obj.useResiliency == 1){ %>
            if (resiliency_m_regs.get_parent() == null) begin
                reg2apb_adapter reg2apb = new();
                reg2apb.p_cfg =  this.cfg.apb_sys_cfg[0];
                resiliency_m_regs.default_map.set_sequencer(m_amba_env.apb_system[0].master.sequencer,reg2apb);
                resiliency_m_regs.default_map.set_auto_predict(1);
            end
        <%}%>
        <%if(obj.DebugApbInfo.length > 0){%>
            if (debug_m_regs.get_parent() == null) begin
                reg2apb_adapter reg2apb_dbg = new();
                reg2apb_dbg.p_cfg =  this.cfg.apb_sys_cfg[0];
                debug_m_regs.default_map.set_sequencer(m_amba_env.apb_system[apb_dbg_id].master.sequencer,reg2apb_dbg);
                debug_m_regs.default_map.set_auto_predict(1);
            end
        <%}%>
        `uvm_info("connect_phase", "Entered...",UVM_LOW)
        <%if(obj.enInternalCode){%>
            if(nCHIs > 0) begin
            <% for(let idx = 0; idx < obj.nCHIs; idx++) {%>
                m_amba_env.chi_system[0].rn[<%=idx%>].prot_mon.item_observed_port.connect(m_perf_analyzer.analysis_imp1);//sv_chi_rn_transaction
            <%}%>
            end
        <%let pidx=0;%>
            <%for(let idx = 0; idx < obj.nAIUs; idx++) { %>
                 <%if(!(obj.AiuInfo[idx].fnNativeInterface.includes('CHI'))){%>
                m_amba_env.axi_system[0].master[<%=pidx%>].monitor.item_observed_port.connect(m_perf_analyzer.analysis_imp2); // master
                <%pidx++;%>
            <%}%>
        <%}%>
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
        <%if(obj.useResiliency == 1){ %>
            resiliency_m_regs.default_map.set_auto_predict(1);
        <%}%>

        `uvm_info("connect_phase", "Exiting...", UVM_LOW)
    endfunction : connect_phase

    // Reset the register model
    task reset_phase(uvm_phase phase);
        phase.raise_objection(this, "Resetting regmodel");
        regmodel.reset();
        <%if(obj.useResiliency == 1){%>
            resiliency_m_regs.reset();
        <%}%>
        phase.drop_objection(this);
    endtask

endclass


