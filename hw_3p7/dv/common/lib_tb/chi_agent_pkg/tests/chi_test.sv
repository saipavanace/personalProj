
package chi_unit_test;

import uvm_pkg::*;
`include "uvm_macros.svh"
import sv_assert_pkg::*;

import <%=obj.BlockId%>_chi_agent_pkg::*;

class chi_test extends uvm_test;

  `uvm_component_utils(chi_test)

  chi_agent_cfg m_cfg;
  chi_agent     m_agt;
  chi_rn_driver_vif  m_drv_vif;
  chi_rn_monitor_vif m_mon_vif;

  function new(
    string name = "chi_test",
    uvm_component parent = null);
    super.new(name, parent);
  endfunction: new

  function void build_phase(uvm_phase phase);
  
    super.build_phase(phase);

    if (!uvm_config_db #(chi_rn_driver_vif)::get(
      this, "", "chi_rn_driver_vif", m_drv_vif)) begin

      `uvm_fatal(get_name(), "Unable to find driver vif")
    end

    if (!uvm_config_db #(chi_rn_monitor_vif)::get(
      this, "", "chi_rn_monitor_vif", m_mon_vif)) begin

      `uvm_fatal(get_name(), "Unable to find monitor vif")
    end

    m_cfg = chi_agent_cfg::type_id::create("m_cfg");
    m_cfg.chi_node_type = RN_F;
    m_cfg.agent_cfg     = AGENT_ACTIVE;
    uvm_config_db #(chi_agent_cfg)::set(this, "m_agt", "config_object", m_cfg);

    uvm_config_db #(chi_rn_driver_vif)::set(this,
      "m_agt", "chi_rn_driver_vif", m_drv_vif);

    uvm_config_db #(chi_rn_monitor_vif)::set(this,
      "m_agt", "chi_rn_monitor_vif", m_mon_vif);
     
    //Construct chi_agent 
    m_agt = chi_agent::type_id::create("m_agt", this);
  endfunction: build_phase

  task run_phase(uvm_phase phase);
    phase.raise_objection(this);
    `uvm_info(get_name(), "Starting test", UVM_NONE)
    #1000ns;
    `uvm_info(get_name(), "Stoping  test", UVM_NONE)
    phase.drop_objection(this);

  endtask: run_phase

endclass: chi_test

endpackage: chi_unit_test
