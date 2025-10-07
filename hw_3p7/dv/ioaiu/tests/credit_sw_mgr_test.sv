<%

var scbPrefixPath = function() {
  if (obj.testBench == "chi_aiu") {
      return "m_env.m_scb";} 
  else {
      return "env.m_scb";}
  };
%>

class credit_sw_mgr_test extends <%=`${(() => {
                                                return "bring_up_test"; // By default  
                                            })()}`%>;

  `uvm_component_utils(credit_sw_mgr_test)

                                  
  function new(string name = "credit_sw_mgr_test", uvm_component parent=null);
    super.new(name,parent);

  endfunction: new

  // UVM PHASE
  extern function void build_phase(uvm_phase phase);
  extern task run_phase (uvm_phase phase);
  extern task post_shutdown_phase (uvm_phase phase);

  // HOOK task call in the parent class
  extern virtual task csr_seq_pre_hook(uvm_phase phase); // before the iteration (outside the iteration loop)
  extern virtual task csr_seq_post_hook(uvm_phase phase); // after the iteration (outside the iteration loop)
  extern virtual task csr_seq_iter_pre_hook(uvm_phase phase, uint64_type iter); // at the beginning of the iteration(inside the iteration loop)
  extern virtual task csr_seq_iter_post_hook(uvm_phase phase, uint64_type iter);// at the end of the iteration (inside the iteration)
  extern virtual task main_seq_pre_hook(uvm_phase phase); // before the iteration (outside the iteration loop)
  extern virtual task main_seq_post_hook(uvm_phase phase); // after the iteration (outside the iteration loop)
  extern virtual task main_seq_iter_pre_hook(uvm_phase phase, uint64_type iter); // at the beginning of the iteration(inside the iteration loop)
  extern virtual task main_seq_iter_post_hook(uvm_phase phase, uint64_type iter);// at the end of the iteration (inside the iteration)
  extern virtual task main_seq_hook_end_run_phase(uvm_phase phase);// at the very end of the run_phase 
  extern         task credit_sw_mgr_processing(uvm_phase phase, uint64_type iter);
  extern         task check_no_smi_activity(); // Check that there is no SMI activities

  int i = 0;
  int nOttEntries  = <%=obj.AiuInfo[obj.Id].cmpInfo.nOttCtrlEntries%> > 30 ? 30 : <%=obj.AiuInfo[obj.Id].cmpInfo.nOttCtrlEntries%>;
  int creditLimit [];

  // Interfaces
  virtual <%=obj.BlockId%>_connectivity_if connectivity_if;

endclass: credit_sw_mgr_test


//METHOD Definitions
///////////////////////////////////////////////////////////////////////////////// 
// #     #  #     #  #     #         ######   #     #     #      #####   #######  
// #     #  #     #  ##   ##         #     #  #     #    # #    #     #  #        
// #     #  #     #  # # # #         #     #  #     #   #   #   #        #        
// #     #  #     #  #  #  #         ######   #######  #     #   #####   #####    
// #     #   #   #   #     #         #        #     #  #######        #  #        
// #     #    # #    #     #         #        #     #  #     #  #     #  #        
//  #####      #     #     #  #####  #        #     #  #     #   #####   #######  
///////////////////////////////////////////////////////////////////////////////// 

function void credit_sw_mgr_test::build_phase(uvm_phase phase);

  super.build_phase(phase);
  cfg_seq_iter = 10;
  main_seq_iter = 10;

  if (!uvm_config_db#(virtual <%=obj.BlockId%>_connectivity_if)::get(null, "", "<%=obj.BlockId%>_connectivity_if", connectivity_if)) begin
    `uvm_fatal("Connectivity interface error", "virtual interface must be set for connectivity_if");
  end
  if (!$test$plusargs("negative_err_credits")) begin
    creditLimit = new [30];
    //#Stimulus.IOAIU.v3.4.SCM.RandomCredit
    for (int i=0; i<30; i++) begin
      creditLimit[i] = i+1;
      `uvm_info(get_name(), $sformatf("KDB creditLimit[%0d]=%0d,)", i, creditLimit[i]), UVM_MEDIUM);
    end
  end else begin // FOr negative counter state
    creditLimit = new [3];
    creditLimit = {(nOttEntries*1/3), (nOttEntries*3/3), (nOttEntries*2/3)};
  end
  `uvm_info(get_name(), $sformatf("KDB creditLimit=%p,)",creditLimit), UVM_MEDIUM);

endfunction : build_phase


task credit_sw_mgr_test::run_phase (uvm_phase phase); 
  //fork
  //  begin
      super.run_phase(phase);
  //  end
  //  begin
  //    check_no_smi_activity();
  //  end
  //join_any
endtask:run_phase

////////////////////////////////////////////////////////////////////////////////////////
// #     #  #######  #######  #    #         #######     #      #####   #    #   #####   
// #     #  #     #  #     #  #   #             #       # #    #     #  #   #   #     #  
// #     #  #     #  #     #  #  #              #      #   #   #        #  #    #        
// #######  #     #  #     #  ###               #     #     #   #####   ###      #####   
// #     #  #     #  #     #  #  #              #     #######        #  #  #          #  
// #     #  #     #  #     #  #   #             #     #     #  #     #  #   #   #     #  
// #     #  #######  #######  #    #  #####     #     #     #   #####   #    #   #####  
////////////////////////////////////////////////////////////////////////////////////////
//////////////////// PRE HOOK                   ////////////
task credit_sw_mgr_test::main_seq_pre_hook(uvm_phase phase);
  `uvm_info(get_name(), "HOOK main_seq_pre_hook", UVM_NONE)

  `uvm_info(get_name(),$sformatf("Value main_seq_iter = %0d", main_seq_iter), UVM_NONE)
  `uvm_info(get_name(),$sformatf("Value cfg_seq_iter = %0d", cfg_seq_iter), UVM_NONE)

  `uvm_info(get_name(), "end of HOOK main_seq_pre_hook", UVM_NONE)
endtask:main_seq_pre_hook

task credit_sw_mgr_test::csr_seq_pre_hook(uvm_phase phase);
  `uvm_info(get_name(), "HOOK csr_seq_pre_hook", UVM_NONE)

  if ($test$plusargs("cfg_seq_iter")) begin
    $value$plusargs("cfg_seq_iter=%0d", cfg_seq_iter);
  end
  `uvm_info(get_name(),$sformatf("Value cfg_seq_iter = %0d", cfg_seq_iter), UVM_NONE)

  `uvm_info(get_name(), "end of HOOK csr_seq_pre_hook", UVM_NONE)
endtask:csr_seq_pre_hook

////////////////////////////////////////////////////////////
//////////////////// PRE HOOK in ITERATION loop ////////////
task credit_sw_mgr_test::main_seq_iter_pre_hook(uvm_phase phase, uint64_type iter);
  `uvm_info(get_name(), $sformatf("HOOK main_seq_iter_pre_hook 0x%0h('d%0d)",iter,iter), UVM_NONE)
//  m_master_pipelined_seq.k_num_read_req                 = 10 * iter+!;
 // m_master_pipelined_seq.k_num_write_req                =  10 * iter+!;


  `uvm_info(get_name(), "end of HOOK main_seq_iter_pre_hook", UVM_NONE)
endtask:main_seq_iter_pre_hook

task credit_sw_mgr_test::csr_seq_iter_pre_hook(uvm_phase phase, uint64_type iter);
  `uvm_info(get_name(), $sformatf("HOOK csr_seq_iter_pre_hook 0x%0h('d%0d)",iter,iter), UVM_NONE)
  //Commenting the iter module 3 part, for negative state test make sure you only run cfg_seq_iter=3;
  //`uvm_info(get_name(), $sformatf("KDB creditLimit[iter modulo 3]=%0d, iter=%0d)",creditLimit[iter%3], iter), UVM_LOW);
  `uvm_info(get_name(), $sformatf("KDB creditLimit[%d]=%0d)", iter, creditLimit[iter]), UVM_NONE);


  for (int i=0; i<<%=obj.DutInfo.nNativeInterfacePorts%>;i++)begin
    for (int j=0; j<<%=obj.nDCEs%>; j++) begin
      m_env_cfg[i].dceCreditLimitTemp[j] = creditLimit[iter];
    end
  end
  
  for (int i=0; i<<%=obj.DutInfo.nNativeInterfacePorts%>;i++)begin
    for (int j=0; j<<%=obj.nDMIs%>; j++) begin
      m_env_cfg[i].dmiCreditLimitTemp[j] = creditLimit[iter];
    end
  end
  
  for (int i=0; i<<%=obj.DutInfo.nNativeInterfacePorts%>;i++)begin
    for (int j=0; j<<%=obj.nDIIs%>; j++) begin
      m_env_cfg[i].diiCreditLimitTemp[j] = creditLimit[iter];
    end
  end

  `uvm_info(get_name(), "end of HOOK csr_seq_iter_pre_hook", UVM_NONE)
endtask:csr_seq_iter_pre_hook

//////////////////////////////////////// ////////////////////
//////////////////// POST HOOK in ITERATION loop ///////////
task credit_sw_mgr_test::main_seq_iter_post_hook(uvm_phase phase, uint64_type iter);
  `uvm_info(get_name(), "HOOK main_seq_iter_post_hook", UVM_NONE)

  credit_sw_mgr_processing(phase,iter);

  `uvm_info(get_name(), "end of HOOK main_seq_iter_post_hook", UVM_NONE)
endtask:main_seq_iter_post_hook

task credit_sw_mgr_test::csr_seq_iter_post_hook(uvm_phase phase, uint64_type iter);
  `uvm_info(get_name(), "HOOK csr_seq_iter_post_hook", UVM_NONE)
  fork
    begin
      //The wait was originally added to synchromize the scoreboard
      wait (connectivity_if.ott_entries >= (creditLimit[iter%3]-1));
    end
    begin
      #10us;
    end
  join_any

  `uvm_info(get_name(), "end of HOOK csr_seq_iter_post_hook", UVM_NONE)
endtask:csr_seq_iter_post_hook

////////////////////////////////////////////////////////////
////////////   HOOK END RUN PHASE       ///////////////
task credit_sw_mgr_test::main_seq_hook_end_run_phase(uvm_phase phase);
  phase.raise_objection(this, "main_seq_hook_end_run_phase");
  `uvm_info(get_name(), "HOOK main_seq_hook_end_run_phase", UVM_NONE)

  
  `uvm_info(get_name(), "end of HOOK main_seq_hook_end_run_phase", UVM_NONE)
   phase.drop_objection(this, "main_seq_hook_end_run_phase");
endtask:main_seq_hook_end_run_phase

////////////////////////////////////////////////////////////
//////////////////// POST HOOK              ///////////////
task credit_sw_mgr_test::main_seq_post_hook(uvm_phase phase);
  `uvm_info(get_name(), "HOOK main_seq_post_hook", UVM_NONE)
  
  `uvm_info(get_name(), "end of HOOK main_seq_post_hook", UVM_NONE)
endtask:main_seq_post_hook

task credit_sw_mgr_test::csr_seq_post_hook(uvm_phase phase);
  `uvm_info(get_name(), "HOOK csr_seq_post_hook", UVM_NONE)
  
  `uvm_info(get_name(), "end of HOOK csr_seq_post_hook", UVM_NONE)
endtask:csr_seq_post_hook

task credit_sw_mgr_test::check_no_smi_activity(); 

  forever begin
    @(posedge connectivity_if.clk)
    <% for (var j=0; j<obj.nDCEs; j++) { %> 
    if(m_smi0_rx_port_config.m_vif.smi_msg_ready && m_smi0_rx_port_config.m_vif.smi_msg_valid &&
    m_smi0_rx_port_config.m_vif.smi_msg_type != SYS_REQ && 
    connectivity_if.XAIUCCR<%=j%>_DCECounterState == 'b010 &&
    m_smi0_rx_port_config.m_vif.smi_targ_id>>WSMINCOREPORTID == addrMgrConst::dce_ids[<%=j%>] ) begin        
      `uvm_error(get_name(),$sformatf("Signal activities detected on SMI0_Tx when not supposed to be any as test for Negative DCE%0d Credit Counter State", <%=j%>))
    end 
    <% } %>
    <% for (var j=0; j<obj.nDMIs; j++) { %> 
    if(m_smi0_rx_port_config.m_vif.smi_msg_ready && m_smi0_rx_port_config.m_vif.smi_msg_valid &&
    m_smi0_rx_port_config.m_vif.smi_msg_type != SYS_REQ && 
    connectivity_if.XAIUCCR<%=j%>_DMICounterState == 'b010 &&
    m_smi0_rx_port_config.m_vif.smi_targ_id>>WSMINCOREPORTID == addrMgrConst::dmi_ids[<%=j%>] ) begin        
      `uvm_error(get_name(),$sformatf("Signal activities detected on SMI0_Tx when not supposed to be any as test for Negative DMI%0d Credit Counter State", <%=j%>))
    end 
    <% } %>
    <% for (var j=0; j<obj.nDIIs; j++) { %> 
    if(m_smi0_rx_port_config.m_vif.smi_msg_ready && m_smi0_rx_port_config.m_vif.smi_msg_valid &&
    m_smi0_rx_port_config.m_vif.smi_msg_type != SYS_REQ && 
    connectivity_if.XAIUCCR<%=j%>_DIICounterState == 'b010 &&
    m_smi0_rx_port_config.m_vif.smi_targ_id>>WSMINCOREPORTID == addrMgrConst::dii_ids[<%=j%>] ) begin        
      `uvm_error(get_name(),$sformatf("Signal activities detected on SMI0_Tx when not supposed to be any as test for Negative DII%0d Credit Counter State", <%=j%>))
    end 
    <% } %>
  end
  
endtask : check_no_smi_activity


////////////////////////////////////////////////////////////
///////////// PROCESS COUNTER              ///////////////
task credit_sw_mgr_test::credit_sw_mgr_processing(uvm_phase phase, uint64_type iter);
  #250ns;

endtask:credit_sw_mgr_processing

task credit_sw_mgr_test::post_shutdown_phase(uvm_phase phase);
endtask:post_shutdown_phase


////////////////////////////////////////////////////////////////////
//#######  #     #  #     #   #####   #######  ###  #######  #     #  
//#        #     #  ##    #  #     #     #      #   #     #  ##    #  
//#        #     #  # #   #  #           #      #   #     #  # #   #  
//#####    #     #  #  #  #  #           #      #   #     #  #  #  #  
//#        #     #  #   # #  #           #      #   #     #  #   # #  
//#        #     #  #    ##  #     #     #      #   #     #  #    ##  
//#         #####   #     #   #####      #     ###  #######  #     #  
////////////////////////////////////////////////////////////////////

