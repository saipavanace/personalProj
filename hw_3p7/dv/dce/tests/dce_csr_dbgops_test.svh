/******************************************************
 Javascript utility functions/calculations
******************************************************/

<% 
var nCacheIds = 0;
var maxDvm_wAxAddr = 0
var has_dvm = 0
obj.AiuInfo.forEach( function(agent) {
    if(agent.NativeInfo.DvmInfo.nDvmMsgInFlight) {
	maxDvm_wAxAddr = (agent.NativeInfo.SignalInfo.wAxAddr > maxDvm_wAxAddr) ? agent.NativeInfo.SignalInfo.wAxAddr : maxDvm_wAxAddr
	has_dvm = 1			       
    }
    if(agent.fnNativeInterface == "ACE") {
       nCacheIds++
    }
});
obj.BridgeAiuInfo.forEach( function(agent) {
    if(agent.NativeInfo.DvmInfo.nDvmMsgInFlight) {
	maxDvm_wAxAddr = (agent.NativeInfo.SignalInfo.wAxAddr > maxDvm_wAxAddr) ? agent.NativeInfo.SignalInfo.wAxAddr : maxDvm_wAxAddr
	has_dvm = 1			       
    }
    if(agent.NativeInfo.useIoCache == 1) {
       nCacheIds++
    }
});
%>

<%
var numCmdSkidEntries = 1
var cmdSkidWidth = obj.DceInfo.Derived.wSfiSlaveTransId + obj.DceInfo.Derived.wSfiAddr + obj.Derived.sfiPriv.width + obj.wSecurityAttribute + obj.wPriorityLevel + 2

var numUpdSkidEntries = 1
var updSkidWidth = obj.DceInfo.Derived.wSfiSlaveTransId + obj.DceInfo.Derived.wSfiAddr + obj.Derived.sfiPriv.width + obj.wSecurityAttribute + obj.wPriorityLevel + 2

var numAttEntries = obj.DceInfo.CmpInfo.nAttCtrlEntries
var attWidth = obj.DceInfo.Derived.wSfiAddr + obj.Derived.sfiPriv.width + 2 * nCacheIds + 1 + obj.wSecurityAttribute + 1 + 2 + 1 + obj.Derived.sfiPriv.ST.width + obj.Derived.sfiPriv.SD.width + obj.Derived.sfiPriv.SO.width + obj.Derived.sfiPriv.SS.width + obj.wPriorityLevel + nCacheIds + 1 + 1 + 1 + 1 + 1 + Math.ceil(Math.log2(obj.DceInfo.CmpInfo.nAttCtrlEntries)) + 1

var numDvmSkidEntries = 1
var dvmSkidWidth = maxDvm_wAxAddr*2 + obj.Derived.sfiPriv.width + 2 + obj.DceInfo.Derived.wSfiSlaveTransId + obj.wSecurityAttribute + obj.wPriorityLevel + 2

var numDvmDtfEntries = 1
var dvmDtfWidth = maxDvm_wAxAddr*2 + obj.Derived.sfiPriv.width + 2 + obj.DceInfo.Derived.wSfiSlaveTransId + obj.wSecurityAttribute + obj.wPriorityLevel + 2

var numDvmDsbEntries = 1
var dvmDsbWidth = 128 + obj.Derived.sfiPriv.width + 2 + obj.wSecurityAttribute + obj.wPriorityLevel + 2

var numDvmDrbEntries = 1
var dvmDrbWidth = obj.Derived.sfiPriv.width + obj.wSecurityAttribute + obj.wPriorityLevel + 3 + Math.ceil(Math.log2(obj.AiuInfo.length)) + 2
if(has_dvm) {
  var structs = ["cmd_skid", "upd_skid", "att", "dvm_skid", "dtf", "dsb", "drb"]
  var numEntriesArray = [numCmdSkidEntries, numUpdSkidEntries, numAttEntries, numDvmSkidEntries, numDvmSkidEntries, numDvmDtfEntries, numDvmDsbEntries, numDvmDrbEntries]
  var numWords = [Math.ceil(cmdSkidWidth / 32), Math.ceil(updSkidWidth / 32), Math.ceil(attWidth / 32), Math.ceil(dvmSkidWidth / 32), Math.ceil(dvmDtfWidth / 32), Math.ceil(dvmDsbWidth / 32), Math.ceil(dvmDrbWidth / 32)]
} else {
  var structs = ["cmd_skid", "upd_skid", "att"]
  var numEntriesArray = [numCmdSkidEntries, numUpdSkidEntries, numAttEntries]
  var numWords = [Math.ceil(cmdSkidWidth / 32), Math.ceil(updSkidWidth / 32), Math.ceil(attWidth / 32)]
}

var dbg_seq = ["DCEUDLR_DbgEntry", "DCEUDCR_DbgOp", "DCEUDAR_DbgOpActv", "DCEUDDR_DbgData"]

%>	

/******************************************************
 TEST DEFINITION
******************************************************/

class dce_csr_dbgops_test extends dce_test_base;
   `uvm_component_utils(dce_csr_dbgops_test)
   extern function new(string name = "dce_csr_dbgops_test", uvm_component parent = null);
   extern virtual function void build_phase(uvm_phase phase);
   extern virtual task run_phase(uvm_phase phase);
   extern virtual task run_main(uvm_phase phase);
endclass // dce_csr_dbgops_test
//------------------------------------------------------------------------------
// Constructor
//------------------------------------------------------------------------------
function dce_csr_dbgops_test::new(string name = "dce_csr_dbgops_test", uvm_component parent = null);
   super.new(name, parent);
  regs = new();
endfunction : new
//------------------------------------------------------------------------------
// Build Phase
//------------------------------------------------------------------------------
function void dce_csr_dbgops_test::build_phase(uvm_phase phase);
   super.build_phase(phase);
endfunction : build_phase

//------------------------------------------------------------------------------
// Run Phase
//------------------------------------------------------------------------------

task dce_csr_dbgops_test::run_phase(uvm_phase phase);
   fork
      this.run_main(phase);
      run_watchdog_timer(phase);
   join
endtask : run_phase

task dce_csr_dbgops_test::run_main(uvm_phase phase);

   dce_seq  test_seq = dce_seq::type_id::create("test_seq");

   phase.raise_objection(this);
   fork
      begin
          if($test$plusargs("inject_dbg_ops")) begin
              m_env.system_quiesce.wait_ptrigger();
	      reg_wait_for_value(32'h0, "DCEUSFMAR_MntOpActv", rd_data);
              `uvm_info("dce_test", "saw system quiesce",UVM_NONE)
<% if(obj.useHwDebug) { %>
              m_env.m_ocp_agent.m_ocp_driver.inject_dbg_seq();
<% } %>
              `uvm_info("dce_test", "saw end of debug injection",UVM_NONE)
              m_env.system_unquiesce.trigger();

              //End of the test
              //wait_for_dirutar_reg_inactive();
              //#10000ns;
              //`uvm_info("dce test", "All attid's are done", UVM_NONE)
              //m_env.m_ocp_agent.m_ocp_driver.inject_dbg_seq();
          end else begin
	      reg_wait_for_value(32'h0, "DCEUSFMAR_MntOpActv", rd_data);
              `uvm_info("dce_test", "reading ttdebug registers while traffic is active",UVM_NONE)
              //#Test.DCE.DbgOpsIgnoredWhenDbgOpActvIsSet
              repeat(10)
                  m_env.m_ocp_agent.m_ocp_driver.inject_dbg_seq();
          end
     end // fork begin
     begin
         test_seq = dce_seq::type_id::create("test_seq");  
         test_seq.m_csm = m_env.m_sb.m_csm;
         test_seq.m_gen = m_env.m_gen;
         test_seq.m_dirm_mgr = m_env.m_dirm_mgr;

         test_seq.wt_cmd_rd_cpy             = $urandom_range(8,10);
         test_seq.wt_cmd_rd_cln             = $urandom_range(8,10);
         test_seq.wt_cmd_rd_vld             = $urandom_range(8,10);
         test_seq.wt_cmd_rd_unq             = $urandom_range(8,10);
         test_seq.wt_cmd_cln_unq            = $urandom_range(8,10);
         test_seq.wt_cmd_cln_vld            = $urandom_range(8,10);
         test_seq.wt_cmd_cln_inv            = $urandom_range(8,10);
         test_seq.wt_cmd_wr_unq_ptl         = $urandom_range(8,10);
         test_seq.wt_cmd_wr_unq_full        = $urandom_range(8,10);
         test_seq.wt_cmd_upd_inv            = $urandom_range(8,10);
         test_seq.wt_cmd_dvm_msg            = $urandom_range(8,10);

         test_seq.k_num_cmd          = $urandom_range(10000, 20000);
         test_seq.k_num_addr         = get_dirm_entries_cnt();


         //Populate SnoopFilter Tables
         test_seq.m_master_sequencer = m_env.m_sfi_master_agent.m_master_sequencer;
         test_seq.m_slave_sequencer  = m_env.m_sfi_slave_agent.m_slave_sequencer;
         test_seq.start(null);
     end
  join
   phase.drop_objection(this);
endtask : run_main
