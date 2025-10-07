<%
//Embedded javascript code to figure number of blocks
   const _blkid = [];
   const _blkidpkg = [];
   const _blktype = [];
   const _blkclkperiod = [];
   const _blkports_suffix =[];
   const _blk   = [{}];
   let pidx = 0;
   let ridx = 0;
   let _idx = 0;
   let chiaiu_idx = 0;
   let ioaiu_idx = 0;
   let ioaiu_mpu_idx = 0;
   let nbr_clk= obj.Clocks.length;
   let ref_clk_period=0; //the first AiuInfo will be the reference to compare all the clokc to check if there are synchro
   let nAIUs_mpu =0; 
   
   for(pidx = 0; pidx < obj.nAIUs; pidx++) {
       if((obj.AiuInfo[pidx].fnNativeInterface == 'CHI-A')||(obj.AiuInfo[pidx].fnNativeInterface == 'CHI-B' || obj.AiuInfo[pidx].fnNativeInterface == 'CHI-E')) {
       _blkclkperiod[_idx] = obj.Clocks.filter(e => e.name == obj.AiuInfo[pidx].unitClk[0]).map(e => parseInt(e.params.period)) //unitClk[0] = fct clk unitClk[1]= duplicate clk (resilience)
       _blk[_idx]   = obj.AiuInfo[pidx];
       _blkid[_idx] = 'chiaiu' + chiaiu_idx +"_0";
       _blkidpkg[_idx] = 'chiaiu' + chiaiu_idx;
       _blktype[_idx]   = 'chiaiu';
       chiaiu_idx++;
       nAIUs_mpu++;
       _idx++;
       } else {
       for (let port_idx = 0; port_idx < obj.AiuInfo[pidx].nNativeInterfacePorts; port_idx++) {
        _blkclkperiod[_idx] = obj.Clocks.filter(e => e.name == obj.AiuInfo[pidx].unitClk[0]).map(e => parseInt(e.params.period)) //unitClk[0] = fct clk unitClk[1]= duplicate clk (resilience)
        _blk[_idx]   = obj.AiuInfo[pidx];
        _blkidpkg[_idx] = 'ioaiu' + ioaiu_idx;
        _blkid[_idx] = 'ioaiu' + ioaiu_idx +"_"+port_idx;
        _blkports_suffix[_idx] = "_" + port_idx;
        _blktype[_idx]   = 'ioaiu';
         _idx++;
        nAIUs_mpu++;
        }
         ioaiu_idx++;
       }
   }
   ref_clk_period=_blkclkperiod[0]; // first is the ref

   for(pidx = 0; pidx < obj.nDCEs; pidx++) {
       ridx = pidx + nAIUs_mpu;
       _blkclkperiod[ridx] = obj.Clocks.filter(e => e.name == obj.DceInfo[pidx].unitClk[0]).map(e => parseInt(e.params.period))
       _blkid[ridx] = 'dce' + pidx;
       _blkidpkg[ridx] = 'dce' + pidx;
       _blktype[ridx]   = 'dce';
       _blk[ridx]   = obj.DceInfo[pidx];
   }
 for(pidx =  0; pidx < obj.nDMIs; pidx++) {
       ridx = pidx + nAIUs_mpu + obj.nDCEs;
       _blkclkperiod[ridx] = obj.Clocks.filter(e => e.name == obj.DmiInfo[pidx].unitClk[0]).map(e => parseInt(e.params.period))
       _blkid[ridx] = 'dmi' + pidx;
       _blkidpkg[ridx] = 'dmi' + pidx;
       _blktype[ridx]   = 'dmi';
       _blk[ridx]   = obj.DmiInfo[pidx];
   }
   for(pidx = 0; pidx < obj.nDIIs; pidx++) {
       ridx = pidx + nAIUs_mpu + obj.nDCEs + obj.nDMIs;
       _blkclkperiod[ridx] = obj.Clocks.filter(e => e.name == obj.DiiInfo[pidx].unitClk[0]).map(e => parseInt(e.params.period))
       _blkid[ridx] = 'dii' + pidx;
       _blkidpkg[ridx] = 'dii' + pidx;
       _blk[ridx]   = 'dii';
       _blk[ridx]   = obj.DiiInfo[pidx];
   }
   for(pidx = 0; pidx < obj.nDVEs; pidx++) {
       ridx = pidx + nAIUs_mpu + obj.nDCEs + obj.nDMIs + obj.nDIIs;
       _blkclkperiod[ridx] = obj.Clocks.filter(e => e.name == obj.DveInfo[pidx].unitClk[0]).map(e => parseInt(e.params.period))
       _blkid[ridx] = 'dve' + pidx;
       _blkidpkg[ridx] = 'dve' + pidx;
       _blktype[ridx]   = 'dve';
       _blk[ridx]   = obj.DveInfo[pidx];
   }
   let nALLs = ridx+1; 
%>
// agent DEBUG
// nbr agents: <%=obj.nAIUs%>
// nbr agents with mpu: <%=nAIUs_mpu%>
// CLOCK DEBUG
// nbr clock=<%=nbr_clk%>
// ref_clk_period = <%=ref_clk_period%>
// Clock ratio
<%for(pidx = 0; pidx < nALLs; pidx++) {   %>
// _<%=_blkid[pidx]%> = <%=_blkclkperiod[pidx]%>
<% } %>
// END CLOCK DEBUG
class concerto_fullsys_test_atomicDecErr extends concerto_fullsys_test; 

  `uvm_component_utils(concerto_fullsys_test_atomicDecErr)

  longint atomicDecErr_interrupt_timeout_us=500;

  //!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!                                  
  // !!! some declarations in the parent with the macro `concerto_fullsys_test_atomicDecErr_all_declarations in files perf_cnt_unit_defines!!!!
  //!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!                                  
                                  
  function new(string name = "concerto_fullsys_test_atomicDecErr", uvm_component parent=null);
    super.new(name,parent);
    if(!$value$plusargs("atomicDecErr_interrupt_timeout_us=%d",atomicDecErr_interrupt_timeout_us)) atomicDecErr_interrupt_timeout_us=500;
  endfunction: new

  extern function void report_phase(uvm_phase phase);

  // HOOK task call in the parent class
  extern virtual task main_seq_iter_pre_hook(uvm_phase phase, int iter); // at the beginning of the iteration(inside the iteration loop)
  extern virtual task main_seq_iter_post_hook(uvm_phase phase, int iter);// at the end of the iteration (inside the iteration)
  extern virtual task main_seq_hook_end_run_phase(uvm_phase phase);
  // FUNCTION

endclass: concerto_fullsys_test_atomicDecErr


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
function void concerto_fullsys_test_atomicDecErr::report_phase(uvm_phase phase);
    `uvm_info("report_phase", "Entered...", UVM_LOW)
      if (test_cfg.dmi_atomicDecErr && !detect_dmi_atomicDecErr) begin
            $display("\n===================================================================");
            $display("UVM FAILED!");
            $display("===================================================================");
        `uvm_error(get_name(), "We don't detect Atomic txn not allow on a DMI without atomic engine: Interrupt disable? wrong cfg all dmi with atomic Engine? stimulus doesn't generate atomic txn?")
     end
      if (test_cfg.dmi_atomicDecErr && detect_dmi_atomicDecErr) begin
            $display("\n===================================================================");
            $display("UVM PASSED!");
            $display("===================================================================");
        end
endfunction : report_phase
////////////////////////////////////////////////////////////////////////////////////////
// #     #  #######  #######  #    #         #######     #      #####   #    #   #####   
// #     #  #     #  #     #  #   #             #       # #    #     #  #   #   #     #  
// #     #  #     #  #     #  #  #              #      #   #   #        #  #    #        
// #######  #     #  #     #  ###               #     #     #   #####   ###      #####   
// #     #  #     #  #     #  #  #              #     #######        #  #  #          #  
// #     #  #     #  #     #  #   #             #     #     #  #     #  #   #   #     #  
// #     #  #######  #######  #    #  #####     #     #     #   #####   #    #   ##### 
// #Stimulus.FSYS.perfmon.mastercountenable 
////////////////////////////////////////////////////////////////////////////////////////
//////////////////// PRE HOOK                   ////////////
task concerto_fullsys_test_atomicDecErr::main_seq_iter_pre_hook(uvm_phase phase, int iter);
  `uvm_info(get_name(), $sformatf("START HOOK main_seq_iter_pre_hook iter:%0d",iter), UVM_NONE)
  phase.raise_objection(this, "Start main_seq_iter_pre_hook");
  if (!test_cfg.dmi_atomicDecErr) begin
     `uvm_error(get_name(), " miss +dmi_atomicDecErr=1 please add in the runtestlist")
  end
  fork:_wait_irq
       <%for(pidx = 0; pidx < obj.nDMIs; pidx++) {%>
        begin:_dmi<%=pidx%>
        queue_of_block dmi_blks;
        uvm_reg_block dmi_blk;
        uvm_reg reg_;
        uvm_status_e status;
        int ErrVld;
        int ErrType;
        int ErrInfo;

          `uvm_info(get_full_name(),"Wait IRQ_C for <%=obj.DmiInfo[pidx].strRtlNamePrefix%>",UVM_NONE)
          wait(tb_top.m_irq_if_<%=obj.DmiInfo[pidx].strRtlNamePrefix%>.uc === 1);
          `uvm_info(get_full_name(),"Seen IRQ_C for <%=obj.DmiInfo[pidx].strRtlNamePrefix%>",UVM_NONE)
          // check status register
          dmi_blks = get_q_block_by_regexpname(m_concerto_env.m_regs,"<%=obj.DmiInfo[pidx].strRtlNamePrefix%>"); // get queue but we know only one block by DMI
          foreach (dmi_blks[dmi_blk]) begin:_foreach_<%=pidx%>
            reg_ = dmi_blk.get_reg_by_name("DMIUUESR");// uncorrectable error status
            reg_.get_field_by_name("ErrVld").read(status,ErrVld);
            if (!ErrVld) begin
                 `uvm_error(get_name(), "Interrupt but <%=obj.DmiInfo[pidx].strRtlNamePrefix%>.DMIUUSER.ErrVld isn't set so it's another interrupt?")
               end
            reg_.get_field_by_name("ErrType").read(status,ErrType);   
            if (ErrType !='hC) begin
                 `uvm_error(get_name(), $sformatf("<%=obj.DmiInfo[pidx].strRtlNamePrefix%>.DMIUUSER.ErrType=%0h should be 0xC=SoftProgError ",ErrType))
            end
            reg_.get_field_by_name("ErrInfo").read(status,ErrInfo);   
            if (ErrInfo != 0) begin
                 `uvm_error(get_name(), $sformatf("<%=obj.DmiInfo[pidx].strRtlNamePrefix%>.DMIUUSER.ErrType=%0h should be 0x0=Atomic Transaction w/o CCP",ErrInfo))
            end
            <%if (obj.DmiInfo[pidx].useAtomic) {%>
                 `uvm_error(get_name(), "<%=obj.DmiInfo[pidx].strRtlNamePrefix%> detect an atomic error but shouldn't be the case because this DMI have an atomic engine" )
            <% } else { // dmi without atomic engine%>
            `uvm_info(get_full_name(),"<%=obj.DmiInfo[pidx].strRtlNamePrefix%> detected a forbidden ATOMIC txn ",UVM_NONE)
            detect_dmi_atomicDecErr = 1;
            phase.jump(uvm_report_phase::get());
            <%}%>
          end:_foreach_<%=pidx%>
        end:_dmi<%=pidx%>
       <%}%>
      begin:_time_out
        #(atomicDecErr_interrupt_timeout_us*1us);
        if (test_cfg.dmi_atomicDecErr && !detect_dmi_atomicDecErr) begin
        `uvm_error(get_name(), "!!!TIMEOUT!!! We don't detect Atomic txn not allow on a DMI without atomic engine: Interrupt disable? wrong cfg all dmi with atomic Engine? stimulus doesn't generate atomic txn?")
        end
        phase.jump(uvm_report_phase::get());
      end:_time_out 
  join_none:_wait_irq
  phase.drop_objection(this, "Finish main_seq_iter_pre_hook");
  `uvm_info(get_name(), $sformatf("END HOOK main_seq_iter_pre_hook iter:%0d",iter), UVM_NONE)

endtask:main_seq_iter_pre_hook

////////////////////////////////////////////////////////////
//////////////////// POST HOOK ///////////
task concerto_fullsys_test_atomicDecErr::main_seq_iter_post_hook(uvm_phase phase, int iter);
  `uvm_info(get_name(), $sformatf("START HOOK main_seq_iter_post_hook iter:%0d",iter), UVM_NONE)
  `uvm_info(get_name(), $sformatf("END HOOK main_seq_iter_post_hook iter:%0d",iter), UVM_NONE)

endtask:main_seq_iter_post_hook

////////////////////////////////////////////////////////////
////////////   HOOK END RUN PHASE       ///////////////
task concerto_fullsys_test_atomicDecErr::main_seq_hook_end_run_phase(uvm_phase phase);
  phase.raise_objection(this, "main_seq_hook_end_run_phase");
  `uvm_info(get_name(), "HOOK main_seq_hook_end_run_phase", UVM_NONE)
   if (test_cfg.dmi_atomicDecErr && !detect_dmi_atomicDecErr) begin
        `uvm_error(get_name(), "We don't detect Atomic txn not allow on a DMI without atomic engine: Interrupt disable? wrong cfg all dmi with atomic Engine? stimulus doesn't generate atomic txn?")
  end
  `uvm_info(get_name(), "end of HOOK main_seq_hook_end_run_phase, perf_cnt_sb disabled!!", UVM_NONE)
   phase.drop_objection(this, "main_seq_hook_end_run_phase");

endtask:main_seq_hook_end_run_phase


////////////////////////////////////////////////////////////////////
//#######  #     #  #     #   #####   #######  ###  #######  #     #  
//#        #     #  ##    #  #     #     #      #   #     #  ##    #  
//#        #     #  # #   #  #           #      #   #     #  # #   #  
//#####    #     #  #  #  #  #           #      #   #     #  #  #  #  
//#        #     #  #   # #  #           #      #   #     #  #   # #  
//#        #     #  #    ##  #     #     #      #   #     #  #    ##  
//#         #####   #     #   #####      #     ###  #######  #     #  
////////////////////////////////////////////////////////////////////
//NOTHING
