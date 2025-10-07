
`include "base_test.sv"
<% var SMC_mntop_seqs = [
        "ioaiu_csr_flush_all_seq",
        "ioaiu_csr_flush_by_addr_range_seq",
        "ioaiu_csr_flush_by_addr_seq",
        "ioaiu_csr_flush_by_index_way_range_seq",
        "ioaiu_csr_time_out_error_seq",
        "ioaiu_csr_flush_by_index_way_seq",
        "ioaiu_ccp_offline_seq",
        "ioaiu_csr_run_all_type_flush_seq"
    ];

    var mntop_debug_read_write_seqs = [
        "ioaiu_csr_elr_seq",
        "ioaiu_csr_CMO_test_seq"
    ];

    /*
        var SMC_mntop_seqs = [
            "ioaiu_csr_flush_all_seq",
            "ioaiu_csr_flush_entry_at_set_way_seq",
            "ioaiu_csr_flush_by_addr_seq"
        ];
    */
     //all csr sequences
    var csr_seqs = [
        "ioaiu_csr_cfg_ccp_seq",
        "ioaiu_csr_uuedr_MemErrDetEn_seq",
        "ioaiu_csr_uueir_MemErrInt_seq",
        "ioaiu_csr_cecr_errInt_seq",
        "io_aiu_csr_caiuuedr_TransErrDetEn_seq",
        "io_aiu_csr_caiuuedr_TransCorrErrDetEn_seq",
        "io_aiu_csr_uuedr_ProtErrDetEn_seq",
        "ioaiu_csr_ucecr_errDetEn_seq",
        "ioaiu_csr_ucecr_errThd_seq",
        "ioaiu_csr_ucecr_sw_write_seq",
        "ioaiu_csr_uuecr_sw_write_seq",
        "ioaiu_csr_ucecr_noDetEn_seq",
        "ioaiu_csr_elr_seq",
        "ioaiu_csr_address_region_overlap_seq",
        "ioaiu_csr_illegal_security_nsaccess",
        "ioaiu_csr_illegal_dii_access",
        "ioaiu_csr_no_address_hit_seq",
        "ioaiu_csr_ucecr_noIntEn_seq",
        "ioaiu_csr_time_out_error_seq",
        "always_inject_error",
        "ioaiu_csr_prot_cecr_errThd_seq",
        "ioaiu_corr_errint_check_through_xaiucesar_seq",
        "ioaiu_timeout_errint_check_through_xaiuuesar_seq",
        "ioaiu_csr_xaiucesar_seq",
        "ioaiu_csr_xaiucctrlr_seq",
        "ioaiu_csr_xaiutbalr0_seq",
        "ioaiu_csr_xaiutbahr0_seq",
        "ioaiu_csr_xaiutctrlr0_seq",
        "ioaiu_csr_xaiutopcr0_seq",
        "ioaiu_csr_xaiutubr0_seq",
        "ioaiu_csr_xaiutubmr0_seq",
        "ioaiu_csr_xaiuuesar_seq",
        "ioaiu_csr_credit_adjustment_seq",
        "ioaiu_chk_proxy_cache_initial_done_seq",
        "ioaiu_starv_en_chk_seq",
        "access_unmapped_csr_addr",
        "set_max_errthd",
        "ioaiu_csr_trace_debug_seq",
        "ioaiu_csr_sysreq_event_seq",
        "csr_connectivity_seq",
        "csr_credit_sw_mgr_seq",
        "ioaiu_interface_parity_detection_seq",
        "ioaiu_csr_PlruErrInject_seq",
        "csr_scm_negative_state_seq"
    ];%>

class bring_up_test extends base_test;

    `uvm_component_utils(bring_up_test)

    axi_memory_model m_axi_memory_model;
    uvm_event         e_agent_isolation_mode_complete;
    uvm_reg_sequence csr_seq[<%=obj.DutInfo.nNativeInterfacePorts%>];
    uvm_reg_sequence smc_mntop_csr_seq[<%=obj.DutInfo.nNativeInterfacePorts%>];
    uvm_reg_sequence mntop_debug_read_write_seq[<%=obj.DutInfo.nNativeInterfacePorts%>];
    //io_aiu_default_reset_seq default_seq[<%=obj.DutInfo.nNativeInterfacePorts%>];
    <%for ( let i=0; i<obj.DutInfo.nNativeInterfacePorts; i++) {%>
        io_aiu_default_reset_seq_<%=i%> default_seq_<%=i%>;
    <%}%>
    ioaiu_csr_attach_seq_0     sysco_attach_seq;
    ral_csr_base_seq         prog_seq;
    ioaiu_write_bw_seq write_bw_seq;

    int clk_count_en;           // Use for CCTRLR update scenario

    uvm_event_pool ev_pool = uvm_event_pool::get_global_pool();
    uvm_event ev_default_seq_en_test;
    <%for ( let i=0; i<obj.DutInfo.nNativeInterfacePorts; i++) {%>
    uvm_event ev_random_traffic_done_<%=i%> = ev_pool.get("ev_random_traffic_done_<%=i%>");
    <%}%>
    uvm_event ev_stop_txns_issue = ev_pool.get("ev_stop_txns_issue");
    `ifdef USE_VIP_SNPS  
        //snps_axi_master_pipelined_seq cust_seq_h;
        io_subsys_base_seq axi_mstr_seq;
        mstr_seq_cfg io_subsys_mstr_seq_cfg_a[`NUM_IOAIU_SVT_MASTERS]; 
        bit aiu_scb_en;
        uvm_event ev_snoop_rsp = ev_pool.get("ev_snoop_rsp");
        <%if(obj.testBench == "io_aiu" && obj.DutInfo.nNativeInterfacePorts == 1 && obj.DutInfo.interfaces.axiInt.params.checkType == 'ODD_PARITY_BYTE_ALL') { %>
            uvm_event wait_for_chk_en_test; 
        <%}%>
    `endif
    `ifndef USE_VIP_SNPS  
        axi_master_pipelined_seq m_master_pipelined_seq[<%=obj.DutInfo.nNativeInterfacePorts%>];
              //sys_event agent seq
        <% if(obj.AiuInfo[obj.Id].interfaces.eventRequestOutInt._SKIP_ == false || obj.AiuInfo[obj.Id].interfaces.eventRequestInInt._SKIP_ == false) { %>
           <%=obj.BlockId%>_event_agent_pkg::event_seq  m_<%=obj.BlockId%>_event_seq;
        <% } %> 
    `endif
   
        // This event triggers if any request is killed when injecting errors
        // to drop all objections and get out of run_phase, resolves hanging tests issue
        uvm_object objectors_list[$];
        uvm_objection objection;
        `ifndef VCS
         event kill_test;
        `else // `ifndef VCS
         uvm_event kill_test;
        `endif // `ifndef VCS

    <%if(obj.useResiliency){%>
        <%if(obj.testBench != "fsys"){%>
            /*
            *demote handle to suppress any error coming for the resiliency 
            *testing. error form the fault_injector_checker will show, but
            *others will be converted to info
            */
            report_catcher_demoter_base fault_injector_checker_demoter_h;
        <%}%>
    <%}%>
    string pcie_test = "";
    function new(string name = "bring_up_test", uvm_component parent=null);
        super.new(name,parent); 
    endfunction: new 

    virtual function void build_phase(uvm_phase phase);
        string  arg_value;
        <%if((obj.useResiliency) && (obj.testBench != "fsys")){%>
            if($test$plusargs("collect_resiliency_cov")) begin
            set_type_override_by_type(.original_type(<%=obj.BlockId%>_smi_agent_pkg::smi_coverage::get_type()), .override_type(smi_resiliency_coverage::get_type()), .replace(1));
            end
        <%}%>
        `ifdef USE_VIP_SNPS
        set_type_override_by_type(svt_axi_master_transaction::get_type(),io_subsys_axi_master_transaction::get_type());
        set_type_override_by_type(svt_axi_master_snoop_transaction::get_type(),io_subsys_ace_master_snoop_transaction::get_type());
        <%if(obj.DutInfo.fnNativeInterface === "ACELITE-E" || obj.DutInfo.fnNativeInterface === "ACE5"){%>
        set_type_override_by_type(io_subsys_base_seq::get_type(),io_subsys_ace_seq::get_type());
        <%}%>
       <%if(obj.DutInfo.fnNativeInterface === "AXI5"){%>
        set_type_override_by_type(io_subsys_base_seq::get_type(),io_subsys_axi_seq::get_type());
        <%}%>
      
     `uvm_info("BRING_UP_TEST",$psprintf("fn:build_phase Override svt_axi_master_transaction by io_subys_axi_master_transaction"),UVM_LOW)
        `endif
        super.build_phase(phase);
            //set_type_override_by_type(ioaiu_scoreboard::get_type(), ioaiu_ccp_scoreboard::get_type());
        
        <%if(obj.DutInfo.useCache){%>
            if($test$plusargs("ioc_fill_seq")) begin
    	        set_type_override_by_type(axi_master_pipelined_seq::get_type(), ioc_fill_seq::get_type());
            end
            if($test$plusargs("ioc_stream_of_hits_seq")) begin
    	        set_type_override_by_type(axi_master_pipelined_seq::get_type(),ioc_stream_of_hits_seq::get_type());
            end
            if($test$plusargs("ioc_wrhit_upg_w_rd_seq")) begin
    	        set_type_override_by_type(axi_master_pipelined_seq::get_type(),ioc_wrhit_upg_w_rd_seq::get_type());
            end
            if($test$plusargs("seq_single_write_multi_read")) begin
    	        set_type_override_by_type(axi_master_pipelined_seq::get_type(),seq_single_write_multi_read::get_type());
            end
             if($test$plusargs("seq_single_read_multi_write")) begin
    	        set_type_override_by_type(axi_master_pipelined_seq::get_type(),seq_single_read_multi_write::get_type());
            end

            if($test$plusargs("eviction_seq")) begin
    	        set_type_override_by_type(axi_master_pipelined_seq::get_type(), eviction_seq::get_type()); 
            end
           if($test$plusargs("ioc_stream_of_alloc_ops_some_sets_seq")) begin
        	set_type_override_by_type(axi_master_pipelined_seq::get_type(), ioc_stream_of_alloc_ops_some_sets::get_type()); 
            end

            if($test$plusargs("force_nonallocate_txn")) begin
    	        set_type_override_by_type(axi_master_pipelined_seq::get_type(), nonallocate_seq::get_type()); 
            end
                        
        <%}%>

            uvm_config_db#(ioaiu_env)::set(this,"*","env_handle",mp_env.m_env[0]);
        <%if(!obj.PSEUDO_SYS_TB){%>
            m_axi_memory_model = new();
        <%}%>
        //instantiate the csr seq
        <%if(obj.INHOUSE_APB_VIP){%>
            <%for(let i = 0; i < obj.DutInfo.nNativeInterfacePorts; i++){%>
                default_seq_<%=i%> = io_aiu_default_reset_seq_<%=i%>::type_id::create("default_seq_<%=i%>");
                default_seq_<%=i%>.coreId = <%=i%>;
            <%}%>
            sysco_attach_seq = ioaiu_csr_attach_seq_0::type_id::create("sysco_attach_seq");
            if(clp.get_arg_value("+wt_illegal_op_addr=", arg_value) && arg_value.atoi() > 0) begin
                <%for(let i = 0; i < obj.DutInfo.nNativeInterfacePorts; i++){%>
                    default_seq_<%=i%>.en_XAIUUEDR_DecErrDetEn = 1;
                <%}%>
            end
            //Set up TransOrderMode
            <%for(let i = 0; i < obj.DutInfo.nNativeInterfacePorts; i++){%>
                default_seq_<%=i%>.dvm_resp_order = this.dvm_resp_order;
                default_seq_<%=i%>.tctrlr  = this.tctrlr;
            <%}%>
            <% if (obj.DutInfo.useCache) {%>
                //legacy set to 1 TODO randomize ?
                <%for(let i = 0; i < obj.DutInfo.nNativeInterfacePorts; i++){%>
                    if(!($value$plusargs("ccp_lookupen=%0d",default_seq_<%=i%>.ccp_lookupen))) begin
                        default_seq_<%=i%>.ccp_lookupen  = 1;
                    end
                <%}%>
                <%for(let i = 0; i < obj.DutInfo.nNativeInterfacePorts; i++){%>
                    if(!($value$plusargs("ccp_allocen=%0d",default_seq_<%=i%>.ccp_allocen))) begin
                            default_seq_<%=i%>.ccp_allocen   = 1;
                    end
                <%}%>

            <%}%>
            <%for(let i = 0; i < obj.DutInfo.nNativeInterfacePorts; i++){%>
                default_seq_<%=i%>.topcr0  = this.topcr0;
                default_seq_<%=i%>.topcr1  = this.topcr1;
                default_seq_<%=i%>.tubr  = this.tubr;
                default_seq_<%=i%>.tubmr = this.tubmr;
            <%}%>
            
           <% if(obj.testBench == 'io_aiu') { %>
           `ifndef VCS
            if (k_csr_seq) begin
           `else // `ifndef VCS
            if (k_csr_seq != "") begin
           `endif // `ifndef VCS ... `else ... 
           <% } else {%>
            if (k_csr_seq) begin
           <% } %>
                <%for(i in csr_seqs){%>
                    if (k_csr_seq == "<%=csr_seqs[i]%>") begin
                        <%for (let j=0; j<obj.DutInfo.nNativeInterfacePorts; j++) {%>
                            csr_seq[<%=j%>] = <%=csr_seqs[i]%>_<%=j%>::type_id::create("csr_seq_<%=j%>");
                        <%}%>
                    end
                <%}%>
            end
            <%if(obj.DutInfo.useCache){%>
               <% if(obj.testBench == 'io_aiu') { %>
               `ifndef VCS
                if (k_csr_SMC_mntop_seq) begin
               `else // `ifndef VCS
                if (k_csr_SMC_mntop_seq != "") begin
               `endif // `ifndef VCS ... `else ... 
               <% } else {%>
                if (k_csr_SMC_mntop_seq) begin
               <% } %>
                    <%for(i in SMC_mntop_seqs){%>
                        if (k_csr_SMC_mntop_seq == "<%=SMC_mntop_seqs[i]%>") begin
                            <%for (let j=0; j<obj.DutInfo.nNativeInterfacePorts; j++) {%>
                                smc_mntop_csr_seq[<%=j%>] = <%=SMC_mntop_seqs[i]%>_<%=j%>::type_id::create("smc_mntop_csr_seq_<%=j%>");
                            <%}%>
                        end
                    <%}%>
                end
            <%}%>
            <%if(obj.DutInfo.useCache){%>
               <% if(obj.testBench == 'io_aiu') { %>
               `ifndef VCS
                if (k_mntop_debug_read_write_seq) begin
               `else // `ifndef VCS
                if (k_mntop_debug_read_write_seq != "") begin
               `endif // `ifndef VCS ... `else ... 
               <% } else {%>
                if (k_mntop_debug_read_write_seq) begin
               <% } %>
                    <%for(i in mntop_debug_read_write_seqs){%>
                        if(k_mntop_debug_read_write_seq == "<%=mntop_debug_read_write_seqs[i]%>") begin
                            <%for (let j=0; j<obj.DutInfo.nNativeInterfacePorts; j++) {%>
                                mntop_debug_read_write_seq[<%=j%>] = <%=mntop_debug_read_write_seqs[i]%>_<%=j%>::type_id::create("mntop_debug_read_write_seq_<%=j%>"); 
                            <%}%>
                        end
                    <%}%>
                end
            <%}%>
        <%}%>

        <%if(obj.useResiliency){%>
            <%if(obj.testBench != "fsys"){%>
                if($test$plusargs("expect_mission_fault")) begin
                   fault_injector_checker_demoter_h = report_catcher_demoter_base::type_id::create("fault_injector_checker_demoter_h");
                   fault_injector_checker_demoter_h.exp_id = {"fault_injector_checker"};
                    if($test$plusargs("test_placeholder_connectivity")) begin
                      fault_injector_checker_demoter_h.exp_id.push_back("placeholder_connectivity_checker");
                    end
                    if($test$plusargs("expect_mission_fault")) begin
                        fault_injector_checker_demoter_h.demote_uvm_fatal = 1;
                        fault_injector_checker_demoter_h.demote_uvm_error = 0;
                    end
                     fault_injector_checker_demoter_h.not_of = 1;
                    fault_injector_checker_demoter_h.build();
                    `uvm_info(get_name(), $sformatf("Registering demoter class{%0s} for resiliency error ignore", fault_injector_checker_demoter_h.get_name()), UVM_LOW)
                    uvm_report_cb::add(null, fault_injector_checker_demoter_h);
                end
            <%}%>
       <%}%>
        `ifdef USE_VIP_SNPS  
            //override the base test default sequence
            //uvm_config_db#(uvm_object_wrapper)::set(this, 
            //                                        "env.axi_system_env.sequencer.main_phase", 
            //                                        "default_sequence", 
            //                                        cust_seq::type_id::get());

            //uvm_config_db#(int unsigned)::set(this, 
            //                                  "env.axi_system_env.sequencer.cust_seq", 
            //                                  "sequence_length", 
            //                                  10);
            //cust_seq_h = snps_axi_master_pipelined_seq::type_id::create("cust_seq_h");
            //cust_seq_h.m_ace_cache_model = m_ace_cache_model[0];
            axi_mstr_seq = io_subsys_base_seq::type_id::create("axi_mstr_seq");
            if(!($value$plusargs("aiu_scb_en=%0d",aiu_scb_en))) begin
              aiu_scb_en=1;
            end
        `endif
    endfunction : build_phase

function void end_of_elaboration_phase(uvm_phase phase);
  `ifdef USE_VIP_SNPS 
    super.end_of_elaboration_phase(phase);
  `endif
    `uvm_info("end_of_elaboration_phase", "Entered...", UVM_LOW)
        uvm_top.print_topology();
    `uvm_info("end_of_elaboration_phase", "Exiting...", UVM_LOW)
endfunction: end_of_elaboration_phase

 function void configure_ioaiu_mstr_seqs();
`ifdef USE_VIP_SNPS
  int seq_id;
  foreach(io_subsys_mstr_seq_cfg_a[i]) begin 
      io_subsys_mstr_seq_cfg_a[i] = io_mstr_seq_cfg::type_id::create($psprintf("%0s_%0s_mstr_seq_cfg_p%0d_s%0d", addrMgrConst::io_subsys_nativeif_a[i].tolower(), addrMgrConst::io_subsys_instname_a[i], i,seq_id));
      io_subsys_mstr_seq_cfg_a[i].init_master_info(addrMgrConst::io_subsys_nativeif_a[i].tolower(), addrMgrConst::io_subsys_instname_a[i], addrMgrConst::io_subsys_funitid_a[i]); 
      uvm_config_db #(mstr_seq_cfg)::set(null ,"*", $sformatf("%0s_%0s_mstr_seq_cfg_p%0d_s%0d", addrMgrConst::io_subsys_nativeif_a[i].tolower(), addrMgrConst::io_subsys_instname_a[i], i,seq_id), io_subsys_mstr_seq_cfg_a[i]);
  end 
 `endif
endfunction:configure_ioaiu_mstr_seqs;

    task run_phase (uvm_phase phase);
        axi_pcie_master_test_seq  pcie_test_seq;
        axi_pcie_sequential_write pcie_sequential_test_seq;     
        axi_pcie_prod_cons_ioaiu pcie_prod_cons_test_seq;     
        axi_pcie_sequential_read seq_read_seq;
        bit test_unit_duplication_uecc;
        
        `ifndef USE_VIP_SNPS 
       
		<%for(var i = 0; i < obj.DutInfo.nNativeInterfacePorts; i++){%>
                m_master_pipelined_seq[<%=i%>] = axi_master_pipelined_seq::type_id::create("m_master_pipelined_seq[<%=i%>]");
           	m_master_pipelined_seq[<%=i%>].core_id = <%=i%>;
                <%}%>
        <% if(obj.AiuInfo[obj.Id].interfaces.eventRequestOutInt._SKIP_ == false || obj.AiuInfo[obj.Id].interfaces.eventRequestInInt._SKIP_ == false) { %>
            m_<%=obj.BlockId%>_event_seq = <%=obj.BlockId%>_event_agent_pkg::event_seq::type_id::create("m_<%=obj.BlockId%>_event_seq") ;
        <% } %>        
        `endif
        // FIXME : why is scoreboard being set to config_db? - SAI
        // uvm_config_db#(ioaiu_scoreboard)::set(uvm_root::get(), 
        //                             "*", 
        //                             "ioaiu_scb", 
        //                             env.m_scb);
<%for(var i = 0; i < obj.DutInfo.nNativeInterfacePorts; i++){%>
            uvm_config_db#(ioaiu_scoreboard)::set(uvm_root::get(), 
                                    "*", 
                                    "ioaiu_scb_<%=i%>", 
                                    mp_env.m_env[<%=i%>].m_scb);
<%}%>

        super.run_phase(phase);
<%if((((obj.DutInfo.fnNativeInterface === "ACELITE-E") || (obj.DutInfo.fnNativeInterface === "ACE-LITE")) && (obj.DutInfo.cmpInfo.nDvmSnpInFlight > 0)) || (obj.DutInfo.fnNativeInterface == "ACE")) {%>
        `ifdef USE_VIP_SNPS  
        `ifndef NOT_USE_INHOUSE_ACE_MODEL 
        //snoop_rsp_cache_update();
        `endif
        `endif
<%}%>

            
                <%if(obj.INHOUSE_APB_VIP){%>
                
                sysco_attach_seq.model         = mp_env.m_env[0].m_regs;
            	<%for (let j=0; j<obj.DutInfo.nNativeInterfacePorts; j++) {%>
            		sysco_attach_seq.scb_en[<%=j%>] = m_env_cfg[<%=j%>].has_scoreboard; 
            		sysco_attach_seq.ioaiu_scb[<%=j%>] 	= mp_env.m_env[<%=j%>].m_scb;
            	<%}%>
                <%for(let i = 0; i < obj.DutInfo.nNativeInterfacePorts; i++){%>
                    default_seq_<%=i%>.model       = mp_env.m_env[0].m_regs;
                <%}%>
                <% if(obj.testBench == 'io_aiu') { %>
                `ifndef VCS
                 if (k_csr_seq) begin
                `else // `ifndef VCS
                 if (k_csr_seq != "") begin
                `endif // `ifndef VCS ... `else ... 
                <% } else {%>
                 if (k_csr_seq) begin
                <% } %>
                    <%for (let i=0; i<obj.DutInfo.nNativeInterfacePorts; i++) {%>
                        csr_seq[<%=i%>].model       = mp_env.m_env[0].m_regs;
                    <%}%>
                end
                <%if(obj.DutInfo.useCache){%>
                    <% if(obj.testBench == 'io_aiu') { %>
                    `ifndef VCS
                     if (k_csr_SMC_mntop_seq) begin
                    `else // `ifndef VCS
                     if (k_csr_SMC_mntop_seq != "") begin
                    `endif // `ifndef VCS ... `else ... 
                    <% } else {%>
                     if (k_csr_SMC_mntop_seq) begin
                    <% } %>
                        <%for (let j=0; j<obj.DutInfo.nNativeInterfacePorts; j++) {%>
                            smc_mntop_csr_seq[<%=j%>].model       = mp_env.m_env[0].m_regs;
            				//smc_mntop_csr_seq[<%=j%>].ioaiu_scb   = mp_env.m_env[<%=j%>].m_scb;
                        <%}%>
                    end
                   <% if(obj.testBench == 'io_aiu') { %>
                   `ifndef VCS
                    if (k_mntop_debug_read_write_seq) begin
                   `else // `ifndef VCS
                    if (k_mntop_debug_read_write_seq != "") begin
                   `endif // `ifndef VCS ... `else ... 
                   <% } else {%>
                    if (k_mntop_debug_read_write_seq) begin
                   <% } %>
                        <%for (let j=0; j<obj.DutInfo.nNativeInterfacePorts; j++) {%>
                            mntop_debug_read_write_seq[<%=j%>].model       = mp_env.m_env[0].m_regs;
                        <%}%>
                    end
                <%}%>
                phase.raise_objection(this, "Start default_seq");
                `uvm_info("run_main", "default_seq started",UVM_NONE)
                ev_default_seq_en_test = uvm_event_pool::get_global("ev_default_seq_en_test");
                fork
                    <%for(let i = 0; i < obj.DutInfo.nNativeInterfacePorts; i++){%>
                        default_seq_<%=i%>.start(mp_env.m_env[0].m_apb_agent.m_apb_sequencer);
                    <%}%>
                join
                ev_default_seq_en_test.trigger();
                `uvm_info("run_main", "default_seq finished",UVM_NONE)
                #100ns;
                phase.drop_objection(this, "Finish default_seq");
            <%}%>
             <%if(obj.testBench == "io_aiu" && obj.DutInfo.nNativeInterfacePorts == 1 && obj.DutInfo.interfaces.axiInt.params.checkType == 'ODD_PARITY_BYTE_ALL') { %>
                
                  `ifdef USE_VIP_SNPS
                     if($test$plusargs("check_enable_low_parity_test"))begin
                      wait_for_chk_en_test = uvm_event_pool::get_global("wait_for_chk_en_test");
                      phase.raise_objection(this,"check_enable low testing start");
                      `uvm_info(get_type_name(),$sformatf("wait for event"),UVM_LOW);
                      wait_for_chk_en_test.wait_trigger();
                      phase.drop_objection(this,"check_enable low testing Done");
                      `uvm_info(get_type_name(),$sformatf("event recrived successfully"),UVM_LOW);
                     end
                  `endif
               
             <%}%>

            <%if(obj.INHOUSE_APB_VIP){%>
                <%if(((obj.DutInfo.orderedWriteObservation == true) || (obj.DutInfo.fnNativeInterface === "ACELITE-E") && (obj.DutInfo.cmpInfo.nDvmSnpInFlight > 0)) || (obj.DutInfo.fnNativeInterface == "ACE" || obj.DutInfo.fnNativeInterface == "ACE5") || ((obj.DutInfo.fnNativeInterface == "AXI4") && obj.DutInfo.useCache)||((obj.DutInfo.orderedWriteObservation == true) || (obj.DutInfo.fnNativeInterface === "AXI5") && (obj.DutInfo.cmpInfo.nDvmSnpInFlight > 0))) { %>
                    begin //attach seq
                        phase.raise_objection(this, "Start attach_seq");
                        `uvm_info("run_main", "ioaiu_csr_attach_seq_started", UVM_NONE)
                                             sysco_attach_seq.start(mp_env.m_env[0].m_apb_agent.m_apb_sequencer);
                        `uvm_info("run_main", "ioaiu_csr_attach_seq_finished", UVM_NONE)
                        phase.drop_objection(this, "Finish attach_seq");
                    end
                <%}%>
            <%}%>
        
        `ifdef USE_VIP_SNPS  
	

          /*  //phase.raise_objection(this, "Start ace_seq");
            //start ace seq here
            cust_seq_h.wt_ace_rdnosnp                 = wt_ace_rdnosnp;
            cust_seq_h.wt_ace_rdonce                  = wt_ace_rdonce;
            cust_seq_h.wt_ace_rdshrd                  = wt_ace_rdshrd;
            cust_seq_h.wt_ace_rdcln                   = wt_ace_rdcln;
            cust_seq_h.wt_ace_rdnotshrddty            = wt_ace_rdnotshrddty;
            cust_seq_h.wt_ace_rdunq                   = wt_ace_rdunq;
            cust_seq_h.wt_ace_clnunq                  = wt_ace_clnunq;
            cust_seq_h.wt_ace_mkunq                   = wt_ace_mkunq;
            cust_seq_h.wt_ace_dvm_msg                 = wt_ace_dvm_msg;
            cust_seq_h.wt_ace_dvm_sync                = wt_ace_dvm_sync;
            cust_seq_h.wt_ace_clnshrd                 = wt_ace_clnshrd;
            cust_seq_h.wt_ace_clninvl                 = wt_ace_clninvl;
            cust_seq_h.wt_ace_mkinvl                  = wt_ace_mkinvl;
            // cust_seq_h.wt_ace_rd_bar                  = wt_ace_rd_bar;
            cust_seq_h.wt_ace_wrnosnp                 = wt_ace_wrnosnp;
            cust_seq_h.wt_ace_wrunq                   = wt_ace_wrunq;
            cust_seq_h.wt_ace_wrlnunq                 = wt_ace_wrlnunq;
            cust_seq_h.wt_ace_wrcln                   = wt_ace_wrcln;
            cust_seq_h.wt_ace_wrbk                    = wt_ace_wrbk;
            cust_seq_h.wt_ace_evct                    = wt_ace_evct;
            cust_seq_h.wt_ace_wrevct                  = wt_ace_wrevct;
            cust_seq_h.wt_ace_wr_bar                  = wt_ace_wr_bar;
            cust_seq_h.k_num_read_req                 = k_num_read_req;
            cust_seq_h.k_num_write_req                = k_num_write_req;
            cust_seq_h.no_updates                     = no_updates;
            cust_seq_h.wt_ace_atm_str                 = wt_ace_atm_str;
            cust_seq_h.wt_ace_atm_ld                  = wt_ace_atm_ld;
            cust_seq_h.wt_ace_atm_swap                = wt_ace_atm_swap;
            cust_seq_h.wt_ace_atm_comp                = wt_ace_atm_comp;
            cust_seq_h.wt_ace_ptl_stash               = wt_ace_ptl_stash;
            cust_seq_h.wt_ace_full_stash              = wt_ace_full_stash;
            cust_seq_h.wt_ace_shared_stash            = wt_ace_shared_stash;
            cust_seq_h.wt_ace_unq_stash               = wt_ace_unq_stash;
            cust_seq_h.wt_ace_rd_cln_invld            = wt_ace_rd_cln_invld;
            cust_seq_h.wt_ace_rd_make_invld           = wt_ace_rd_make_invld;
            cust_seq_h.wt_ace_clnshrd_pers            = wt_ace_clnshrd_pers; */
            if(aiu_scb_en==1) begin
                //env.m_scb.k_num_reads  = cust_seq_h.k_num_read_req;
                //env.m_scb.k_num_writes = cust_seq_h.k_num_write_req;
                <%for(var i = 0; i < obj.DutInfo.nNativeInterfacePorts; i++){%>
                    mp_env.m_env[<%=i%>].m_scb.k_num_reads  = 0;
                    mp_env.m_env[<%=i%>].m_scb.k_num_writes = 2;
                <%}%>
            end
            //snps_cache = axi_system_env.master[0].get_cache();//[master_no]
            //cust_seq_h.snps_cache = snps_cache;
            //cust_seq_h.start(axi_system_env.sequencer);
            //#10ns;
            //phase.drop_objection(this, "Finish ace_seq");
fork
            begin
	            if(!$test$plusargs("wrong_snpreq_target_id") && !$test$plusargs("wrong_cmdrsp_target_id") && !$test$plusargs("wrong_dtwrsp_target_id") && !$test$plusargs("wrong_dtrrsp_target_id") && !$test$plusargs("wrong_strreq_target_id") && !$test$plusargs("wrong_dtrreq_target_id") && !$test$plusargs("wrong_updrsp_target_id")) begin
                    phase.raise_objection(this, "Start AIU m_master_pipelined_seq");
	            end		       
               <% if(obj.testBench == 'io_aiu') { %>
               `ifndef VCS
                if(k_csr_seq) begin
               `else // `ifndef VCS
                if(k_csr_seq != "") begin
               `endif // `ifndef VCS ... `else ... 
               <% } else {%>
                if(k_csr_seq) begin
               <% } %>
                    `uvm_info("run_main","Waiting for CSR seq to set the control register",UVM_NONE)
                    fork
                        begin
                            <%for(let i=0; i<obj.DutInfo.nNativeInterfacePorts; i++) {%>
                                //ev_<%=i%>.wait_ptrigger();
                            <%}%>
                        end
                    join
                    `uvm_info("run_main","Waiting Completed for CSR seq to set the control register",UVM_NONE)
                end
                main_seq_pre_hook(phase); // virtual task
                for(uint64_type i=0;i<main_seq_iter;i++) begin:forloop_main_seq_iter // by default main_seq_iter=1
                    main_seq_iter_pre_hook(phase,i); // virtual task
                    if (!smi_rx_stall_en) begin
                        //cust_seq_h.start(axi_system_env.sequencer);
                        `ifdef USE_VIP_SNPS
                        configure_ioaiu_mstr_seqs();
                        axi_mstr_seq.nativeif = addrMgrConst::io_subsys_nativeif_a[0].tolower();
                        axi_mstr_seq.instname = addrMgrConst::io_subsys_instname_a[0];
                        axi_mstr_seq.portid = 0;
                        //axi_mstr_seq.start(io_subsys_mstr_agnt_seqr_a[0]);
                         `endif
                        //m_master_pipelined_seq.start(null);
                        
                    end
                    main_seq_iter_post_hook(phase,i); // virtual task
                end:forloop_main_seq_iter
                main_seq_post_hook(phase); // virtual task
                main_seq_hook_end_run_phase(phase); // virtual task

                <%if(obj.INHOUSE_APB_VIP){%>
                    <%if(obj.DutInfo.useCache){%>
                       <% if(obj.testBench == 'io_aiu') { %>
                       `ifndef VCS
                        if (k_mntop_debug_read_write_seq) begin
                       `else // `ifndef VCS
                        if (k_mntop_debug_read_write_seq != "") begin
                       `endif // `ifndef VCS ... `else ... 
                       <% } else {%>
                        if (k_mntop_debug_read_write_seq) begin
                       <% } %>
                            #250us;
                            `uvm_info("CMO debug read write", "mntop_debug_read_write_seq started",UVM_NONE)
                            <%for (let j=0; j<obj.DutInfo.nNativeInterfacePorts; j++) {%>
                                mntop_debug_read_write_seq[<%=j%>].start(mp_env.m_env[0].m_apb_agent.m_apb_sequencer);
                            <%}%>
                            `uvm_info("CMO debug read write", "mntop_debug_read_write_seq finished",UVM_NONE)
                            #250us;
                        end
                    <%}%>
                <%}%>
                if(!$test$plusargs("wrong_snpreq_target_id") && !$test$plusargs("wrong_cmdrsp_target_id") && !$test$plusargs("wrong_dtwrsp_target_id") && !$test$plusargs("wrong_dtrrsp_target_id") && !$test$plusargs("wrong_strreq_target_id") && !$test$plusargs("wrong_dtrreq_target_id") && !$test$plusargs("wrong_updrsp_target_id") && !$test$plusargs("wrong_sysreq_target_id")) begin
                    phase.drop_objection(this, "Finish AIU m_master_pipelined_seq");
                               end		       
            end
            <%if(obj.INHOUSE_APB_VIP ){%>
                if (k_csr_seq != "") begin
                    phase.raise_objection(this, "Start csr_seq run phase");
                    `uvm_info("run_main", "csr_seq started",UVM_NONE)
                    fork
                        <%for (let i=0; i<obj.DutInfo.nNativeInterfacePorts; i++) {%>
                            if((k_csr_seq ==="set_max_errthd" || k_csr_seq ==="ioaiu_csr_cecr_errInt_seq" || k_csr_seq ==="ioaiu_csr_trace_debug_seq" || k_csr_seq ==="io_aiu_csr_caiuuedr_TransCorrErrDetEn_seq") && <%=obj.DutInfo.nNativeInterfacePorts%> > 1)begin
        		    if($test$plusargs("constraint_traffic_to_single_core")) begin
				if (select_core == <%=i%>)
                            	csr_seq[<%=i%>].start(mp_env.m_env[0].m_apb_agent.m_apb_sequencer);
                            end
			end
                            else begin
                csr_seq[<%=i%>].model = mp_env.m_env[0].m_regs;
			    //csr_seq[<%=i%>].start(mp_env.m_env[0].m_apb_agent.m_apb_sequencer);
                            end
                        <%}%>
                    join
                    `uvm_info("run_main", "csr_seq finished",UVM_NONE)
                    phase.drop_objection(this, "Finish csr_seq run phase");
                end
            <%}%>
            <%if((obj.useResiliency) || (obj.testBench == "io_aiu")){%> //CONC-9024
                fork
                begin
                    <%if((obj.testBench != "fsys") && (obj.INHOUSE_APB_VIP)){%>
                        if($test$plusargs("check_corr_error_cnt")) begin
                            fork 
                                begin
                                    <%for(var i = 0; i < obj.DutInfo.nNativeInterfacePorts; i++){%>
                                    res_corr_err_threshold_seq_<%=i%> res_crtr_seq_<%=i%> = res_corr_err_threshold_seq_<%=i%>::type_id::create("res_crtr_seq_<%=i%>");
                                    res_crtr_seq_<%=i%>.model = mp_env.m_env[0].m_regs;
                                    res_crtr_seq_<%=i%>.start(mp_env.m_env[0].m_apb_agent.m_apb_sequencer);
                                    <%}%>
                                end
                            join
                        end
                    <%}%>
                end
                <%if((obj.useResiliency)){%>
                begin
                    `ifndef VCS
                     if(!uvm_config_db#(event)::get(this, "", "kill_test", kill_test)) begin
                   `uvm_error( "kill test run_phase", "kill test event not found" )
                    end
                    `else
                    if(!uvm_config_db#(uvm_event)::get(this, "", "kill_test", kill_test)) begin
                   `uvm_error( "kill test run_phase", "kill test event not found" )
                    end
                    `endif
                    if ($test$plusargs("test_placeholder_connectivity")) begin
                        `uvm_info("run_main", "waiting for kill_test event to trigger",UVM_NONE)
                          phase.raise_objection(this, "Start placeholder test");
				`ifndef VCS
                                 @kill_test;
				`else // `ifndef VCS
				kill_test.wait_trigger();
				`endif // `ifndef VCS
                          `uvm_info("run_main", "kill_test event triggered",UVM_NONE)
                           #100ns;
                           phase.drop_objection(this, "Finish placeholder test");
                    end
               end 
               <%}%>
                begin
                    uvm_config_db#(bit)::get(this, "", "test_unit_duplication_uecc", test_unit_duplication_uecc);
                    if (test_unit_duplication_uecc) begin
                        `uvm_info("run_main", "waiting for kill_test event to trigger",UVM_NONE)
                        <%for(var i = 0; i < obj.DutInfo.nNativeInterfacePorts; i++){%>
                            if(m_env_cfg[<%=i%>].has_scoreboard)
                                @mp_env.m_env[<%=i%>].m_scb.kill_test;
                                <%if((obj.useResiliency)){%>
                            else
                                @kill_test;
                                <%}%>
                            `uvm_info("run_main", "kill_test event triggered",UVM_NONE)
                        <%}%>
                    end
                    if ($test$plusargs("inj_cntl") && $test$plusargs("expect_mission_fault")) begin
                        // Fetching the objection from current phase
                        objection = phase.get_objection();

                        // Collecting all the objectors which currently have objections raised
                        objection.get_objectors(objectors_list);

                        // Dropping the objections forcefully
                       if (!(($test$plusargs("dtw_dbg_rsp_err_inj")) || ($test$plusargs("dtr_req_err_inj")) || ($test$plusargs("snp_req_err_inj")) || ($test$plusargs("dtw_rsp_err_inj")) || ($test$plusargs("ccmd_rsp_err_inj")) || ($test$plusargs("str_req_err_inj")) || ($test$plusargs("dtr_rsp_err_inj")) || ($test$plusargs("ccmd_rsp_err_inj")) || ($test$plusargs("nccmd_rsp_err_inj")) || ($test$plusargs("cmp_rsp_err_inj")) || ($test$plusargs("sys_req_err_inj_uc")) || ($test$plusargs("sys_req_err_inj_c")) || ($test$plusargs("upd_rsp_err_inj")) || ($test$plusargs("dtw_dbg_rsp_err_inj_uc")) || ($test$plusargs("dtw_dbg_rsp_err_inj_c")) || ($test$plusargs("sys_rsp_err_inj_uc")) || ($test$plusargs("sys_rsp_err_inj_c")))) begin
                          foreach(objectors_list[i]) begin
                              uvm_report_info("run_main", $sformatf("objection count %d", objection.get_objection_count(objectors_list[i])),UVM_MEDIUM);
                              while(objection.get_objection_count(objectors_list[i]) != 0) begin
                                  phase.drop_objection(objectors_list[i], "dropping objections to kill the test");
                              end
                          end
                      end
                    end
                end
                begin
                    if ($test$plusargs("expect_mission_fault")) begin
                        if(!$test$plusargs("test_unit_duplication")) begin
                            begin
                                forever begin
                                    #(100*1ns);
                                     <%if(obj.useResiliency){%>
                                    if (u_csr_probe_vif[0].fault_mission_fault == 0) begin
                                        phase.raise_objection(this, "ioaiu_uncorr_error_bringup_test");
                                        `uvm_info(get_name(),"raised_objection::uncorr", UVM_DEBUG);
                                        @u_csr_probe_vif[0].fault_mission_fault;
                                        phase.drop_objection(this, "ioaiu_uncorr_error_bringup_test");
                                        `uvm_info(get_name(),"dropped_objection::uncorr", UVM_DEBUG);
                                    end
                                   <%}%>
                                    if($test$plusargs("expect_mission_fault_cov"))begin
                                        //repeat(10000) @(negedge u_csr_probe_vif[0].clk);
                                        #1ms; // keep testcase timeout higher than this to avoid hearbeat failure
                                    end
                                    #(10000*1ns);
                                    `uvm_info($sformatf("%m"), $sformatf("<%=obj.BlockId%> saw mission fault. Kill test"), UVM_NONE)
                                     kill_test.trigger();   // otherwise the test will hang and timeout
                                    `uvm_info($sformatf("%m"), $sformatf("<%=obj.BlockId%> saw mission fault. Jump to report phase"), UVM_NONE)
                                    phase.jump(uvm_report_phase::get());
                                end
                            end
                        end
                    end
                end
                join_none
            <%}%>
join
        `endif
        `ifndef USE_VIP_SNPS  
            <%if(!obj.SFI_BFM_TEST_MODE){%>
                <%for(var i = 0; i < obj.DutInfo.nNativeInterfacePorts; i++){%>
                    m_master_pipelined_seq[<%=i%>].m_read_addr_chnl_seqr          = mp_env.m_env[<%=i%>].m_axi_master_agent.m_read_addr_chnl_seqr;
                    m_master_pipelined_seq[<%=i%>].m_read_data_chnl_seqr          = mp_env.m_env[<%=i%>].m_axi_master_agent.m_read_data_chnl_seqr;
                    m_master_pipelined_seq[<%=i%>].m_write_addr_chnl_seqr         = mp_env.m_env[<%=i%>].m_axi_master_agent.m_write_addr_chnl_seqr;
                    m_master_pipelined_seq[<%=i%>].m_write_data_chnl_seqr         = mp_env.m_env[<%=i%>].m_axi_master_agent.m_write_data_chnl_seqr;
                    m_master_pipelined_seq[<%=i%>].m_write_resp_chnl_seqr         = mp_env.m_env[<%=i%>].m_axi_master_agent.m_write_resp_chnl_seqr;
                    m_master_pipelined_seq[<%=i%>].m_ace_cache_model              = m_ace_cache_model[<%=i%>];
                    m_master_pipelined_seq[<%=i%>].wt_ace_rdnosnp                 = mp_env.m_env[<%=i%>].m_axi_master_agent.m_cfg.wt_ace_rdnosnp;
                    m_master_pipelined_seq[<%=i%>].wt_ace_rdonce                  = mp_env.m_env[<%=i%>].m_axi_master_agent.m_cfg.wt_ace_rdonce;
                    m_master_pipelined_seq[<%=i%>].wt_ace_rdshrd                  = mp_env.m_env[<%=i%>].m_axi_master_agent.m_cfg.wt_ace_rdshrd;
                    m_master_pipelined_seq[<%=i%>].wt_ace_rdcln                   = mp_env.m_env[<%=i%>].m_axi_master_agent.m_cfg.wt_ace_rdcln;
                    m_master_pipelined_seq[<%=i%>].wt_ace_rdnotshrddty            = mp_env.m_env[<%=i%>].m_axi_master_agent.m_cfg.wt_ace_rdnotshrddty;
                    m_master_pipelined_seq[<%=i%>].wt_ace_rdunq                   = mp_env.m_env[<%=i%>].m_axi_master_agent.m_cfg.wt_ace_rdunq;
                    m_master_pipelined_seq[<%=i%>].wt_ace_clnunq                  = mp_env.m_env[<%=i%>].m_axi_master_agent.m_cfg.wt_ace_clnunq;
                    m_master_pipelined_seq[<%=i%>].wt_ace_mkunq                   = mp_env.m_env[<%=i%>].m_axi_master_agent.m_cfg.wt_ace_mkunq;
                    m_master_pipelined_seq[<%=i%>].wt_ace_dvm_msg                 = mp_env.m_env[<%=i%>].m_axi_master_agent.m_cfg.wt_ace_dvm_msg;
                    m_master_pipelined_seq[<%=i%>].wt_ace_dvm_sync                = mp_env.m_env[<%=i%>].m_axi_master_agent.m_cfg.wt_ace_dvm_sync;
                    m_master_pipelined_seq[<%=i%>].wt_ace_clnshrd                 = mp_env.m_env[<%=i%>].m_axi_master_agent.m_cfg.wt_ace_clnshrd;
                    m_master_pipelined_seq[<%=i%>].wt_ace_clninvl                 = mp_env.m_env[<%=i%>].m_axi_master_agent.m_cfg.wt_ace_clninvl;
                    m_master_pipelined_seq[<%=i%>].wt_ace_mkinvl                  = mp_env.m_env[<%=i%>].m_axi_master_agent.m_cfg.wt_ace_mkinvl;
                    m_master_pipelined_seq[<%=i%>].wt_ace_rd_bar                  = mp_env.m_env[<%=i%>].m_axi_master_agent.m_cfg.wt_ace_rd_bar;
                    m_master_pipelined_seq[<%=i%>].wt_ace_wrnosnp                 = mp_env.m_env[<%=i%>].m_axi_master_agent.m_cfg.wt_ace_wrnosnp;
                    m_master_pipelined_seq[<%=i%>].wt_ace_wrunq                   = mp_env.m_env[<%=i%>].m_axi_master_agent.m_cfg.wt_ace_wrunq;
                    m_master_pipelined_seq[<%=i%>].wt_ace_wrlnunq                 = mp_env.m_env[<%=i%>].m_axi_master_agent.m_cfg.wt_ace_wrlnunq;
                    m_master_pipelined_seq[<%=i%>].wt_ace_wrcln                   = mp_env.m_env[<%=i%>].m_axi_master_agent.m_cfg.wt_ace_wrcln;
                    m_master_pipelined_seq[<%=i%>].wt_ace_wrbk                    = mp_env.m_env[<%=i%>].m_axi_master_agent.m_cfg.wt_ace_wrbk;
                    m_master_pipelined_seq[<%=i%>].wt_ace_evct                    = mp_env.m_env[<%=i%>].m_axi_master_agent.m_cfg.wt_ace_evct;
                    m_master_pipelined_seq[<%=i%>].wt_ace_wrevct                  = mp_env.m_env[<%=i%>].m_axi_master_agent.m_cfg.wt_ace_wrevct;
                    m_master_pipelined_seq[<%=i%>].wt_ace_wr_bar                  = mp_env.m_env[<%=i%>].m_axi_master_agent.m_cfg.wt_ace_wr_bar;
                    m_master_pipelined_seq[<%=i%>].k_num_read_req                 = mp_env.m_env[<%=i%>].m_axi_master_agent.m_cfg.k_num_read_req;
                    m_master_pipelined_seq[<%=i%>].k_num_write_req                = mp_env.m_env[<%=i%>].m_axi_master_agent.m_cfg.k_num_write_req;
                    m_master_pipelined_seq[<%=i%>].no_updates                     = mp_env.m_env[<%=i%>].m_axi_master_agent.m_cfg.no_updates;
                    m_master_pipelined_seq[<%=i%>].wt_ace_atm_str                 = mp_env.m_env[<%=i%>].m_axi_master_agent.m_cfg.wt_ace_atm_str;
                    m_master_pipelined_seq[<%=i%>].wt_ace_atm_ld                  = mp_env.m_env[<%=i%>].m_axi_master_agent.m_cfg.wt_ace_atm_ld;
                    m_master_pipelined_seq[<%=i%>].wt_ace_atm_swap                = mp_env.m_env[<%=i%>].m_axi_master_agent.m_cfg.wt_ace_atm_swap;
                    m_master_pipelined_seq[<%=i%>].wt_ace_atm_comp                = mp_env.m_env[<%=i%>].m_axi_master_agent.m_cfg.wt_ace_atm_comp;
                    m_master_pipelined_seq[<%=i%>].wt_ace_ptl_stash               = mp_env.m_env[<%=i%>].m_axi_master_agent.m_cfg.wt_ace_ptl_stash;
                    m_master_pipelined_seq[<%=i%>].wt_ace_full_stash              = mp_env.m_env[<%=i%>].m_axi_master_agent.m_cfg.wt_ace_full_stash;
                    m_master_pipelined_seq[<%=i%>].wt_ace_shared_stash            = mp_env.m_env[<%=i%>].m_axi_master_agent.m_cfg.wt_ace_shared_stash;
                    m_master_pipelined_seq[<%=i%>].wt_ace_unq_stash               = mp_env.m_env[<%=i%>].m_axi_master_agent.m_cfg.wt_ace_unq_stash;
                    m_master_pipelined_seq[<%=i%>].wt_ace_rd_cln_invld            = mp_env.m_env[<%=i%>].m_axi_master_agent.m_cfg.wt_ace_rd_cln_invld;
                    m_master_pipelined_seq[<%=i%>].wt_ace_rd_make_invld           = mp_env.m_env[<%=i%>].m_axi_master_agent.m_cfg.wt_ace_rd_make_invld;
                    m_master_pipelined_seq[<%=i%>].wt_ace_clnshrd_pers            = mp_env.m_env[<%=i%>].m_axi_master_agent.m_cfg.wt_ace_clnshrd_pers;
                    m_master_pipelined_seq[<%=i%>].wt_illegal_op_addr             = wt_illegal_op_addr; 
                    m_master_pipelined_seq[<%=i%>].wt_ace_stash_trans             = 0; // AWSNOOP='b1110 StashOp:StashTranslation is not supported in Ncore 3.x
                    m_master_pipelined_seq[<%=i%>].num_sets                       = num_sets;
                    <%}%>
            <%}%>
        `endif
            <%if(obj.DutInfo.useCache){%>
                begin
                    phase.raise_objection(this, "wait for memory init");
                    if($test$plusargs("perf_test")) 
                        #<%=10000 * obj.DutInfo.clkPeriodPs%>ps;
                end
                phase.drop_objection(this, "Finished memory init");
            <%}%>		
            phase.raise_objection(this, "prog sequences");
            if(pcie_test != "") begin
                prog_seq = pcie_prod_cons_prog_0::type_id::create("prod_cons_prog_seq");
                prog_seq.model = mp_env.m_env[0].m_regs;
                prog_seq.start(mp_env.m_env[0].m_apb_agent.m_apb_sequencer);
            end
            phase.drop_objection(this, "prog sequences");
            fork 
	        begin
                if($test$plusargs("wrong_snpreq_target_id") || $test$plusargs("wrong_dtwrsp_target_id") || $test$plusargs("wrong_dtrrsp_target_id")) begin
                        phase.raise_objection(this, "Start AIU write bring up test");
                        //DCTODO remove below pound delay when scoreboard is enabled and using objection mechanism
                        #50000ns;
                        phase.drop_objection(this, "Finish AIU write bring up test");
                end		       
            end
            begin
	            if(!$test$plusargs("wrong_snpreq_target_id") && !$test$plusargs("wrong_cmdrsp_target_id") && !$test$plusargs("wrong_dtwrsp_target_id") && !$test$plusargs("wrong_dtrrsp_target_id") && !$test$plusargs("wrong_strreq_target_id") && !$test$plusargs("wrong_dtrreq_target_id") && !$test$plusargs("wrong_updrsp_target_id") && !$test$plusargs("wrong_sysrsp_target_id")) begin
                    phase.raise_objection(this, "Start AIU m_master_pipelined_seq");
                    `uvm_info("run_main", "master_pipelined_seq started",UVM_NONE)
	            end		       
               <% if(obj.testBench == 'io_aiu') { %>
               `ifndef VCS
                if(k_csr_seq) begin
               `else // `ifndef VCS
                if(k_csr_seq != "") begin
               `endif // `ifndef VCS ... `else ... 
               <% } else {%>
                if(k_csr_seq) begin
               <% } %>
                    `uvm_info("run_main","Waiting for CSR seq to set the control register",UVM_NONE)
                    fork
                            <%for(let i=0; i<obj.DutInfo.nNativeInterfacePorts; i++) {%>
                        begin
                            if((k_csr_seq ==="set_max_errthd" || k_csr_seq ==="ioaiu_csr_cecr_errInt_seq" || k_csr_seq ==="ioaiu_csr_trace_debug_seq" || k_csr_seq ==="io_aiu_csr_caiuuedr_TransCorrErrDetEn_seq") && <%=obj.DutInfo.nNativeInterfacePorts%> > 1)begin
                            if(select_core == <%=i%>)
          		     ev_<%=i%>.wait_ptrigger();
                            end
                            else begin
                             ev_<%=i%>.wait_ptrigger();
                            end
                        end
                            <%}%>
                    join
                    `uvm_info("run_main","Waiting Completed for CSR seq to set the control register",UVM_NONE)
                end
                main_seq_pre_hook(phase); // virtual task
                for(uint64_type i=0;i<main_seq_iter;i++) begin:forloop_main_seq_iter // by default main_seq_iter=1
                    main_seq_iter_pre_hook(phase,i); // virtual task
                    if (!smi_rx_stall_en) begin
                                `uvm_info("run_main",$sformatf("Printing cfg %0p inf %0s active %0s delay_export %0d",mp_env.m_env[0].m_axi_master_agent.m_cfg,mp_env.m_env[0].m_axi_master_agent.m_cfg.m_intf_type,mp_env.m_env[0].m_axi_master_agent.m_cfg.active,mp_env.m_env[0].m_axi_master_agent.m_cfg.delay_export),UVM_NONE)
mp_env.m_env[0].m_axi_master_agent.m_cfg.sprint();
                        fork
                        <%for(var i = 0; i < obj.DutInfo.nNativeInterfacePorts; i++){%>
                        begin
                            //#Check.IOAIU.WriteInterleave
                            `ifndef USE_VIP_SNPS 
                                `uvm_info("run_main","Start m_master_pipelined_seq seq",UVM_NONE)
        			if($test$plusargs("constraint_traffic_to_single_core")) begin
					if (select_core == (<%=i%>))
                            		m_master_pipelined_seq[<%=i%>].start(null); 
				end else begin
                            	m_master_pipelined_seq[<%=i%>].start(null); // FIXME: SAI MP - the 2 sequences must be in fork join
				end
                             `else
                                  svt_axi_item_helper::disable_boot_addr();
                                  axi_mstr_seq.start(io_subsys_mstr_agnt_seqr_a[0]); 
                             `endif
                             
                        end        
                        <%}%>
                        <% if(obj.AiuInfo[obj.Id].interfaces.eventRequestOutInt._SKIP_ == false || obj.AiuInfo[obj.Id].interfaces.eventRequestInInt._SKIP_ == false) { %>
                        `ifndef USE_VIP_SNPS
                        begin
                          `uvm_info("run_main","START <%=obj.BlockId%> EVENT SEQ ", UVM_LOW)
                           m_<%=obj.BlockId%>_event_seq.start(mp_env.m_env[0].m_event_agent.m_sequencer);
                          `uvm_info("run_main","END <%=obj.BlockId%> EVENT SEQ ", UVM_LOW)
                          end
                          `endif
                        
                  <% } %>
                        join
						<%for(let i=0; i<obj.DutInfo.nNativeInterfacePorts; i++) {%>
                        	ev_random_traffic_done_<%=i%>.trigger();
                    	<%}%>
                    end
                    main_seq_iter_post_hook(phase,i); // virtual task
                end:forloop_main_seq_iter
                main_seq_post_hook(phase); // virtual task
                main_seq_hook_end_run_phase(phase); // virtual task

                <%if(obj.INHOUSE_APB_VIP){%>
                    <%if(obj.DutInfo.useCache){%>
                       <% if(obj.testBench == 'io_aiu') { %>
                       `ifndef VCS
                        if (k_mntop_debug_read_write_seq) begin
                       `else // `ifndef VCS
                        if (k_mntop_debug_read_write_seq != "") begin
                       `endif // `ifndef VCS ... `else ... 
                       <% } else {%>
                        if (k_mntop_debug_read_write_seq) begin
                       <% } %>
                            #250us;
                            `uvm_info("CMO debug read write", "mntop_debug_read_write_seq started",UVM_NONE)
                            <%for (let j=0; j<obj.DutInfo.nNativeInterfacePorts; j++) {%>
                                mntop_debug_read_write_seq[<%=j%>].start(mp_env.m_env[0].m_apb_agent.m_apb_sequencer);
                            <%}%>
                            `uvm_info("CMO debug read write", "mntop_debug_read_write_seq finished",UVM_NONE)
                            #250us;
                        end
                    <%}%>
                <%}%>
                if(!$test$plusargs("wrong_snpreq_target_id") && !$test$plusargs("wrong_cmdrsp_target_id") && !$test$plusargs("wrong_dtwrsp_target_id") && !$test$plusargs("wrong_dtrrsp_target_id") && !$test$plusargs("wrong_strreq_target_id") && !$test$plusargs("wrong_dtrreq_target_id") && !$test$plusargs("wrong_updrsp_target_id") && !$test$plusargs("wrong_sysrsp_target_id")) begin
                    phase.drop_objection(this, "Finish AIU m_master_pipelined_seq");

                    `uvm_info("run_main", "master_pipelined_seq finished",UVM_NONE)
                end		       
            end
	        begin
               <% if(obj.testBench == 'io_aiu') { %>
               `ifndef VCS
                if (k_csr_seq) begin
               `else // `ifndef VCS
                if (k_csr_seq != "") begin
               `endif // `ifndef VCS ... `else ... 
               <% } else {%>
                if (k_csr_seq) begin
               <% } %>
                    `uvm_info("run_main","Waiting for CSR seq to set the control register",UVM_NONE)
                    fork
                        begin
                            <%for(let i=0; i<obj.DutInfo.nNativeInterfacePorts; i++) {%>
                            if((k_csr_seq ==="set_max_errthd" || k_csr_seq ==="ioaiu_csr_cecr_errInt_seq" || k_csr_seq ==="ioaiu_csr_trace_debug_seq" || k_csr_seq ==="io_aiu_csr_caiuuedr_TransCorrErrDetEn_seq") && <%=obj.DutInfo.nNativeInterfacePorts%> > 1)begin
                            if(select_core == <%=i%>)
          		     ev_<%=i%>.wait_ptrigger();
                            end
                            else begin
                             ev_<%=i%>.wait_ptrigger();
                            end
                            <%}%>
                        end
                    join
                    `uvm_info("run_main","Waiting Completed for CSR seq to set the control register",UVM_NONE)
                end
                <%if(obj.INHOUSE_APB_VIP){%>
                    <%if(obj.DutInfo.useCache){%>
                       <% if(obj.testBench == 'io_aiu') { %>
                       `ifndef VCS
                        if (k_csr_SMC_mntop_seq) begin
                       `else // `ifndef VCS
                        if (k_csr_SMC_mntop_seq != "") begin
                       `endif // `ifndef VCS ... `else ... 
                       <% } else {%>
                        if (k_csr_SMC_mntop_seq) begin
                       <% } %>
                            phase.raise_objection(this, "Start MaintOp seq");
                            `uvm_info("run_main", "smc_mntop_csr_seq started",UVM_NONE)
                            fork
                            <%for (let j=0; j<obj.DutInfo.nNativeInterfacePorts; j++) {%>
								begin
                        		ev_random_traffic_done_<%=j%>.wait_ptrigger();
                            	smc_mntop_csr_seq[<%=j%>].start(mp_env.m_env[0].m_apb_agent.m_apb_sequencer);
								end
                            <%}%>
							join
                            phase.drop_objection(this, "Finish MaintOp seq");
                            `uvm_info("run_main", "smc_mntop_csr_seq finished",UVM_NONE)
                        end
                    <%}%>
                <%}%>
            end		       
            
            <%if(obj.INHOUSE_APB_VIP){%>
               <% if(obj.testBench == 'io_aiu') { %>
               `ifndef VCS
                if (k_csr_seq) begin
               `else // `ifndef VCS
                if (k_csr_seq != "") begin
               `endif // `ifndef VCS ... `else ... 
               <% } else {%>
                if (k_csr_seq) begin
               <% } %>
                    phase.raise_objection(this, "Start csr_seq run phase");
                    `uvm_info("run_main", "csr_seq started",UVM_NONE)
                    csr_seq_pre_hook(phase); // virtual task
                    for(uint64_type i=0;i<cfg_seq_iter;i++) begin:forloop_cfg_seq_iter // by default cfg_seq_iter=1
                      csr_seq_iter_pre_hook(phase,i); // virtual task
                      fork
                        <%for (let i=0; i<obj.DutInfo.nNativeInterfacePorts; i++) {%>
                            if((k_csr_seq ==="set_max_errthd" || k_csr_seq ==="ioaiu_csr_cecr_errInt_seq" || k_csr_seq ==="ioaiu_csr_trace_debug_seq" || k_csr_seq ==="io_aiu_csr_caiuuedr_TransCorrErrDetEn_seq") && <%=obj.DutInfo.nNativeInterfacePorts%> > 1)begin
                            
        		    if($test$plusargs("constraint_traffic_to_single_core")) begin
				if (select_core == <%=i%>)
                            	csr_seq[<%=i%>].start(mp_env.m_env[0].m_apb_agent.m_apb_sequencer);
                            end
			end
                            else begin
			    csr_seq[<%=i%>].start(mp_env.m_env[0].m_apb_agent.m_apb_sequencer);
                            end

                        <%}%>
                      join
                      csr_seq_iter_post_hook(phase,i); // virtual task
                    end:forloop_cfg_seq_iter
                    csr_seq_post_hook(phase); // virtual task
                    `uvm_info("run_main", "csr_seq finished",UVM_NONE)
                    phase.drop_objection(this, "Finish csr_seq run phase");
                end

                // ------------------------------------------------------------------
                // Implementation for CONC-8404.
                // This block is added to help verifying SMI ports quiescing for
                // trace capture...
                // First pickOne value:: Time to TURN OFF all Trace regs.
                // Second pickOne value: Update all Trace Regs with new User Values
                // ------------------------------------------------------------------
                if ($test$plusargs("ioaiu_cctrlr_mod")) begin  
                    int pickOne, kcount;

                    for(int k=1; k<3; ++k) begin
                        pickOne = (k==1) ? $urandom_range(50000,30000) : $urandom_range(40000,20000);

                        kcount=0;
                        while(kcount < pickOne) begin
                        @(negedge u_csr_probe_vif[0].clk);
                        clk_count_en = (++kcount==pickOne) ?  k : 0;
                        end
                    end
                end
            <%}%>

            //-------------------------------------------------------------------------------------
            // Special case:: Added for Trace Capture and Trigger. -- CONC-8404
            // - This thread will only be invoked, if and only if the user's intent is
            //   to modify the Trace Debug registers, in the middle of simulation
            //   registers such as:: CCTRLR,TCCTRLR,TBALR,GBAHR,TOPCR[0,1],TUBR,TUBMR.
            // - Use the UVM Factory to indicate when those changes had taken place.
            //   That will happen in the sequence..
            // Notes::
            //    There are three phases for this implementation::
            //    Phase   I._ Turn off all enablement bits and reset all the TCAP and
            //                TTrig registers -- (ioaiu_cctrlr_phase=1)
            //    Phase  II._ Configure all the registers again with the user preferred
            //                values    -- (ioaiu_cctrlr_phase=2)
            //    Phase III._ Start simulation with the new configuration. (ioaiu_cctrlr_phase=3)
            //-------------------------------------------------------------------------------------
            begin 
                if($test$plusargs("ioaiu_cctrlr_mod")) begin
                    wait(clk_count_en==1);              // Turn off all the SMI Ports
                    `uvm_info("TRACE Dbg Seq", "Phase I::About to reset all Trace Debug Regs.",UVM_NONE)
                    uvm_config_db#(int)::set(null,"*","ioaiu_cctrlr_phase",1);
                    fork
                        <%for (let i=0; i<obj.DutInfo.nNativeInterfacePorts; i++) {%>
                            csr_seq[<%=i%>].start(mp_env.m_env[0].m_apb_agent.m_apb_sequencer);
                        <%}%>
                    join
                    wait(clk_count_en==2);              // Ready to load the new value.
                    `uvm_info("TRACE Dbg Seq", "Phase II::About to restore all Trace Debug Regs with their new values.",UVM_NONE)
                    uvm_config_db#(int)::set(null,"","ioaiu_cctrlr_phase",2); 
                    fork
                        <%for (let i=0; i<obj.DutInfo.nNativeInterfacePorts; i++) {%>
                            csr_seq[<%=i%>].start(mp_env.m_env[0].m_apb_agent.m_apb_sequencer);
                        <%}%>
                    join  
                    // csr_seq.start(mp_env.m_env[0].m_apb_agent.m_apb_sequencer);

                    // --------------------------------------------------------------
                    // We need to let the ioau_tb_top.sv initial block know that the
                    // "ioaiu_csr_trace_debug_seq" has completed. This is the reason
                    // that we need to set it to "3"..... just for it to be aware.
                    uvm_config_db#(int)::set(null,"*","ioaiu_cctrlr_phase",3);   
                    `uvm_info("TRACE Dbg Seq", "Phase III::Nullify ioaiu_tb_top to release all force signals.",UVM_NONE)
                end
            end

            //----------------------------------------------------------
            begin
                if($test$plusargs("write_bw_test")) begin
                    phase.raise_objection(this, "Start IOAIU Write BW sequence");
                    #200ns;
                    `uvm_info("IOAIU AXI Seq", "Starting IOAIU Write BW sequence",UVM_NONE)
                    for(int i = 0; i < 17; i++) begin
                        automatic int k = i;
                        fork
                        begin
                        write_bw_seq       = ioaiu_write_bw_seq::type_id::create("ioaiu_write_bw_seq");
                        write_bw_seq.use_awid = 0;
                        write_bw_seq.m_axlen = (k == 0) ? 32*8/WXDATA-1: 256*8/WXDATA-1;
                        //Fixme Sai - not part of multicsr access????
                        write_bw_seq.start(mp_env.m_env[<%=i%>].m_axi_master_agent.m_axi_virtual_seqr);
                        end
                        join_none
                    end
                    #200ns;
                    phase.drop_objection(this, "Finish IOAIU Write BW sequence");
                end
            end
            <%if(obj.useResiliency){%>
                fork
                begin
                    <%if((obj.testBench != "fsys") && (obj.INHOUSE_APB_VIP)){%>
                        if($test$plusargs("check_corr_error_cnt")) begin
                            fork 
                                <%for(var i = 0; i < obj.DutInfo.nNativeInterfacePorts; i++){%>
                                begin
                                res_corr_err_threshold_seq_<%=i%> res_crtr_seq_<%=i%> = res_corr_err_threshold_seq_<%=i%>::type_id::create("res_crtr_seq_<%=i%>");
                                res_crtr_seq_<%=i%>.model = mp_env.m_env[0].m_regs;
                                res_crtr_seq_<%=i%>.start(mp_env.m_env[0].m_apb_agent.m_apb_sequencer);
                                end
                                <%}%>
                            join
                        end
                    <%}%>
                end
                 begin
                    `ifndef VCS
                     if(!uvm_config_db#(event)::get(this, "", "kill_test", kill_test)) begin
                   `uvm_error( "kill test run_phase", "kill test event not found" )
                    end
                    `else
                    if(!uvm_config_db#(uvm_event)::get(this, "", "kill_test", kill_test)) begin
                   `uvm_error( "kill test run_phase", "kill test event not found" )
                    end
                    `endif
                    if ($test$plusargs("test_placeholder_connectivity")) begin
                        `uvm_info("run_main", "waiting for kill_test event to trigger",UVM_NONE)
                          phase.raise_objection(this, "Start placeholder test");
				`ifndef VCS
                                 @kill_test;
				`else // `ifndef VCS
				kill_test.wait_trigger();
				`endif // `ifndef VCS
                          `uvm_info("run_main", "kill_test event triggered",UVM_NONE)
                           #100ns;
                           phase.drop_objection(this, "Finish placeholder test");
                    end
               end 
                begin
                    uvm_config_db#(bit)::get(this, "", "test_unit_duplication_uecc", test_unit_duplication_uecc);
                    if (test_unit_duplication_uecc) begin
                        `uvm_info("run_main", "waiting for kill_test event to trigger",UVM_NONE)
                        <%for(var i = 0; i < obj.DutInfo.nNativeInterfacePorts; i++){%>
                            if(m_env_cfg[<%=i%>].has_scoreboard)
                                @mp_env.m_env[<%=i%>].m_scb.kill_test;
                            else
				`ifndef VCS
                                 @kill_test;
				`else // `ifndef VCS
				kill_test.wait_trigger();
				`endif // `ifndef VCS
                            `uvm_info("run_main", "kill_test event triggered",UVM_NONE)
                        <%}%>
                    end
                    if ($test$plusargs("inj_cntl") && $test$plusargs("expect_mission_fault")) begin
                        // Fetching the objection from current phase
                        objection = phase.get_objection();

                        // Collecting all the objectors which currently have objections raised
                        objection.get_objectors(objectors_list);

                        // Dropping the objections forcefully
                       if (!(($test$plusargs("dtw_dbg_rsp_err_inj")) || ($test$plusargs("dtr_req_err_inj")) || ($test$plusargs("snp_req_err_inj")) || ($test$plusargs("dtw_rsp_err_inj")) || ($test$plusargs("ccmd_rsp_err_inj")) || ($test$plusargs("str_req_err_inj")) || ($test$plusargs("dtr_rsp_err_inj")) || ($test$plusargs("ccmd_rsp_err_inj")) || ($test$plusargs("nccmd_rsp_err_inj")) || ($test$plusargs("cmp_rsp_err_inj")) || ($test$plusargs("sys_req_err_inj_uc")) || ($test$plusargs("sys_req_err_inj_c")) || ($test$plusargs("upd_rsp_err_inj")) || ($test$plusargs("dtw_dbg_rsp_err_inj_uc")) || ($test$plusargs("dtw_dbg_rsp_err_inj_c")) || ($test$plusargs("sys_rsp_err_inj_uc")) || ($test$plusargs("sys_rsp_err_inj_c")))) begin
                           foreach(objectors_list[i]) begin
                               uvm_report_info("run_main", $sformatf("objection count %d", objection.get_objection_count(objectors_list[i])),UVM_MEDIUM);
                               while(objection.get_objection_count(objectors_list[i]) != 0) begin
                                   phase.drop_objection(objectors_list[i], "dropping objections to kill the test");
                               end
                           end
                       end
                    end
                end
                begin
                    if ($test$plusargs("expect_mission_fault")) begin
                        if(!$test$plusargs("test_unit_duplication")) begin
                            begin
                                forever begin
                                    #(100*1ns);
                                     <%if(obj.useResiliency){%>
                                    if (u_csr_probe_vif[0].fault_mission_fault == 0) begin
                                        phase.raise_objection(this, "ioaiu_uncorr_error_bringup_test");
                                        `uvm_info(get_name(),"raised_objection::uncorr", UVM_DEBUG);
                                        @u_csr_probe_vif[0].fault_mission_fault;
                                        phase.drop_objection(this, "ioaiu_uncorr_error_bringup_test");
                                        `uvm_info(get_name(),"dropped_objection::uncorr", UVM_DEBUG);
                                    end
                                   <%}%>
                                    if($test$plusargs("expect_mission_fault_cov"))begin
                                        //repeat(10000) @(negedge u_csr_probe_vif[0].clk);
                                        #1ms; // keep testcase timeout higher than this to avoid hearbeat failure
                                    end
                                    #(100000*1ns);
                                    `uvm_info($sformatf("%m"), $sformatf("<%=obj.BlockId%> saw mission fault. Kill test"), UVM_NONE)
                                    `ifndef VCS
    				    -> kill_test;
                                    `else // `ifndef VCS
   				     kill_test.trigger();
		                  `endif // `ifndef VCS ... `else ..`uvm_info($sformatf("%m"), $sformatf("<%=obj.BlockId%> saw mission fault. Jump to report phase"), UVM_NONE)
                                    phase.jump(uvm_report_phase::get());
                                end
                            end
                        end
                    end
                end
                join_none
            <%}%>
            join
       
    endtask : run_phase

   virtual function void report_phase(uvm_phase phase);
     <% if ((obj.useResiliency) && (obj.testBench != "fsys")) { %>
     int res_corr_err_threshold;
     bit patch_conc_7033, patch_conc_7597;
     int tolerance_range_low_val, tolerance_range_high_val, res_corr_err_tolerance_cnt;
     int tb_res_smi_corr_err, rtl_res_smi_corr_err, mod_res_smi_corr_err, rtl_res_smi_corr_thresh;
     bit test_unit_duplication_uecc;
     uvm_config_db#(bit)::get(this, "", "test_unit_duplication_uecc", test_unit_duplication_uecc);
     if($test$plusargs("expect_mission_fault") && test_unit_duplication_uecc) begin
       if (u_csr_probe_vif[0].fault_mission_fault == 0) begin
         `uvm_error({"fault_injector_checker_",get_name()}, $sformatf({"expect_mission_fault argument is passed from command line & observed mission_fault=%0d"}, u_csr_probe_vif[0].fault_mission_fault))
       end else begin
         `uvm_info(get_name(), $sformatf({"expect_mission_fault argument is passed from command line & observed mission_fault=%0d"}, u_csr_probe_vif[0].fault_mission_fault), UVM_LOW)
       end
     end
    if(($test$plusargs("inj_cntl")) && 
        ($test$plusargs("smi_ndp_err_inj") ||
         $test$plusargs("smi_hdr_err_inj") ||
         $test$plusargs("smi_dp_ecc_inj")) &&
         $test$plusargs("check_corr_error_cnt")
       )
    begin
        patch_conc_7033 = 1; // TODO: disabled if CONC-7033 decides to stop counter at threshold+1
            
        tb_res_smi_corr_err = mp_env.m_env[0].m_scb.res_smi_corr_err;
        rtl_res_smi_corr_err = u_csr_probe_vif[0].cerr_counter;
        rtl_res_smi_corr_thresh = u_csr_probe_vif[0].cerr_threshold;

        patch_conc_7597 = (tb_res_smi_corr_err > rtl_res_smi_corr_thresh) ? 0 : 1; // already hit threshold so no tolerance required
        if(patch_conc_7597) res_corr_err_tolerance_cnt = 1; // CONC-7597. 1 count tolerance added

        mod_res_smi_corr_err = (tb_res_smi_corr_err > rtl_res_smi_corr_thresh) ? (rtl_res_smi_corr_thresh + 1) : tb_res_smi_corr_err;
        tolerance_range_low_val = mod_res_smi_corr_err-res_corr_err_tolerance_cnt;
        tolerance_range_high_val = mod_res_smi_corr_err+res_corr_err_tolerance_cnt + patch_conc_7033;
        `uvm_info(get_full_name(), $sformatf({"tolerance_range=[%0d:%0d]"}, tolerance_range_low_val, tolerance_range_high_val), UVM_DEBUG)

        if(!(rtl_res_smi_corr_err inside {[tolerance_range_low_val : tolerance_range_high_val]})) begin
            `uvm_error(get_full_name(), $sformatf("CORR_ERR:: No of error injection(TB) Vs detection(RTL) counter mismatch {TB_raw=%0d|TB_adj=%0d|RTL=%0d}", tb_res_smi_corr_err, mod_res_smi_corr_err, rtl_res_smi_corr_err))
        end else begin
            `uvm_info(get_full_name(), $sformatf("CORR_ERR:: No of error injection(TB) Vs detection(RTL) counter match {TB_raw=%0d|TB_adj=%0d|RTL=%0d}", tb_res_smi_corr_err, mod_res_smi_corr_err, rtl_res_smi_corr_err), UVM_MEDIUM)
        end

       if(u_csr_probe_vif[0].cerr_counter > u_csr_probe_vif[0].cerr_threshold) begin
         if(u_csr_probe_vif[0].cerr_over_thres_fault !== 1) begin
           `uvm_error(get_full_name(), $sformatf("CORR_ERR:: counter value{%0d} is higher than threshold{%0d} but cerr_over_thres_fault{%0d} didn't triggered", u_csr_probe_vif[0].cerr_counter, u_csr_probe_vif[0].cerr_threshold, u_csr_probe_vif[0].cerr_over_thres_fault))
         end else begin
           `uvm_info(get_full_name(), $sformatf("CORR_ERR:: counter value{%0d} is higher than threshold{%0d} so cerr_over_thres_fault{%0d} triggered", u_csr_probe_vif[0].cerr_counter, u_csr_probe_vif[0].cerr_threshold, u_csr_probe_vif[0].cerr_over_thres_fault), UVM_MEDIUM)
         end
       end else begin
         if(u_csr_probe_vif[0].cerr_over_thres_fault === 1) begin
           `uvm_error(get_full_name(), $sformatf("CORR_ERR:: counter value{%0d} is lower than threshold{%0d} but cerr_over_thres_fault{%0d} triggered", u_csr_probe_vif[0].cerr_counter, u_csr_probe_vif[0].cerr_threshold, u_csr_probe_vif[0].cerr_over_thres_fault))
         end else begin
           `uvm_info(get_full_name(), $sformatf("CORR_ERR:: counter value{%0d} is lower than threshold{%0d} so cerr_over_thres_fault{%0d} didn't triggered", u_csr_probe_vif[0].cerr_counter, u_csr_probe_vif[0].cerr_threshold, u_csr_probe_vif[0].cerr_over_thres_fault), UVM_MEDIUM)
         end
       end
       if($value$plusargs("res_corr_err_threshold=%0d", res_corr_err_threshold)) begin
         if(u_csr_probe_vif[0].cerr_threshold != res_corr_err_threshold) begin
           `uvm_error(get_full_name(), $sformatf("CORR_ERR:: threshold value mis-match{RTL=%0d|TB=%0d}", u_csr_probe_vif[0].cerr_threshold, res_corr_err_threshold))
         end else begin
           `uvm_info(get_full_name(), $sformatf("CORR_ERR:: threshold value match{RTL=%0d|TB=%0d}", u_csr_probe_vif[0].cerr_threshold, res_corr_err_threshold), UVM_LOW)
         end
       end
     end
     <% } %>
     super.report_phase(phase);
   endfunction: report_phase

/*`ifdef USE_VIP_SNPS  
`ifndef NOT_USE_INHOUSE_ACE_MODEL 
   function void snoop_rsp_cache_update();
     ace_snoop_addr_pkt_t snoop_addr_pkt;
     bit [`SVT_AXI_ADDR_WIDTH - 1 : 0] addr; 
     int index;
     bit [7:0] data[];
     bit is_unique;
     bit is_clean;
     longint age;
     axi_crresp_t crresp;
     axi_xdata_t cddata[];

     axi_master_pipelined_seq m_master_pipelined_seq = axi_master_pipelined_seq::type_id::create("m_master_pipelined_seq");
// for DVM sync
       bit                                                 need_to_send_dvmcmpl;
       bit                                                 is_dvm_sync_snp;                                                                                      
       bit [3:0]                                            acsnoop;
       bit                                                 is_last_part_dvm_snp = 1;
       bit                                                 m_axi_dvm_sync_q[$];
       ace_command_types_enum_t                            snptype;
       snps_axi_master_read_seq m_axi_read_seq = snps_axi_master_read_seq ::type_id::create("m_axi_read_seq"); 
       snps_axi_master_base_seq m_read_seq = snps_axi_master_base_seq ::type_id::create("m_read_seq");
     fork begin
       forever begin
         ev_snoop_rsp.wait_trigger();
         $cast(snoop_addr_pkt, ev_snoop_rsp.get_trigger_data());
         addr = snoop_addr_pkt.acaddr;
         acsnoop   = snoop_addr_pkt.acsnoop;
         fork begin
                snptype                                    = m_ace_cache_model[0].convert_snp_type(acsnoop);
                if(snptype == DVMCMPL) begin
                    need_to_send_dvmcmpl = 0;
                    is_dvm_sync_snp = 0;
                    is_last_part_dvm_snp = 1;
                end
                else if (snptype == DVMMSG &&
                snoop_addr_pkt.acaddr[15] == 1 &&
                snoop_addr_pkt.acaddr[0] == 1
                ) begin
                    need_to_send_dvmcmpl = 1;
                    is_dvm_sync_snp = 1;
                    is_last_part_dvm_snp = 0;
                end
                else if (snptype == DVMMSG &&
                         snoop_addr_pkt.acaddr[15] == 1 &&
                         snoop_addr_pkt.acaddr[0] == 0  &&
                         is_last_part_dvm_snp == 1
                     ) begin
                    need_to_send_dvmcmpl = 1;
                    is_last_part_dvm_snp = 1;
                    is_dvm_sync_snp = 1;
                end
                else if (snptype == DVMMSG &&
                    snoop_addr_pkt.acaddr[15] == 0 &&
                    snoop_addr_pkt.acaddr[0] == 1 &&
                    is_last_part_dvm_snp == 1
                ) begin
                    need_to_send_dvmcmpl = 0;
                    is_last_part_dvm_snp = 0;
                    is_dvm_sync_snp = 0;
                end 
                else if (snptype == DVMMSG &&
                         snoop_addr_pkt.acaddr[15] == 0 &&
                         snoop_addr_pkt.acaddr[0] == 0 &&
                         is_last_part_dvm_snp == 1) begin
                        need_to_send_dvmcmpl = 0;
                        is_last_part_dvm_snp = 1;
                        is_dvm_sync_snp = 0;
                end
                else begin
                    if(is_last_part_dvm_snp == 0) begin
                         is_last_part_dvm_snp = 1;
                    end
                    else begin
                    end
                end
                if (snptype == DVMCMPL) begin
                  m_read_seq.isDVMSyncOutStanding = 0;
                end
                if (snptype == DVMMSG &&
                    need_to_send_dvmcmpl == 1 &&
                    is_last_part_dvm_snp ==1 &&
                    is_dvm_sync_snp == 1
                ) begin
                    m_axi_dvm_sync_q.push_back('b1);
                    need_to_send_dvmcmpl = 0;
                end
                wait(m_axi_dvm_sync_q.size() > 0);
                 m_axi_dvm_sync_q.pop_front();
                 m_read_seq.sendDVMComplete   = 1;
                if ((m_read_seq.read_req_count >= m_read_seq.read_req_total_count) ) begin
                    m_read_seq.start(null);
                end 
                wait (m_read_seq.sendDVMComplete == 0); 
             end
             begin
                     `uvm_info(get_name(),$psprintf("snoop_rsp_cache_update addr=0x%0h",addr),UVM_NONE)
                      snps_cache.read_by_addr(addr,index,data,is_unique,is_clean,age,0);
                      m_ace_cache_model[0].give_snoop_resp(addr,snoop_addr_pkt.acsnoop, crresp, cddata
                      <% if (obj.wSecurityAttribute > 0) { %>                                             
                             ,snoop_addr_pkt.acprot[1]
                      <% } %>  
                      );
                      if (snptype !== DVMMSG && snptype !== DVMCMPL ) begin
                      `uvm_info(get_name(),$psprintf("txn addr=0x%0h, start state: is_unique=%0b is_clean=%0b crresp=%0b",addr,is_unique,is_clean,crresp),UVM_NONE)
                       m_ace_cache_model[0].modify_cache_line_for_snoop(snoop_addr_pkt.acaddr
                       <% if (obj.wSecurityAttribute > 0) { %>                                             
                            ,snoop_addr_pkt.acprot[1]
                       <% } %>                                                
                       );
                       `uvm_info(get_name(),$psprintf("txn addr=0x%0h, start state: is_unique=%0b is_clean=%0b crresp=%0b",addr,is_unique,is_clean,crresp),UVM_NONE)
                      end
             end
           join_any
           end
       end
     join_none
   endfunction: snoop_rsp_cache_update
`endif
`endif*/

endclass: bring_up_test

//#Test.IOAIU.ccp_switch_on_off
//#Test.IOAIU.ccp_update_disable
<%if(obj.DutInfo.useCache) { %>
class ioaiu_ccp_switch_on_off extends bring_up_test;

    `uvm_component_utils(ioaiu_ccp_switch_on_off)
  
    <%for(var i = 0; i < obj.DutInfo.nNativeInterfacePorts; i++){%>
    ioaiu_csr_flush_all_seq_<%=i%> ccp_flush_seq_<%=i%>;
    ioaiu_csr_cfg_ccp_seq_<%=i%> cfg_ccp_seq_<%=i%>;
    ioaiu_wait_for_idle_<%=i%> ioaiu_idle_seq_<%=i%>;
    <%}%>
    ccpCacheLine m_ncbu_cache_allocEn_q[<%=obj.DutInfo.nNativeInterfacePorts%>][$];
    ccpCacheLine m_ncbu_cache_allocDis_q[<%=obj.DutInfo.nNativeInterfacePorts%>][$];
    int temp_index[$];

    function new(string name = "ioaiu_ccp_switch_on_off", uvm_component parent = null);
      super.new(name, parent);
    endfunction : new
  
   virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    <%for(var i = 0; i < obj.DutInfo.nNativeInterfacePorts; i++){%>
        ccp_flush_seq_<%=i%> = ioaiu_csr_flush_all_seq_<%=i%>::type_id::create("ccp_flush_seq_<%=i%>");
        cfg_ccp_seq_<%=i%> = ioaiu_csr_cfg_ccp_seq_<%=i%>::type_id::create("cfg_ccp_seq_<%=i%>");
        ioaiu_idle_seq_<%=i%> = ioaiu_wait_for_idle_<%=i%>::type_id::create("ioaiu_idle_seq_<%=i%>");
    <%}%>
   endfunction:build_phase  

    task run_phase (uvm_phase phase);
        // INIT
        <%for(var i = 0; i < obj.DutInfo.nNativeInterfacePorts; i++){%>
        cfg_ccp_seq_<%=i%>.model    = mp_env.m_env[0].m_regs;
        ccp_flush_seq_<%=i%>.model  = mp_env.m_env[0].m_regs;
        ioaiu_idle_seq_<%=i%>.model  = mp_env.m_env[0].m_regs;
        <%}%>
        
        //............................... STEP 1 : run txn with lookupen =0 & allocen=0..................................//
        `uvm_info(get_type_name(), "Step1 LookupEN=0 and AllocEn=0", UVM_NONE)
        super.run_phase(phase);

         //............................... STEP 2 : run txn with lookupen =1 & allocen=0..................................//
        `uvm_info(get_type_name(), "Step2 LookupEN=1 and AllocEn=0", UVM_NONE)
        pctcr_reg_config(1,0);
        fork
            begin
               generate_snoop();
            end
            begin
               fork
                 <%for(var i = 0; i < obj.DutInfo.nNativeInterfacePorts; i++){%>
                     begin
                      phase.raise_objection(this, "Start AIU m_master_pipelined_seq 2/6");
                      `ifndef USE_VIP_SNPS
                     `uvm_info(get_type_name(), $sformatf("master_pipelined_seq REstarted 2/6"), UVM_NONE)
        			if($test$plusargs("constraint_traffic_to_single_core")) begin
					if (select_core == (<%=i%>))
                            		m_master_pipelined_seq[<%=i%>].start(null); 
				end else begin
                            	m_master_pipelined_seq[<%=i%>].start(null); // FIXME: SAI MP - the 2 sequences must be in fork join
				end
                      `else
                                svt_axi_item_helper::disable_boot_addr();
                                axi_mstr_seq.start(io_subsys_mstr_agnt_seqr_a[0]); 
                      `endif
                     phase.drop_objection(this, "Finish AIU m_master_pipelined_seq[<%=i%>] 2/6");
                     end
                 <%}%>
               join
            end
         join

        //............................... STEP 3 : run txn with lookupen =1 & allocen=1..................................//
        `uvm_info(get_type_name(), "Step3 LookupEN=1 and AllocEn=1", UVM_NONE)
        pctcr_reg_config(1,1);
        fork
            begin
               generate_snoop();
            end
            begin
               fork
                 <%for(var i = 0; i < obj.DutInfo.nNativeInterfacePorts; i++){%>
                     begin
                     phase.raise_objection(this, "Start AIU m_master_pipelined_seq 3/6");
                     `ifndef USE_VIP_SNPS 
                     `uvm_info(get_type_name(), $sformatf("master_pipelined_seq REstarted 3/6"), UVM_NONE)
        			if($test$plusargs("constraint_traffic_to_single_core")) begin
					if (select_core == (<%=i%>))
                            		m_master_pipelined_seq[<%=i%>].start(null); 
				end else begin
                            	m_master_pipelined_seq[<%=i%>].start(null); // FIXME: SAI MP - the 2 sequences must be in fork join
				end
                      `else
                                 svt_axi_item_helper::disable_boot_addr();
                                 axi_mstr_seq.start(io_subsys_mstr_agnt_seqr_a[0]);
                       `endif
                     phase.drop_objection(this, "Finish AIU m_master_pipelined_seq[<%=i%>] 3/6");
                     end
                 <%}%>
               join
            end
         join
        //............................... STEP 3 Wait for ioaiu idle CONC-12297 ..................................//
          `uvm_info(get_type_name(), "Step3 Wait for ioaiu idle sequence", UVM_NONE)
          fork
               <%for(var i = 0; i < obj.DutInfo.nNativeInterfacePorts; i++){%>
               begin
               phase.raise_objection(this, "wait for ioaiu idle");
               ioaiu_idle_seq_<%=i%>.start(mp_env.m_env[0].m_apb_agent.m_apb_sequencer);
               phase.drop_objection(this, "wait for ioaiu idle");
               end
               <%}%>
          join

        
        //............................... STEP 3 :Collect ncbu cache entries ..................................//
        //Taking snapshot of ncbu cache on PCTCR proxy cache alloc=1
         <%for(var i = 0; i < obj.DutInfo.nNativeInterfacePorts; i++){%>
            `uvm_info(get_type_name(), $sformatf("After Step 3/6 num_ncbu_cache<%=i%> contents:%0d", mp_env.m_env[<%=i%>].m_scb.m_ncbu_cache_q.size()), UVM_NONE)
            for(int i=0;i<mp_env.m_env[<%=i%>].m_scb.m_ncbu_cache_q.size;i++) begin
                m_ncbu_cache_allocEn_q[<%=i%>].push_back(mp_env.m_env[<%=i%>].m_scb.m_ncbu_cache_q[i]);
               //`uvm_info(get_type_name(), $sformatf("Core<%=i%> After Step 3/6 AllocEn contents num_ncbu_cache<%=i%> :%0h", m_ncbu_cache_allocEn_q[<%=i%>][i].addr), UVM_NONE)
            end
        <%}%>
        //............................... STEP 4 : run txn with lookupen =1 & allocen=0..................................//
        `uvm_info(get_type_name(), "Step4 LookupEN=1 and AllocEn=0", UVM_NONE)
        pctcr_reg_config(1,0);
        fork
            begin
               generate_snoop();
            end
            begin
               fork
                 <%for(var i = 0; i < obj.DutInfo.nNativeInterfacePorts; i++){%>
                     begin
                     phase.raise_objection(this, "Start AIU m_master_pipelined_seq 4/6");
                      `ifndef USE_VIP_SNPS
                     `uvm_info(get_type_name(), $sformatf("master_pipelined_seq REstarted 4/6"), UVM_NONE)
        			if($test$plusargs("constraint_traffic_to_single_core")) begin
					if (select_core == (<%=i%>))
                            		m_master_pipelined_seq[<%=i%>].start(null); 
				end else begin
                            	m_master_pipelined_seq[<%=i%>].start(null); // FIXME: SAI MP - the 2 sequences must be in fork join
				end
                           `else
                                  svt_axi_item_helper::disable_boot_addr();
                                  axi_mstr_seq.start(io_subsys_mstr_agnt_seqr_a[0]); 
                            `endif

                     phase.drop_objection(this, "Finish AIU m_master_pipelined_seq[<%=i%>] 4/6");
                     end
                 <%}%>
               join
            end
         join
       
        //............................... STEP 4 :Collect ncbu cache entries ..................................//
        //Taking snapshot of ncbu cache on PCTCR proxy cache alloc=0
        <%for(var i = 0; i < obj.DutInfo.nNativeInterfacePorts; i++){%>
            m_ncbu_cache_allocDis_q[<%=i%>]={};
            for(int i=0;i<mp_env.m_env[<%=i%>].m_scb.m_ncbu_cache_q.size;i++) begin
                m_ncbu_cache_allocDis_q[<%=i%>].push_back(mp_env.m_env[<%=i%>].m_scb.m_ncbu_cache_q[i]); 
            //`uvm_info(get_type_name(), $sformatf("Core<%=i%> After Step 4/6 Alloc_Disable contents num_ncbu_cache<%=i%> :%0h", m_ncbu_cache_allocDis_q[<%=i%>][i].addr), UVM_NONE)
            end
        <%}%>
        //............................... STEP 4 :Compare ncbu cache entries ..................................//
        <%for(var i = 0; i < obj.DutInfo.nNativeInterfacePorts; i++){%>
          if (m_system_bfm_seq.k_num_snp.get_value()==0) begin   // No snoop Txn
            int m_ncbu_cache_allocDis_size;
            temp_index={};
            `uvm_info(get_type_name(), $sformatf("Core<%=i%>Step 4/6 Allocated entries while alloc was disabled ncbu_q size %0d at allocEn=0 ncbu_q size %0d at allocEn=1",m_ncbu_cache_allocDis_q[<%=i%>].size(),m_ncbu_cache_allocEn_q[<%=i%>].size()), UVM_NONE)
            m_ncbu_cache_allocDis_size=m_ncbu_cache_allocDis_q[<%=i%>].size();
            //checker for q size mismatch
            //#Check.IOAIU.ccp_switch_on_off
            if( m_ncbu_cache_allocDis_q[<%=i%>].size() != m_ncbu_cache_allocEn_q[<%=i%>].size() ) begin 
                 `uvm_error("CCP_SWITCH_ON_OFF", $sformatf("Core<%=i%> Step 4/6 cache allocation mismatch  ncbu_q size %0d at allocEn=1 ncbu_q size %0d at allocEn=0",m_ncbu_cache_allocEn_q[<%=i%>].size(),m_ncbu_cache_allocDis_q[<%=i%>].size()));
            end

            for(int j=0; j<m_ncbu_cache_allocDis_size;j++) begin
                temp_index=m_ncbu_cache_allocDis_q[<%=i%>].find_first_index() with(item.addr == m_ncbu_cache_allocEn_q[<%=i%>][j].addr); 
                if( temp_index.size() !=1 ) begin 
                     `uvm_error("CCP_SWITCH_ON_OFF", $sformatf("Core<%=i%> Step 4/6 multiple match found actual ncbu_q size %0d at allocEn=1 ncbu_q size %0d at allocEn=9",m_ncbu_cache_allocEn_q[<%=i%>].size(),m_ncbu_cache_allocDis_q[<%=i%>].size()));
                end else begin
                m_ncbu_cache_allocDis_q[<%=i%>].delete(temp_index[0]);
               //`uvm_info(get_type_name(), $sformatf("Core<%=i%> Step 4/6 Deleting cache entry for address %0h",m_ncbu_cache_allocEn_q[<%=i%>][j].addr), UVM_NONE)
                end
            end
          end
        <%}%>
        //............................... STEP 4 :Start Flush sequence ..................................//
        `uvm_info(get_type_name(), "Step4 Start Flush sequence", UVM_NONE)
        phase.raise_objection(this, "Flush the proxy cache");
        fork
        <%for(var i = 0; i < obj.DutInfo.nNativeInterfacePorts; i++){%>
        ccp_flush_seq_<%=i%>.disable_check = 1;
        ccp_flush_seq_<%=i%>.start(mp_env.m_env[0].m_apb_agent.m_apb_sequencer);
        <%}%>
        join
        phase.drop_objection(this, "Flush the proxy cache");
        
        <%for(var i = 0; i < obj.DutInfo.nNativeInterfacePorts; i++){%>
            `uvm_info(get_type_name(), $sformatf("After cache_flush_seq num_ncbu_cache<%=i%> contents:%0d", mp_env.m_env[<%=i%>].m_scb.m_ncbu_cache_q.size()), UVM_HIGH)
        <%}%>
        //............................... STEP 4 :Random traffic ..................................//
        fork
            begin
               generate_snoop();
            end
            begin
               fork
                 <%for(var i = 0; i < obj.DutInfo.nNativeInterfacePorts; i++){%>
                     begin
                     phase.raise_objection(this, "Start AIU m_master_pipelined_seq 4/6");
                      `ifndef USE_VIP_SNPS
                     `uvm_info(get_type_name(), $sformatf("master_pipelined_seq REstarted 4/6"), UVM_NONE)
        			if($test$plusargs("constraint_traffic_to_single_core")) begin
					if (select_core == (<%=i%>))
                            		m_master_pipelined_seq[<%=i%>].start(null); 
				end else begin
                            	m_master_pipelined_seq[<%=i%>].start(null); // FIXME: SAI MP - the 2 sequences must be in fork join
				end
                         `else
                                  svt_axi_item_helper::disable_boot_addr();
                                  axi_mstr_seq.start(io_subsys_mstr_agnt_seqr_a[0]);
                          `endif
                     phase.drop_objection(this, "Finish AIU m_master_pipelined_seq[<%=i%>] 4/6");
                     end
                 <%}%>
               join
            end
         join
        //............................... STEP 5 :run txn with lookupen =0 & allocen=0 ..................................//
        `uvm_info(get_type_name(), "Step5 Disable ALLOCEN & LOOKUPEN", UVM_NONE)
        pctcr_reg_config(0,0);
        fork
            begin
               generate_snoop();
            end
            begin
               fork
                 <%for(var i = 0; i < obj.DutInfo.nNativeInterfacePorts; i++){%>
                     begin
                     phase.raise_objection(this, "Start AIU m_master_pipelined_seq 5/6");
                     `ifndef USE_VIP_SNPS
                     `uvm_info(get_type_name(), $sformatf("master_pipelined_seq REstarted 5/6"), UVM_NONE)
        			if($test$plusargs("constraint_traffic_to_single_core")) begin
					if (select_core == (<%=i%>))
                            		m_master_pipelined_seq[<%=i%>].start(null); 
				end else begin
                            	m_master_pipelined_seq[<%=i%>].start(null); // FIXME: SAI MP - the 2 sequences must be in fork join
				end
                      `else
                                  svt_axi_item_helper::disable_boot_addr();
                                  axi_mstr_seq.start(io_subsys_mstr_agnt_seqr_a[0]);
                     `endif
                     phase.drop_objection(this, "Finish AIU m_master_pipelined_seq[<%=i%>] 5/6");
                     end
                 <%}%>
               join
            end
         join

        

        //............................... STEP 6 :run txn with lookupen =1 & allocen=1 ..................................//
        `uvm_info(get_type_name(), "Step6 Enable ALLOCEN & LOOKUPEN", UVM_NONE)
        pctcr_reg_config(1,1);
        fork
            begin
               generate_snoop();
            end
            begin
               fork
                 <%for(var i = 0; i < obj.DutInfo.nNativeInterfacePorts; i++){%>
                     begin
                     phase.raise_objection(this, "Start AIU m_master_pipelined_seq 6/6");
                      `ifndef USE_VIP_SNPS
                     `uvm_info(get_type_name(), $sformatf("master_pipelined_seq REstarted 6/6"), UVM_NONE)
        			if($test$plusargs("constraint_traffic_to_single_core")) begin
					if (select_core == (<%=i%>))
                            		m_master_pipelined_seq[<%=i%>].start(null); 
				end else begin
                            	m_master_pipelined_seq[<%=i%>].start(null); // FIXME: SAI MP - the 2 sequences must be in fork join
				end
                      `else
                                  svt_axi_item_helper::disable_boot_addr();
                                  axi_mstr_seq.start(io_subsys_mstr_agnt_seqr_a[0]);
                      `endif
                     phase.drop_objection(this, "Finish AIU m_master_pipelined_seq[<%=i%>] 6/6");
                     end
                 <%}%>
               join
            end
         join
    endtask : run_phase
    task pctcr_reg_config(bit lookupEN, bit allocEN);
            fork
                <%for(var i = 0; i < obj.DutInfo.nNativeInterfacePorts; i++){%>
                begin
                    cfg_ccp_seq_<%=i%>.ccp_lookupen=lookupEN;
                    cfg_ccp_seq_<%=i%>.ccp_allocen=allocEN;    
                    cfg_ccp_seq_<%=i%>.start(mp_env.m_env[0].m_apb_agent.m_apb_sequencer);
                end
                <%}%>
            join
        endtask
        task generate_snoop();
                 m_system_bfm_seq.snoop_count =0;
                 m_system_bfm_seq.create_snoop_req(); // regenerate snoop req
        endtask
      
  
endclass : ioaiu_ccp_switch_on_off

class ioaiu_ccp_switch_on_off_onfly extends bring_up_test;

    `uvm_component_utils(ioaiu_ccp_switch_on_off_onfly)
  
    <%for(var i = 0; i < obj.DutInfo.nNativeInterfacePorts; i++){%>
    ioaiu_csr_flush_all_seq_<%=i%> ccp_flush_seq_<%=i%>;
    ioaiu_csr_cfg_ccp_seq_<%=i%> cfg_ccp_seq_<%=i%>;
    <%}%>
    int total_snp_send;
    int nbr_of_step = 5; // step1: lookupen & allocen = 1 / step2: lo=1 al=0 / step3: flush with lo=1 al=0 / step4: lo=0 al=0 /step5: lo&al=1

    function new(string name = "ioaiu_ccp_switch_on_off_onfly", uvm_component parent = null);
      super.new(name, parent);
    endfunction : new
  
   virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    <%for(var i = 0; i < obj.DutInfo.nNativeInterfacePorts; i++){%>
    ccp_flush_seq_<%=i%> = ioaiu_csr_flush_all_seq_<%=i%>::type_id::create("ccp_flush_seq_<%=i%>");
    cfg_ccp_seq_<%=i%> = ioaiu_csr_cfg_ccp_seq_<%=i%>::type_id::create("cfg_ccp_seq_<%=i%>");
    <%}%>
   endfunction:build_phase  

    task run_phase (uvm_phase phase);

         // preliminary check
         total_snp_send =  m_system_bfm_seq.k_num_snp.get_value();
         if (!total_snp_send || (total_snp_send <50)) `uvm_error(get_type_name(),"+k_num_snoop MUST BE SET with value > 50")

        // INIT
        <%for(var i = 0; i < obj.DutInfo.nNativeInterfacePorts; i++){%>
        cfg_ccp_seq_<%=i%>.model    = mp_env.m_env[0].m_regs;
        ccp_flush_seq_<%=i%>.model  = mp_env.m_env[0].m_regs;
        <%}%>
        
        // run read,write & snopp txn
            fork
                begin
                super.run_phase(phase);
                end
            join_none

        for (int step=1;step<nbr_of_step;step++) // cf comment on  nbr_of_step declaration
        begin:_for_loop 
        wait(m_system_bfm_seq.snoop_count > (total_snp_send/nbr_of_step)*step); // use the snoop count as timing reference
            <%for(var i = 0; i < obj.DutInfo.nNativeInterfacePorts; i++){%>
            fork
                begin:_fork<%=i%>
                    case (step)
                        4: cfg_ccp_seq_<%=i%>.ccp_lookupen=0;
                        default: cfg_ccp_seq_<%=i%>.ccp_lookupen=1;
                    endcase
                    case (step)
                        2,3,4:cfg_ccp_seq_<%=i%>.ccp_allocen=0;
                        default: cfg_ccp_seq_<%=i%>.ccp_allocen=1;
                    endcase
                    `uvm_info(get_type_name(), $sformatf("Step:%0d lookupen:%0d allocen:%0d",step,cfg_ccp_seq_<%=i%>.ccp_lookupen,cfg_ccp_seq_<%=i%>.ccp_allocen), UVM_NONE)
                    cfg_ccp_seq_<%=i%>.start(mp_env.m_env[0].m_apb_agent.m_apb_sequencer);
                    if (step == 3) begin:_flush_ccp<%=i%>
                        // flush ccp 
                      // flush ccp 
                        // flush ccp 
                      // flush ccp 
                        // flush ccp 
                      // flush ccp 
                        // flush ccp 
                      // flush ccp 
                        // flush ccp 
                      // flush ccp 
                        // flush ccp 
                      // flush ccp 
                        // flush ccp 
                      // flush ccp 
                        // flush ccp 
                      // flush ccp 
                        // flush ccp 
                        `uvm_info(get_type_name(), $sformatf("Step%0d: Flush the proxy cache",step), UVM_NONE)
                        ccp_flush_seq_<%=i%>.start(mp_env.m_env[0].m_apb_agent.m_apb_sequencer);
                        if (aiu_scb_en) begin
                            //FIXME : Need to expand to multiple cores - SAI MP
                            mp_env.m_env[0].m_scb.m_ncbu_cache_q.delete(); // flush the scoreboard cache
                        end
                    end:_flush_ccp<%=i%>
                end:_fork<%=i%>
            join_none
            <%}%>
        end:_for_loop  
    endtask : run_phase
  
endclass : ioaiu_ccp_switch_on_off_onfly
<%}%>

