class ccp_env extends uvm_env;
    `uvm_component_param_utils(ccp_env)

    //CCP Local variables
    bit             has_scoreboard=1;
    bit             has_functional_coverage;
    ccp_agent       m_agent;
   // ccp_scoreboard  m_scb;
    ccp_agent_config  m_cfg;


    //Constructor
    function new (string name="ccp_env", uvm_component parent=null);
        super.new (name, parent);
    endfunction

    //build_phase
    virtual function void build_phase(uvm_phase phase);
        `uvm_info("build_phase", "Entered...",UVM_LOW)
        super.build_phase(phase);

        if (!uvm_config_db#(ccp_agent_config)::get(.cntxt( this ), 
                                                   .inst_name ( "" ), 
                                                   .field_name( "ccp_agent_config" ),
                                                   .value( m_cfg ))) begin
          `uvm_fatal( get_name(),"m_ccp_agent_config not found" )
        end
        
        m_agent = ccp_agent::type_id::create("ccp_agent", this);

        uvm_config_db#(ccp_agent_config)::set(.cntxt( this ), 
                                              .inst_name ( "*" ), 
                                              .field_name( "ccp_agent_config" ),
                                              .value( m_cfg ));
      
        if(m_cfg.has_scoreboard) begin
     //       m_scb = ccp_scoreboard::type_id::create("m_scb", this);
        end

        `uvm_info("build_phase", "Exiting...", UVM_LOW)
    endfunction

    //connect_phase 
    virtual function void connect_phase(uvm_phase phase);
        `uvm_info("connect_phase", "Entered...",UVM_LOW)
        super.connect_phase(phase);

        if(m_cfg.has_scoreboard) begin
      //      m_agent.ctrlwr_ap.connect(m_scb.ccp_wr_data_port);
      //      m_agent.ctrlstatus_ap.connect(m_scb.ccp_ctrl_port);
      //      m_agent.cachefillctrl_ap.connect(m_scb.ccp_fill_ctrl_port);
      //      m_agent.cachefilldata_ap.connect(m_scb.ccp_fill_data_port);
      //      m_agent.cacherdrsp_ap.connect(m_scb.ccp_rd_rsp_port);
      //      m_agent.cacheevict_ap.connect(m_scb.ccp_evict_port);
        end
    
    endfunction

    virtual function void start_of_simulation_phase(uvm_phase phase);
        `uvm_info("start_of_simulation_phase", "Entered...",UVM_LOW)
    endfunction : start_of_simulation_phase

endclass

