
`define NUM_MASTERS 0
`define NUM_SLAVES  1
<%
    let derivedAxiInt;
    if(Array.isArray(obj.DmiInfo[obj.Id].interfaces.axiInt)){
        derivedAxiInt = obj.DmiInfo[obj.Id].interfaces.axiInt[0];
    }else{
        derivedAxiInt = obj.DmiInfo[obj.Id].interfaces.axiInt;
    }
%>
   


class cust_svt_axi_cfg extends svt_axi_system_configuration;

  /** UVM Object Utility macro */
  `uvm_object_utils (cust_svt_axi_cfg)
  dmi_env_config m_cfg;

  bit has_cache = <%= obj.useCmc%>;
  //Width of all channels
  int wAddr = <%= derivedAxiInt.params.wAddr%>;
  int wData = <%= derivedAxiInt.params.wData%>;
  int wResp = <%= derivedAxiInt.params.wResp%>;
  int wLen  = <%= derivedAxiInt.params.wLen%>;
  int wAwId  = <%= derivedAxiInt.params.wAwId%>;
  int wArId  = <%= derivedAxiInt.params.wArId%>;
  int wArUser = <%= derivedAxiInt.params.wArUser%>;
  int wAwUser = <%= derivedAxiInt.params.wAwUser%>;
  int wRUser = <%= derivedAxiInt.params.wRUser%>;
  int wWUser = <%= derivedAxiInt.params.wWUser%>;
  int wBUser = <%= derivedAxiInt.params.wBUser%>;

  bit has_ar_user = <%=(derivedAxiInt.params.wArUser > 0) ? 1 : 0 %>;
  bit has_aw_user = <%=(derivedAxiInt.params.wAwUser > 0) ? 1 : 0 %>;
  bit has_r_user = <%=(derivedAxiInt.params.wRUser > 0) ? 1 : 0 %>;
  bit has_w_user = <%=(derivedAxiInt.params.wWUser > 0) ? 1 : 0 %>;
  bit has_b_user = <%=(derivedAxiInt.params.wBUser > 0) ? 1 : 0 %>;
  bit unq_cache_state_allowed = <%=(derivedAxiInt.params.eUnique > 0 ) ? 1 : 0 %>;
  bit qos_enabled = <%=(derivedAxiInt.params.wQos > 0 ) ? 1 : 0 %>;

  //int master_ports[`NUM_MASTERS];
  rand int default_sequence_length;

  /** Class Constructor */
  function new (string name = "cust_svt_axi_cfg");
    super.new(name);
    if(!uvm_config_db#(dmi_env_config)::get(.cntxt( null ),
                                       .inst_name( "uvm_test_top.*" ),
                                       .field_name( "dmi_env_config" ),
                                       .value( m_cfg ))) begin
      `uvm_error(get_type_name(), "dmi_env_config handle not found")
    end
    default_sequence_length = 15;
    /** Assign the necessary configuration parameters. This example uses single
      * master and single slave configuration.
      */
    this.num_masters = `NUM_MASTERS;
    this.num_slaves  = `NUM_SLAVES;

    /* Add domain specific master ports */

    //add_domain_specific_ports();
    this.create_sub_cfgs(`NUM_MASTERS,`NUM_SLAVES);

    this.bus_inactivity_timeout = 0;
    this.use_interconnect = 0;

    this.system_monitor_enable = 0;
    this.rready_watchdog_timeout = 200000;
    this.set_addr_range(0, 'h0, 'hffff_ffff_fffff);
    
    for(int i = 0;i < `NUM_SLAVES;i++) begin // If AXI interface is > 1 modify all dmi_config_info package values to arrays
       slave_cfg[i].is_active                   = m_cfg.m_args.test_unit_duplication ? 0 : 1;
       slave_cfg[i].axi_interface_type          = svt_axi_port_configuration::AXI4;
       slave_cfg[i].addr_width                  = wAddr;
       slave_cfg[i].data_width                  = wData;
       slave_cfg[i].protocol_checks_enable      = 1;
       slave_cfg[i].read_data_reordering_depth  = (m_cfg.rand_OOO_axi_mode || (m_cfg.m_args.k_OOO_axi_response == 1) || m_cfg.m_args.k_OOO_axi_rd_response) ? 2 : 1;
       slave_cfg[i].write_resp_reordering_depth = (m_cfg.rand_OOO_axi_mode || (m_cfg.m_args.k_OOO_axi_response == 1) || m_cfg.m_args.k_OOO_axi_wr_response) ? 2 : 1 ;
       slave_cfg[i].reordering_algorithm        = m_cfg.axi_reordering_algorithm;
       slave_cfg[i].enable_xml_gen              = 1;
       slave_cfg[i].transaction_coverage_enable = 1;
       if(m_cfg.m_args.k_rtt_timeout_error_test)begin
         slave_cfg[i].default_rready             = 0;
         slave_cfg[i].default_arready            = 0;
       end
       else begin
         //Block transactions from time 0
         slave_cfg[i].default_arready  = !m_cfg.enable_axi_backpressure;
         slave_cfg[i].default_rready   = !m_cfg.enable_axi_backpressure;
       end
       if(m_cfg.m_args.k_smc_timeout_error_test || m_cfg.m_args.k_wtt_timeout_error_test)begin
         slave_cfg[i].default_wready              = 0;
         slave_cfg[i].default_awready             = 0;
       end
       else begin
         //Block transactions from time 0
         slave_cfg[i].default_awready  = !m_cfg.enable_axi_backpressure;
         slave_cfg[i].default_wready   = !m_cfg.enable_axi_backpressure;
       end
       slave_cfg[i].num_outstanding_xact        = -1;
       slave_cfg[i].num_read_outstanding_xact   = `SVT_AXI_MAX_NUM_OUTSTANDING_XACT;
       slave_cfg[i].num_write_outstanding_xact  = `SVT_AXI_MAX_NUM_OUTSTANDING_XACT;
       slave_cfg[i].exclusive_access_enable     = 1;
       slave_cfg[i].exclusive_monitor_enable    = 0;
       slave_cfg[i].aruser_enable               = has_ar_user;
       slave_cfg[i].awuser_enable               = has_aw_user;
       slave_cfg[i].ruser_enable                = has_r_user;
       slave_cfg[i].wuser_enable                = has_w_user;
       slave_cfg[i].buser_enable                = has_b_user;
       slave_cfg[i].awqos_enable                = qos_enabled;
       slave_cfg[i].arqos_enable                = qos_enabled;
       slave_cfg[i].read_data_chan_idle_val     = svt_axi_port_configuration::INACTIVE_CHAN_LOW_VAL;
       slave_cfg[i].read_data_interleave_size   = 1;
       if(m_cfg.m_args.prob_ace_rd_resp_error > 0 || m_cfg.m_args.prob_ace_wr_resp_error > 0) begin
        slave_cfg[i].error_response_policy = svt_axi_port_configuration :: ERROR_ON_BOTH;
       end
       else begin
         if(m_cfg.m_args.exclusive_monitor_size > 0) begin
           slave_cfg[i].exclusive_monitor_enable = 0;
         end
         else begin
           slave_cfg[i].exclusive_monitor_enable = 1;
         end
       end
       if(m_cfg.m_args.k_axi_zero_delay) begin
        slave_cfg[i].zero_delay_enable = 1 ;
       end
    end
  endfunction : new

  /* Add domain specific ports */
  /*function void add_domain_specific_ports();
      for(int i = 0; i < `NUM_MASTERS; i++) 
          master_ports[i] = i;
  endfunction: add_domain_specific_ports*/

  /* Specify non shareable address domain */
  function void specify_nonshrd_domain(bit [`SVT_AXI_ADDR_WIDTH - 1 : 0]start_addr = 0, bit [`SVT_AXI_ADDR_WIDTH - 1 : 0]end_addr = 0);
      if(start_addr == end_addr)  begin
          /* create an new domain */
          //this.create_new_domain(0, svt_axi_system_domain_item::NONSHAREABLE, master_ports);
          /* Sets an address range for the domain */
          this.set_addr_for_domain(0, 'h0, 'hffff);
      end else begin
          /* create an new domain */
          //this.create_new_domain(0, svt_axi_system_domain_item::NONSHAREABLE, master_ports);
          /* Sets an address range for the domain */
          this.set_addr_for_domain(0, start_addr, end_addr);
      end
      
  endfunction: specify_nonshrd_domain

  /*Specify inner shareable domain */
  function void specify_innshrd_domain(bit [`SVT_AXI_ADDR_WIDTH - 1 : 0]start_addr = 0, bit [`SVT_AXI_ADDR_WIDTH - 1 : 0]end_addr = 0);
    if(start_addr == end_addr) begin
        /* create an new domain */
        //this.create_new_domain(1, svt_axi_system_domain_item::INNERSHAREABLE, master_ports);
        /* Sets an address range for the domain */
        this.set_addr_for_domain(1, 'h10000, 'h1ffff);
    end else begin
          /* create an new domain */
          //this.create_new_domain(1, svt_axi_system_domain_item::INNERSHAREABLE, master_ports);
          /* Sets an address range for the domain */
          this.set_addr_for_domain(1, start_addr, end_addr);
    end
  endfunction: specify_innshrd_domain

  /*Specify Outer shareable domain */
  function void specify_outshrd_domain(bit [`SVT_AXI_ADDR_WIDTH - 1 : 0]start_addr = 0, bit [`SVT_AXI_ADDR_WIDTH - 1 : 0]end_addr = 0);
    if(start_addr == end_addr) begin
        /* create an new domain */
        //this.create_new_domain(2, svt_axi_system_domain_item::OUTERSHAREABLE, master_ports);
        /* Sets an address range for the domain */
        this.set_addr_for_domain(2, 'h20000, 'h2ffff);
    end else begin
          /* create an new domain */
          //this.create_new_domain(2, svt_axi_system_domain_item::OUTERSHAREABLE, master_ports);
          /* Sets an address range for the domain */
          this.set_addr_for_domain(2, start_addr, end_addr);
    end
  endfunction: specify_outshrd_domain

  /*Specify System domain */
  function void specify_system_domain(bit [`SVT_AXI_ADDR_WIDTH - 1 : 0]start_addr = 0, bit [`SVT_AXI_ADDR_WIDTH - 1 : 0]end_addr = 0);
    if(start_addr == end_addr) begin
        /* create an new domain */
        //this.create_new_domain(3, svt_axi_system_domain_item::SYSTEMSHAREABLE, master_ports);
        /* Sets an address range for the domain */
        this.set_addr_for_domain(3, 'h30000, 'h3ffff);
    end else begin
          /* create an new domain */
          //this.create_new_domain(3, svt_axi_system_domain_item::SYSTEMSHAREABLE, master_ports);
          /* Sets an address range for the domain */
          this.set_addr_for_domain(3, start_addr, end_addr);
    end
  endfunction: specify_system_domain

endclass
