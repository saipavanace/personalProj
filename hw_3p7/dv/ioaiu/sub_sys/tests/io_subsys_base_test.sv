<%
var aiu_rpn = []; 
var numIoAiu = 0; 
for(var pidx = 0; pidx < obj.nAIUs; pidx++) {
    if(!obj.AiuInfo[pidx].fnNativeInterface.match("CHI")) {
        if (obj.AiuInfo[pidx].nNativeInterfacePorts > 1) {
            aiu_rpn[pidx]= obj.AiuInfo[pidx].rpn[0];
        } else { 
            aiu_rpn[pidx]= obj.AiuInfo[pidx].rpn;
        }
        for(var i=0; i<obj.AiuInfo[pidx].nNativeInterfacePorts; i++) {
           numIoAiu++ ; 
        }
    }
 }
%>

`ifdef USE_VIP_SNPS // Now using this test for synopsys vip sim
class io_subsys_base_test extends concerto_fullsys_test;
    `uvm_component_utils(io_subsys_base_test)
    static string inst_name="";
    addr_trans_mgr m_addr_mgr;

    function new(string name = "io_subsys_base_test", uvm_component parent = null);
        super.new(name, parent);
        if(inst_name=="")
            inst_name=name;
            m_addr_mgr = addr_trans_mgr::get_instance();
    endfunction: new

    function void build_phase(uvm_phase phase);
        `uvm_info("IO_SUBSYS_BASE_TEST", "Enter BUILD_PHASE", UVM_LOW);
        super.build_phase(phase);
        `uvm_info("IO_SUBSYS_BASE_TEST", "Exit BUILD_PHASE", UVM_LOW);
    endfunction: build_phase

    function void end_of_elaboration_phase(uvm_phase phase);
        `uvm_info("IO_SUBSYS_BASE_TEST", "Enter END_OF_ELABORATION_PHASE", UVM_LOW);
        
        super.end_of_elaboration_phase(phase);
        
        configure_mstr_seqs();
        if (this.get_report_verbosity_level() >= UVM_LOW) begin
            //uvm_top.print_topology();
        end
  
        `uvm_info("IO_SUBSYS_BASE_TEST", "Exit END_OF_ELABORATION_PHASE", UVM_LOW);
        //`uvm_error("IO_SUBSYS_BASE_TEST", "End to debug");
    endfunction: end_of_elaboration_phase
    
    function void start_of_simulation_phase(uvm_phase phase);

        `uvm_info("IO_SUBSYS_BASE_TEST", "Enter START_OF_SIMULATION_PHASE", UVM_LOW);
        
        super.start_of_simulation_phase(phase);
        if ($test$plusargs("use_user_addrq") && !test_cfg.k_access_boot_region) begin:_use_user_addrq
            gen_addr_use_user_addrq();
        end:_use_user_addrq
        if ($test$plusargs("use_user_noncoh_addrq")&& !test_cfg.k_access_boot_region) begin
                  gen_noncoh_addr_use_user_addrq();
        end

        apply_vseq_overrides();
        `uvm_info("IO_SUBSYS_BASE_TEST", "End START_OF_SIMULATION_PHASE", UVM_LOW);
    
    endfunction: start_of_simulation_phase
    
    task run_phase(uvm_phase phase);
        `uvm_info("IO_SUBSYS_BASE_TEST", "Enter RUN_PHASE", UVM_LOW);

        super.run_phase(phase);
        `uvm_info("IO_SUBSYS_BASE_TEST", "Exit RUN_PHASE", UVM_LOW);
    endtask: run_phase

    task exec_inhouse_seq(uvm_phase phase);
        
        phase.raise_objection(this, "io_subsys_base_test");
        csr_init_done.trigger(null);
        #100ns
        start_sequence();
        phase.drop_objection(this, "io_subsys_base_test");
    endtask: exec_inhouse_seq

    virtual task start_sequence();
        
    endtask: start_sequence

    function void configure_mstr_seqs();
        //`uvm_info("IO_SUBSYS_BASE_TEST", "configure master sequence configs", UVM_LOW);
        int seq_id;
        foreach(addrMgrConst::io_subsys_nativeif_a[i]) begin 
            //`uvm_info("IO_SUBSYS_BASE_TEST", $psprintf("create master sequence configs for master:%0d nativeif:%0s instname:%0s", i, addrMgrConst::io_subsys_nativeif_a[i].tolower(), addrMgrConst::io_subsys_instname_a[i]), UVM_LOW);
            io_subsys_mstr_seq_cfg_a[i] = io_mstr_seq_cfg::type_id::create($psprintf("%0s_%0s_mstr_seq_cfg_p%0d_s%0d", addrMgrConst::io_subsys_nativeif_a[i].tolower(), addrMgrConst::io_subsys_instname_a[i], i,seq_id));
            io_subsys_mstr_seq_cfg_a[i].init_master_info(addrMgrConst::io_subsys_nativeif_a[i].tolower(), addrMgrConst::io_subsys_instname_a[i], addrMgrConst::io_subsys_funitid_a[i]);
            uvm_config_db #(mstr_seq_cfg)::set(this ,"m_concerto_env.snps.svt.amba_system_env.axi_system[0]*", $sformatf("%0s_%0s_mstr_seq_cfg_p%0d_s%0d", addrMgrConst::io_subsys_nativeif_a[i].tolower(), addrMgrConst::io_subsys_instname_a[i], i,seq_id), io_subsys_mstr_seq_cfg_a[i]);
        end 
            
    endfunction:configure_mstr_seqs;

    virtual task gen_addr_use_user_addrq();
        longint addr;
        bit [addrMgrConst::W_SEC_ADDR -1: 0] uaddrq[$];
        addrMgrConst::mem_type get_coh_noncoh_type;
        int num_set,core_id;
        int num_addr_per_ioc;
        int num_addr_per_set;
        bit usecache='b1;
        int reduce_mem_size;
        int idx_w,ccp_setindex;
        string instname;
        string core_str_tmp, core_str;
        addrMgrConst::atomic_addrq = {};
        `uvm_info("IO_SUBSYS_BASE_TEST", $psprintf("fn:gen_addr_use_user_addrq size:%0d",addrMgrConst::user_addrq[addrMgrConst::COH].size()), UVM_LOW);

        if($test$plusargs("constrain_ioc_set_index") && addrMgrConst::NUM_IOC !=0 ) begin
           foreach (addrMgrConst::ioc_set_idx_w[i]) begin  //looping through each IOC
               idx_w=addrMgrConst::ioc_set_idx_w[i];
               num_set= $urandom_range(3,6);  
               //`uvm_info("IO_SUBSYS_BASE_TEST", $psprintf("fn:gen_addr_use_user_addrq idx_w:%0d num_set:%0d", addrMgrConst::ioc_set_idx_w[i],num_set), UVM_LOW);
               for(int j=1;j<=num_set;j++) begin 
                   ccp_setindex=$urandom_range((1 << idx_w)-1,0);
                   //num_addr_per_set = num_addr_per_ioc/num_set;
                   num_addr_per_set = (addrMgrConst::ioc_nWay[i]+ (addrMgrConst::ioc_nWay[i]/2));
                   get_coh_noncoh_type=addrMgrConst::COH_DMI;
                   uaddrq={};
                   //`uvm_info("IO_SUBSYS_BASE_TEST", $psprintf("fn:gen_addr_use_user_addrq ccp_setindex:%0d num_addr_per_set:%0d", ccp_setindex,num_addr_per_set), UVM_LOW);
                   instname=addrMgrConst::io_subsys_instname_a[addrMgrConst::ioc_mstr_idx[i]];
                   core_str_tmp  = instname.substr(instname.len()-3, instname.len()-1); 
                   if (core_str_tmp inside {"_c0", "_c1", "_c2", "_c3"}) begin 
                       core_str = core_str_tmp.substr(core_str_tmp.len()-1, core_str_tmp.len()-1);
                       core_id = core_str.atoi();
                   end else begin 
                       core_id = 0;
                   end
                   //`uvm_info("IO_SUBSYS_BASE_TEST", $psprintf("fn:gen_addr_use_user_addrq ioc_mstr_idx:%0d instname:%0s core_str_tmp:%0s core_id :%0d funitid:%0d", addrMgrConst::ioc_mstr_idx[i],instname,core_str_tmp,core_id,addrMgrConst::io_subsys_funitid_a[addrMgrConst::ioc_mstr_idx[i]]), UVM_LOW);

                   m_addr_mgr.get_addrq_w_fix_set_index(ccp_setindex,addrMgrConst::io_subsys_funitid_a[addrMgrConst::ioc_mstr_idx[i]],core_id,num_addr_per_set,uaddrq,get_coh_noncoh_type,usecache);
                   for(int k=0; k<uaddrq.size();k++) begin
                       addrMgrConst::user_addrq[addrMgrConst::COH].push_back(uaddrq[k]);
                       //`uvm_info("IO_SUBSYS_BASE_TEST", $psprintf("fn:gen_addr_use_user_addrq uaddrq[k]:%0h", uaddrq[k]), UVM_LOW);
                       if (addr_trans_mgr::allow_atomic_txn_with_addr(uaddrq[k]) == 1) begin
                           addrMgrConst::atomic_addrq.push_back(uaddrq[k] >> 6);
                       end
                   end
               end
              //`uvm_info("IO_SUBSYS_BASE_TEST", $psprintf("fn:gen_addr_use_user_addrq done populating size:%0d num_addr_per_ioc:%0d", addrMgrConst::user_addrq[addrMgrConst::COH].size(),num_addr_per_ioc), UVM_LOW);
           end   
        end else begin
        foreach (addrMgrConst::memregions_info[region]) begin:_foreach_memregions
            if (addrMgrConst::is_dmi_addr(addrMgrConst::memregions_info[region].start_addr) && 
                !addrMgrConst::get_addr_gprar_nc(addrMgrConst::memregions_info[region].start_addr)) begin 
                addr = addrMgrConst::memregions_info[region].start_addr;
                for(int i=0; i< test_cfg.reduce_mem_size; i++) begin
                    addrMgrConst::user_addrq[addrMgrConst::COH].push_back(addr);
                    if (addr_trans_mgr::allow_atomic_txn_with_addr(addr) == 1) begin
                        addrMgrConst::atomic_addrq.push_back(addr >> <%=obj.wCacheLineOffset%>);
                    end
                    addr += (1<< <%=obj.wCacheLineOffset%>);
                    if (addr >= addrMgrConst::memregions_info[region].end_addr) begin 
                        break;
                    end
                end
                break;
            end
        end: _foreach_memregions
       
        end
        `uvm_info("IO_SUBSYS_BASE_TEST", $psprintf("fn:gen_addr_use_user_addrq done populating size:%0d ", addrMgrConst::user_addrq[addrMgrConst::COH].size()), UVM_LOW);
    

    endtask: gen_addr_use_user_addrq
    virtual task gen_noncoh_addr_use_user_addrq();
    longint addr;
        int reduce_mem_size;
        addrMgrConst::atomic_addrq = {};
       foreach (addrMgrConst::memregions_info[region]) begin:_foreach_memregions
          if (((addrMgrConst::is_dii_addr(addrMgrConst::memregions_info[region].start_addr))||
               (addrMgrConst::is_dmi_addr(addrMgrConst::memregions_info[region].start_addr) && 
               addrMgrConst::get_addr_gprar_nc(addrMgrConst::memregions_info[region].start_addr)))) begin 
                addr = addrMgrConst::memregions_info[region].start_addr;
               for(int i=0; i< 20; i++) begin
                   addrMgrConst::user_addrq[addrMgrConst::NONCOH].push_back(addr);
                   if (addr_trans_mgr::allow_atomic_txn_with_addr(addr) == 1) begin
                       addrMgrConst::atomic_addrq.push_back(addr >> <%=obj.wCacheLineOffset%>);
                   end
                   addr += (1<< <%=obj.wCacheLineOffset%>);
                   if (addr >= addrMgrConst::memregions_info[region].end_addr) begin 
                       break;
                   end
               end
               break;
          end
       end: _foreach_memregions
       `uvm_info("IO_SUBSYS_BASE_TEST", $psprintf("fn:gen_noncoh_addr_use_user_addrq done populating size:%0d Queue element %0p ", addrMgrConst::user_addrq[addrMgrConst::NONCOH].size(),addrMgrConst::user_addrq[addrMgrConst::NONCOH]), UVM_LOW);
     endtask: gen_noncoh_addr_use_user_addrq

    function apply_vseq_overrides;
        string vseq;
        if ($value$plusargs("vseq=%0s", vseq)) begin
            if (vseq == "pcie_vseq") begin
                io_subsys_snps_vseq::type_id::set_type_override(io_subsys_snps_pcie_vseq::get_type());
            end
            if(vseq== "stash_vseq") begin
                io_subsys_snps_vseq::type_id::set_type_override(io_subsys_stash_stress_vseq::get_type());
            end
        end
    endfunction: apply_vseq_overrides
endclass:io_subsys_base_test
`endif //USE_VIP_SNPS Now using this test for synopsys vip sim
