

//                                                        //
//                                                        //
//File     : concerto_boot_tasks.sv                       //
//Author   : Cyrille LUDWIG                               //
////////////////////////////////////////////////////////////
// CallBack to display values of field when read or write
class verbose_reg_callback extends uvm_reg_cbs; 
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

endclass: verbose_reg_callback

class concerto_boot_tasks extends uvm_component;

   //////////////////
   //UVM Registery
   //////////////////   
   `uvm_component_utils(concerto_boot_tasks)

   //////////////////
   //Properties
   //////////////////
   queue_of_block dves,dmis,dces,diis,chiaius,ioaius;
   
   //set env 
   concerto_test_cfg test_cfg;
   concerto_env_cfg m_concerto_env_cfg;  
   concerto_env     m_concerto_env;
   concerto_register_map_pkg::ral_sys_ncore  m_regs;
   verbose_reg_callback verbose_reg_cb;

   //////////////////
   //Methods
   //////////////////
   
   //constructor
   extern function new(string name = "concerto_boot_tasks", uvm_component parent = null);
   extern function void build_phase(uvm_phase phase);

   //uvm_phase
   extern virtual task  pre_ncore_configure();
   extern virtual task  ncore_configure();

   //tasks  
   extern virtual task setup_init_mem();
   extern virtual task setup_gprar_mem();
   extern virtual task setup_init_dce();
   extern virtual task setup_init_dve();
   extern virtual task setup_init_dii();
   extern virtual task setup_init_dmi();   
   extern virtual task setup_init_ioaiu();   
   extern virtual task setup_init_chiaiu();   
   extern virtual task pull_sysco_attached();
   extern virtual task print_region_mem();

   // TOOLS
   //extern static function queue_of_reg  get_q_reg_by_regexpname(uvm_reg_block blk,string regexpname);
   //extern static function queue_of_block  get_q_block_by_regexpname(uvm_reg_block blk,string regexpname);
   extern task launch_mem_maintenance(uvm_reg_data_t data, bit enable_dce=0); // add enalbe_dce because we should only init one time the snoop filter if we use 2 times
   extern task pull_mem_maintenance();

endclass: concerto_boot_tasks


function concerto_boot_tasks::new(string name = "concerto_boot_tasks", uvm_component parent = null);

  super.new(name,parent);
    
endfunction: new
// ////////////////////////////////////////////////////////////////////////////
// #     # #     # #     #         ######  #     #    #     #####  #######
// #     # #     # ##   ##         #     # #     #   # #   #     # #
// #     # #     # # # # #         #     # #     #  #   #  #       #
// #     # #     # #  #  #         ######  ####### #     #  #####  #####
// #     #  #   #  #     #         #       #     # #######       # #
// #     #   # #   #     #         #       #     # #     # #     # #
//  #####     #    #     # ####### #       #     # #     #  #####  #######
////////////////////////////////////////////////////////////////////////////
function void concerto_boot_tasks::build_phase(uvm_phase phase);

     
     if(!(uvm_config_db #(concerto_env_cfg)::get(uvm_root::get(), "", "m_cfg", m_concerto_env_cfg)))begin
        `uvm_fatal(this.get_full_name(), "Could not find concerto_env_cfg object in UVM DB");
    end   
      if(!(uvm_config_db #(concerto_env)::get(uvm_root::get(), "", "m_env", m_concerto_env)))begin
        `uvm_fatal(this.get_full_name(), "Could not find concerto_env_cfg object in UVM DB");
    end  
     if(!(uvm_config_db #(concerto_test_cfg)::get(uvm_root::get(), "", "test_cfg", test_cfg)))begin
        `uvm_fatal(this.get_full_name(), "Could not find concerto_test_cfg object in UVM DB");
    end 

   // callback use to demoted warning messages
   verbose_reg_cb = verbose_reg_callback::type_id::create( "verbose_reg_cb" );
endfunction:build_phase

task  concerto_boot_tasks::pre_ncore_configure();
        queue_of_reg   regs;
        queue_of_block blks;
        uvm_reg reg_;
        uvm_reg_block blk_;
        int i;

        `uvm_info(this.get_full_name(), "Start PRE_CONFIGURE_PHASE", UVM_LOW)
        
        m_regs = m_concerto_env.m_regs;  
       

        dves = get_q_block_by_regexpname(m_regs,"*dve*");
        dces = get_q_block_by_regexpname(m_regs,"*dce*");
        //diis = get_q_block_by_regexpname(m_regs,"*diis*");
        //dmis = get_q_block_by_regexpname(m_regs,"*dmi*");
       foreach (test_cfg.diis_name_a[i]) begin  
           blks = get_q_block_by_regexpname(m_regs,test_cfg.diis_name_a[i]);
           foreach(blks[blk_]) begin
                diis[blk_] = i; // append block 
           end
        end 
       foreach (test_cfg.dmis_name_a[i]) begin  
           blks = get_q_block_by_regexpname(m_regs,test_cfg.dmis_name_a[i]);
           foreach(blks[blk_]) begin
                dmis[blk_] = i; // append block 
           end
        end 
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
        regs =get_q_reg_by_regexpname(m_regs,"*");
        foreach (regs[reg_]) begin:_foreach_regs
            reg_.reset();
            uvm_reg_cb::add(reg_, verbose_reg_cb );
        end:_foreach_regs
       `uvm_info(this.get_full_name(), "End PRE_CONFIGURE_PHASE", UVM_LOW)

endtask:pre_ncore_configure

task  concerto_boot_tasks::ncore_configure();
        pre_ncore_configure();
        if (!test_cfg.disable_boot_tasks && !test_cfg.k_csr_access_only) begin
        `uvm_info(this.get_full_name(), "Start CONFIGURE_PHASE", UVM_LOW)
           if(test_cfg.use_new_csr==1) begin // Configure ncore register using legacy boot task 
             setup_gprar_mem();
             setup_init_dce();
             setup_init_chiaiu();
             setup_init_ioaiu();
             setup_init_dmi();
             setup_init_dii();
             setup_init_mem();
             if (uvm_top.get_report_verbosity_level() >= UVM_LOW) print_region_mem();
             if(!test_cfg.sysco_disable) pull_sysco_attached();
           end 
        `uvm_info(this.get_full_name(), "End CONFIGURE_PHASE", UVM_LOW)
        end
endtask:ncore_configure

/////////////////////////////////////
// #######    #     #####  #    #
//    #      # #   #     # #   #
//    #     #   #  #       #  #
//    #    #     #  #####  ###
//    #    #######       # #  #
//    #    #     # #     # #   #
//    #    #     #  #####  #    #
// /////////////////////////////////////
task concerto_boot_tasks::setup_gprar_mem();
    uvm_status_e status;
    uvm_reg_data_t data;
    queue_of_reg   regs;
    uvm_reg reg_;
    int ig;
    int q_find[$];
     
    if (ioaius.size()) 
    `uvm_info("setup_gprar_init", "Start setup_gprar", UVM_LOW)
    foreach (test_cfg.csrq[ig]) begin:_foreach_csrq_ig
             regs = get_q_reg_by_regexpname(m_regs,$sformatf("*GPRBLR%0d",ig));
             foreach (regs[reg_]) begin //foreach xxxGPRBLR regs
                  reg_.write(status,test_cfg.csrq[ig].low_addr);
             end
             regs = get_q_reg_by_regexpname(m_regs,$sformatf("*GPRBHR%0d",ig));
             foreach (regs[reg_]) begin //foreach xxxGPRBHR regs
                  reg_.write(status,test_cfg.csrq[ig].upp_addr);
             end
             regs = get_q_reg_by_regexpname(m_regs,$sformatf("*GPRAR%0d",ig));
             foreach (regs[reg_]) begin //foreach xxxGPRAR regs
                  data = reg_.get_reset(); 
                  ral_fill_field(reg_, "HUT",data,(test_cfg.csrq[ig].unit == ncore_config_pkg::ncoreConfigInfo::DII ? 2'b10 : 2'b00));
                  ral_fill_field(reg_, "Size",data,test_cfg.csrq[ig].size);
                  ral_fill_field(reg_, "HUI",data,test_cfg.csrq[ig].mig_nunitid);
                  ral_fill_field(reg_, "ReadID",data,test_cfg.csrq[ig].order.readid);
                  ral_fill_field(reg_, "WriteID",data,test_cfg.csrq[ig].order.writeid);
                  ral_fill_field(reg_, "Policy",data,test_cfg.csrq[ig].order.policy);
                  ral_fill_field(reg_, "NSX",data,test_cfg.csrq[ig].nsx);
                  //reg_.get_field_by_name("HUT").write(status,(test_cfg.csrq[ig].unit == ncore_config_pkg::ncoreConfigInfo::DII ? 2'b10 : 2'b00),UVM_BACKDOOR);
                  //reg_.get_field_by_name("Size").write(status,test_cfg.csrq[ig].size,UVM_BACKDOOR);
                  //reg_.get_field_by_name("HUI").write(status,test_cfg.csrq[ig].mig_nunitid,UVM_BACKDOOR);
                  //reg_.get_field_by_name("Policy").write(status,test_cfg.csrq[ig].order,UVM_BACKDOOR);
                  //reg_.get_field_by_name("NSX").write(status,test_cfg.csrq[ig].nsx,UVM_BACKDOOR);
                  if (!uvm_re_match(uvm_glob_to_re("XAIU*"),reg_.get_name())) begin:_if_ioaiu// only IOAIU
                     if (reg_.get_field_by_name("NC")) begin:_if_nc
                           //reg_.get_field_by_name("NC").write(status,test_cfg.csrq[ig].nc,UVM_BACKDOOR);
                           ral_fill_field(reg_, "NC",data,test_cfg.csrq[ig].nc);
                     end:_if_nc
                  end:_if_ioaiu 
                  //reg_.get_field_by_name("Valid").write(status,1,UVM_BACKDOOR);// TODO MUST BE FRONTDOOR ??
                  ral_fill_field(reg_, "Valid",data,1);
                  reg_.write(status,data);
            end // end foreach xxxGPRAR regs
     end:_foreach_csrq_ig
    `uvm_info("setup_gprar_init", "End setup_gprar", UVM_LOW)
     
     //Active Memory Interleave Group Register xxxAMIGR
     regs = get_q_reg_by_regexpname(m_regs,"*AMIGR*");
     foreach (regs[reg_]) begin //foreach xxxGPRBHR regs
         //reg_.get_field_by_name("AMIGS").write(status,ncore_config_pkg::ncoreConfigInfo::picked_dmi_igs,UVM_BACKDOOR);
         //reg_.get_field_by_name("Valid").write(status,1,UVM_BACKDOOR);  // TODO MUST BE FRONTDOOR ??
         reg_.get_reset();
         ral_fill_field(reg_, "AMIGS",data,ncore_config_pkg::ncoreConfigInfo::picked_dmi_igs);
         ral_fill_field(reg_, "Valid",data,1);
         reg_.write(status,data);
     end
     regs = get_q_reg_by_regexpname(m_regs,"*MIFSR*");
     foreach (regs[reg_]) begin //foreach xxxGPRBHR regs
         reg_.get_reset();
         ral_fill_field(reg_, "MIG2AIFId",data,ncore_config_pkg::ncoreConfigInfo::picked_dmi_if[2]);
         ral_fill_field(reg_, "MIG3AIFId",data,ncore_config_pkg::ncoreConfigInfo::picked_dmi_if[3]);
         ral_fill_field(reg_, "MIG4AIFId",data,ncore_config_pkg::ncoreConfigInfo::picked_dmi_if[4]);
         ral_fill_field(reg_, "MIG8AIFId",data,ncore_config_pkg::ncoreConfigInfo::picked_dmi_if[8]);
         ral_fill_field(reg_, "MIG16AIFId",data,ncore_config_pkg::ncoreConfigInfo::picked_dmi_if[16]);
         reg_.write(status,data);
     end
     // TODO xxxBRAR registers  // BOOTREGION // wait new addr mgr
     // TODO xxxNRSBAR registers // CSR register base address // wait new addr mgr

endtask:setup_gprar_mem

task concerto_boot_tasks::print_region_mem();
  int max_gprar = 16;
  queue_of_reg   regs;
  uvm_reg reg_;
  string s ="";
  uvm_reg_block blk_;
  int size;
  longint low_addr;

  // get one agent block among all. no matter which one.  all the agent have the same mem configuration
  if (ioaius.size()) begin 
    blk_ = m_regs.get_block_by_name(test_cfg.ioaius_name_a[0]);
  end else begin
    blk_ = m_regs.get_block_by_name(test_cfg.chiaius_name_a[0]);
  end

  `uvm_info(this.get_full_name(), "### START PRINT_MEM CONFIGURATION ###", UVM_LOW)
  for (int i=0;i<max_gprar;i++) begin:_each_gprar
      s= "";
      low_addr=0;
      regs = get_q_reg_by_regexpname(blk_,$sformatf("*GPRAR%0d",i));
      foreach (regs[reg_]) begin //foreach xxxGPRAR regs
        $sformat(s,"%s Valid:%0d ",s,reg_.get_field_by_name("Valid").get());
        $sformat(s,"%s GPRAR%0d %5s ",s,i,(reg_.get_field_by_name("HUT").get())? "DII":"DMI");
        $sformat(s,"%s MIG_UnitId:0x%0h ",s,reg_.get_field_by_name("HUI").get());
        $sformat(s,"%s Policy:0x%2h ",s,reg_.get_field_by_name("Policy").get());
        size =reg_.get_field_by_name("Size").get();
        $sformat(s,"%s Size:%0dKB (raw:%0d) ",s,(2**(size+12))/1024,size);
        $sformat(s,"%s NSX:0x%0h ",s,reg_.get_field_by_name("NSX").get());
        if (!uvm_re_match(uvm_glob_to_re("XAIU*"),reg_.get_name())) begin:_if_ioaiu// only IOAIU
           if (reg_.get_field_by_name("NC")) begin:_if_nc
                          $sformat(s,"%s NC:0x%0h ",s,reg_.get_field_by_name("NC").get());
                     end:_if_nc
        end:_if_ioaiu
      end
      regs = get_q_reg_by_regexpname(blk_,$sformatf("*GPRBHR%0d",i));
      foreach (regs[reg_]) begin
            low_addr = reg_.get() << 44;
      end
      regs = get_q_reg_by_regexpname(blk_,$sformatf("*GPRBLR%0d",i));
      foreach (regs[reg_]) begin
            low_addr = low_addr | (reg_.get() << 12);
            $sformat(s,"%s start address:%0h ",s,low_addr);
      end
      if (s !="") $display ("%0s",s);
  end:_each_gprar
  `uvm_info(this.get_full_name(), "### END PRINT_MEM CONFIGURATION ###", UVM_LOW)

endtask:print_region_mem

task concerto_boot_tasks::setup_init_dce();
    uvm_status_e status;
    uvm_reg_data_t data;
    uvm_reg_block  dce;
    queue_of_reg   regs;
    uvm_reg reg_;
    int dce_idx;
    int i;

    foreach (dces[dce]) begin:_foreach_dce
         dce_idx=dce.get_reg_by_name("DCEUIDR").get_field_by_name("NUnitId").get_reset();
        `uvm_info("setup_init_dce", $sformatf("Start setup dce%0d", dce_idx), UVM_LOW)
         // enable decode errror
         //dce.get_reg_by_name("DCEUUEDR").get_field_by_name("DecErrDetEn").write(status, 1,UVM_BACKDOOR);
         reg_=dce.get_reg_by_name("DCEUUEDR");
         data=reg_.get_reset(); 
         ral_fill_field(reg_, "SoftwareProgConfigErrDetEn",data,1);
         reg_.write(status,data);
      
        // Enable Error detection to enable error correction feature by default
        //DCEUCECR   
        //dce.get_reg_by_name("DCEUCECR").get_field_by_name("ErrDetEn").write(status,1,UVM_BACKDOOR);
         reg_=dce.get_reg_by_name("DCEUCECR");
         data=reg_.get_reset(); 
         ral_fill_field(reg_, "ErrDetEn",data,1);
         reg_.write(status,data);

         if (test_cfg.dce_qos_threshold[dce_idx] >= 0) begin
           //dce.get_reg_by_name("DCEUQOSCR0").get_field_by_name("EventThreshold").write(status,test_cfg.dce_qos_threshold[dce_idx],UVM_BACKDOOR);
           reg_=dce.get_reg_by_name("DCEUQOSCR0");
           data=reg_.get_reset(); 
           ral_fill_field(reg_, "EventThreshold",data,test_cfg.dce_qos_threshold[dce_idx]);
           reg_.write(status,data);
         end
 
     //DCE SYSCO EVENT 
        if(test_cfg.sysco_disable) begin
            regs = get_q_reg_by_regexpname(dce,"DCEUSER*");
            foreach (regs[reg_]) begin //foreach DCEUSER reg
               reg_.write(status,32'hFFFF_FFFF);
            end // end foreach DCEUSER reg
        end
        //DCE SYS EVENT
         reg_=dce.get_reg_by_name("DCEUTCR");
         data=reg_.get_reset(); 
         ral_fill_field(reg_, "EventDisable",data,test_cfg.sys_event_disable);
         reg_.write(status,data);
        `uvm_info("setup_init_dce", $sformatf("end block setup dce%0d", dce_idx), UVM_LOW)
    end:_foreach_dce

    
      `uvm_info("setup_init_dce", "End setup dce", UVM_LOW)
       

endtask: setup_init_dce

task concerto_boot_tasks::setup_init_dmi();
    uvm_status_e status;
    uvm_reg_data_t data;
    uvm_reg_block  dmi;
    queue_of_reg   regs;
    uvm_reg reg_;
    int i;
    int dmi_idx;
   
   foreach (dmis[dmi]) begin:_foreach_dmi
       dmi_idx = dmi.get_reg_by_name("DMIUIDR").get_field_by_name("NUnitId").get_reset();
      `uvm_info("setup_init_dmi", $sformatf("Start setup dmi%0d", dmi_idx), UVM_LOW)
      
      // Enable Error detection to enable error correction feature by default
         reg_ = dmi.get_reg_by_name("DMIUUEDR");
         data = reg_.get_reset();
         ral_fill_field(reg_, "SoftwareProgConfigErrDetEn",data,1);
         reg_.write(status,data);
         

      // Configure SMC 
      if(ncoreConfigInfo::dmis_with_cmc[dmi_idx]) begin:_if_cache 
         // Configure Scratchpad memories 
         if(ncoreConfigInfo::dmis_with_cmcsp[dmi_idx]) begin:_if_scratchpad 
            //DMIUSMCSPBR*
            //#Stimulus.FSYS.DMI_ScratchPad
            longint ScPadBaseAddr = test_cfg.k_sp_base_addr[dmi_idx];
	         longint ScPadBaseAddr_ns;
            if(ncoreConfigInfo::ADDR_WIDTH > 32) begin
               dmi.get_reg_by_name("DMIUSMCSPBR0").write(status, ScPadBaseAddr[31:0]);
               ScPadBaseAddr_ns = ScPadBaseAddr>>32;
               ScPadBaseAddr_ns[ncoreConfigInfo::ADDR_WIDTH - ncoreConfigInfo::WCACHE_OFFSET-32]=  test_cfg.sp_ns[dmi_idx];
               dmi.get_reg_by_name("DMIUSMCSPBR1").write(status, (ScPadBaseAddr_ns[31:0])); // ScPadBaseAddrHi
            end else begin
               ScPadBaseAddr[ncoreConfigInfo::ADDR_WIDTH - ncoreConfigInfo::WCACHE_OFFSET]=  test_cfg.sp_ns[dmi_idx];
               dmi.get_reg_by_name("DMIUSMCSPBR0").write(status, ScPadBaseAddr);
            end
            `uvm_info("setup_init_dmi", $sformatf("dmi%0d Raw ScPadBaseAddr in register:%0h // ScPadBasAddr:%0h", dmi_idx,ScPadBaseAddr,  ScPadBaseAddr<< ncore_config_pkg::ncoreConfigInfo::WCACHE_OFFSET), UVM_NONE)

            begin
            //DMIUSMCSPCR*
            //dmi.get_reg_by_name("DMIUSMCSPCR0").get_field_by_name("NumScPadWays").write(status, test_cfg.sp_ways[dmi_idx]-1,UVM_BACKDOOR);
            //dmi.get_reg_by_name("DMIUSMCSPCR1").get_field_by_name("ScPadSize").write(status, test_cfg.sp_size[dmi_idx]-1,UVM_BACKDOOR);
            //dmi.get_reg_by_name("DMIUSMCSPCR0").get_field_by_name("ScPadEn").write(status, ScPadEn);
             reg_ = dmi.get_reg_by_name("DMIUSMCSPCR0");
             data = reg_.get_reset();
             ral_fill_field(reg_, "NumScPadWays",data,(test_cfg.sp_ways[dmi_idx]-1));
             ral_fill_field(reg_, "ScPadEn",data,test_cfg.sp_en[dmi_idx]);
             reg_.write(status,data);

             reg_ = dmi.get_reg_by_name("DMIUSMCSPCR1");
             data = reg_.get_reset();
             ral_fill_field(reg_, "ScPadSize",data,(test_cfg.sp_size[dmi_idx]-1));
             reg_.write(status,data);

            end
         end:_if_scratchpad

         // Configure way partitioning // TODO what if SP and Way partitioning both are enabled together ?
         if(ncore_config_pkg::ncoreConfigInfo::dmis_with_cmcwp[dmi_idx]) begin:_if_way_partionning
            if (!$test$plusargs("no_way_partitioning")) begin
               for( int j=0;j<ncore_config_pkg::ncoreConfigInfo::dmi_CmcWPReg[dmi_idx];j++) begin
                  //DMIUSMCWPCR0* : 
                  regs = get_q_reg_by_regexpname(dmi,$sformatf("DMIUSMCWPCR0%0d",j));
                  foreach (regs[reg_]) begin //foreach DMIUSMCWPCR0* regs
                     reg_.write(status,test_cfg.agent_ids_assigned_q[dmi_idx][j]);
                  end
                  //DMIUSMCWPCR1*
                  regs = get_q_reg_by_regexpname(dmi,$sformatf("DMIUSMCWPCR1%0d",j));
                  foreach (regs[reg_]) begin //foreach DMIUSCMWPCR1* regs
                     //reg_.get_field_by_name("WpWayVector").write(status,test_cfg.wayvec_assigned_q[dmi_idx][j]);
                     reg_.write(status,test_cfg.wayvec_assigned_q[dmi_idx][j]);
                  end
               end//( int j=0;j<ncore_config_pkg::ncoreConfigInfo::dmi_CmcWPReg[dmi_idx];j++
            end // if (!$test$plusargs("no_way_partitioning")              
         end:_if_way_partionning

         // Configure policies
         //DMIUSMCTCR : 
         reg_ = dmi.get_reg_by_name("DMIUSMCTCR");
         data = reg_.get_reset();
         ral_fill_field(reg_, "LookupEn",data,test_cfg.dmi_lookupen[dmi_idx]);
         ral_fill_field(reg_, "AllocEn",data,test_cfg.dmi_allocen[dmi_idx]);
         reg_.write(status,data);  
         //dmi.get_reg_by_name("DMIUSMCTCR").get_field_by_name("LookupEn").write(status, test_cfg.dmi_lookupen[dmi_idx],UVM_BACKDOOR);
         //dmi.get_reg_by_name("DMIUSMCTCR").get_field_by_name("AllocEn").write(status, test_cfg.dmi_allocen[dmi_idx],UVM_BACKDOOR);

         //DMIUSMCAPR :
         //#Check.FSYS.SMC.TOFAllocDisable
         //#Check.FSYS.SMC.ClnWrAllocDisable
         //#Check.FSYS.SMC.DtyWrAllocDisable
         //#Check.FSYS.SMC.RdAllocDisable
         //#Check.FSYS.SMC.WrAllocDisable 
         dmi.get_reg_by_name("DMIUSMCAPR").write(status, test_cfg.dmiusmc_policy);
      end:_if_cache

      // Enable Error detection to enable error correction feature by default
      //DMIUCECR :  
         reg_= dmi.get_reg_by_name("DMIUCECR");
         data=reg_.get_reset(); 
         ral_fill_field(reg_, "ErrDetEn",data,1);
         reg_.write(status,data); //dmi.get_reg_by_name("DMIUCECR").get_field_by_name("ErrDetEn").write(status,1,UVM_BACKDOOR);


       if (test_cfg.dmi_atomicDecErr) begin:_atomicDecErr 
        // Enable Softprog detection error
         //DMIUUEDR :  
         reg_= dmi.get_reg_by_name("DMIUUEDR");// enable detection
         data=reg_.get_reset(); 
         ral_fill_field(reg_, "SoftwareProgConfigErrDetEn",data,1);
         reg_.write(status,data); 
         reg_= dmi.get_reg_by_name("DMIUUEIR");// enable interrupt
         data=reg_.get_reset(); 
         ral_fill_field(reg_, "SoftwareProgConfigErrIntEn",data,1);
         reg_.write(status,data); 
       end:_atomicDecErr

      //Program QOS Event Threshold
      if (test_cfg.dmi_qos_threshold[dmi_idx] >= 0) begin
           reg_=dmi.get_reg_by_name("DMIUQOSCR0");
           data=reg_.get_reset(); 
           ral_fill_field(reg_, "EventThreshold",data,test_cfg.dmi_qos_threshold[dmi_idx]);
           reg_.write(status,data);
           //dmi.get_reg_by_name("DMIUQOSCR0").get_field_by_name("EventThreshold").write(status,test_cfg.dmi_qos_threshold[dmi_idx],UVM_BACKDOOR);
           reg_=dmi.get_reg_by_name("DMIUTQOSCR0");
           reg_.write(status,test_cfg.dmi_qos_rsved);
      end
      //disable DMI system event
         reg_= dmi.get_reg_by_name("DMIUTCR");
         data=reg_.get_reset(); 
         ral_fill_field(reg_, "EventDisable",data,test_cfg.dmi_sys_event_disable);
         reg_.write(status,data); //dmi.get_reg_by_name("DMIUCECR").get_field_by_name("ErrDetEn").write(status,1,UVM_BACKDOOR);
         data=dmi.get_reg_by_name("DMIUTCR").get_reset();
      `uvm_info("setup_init_dmi", $sformatf("End setup dmi%0d", dmi_idx), UVM_LOW)
   end:_foreach_dmi
endtask: setup_init_dmi

task concerto_boot_tasks::setup_init_dve();
    uvm_status_e status;
    uvm_reg_data_t data;
    uvm_reg_block  dve;
    queue_of_reg   regs;
    uvm_reg reg_;
    int i;
    int dve_idx;
    
   foreach (dves[dve]) begin:_foreach_dve
      dve_idx = dve.get_reg_by_name("DVEUIDR").get_field_by_name("NUnitId").get_reset();
      `uvm_info("setup_init_dve", $sformatf("Start setup dve%0d", dve_idx), UVM_LOW)
      if(test_cfg.sysco_disable) begin
         //DVEUSER0
         dve.get_reg_by_name("DVEUSER0").write(status,32'hFFFF_FFFF);     
      end
      `ifdef USE_VIP_SNPS
         //DVEUENGDBR
          //CONC-9313
         dve.get_reg_by_name("DVEUENGDBR").write(status,1);     
      `endif
      `uvm_info("setup_init_dve", $sformatf("End setup dve%0d", dve_idx), UVM_LOW)
   end:_foreach_dve
endtask: setup_init_dve

task concerto_boot_tasks::setup_init_dii();
    uvm_status_e status;
    uvm_reg_data_t data;
    uvm_reg_block  dii;
    queue_of_reg   regs;
    uvm_reg reg_;
    int i;
    int dii_idx;
    
   foreach (diis[dii]) begin:_foreach_dii
      dii_idx=dii.get_reg_by_name("DIIUIDR").get_field_by_name("NUnitId").get_reset();
      `uvm_info("setup_init_dii", $sformatf("Start setup dii%0d", dii_idx), UVM_LOW)
      //Disable sys event for DII
      reg_=dii.get_reg_by_name("DIIUTCR");
      data=reg_.get_reset(); 
      ral_fill_field(reg_, "EventDisable",data,test_cfg.dii_sys_event_disable);
      reg_.write(status,data);
      `uvm_info("setup_init_dii", $sformatf("End setup dii%0d", dii_idx), UVM_LOW)
   end:_foreach_dii
endtask: setup_init_dii

task concerto_boot_tasks::setup_init_mem();
   uvm_status_e status;
   uvm_reg_data_t data;
   uvm_reg_block  dmi,dce,ioaiu;
   queue_of_reg   regs;
   uvm_reg reg_;
   int i;
   int idx;
   uvm_path_e access;
   int init_complete;
   int mnt_op_active;
    
   `uvm_info("setup_init_mem", "Start TAG mem initalization", UVM_LOW)
   //START ALL init MEM in parallel !!! if possible!!! 
   //!!!!!!! NCAIU & DMI TAG & DATA cachemem initialization can't be run in same time !!!!
   //!!! Need 2 paths !!!
   launch_mem_maintenance(0); // ALL *MCR* register TAG mem initialisation

   `uvm_info("setup_init_mem", "Pull TAG mem Maintenance_activity bit", UVM_LOW)
   pull_mem_maintenance();  // NCAIU & DMI
   `uvm_info("setup_init_mem", "END TAG mem initalization", UVM_LOW)

    // Second path: START init MEM (only NCAIU & DMI DATA cache mem)
   `uvm_info("setup_init_mem", "START DATA mem initalization", UVM_LOW)
   data=0;
   regs =get_q_reg_by_regexpname(m_regs,"*MCR*");
   foreach (regs[reg_]) begin  // capture the ArrayId offset position
      if (reg_.get_field_by_name("ArrayID")) begin // if field exist (case without IO cache only DCE mem)
         data = 1 << reg_.get_field_by_name("ArrayID").get_lsb_pos();
         break; // ALL reg have the same position. Break after the first one
      end
   end
   launch_mem_maintenance(data,.enable_dce(1)); // ALL *MCR* register DATA mem initialisation & DCE snoop filter
   
   // Second PULL maintenance operation status of the DMI
   `uvm_info("setup_init_mem", "Pull DATA mem Maintenance_activity bit", UVM_LOW)
   pull_mem_maintenance();
   `uvm_info("setup_init_mem", "END DATA mem initalization", UVM_LOW)
endtask: setup_init_mem

task concerto_boot_tasks::setup_init_ioaiu();
   uvm_status_e status; 
   uvm_reg_data_t data;
   uvm_reg_block  ioaiu;
   queue_of_reg   regs;
   int find_idx[$];
   int do_sysco_process;
   uvm_reg reg_;
   int aiu_idx;
   int infor_ut; //xAIUINFOR.UT = 0(coh)||1(noncoh)||2(noncoh with proxy cache)
   int infor_ust;// coh:0(ace)||1(chiA)||2(chib) // noncoh: 0(AXI)||1(ACE-LITE)||2(ACE-LITE-E)

   `uvm_info("setup_init_ioaiu", "Start initalization", UVM_LOW)

   foreach (ioaius[ioaiu]) begin:_foreach_ioaiu
      // extract some info
      aiu_idx = ioaiu.get_reg_by_name("XAIUIDR").get_field_by_name("NUnitId").get_reset();
      infor_ut  = ioaiu.get_reg_by_name("XAIUINFOR").get_field_by_name("UT").get_reset();
      infor_ust = ioaiu.get_reg_by_name("XAIUINFOR").get_field_by_name("UST").get_reset();
      `uvm_info("setup_init_ioaiu", $sformatf("Start setup ioaiu AIU%0d", aiu_idx), UVM_LOW)
      
      // Enable Error detection to enable error correction feature by default
         reg_ = ioaiu.get_reg_by_name("XAIUUEDR");
         data = reg_.get_reset();
         ral_fill_field(reg_, "DecErrDetEn",data,1);
         ral_fill_field(reg_, "SoftwareProgConfigErrEn",data,1);
         ral_fill_field(reg_, "TimeoutErrDetEn",data,test_cfg.sys_event_errdeten);
         reg_.write(status,data);
              //Configure system event hadshak timeout for error testing 
         if (test_cfg.sys_event_errdeten) begin
            reg_ = ioaiu.get_reg_by_name("XAIUEHTOCR");
            data = reg_.get_reset();
            ral_fill_field(reg_, "TimeOutThreshold",data,1); //set timeout value to 1*1k
            reg_.write(status,data);
         end
      
        // Enable Error detection to enable error correction feature by default
         reg_ = ioaiu.get_reg_by_name("XAIUCECR");
         data = reg_.get_reset();
         ral_fill_field(reg_, "ErrDetEn",data,1);
         reg_.write(status,data);
         //ioaiu.get_reg_by_name("XAIUUEDR").get_field_by_name("DecErrDetEn").write(status,1,UVM_BACKDOOR);
         //ioaiu.get_reg_by_name("XAIUCECR").get_field_by_name("ErrDetEn").write(status,1,UVM_BACKDOOR);
  
         reg_ = ioaiu.get_reg_by_name("XAIUQOSCR");
         data = reg_.get_reset();
         ral_fill_field(reg_, "EventThreshold", data, test_cfg.starv_thres[aiu_idx]);
         reg_.write(status,data);

      regs =get_q_reg_by_regexpname(ioaiu,"*PCTCR*");
      foreach (regs[reg_]) begin
         // reg_.get_field_by_name("LookupEn").write(status,test_cfg.ccp_lookupen[aiu_idx],UVM_BACKDOOR); 
         // reg_.get_field_by_name("UpdateDis").write(status,test_cfg.ccp_update_cmd_disable,UVM_BACKDOOR);
         // reg_.get_field_by_name("AllocEn").write(status,test_cfg.ccp_allocen[aiu_idx],UVM_BACKDOOR);
         data=reg_.get_reset();
         ral_fill_field(reg_, "LookupEn",data,test_cfg.ccp_lookupen[aiu_idx]);
         ral_fill_field(reg_, "AllocEn",data,test_cfg.ccp_allocen[aiu_idx]);
         ral_fill_field(reg_, "UpdateDis",data,test_cfg.ccp_update_cmd_disable);
         reg_.write(status,data);
      end
      
      // TIMEOUT 
      ioaiu.get_reg_by_name("XAIUTOCR").write(status,test_cfg.ioaiu_timeout_val); // frontdoor to enable timeout


       // Begin_XAIUTCR // !!! same <data> until "End_XAIUTCR"
       // lookup the name of ioaiu is allow to process the sysco request
       // only core0 can attach with syco request
      find_idx = test_cfg.ioaius_sysco_name_a.find_first_index(item) with ( item == ioaiu.get_name());
      do_sysco_process = 0;
      if (find_idx.size()) do_sysco_process =1;
      reg_ = ioaiu.get_reg_by_name("XAIUTCR");
      data = reg_.get_reset();
      if(infor_ut == 1 || infor_ut == 2) begin // only if NCAIU
         //ioaiu.get_reg_by_name("XAIUTCR").get_field_by_name("TransOrderModeRd").write(status,test_cfg.transorder_mode[aiu_idx],UVM_BACKDOOR);
         //ioaiu.get_reg_by_name("XAIUTCR").get_field_by_name("TransOrderModeWr").write(status,test_cfg.transorder_mode[aiu_idx],UVM_BACKDOOR);
         ral_fill_field(reg_, "TransOrderModeRd",data,test_cfg.transorder_mode[aiu_idx]);
         ral_fill_field(reg_, "TransOrderModeWr",data,test_cfg.transorder_mode[aiu_idx]);
      end 
      if (m_concerto_env_cfg.sysco_implemented[aiu_idx]) begin // if sysco when AIU coh or axi+proxy or ACE-LITE (attach DVM)
         //ioaiu.get_reg_by_name("XAIUTCR").get_field_by_name("EventDisable").write(status,0,UVM_BACKDOOR);
         ral_fill_field(reg_, "EventDisable",data,0);
         if (test_cfg.sysco_disable || !do_sysco_process) begin
             //ioaiu.get_reg_by_name("XAIUTCR").get_field_by_name("SysCoDisable").write(status,1);
             ral_fill_field(reg_, "SysCoDisable",data,1);
         end else begin
            // Enable SysEvent & ATTACHED coh IOAIU
            //ioaiu.get_reg_by_name("XAIUTCR").get_field_by_name("SysCoDisable").write(status,0,UVM_BACKDOOR);
            //ioaiu.get_reg_by_name("XAIUTCR").get_field_by_name("SysCoAttach").write(status,1); //WRC reg
             ral_fill_field(reg_, "SysCoDisable",data,0);
             ral_fill_field(reg_, "SysCoAttach",data,1);
         end
      end
      reg_.write(status,data);
     // End_XAIUTCR
   end:_foreach_ioaiu

   if($test$plusargs("perf_test") && !$test$plusargs("read_test") && !$test$plusargs("write_test") ) begin
      int XAIUEDR4_rd_pct;
      int XAIUEDR4_wr_pct;

      if (!$value$plusargs("XIAUEDR4_RD=%d",XAIUEDR4_rd_pct)) begin
         XAIUEDR4_rd_pct = 30;
      end
      if (!$value$plusargs("XIAUEDR4_WR=%d",XAIUEDR4_wr_pct)) begin
         XAIUEDR4_wr_pct = 0;
      end

      foreach (ioaius[ioaiu]) begin:_foreach_ioaiu
         if (ioaiu.get_reg_by_name("XAIUIDR").get_field_by_name("MultiCoreValid").get_reset() == 0) begin
            continue;
         end
         // CONC-14268
        `uvm_info("setup_init_ioaiu", $sformatf("Start setup ioaiu AIU%0d Read transactions limit", aiu_idx), UVM_LOW)

         reg_ = ioaiu.get_reg_by_name("XAIUEDR4");
         data = reg_.get_reset();
         ral_fill_field(reg_, "RD",data,128*XAIUEDR4_rd_pct/100);
         ral_fill_field(reg_, "WR",data,128*XAIUEDR4_wr_pct/100);
         reg_.write(status,data);

      end:_foreach_ioaiu
   end
   `uvm_info("setup_init_ioaiu", "End initalization", UVM_LOW)
  
endtask: setup_init_ioaiu

task concerto_boot_tasks::setup_init_chiaiu();
   uvm_status_e status;
   uvm_reg_data_t data;
   uvm_reg_block  chi;
   queue_of_reg   regs;
   uvm_reg reg_;
   int i;
   int chi_idx;
    
   foreach (chiaius[chi]) begin:_foreach_chi
      chi_idx= chi.get_reg_by_name("CAIUIDR").get_field_by_name("NUnitId").get_reset();
      `uvm_info("setup_init_chi", $sformatf("Start setup chi AIU%0d", chi_idx), UVM_LOW)
      
      // Enable Error detection to enable error correction feature by default
      reg_ = chi.get_reg_by_name("CAIUUEDR");
      data = reg_.get_reset();
      ral_fill_field(reg_, "DecErrDetEn",data,1);
      ral_fill_field(reg_, "SoftwareProgConfigErrDetEn",data,1);
      ral_fill_field(reg_, "TimeoutErrDetEn",data,test_cfg.sys_event_errdeten);
      reg_.write(status,data);
      //chi.get_reg_by_name("CAIUUEDR").get_field_by_name("DecErrDetEn").write(status,1,UVM_BACKDOOR);

      //Configure system event hadshak timeout for error testing 
      if (test_cfg.sys_event_errdeten) begin
         reg_ = chi.get_reg_by_name("CAIUEHTOCR");
         data = reg_.get_reset();
         ral_fill_field(reg_, "TimeOutThreshold",data,1); //set timeout value to 1*1k
         reg_.write(status,data);
      end

       // Begin_CAIUTCR // !!! same <data> until "End_CAIUTCR"
      // SysEvent for CHI-AIU CAIUTCR
        reg_=chi.get_reg_by_name("CAIUTCR");
        data= reg_.get_reset();
        ral_fill_field(reg_, "EventDisable",data,0);
        if(test_cfg.sysco_disable) begin
            //chi.get_reg_by_name("CAIUTCR").get_field_by_name("SysCoDisable").write(status,1);
             ral_fill_field(reg_, "SysCoDisable",data,1);
        end else begin
            // Enable SysEvent & ATTACHED coh chi
            //chi.get_reg_by_name("CAIUTCR").get_field_by_name("SysCoDisable").write(status,0,UVM_BACKDOOR);
            //chi.get_reg_by_name("CAIUTCR").get_field_by_name("SysCoAttach").write(status,1); //WRC reg
             ral_fill_field(reg_, "SysCoDisable",data,0);
// #Stimulus.FSYS.misc.CHI_B.CAIUTCR.SysCoAttach
// #Stimulus.FSYS.misc.CHI_E.CAIUTCR.SysCoAttach
             
             if(test_cfg.en_chiaiu_coherency_via_reg) begin
                 ral_fill_field(reg_, "SysCoAttach",data,1);
             end
         // use syco_req pin to connect the chi wiht m_chi<%=idx%>_vseq.construct_sysco_seq(chiaiu<%=idx%>_chi_agent_pkg::CONNECT)
         //    ral_fill_field(reg_, "SysCoAttach",data,0);
        end
      reg_.write(status,data);
      // End_CAIUTCR 
   
      // TIMEOUT 
      chi.get_reg_by_name("CAIUTOCR").write(status,test_cfg.chiaiu_timeout_val);
      
      // QOSTHRESHOLD
      chi.get_reg_by_name("CAIUQOSCR").write(status,test_cfg.aiu_qos_threshold[test_cfg.aiu_qos_offset[chi_idx]]);

   end:_foreach_chi
endtask: setup_init_chiaiu

task concerto_boot_tasks::pull_sysco_attached();
   uvm_status_e status;
   queue_of_reg   regs;
   uvm_reg reg_;
   uvm_path_e access;
   int sysattach_complete;
   int sysco_attached;
   int aiu_idx;
   uvm_reg  q_regs_sysco_finished[$];
   int find_idx[$];  
   int do_sysco_process; 
   
   // Check the attached state: ALL attach was sent in parallel
   begin:_check_attach
      `uvm_info("pull_sysco_attached", "check_sysco_attached bit", UVM_LOW)
      do begin:_do_pull_sysco
         sysattach_complete = 1;
         regs = get_q_reg_by_regexpname(m_regs,"*AIUTAR*"); 
         foreach (regs[reg_]) begin:_foreach_aiu_sysco
              // lookup the name of ioaiu is allow to process the sysco request
              // only core0 can attach with syco request
              do_sysco_process =0;
              find_idx = test_cfg.ioaius_sysco_name_a.find_first_index(item) with ( item == reg_.get_parent().get_name());
              if (find_idx.size()) do_sysco_process=1; 
              find_idx = test_cfg.chiaius_name_a.find_first_index(item) with ( item == reg_.get_parent().get_name());
              if (find_idx.size()) do_sysco_process=1; 
              if (!do_sysco_process) continue; 

             aiu_idx = reg_.get_parent().get_field_by_name("NUnitId").get_reset();
             if (m_concerto_env_cfg.sysco_implemented[aiu_idx]) begin:_if_syscoattach_implemented  // if sysco when AIU coh or axi+proxy or ACE-LITE (attach DVM)
                  int already_finished[$] =  q_regs_sysco_finished.find_first_index with (item == reg_);
                  if (already_finished.size()) continue; // sysco already finished read next register
                  reg_.get_field_by_name("SysCoAttached").read(status,sysco_attached);
                  if (!sysco_attached) begin 
                     sysattach_complete = 0; // if one IO no attached pull isn't finished
                  end else begin
                     q_regs_sysco_finished.push_back(reg_);
                  end 
            end:_if_syscoattach_implemented
         end:_foreach_aiu_sysco
      end:_do_pull_sysco while (!sysattach_complete);
      test_cfg.ev_all_aiu_sysco_attached.trigger();
     `uvm_info("pull_sysco_attached", "END check_sysco_attached bit", UVM_LOW)
   end:_check_attach
endtask:pull_sysco_attached
////////////////////////////////////////////////
//#######
//   #      ####    ####   #        ####
//   #     #    #  #    #  #       #
//   #     #    #  #    #  #        ####
//   #     #    #  #    #  #            #
//   #     #    #  #    #  #       #    #
//   #      ####    ####   ######   ####
////////////////////////////////////////////////
task concerto_boot_tasks::launch_mem_maintenance(uvm_reg_data_t data, bit enable_dce=0);
   uvm_status_e status;
   queue_of_reg   regs;
   uvm_reg reg_;
   regs = get_q_reg_by_regexpname(m_regs,"*MCR*"); // if doesn't exist do nothing
   foreach (regs[reg_]) begin
      if (!uvm_re_match(uvm_glob_to_re("*DCE*"),reg_.get_name())) begin 
         if (enable_dce) begin 
            reg_.write(status,data);      
         end
      end else begin
         reg_.write(status,data);      
      end
   end   
endtask:launch_mem_maintenance

task concerto_boot_tasks::pull_mem_maintenance();
   uvm_status_e status;
   uvm_reg_data_t data;
   queue_of_reg   regs;
   uvm_reg reg_;
   int init_complete;
   int mnt_op_active;
   uvm_reg  q_regs_mnt_finished[$];
   
   // PULL ALL the maintenance operation status
   do begin:_do_pull
      init_complete = 1;
      #200ns; // reduce the  unuseful txn in the apb bus
      regs = get_q_reg_by_regexpname(m_regs,"*MAR*"); // if doesn't exist do nothing
      foreach (regs[reg_]) begin
         int already_finished[$] =  q_regs_mnt_finished.find_first_index with (item == reg_);
         if (already_finished.size()) continue; // maintenance already finished read next register
         reg_.get_field_by_name("MntOpActv").read(status,mnt_op_active);
         if (mnt_op_active) begin 
            init_complete = 0; // if one mem no complete pull isn't finished
         end else begin
            q_regs_mnt_finished.push_back(reg_);
         end
      end 
    end:_do_pull while (!init_complete);
endtask:pull_mem_maintenance
