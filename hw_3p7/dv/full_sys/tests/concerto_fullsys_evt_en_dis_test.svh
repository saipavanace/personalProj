<%
//Embedded javascript code to figure number of blocks
var numChiAiu = 0; // Number of CHI AIUs
var numACEAiu = 0; // Number of ACE AIUs
var numIoAiu = 0; // Number of IO AIUs
var numCAiu = 0; // Number of Coherent AIUs
var numNCAiu = 0; // Number of Non-Coherent AIUs
var found_csr_access_ioaiu =0;
var found_csr_access_chi =0;
var csrAccess_ioaiu=0;
var csrAccess_chiaiu;

var qidx = 0;
var initiatorAgents   = obj.AiuInfo.length ;
var aiu_NumCores = [];
var numAiuRpns = 0;   //Total AIU RPN's
var chiaiu0;  // strRtlNamePrefix of chiaiu0
var aceaiu0;  // strRtlNamePrefix of aceaiu0
var _blkid = [];
var _blktype = [];
var _blksuffix = [];
var _blk   = [];
var pidx = 0;
var ridx = 0;
var chiaiu_idx = 0;
var ioaiu_idx = 0;


for(pidx = 0; pidx < obj.nAIUs; pidx++) {
       _blk[pidx]   = obj.AiuInfo[pidx];
       if((obj.AiuInfo[pidx].fnNativeInterface == 'CHI-A')||(obj.AiuInfo[pidx].fnNativeInterface == 'CHI-B')||(obj.AiuInfo[pidx].fnNativeInterface == 'CHI-E')) {
       _blkid[pidx] = 'chiaiu' + chiaiu_idx;
       _blksuffix[pidx] = "_0";
       _blktype[pidx]   = 'chiaiu';
       chiaiu_idx++;
       } else {
       _blkid[pidx] = 'ioaiu' + ioaiu_idx;
       _blksuffix[pidx] = "_0";
       _blktype[pidx]   = 'ioaiu';
       ioaiu_idx++;
       }
   }
   for(pidx = 0; pidx < obj.nDCEs; pidx++) {
       ridx = pidx + obj.nAIUs;
       _blkid[ridx] = 'dce' + pidx;
       _blktype[ridx]   = 'dce';
       _blksuffix[ridx] = "";
       _blk[ridx]   = obj.DceInfo[pidx];
   }
   for(pidx =  0; pidx < obj.nDMIs; pidx++) {
       ridx = pidx + obj.nAIUs + obj.nDCEs;
       _blkid[ridx] = 'dmi' + pidx;
       _blktype[ridx]   = 'dmi';
       _blksuffix[ridx] = "";
       _blk[ridx]   = obj.DmiInfo[pidx];
   }
   for(pidx = 0; pidx < obj.nDIIs; pidx++) {
       ridx = pidx + obj.nAIUs + obj.nDCEs + obj.nDMIs;
       _blkid[ridx] = 'dii' + pidx;
       _blk[ridx]   = 'dii';
       _blksuffix[ridx] = "";
       _blk[ridx]   = obj.DiiInfo[pidx];
   }
   
   var nALLs = ridx+1; 

for(var pidx = 0; pidx < initiatorAgents; pidx++) { 
   if(Array.isArray(obj.AiuInfo[pidx].interfaces.axiInt)) {
       aiu_NumCores[pidx]    = obj.AiuInfo[pidx].interfaces.axiInt.length;
   } else {
       aiu_NumCores[pidx]    = 1;
   }
 }




for(pidx = 0; pidx < obj.nAIUs; pidx++) {
    if( obj.AiuInfo[pidx].fnNativeInterface == "CHI-A" || obj.AiuInfo[pidx].fnNativeInterface == "CHI-B" ||
        obj.AiuInfo[pidx].fnNativeInterface == "CHI-C" || obj.AiuInfo[pidx].fnNativeInterface == "CHI-D" ||
        obj.AiuInfo[pidx].fnNativeInterface == "CHI-E")
    {
        if ((found_csr_access_chi==0) && (obj.AiuInfo[pidx].fnCsrAccess == 1)) {
            csrAccess_chi_idx = numChiAiu;
            csrAccess_chiaiu = numChiAiu;
            found_csr_access_chi = 1;
            }
        if(numChiAiu == 0) { chiaiu0 = obj.AiuInfo[pidx].strRtlNamePrefix; }
        numChiAiu = numChiAiu + 1;numCAiu++ ; 
    } else {
      
        if ((found_csr_access_ioaiu==0) && (obj.AiuInfo[pidx].fnCsrAccess == 1)) {
            csrAccess_io_idx = numIoAiu;
            csrAccess_ioaiu = numIoAiu;
            found_csr_access_ioaiu = 1;
            }
        numIoAiu = numIoAiu + 1;

         if(obj.AiuInfo[pidx].fnNativeInterface == "ACE") { 
            if(numACEAiu == 0) { aceaiu0 = obj.AiuInfo[pidx].strRtlNamePrefix; }
            numCAiu++; numACEAiu++; 
         } else {
            if(Array.isArray(obj.AiuInfo[pidx].interfaces.axiInt)) {
               if (numNCAiu == 0) { ncaiu0  = obj.AiuInfo[pidx].strRtlNamePrefix + "_0"; }
            } else {
               if (numNCAiu == 0) { ncaiu0  = obj.AiuInfo[pidx].strRtlNamePrefix; }
            }
            numNCAiu++ ;
         }
    }
  if(obj.AiuInfo[pidx].nNativeInterfacePorts) {
       numAiuRpns += obj.AiuInfo[pidx].nNativeInterfacePorts;
    } else {
       numAiuRpns++;
    }
}

var regPrefixName = function() {
                                if (obj.BlockId.charAt(0)=="d")
                                    {return obj.BlockId.match(/[a-z]+/i)[0].toUpperCase();} //dmi,dii,dce,dve => DMI,DII,DVE 
                                if ((obj[obj.AgentInfoName][obj.Id].fnNativeInterface == 'CHI-A')||(obj[obj.AgentInfoName][obj.Id].fnNativeInterface == 'CHI-B')||(obj[obj.AgentInfoName][obj.Id].fnNativeInterface == 'CHI-E')) 
                                    {return "CAIU";}
                                return "XAIU"; // by default
                                };
%>

<%function generateRegPath(regName) {
    if(obj.nNativeInterfacePorts > 1) {
        return 'm_regs.'+obj.strRtlNamePrefix+'_0.'+regName;
    } else {
        return 'm_regs.'+obj.strRtlNamePrefix+'.'+regName;
    }
}%>
//This test will enbale/disable system event 
import addr_trans_mgr_pkg::*;

class concerto_fullsys_evt_en_dis_test extends concerto_fullsys_test; 

  `uvm_component_utils(concerto_fullsys_evt_en_dis_test)


  int main_seq_iter=1;
  int boot_from_ioaiu = 1;
  queue_of_block dves,dmis,dces,diis,chiaius,ioaius;
  verbose_reg_callback verbose_reg_cb;
  concerto_register_map_pkg::ral_sys_ncore  m_regs;

                              
                                  
  function new(string name = "concerto_fullsys_evt_en_dis_test", uvm_component parent=null);
    super.new(name,parent);
  endfunction: new

  // UVM PHASE
  extern task run_phase (uvm_phase phase);
  extern function void build_phase(uvm_phase phase);
  

  // HOOK task call in the parent class
  extern virtual task main_seq_iter_pre_hook(uvm_phase phase, int iter); // at the beginning of the iteration(inside the iteration loop)
  extern virtual task main_seq_iter_post_hook(uvm_phase phase, int iter);// at the end of the iteration (inside the iteration)
  extern virtual task main_seq_hook_end_run_phase(uvm_phase phase);
  // PRIVATE TASK

  extern task set_event_dis_reg(bit sys_event_disable );// this function will enable/disable systeme event receivers
  extern virtual task  set_registers();

 
endclass: concerto_fullsys_evt_en_dis_test


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
function void concerto_fullsys_evt_en_dis_test::build_phase(uvm_phase phase);
    super.build_phase(phase);
   // callback use to demoted warning messages
   verbose_reg_cb = verbose_reg_callback::type_id::create( "verbose_reg_cb" );
endfunction:build_phase

task  concerto_fullsys_evt_en_dis_test::set_registers();
        queue_of_reg   regs;
        queue_of_block blks;
        uvm_reg reg_;
        uvm_reg_block blk_;
        int i;

        `uvm_info(this.get_full_name(), "Start PRE_CONFIGURE_PHASE", UVM_LOW)
        
        m_regs = m_concerto_env.m_regs;  

        foreach (test_cfg.chiaius_name_a[i]) begin  
           blks = get_q_block_by_regexpname(m_regs,test_cfg.chiaius_name_a[i]);
           foreach(blks[blk_]) begin
                chiaius[blk_] = i; // append block 
           end
        end 
         foreach (test_cfg.ioaius_name_a[i]) begin  
           blks = get_q_block_by_regexpname(m_regs,test_cfg.ioaius_name_a[i]);
           foreach(blks[blk_]) begin
                ioaius[blk_] = i; // append block 
           end
        end 
        // Sample all mirror values & add callback
        /*regs =get_q_reg_by_regexpname(m_regs,"*");
        foreach (regs[reg_]) begin:_foreach_regs
            reg_.reset();
            uvm_reg_cb::add(reg_, verbose_reg_cb );
        end:_foreach_regs*/
       `uvm_info(this.get_full_name(), "End PRE_CONFIGURE_PHASE", UVM_LOW)

endtask:set_registers 

task concerto_fullsys_evt_en_dis_test::run_phase (uvm_phase phase); 
  max_iteration = 3;
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
////////////////////////////////////////////////////////////////////////////////////////
//////////////////// PRE HOOK                   ////////////
task concerto_fullsys_evt_en_dis_test::main_seq_iter_pre_hook(uvm_phase phase, int iter);
  `uvm_info(get_name(), $sformatf("START HOOK main_seq_iter_pre_hook iter:%0d",iter), UVM_NONE)
  phase.raise_objection(this, "Start  cfg sequence");
  `uvm_info(get_name(), " cfg sequence started", UVM_NONE)

  #1us; // wait propagation of the last write to register
    // TODO FOREACH DVE,DCE,DMI,DII
  phase.drop_objection(this, "Finish  cfg sequence");
  `uvm_info(get_name(), $sformatf("END HOOK main_seq_iter_pre_hook iter:%0d",iter), UVM_NONE)

endtask:main_seq_iter_pre_hook

////////////////////////////////////////////////////////////
//////////////////// POST HOOK ///////////
task concerto_fullsys_evt_en_dis_test::main_seq_iter_post_hook(uvm_phase phase, int iter);
  
  `uvm_info(get_name(), $sformatf("START HOOK main_seq_iter_post_hook iter:%0d",iter), UVM_NONE)
if (iter == 1) begin//after the first iteration  we will disable system event  
  set_registers();
  set_event_dis_reg(1);
end else 
if(iter == 2)begin // thenn will enable system_event
    set_event_dis_reg(0);
end 


    `ifndef USE_VIP_SNPS 
      `ifdef VCS
      super.main_seq_iter_post_hook(phase,iter); 
      `endif // `ifdef VCS
   `endif // `ifndef USE_VIP_SNPS 

  `uvm_info(get_name(), $sformatf("END HOOK main_seq_iter_post_hook iter:%0d",iter), UVM_NONE)

endtask:main_seq_iter_post_hook

////////////////////////////////////////////////////////////
////////////   HOOK END RUN PHASE       ///////////////
task concerto_fullsys_evt_en_dis_test::main_seq_hook_end_run_phase(uvm_phase phase);
  phase.raise_objection(this, "main_seq_hook_end_run_phase");
  `uvm_info(get_name(), "HOOK main_seq_hook_end_run_phase", UVM_NONE)
   

  `uvm_info(get_name(), "end of HOOK main_seq_hook_end_run_phase, ", UVM_NONE)
   phase.drop_objection(this, "main_seq_hook_end_run_phase");

endtask:main_seq_hook_end_run_phase

task concerto_fullsys_evt_en_dis_test::set_event_dis_reg(bit sys_event_disable );
   uvm_status_e status; 
   uvm_reg_data_t data;
   uvm_reg_block  ioaiu;
   queue_of_reg   regs;
   int find_idx[$];
   uvm_reg reg_;
   int ioaiu_idx;

   uvm_status_e chi_status;
   uvm_reg_data_t chi_data;
   uvm_reg_block  chi;
   queue_of_reg   chi_regs;
   uvm_reg chi_reg_;
   int i;
   int chi_idx;

   
   foreach (chiaius[chi]) begin:_foreach_chi
   `uvm_info(get_name(), "start programming CHIAIU EventDisable", UVM_NONE)
      chi_idx=chi.get_reg_by_name("CAIUIDR").get_field_by_name("NUnitId").get_reset();
      `uvm_info("set_event_dis_reg", $sformatf("Start setup chiaiu%0d", chi_idx), UVM_LOW)
      //Disable sys event for CHI
      chi_reg_=chi.get_reg_by_name("CAIUTCR");
      chi_data=chi_reg_.get_reset(); 
      ral_fill_field(chi_reg_, "EventDisable",chi_data,sys_event_disable);
      ral_fill_field(chi_reg_, "SysCoDisable",chi_data,1);
      chi_reg_.write(chi_status,chi_data);
      `uvm_info("set_event_dis_reg", $sformatf("End setup chiaiu%0d", chi_idx), UVM_LOW)
   end:_foreach_chi

   foreach (ioaius[ioaiu]) begin:_foreach_ioaiu
   `uvm_info(get_name(), "start programming IOAIU EventDisable", UVM_NONE)
      ioaiu_idx=ioaiu.get_reg_by_name("XAIUIDR").get_field_by_name("NUnitId").get_reset();
      `uvm_info("set_event_dis_reg", $sformatf("Start setup ioaiu%0d", ioaiu_idx), UVM_LOW)
      //Disable sys event for IOAIU
      reg_=ioaiu.get_reg_by_name("XAIUTCR");
      data=reg_.get_reset(); 
      ral_fill_field(reg_, "EventDisable",data,sys_event_disable);
      ral_fill_field(reg_, "SysCoDisable",data,1);
      reg_.write(status,data);
      `uvm_info("set_event_dis_reg", $sformatf("End setup ioaiu%0d", ioaiu_idx), UVM_LOW)
   end:_foreach_ioaiu

endtask:set_event_dis_reg


////////////////////////////////////////////////////////////////////
//#######  #     #  #     #   #####   #######  ###  #######  #     #  
//#        #     #  ##    #  #     #     #      #   #     #  ##    #  
//#        #     #  # #   #  #           #      #   #     #  # #   #  
//#####    #     #  #  #  #  #           #      #   #     #  #  #  #  
//#        #     #  #   # #  #           #      #   #     #  #   # #  
//#        #     #  #    ##  #     #     #      #   #     #  #    ##  
//#         #####   #     #   #####      #     ###  #######  #     #  
////////////////////////////////////////////////////////////////////
/*class verbose_reg_callback extends uvm_reg_cbs; 
 `uvm_object_param_utils( verbose_reg_callback )
 
  function new( string name = "verbose_reg_callback" );
    super.new( name );
  endfunction: new

  task display_fields(uvm_reg_item rw,string rw_type="unknown");
   uvm_reg reg_; 
   uvm_reg_field fields[$];
   uvm_reg_data_t data;
   uvm_reg_addr_t addr;
   int i;

   $cast(reg_,rw.element);
   addr=reg_.get_address(); // init with raw reg value 
   data = rw.value[0];
   `uvm_info({"CallBackEmu: FULL_REG_post_",rw_type}, $sformatf("%0s address:0x%0h value_hex:0x%0h",reg_.get_full_name(),addr,data), UVM_LOW)
   
   reg_.get_fields(fields);
   foreach(fields[i]) begin:_foreach_field
     uvm_reg_data_t data;
     uvm_reg_data_t mask; 
     if (uvm_re_match(uvm_glob_to_re("*Rsvd*"),fields[i].get_name())) begin:_display_no_rsvd_field
       mask = (((1 << fields[i].get_n_bits())-1) << fields[i].get_lsb_pos());// highlight selected field  
       data=rw.value[0]; // init with raw reg value 
       data &= mask; // other fields set to 0
       data = (data >> fields[i].get_lsb_pos());
       `uvm_info({"CallBack: post_",rw_type}, $sformatf("%0s value:%0d value_hex:0x%0h value_binary:%0b",fields[i].get_full_name(),data,data,data), UVM_LOW)
     end:_display_no_rsvd_field
   end:_foreach_field 
  endtask:display_fields;

  virtual task post_write( uvm_reg_item rw ); // use only in case of uvm_reg
   if (uvm_top.get_report_verbosity_level() >= UVM_LOW) display_fields(rw,"write");
  endtask:post_write;
  
  virtual task post_read( uvm_reg_item rw ); // use only in case of uvm_reg
   if (uvm_top.get_report_verbosity_level() >= UVM_LOW) display_fields(rw,"read");
  endtask:post_read;

endclass: verbose_reg_callback*/