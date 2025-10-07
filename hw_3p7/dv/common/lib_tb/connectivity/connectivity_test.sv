<%
var aiu;
if(obj.testBench === "fsys") {
    aiu = obj.AiuInfo[obj.Id];
} else {
    aiu = obj.DutInfo;
}

var scbPrefixPath = function() {
  if (obj.testBench == "chi_aiu") {
      return "m_env.m_scb";} 
  else {
      return "env.m_scb";}
  };
%>
import <%=obj.BlockId%>_connectivity_defines::*;

class connectivity_test extends <%=`${(() => {
                                              if (obj.BlockId.includes("dmi")) {return "dmi_test";}
                                              if (obj.BlockId.includes("dve")) {return "dve_bringup_test";}
                                              if (obj.BlockId.includes("dce")) {return "dce_bringup_test";}

                                              if (obj.BlockId.includes("dii")) {return "dii_test";}

                                              if (obj.AiuInfo[obj.Id].fnNativeInterface.includes('CHI')) {
                                                return "chi_aiu_bringup_test";}
                                              if  (obj.BlockId.includes("ncaiu") || ( obj.testBench == "fsys" && obj.AiuInfo[obj.Id].strRtlNamePrefix.includes("ncaiu"))){
                                                return "bring_up_test";} 
                                                return "bring_up_test"; // By default  
                                            })()}`%>;

  `uvm_component_utils(connectivity_test)

   //coverage instance
   <% if(obj.testbench == "chi_aiu") { %>
   chi_aiu_coverage cov;
   <% } %>

  //!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!                                  
  // !!! some declarations in the parent with the macro `macro_connectivity_test_all_declarations !!!!
  //!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!                                  
                                  
  function new(string name = "connectivity_test", uvm_component parent=null);
    super.new(name,parent);
    m_addr_mgr = addr_trans_mgr::get_instance();
   <% if(obj.testbench == "chi_aiu") { %>
    cov = new();
   <% } %>

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
  extern         task connectivity_processing(uvm_phase phase,uint64_type iter); //Will do save,read,compare 
  extern         task check_reset_n_done(); // Check that reset cycle is finished
  extern         task check_ott_busy(); // Check that there is no more OTT ongoing
  extern         task check_no_tx_smi_activity(); // Check that there is no TX SMI activities
  extern         task check_no_rx_smi_activity(); // Check that there is no RX SMI activities

  event e_ott_empty;
  // Interfaces
  virtual <%=obj.BlockId%>_connectivity_if connectivity_if;
    //Address Manager handle
  addr_trans_mgr m_addr_mgr;

  <%if(obj.testBench == 'io_aiu') { 
    for(let i=0; i<aiu.nNativeInterfacePorts; i++) {%>
    csr_connectivity_seq_<%=i%> connectivity_csr_seq_<%=i%> ;
    <%}
  } else {%>
  csr_connectivity_seq connectivity_csr_seq ;
  <%}%>

  AiuDce_connectivity_vec_type AiuDce_connectivity_vec;
  AiuDmi_connectivity_vec_type AiuDmi_connectivity_vec;
  AiuDii_connectivity_vec_type AiuDii_connectivity_vec;

endclass: connectivity_test


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

function void connectivity_test::build_phase(uvm_phase phase);

    super.build_phase(phase);
   
    // Bound Interface
    if (!uvm_config_db#(virtual <%=obj.BlockId%>_connectivity_if)::get(null, "", "<%=obj.BlockId%>_connectivity_if", connectivity_if)) begin
        `uvm_fatal("Connectivity interface error", "virtual interface must be set for connectivity_if");
    end

    m_addr_mgr.set_connectivity_test();
    connectivity_if.test_connectivity_test  = 1'b1;
    super.test_connectivity_test            = 1'b1;
    
    if($test$plusargs("dii_connectivity_check")) begin // ATOMIC Txns on DII not supported
      <%if(obj.testBench == 'io_aiu') { %>
    	<%for(var i = 0; i < obj.DutInfo.nNativeInterfacePorts; i++){%>
      m_axi_master_cfg[<%=i%>].wt_ace_atm_str  = 0;
      m_axi_master_cfg[<%=i%>].wt_ace_atm_ld   = 0;
      m_axi_master_cfg[<%=i%>].wt_ace_atm_swap = 0;
      m_axi_master_cfg[<%=i%>].wt_ace_atm_comp = 0;
      <%}%>
      <%} else {%>
      m_args.k_atomic_st_pct.set_value(0);
      m_args.k_atomic_ld_pct.set_value(0);
      m_args.k_atomic_sw_pct.set_value(0);
      m_args.k_atomic_cm_pct.set_value(0);
      <%}%>
    end

endfunction : build_phase


task connectivity_test::run_phase (uvm_phase phase); 

  fork
    begin
      super.run_phase(phase);
    end
    begin
      if ($test$plusargs("dce_connectivity_check") || $test$plusargs("dmi_connectivity_check") || $test$plusargs("dii_connectivity_check")) begin
        check_no_tx_smi_activity();
      end
    end
  join_any
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
task connectivity_test::main_seq_pre_hook(uvm_phase phase);
  `uvm_info(get_name(), "HOOK main_seq_pre_hook", UVM_NONE)
  

  if (! $value$plusargs("main_seq_iter=%0d", main_seq_iter)) begin
    main_seq_iter = 2**(<%=obj.nDCEs%>+<%=obj.nDMIs%>+<%=obj.nDIIs%>) + 2; // 2**(obj.nDCEs + obj.nDMIs + obj.nDIIs) //+2 to have 2 lasts loop with all vec at 0 then all vec at all 1
    if (!$test$plusargs("cfg_seq_iter")) begin
      if($test$plusargs("atomic_txn_test") || $test$plusargs("dataless_txn_test") ) begin
        cfg_seq_iter = main_seq_iter-(2**(<%=obj.nDIIs%>))-1; //-2**(obj.nDIIs)loop cycle with no error expected  & -1 as very last loop did not have error expected
      end else begin 
        cfg_seq_iter = main_seq_iter-(2**(<%=obj.nDCEs%>))-1; //-2**(obj.nDCEs)loop cycle with no error expected  & -1 as very last loop did not have error expected
      end
    end
  end else if (!$test$plusargs("cfg_seq_iter") )begin
    cfg_seq_iter = main_seq_iter; 
  end

  <%if (obj.AiuInfo[obj.Id].fnNativeInterface.includes('CHI')) {%>
  if ($test$plusargs("all_loop_possible")) begin
    main_seq_iter = 1; 
    cfg_seq_iter  = 1; 
  end
  <%}%>
  `uvm_info(get_name(),$sformatf("Value main_seq_iter = %0d", main_seq_iter), UVM_NONE)
  `uvm_info(get_name(),$sformatf("Value cfg_seq_iter = %0d", cfg_seq_iter), UVM_NONE)

  `uvm_info(get_name(), "end of HOOK main_seq_pre_hook", UVM_NONE)
endtask:main_seq_pre_hook

task connectivity_test::csr_seq_pre_hook(uvm_phase phase);
  `uvm_info(get_name(), "HOOK csr_seq_pre_hook", UVM_NONE)

  if ($test$plusargs("cfg_seq_iter")) begin
    $value$plusargs("cfg_seq_iter=%0d", cfg_seq_iter);
  end
  `uvm_info(get_name(),$sformatf("Value cfg_seq_iter = %0d", cfg_seq_iter), UVM_NONE)

  `uvm_info(get_name(), "end of HOOK csr_seq_pre_hook", UVM_NONE)
endtask:csr_seq_pre_hook

////////////////////////////////////////////////////////////
//////////////////// PRE HOOK in ITERATION loop ////////////
task connectivity_test::main_seq_iter_pre_hook(uvm_phase phase, uint64_type iter);
  `uvm_info(get_name(), $sformatf("HOOK main_seq_iter_pre_hook 0x%0h('d%0d)",iter,iter), UVM_NONE)
  connectivity_if.main_seq_iter = iter;
  `uvm_info(get_name(), "end of HOOK main_seq_iter_pre_hook", UVM_NONE)
endtask:main_seq_iter_pre_hook

task connectivity_test::csr_seq_iter_pre_hook(uvm_phase phase, uint64_type iter);
  `uvm_info(get_name(), $sformatf("HOOK csr_seq_iter_pre_hook 0x%0h('d%0d)",iter,iter), UVM_NONE)
  connectivity_if.csr_seq_iter = iter;

  <%if (obj.testBench == "chi_aiu") {%>
  m_env.m_scb.csr_addr_decode_err_addr_q.delete();
  m_env.m_scb.csr_addr_decode_err_cmd_type_q.delete();
  m_env.m_scb.csr_addr_decode_err_type_q.delete();
  m_env.m_scb.csr_addr_decode_err_msg_id_q.delete();
  <%} else {
    for(let i=0; i<aiu.nNativeInterfacePorts; i++) {%>
  mp_env.m_env[<%=i%>].m_scb.csr_addr_decode_err_addr_q.delete();
  mp_env.m_env[<%=i%>].m_scb.csr_addr_decode_err_cmd_type_q.delete();
  mp_env.m_env[<%=i%>].m_scb.csr_addr_decode_err_type_q.delete();
  mp_env.m_env[<%=i%>].m_scb.csr_addr_decode_err_msg_id_q.delete();
    <%};
  }%>

  //<%=scbPrefixPath()%>.csr_addr_decode_err_addr_q.delete();
  //<%=scbPrefixPath()%>.csr_addr_decode_err_cmd_type_q.delete();
  //<%=scbPrefixPath()%>.csr_addr_decode_err_type_q.delete();
  //<%=scbPrefixPath()%>.csr_addr_decode_err_msg_id_q.delete();
  
  `uvm_info(get_name(), "end of HOOK csr_seq_iter_pre_hook", UVM_NONE)
endtask:csr_seq_iter_pre_hook

////////////////////////////////////////////////////////////
//////////////////// POST HOOK in ITERATION loop ///////////
task connectivity_test::main_seq_iter_post_hook(uvm_phase phase, uint64_type iter);
  `uvm_info(get_name(), "HOOK main_seq_iter_post_hook", UVM_NONE)

  connectivity_processing(phase,iter);
  //Add delay of 20 clk cycles to synchronize csr seq write of ErrDetEn/ErrIntEn regs before starting main_seq
  //#20*(<%=obj.Clocks[0].params.period%>)ps; //obj.Clocks[0].params.period
  #50ns; //obj.Clocks[0].params.period

  `uvm_info(get_name(), "end of HOOK main_seq_iter_post_hook", UVM_NONE)
endtask:main_seq_iter_post_hook

task connectivity_test::csr_seq_iter_post_hook(uvm_phase phase, uint64_type iter);
  `uvm_info(get_name(), "HOOK csr_seq_iter_post_hook", UVM_NONE)

  //check_ott_busy();
  @(e_ott_empty);

  `uvm_info(get_name(), "end of HOOK csr_seq_iter_post_hook", UVM_NONE)
endtask:csr_seq_iter_post_hook

////////////////////////////////////////////////////////////
////////////   HOOK END RUN PHASE       ///////////////
task connectivity_test::main_seq_hook_end_run_phase(uvm_phase phase);
  phase.raise_objection(this, "main_seq_hook_end_run_phase");
  `uvm_info(get_name(), "HOOK main_seq_hook_end_run_phase", UVM_NONE)

  //connectivity_processing(phase,main_seq_iter);
  
  `uvm_info(get_name(), "end of HOOK main_seq_hook_end_run_phase", UVM_NONE)
   phase.drop_objection(this, "main_seq_hook_end_run_phase");
endtask:main_seq_hook_end_run_phase

////////////////////////////////////////////////////////////
//////////////////// POST HOOK              ///////////////
task connectivity_test::main_seq_post_hook(uvm_phase phase);
  `uvm_info(get_name(), "HOOK main_seq_post_hook", UVM_NONE)
  <%if (obj.testBench == "chi_aiu") {%>
  ev_main_seq_done.trigger();
  <%}%> 

  `uvm_info(get_name(), "end of HOOK main_seq_post_hook", UVM_NONE)
endtask:main_seq_post_hook

task connectivity_test::csr_seq_post_hook(uvm_phase phase);
  `uvm_info(get_name(), "HOOK csr_seq_post_hook", UVM_NONE)
  
  `uvm_info(get_name(), "end of HOOK csr_seq_post_hook", UVM_NONE)
endtask:csr_seq_post_hook



task connectivity_test::check_reset_n_done(); 
    wait(connectivity_if.rst_n == 1'b0);
    wait(connectivity_if.rst_n == 1'b1);
endtask : check_reset_n_done


task connectivity_test::check_ott_busy(); 
  int timeout_cnt_clk;

  do begin
    timeout_cnt_clk = 400 ;
  
    wait(connectivity_if.ott_busy == 1'b0);
    while(connectivity_if.ott_busy == 1'b0 && timeout_cnt_clk > 0) begin
      timeout_cnt_clk--;
      #<%=obj.Clocks[0].params.period%>ps; //obj.Clocks[0].params.period
    end
  end while (timeout_cnt_clk != 0);
  
  ->e_ott_empty;

endtask : check_ott_busy

task connectivity_test::check_no_tx_smi_activity(); 
  //#Check.CHIAIU.v3.4.Connectivity.SMIActivity
  //#Check.IOAIU.v3.4.Connectivity.NoSMIActivity
  <%function generateSMITXpath(i, SMI_field) {
    if(obj.testBench == 'io_aiu') {
      return 'm_smi' + i + '_rx_port_config.m_vif.' + SMI_field;
    } else {
      return 'm_env_cfg.m_smi' + i + '_rx_vif.' + SMI_field;
    }
  }%>
  forever begin
    @(posedge connectivity_if.clk)
    <% for (var i = 0; i < obj.DutInfo.nSmiTx; i++) { %> 
    if(<%=generateSMITXpath(i,"smi_msg_ready")%> && <%=generateSMITXpath(i,"smi_msg_valid")%> &&
        <%=generateSMITXpath(i,"smi_msg_type")%> != SYS_REQ) begin        
      `uvm_error(get_name(),$sformatf("Signal activities detected on SMI<%=i%>_Tx when not supposed to be any as test for unit disconnected smi_msg_type=%0h", <%=generateSMITXpath(i,"smi_msg_type")%>))
    end 
    <% } %>
  end
  
endtask : check_no_tx_smi_activity

task connectivity_test::check_no_rx_smi_activity(); 
  <%function generateSMIRXpath(i, SMI_field) {
    if(obj.testBench == 'io_aiu') {
      return 'm_smi' + i + '_tx_port_config.m_vif.' + SMI_field;
    } else {
      return 'm_env_cfg.m_smi' + i + '_tx_vif.' + SMI_field;
    }
  }
  
  function generate_var_SMI(i) {
      return 'smi' + i + '_tx';
  }%>
  <% for (var i = 0; i < obj.DutInfo.nSmiRx; i++) { %> 
  bit <%=generate_var_SMI(i)%>;<% } %>

  wait(<% for (var i = 0; i < obj.DutInfo.nSmiRx-1; i++) { %> 
      <%=generateSMIRXpath(i,"smi_dp_present")%> == 0 && <% } %>
      <%=generateSMIRXpath(obj.DutInfo.nSmiRx-1,"smi_dp_present")%> == 0 
  );

endtask : check_no_rx_smi_activity

////////////////////////////////////////////////////////////
///////////// PROCESS COUNTER              ///////////////
task connectivity_test::connectivity_processing(uvm_phase phase, uint64_type iter);

  check_ott_busy();
  //#Stimulus.CHIAIU.v3.4.Connectivity.RandUnconnectedDceDmiDii
  //#Stimulus.CHIAIU.v3.4.Connectivity.UnconnectedDce
  //#Stimulus.CHIAIU.v3.4.Connectivity.UnconnectedDii
  //#Stimulus.CHIAIU.v3.4.Connectivity.UnconnectedDmi
  //#Stimulus.CHIAIU.v3.4.Connectivity.SysCoPinUnconnectedDce
  //#Stimulus.CHIAIU.v3.4.Connectivity.SysCoRegisterUnconnectedDce
  //#Stimulus.IOAIU.v3.4.Connectivity.RandUnconnectedDceDmiDii
  //#Stimulus.IOAIU.v3.4.Connectivity.UnconnectedDce
  //#Stimulus.IOAIU.v3.4.Connectivity.UnconnectedDmi
  //#Stimulus.IOAIU.v3.4.Connectivity.UnconnectedDii
  //#Stimulus.IOAIU.v3.4.Connectivity.SysCoPinUnconnectedDce
  //#Stimulus.IOAIU.v3.4.Connectivity.SysCoRegisterUnconnectedDce
  //#Stimulus.IOAIU.Connectivity.RandUnconnectedDceDmiDii
  //#Stimulus.IOAIU.Connectivity.UnconnectedDce
  //#Stimulus.IOAIU.Connectivity.UnconnectedDmi
  @(posedge connectivity_if.clk)
 if ($test$plusargs("all_loop_possible")) begin
    <%if(obj.testBench == 'io_aiu') {%>
    //By default, we go through all possible combinaison
    if((connectivity_if.AiuDii_connectivity_vec >= 2**(<%=obj.nDIIs%>) -1) &&     //  >= 2**(obj.nDIIs -1) 
      (connectivity_if.AiuDmi_connectivity_vec >= 2**(<%=obj.nDMIs%>) -1)) begin //  >= 2**(obj.nDMIs -1) 
        connectivity_if.AiuDce_connectivity_vec ++;
    end  


    if(connectivity_if.AiuDmi_connectivity_vec >= (2**<%=obj.nDMIs%> -1)) begin //  >= 2**obj.nDMIs-1
      connectivity_if.AiuDii_connectivity_vec ++;
    end

    connectivity_if.AiuDmi_connectivity_vec ++;

    if(connectivity_if.main_seq_iter >= main_seq_iter-2 ) begin // Last loop iteration 
      connectivity_if.AiuDce_connectivity_vec = {<%=obj.nDCEs%>{1'b1}};
      connectivity_if.AiuDmi_connectivity_vec = {<%=obj.nDMIs%>{1'b1}};
      connectivity_if.AiuDii_connectivity_vec = {<%=obj.nDIIs%>{1'b1}};
    end
    <%} else {%>

      connectivity_if.AiuDce_connectivity_vec = $urandom_range(2**(<%=obj.nDCEs%>)-1);
      connectivity_if.AiuDmi_connectivity_vec = $urandom_range(2**(<%=obj.nDMIs%>)-1);
      connectivity_if.AiuDii_connectivity_vec = $urandom_range(2**(<%=obj.nDIIs%>)-1);

      `uvm_info(get_name(),$sformatf("Value AiuDce_connectivity_vec = %0d", connectivity_if.AiuDce_connectivity_vec), UVM_NONE)
      `uvm_info(get_name(),$sformatf("Value AiuDmi_connectivity_vec = %0d", connectivity_if.AiuDmi_connectivity_vec), UVM_NONE)
      `uvm_info(get_name(),$sformatf("Value AiuDii_connectivity_vec = %0d", connectivity_if.AiuDii_connectivity_vec), UVM_NONE)

    <%} %>

  end else begin

    // Default forced values Only DCE connected
    if (! $value$plusargs("hexAiuDceItr=0x%0h", AiuDce_connectivity_vec)) AiuDce_connectivity_vec = AiuDce_connectivity_vec_default;
    if (! $value$plusargs("hexAiuDmiItr=0x%0h", AiuDmi_connectivity_vec)) AiuDmi_connectivity_vec = AiuDmi_connectivity_vec_default;
    if (! $value$plusargs("hexAiuDiiItr=0x%0h", AiuDii_connectivity_vec)) AiuDii_connectivity_vec = AiuDii_connectivity_vec_default;

    connectivity_if.AiuDce_connectivity_vec = AiuDce_connectivity_vec;
    connectivity_if.AiuDmi_connectivity_vec = AiuDmi_connectivity_vec;
    connectivity_if.AiuDii_connectivity_vec = AiuDii_connectivity_vec;
  end

  <% if(obj.testbench == "chi_aiu") { %>
  cov.collect_connectivity_all_comb(connectivity_if.AiuDce_connectivity_vec,connectivity_if.AiuDmi_connectivity_vec,connectivity_if.AiuDii_connectivity_vec);
  <% } %>
  
  //check_no_rx_smi_activity();
  //connectivity_if.force_rst_n = 1;
  //check_reset_n_done();


endtask:connectivity_processing

task connectivity_test::post_shutdown_phase(uvm_phase phase);
  //main_seq_hook_end_run_phase(phase);
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

