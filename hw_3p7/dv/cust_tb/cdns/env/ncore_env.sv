`ifndef GUARD_NCORE_SYSTEM_ENV_SV
`define GUARD_NCORE_SYSTEM_ENV_SV
<%
//Embedded javascript code to figure number of blocks
   var _child_blkid = [];
   var _child_blk   = [];
   var pidx = 0;
   var ridx = 0;
   var chiaiu_idx = 0;
   var ioaiu_idx = 0;
   var axi_idx = 0;
   var acelite_idx = 0;
   var initiatorAgents = obj.AiuInfo.length ;
   var csrAccess_chiaiu = 0;
   var found_csr_access_chiaiu = 0;
   var csrAccess_ioaiu = 0;
   var found_csr_access_ioaiu = 0;

   for(pidx = 0; pidx < obj.nAIUs; pidx++) {
       if(obj.AiuInfo[pidx].fnNativeInterface.includes('CHI')) {
         _child_blkid[pidx] = 'chiaiu' + chiaiu_idx;
         _child_blk[pidx]   = 'chiaiu';
         if(obj.AiuInfo[pidx].fnCsrAccess == 1 && found_csr_access_chiaiu == 0) {
           csrAccess_chiaiu = chiaiu_idx;
           found_csr_access_chiaiu = 1;
         }
         chiaiu_idx++;
       } else {
         _child_blkid[pidx] = 'ioaiu' + ioaiu_idx;
         _child_blk[pidx]   = 'ioaiu';
         if(obj.AiuInfo[pidx].fnCsrAccess == 1 && found_csr_access_ioaiu == 0) {
	   csrAccess_ioaiu = ioaiu_idx;
	   found_csr_access_ioaiu = 1;
         }
         ioaiu_idx += obj.AiuInfo[pidx].nNativeInterfacePorts;
       }
       if(obj.AiuInfo[pidx].fnNativeInterface == 'AXI4'|| obj.AiuInfo[pidx].fnNativeInterface == 'AXI5' ){
         axi_idx += obj.AiuInfo[pidx].nNativeInterfacePorts;
       }
       if(obj.AiuInfo[pidx].fnNativeInterface == 'ACE-LITE'){
         acelite_idx += obj.AiuInfo[pidx].nNativeInterfacePorts;
       }

   }
   if (found_csr_access_ioaiu == 0 && found_csr_access_chiaiu == 0) {
     var e = new Error("No master is allowed to access register, check fnCsrAccess field in .json file");
     throw e;
   }
   for(pidx = 0; pidx < obj.nDCEs; pidx++) {
       ridx = pidx + obj.nAIUs;
       _child_blkid[ridx] = 'dce' + pidx;
       _child_blk[ridx]   = 'dce';
   }
   for(pidx =  0; pidx < obj.nDMIs; pidx++) {
       ridx = pidx + obj.nAIUs + obj.nDCEs;
       _child_blkid[ridx] = 'dmi' + pidx;
       _child_blk[ridx]   = 'dmi';
   }
   for(pidx = 0; pidx < obj.nDIIs; pidx++) {
       ridx = pidx + obj.nAIUs + obj.nDCEs + obj.nDMIs;
       _child_blkid[ridx] = 'dii' + pidx;
       _child_blk[ridx]   = 'dii';
   }
   for(pidx = 0; pidx < obj.nDVEs; pidx++) {
       ridx = pidx + obj.nAIUs + obj.nDCEs + obj.nDMIs + obj.nDIIs;
       _child_blkid[ridx] = 'dve' + pidx;
       _child_blk[ridx]   = 'dve';
   }
%>

`include "reg2apb_adapter.sv"
`include "reg2axi_adapter.sv"
`include "reg2chi_adapter.sv"

class ncore_env extends uvm_env;
  `uvm_component_utils(ncore_env)

<% var cnt =0; var chi_idx=0;%>
<% obj.AiuInfo.forEach(function(e, indx, array) { %>
<% if(e.fnNativeInterface.includes('CHI')) {%>
    activeChiDownAgent<%=chi_idx%>  m_aiuChiMstAgent<%=chi_idx%>;
    passiveChiDownAgent<%=chi_idx%>  m_aiuChiMstAgentPassive<%=chi_idx%>;
    <%chi_idx++; %>
<%} else {%>
     <%for (var mpu_io = 0; mpu_io < e.nNativeInterfacePorts; mpu_io++){ %>
    activeMasterAgent<%=cnt%>  m_aiuMstAgent<%=cnt%> ;
    passiveMasterAgent<%=cnt%>  m_aiuMstAgentPassive<%=cnt%> ;
    <%cnt++} %>
<%}%>
<%}); %>

<% var cnt =0; 
    obj.DmiInfo.forEach(function(e, i, array) { %>
    dmiactiveSlaveAgent<%=cnt%>  m_dmiSlvAgent<%=cnt%>;
    dmipassiveSlaveAgent<%=cnt%> m_dmiSlvAgentPassive<%=cnt%>;
<% cnt++ }); %>

<% var cnt =0; 
    obj.DiiInfo.forEach(function(e, i, array) { %>
<%  if (e.configuration == 0) {   %>	
    diiactiveSlaveAgent<%=cnt%>  m_diiSlvAgent<%=cnt%>;
    diipassiveSlaveAgent<%=cnt%> m_diiSlvAgentPassive<%=cnt%>;
<% cnt++ } %>
<% }); %>

<%if(obj.useResiliency == 1){%>
    cdnApbUvmActiveMasterAgent_fsc   m_fsc_activeMaster;
    cdnApbUvmPassiveMasterAgent_fsc  m_fsc_passiveMaster;
<% } %>
<%if(obj.DebugApbInfo.length > 0){%>
    cdnApbUvmActiveMasterAgent_apb   m_apb_dbg_activeMaster;
    cdnApbUvmPassiveMasterAgent_apb  m_apb_dbg_passiveMaster;
<% } %>

    ncore_vip_configuration cfg;
    addr_trans_mgr         m_addr_mgr;

    ral_sys_ncore                                  regmodel;
    reg2chi_adapter                                reg2chi;
    reg2axi_adapter                                reg2axi;
<% if(obj.useResiliency == 1){%>
    reg2apb_adapter                                reg2apb;
<%}%>
<%if(obj.DebugApbInfo.length > 0){ %>
    reg2apb_adapter                                reg2apb_dbg;
    ral_sys_ncore                                  debug_m_regs;
    uvm_reg_predictor#(denaliCdn_apbTransaction)   ApbRegPredict_dbg;          //updates the register model with the results from the bus
<%}%>

<%if(obj.useResiliency == 1){ %>
    ral_sys_resiliency                             resiliency_m_regs;
    uvm_reg_predictor#(denaliCdn_apbTransaction)   ApbRegPredict;          //updates the register model with the results from the bus
<%}%>

    function new (string name="ncore_env", uvm_component parent=null);
      super.new (name, parent);
    endfunction

    virtual function void build_phase(uvm_phase phase);
        `uvm_info("build_phase", "Entered...",UVM_LOW)

        super.build_phase(phase);
        cfg = ncore_vip_configuration::type_id::create("cfg");
        cfg.set_amba_sys_config();
        <% var cnt =0; var chi_idx=0;%>
        <% obj.AiuInfo.forEach(function(e, indx, array) { %>

        <% if(e.fnNativeInterface.includes('CHI')) {%>
             m_aiuChiMstAgent<%=chi_idx%> = activeChiDownAgent<%=chi_idx%>::type_id::create("m_aiuChiMstAgent<%=chi_idx%>", this);
             m_aiuChiMstAgentPassive<%=chi_idx%> = passiveChiDownAgent<%=chi_idx%>::type_id::create("m_aiuChiMstAgentPassive<%=chi_idx%>", this);
             set_config_object("m_aiuChiMstAgent<%=chi_idx%>", "cfg", cfg.m_aiuChiMstCfg<%=chi_idx%>);
             set_config_object("m_aiuChiMstAgentPassive<%=chi_idx%>", "cfg", cfg.m_aiuChiMstCfgPassive<%=chi_idx%>);
        <% chi_idx++; %>
        <% } else { %>
        <% for (var mpu_io = 0; mpu_io < e.nNativeInterfacePorts; mpu_io++){ %>
        <% if (obj.DISABLE_CDN_AXI5 == 0) { %>
            m_aiuMstAgent<%=cnt%> = activeMasterAgent<%=cnt%>::type_id::create("m_aiuMstAgent<%=cnt%>", this);
            set_config_object("m_aiuMstAgent<%=cnt%>", "cfg", cfg.m_aiuMstCfg<%=cnt%>);

            m_aiuMstAgentPassive<%=cnt%> = passiveMasterAgent<%=cnt%>::type_id::create("m_aiuMstAgentPassive<%=cnt%>", this);
            set_config_object("m_aiuMstAgentPassive<%=cnt%>", "cfg", cfg.m_aiuMstCfgPassive<%=cnt%>);
        <% } else if ((obj.DISABLE_CDN_AXI5 == 1) && (e.fnNativeInterface != 'ACELITE-E' )) { %>
            m_aiuMstAgent<%=cnt%> = activeMasterAgent<%=cnt%>::type_id::create("m_aiuMstAgent<%=cnt%>", this);
            set_config_object("m_aiuMstAgent<%=cnt%>", "cfg", cfg.m_aiuMstCfg<%=cnt%>);

            m_aiuMstAgentPassive<%=cnt%> = passiveMasterAgent<%=cnt%>::type_id::create("m_aiuMstAgentPassive<%=cnt%>", this);
            set_config_object("m_aiuMstAgentPassive<%=cnt%>", "cfg", cfg.m_aiuMstCfgPassive<%=cnt%>);
        <%} cnt++ }  %>
        <% }}); %>

    <% var cnt =0; 
    obj.DmiInfo.forEach(function(e, i, array) { %>
        m_dmiSlvAgent<%=cnt%> = dmiactiveSlaveAgent<%=cnt%>::type_id::create("m_dmiSlvAgent<%=cnt%>", this);
        set_config_object("m_dmiSlvAgent<%=cnt%>", "cfg", cfg.m_dmiSlvCfg<%=cnt%>);
    
        m_dmiSlvAgentPassive<%=cnt%> = dmipassiveSlaveAgent<%=cnt%>::type_id::create("m_dmiSlvAgentPassive<%=cnt%>", this);
        set_config_object("m_dmiSlvAgentPassive<%=cnt%>", "cfg", cfg.m_dmiSlvCfgPassive<%=cnt%>);
    <% cnt++ }); %>
    
    <% var cnt =0; 
    obj.DiiInfo.forEach(function(e, i, array) { %>
    <%  if (e.configuration == 0) {   %>	
        m_diiSlvAgent<%=cnt%> = diiactiveSlaveAgent<%=cnt%>::type_id::create("m_diiSlvAgent<%=cnt%>", this);
        set_config_object("m_diiSlvAgent<%=cnt%>", "cfg", cfg.m_diiSlvCfg<%=cnt%>);
    
        m_diiSlvAgentPassive<%=cnt%> = diipassiveSlaveAgent<%=cnt%>::type_id::create("m_diiSlvAgentPassive<%=cnt%>", this);
        set_config_object("m_diiSlvAgentPassive<%=cnt%>", "cfg", cfg.m_diiSlvCfgPassive<%=cnt%>);
    <% cnt++ } %>
    <% }); %>
    
    <%if(obj.useResiliency == 1){%>
        m_fsc_activeMaster = cdnApbUvmActiveMasterAgent_fsc::type_id::create("m_fsc_activeMaster", this);
        set_config_object("m_fsc_activeMaster", "cfg", cfg.m_fscMstCfg);
    
        m_fsc_passiveMaster= cdnApbUvmPassiveMasterAgent_fsc::type_id::create("m_fsc_passiveMaster", this);
        set_config_object("m_fsc_passiveMaster", "cfg", cfg.m_fscMstCfgPassive);
    <% } %>
    <%if(obj.DebugApbInfo.length > 0){%>
        m_apb_dbg_activeMaster = cdnApbUvmActiveMasterAgent_apb::type_id::create("m_apb_dbg_activeMaster", this);
        set_config_object("m_apb_dbg_activeMaster", "cfg", cfg.m_apb_dbg_MstCfg);
    
        m_apb_dbg_passiveMaster= cdnApbUvmPassiveMasterAgent_apb::type_id::create("m_apb_dbg_passiveMaster", this);
        set_config_object("m_apb_dbg_passiveMaster", "cfg", cfg.m_apb_dbg_MstCfgPassive);
    <% } %>


   // Check if regmodel is passed to env if not then create and lock it
    if (regmodel == null) begin
      regmodel = ral_sys_ncore::type_id::create("regmodel");
      regmodel.build();
      `uvm_info("build_phase", "Reg Model created", UVM_LOW)
      regmodel.lock_model();
    end
    reg2chi = reg2chi_adapter::type_id::create("reg2chi");
    reg2axi = reg2axi_adapter::type_id::create("reg2axi");

    <%if(obj.useResiliency == 1){%>
        if (resiliency_m_regs == null) begin
          resiliency_m_regs= ral_sys_resiliency::type_id::create("resiliency_m_regs");
          resiliency_m_regs.build();
          `uvm_info("build_phase", "resiliency_m_regs Model created", UVM_LOW)
          resiliency_m_regs.lock_model();
        end
        reg2apb = reg2apb_adapter::type_id::create("reg2apb");
        ApbRegPredict = uvm_reg_predictor#(denaliCdn_apbTransaction)::type_id::create("ApbRegPredict", this);
    <% } %>
    <% if(obj.DebugApbInfo.length > 0){ %>
        if (debug_m_regs == null) begin
          debug_m_regs = ral_sys_ncore::type_id::create("debug_m_regs", this);
          debug_m_regs.build();
          `uvm_info("build_phase", "debug_m_regs Reg Model created", UVM_LOW)
          debug_m_regs.lock_model();
          debug_m_regs.reset();
        end
        reg2apb_dbg= reg2apb_adapter::type_id::create("reg2apb_dbg");
        ApbRegPredict_dbg = uvm_reg_predictor#(denaliCdn_apbTransaction)::type_id::create("ApbRegPredict_dbg", this);
    <% } %>
    // build address manager
        m_addr_mgr = addr_trans_mgr::get_instance();
        m_addr_mgr.gen_memory_map();
        `uvm_info("build_phase", "Exiting...", UVM_LOW)
    endfunction

    function void connect_phase(uvm_phase phase);
        `uvm_info("connect_phase", "Entered...",UVM_LOW)

        // Connect Regmodel to adapter to send transaction to driver.
        if (regmodel.get_parent() == null) begin

        <% if (chiaiu_idx > 0 && found_csr_access_chiaiu != 0) { %>
            regmodel.default_map.set_sequencer(m_aiuChiMstAgent<%=csrAccess_chiaiu%>.sequencer,reg2chi);
            regmodel.default_map.set_auto_predict(1);
        <% } else { %>
            m_aiuMstAgent<%=csrAccess_ioaiu%>.inst.updateErrorControl(CDN_AXI_FATAL_ERROR_INSUFFICIENT_NUMBER_OF_PASSIVE_AGENTS_IN_ENV,DENALI_CDN_AXI_ERR_CONFIG_SEVERITY_Silent);
            m_aiuMstAgent<%=csrAccess_ioaiu%>.inst.updateErrorControl(CDN_AXI_FATAL_ERROR_INSUFFICIENT_NUMBER_OF_PASSIVE_AGENTS_IN_ENV,DENALI_CDN_AXI_ERR_CONFIG_SEVERITY_Silent);
            m_aiuMstAgentPassive<%=csrAccess_ioaiu%>.inst.updateErrorControl(CDN_AXI_FATAL_ERROR_INSUFFICIENT_NUMBER_OF_PASSIVE_AGENTS_IN_ENV,DENALI_CDN_AXI_ERR_CONFIG_SEVERITY_Silent);
        // specify the master sequencer for reg sequences
            regmodel.default_map.set_sequencer(m_aiuMstAgent<%=csrAccess_ioaiu%>.sequencer, reg2axi);
	        regmodel.default_map.set_auto_predict(1);
	
        <% } %>
        <% if(obj.useResiliency == 1){ %>
            resiliency_m_regs.default_map.set_sequencer(m_fsc_activeMaster.sequencer,reg2apb);
            resiliency_m_regs.default_map.set_auto_predict(1);
            ApbRegPredict.map = resiliency_m_regs.default_map;
            ApbRegPredict.adapter = reg2apb;
            `uvm_info("connect_phase", "FSC Reg Model connected to adapter", UVM_LOW)
            resiliency_m_regs.default_map.set_auto_predict(1);
        <% } %>
        end

        <%if(obj.DebugApbInfo.length > 0){%>
            debug_m_regs.default_map.set_sequencer(m_apb_dbg_activeMaster.sequencer,reg2apb_dbg);
            debug_m_regs.default_map.set_auto_predict(1);
            ApbRegPredict_dbg.map = debug_m_regs.default_map;
            ApbRegPredict_dbg.adapter = reg2apb_dbg;
            `uvm_info("connect_phase", "FSC Reg Model connected to adapter", UVM_LOW)
            debug_m_regs.default_map.set_auto_predict(1);
        <%}%>
    
        `uvm_info("connect_phase", "Exiting...", UVM_LOW)
    endfunction : connect_phase

    virtual function void end_of_elaboration_phase ( uvm_phase phase );
        super.end_of_elaboration_phase(phase);
        <% if (chiaiu_idx > 0) { %>
            if($test$plusargs("en_axi_adapter")) 
        <% } %>
        begin
        <% if(ioaiu_idx > 0) { %>
            void'(m_aiuMstAgentPassive0.setCallback(DENALI_CDN_AXI_CB_Ended));
            m_aiuMstAgentPassive0.monitor.set_report_severity_id_action(UVM_FATAL, "CDN_AXI_FATAL_ERR_VR_AXI226_MEMORY_INCONSISTENCY",UVM_NO_ACTION);
        <% } %>
        end
        <% if (chiaiu_idx > 0) { %>
        else 
            begin
            void'(m_aiuChiMstAgentPassive0.setCallback(DENALI_CHI_CB_CompletionQueueExit));
            end
        <% } %>

    endfunction : end_of_elaboration_phase


   // Reset the register model
   task reset_phase(uvm_phase phase);
        phase.raise_objection(this, "Resetting regmodel");
        regmodel.reset();
        <% if(obj.useResiliency == 1){ %>
        resiliency_m_regs.reset();
        <% } %>
        phase.drop_objection(this);
   endtask

endclass

`endif // GUARD_NCORE_SYSTEM_ENV_SV
