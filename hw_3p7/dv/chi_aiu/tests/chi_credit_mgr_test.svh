
<%
var scbPrefixPath = function() {
  if (obj.testBench == "chi_aiu") {
      return "m_env.m_scb";} 
  else {
      return "env.m_scb";}
  };
%>

class chi_credit_sw_mgr_test extends <%=`${(() => {
                                              if ((obj.AiuInfo[obj.Id].fnNativeInterface == 'CHI-A')||(obj.AiuInfo[obj.Id].fnNativeInterface == 'CHI-B') || (obj.AiuInfo[obj.Id].fnNativeInterface == 'CHI-E') && (obj.BlockId.includes("caiu"))) {
                                                return "chi_aiu_bringup_test";}
                                            })()}`%>;
  `uvm_component_utils(chi_credit_sw_mgr_test)

   virtual chi_aiu_dut_probe_if u_dut_probe_vif;
   virtual <%=obj.BlockId%>_connectivity_if connectivity_if;
   uvm_event_pool ev_pool = uvm_event_pool::get_global_pool();
   uvm_event ev = ev_pool.get("ev");
   uvm_event ev_update_crd = ev_pool.get("ev_update_crd");
   int update_crd_detected;



  function new(string name = "chi_credit_sw_mgr_test", uvm_component parent=null);
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
  extern task credit_sw_mgr_processing(uvm_phase phase, uint64_type iter);
  extern         task check_ott_busy(); // Check that there is no more OTT ongoing

endclass: chi_credit_sw_mgr_test

function void chi_credit_sw_mgr_test::build_phase(uvm_phase phase);

    super.build_phase(phase);
    cfg_seq_iter = 10;
    main_seq_iter = 10;

    if(!uvm_config_db#(virtual chi_aiu_dut_probe_if )::get(null, get_full_name(), "u_dut_probe_if",u_dut_probe_vif)) begin
        `uvm_error("NOVIF",{"virtual interface must be set  for :",get_full_name(),".vif"})
    end

    if (!uvm_config_db#(virtual <%=obj.BlockId%>_connectivity_if)::get(null, "", "<%=obj.BlockId%>_connectivity_if", connectivity_if)) begin
        `uvm_fatal("Connectivity interface error", "virtual interface must be set for connectivity_if");
    end

endfunction : build_phase


task chi_credit_sw_mgr_test::run_phase (uvm_phase phase); 
      super.run_phase(phase);
endtask:run_phase

task chi_credit_sw_mgr_test::main_seq_pre_hook(uvm_phase phase);
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

  `uvm_info(get_name(),$sformatf("Value main_seq_iter = %0d", main_seq_iter), UVM_NONE)
  `uvm_info(get_name(),$sformatf("Value cfg_seq_iter = %0d", cfg_seq_iter), UVM_NONE)

  `uvm_info(get_name(), "end of HOOK main_seq_pre_hook", UVM_NONE)

endtask:main_seq_pre_hook

task chi_credit_sw_mgr_test::csr_seq_pre_hook(uvm_phase phase);
  `uvm_info(get_name(), "HOOK csr_seq_pre_hook", UVM_NONE)

  if ($test$plusargs("cfg_seq_iter")) begin
    $value$plusargs("cfg_seq_iter=%0d", cfg_seq_iter);
  end
  `uvm_info(get_name(),$sformatf("Value cfg_seq_iter = %0d", cfg_seq_iter), UVM_NONE)

  `uvm_info(get_name(), "end of HOOK csr_seq_pre_hook", UVM_NONE)

endtask:csr_seq_pre_hook

////////////////////////////////////////////////////////////
//////////////////// PRE HOOK in ITERATION loop ////////////
task chi_credit_sw_mgr_test::main_seq_iter_pre_hook(uvm_phase phase, uint64_type iter);
  `uvm_info(get_name(), $sformatf("HOOK main_seq_iter_pre_hook 0x%0h('d%0d)",iter,iter), UVM_NONE)
//  m_master_pipelined_seq.k_num_read_req                 = 10 * iter+!;
 // m_master_pipelined_seq.k_num_write_req                =  10 * iter+!;


  `uvm_info(get_name(), "end of HOOK main_seq_iter_pre_hook", UVM_NONE)

endtask:main_seq_iter_pre_hook

task chi_credit_sw_mgr_test::csr_seq_iter_pre_hook(uvm_phase phase, uint64_type iter);

    int pick_rand_range;
    int sel_tgt;
    int dce_credit[];
    int dmi_credit[];
    int dii_credit[];
    int init_credit_val;

    dce_credit = new[<%=obj.nDCEs%>];
    dmi_credit = new[<%=obj.nDMIs%>];
    dii_credit = new[<%=obj.nDIIs%>];

    if (!$value$plusargs("k_chi_init_credit_val=%d",init_credit_val)) begin
        init_credit_val = -1;
    end

    if ((iter == 'h0) && ($test$plusargs("zero_nonzero_crd_test"))) begin // #Stimulus.CHIAIU.v3.4.SCM.MixedCredit 

        <%if(obj.AiuInfo[obj.Id].nDiis >1){%>
            sel_tgt = $urandom_range(1,3); 
        <%}else{%>
            sel_tgt = $urandom_range(1,2); 
        <%}%>

        for (int j=0; j<<%=obj.nDCEs%>; j++) begin
          dce_credit[j] = (sel_tgt == 1) ? 0 : $urandom_range(1,31);
        end

        for (int j=0; j<<%=obj.nDMIs%>; j++) begin
          dmi_credit[j] = (sel_tgt == 2) ? 0 : $urandom_range(1,31);
        end

        for (int j=0; j<<%=obj.nDIIs%>; j++) begin
          dii_credit[j] = (sel_tgt == 3) ? 0 : $urandom_range(1,31);
        end
    end else if (iter == 'h0) begin
        for (int j=0; j<<%=obj.nDCEs%>; j++) begin
          dce_credit[j] = (init_credit_val < 0) ? $urandom_range(1,5) : init_credit_val;
        end

        for (int j=0; j<<%=obj.nDMIs%>; j++) begin
          dmi_credit[j] = (init_credit_val < 0) ? $urandom_range(1,5) : init_credit_val;
        end

        for (int j=0; j<<%=obj.nDIIs%>; j++) begin
          dii_credit[j] = (init_credit_val < 0) ? $urandom_range(1,5) : init_credit_val;
        end
    end
    
    if (update_crd_detected == 1) begin
      if($test$plusargs("dce_state_fcov")|| $test$plusargs("dmi_state_fcov") )begin
        pick_rand_range = 1;
        end
      else  begin
       pick_rand_range = (!$test$plusargs("scm_bckpressure_test")) ? $urandom_range(1,3) : 0;
      end
       `uvm_info(get_full_name(),$sformatf("SCM_TEST: random_range is : %0d",pick_rand_range),UVM_HIGH)

        if (pick_rand_range == 1) begin
          for (int j=0; j<<%=obj.nDCEs%>; j++) begin
            if($test$plusargs("dce_state_fcov"))begin
               dce_credit[j] = 2; 
            end else if ($test$plusargs("dmi_state_fcov")) begin
               dce_credit[j] = 29; //$urandom_range(1,10);
            end else begin
               dce_credit[j] = $urandom_range(1,10);
            end
          end

          for (int j=0; j<<%=obj.nDMIs%>; j++) begin
               if ($test$plusargs("dmi_state_fcov")) begin
                    dmi_credit[j] = 2; //$urandom_range(1,10);
               end else begin
                    dmi_credit[j] = $urandom_range(1,10);
               end
          end

          for (int j=0; j<<%=obj.nDIIs%>; j++) begin
            dii_credit[j] = $urandom_range(1,10);
          end
        end else if (pick_rand_range == 2) begin // #Stimulus.CHIAIU.v3.4.SCM.RandomCredit
          for (int j=0; j<<%=obj.nDCEs%>; j++) begin
            dce_credit[j] = $urandom_range(11,20);
          end

          for (int j=0; j<<%=obj.nDMIs%>; j++) begin
            dmi_credit[j] = $urandom_range(11,20);
          end

          for (int j=0; j<<%=obj.nDIIs%>; j++) begin
            dii_credit[j] = $urandom_range(11,20);
          end
        end else if (pick_rand_range == 3) begin
          for (int j=0; j<<%=obj.nDCEs%>; j++) begin
            dce_credit[j] = $urandom_range(21,31);
          end

          for (int j=0; j<<%=obj.nDMIs%>; j++) begin
            dmi_credit[j] = $urandom_range(21,31);
          end

          for (int j=0; j<<%=obj.nDIIs%>; j++) begin
            dii_credit[j] = $urandom_range(21,31);
          end
        end else begin
          for (int j=0; j<<%=obj.nDCEs%>; j++) begin
            dce_credit[j] = 1;
          end

          for (int j=0; j<<%=obj.nDMIs%>; j++) begin
            dmi_credit[j] = 1;
          end

          for (int j=0; j<<%=obj.nDIIs%>; j++) begin
            dii_credit[j] = 1;
          end
        end
        
        update_crd_detected = 'h0;
    end
    
      `uvm_info(get_full_name(),$sformatf("CRD_SCM_CHECK : dce_crd_limit : %0p dmi_crd_limit : %0p dii_crd_limit : %0p",dce_credit,dmi_credit,dii_credit),UVM_HIGH)
    <%for (var j=0; j< obj.nDCEs; j++){%> 
       uvm_config_db#(int)::set(null,"*","check_dce_credit_limit_<%=j%>",dce_credit[<%=j%>]);
     <%}%>

    <%for (var j=0; j< obj.nDMIs; j++){%> 
       uvm_config_db#(int)::set(null,"*","check_dmi_credit_limit_<%=j%>",dmi_credit[<%=j%>]);
     <%}%>


    <%for (var j=0; j< obj.nDIIs; j++){%> 
       uvm_config_db#(int)::set(null,"*","check_dii_credit_limit_<%=j%>",dii_credit[<%=j%>]);
     <%}%>

endtask:csr_seq_iter_pre_hook

//////////////////////////////////////// ////////////////////
//////////////////// POST HOOK in ITERATION loop ///////////
task chi_credit_sw_mgr_test::main_seq_iter_post_hook(uvm_phase phase, uint64_type iter);
  `uvm_info(get_name(), "HOOK main_seq_iter_post_hook", UVM_NONE)

   credit_sw_mgr_processing(phase,iter);

  `uvm_info(get_name(), "end of HOOK main_seq_iter_post_hook", UVM_NONE)

endtask:main_seq_iter_post_hook


task chi_credit_sw_mgr_test::csr_seq_iter_post_hook(uvm_phase phase, uint64_type iter);
  `uvm_info(get_name(), "HOOK csr_seq_iter_post_hook", UVM_NONE)
  `uvm_info(get_name(), "Start waiting for ott/stt to be idel", UVM_DEBUG)
  //wait((u_dut_probe_vif.ott_entry_validvec === 'h0) && (u_dut_probe_vif.stt_entry_validvec === 'h0)); //CONC-8769
  //repeat(5000)  @(posedge u_dut_probe_vif.clk);
   ev_update_crd.wait_ptrigger();
   update_crd_detected = 'h1;
  `uvm_info(get_name(), "Done waiting for ott/stt to be idel", UVM_DEBUG)
  `uvm_info(get_name(), "end of HOOK csr_seq_iter_post_hook", UVM_NONE)
endtask:csr_seq_iter_post_hook

task chi_credit_sw_mgr_test::check_ott_busy(); 
  int timeout_cnt_clk;

  do begin
    <% if  (obj.testBench == "chi_aiu") { %>
    timeout_cnt_clk = 50 ;
    <%} else {%>
    timeout_cnt_clk = 400 ;
    <%}%>  
  
    wait(connectivity_if.ott_busy == 1'b0);
    while(connectivity_if.ott_busy == 1'b0 && timeout_cnt_clk > 0) begin
      timeout_cnt_clk--;
      #<%=obj.Clocks[0].params.period%>ps; //obj.Clocks[0].params.period
    end
  end while (timeout_cnt_clk != 0);
  

endtask : check_ott_busy
////////////////////////////////////////////////////////////
////////////   HOOK END RUN PHASE       ///////////////
task chi_credit_sw_mgr_test::main_seq_hook_end_run_phase(uvm_phase phase);
  phase.raise_objection(this, "main_seq_hook_end_run_phase");
  `uvm_info(get_name(), "HOOK main_seq_hook_end_run_phase", UVM_NONE)
  
  `uvm_info(get_name(), "end of HOOK main_seq_hook_end_run_phase", UVM_NONE)
   phase.drop_objection(this, "main_seq_hook_end_run_phase");
endtask:main_seq_hook_end_run_phase

////////////////////////////////////////////////////////////
//////////////////// POST HOOK              ///////////////
task chi_credit_sw_mgr_test::main_seq_post_hook(uvm_phase phase);
  `uvm_info(get_name(), "HOOK main_seq_post_hook", UVM_NONE)
  <%if (obj.testBench == "chi_aiu") {%> //CHI-AIU
  ev_main_seq_done.trigger();
  <%}%> 
  
  `uvm_info(get_name(), "end of HOOK main_seq_post_hook", UVM_NONE)
endtask:main_seq_post_hook

task chi_credit_sw_mgr_test::csr_seq_post_hook(uvm_phase phase);
  `uvm_info(get_name(), "HOOK csr_seq_post_hook", UVM_NONE)
  
  `uvm_info(get_name(), "end of HOOK csr_seq_post_hook", UVM_NONE)
endtask:csr_seq_post_hook

////////////////////////////////////////////////////////////
///////////// PROCESS COUNTER              ///////////////
task chi_credit_sw_mgr_test::credit_sw_mgr_processing(uvm_phase phase, uint64_type iter);

  check_ott_busy();
endtask:credit_sw_mgr_processing

task chi_credit_sw_mgr_test::post_shutdown_phase(uvm_phase phase);

endtask:post_shutdown_phase

