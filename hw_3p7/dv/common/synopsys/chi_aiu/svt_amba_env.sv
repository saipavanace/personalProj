//=======================================================================
// COPYRIGHT (C) 2013 SYNOPSYS INC.
// This software and the associated documentation are confidential and
// proprietary to Synopsys, Inc. Your use or disclosure of this software
// is subject to the terms and conditions of a written license agreement
// between you, or your company, and Synopsys, Inc. In the event of
// publications, the following notice is applicable:
//
// ALL RIGHTS RESERVED
//
// The entire notice above must be reproduced on all authorized copies.
//-----------------------------------------------------------------------

/**
 * Abstract: 
 * class 'svt_amba_env' is extended from uvm_env base class.  It implements
 * the build phase to construct the structural elements of this environment.
 *
 * svt_amba_env is the testbench environment, which constructs the AMBA System
 * ENV in the build_phase method using the UVM factory service.  The AMBA System
 * ENV is the top level component provided by the VIP. The AMBA System ENV
 * in turn constructs the CHI System ENV. 
 * CHI System ENV contains CHI RN agents,SN agents, AXI4 Master agents and AXI4 Slave agents.
 *
 * The simulation ends after all the objections are dropped.  This is done by
 * using objections provided by phase arguments.
 */
`ifndef GUARD_AMBA_BASIC_ENV_SV
`define GUARD_AMBA_BASIC_ENV_SV

`include "snps_compile.sv"

package svt_amba_env_class_pkg;
import uvm_pkg::*;
`include "uvm_macros.svh"

`include "snps_import.sv"
`include "cust_svt_amba_system_configuration.sv"

class svt_amba_env extends uvm_env;

  /** Reset control interface */
  //virtual tb_reset_if rst_vif;

  /** AMBA System ENV */
  svt_amba_system_env   amba_system_env;

  /** Configuration class which is extended from AMBA System Configuration class. */
  cust_svt_amba_system_configuration cfg;

  /** UVM Component Utility macro */
  `uvm_component_utils(svt_amba_env)

  /** Class Constructor */
  function new (string name="svt_amba_env", uvm_component parent=null);
    super.new (name, parent);
  endfunction

  /** Build and configure the AMBA System ENV */
  virtual function void build_phase(uvm_phase phase);
    `uvm_info("build_phase", "Entered...",UVM_LOW)

    super.build_phase(phase);

    /** Get the reset interface */
    //if (!uvm_config_db#(virtual tb_reset_if)::get(this, "", "reset_if", rst_vif)) begin
    //  `uvm_fatal("build", "An instance to the tb_reset_if interface was not supplied to the environment")
    //  return;
    //end

    /**
     * Check if the configuration is passed to the environment.  If not then
     * create the configuration and pass it to the agent. Note that
     * cust_svt_amba_system_configuration::set_amba_sys_config used below is a
     * testbench utility method used to initialize configuration of the AMBA
     * System ENV and underlying CHI System ENV and AXI System ENV.
     */
    if (!uvm_config_db#(cust_svt_amba_system_configuration)::get(this, "", "svt_cfg", cfg)) begin
        <% if (obj.testBench == "fsys") { %>
            `uvm_fatal("Missing Config Obj", "cust_svt_amba_system_configuration object in UVM DB");
        <% } else { %>
            cfg = cust_svt_amba_system_configuration::type_id::create("cfg");
            cfg.set_amba_sys_config();
        <% } %>
    end

    /** Apply the configuration to the AMBA System ENV */
    uvm_config_db#(svt_amba_system_configuration)::set(this, "amba_system_env", "cfg", cfg);

    /** Construct the AMBA system ENV */
    amba_system_env = svt_amba_system_env::type_id::create("amba_system_env", this);

    `uvm_info("build_phase", "Exiting...", UVM_LOW)
  endfunction

endclass
endpackage

`endif // GUARD_AMBA_BASIC_ENV_SV
