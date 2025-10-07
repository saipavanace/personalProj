`ifndef GUARD_OCP_OCP_BASE_TEST_SV
`define GUARD_OCP_OCP_BASE_TEST_SV

<%  if((obj.BLK_SNPS_OCP_VIP)) { %>
`include "dmi_csr_seq_lib.sv"
<%  } %>
<%  if((obj.INHOUSE_OCP_VIP)) { %>
import apb_agent_pkg::*;
<%  } %>

class apb_base_test extends dmi_base_test;

  /** UVM Component Utility macro */
  `uvm_component_utils (apb_base_test)
    bit [31:0] wr_data;
    bit [31:0] rd_data;
    bit [31:0] mask_data;
    bit [31:0] r_data;
    bit [31:0] r_addr;
    bit [31:0] r_mask;
    bit [31:0] r_reset;
    bit [31:0]  addr;
    string     reg_name;
    int        lsb,msb;
    string     Rsvd; 

<%  if((obj.BLK_SNPS_OCP_VIP)) { %>
  svt_apb_master_transaction req;
  /** Customized configuration */ 
  cust_svt_apb_system_configuration test_cfg;
<%  } %>

  //dmi_reg regs;   

  int active_xact;

<%  if((obj.BLK_SNPS_OCP_VIP)) { %>
  csr_rmw_check_seq      rmw_seq ;
  csr_rd_seq             rd_seq ;
  csr_wr_seq             wr_seq ;
<%  } %>

<%  if((obj.INHOUSE_OCP_VIP)) { %>
  apb_agent_config       m_apb_cfg;
<%  } %>

  /** Class Constructor */
  function new (string name="apb_base_test", uvm_component parent=null);
    super.new (name, parent);
    //regs = new();
  endfunction : new

   task injectUncorrErrRtt();
<%  if(obj.useRttDataEntries > 0) { %>
   <% if ((obj.DmiInfo[obj.Id].cmpInfo.RttDataErrorInfo.fnErrDetectCorrect.substring(0,6) === "SECDED")) { %>
      m_env.injectDoubleErrRtt.trigger();
<% } else if ((obj.DmiInfo[obj.Id].cmpInfo.RttDataErrorInfo.fnErrDetectCorrect.substring(0,6) === "PARITY")) { %>
      m_env.injectSingleErrRtt.trigger();
<% } else { %>
      `uvm_error("injectUncorrErrRtt", "This task shouldn't be called in this config")
<%   }
}%>
      `uvm_info("injectUncorrErrRtt","Triggered environment event to cause error on next read",UVM_NONE);
   endtask // injectUncorrErrRtt


   task injectUncorrErrHtt();
<%  if(obj.nHttCtrlEntries > 0) { %>
<%   //console.log(obj.DmiInfo[obj.Id].cmpInfo.HttDataErrorInfo.fnErrDetectCorrect);
%>
   <% if ((obj.DmiInfo[obj.Id].cmpInfo.HttDataErrorInfo.fnErrDetectCorrect.substring(0,6) === "SECDED")) { %>
      m_env.injectDoubleErrHtt.trigger();
<% } else if ((obj.DmiInfo[obj.Id].cmpInfo.HttDataErrorInfo.fnErrDetectCorrect.substring(0,6) === "PARITY")) { %>
      m_env.injectSingleErrHtt.trigger();
<% } else { %>
      `uvm_error("injectUncorrErrHtt", "This task shouldn't be called in this config")
<%   }
}%>
      `uvm_info("injectUncorrErrHtt","Triggered environment event to cause error on next read",UVM_NONE);
   endtask // injectUncorrErrHtt

   task injectCorrErrRtt();
<%  if(obj.useRttDataEntries > 0) { %>
   <% if ((obj.DmiInfo[obj.Id].cmpInfo.RttDataErrorInfo.fnErrDetectCorrect.substring(0,6) === "SECDED")) { %>
      m_env.injectSingleErrRtt.trigger();
<% } else { %>
      `uvm_error("injectCorrErrRtt", "This task shouldn't be called in this config")
<%   }
}%>
      `uvm_info("injectCorrErrRtt","Triggered environment event to cause error on next read",UVM_NONE);
   endtask // injectCorrErrRtt

   task injectCorrErrHtt();
<%  if(obj.nHttCtrlEntries > 0) { %>
   <% if ((obj.DmiInfo[obj.Id].cmpInfo.HttDataErrorInfo.fnErrDetectCorrect.substring(0,6) === "SECDED")) { %>
      m_env.injectSingleErrHtt.trigger();
<% } else { %>
      `uvm_error("injectUncorrErrHtt", "This task shouldn't be called in this config")
<%   }
}%>
      `uvm_info("injectUncorrErrHtt","Triggered environment event to cause error on next read",UVM_NONE);
   endtask // injectCorrErrHtt

<% if (obj.useCmc) { %>

   task injectCcpTagErrSingle();
     
     randcase
  <%for( var i=0;i<obj.nTagBanks;i++){%>
      1: begin
           m_env.injectSingleErrTag<%=i%>.trigger();
           `uvm_info("injectCcpTagErrSingle","Triggered environment event to cause CCP Tag Single Err at entry=<%=i%>",UVM_NONE);
         end
  <% } %>
     endcase


   endtask 

   task injectCcpTagErrDouble();

     randcase
  <%for( var i=0;i<obj.nTagBanks;i++){%>
      1: begin
           m_env.injectDoubleErrTag<%=i%>.trigger();
           `uvm_info("injectCcpTagErrDouble","Triggered environment event to cause CCP Tag Double Err at entry=<%=i%>",UVM_NONE);
         end
  <% } %>
     endcase

   endtask


   task injectCcpDataErrSingle();

     randcase
  <%for( var i=0;i<obj.nDataBanks;i++){%>
      1: begin
           m_env.injectSingleErrData<%=i%>.trigger();
           `uvm_info("injectCcpDataErrSingle","Triggered environment event to cause CCP Data Single Err at entry=<%=i%>",UVM_NONE);
         end
  <% } %>
     endcase

   endtask 

   task injectCcpDataErrDouble();

     randcase
  <%for( var i=0;i<obj.nDataBanks;i++){%>
      1: begin
           m_env.injectDoubleErrData<%=i%>.trigger();
           `uvm_info("injectCcpDataErrDouble","Triggered environment event to cause CCP Data Double Err at entry=<%=i%>",UVM_NONE);
         end
  <% } %>
     endcase

   endtask

<% } %>
   
   /**
   * Build Phase
   * - Create and apply the customized configuration transaction factory.
   * - Create the TB ENV.
   * - Set the default sequences.
   * .
   */
  virtual function void build_phase(uvm_phase phase);
    `uvm_info("build_phase", "is entered",UVM_LOW)
    
    super.build_phase(phase);
    //m_env_cfg.has_scoreboard = 0;

<% if (obj.INHOUSE_OCP_VIP) { %>
  m_apb_cfg  = apb_agent_config::type_id::create("m_apb_cfg",  this);
  m_env_cfg.m_apb_cfg  = m_apb_cfg;
<% } %>
<%  if((obj.BLK_SNPS_OCP_VIP)) { %>
    rmw_seq  = csr_rmw_check_seq::type_id::create("rmw_seq");
    rd_seq  = csr_rd_seq::type_id::create("rd_seq");
    wr_seq  = csr_wr_seq::type_id::create("wr_seq");

    /** Create the configuration object */
    test_cfg = cust_svt_apb_system_configuration::type_id::create("test_cfg");

    /**
    * Apply the configuration to the env
    */
    uvm_config_db#(cust_svt_apb_system_configuration)::set(this, "m_env", "test_cfg", this.test_cfg);
<% } %>
    
    /**
    * Setup the agents as UVM_ACTIVE
    */
    uvm_config_db#(uvm_active_passive_enum)::set(this, "*_agent.is_active", "", UVM_ACTIVE);
    

<%  if((obj.BLK_SNPS_OCP_VIP)) { %>
    /**
    * Apply the default reset sequence to the reset_phase of the sb_sequencer 
    */
    uvm_config_db#(uvm_object_wrapper)::set(this, "*master_agent.sb_sequencer.reset_phase", "default_sequence", apb_sideband_reset_sequence::type_id::get());
<% } %>
    `uvm_info("build_phase", "is exited",UVM_LOW)


  endfunction : build_phase

  extern virtual task main_phase(uvm_phase phase);
  extern virtual task run_main(uvm_phase phase);
endclass: apb_base_test

task apb_base_test::main_phase(uvm_phase phase);
  fork
    run_main(phase);
    //run_watchdog_timer(phase);
  join
endtask : main_phase

 task apb_base_test::run_main(uvm_phase phase);

<%  if((obj.BLK_SNPS_OCP_VIP)) { %>
  fork
    begin
      while (1) begin
        m_env.apb_master_agent.driver.NOTIFY_DATAFLOW_TRANSACTION_STARTED.wait_trigger();
        if (this.active_xact == 0) begin
          phase.raise_objection(this);
        end
        this.active_xact++;
        `uvm_info("run_main", "objection raised",UVM_LOW)
      end
    end
    begin
      while (1) begin
       m_env.apb_master_agent.driver.NOTIFY_DATAFLOW_TRANSACTION_FINISHED.wait_trigger();
        this.active_xact--;
        if (this.active_xact == 0) begin
          phase.drop_objection(this);
        `uvm_info("run_main", "objection dropped",UVM_LOW)
        end
      end
    end
  join_none
<% } %>
    `uvm_info("end_of_run_main", "is exited",UVM_LOW)
  endtask : run_main
`endif //  `ifndef GUARD_OCP_OCP_BASE_TEST_SV
