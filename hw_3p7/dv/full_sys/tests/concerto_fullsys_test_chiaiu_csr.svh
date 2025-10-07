<%
//Embedded javascript code to figure number of blocks
   var _blkid = [];
   var _blkidpkg = [];
   var _blktype = [];
   var _blkports_suffix =[];
   var _blk_nCore = [];
   var _blk   = [{}];
   var pidx = 0;
   var ridx = 0;
   var _idx = 0;
   var chiaiu_idx = 0;
   var ioaiu_idx = 0;
   var ioaiu_mpu_idx = 0;
   obj.nAIUs_mpu =0; 

   for(pidx = 0; pidx < obj.nAIUs; pidx++) {
       if((obj.AiuInfo[pidx].fnNativeInterface == 'CHI-A')||(obj.AiuInfo[pidx].fnNativeInterface == 'CHI-B')) {
       _blk[_idx]   = obj.AiuInfo[pidx];
       _blkid[_idx] = 'chiaiu' + chiaiu_idx +"_0";
       _blkidpkg[_idx] = 'chiaiu' + chiaiu_idx;
       _blktype[_idx]   = 'chiaiu';
       _blk_nCore[pidx] = 1;
       chiaiu_idx++;
       obj.nAIUs_mpu++;
       _idx++;
       } else {
       for (var port_idx = 0; port_idx < obj.AiuInfo[pidx].nNativeInterfacePorts; port_idx++) {
        _blk[_idx]   = obj.AiuInfo[pidx];
        _blkidpkg[_idx] = 'ioaiu' + ioaiu_idx;
        _blkid[_idx] = 'ioaiu' + ioaiu_idx +"_"+port_idx;
        _blkports_suffix[_idx] = "_" + port_idx;
        _blktype[_idx]   = 'ioaiu';
        _blk_nCore[pidx] = obj.AiuInfo[pidx].nNativeInterfacePorts;
         _idx++;
        obj.nAIUs_mpu++;
        }
         ioaiu_idx++;
       }
   }

   for(pidx = 0; pidx < obj.nDCEs; pidx++) {
       ridx = pidx + obj.nAIUs_mpu;
       _blkid[ridx] = 'dce' + pidx;
       _blkidpkg[ridx] = 'dce' + pidx;
       _blktype[ridx]   = 'dce';
       _blk[ridx]   = obj.DceInfo[pidx];
   }
 for(pidx =  0; pidx < obj.nDMIs; pidx++) {
       ridx = pidx + obj.nAIUs_mpu + obj.nDCEs;
       _blkid[ridx] = 'dmi' + pidx;
       _blkidpkg[ridx] = 'dmi' + pidx;
       _blktype[ridx]   = 'dmi';
       _blk[ridx]   = obj.DmiInfo[pidx];
   }
   for(pidx = 0; pidx < obj.nDIIs; pidx++) {
       ridx = pidx + obj.nAIUs_mpu + obj.nDCEs + obj.nDMIs;
       _blkid[ridx] = 'dii' + pidx;
       _blkidpkg[ridx] = 'dii' + pidx;
       _blk[ridx]   = 'dii';
       _blk[ridx]   = obj.DiiInfo[pidx];
   }
   for(pidx = 0; pidx < obj.nDVEs; pidx++) {
       ridx = pidx + obj.nAIUs_mpu + obj.nDCEs + obj.nDMIs + obj.nDIIs;
       _blkid[ridx] = 'dve' + pidx;
       _blkidpkg[ridx] = 'dve' + pidx;
       _blktype[ridx]   = 'dve';
       _blk[ridx]   = obj.DveInfo[pidx];
   }
   var nALLs = ridx+1; 
%>
class concerto_fullsys_test_chiaiu_csr extends concerto_fullsys_test; 

  `uvm_component_utils(concerto_fullsys_test_chiaiu_csr)
     int chi_csr_nbr;
     bit skip_test=0;

`ifdef USE_VIP_SNPS_CHI //existing flow will not run when USE_VIP_SNPS set
  <% var chi_idx=0;%>
  <% for(var idx = 0;  idx < obj.nAIUs; idx++) {%> 
  <% if (obj.AiuInfo[idx].fnNativeInterface.match('CHI')) { %>
   chi_subsys_pkg::chi_subsys_vseq         m_snps_chi<%=chi_idx%>_vseq;
   <% chi_idx++;} }%>
`ifdef CHI_UNITS_CNT_NON_ZERO
   chi_aiu_unit_args_pkg::chi_aiu_unit_args m_chi0_args;
`endif
`endif

  // UVM PHASE
  extern function void start_of_simulation_phase (uvm_phase phase);
  extern task ncore_test_stimulus(uvm_phase phase);
                                  
  function new(string name = "concerto_fullsys_test_chiaiu_csr", uvm_component parent=null);
    super.new(name,parent);
     if (!$value$plusargs("chi_csr_nbr=%d",chi_csr_nbr)) begin 
         chi_csr_nbr=0;
     end else begin // if chi_csr_nbr doesn't exist use CHI0
         if (!(chi_csr_nbr inside { 0 <%for(let i=1; i< obj.nCHIs; i++){%> , <%=i%><%}%>})) begin 
             skip_test = 1;
         end
     end
   endfunction: new

endclass: concerto_fullsys_test_chiaiu_csr


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
function void concerto_fullsys_test_chiaiu_csr::start_of_simulation_phase(uvm_phase phase);
  uvm_factory factory = uvm_factory::get();

  `uvm_info("FULLSYS_TEST_CHIAU_CSR_TEST", "START_OF_SIMULATION", UVM_LOW)
  super.start_of_simulation_phase(phase);

    `ifndef CHI_SUBSYS
            `ifdef CHI_UNITS_CNT_NON_ZERO
           <% var cidx = 0; %>
           <% for(var idx = 0; idx < obj.nAIUs; idx++) {
            if(obj.AiuInfo[idx].fnNativeInterface.match('CHI')) { %>
            factory.set_inst_override_by_name("svt_chi_rn_transaction",test_cfg.chi_txn_seq_name,"uvm_test_top.m_concerto_env.snps.svt.amba_system_env.chi_system[0].rn[<%=cidx%>].*"); 
            <%cidx++;}}%> 
            `endif // CHI_UNITS_CNT_NON_ZERO
    `endif
endfunction:start_of_simulation_phase

task concerto_fullsys_test_chiaiu_csr::ncore_test_stimulus(uvm_phase phase); 
  #100ns;
  if (!test_cfg.k_csr_access_only)
      `uvm_error("CHIAIU CSR TEST", "you must use +k_csr_access_only=1")
 
   `uvm_info("CONCERTO_FULLSYS_TEST_CHIAIU_CSR", "START ncore_test_stimulus", UVM_LOW)
  // in case of k_csr_access_only run csr with each CHI to cover connection CHI to SYS_DII
  <%var chi_idx =0;%>
  <% for(var idx = 0;  idx < obj.nAIUs; idx++) {%> 
  <% if (obj.AiuInfo[idx].fnNativeInterface.match('CHI')) { %>
  <% if (obj.AiuInfo[idx].fnCsrAccess) { %>
  if ((chi_csr_nbr == <%=chi_idx%>) && (skip_test==0)) begin: _csr_chi_<%=chi_idx%>
  `ifndef USE_VIP_SNPS_CHI //existing flow will not run when USE_VIP_SNPS set
     `uvm_info("TEST_CSR_CHI", "REStart CHIAIU<%=idx%> enum_boot_seq", UVM_NONE)
      m_chi<%=chi_idx%>_vseq.enum_boot_seq(test_cfg.agent_ids_assigned_q,
                                       test_cfg.wayvec_assigned_q,
                                       test_cfg.k_sp_base_addr, 
                                       test_cfg.sp_ways,
                                       test_cfg.sp_size,
                                       test_cfg.aiu_qos_threshold,
                                       test_cfg.dce_qos_threshold,
                                       test_cfg.dmi_qos_threshold);
  `else //  `ifndef USE_VIP_SNPS  
  // New FSYS caused compile issues with fsys_snps. Temp work around to move progress
  m_snps_chi<%=chi_idx%>_vseq = chi_subsys_pkg::chi_subsys_vseq::type_id::create("m_chi<%=chi_idx%>_seq");
  m_snps_chi<%=chi_idx%>_vseq.set_seq_name("m_chi<%=chi_idx%>_seq");
  m_snps_chi<%=chi_idx%>_vseq.set_done_event_name("done_svt_chi_rn_seq_h<%=chi_idx%>");
  m_snps_chi<%=chi_idx%>_vseq.rn_xact_seqr    =  m_concerto_env.snps.svt.amba_system_env.chi_system[0].rn[<%=chi_idx%>].rn_xact_seqr;  
  m_snps_chi<%=chi_idx%>_vseq.shared_status =  m_concerto_env.snps.svt.amba_system_env.chi_system[0].rn[<%=chi_idx%>].shared_status;  
  m_snps_chi<%=chi_idx%>_vseq.chi_num_trans =  10;  
  m_snps_chi<%=chi_idx%>_vseq.m_regs = m_concerto_env.m_regs;
  // Due to STATIC m_chi0_args must create a dummy one.
  m_chi0_args = chi_aiu_unit_args_pkg::chi_aiu_unit_args::type_id::create("chi0_aiu_unit_args0");
  m_chi0_args.k_num_requests.set_value(10);
  m_chi0_args.k_coh_addr_pct.set_value(50);
  m_chi0_args.k_noncoh_addr_pct.set_value(50);
  m_chi0_args.k_device_type_mem_pct.set_value(50);
  m_chi0_args.k_new_addr_pct.set_value(50);
  m_snps_chi<%=chi_idx%>_vseq.set_unit_args(m_chi0_args);
  m_snps_chi<%=chi_idx%>_vseq.m_regs = m_concerto_env.m_regs;
  m_snps_chi<%=chi_idx%>_vseq.enum_boot_seq(test_cfg.agent_ids_assigned_q,
                                             test_cfg.wayvec_assigned_q,
                                             test_cfg.k_sp_base_addr, 
                                             test_cfg.sp_ways,
                                             test_cfg.sp_size,
                                             test_cfg.aiu_qos_threshold,
                                             test_cfg.dce_qos_threshold,
                                             test_cfg.dmi_qos_threshold);
   `endif //`ifndef USE_VIP_SNPS ... else
  end: _csr_chi_<%=chi_idx%>
    <% } chi_idx++; }} %>
  
  if(skip_test==1)
  begin : _skip_csr_chi_ //skipping because there is no chi present as passed by run time argument
     `uvm_info("TEST_CSR_CHI", $psprintf("Skipping CHIAIU%0d enum_boot_seq because there is no chi=%0d present",chi_csr_nbr,chi_csr_nbr), UVM_NONE)
     #20000ns; // Hard delay to not get this error (allowing enough time for the test to finish gracefully) - Scoreboard still has pending SYS transactions at the end of the test.
  end : _skip_csr_chi_ 
  ev_sim_done.trigger();
   `uvm_info("CONCERTO_FULLSYS_TEST_CHIAIU_CSR", "END ncore_test_stimulus", UVM_LOW)
endtask:ncore_test_stimulus

////////////////////////////////////////////////////////////////////
//#######  #     #  #     #   #####   #######  ###  #######  #     #  
//#        #     #  ##    #  #     #     #      #   #     #  ##    #  
//#        #     #  # #   #  #           #      #   #     #  # #   #  
//#####    #     #  #  #  #  #           #      #   #     #  #  #  #  
//#        #     #  #   # #  #           #      #   #     #  #   # #  
//#        #     #  #    ##  #     #     #      #   #     #  #    ##  
//#         #####   #     #   #####      #     ###  #######  #     #  
////////////////////////////////////////////////////////////////////
