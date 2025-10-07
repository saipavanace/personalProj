<% var aiu_frequency;
    for(var clk=0; clk<obj.Clocks.length; clk++) {
        if(obj.AiuInfo[obj.Id].nativeClk == obj.Clocks[clk].name) {
            aiu_frequency = obj.Clocks[clk].params.frequency;
            break;
        }
    }
%>
<% var found_me      = 0;
   var my_ioaiu_id   = 0;

   for (var idx=0; idx < obj.AiuInfo.length; idx++) {
      if (obj.AiuInfo[idx].fnNativeInterface.indexOf("CHI") < 0) {
         if (obj.Id == idx) {
            found_me = 1;
         } else if (! found_me) {
            my_ioaiu_id ++;
         }   
      }
   }
%>

class ioaiu_env extends uvm_env;
    /** UVM Component Utility macro */
    `uvm_component_param_utils(ioaiu_env)

    int file_handle;
<% if(obj.testBench=="emu") { %>
`ifdef BLK_SNPS_ACE_VIP
  /** AXI System ENV */
  svt_axi_system_env   axi_system_env;

/** Virtual Sequencer */
  axi_virtual_sequencer sequencer;

/** AXI System Configuration */
  ace_env_config cfg;
`endif

<% } %>

    /** AIU Configuration Classes*/
    ioaiu_env_config m_cfg;

    /** AXI Agent*/
    axi_master_agent m_axi_master_agent;
    <%if(!(obj.PSEUDO_SYS_TB && !(obj.FULL_SYS_TB == 1 && !obj.CUSTOMER_ENV ))){%>
        axi_slave_agent  m_axi_slave_agent;
    <%}%>

    // Probe Agent
    ioaiu_probe_agent m_probe_agent;

    /** SMI Agent*/
    smi_agent       m_smi_agent;
    //sys_event agent 
 <% if(obj.testBench=="fsys" || obj.testBench =="io_aiu"){ %>
 <% if(obj.AiuInfo[obj.Id].interfaces.eventRequestOutInt._SKIP_ == false || obj.AiuInfo[obj.Id].interfaces.eventRequestInInt._SKIP_ == false) { %>

    <%=obj.BlockId%>_event_agent_pkg::event_agent m_event_agent;
<%}%>    
<%}%>    
    q_chnl_agent    m_q_chnl_agent;
    int             time_bw_Q_chnl_req;
    addr_trans_mgr  m_addr_mgr;

    int core_id;

   `ifndef PSEUDO_SYS_TB
        //reset_monitor m_rst_mon;
   `endif
    <% if(!obj.CUSTOMER_ENV) { %>
        /** AIU scoreboard*/
        <%if(obj.NO_SCB === undefined){%>   
            ioaiu_scoreboard     m_scb;
            <%if(obj.DutInfo.useCache){%>
                ioaiu_ccp_scoreboard m_ccp_scb;
            <%}%>
            //trace_debug_scb      m_trace_debug_scb;

            <%if(obj.testBench=="fsys" || obj.testBench=="emu") { %>
                // newperf test scoreboard
                newperf_test_ace_scb m_newperf_test_ace_scb;
            <%}%>
        <%}%>
        //ccp_scoreboard  m_ccp_scb;
        <% if( obj.DutInfo.useCache) { %> 
            //ncbu_rtl_monitor    ncbu_ccp_rtl_mon;
        <%}%>
        <% if(obj.COVER_ON){%>
            /** AIU ACE scoreboard callback */
            // axi_scoreboard_cov_cb sb_cov_ace;

            /** AIU AXI4 scoreboard callback */
            // axi_scoreboard_cov_cb sb_cov_axi4;

            /** AIU SMI  scoreboard callback */
            // smi_scoreboard_cov_cb sb_cov_sfm;
        <%}%>


        /** AIU RTL Monitor     **/
        // aiu_rtl_monitor    rtl_mon;
        <%if(obj.testBench=="ioaiu" && obj.INHOUSE_OCP_VIP && 
            ((obj.instanceName) ? (obj.BlockId == obj.instanceName) :
            (obj.DutInfo.ioaiuId==0))) { %>
                //AIU registers
                //DCTODO DATACHK  concerto_register_map     m_regs;
        <%}%>
    <%}%>
    //testbench=<%=obj.testBench%> obj.Id=<%=obj.Id%>
    <%if((obj.testBench=="io_aiu") && (obj.INHOUSE_APB_VIP) && 
        ((obj.instanceName) ? (obj.BlockId == obj.instanceName) :
        (obj.DutInfo.ioaiuId==0))) { %>
        <%=obj.BlockId%>_concerto_register_map_pkg::ral_sys_ncore    m_regs;
    <%} else if(obj.testBench == "fsys" || obj.testBench=="emu") { %>
        concerto_register_map_pkg::ral_sys_ncore                     m_regs;
    <%}%>
        apb_agent                       m_apb_agent; 

    <% if(obj.BLK_SNPS_OCP_VIP) { %>
        /** OCP System virtual interface */
        virtual svt_ocp_if mstr_vif;
  
        /* OCP Master components */
        svt_ocp_master_agent  ocp_master_agent;
        /* OCP System sequencer is a virtual sequencer with references to each master
        * and slave sequencers in the system.
        */
        svt_ocp_system_virtual_sequencer ocp_sequencer;
        
        /**
        * Customized OCP System configuration 
        */
        local cust_svt_ocp_system_configuration       test_cfg;
        /**
        * Captures the value passed in from the command line by +sequence_length=n.
        * This value is used to drive multiple sequences through the sequencer.
        */
        int plusarg_sequence_length = 20;
        // ---------------------------------------------------------------------------
    <%}%>
    <% if(obj.testBench=="ioaiu" && obj.INHOUSE_OCP_VIP) { %>
        uvm_event         system_quiesce;
        uvm_event         system_unquiesce;
        virtual ocp_if    m_ocp_if;
    <%}%>

    <%if(obj.DutInfo.useCache) { %>                   
        ccp_agent       m_ccp_agent;
    <%}%>
    virtual <%=obj.BlockId%>_axi_cmdreq_id_if axi_cmdreq_id_if;

    /** Class Constructor */
    function new (string name="ioaiu_env", uvm_component parent=null);
        super.new (name, parent);
        <% if(obj.BLK_SNPS_OCP_VIP) { %>
            if ($value$plusargs("sequence_length=%d", plusarg_sequence_length)) begin
                `uvm_info("new", $sformatf("Set plusarg_sequence_length from +sequence_length=%b", this.plusarg_sequence_length), UVM_HIGH);
            end
        <%}%>
    endfunction

    /** Build the AXI System ENV */
    virtual function void build_phase(uvm_phase phase);
     
        super.build_phase(phase);
         /** Get env cfg from cfg db */
        if (!uvm_config_db#(ioaiu_env_config)::get(.cntxt       (uvm_root::get()    ),
                                                   .inst_name   (get_full_name()         ),
                                                   .field_name  ("ioaiu_env_config" ),
                                                   .value       (m_cfg          ) ) ) 
        begin
            `uvm_fatal( get_name(), "ioaiu_env_config not found" )
        end
        m_addr_mgr = addr_trans_mgr::get_instance();
        axi_cmdreq_id_if = m_cfg.axi_cmdreq_id_if;

        <% if (obj.testBench== "emu" || obj.testBench == "fsys") {%>
        // axi_cmdreq_id_if = m_cfg.axi_cmdreq_id_if;
        <% } else { %>
            // uvm_config_db#(virtual <%=obj.BlockId%>_axi_cmdreq_id_if)::get(this, "","<%=obj.BlockId%>_axi_cmdreq_id_vif", axi_cmdreq_id_if);
            m_addr_mgr.gen_memory_map();
        <%}%>
        <%if(obj.NO_SMI === undefined){%>
            //m_smi_agent = smi_agent::type_id::create("m_smi_agent", this);
        <%}%>
        <% if((obj.DutInfo.useCache)) { %>                   
            m_ccp_agent = ccp_agent::type_id::create("m_ccp_agent", this);
        <%}%>
    
        <%if(obj.testBench!= "emu" ){%>
            m_probe_agent = ioaiu_probe_agent::type_id::create("m_probe_agent", this);
            m_probe_agent.core_id = core_id;
        <%}%>

 <% if(obj.testBench=="emu") { %>
  uvm_config_db #(virtual <%=obj.BlockId%>_ace_emu_if)::set(this,
    "m_axi_master_agent.*", "<%=obj.BlockId%>_ace_emu_if", m_cfg.m_ace_vif); 


  uvm_config_db #(virtual mgc_axi_master_if)::set(this,
    "m_axi_master_agent.*", "mgc_ace_m_if_<%=obj.BlockId%>", m_cfg.mgc_ace_vif);    //Added DH 29-11
<% } %> 
 
        `ifndef PSEUDO_SYS_TB
            <% if(!obj.CUSTOMER_ENV) { %>
                //FIXME added instantiation
            <%}%>
        `endif
  
        <% if (obj.testBench == 'io_aiu') { %>
            if (! m_cfg.m_q_chnl_agent_cfg) `uvm_fatal( get_name(), "m_cfg.m_q_chnl_agent_cfg not found" )
            uvm_config_db#(q_chnl_agent_config )::set(.cntxt( this ),
                                                        .inst_name( "m_q_chnl_agent" ),
                                                        .field_name( "q_chnl_agent_config" ),
                                                        .value( m_cfg.m_q_chnl_agent_cfg ));

            m_cfg.m_q_chnl_agent_cfg.time_bw_Q_chnl_req = time_bw_Q_chnl_req;
            m_q_chnl_agent = q_chnl_agent::type_id::create("m_q_chnl_agent", this);
        <%}%>

 <% if(obj.testBench=="emu") { %>    
`ifdef BLK_SNPS_ACE_VIP
  /** Apply the configuration to the System ENV */
    uvm_config_db#(svt_axi_system_configuration)::set(this, "axi_system_env", "cfg", cfg);

  /** Construct the system agent */
    axi_system_env = svt_axi_system_env::type_id::create("axi_system_env", this);

  /** Construct the virtual sequencer */
   sequencer = axi_virtual_sequencer::type_id::create("sequencer", this);
`endif
<% } %>

        // AXI master agent
        m_axi_master_agent = axi_master_agent::type_id::create("m_axi_master_agent", this);
    
        <% if(!obj.CUSTOMER_ENV) { %>
            <% if (obj.NO_SCB === undefined) { %>
                if(m_cfg.has_scoreboard) begin
                    m_scb            = ioaiu_scoreboard::type_id::create("m_scb", this);
                    m_scb.core_id    = core_id;
                    <%if(obj.DutInfo.useCache){%>
                        <%if(obj.EN_CCP_SCB){%>
                        m_ccp_scb    = ioaiu_ccp_scoreboard::type_id::create("m_ccp_scb", this);
                        <%}%>
                    <%}%>
                    //m_trace_debug_scb = trace_debug_scb::type_id::create("m_trace_debug_scb", this);

                    <%if(obj.testBench=="fsys" || obj.testBench=="emu"){%>
	                    //newperf test scoreboard
                        if ($test$plusargs("newperf_test_scb")) begin
                            int doff_nbr_rd_tx;
                            int doff_nbr_wr_tx;
                            

                            $value$plusargs("doff_ioaiu<%=my_ioaiu_id%>_nbr_rd_tx=%d",doff_nbr_rd_tx);
                            $value$plusargs("doff_ioaiu<%=my_ioaiu_id%>_nbr_wr_tx=%d",doff_nbr_wr_tx);
                            

                            m_newperf_test_ace_scb     = newperf_test_ace_scb#(.T_RA (axi4_read_addr_pkt_t)
                                                                    ,.T_RD (axi4_read_data_pkt_t)
                                                                    ,.T_WA (axi4_write_addr_pkt_t)
                                                                    ,.T_WD (axi4_write_data_pkt_t)
                                                                    ,.T_WR (axi4_write_resp_pkt_t))::type_id::create("m_newperf_test_ace_scb", this);
                            m_newperf_test_ace_scb.cfg_e_type = newperf_test_tools_pkg::ACE;
                            m_newperf_test_ace_scb.cfg_aiu_id = <%=my_ioaiu_id%>;
                            m_newperf_test_ace_scb.aiu_name = "<%=obj.DutInfo.strRtlNamePrefix%>";
                            m_newperf_test_ace_scb.frequency  = <%=aiu_frequency%>;
                            m_newperf_test_ace_scb.doff_nbr_rd_tx = ($test$plusargs("read_test"))? doff_nbr_rd_tx+doff_nbr_wr_tx : ($test$plusargs("write_test"))? 0 : doff_nbr_rd_tx; 
                            m_newperf_test_ace_scb.doff_nbr_wr_tx = ($test$plusargs("write_test"))? doff_nbr_rd_tx+doff_nbr_wr_tx : ($test$plusargs("read_test"))? 0 : doff_nbr_wr_tx;
                            //deactivate check of !bw in case of cache init using write txn
                            if($test$plusargs("init_all_cache")) begin 
                                 $value$plusargs("ioaiu_num_trans=%d",doff_nbr_wr_tx); 
                                 m_newperf_test_ace_scb.doff_nbr_wr_tx += doff_nbr_wr_tx;
                            end
                        end    
                    <%}%>		

                    <%if( obj.DutInfo.useCache) { %> 
                        <%if(obj.EN_CCP_SCB){%>
                            m_ccp_scb = ccp_scoreboard::type_id::create("m_ccp_scb", this);
                        <%}%>
                    <%}%>
                    <% if(obj.COVER_ON){%>
                        /*
                            if(m_cfg.has_functional_coverage) begin
                                sb_cov_ace  = new("sb_cov_ace","<%=obj.fnNativeInterface%>");
                                //sb_cov_sfi  = new("sb_cov_sfi");
                            end
                        */
                    <%}%>
                end
            <%}%>
        <%}else{%>
        <%}%>

        <%if(obj.BLK_SNPS_OCP_VIP) { %>
            /** Get the configuration using config_db */
            if (!uvm_config_db#(cust_svt_ocp_system_configuration)::get(this, "", "test_cfg", this.test_cfg) || (this.test_cfg == null)) begin
                `uvm_fatal("build_phase", "'test_cfg' is null.  A cust_svt_ocp_system_configuration object must be set using the UVM configuration infrastructure.");
            end else begin
                `uvm_info("build_ph",$sformatf("***************System Configuration**************\n%0s",this.test_cfg.sprint()), UVM_LOW);
                if (uvm_config_db#(virtual svt_ocp_if)::get(this, "", "mstr_vif", mstr_vif)) begin
                    `uvm_info("build_phase", "Applying the virtual interface received through the config db to the configuration.", UVM_HIGH);
                    test_cfg.vip_ocp_sys_cfg_master.m_o_mstr_cfg.set_ocp_if(mstr_vif);
                end else begin
                    if (test_cfg.vip_ocp_sys_cfg_master.m_o_mstr_cfg.ocp_if == null) begin
                        `uvm_fatal("build_phase", "A virtual interface was not received either through the config db, or through the configuration object for the master.");
                    end
                end
            end
            /**
            * Apply the configuration to the agents
            */
            //    uvm_config_db#(svt_ocp_core_configuration)::set(this, "ocp_master_agent", "cfg", this.test_cfg.vip_ocp_sys_cfg_master.m_o_mstr_cfg);
            //    ocp_master_agent = svt_ocp_master_agent::type_id::create("ocp_master_agent", this);

            // Construct the sequencer
            //    ocp_sequencer = svt_ocp_system_virtual_sequencer::type_id::create("ocp_sequencer", this);
        <%}%>

        <%if(obj.testBench=="ioaiu" && obj.INHOUSE_OCP_VIP) { %>
            system_quiesce = new("system_quiesce");
            system_unquiesce = new("system_unquiesce");

            if (!uvm_config_db#(virtual ocp_if)::get(.cntxt( this ),
                                           .inst_name( "uvm_test_top.env" ),
                                           .field_name( "ocp_if" ),
                                           .value( m_cfg.m_ocp_cfg.m_vif ))) 
            begin
                `uvm_error("AIU ENV", "Dang no OCP if found. Get some coffee :)")
            end
            if (!uvm_config_db#(uvm_event)::get( .cntxt(null),
                                      .inst_name( get_full_name()),
                                      .field_name( "system_quiesce" ),
                                      .value( this.system_quiesce ))) 
            begin
                `uvm_error("AIU ENV", "Event system_quiesce not found")
            end
            if (!uvm_config_db#(uvm_event)::get( .cntxt(null),
                                      .inst_name(get_full_name()),
                                      .field_name( "system_unquiesce" ),
                                      .value( this.system_unquiesce ))) 
            begin
                `uvm_error("AIU ENV", "Event system_unquiesce not found")
            end
            if(m_cfg.hasRAL) begin
                m_regs = concerto_register_map::type_id::create("concerto_register_map", this);
                m_regs.build();
                m_regs.lock_model();
            end
        <%}%>

        <%if((obj.testBench=="io_aiu") && (obj.INHOUSE_APB_VIP) && 
             ((obj.instanceName) ? (obj.DutInfo.strRtlNamePrefix == obj.instanceName) :
             (obj.DutInfo.ioaiuId==0))) { %>

            if(m_cfg.hasRAL) begin
            uvm_config_db#(apb_agent_config )::set(.cntxt( this ),
                                           .inst_name( "m_apb_agent" ),
                                           .field_name( "apb_agent_config" ),
                                           .value( m_cfg.m_apb_cfg ));

            m_apb_agent = apb_agent::type_id::create("m_apb_agent", this);
            end
        <%}%>

        <%if(obj.testBench == "fsys") { %>
            if(m_cfg.hasRAL) begin
            m_apb_agent = apb_agent::type_id::create("m_apb_agent", this);
            end
        <%}%>
            //sys_event agent
 <% if(obj.testBench=="fsys" || obj.testBench =="io_aiu"){ %>
 <% if(obj.AiuInfo[obj.Id].interfaces.eventRequestOutInt._SKIP_ == false || obj.AiuInfo[obj.Id].interfaces.eventRequestInInt._SKIP_ == false) { %>
            m_event_agent = <%=obj.BlockId%>_event_agent_pkg::event_agent::type_id::create("m_event_agent", this);
uvm_config_db#(<%=obj.BlockId%>_event_agent_pkg::event_agent_config)::set(uvm_root::get(),"*","event_agent_config",m_cfg.m_event_agent_cfg);
`uvm_info("debug_event_agent"," setting event_agent_config",UVM_NONE)
        <%}%>             
        <%}%>             
        /*<%if((obj.testBench=="io_aiu") && (obj.INHOUSE_APB_VIP) && 
            ((obj.instanceName) ? (obj.BlockId == obj.instanceName) :
            (obj.DutInfo.ioaiuId==0))){ %>
                m_regs = <%=obj.BlockId%>_concerto_register_map_pkg::ral_sys_ncore::type_id::create("ral_sys_ncore", this);
                m_regs.build();
                m_regs.lock_model();
                uvm_config_db #(<%=obj.BlockId%>_concerto_register_map_pkg::ral_sys_ncore)::set(null,"","m_regs",m_regs);
        <% } else if(obj.testBench == 'fsys') { %>
        if(!uvm_config_db #(concerto_register_map_pkg::ral_sys_ncore)::get(null,"","m_regs",m_regs)) `uvm_fatal("Missing in DB::", "RAL m_regs not found");
        <% } %> */


        `ifndef USE_VIP_SNPS  
           // m_cfg.m_axi_master_agent_cfg.active = UVM_ACTIVE;
            m_cfg.m_axi_slave_agent_cfg.active  = UVM_ACTIVE;
            `uvm_info("build_phase 1", "Exiting...", UVM_LOW)
        `elsif
            m_cfg.m_axi_master_agent_cfg.active = UVM_PASSIVE;
            m_cfg.m_axi_slave_agent_cfg.active  = UVM_PASSIVE;
            `uvm_info("build_phase 2", "Exiting...", UVM_LOW)
        `endif
    endfunction

  /** Connect the AXI System ENV */
    virtual function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);

        if($test$plusargs("en_perf_trace")) begin
            file_handle = $fopen("perf_trace.txt","w");

            //m_sfi_master_agent.m_monitor.file_handle = file_handle;
            //m_sfi_slave_agent.m_monitor.file_handle = file_handle;
            m_axi_master_agent.m_monitor.file_handle = file_handle;
        end
        <%if(obj.NO_SCB === undefined) { %>
            <%if(!obj.CUSTOMER_ENV) { %>
                if(m_cfg.has_scoreboard) begin
                    m_axi_master_agent.read_addr_ap.connect               ( m_scb.read_addr_port               ) ;
                    m_axi_master_agent.write_addr_ap.connect              ( m_scb.write_addr_port              ) ;
                    m_axi_master_agent.read_data_ap.connect               ( m_scb.read_data_port               ) ;
                    m_axi_master_agent.read_data_advance_copy_ap.connect  ( m_scb.read_data_advance_copy_port  ) ;
                    m_axi_master_agent.write_data_every_beat_ap.connect   ( m_scb.write_data_port              ) ;
                    m_axi_master_agent.write_resp_ap.connect              ( m_scb.write_resp_port              ) ;
                    m_axi_master_agent.write_resp_advance_copy_ap.connect ( m_scb.write_resp_advance_copy_port ) ;
                    m_axi_master_agent.read_data_every_beat_ap.connect    ( m_scb.read_data_port_every_beat    ) ;

                    //connect probe agent to ioaiu scoreboard
                        m_probe_agent.probe_rtl_ap.connect                    ( m_scb.probe_rtl_port               ) ;
			m_probe_agent.probe_ottvec_ap.connect                 ( m_scb.probe_ottvec_port            ) ;
			m_probe_agent.probe_owo_ap.connect                 ( m_scb.probe_owo_port            ) ;
                        m_probe_agent.probe_cycle_tracker_ap.connect          ( m_scb.probe_cycle_tracker_port     );
                        m_probe_agent.probe_bypass_ap.connect                 ( m_scb.probe_bypass_port     );
            
                    <% if (obj.testBench=="fsys" || obj.testBench=="emu") { %>
                        // newperf test
                        if ($test$plusargs("newperf_test_scb")) begin
                            m_axi_master_agent.read_addr_ap.connect               ( m_newperf_test_ace_scb.read_addr_port               ) ;
                            m_axi_master_agent.write_addr_ap.connect              ( m_newperf_test_ace_scb.write_addr_port              ) ;
                            m_axi_master_agent.read_data_every_beat_ap.connect    ( m_newperf_test_ace_scb.read_data_port               ) ;
                            m_axi_master_agent.write_data_every_beat_ap.connect   ( m_newperf_test_ace_scb.write_data_port              ) ;
                            m_axi_master_agent.write_resp_ap.connect              ( m_newperf_test_ace_scb.write_resp_port              ) ;
                        end
                    <%}%>
                    <%if(obj.fnNativeInterface == "ACE" || obj.fnNativeInterface == "ACE5"|| ((obj.fnNativeInterface == "ACELITE-E" || obj.fnNativeInterface == "ACE-LITE") && obj.DutInfo.cmpInfo.nDvmSnpInFlight > 0)) { %>
                            m_axi_master_agent.snoop_addr_ap.connect              ( m_scb.snoop_addr_port          ) ;
                            m_axi_master_agent.snoop_resp_ap.connect              ( m_scb.snoop_resp_port          ) ;
                            m_axi_master_agent.snoop_data_ap.connect              ( m_scb.snoop_data_port          ) ;
                    <%}%>

                    // TODO: Re-connect below connections
                    <%var NSMIIFTX = obj.nSmiRx;
                    for(var i = 0; i < NSMIIFTX; i++){%>
                        //m_smi_agent.m_smi<%=i%>_tx_port_ap.connect             ( m_scb.ioaiu_smi_port      ) ;
                        if($test$plusargs("tcap_scb_en")) begin
                            // m_smi_agent.m_smi<%=i%>_tx_port_ap.connect          ( m_trace_debug_scb.analysis_smi<%=i%>_tx_port);
                            // <%if(i == (NSMIIFTX-1)){%>
                            //     m_smi_agent.m_smi<%=i%>_tx_ndp_ap.connect          ( m_trace_debug_scb.analysis_smi_dntx_ndp_only_port);
                            // <%}%>
                        end
                    <%}%>
                    <%var NSMIIFRX = obj.nSmiTx;
                    for(var i = 0; i < NSMIIFRX; i++){%>
                        //m_smi_agent.m_smi<%=i%>_rx_port_ap.connect             ( m_scb.ioaiu_smi_port      ) ;
                        if($test$plusargs("tcap_scb_en")) begin
                            //m_smi_agent.m_smi<%=i%>_rx_port_ap.connect         ( m_trace_debug_scb.analysis_smi<%=i%>_rx_port);
                            <%if(i == (NSMIIFRX-1)){%>
                                //m_smi_agent.m_smi<%=i%>_rx_ndp_ap.connect      ( m_trace_debug_scb.analysis_smi_dnrx_ndp_only_port);
                            <%}%>
                        end
                    <%}%>
            
                    m_scb.k_num_snoops = m_axi_master_agent.m_cfg.k_num_snp;
                    m_scb.k_num_reads  = m_axi_master_agent.m_cfg.k_num_read_req;
                    m_scb.k_num_sets  = m_axi_master_agent.m_cfg.num_sets;
                    m_scb.k_num_writes = m_axi_master_agent.m_cfg.k_num_write_req;
                    m_scb.k_num_evictions = m_axi_master_agent.m_cfg.k_num_eviction_req;
                    m_scb.axi_cmdreq_id_vif = axi_cmdreq_id_if;
                    <%if( obj.DutInfo.useCache) { %> 
                      <%if(obj.EN_CCP_SCB){%>
                    m_ccp_scb.axi_cmdreq_id_vif = axi_cmdreq_id_if;
                      <%}%>
                    <%}%>
                    if(m_cfg.hasRAL) begin
                        m_scb.m_regs       = m_regs;
                    end
                        
                    <%if((obj.DutInfo.useCache)) { %>                   
                        //ncbu_ccp_rtl_mon.ncbu_rtl_ap.connect ( m_scb.ncbu_ccp_rtl_port       ) ;
                        m_ccp_agent.ctrlwr_ap.connect        ( m_scb.ncbu_ccp_wr_data_port   ) ;
                        m_ccp_agent.ctrlstatus_ap.connect    ( m_scb.ncbu_ccp_ctrl_port      ) ;
                        m_ccp_agent.cachefillctrl_ap.connect ( m_scb.ncbu_ccp_fill_ctrl_port ) ;
                        m_ccp_agent.cachefilldata_ap.connect ( m_scb.ncbu_ccp_fill_data_port ) ;
                        m_ccp_agent.cacherdrsp_ap.connect    ( m_scb.ncbu_ccp_rd_rsp_port    ) ;
                        m_ccp_agent.cacheevict_ap.connect    ( m_scb.ncbu_ccp_evict_port     ) ;
                        <%if(obj.EN_CCP_SCB){%>
                            m_ccp_agent.ctrlwr_ap.connect        ( m_ccp_scb.ccp_wr_data_port    ) ;
                            m_ccp_agent.ctrlstatus_ap.connect    ( m_ccp_scb.ccp_ctrl_port       ) ;
                            m_ccp_agent.cachefillctrl_ap.connect ( m_ccp_scb.ccp_fill_ctrl_port  ) ;
                            m_ccp_agent.cachefilldata_ap.connect ( m_ccp_scb.ccp_fill_data_port  ) ;
                            m_ccp_agent.cacherdrsp_ap.connect    ( m_ccp_scb.ccp_rd_rsp_port     ) ;
                            m_ccp_agent.cacheevict_ap.connect    ( m_ccp_scb.ccp_evict_port      ) ;
                        <%}%>
                    <%}%>


        	`uvm_info(get_full_name(), $sformatf("connect_phase hasRAL:%0d", m_cfg.hasRAL), UVM_LOW)
            if(m_cfg.hasRAL) begin
                        m_apb_agent.m_apb_monitor.apb_req_ap.connect(m_scb.analysis_apb_port);
            end

                    <% if(!(obj.PSEUDO_SYS_TB && !(obj.FULL_SYS_TB == 1 && !obj.CUSTOMER_ENV))) { %>
                        <%if(obj.COVER_ON){%>

                        <%}%>
                    <%}%>
                    <% if (obj.testBench == 'ioaiu') { %>
                        m_q_chnl_agent.q_chnl_ap.connect(m_scb.analysis_q_chnl_port);
                    <%}%>
                end
            <%}%>
        <%}%>
       /* 
        <% if((obj.testBench=="io_aiu") && (obj.INHOUSE_APB_VIP) && 
            ((obj.instanceName) ? (obj.BlockId == obj.instanceName) :
            (obj.DutInfo.ioaiuId==0))) { %>
            m_regs.default_map.set_auto_predict(1);
            m_regs.default_map.set_sequencer(.sequencer(m_apb_agent.m_apb_sequencer),
                                            .adapter(m_apb_agent.m_apb_reg_adapter));
            if(m_cfg.has_scoreboard) begin
               m_scb.m_regs = this.m_regs; 
            end                            
        <%}%>*/
    endfunction
    virtual function void start_of_simulation_phase(uvm_phase phase);
    endfunction : start_of_simulation_phase

    /* print each master cache details */
    function void report_phase(uvm_phase phase);
        `ifdef USE_VIP_SNPS
            <%if (obj.testBench == "io_aiu") { %>
                //svt_axi_cache master_cache;
                //foreach(axi_system_env.master[i]) begin
                //  master_cache = axi_system_env.master[i].get_cache();
                //  `uvm_info("report_phase", $psprintf("Cache contents of master %0d", i),UVM_HIGH)
                //  master_cache.print();
                //end
            <%}%>
        `endif
        $fclose(file_handle);
    endfunction
endclass
