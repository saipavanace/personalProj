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
       if((obj.AiuInfo[pidx].fnNativeInterface == 'CHI-A')||(obj.AiuInfo[pidx].fnNativeInterface == 'CHI-B' || obj.AiuInfo[pidx].fnNativeInterface == 'CHI-E')) {
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
class concerto_fullsys_2ndIter_cachelookuponly extends concerto_fullsys_test; 

  `uvm_component_utils(concerto_fullsys_2ndIter_cachelookuponly)

  int main_seq_iter=1;
                                  
  function new(string name = "concerto_fullsys_2ndIter_cachelookuponly", uvm_component parent=null);
    super.new(name,parent);
  endfunction: new

  // UVM PHASE
  extern function void build_phase(uvm_phase phase);
  extern task run_phase (uvm_phase phase);
//  extern task post_shutdown_phase (uvm_phase phase);

  // HOOK task call in the parent class
  //extern virtual task main_seq_pre_hook(uvm_phase phase);  // before the iteration (outside the iteration loop)
  //extern virtual task main_seq_post_hook(uvm_phase phase); // after the iteration (outside the iteration loop)
  extern virtual task main_seq_iter_pre_hook(uvm_phase phase, int iter); // at the beginning of the iteration(inside the iteration loop)
  extern virtual task main_seq_iter_post_hook(uvm_phase phase, int iter);// at the end of the iteration (inside the iteration)
  extern virtual task main_seq_hook_end_run_phase(uvm_phase phase);

endclass: concerto_fullsys_2ndIter_cachelookuponly


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
function void concerto_fullsys_2ndIter_cachelookuponly::build_phase(uvm_phase phase);
    super.build_phase(phase);
endfunction : build_phase
task concerto_fullsys_2ndIter_cachelookuponly::run_phase (uvm_phase phase); 
  max_iteration = 2;
  super.run_phase(phase);
endtask:run_phase

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
task concerto_fullsys_2ndIter_cachelookuponly::main_seq_iter_pre_hook(uvm_phase phase, int iter);
  phase.raise_objection(this, "main_seq_pre_hook_run_phase");
  `uvm_info(get_name(), $sformatf("START HOOK main_seq_iter_pre_hook iter:%0d",iter), UVM_NONE)
  `uvm_info(get_name(), $sformatf("END HOOK main_seq_iter_pre_hook iter:%0d",iter), UVM_NONE)
  phase.drop_objection(this, "main_seq_pre_hook_run_phase");
endtask:main_seq_iter_pre_hook

////////////////////////////////////////////////////////////
//////////////////// POST HOOK ///////////
task concerto_fullsys_2ndIter_cachelookuponly::main_seq_iter_post_hook(uvm_phase phase, int iter);
  uvm_reg ral_reg;
  uvm_reg_field ral_field;
  bit [31:0] data;
  bit [31:0] mask;

  phase.raise_objection(this, "main_seq_post_hook_run_phase");
   #2us; // wait last txn finish
  `uvm_info(get_name(), $sformatf("START HOOK main_seq_iter_post_hook iter:%0d",iter), UVM_NONE)
`ifndef USE_VIP_SNPS //existing flow will not run when USE_VIP_SNPS set
   <%for(var pidx = 0; pidx < obj.nAIUs_mpu; pidx++) {%>
      <%if(_blk[pidx].fnNativeInterface == 'AXI4' && _blk[pidx].useCache) {%>
         ral_reg = m_concerto_env.m_regs.get_block_by_name("<%=_blk[pidx].strRtlNamePrefix+((_blk_nCore[pidx]>1)?_blkports_suffix[pidx]:"")%>").get_reg_by_name("XAIUPCTCR");
        <% if (ioaiu_idx) {%> 
          rw_tsks.read_csr0(ral_reg.get_address(),data); 
        <%} else {%>
          m_chi0_vseq.read_csr(ral_reg.get_address(),data); 
        <%}%>
         
         ral_field = ral_reg.get_field_by_name("LookupEn");
         mask = ~(((1 << ral_field.get_n_bits())-1) << ral_field.get_lsb_pos()); // set field to all zeroes
         data &= mask; // set field to 0
         data |= (1 << ral_field.get_lsb_pos()); // set field to value // lookupen enable = 1 

         mask = 0;
         ral_field = ral_reg.get_field_by_name("AllocEn");
         mask = ~(((1 << ral_field.get_n_bits())-1) << ral_field.get_lsb_pos()); // set field to all zeroes
         data &= mask; // set field to 0 // allocen=0
         <% if (ioaiu_idx) {%>  
         rw_tsks.write_csr0(ral_reg.get_address(),data,0);
          <%} else {%>
          m_chi0_vseq.write_csr(ral_reg.get_address(),data); 
          <%}%>
         
         	`uvm_info("WRITE REG <%=_blk[pidx].strRtlNamePrefix+((_blk_nCore[pidx]>1)?_blkports_suffix[pidx]:"")%>.XAIUPCTCR", $sformatf("Write ADDR 0x%0h DATA 0x%0h", ral_reg.get_address(), data), UVM_NONE)
      <%}%>
   <%}%>
   <%for(var pidx = obj.nAIUs_mpu + obj.nDCEs; pidx < obj.nAIUs_mpu + obj.nDCEs+obj.nDMIs; pidx++) {%>
      <%if(_blk[pidx].useCmc) {%>
        ral_reg = m_concerto_env.m_regs.get_block_by_name("<%=_blk[pidx].strRtlNamePrefix%>").get_reg_by_name("DMIUSMCTCR");
          <% if (ioaiu_idx) {%> 
          rw_tsks.read_csr0(ral_reg.get_address(),data); 
        <%} else {%>
          m_chi0_vseq.read_csr(ral_reg.get_address(),data); 
        <%}%>
         
         ral_field = ral_reg.get_field_by_name("LookupEn");
         mask = ~(((1 << ral_field.get_n_bits())-1) << ral_field.get_lsb_pos()); // set field to all zeroes
         data &= mask; // set field to 0
         data |= (1 << ral_field.get_lsb_pos()); // set field to value // lookupen enable = 1 
         if(m_args.dmi_scb_en) m_concerto_env.inhouse.m_dmi<%=_blk[pidx].nUnitId%>_env.m_sb.lookup_en =1; // update DMI SCB !!! because don't use RAL !!! 

         mask = 0;
         ral_field = ral_reg.get_field_by_name("AllocEn");
         mask = ~(((1 << ral_field.get_n_bits())-1) << ral_field.get_lsb_pos()); // set field to all zeroes
         data &= mask; // set field to 0 // allocen=0
           <% if (ioaiu_idx) {%>  
            rw_tsks.write_csr0(ral_reg.get_address(),data,0);
          <%} else {%>
          m_chi0_vseq.write_csr(ral_reg.get_address(),data); 
          <%}%>
         if(m_args.dmi_scb_en) m_concerto_env.inhouse.m_dmi<%=_blk[pidx].nUnitId%>_env.m_sb.alloc_en =0; // update DMI SCB !!! because don't use RAL !!! 

         	`uvm_info("WRITE REG <%=_blk[pidx].strRtlNamePrefix%>.DMIUSMCTCR", $sformatf("Write ADDR 0x%0h DATA 0x%0h", ral_reg.get_address(), data), UVM_NONE)
  
      <%}%>
   <%}%>  
`endif //  `ifndef USE_VIP_SNPS 

  `ifndef USE_VIP_SNPS 
      `ifdef VCS
      super.main_seq_iter_post_hook(phase,iter); 
      `endif // `ifdef VCS
   `endif // `ifndef USE_VIP_SNPS 

  `uvm_info(get_name(), $sformatf("END HOOK main_seq_iter_post_hook iter:%0d",iter), UVM_NONE)
  phase.drop_objection(this, "main_seq_post_hook_run_phase");

endtask:main_seq_iter_post_hook

////////////////////////////////////////////////////////////
////////////   HOOK END RUN PHASE       ///////////////
task concerto_fullsys_2ndIter_cachelookuponly::main_seq_hook_end_run_phase(uvm_phase phase);
  phase.raise_objection(this, "main_seq_hook_end_run_phase");
  `uvm_info(get_name(), "HOOK main_seq_hook_end_run_phase", UVM_NONE)
  `uvm_info(get_name(), "end of HOOK main_seq_hook_end_run_phase", UVM_NONE)
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
