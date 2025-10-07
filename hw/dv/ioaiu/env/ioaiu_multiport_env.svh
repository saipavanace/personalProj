<% var aiu;
if((obj.testBench === "fsys") || (obj.testBench === "emu_t") || (obj.testBench === "emu")) {
    aiu = obj.AiuInfo[obj.Id];
} else {
    aiu = obj.DutInfo;
}%>

class ioaiu_multiport_env extends uvm_env;

// purpose: 
//     class with similar hierarchy to ioaiu_core_wrapper
//     this will instantiate the following:
//         ioaiu_env (1 per core)
//         apb_agent (1)
//         apb_demux (1)
//         qchnl_agent (1)
//         smi_agent (1)
//         smi_demux (1)
//         trace_debug_scoreboard (1)

    `uvm_component_param_utils(ioaiu_multiport_env)

   ioaiu_env m_env[<%=aiu.nNativeInterfacePorts%>];
    <% if (obj.testBench == "fsys" || obj.testBench == "emu") { %>
    ioaiu_env_config m_env_cfg[<%=aiu.nNativeInterfacePorts%>];
    <%}%>
    q_chnl_agent    m_q_chnl_agent;
   
    axi_agent_config m_axi_slave_cfg[<%=aiu.nNativeInterfacePorts%>];
    axi_virtual_sequencer  m_ioaiu_vseqr[<%=aiu.nNativeInterfacePorts%>];
    ioaiu_smi_demux m_smi_demux;

    <%if((obj.testBench=="io_aiu") && (obj.INHOUSE_APB_VIP) && 
        ((obj.instanceName) ? (obj.BlockId == obj.instanceName) : 
        (obj.ioaiuId==0))) { %>
        <%=obj.BlockId%>_concerto_register_map_pkg::ral_sys_ncore    m_regs;
    <%} else if(obj.testBench == "fsys" || obj.testBench=="emu") { %>
        concerto_register_map_pkg::ral_sys_ncore                     m_regs;
    <%}%>
    
    smi_agent           m_smi_agent;
    <% if (obj.testBench == "fsys" || obj.testBench == "emu") { %>
    smi_agent_config      m_smi_agent_cfg;
    <%}%>
        <% if(obj.testBench=="fsys"   || obj.testBench =="io_aiu"){ %>
        <% if(obj.AiuInfo[obj.Id].interfaces.eventRequestOutInt._SKIP_ == false || obj.AiuInfo[obj.Id].interfaces.eventRequestInInt._SKIP_ == false) { %>
    <%=obj.BlockId%>_event_agent_pkg::event_agent           m_event_agent; 
    <%}%>
    <%}%>
    trace_debug_scb      m_trace_debug_scb;
    virtual <%=obj.BlockId%>_axi_cmdreq_id_if axi_cmdreq_id_if[<%=aiu.nNativeInterfacePorts%>];

    function new(string name = "ioaiu_multiport_env", uvm_component parent=null);
        super.new(name,parent);
        <%for(let i=0; i<aiu.nNativeInterfacePorts; i++) {%>
            m_env[<%=i%>] = ioaiu_env::type_id::create("m_env[<%=i%>]", this); // core_id
            m_env[<%=i%>].core_id =  <%=i%>;
        <%}%>
 
        <%for(let i=0; i<aiu.nNativeInterfacePorts; i++) {%>
            m_ioaiu_vseqr[<%=i%>]                   = axi_virtual_sequencer::type_id::create("m_ioaiu_vseqr[<%=i%>]", this);
        <%}%>
        <%if(obj.NO_SMI === undefined){%>
            m_smi_agent = smi_agent::type_id::create("m_smi_agent", this);
	 		<%}%>
        if($test$plusargs("tcap_scb_en")) begin
        m_trace_debug_scb = trace_debug_scb::type_id::create("m_trace_debug_scb", this);
        end
        m_smi_demux = ioaiu_smi_demux::type_id::create("m_smi_demux", this);

        <% if(obj.testBench=="fsys"  || obj.testBench =="io_aiu"){ %>
        <% if(obj.AiuInfo[obj.Id].interfaces.eventRequestOutInt._SKIP_ == false || obj.AiuInfo[obj.Id].interfaces.eventRequestInInt._SKIP_ == false) { %>
        m_event_agent = <%=obj.BlockId%>_event_agent_pkg::event_agent::type_id::create("m_event_agent", this);
        <%}%>
        <%}%>
 
    endfunction : new

    virtual function void build_phase(uvm_phase phase);
    <%if((obj.testBench=="io_aiu") && (obj.INHOUSE_APB_VIP) && 
            ((obj.instanceName) ? (obj.BlockId == obj.instanceName) :
            (obj.ioaiuId==0))){ %>
                m_regs = <%=obj.BlockId%>_concerto_register_map_pkg::ral_sys_ncore::type_id::create("ral_sys_ncore", this);
                m_regs.build();
                m_regs.lock_model();
                uvm_config_db #(<%=obj.BlockId%>_concerto_register_map_pkg::ral_sys_ncore)::set(null,"","m_regs",m_regs);
        <% } else if(obj.testBench == 'fsys') { %>
        if(!uvm_config_db #(concerto_register_map_pkg::ral_sys_ncore)::get(null,"","m_regs",m_regs)) `uvm_fatal("Missing in DB::", "RAL m_regs not found");
        <% } %>

        super.build_phase(phase);
         
    endfunction : build_phase
 
    virtual function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);
        <%for(let i = 0; i < aiu.nNativeInterfacePorts; i++){%>
        <% if(obj.testBench == "fsys" || obj.testBench == "emu") { %>
        m_env_cfg[<%=i%>] = m_env[<%=i%>].m_cfg;
        
            if(m_env_cfg[<%=i%>].has_scoreboard) begin
                m_smi_demux.m_smi_scb_ap[<%=i%>].connect             ( m_env[<%=i%>].m_scb.ioaiu_smi_port      ) ;
                m_smi_demux. m_smi_every_beat_scb_ap[<%=i%>].connect             ( m_env[<%=i%>].m_scb.ioaiu_smi_every_beat_port) ;
       
                if ($test$plusargs("newperf_test_scb")) m_env[<%=i%>].m_newperf_test_ace_scb.update_id((m_env[<%=i%>].m_newperf_test_ace_scb.cfg_aiu_id*10)+ <%=i%>);  //CLUTODO replace testplusargs by has_perf_scoreboard
            
            end
        <%}%>
        <% if(obj.testBench=="fsys" || obj.testBench =="io_aiu"){ %>
                if(m_env[0].m_cfg.has_scoreboard) begin
        <% if( obj.AiuInfo[obj.Id].interfaces.eventRequestInInt._SKIP_ == false) { %>
                m_env[<%=i%>].m_event_agent.m_monitor.event_sender_ap_master.connect (m_env[<%=i%>].m_scb.event_sender_port);
                `uvm_info("DEBUG_SYS","connected event_sender_ap_master to event_port",UVM_LOW)

    <%}%>
        <% if(obj.AiuInfo[obj.Id].interfaces.eventRequestOutInt._SKIP_ == false ) { %>
                m_env[<%=i%>].m_event_agent.m_monitor.event_receiver_ap_slave.connect (m_env[<%=i%>].m_scb.event_reciever_port);
                `uvm_info("DEBUG_SYS","connected event_sender_ap_master to event_port",UVM_LOW)
    <%}%>
               end
    <%}%>
        <%}%>
        <%var NSMIIFTX = obj.nSmiRx;
        for(var i = 0; i < NSMIIFTX; i++){%>
            m_smi_agent.m_smi<%=i%>_tx_port_ap.connect             ( m_smi_demux.ioaiu_smi_port ) ;
            m_smi_agent.m_smi<%=i%>_tx_every_beat_port_ap.connect             ( m_smi_demux.ioaiu_smi_every_beat_port) ;
            if($test$plusargs("tcap_scb_en")) begin
                m_smi_agent.m_smi<%=i%>_tx_port_ap.connect          ( m_trace_debug_scb.analysis_smi<%=i%>_tx_port);
                <%if(i == (NSMIIFTX-1)){%>
                    m_smi_agent.m_smi<%=i%>_tx_ndp_ap.connect          ( m_trace_debug_scb.analysis_smi_dntx_ndp_only_port);
                <%}%>
            end
        <%}%>
        <%var NSMIIFRX = obj.nSmiTx;
        for(var i = 0; i < NSMIIFRX; i++){%>
            m_smi_agent.m_smi<%=i%>_rx_port_ap.connect             ( m_smi_demux.ioaiu_smi_port ) ;
            m_smi_agent.m_smi<%=i%>_rx_every_beat_port_ap.connect          ( m_smi_demux.ioaiu_smi_every_beat_port) ;

            if($test$plusargs("tcap_scb_en")) begin
                m_smi_agent.m_smi<%=i%>_rx_port_ap.connect         ( m_trace_debug_scb.analysis_smi<%=i%>_rx_port);
                <%if(i == (NSMIIFRX-1)){%>
                    m_smi_agent.m_smi<%=i%>_rx_ndp_ap.connect      ( m_trace_debug_scb.analysis_smi_dnrx_ndp_only_port);
                <%}%>
            end
        <%}%>
         <% if(((obj.testBench=="ioaiu") && (obj.INHOUSE_OCP_VIP))) { %>
            m_regs.default_map.set_auto_predict(0);
            m_regs.default_map.set_sequencer(.sequencer(m_ocp_agent.m_ocp_sequencer),
                                            .adapter(m_ocp_agent.m_reg_adapter));
        <%}%>
        <% if((obj.testBench=="io_aiu") && (obj.INHOUSE_APB_VIP) && 
            ((obj.instanceName) ? (obj.BlockId == obj.instanceName) :
            (obj.ioaiuId==0))) { %>
            m_regs.default_map.set_auto_predict(1);
            m_regs.default_map.set_sequencer(.sequencer(m_env[0].m_apb_agent.m_apb_sequencer), 
                                            .adapter(m_env[0].m_apb_agent.m_apb_reg_adapter));
         <%for(let i = 0; i < aiu.nNativeInterfacePorts; i++){%>
           if(m_env[<%=i%>].m_cfg.has_scoreboard) begin
               m_env[<%=i%>].m_scb.m_regs = this.m_regs; 
            end    
               m_env[<%=i%>].m_regs =this.m_regs;                       
          <%}%>
         <%}%>
    endfunction : connect_phase

endclass : ioaiu_multiport_env
