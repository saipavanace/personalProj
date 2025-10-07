

<%if (obj.testBench == "dii") {%>
`define NUM_AXI_MASTERS 0
`define NUM_AXI_SLAVES  1
`define NUM_AXI_CFGS 1
`define NUM_APB_CFGS  1
`define NUM_APBS  1
<%}%>

class dii_amba_env_config extends svt_amba_system_configuration;

/** UVM Object Utility macro */
`uvm_object_utils (dii_amba_env_config)




/** Class Constructor */
function new (string name = "dii_amba_env_config");
  super.new(name);

  //create_sub_cfgs ( int num_axi_systems = 0, int num_ahb_systems = 0, int num_apb_systems = 0, int num_chi_systems = 0 )
  this.create_sub_cfgs(`NUM_AXI_CFGS,0,`NUM_APB_CFGS,0);
  

endfunction : new



function void set_axi_config();

  this.axi_sys_cfg[0].num_masters = `NUM_AXI_MASTERS;
  this.axi_sys_cfg[0].num_slaves  = `NUM_AXI_SLAVES;

  /** Create port configurations */
  /* 3rd and 4th arguments are for intercconnect */

  this.axi_sys_cfg[0].create_sub_cfgs(`NUM_AXI_MASTERS,`NUM_AXI_SLAVES,0,0);

  this.axi_sys_cfg[0].bus_inactivity_timeout = 0;
  this.axi_sys_cfg[0].use_interconnect = 0;
  this.axi_sys_cfg[0].system_monitor_enable = 0;
  this.axi_sys_cfg[0].bready_watchdog_timeout      = 100000;
  this.axi_sys_cfg[0].rready_watchdog_timeout      = 100000;

  this.axi_sys_cfg[0].slave_cfg[0].is_active                    = 1;
  this.axi_sys_cfg[0].slave_cfg[0].num_read_outstanding_xact    = 128;
  this.axi_sys_cfg[0].slave_cfg[0].num_write_outstanding_xact   = 128;
  this.axi_sys_cfg[0].slave_cfg[0].num_outstanding_xact         = -1;
  this.axi_sys_cfg[0].slave_cfg[0].axi_interface_type           = svt_axi_port_configuration::AXI4;
  if($test$plusargs("snps_axi_protocol_checks_disable")) begin
  this.axi_sys_cfg[0].slave_cfg[0].protocol_checks_enable       = 0;
  end else begin
  this.axi_sys_cfg[0].slave_cfg[0].protocol_checks_enable       = 1;
  end
  this.axi_sys_cfg[0].slave_cfg[0].addr_width                   = <%=obj.DiiInfo[obj.Id].interfaces.axiInt.params.wAddr%>;
  this.axi_sys_cfg[0].slave_cfg[0].data_width                   = <%=obj.DiiInfo[obj.Id].interfaces.axiInt.params.wData%>;
  this.axi_sys_cfg[0].slave_cfg[0].id_width                     = <%=Math.max(obj.DiiInfo[obj.Id].interfaces.axiInt.params.wAwId,obj.DiiInfo[obj.Id].interfaces.axiInt.params.wArId)%>;
  this.axi_sys_cfg[0].slave_cfg[0].enable_xml_gen               = 0;
  this.axi_sys_cfg[0].slave_cfg[0].transaction_coverage_enable  = 0;
  this.axi_sys_cfg[0].slave_cfg[0].default_arready              = 1;
  this.axi_sys_cfg[0].slave_cfg[0].default_awready              = 1;
  this.axi_sys_cfg[0].slave_cfg[0].default_wready               = 1;
       
<%     if(obj.DiiInfo[obj.Id].interfaces.axiInt.params.wArUser > 0) { %>
  this.axi_sys_cfg[0].slave_cfg[0].aruser_enable                = 1;
<%     } else {%>
  this.axi_sys_cfg[0].slave_cfg[0].aruser_enable                = 0;
<%     } %>

<%     if(obj.DiiInfo[obj.Id].interfaces.axiInt.params.wAwUser > 0) { %>
  this.axi_sys_cfg[0].slave_cfg[0].awuser_enable                = 1;
<%     } else { %>
  this.axi_sys_cfg[0].slave_cfg[0].awuser_enable                = 0;
<%     } %>

<%     if(obj.DiiInfo[obj.Id].interfaces.axiInt.params.wRUser > 0) { %>
  this.axi_sys_cfg[0].slave_cfg[0].ruser_enable                 = 1;
<%     } else {%>
  this.axi_sys_cfg[0].slave_cfg[0].ruser_enable                 = 0;
<%     } %>

<%     if (obj.DiiInfo[obj.Id].interfaces.axiInt.params.wWUser > 0) { %>
  this.axi_sys_cfg[0].slave_cfg[0].wuser_enable                 = 1;
<%     } else {%>
  this.axi_sys_cfg[0].slave_cfg[0].wuser_enable                 = 0;
<%     } %>

<%     if (obj.DiiInfo[obj.Id].interfaces.axiInt.params.wBUser > 0) { %>
  this.axi_sys_cfg[0].slave_cfg[0].buser_enable                 = 1;
<%     } else {%>
  this.axi_sys_cfg[0].slave_cfg[0].buser_enable                 = 0;
<%     } %>
<%     if (obj.DiiInfo[obj.Id].interfaces.axiInt.params.wQos > 0) { %>
  this.axi_sys_cfg[0].slave_cfg[0].awqos_enable                 = 1;
  this.axi_sys_cfg[0].slave_cfg[0].arqos_enable                 = 1;
<%     } else {%>
  this.axi_sys_cfg[0].slave_cfg[0].awqos_enable                 = 0;
  this.axi_sys_cfg[0].slave_cfg[0].arqos_enable                 = 0;
<%     } %>


endfunction: set_axi_config

function void set_apb_config();

    this.apb_sys_cfg[0].create_sub_cfgs(`NUM_APBS); 
    //this.apb_sys_cfg[0].slave_addr_allocation_enable = 1;
    this.apb_sys_cfg[0].wait_for_reset_enable = 1;
    this.apb_sys_cfg[0].disable_x_check_of_presetn = 0;
    this.apb_sys_cfg[0].disable_x_check_of_pclk = 0;
    this.apb_sys_cfg[0].paddr_width = svt_apb_system_configuration::paddr_width_enum'(<%=obj.DiiInfo[obj.Id].interfaces.apbInt.params.wAddr%>);
    this.apb_sys_cfg[0].pdata_width = svt_apb_system_configuration::pdata_width_enum'(<%=obj.DiiInfo[obj.Id].interfaces.apbInt.params.wData%>);
    this.apb_sys_cfg[0].apb3_enable = 1;
    this.apb_sys_cfg[0].apb4_enable = 0;
    this.apb_sys_cfg[0].num_slaves = 1;

      /** Master setup */
    this.apb_sys_cfg[0].is_active = 1;
    this.apb_sys_cfg[0].enable_xml_gen = 1;
    this.apb_sys_cfg[0].slave_cfg[0].enable_xml_gen = 1;
    this.apb_sys_cfg[0].slave_cfg[0].is_active = 1;
      
    /** Enable UVM APB Ral Adapter */
    this.apb_sys_cfg[0].uvm_reg_enable = 1;
    
    this.apb_sys_cfg[0].transaction_coverage_enable = 0;
    this.apb_sys_cfg[0].slave_cfg[0].transaction_coverage_enable = 0;
    this.apb_sys_cfg[0].protocol_checks_coverage_enable = 0;
    this.apb_sys_cfg[0].slave_cfg[0].protocol_checks_coverage_enable = 0;

endfunction:set_apb_config

function void set_amba_env_config();

this.set_axi_config();
this.set_apb_config();

endfunction:set_amba_env_config


endclass

