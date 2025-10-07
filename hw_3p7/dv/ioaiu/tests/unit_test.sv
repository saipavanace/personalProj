class unit_test extends base_test;

    `uvm_component_utils(unit_test)

    ace_cache_model  m_ace_cache_model[<%=obj.DutInfo.nNativeInterfacePorts%>];
    uvm_reg_sequence csr_seq[<%=obj.DutInfo.nNativeInterfacePorts%>];
    uvm_reg_sequence smc_mntop_csr_seq[<%=obj.DutInfo.nNativeInterfacePorts%>];
    uvm_reg_sequence mntop_debug_read_write_seq[<%=obj.DutInfo.nNativeInterfacePorts%>];
    <%for(var i = 0; i < obj.DutInfo.nNativeInterfacePorts; i++){%>
    io_aiu_default_reset_seq_<%=i%> default_seq_<%=i%>;
    <%}%>
    ioaiu_csr_attach_seq_0     sysco_attach_seq;

    int clk_count_en;           // Use for CCTRLR update scenario

    <%if(obj.useResiliency){%>
        // This event triggers if any request is killed when injecting errors
        // to drop all objections and get out of run_phase, resolves hanging tests issue
        uvm_object objectors_list[$];
        uvm_objection objection;
        event kill_test;
        virtual <%=obj.BlockId%>_probe_if u_csr_probe_vif;
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
    function new(string name = "unit_test", uvm_component parent=null);
        super.new(name,parent);
        if($test$plusargs("DISABLE_INHOUSE_ACE_MODEL")) begin
            `define NOT_USE_INHOUSE_ACE_MODEL
            $display("NOT_USE_INHOUSE_ACE_MODEL unit test");
        end else begin
            `undef NOT_USE_INHOUSE_ACE_MODEL
            $display("USE_INHOUSE_ACE_MODEL unit test");
        end
        `uvm_info(name, "fn:new",UVM_NONE)
    endfunction: new

    virtual function void build_phase(uvm_phase phase);
        string  arg_value;
        super.build_phase(phase);

        //uvm_config_db#(ioaiu_env)::set(this,"*","env_handle",env);
        
        //instantiate the csr seq
        <%if(obj.INHOUSE_APB_VIP){%>
            sysco_attach_seq = ioaiu_csr_attach_seq_0::type_id::create("sysco_attach_seq");
            sysco_attach_seq.model  = mp_env.m_env[0].m_regs;
     <%for (let j=0; j<obj.DutInfo.nNativeInterfacePorts; j++) {%>
                        sysco_attach_seq.scb_en[<%=j%>] = m_env_cfg[<%=j%>].has_scoreboard; 
                        <%}%>

            <%for(var i = 0; i < obj.DutInfo.nNativeInterfacePorts; i++){%>
            default_seq_<%=i%> = io_aiu_default_reset_seq_<%=i%>::type_id::create("default_seq_<%=i%>");
            //if($val$plusargs("en_XAIUUEDR_DecErrDetEn"))
            if(clp.get_arg_value("+wt_illegal_op_addr=", arg_value) && arg_value.atoi() > 0)
                default_seq_<%=i%>.en_XAIUUEDR_DecErrDetEn = 1;
            default_seq_<%=i%>.dvm_resp_order = this.dvm_resp_order;
            default_seq_<%=i%>.tctrlr  = this.tctrlr;
            <% if (obj.DutInfo.useCache) {%>
            //legacy set to 1 TODO randomize ?
            if(!($value$plusargs("ccp_lookupen=%0d",default_seq_<%=i%>.ccp_lookupen))) begin
                default_seq_<%=i%>.ccp_lookupen  = 1;
            end
            if(!($value$plusargs("ccp_allocen=%0d",default_seq_<%=i%>.ccp_allocen))) begin
                  default_seq_<%=i%>.ccp_allocen   = 1;
            end
            <%}%>
            default_seq_<%=i%>.topcr0  = this.topcr0;
            default_seq_<%=i%>.topcr1  = this.topcr1;
            default_seq_<%=i%>.tubr  = this.tubr;
            default_seq_<%=i%>.tubmr = this.tubmr;
            <%}%>
        <%}%>

       endfunction : build_phase

    task run_phase (uvm_phase phase);
  		ioaiu_vseq#(<%=obj.AiuInfo[obj.Id].FUnitId%>) m_vseq[<%=obj.DutInfo.nNativeInterfacePorts%>];
        
        <%if((((obj.DutInfo.fnNativeInterface === "ACELITE-E") || (obj.DutInfo.fnNativeInterface === "ACE-LITE")) && (obj.DutInfo.cmpInfo.nDvmSnpInFlight > 0)) || (obj.DutInfo.fnNativeInterface == "ACE")) { %>
        <%for(var i = 0; i < obj.DutInfo.nNativeInterfacePorts; i++){%>
            axi_master_snoop_seq m_master_snoop_seq_<%=i%> = axi_master_snoop_seq::type_id::create("m_master_snoop_seq_<%=i%>");
        <%}%>
        <%}%>
            
        <%for(var i = 0; i < obj.DutInfo.nNativeInterfacePorts; i++){%>
  		m_vseq[<%=i%>] = ioaiu_vseq#(<%=obj.AiuInfo[obj.Id].FUnitId%>)::type_id::create("m_vseq_<%=i%>");
        
        uvm_config_db#(ioaiu_scoreboard)::set(uvm_root::get(), "*", "ioaiu_scb_<%=i%>", mp_env.m_env[<%=i%>].m_scb);
        <%}%>

        super.run_phase(phase);
        
        //update below to use knobs 
        <%for(var i = 0; i < obj.DutInfo.nNativeInterfacePorts; i++){%>
		m_vseq[<%=i%>].m_ace_cache_model.prob_unq_cln_to_unq_dirty           = prob_unq_cln_to_unq_dirty;
        m_vseq[<%=i%>].m_ace_cache_model.prob_unq_cln_to_invalid             = prob_unq_cln_to_invalid;
        m_vseq[<%=i%>].m_ace_cache_model.total_outstanding_coh_writes        = total_outstanding_coh_writes;
        m_vseq[<%=i%>].m_ace_cache_model.total_min_ace_cache_size            = total_min_ace_cache_size;
        m_vseq[<%=i%>].m_ace_cache_model.total_max_ace_cache_size            = total_max_ace_cache_size;
        m_vseq[<%=i%>].m_ace_cache_model.size_of_wr_queue_before_flush       = size_of_wr_queue_before_flush;
        m_vseq[<%=i%>].m_ace_cache_model.wt_expected_end_state               = wt_expected_end_state;
        m_vseq[<%=i%>].m_ace_cache_model.wt_legal_end_state_with_sf          = wt_legal_end_state_with_sf;
        m_vseq[<%=i%>].m_ace_cache_model.wt_legal_end_state_without_sf       = wt_legal_end_state_without_sf;
        m_vseq[<%=i%>].m_ace_cache_model.wt_expected_start_state             = wt_expected_start_state;
        m_vseq[<%=i%>].m_ace_cache_model.wt_legal_start_state                = wt_legal_start_state;
        m_vseq[<%=i%>].m_ace_cache_model.wt_lose_cache_line_on_snps          = wt_lose_cache_line_on_snps;
        m_vseq[<%=i%>].m_ace_cache_model.wt_keep_drty_cache_line_on_snps     = wt_keep_drty_cache_line_on_snps;
        m_vseq[<%=i%>].m_ace_cache_model.prob_respond_to_snoop_coll_with_wr  = prob_respond_to_snoop_coll_with_wr;
        m_vseq[<%=i%>].m_ace_cache_model.prob_was_unique_snp_resp            = prob_was_unique_snp_resp;
        m_vseq[<%=i%>].m_ace_cache_model.prob_was_unique_always0_snp_resp    = prob_was_unique_always0_snp_resp;
        m_vseq[<%=i%>].m_ace_cache_model.prob_dataxfer_snp_resp_on_clean_hit = prob_dataxfer_snp_resp_on_clean_hit;
        m_vseq[<%=i%>].m_ace_cache_model.prob_ace_wr_ix_start_state          = prob_ace_wr_ix_start_state;
        m_vseq[<%=i%>].m_ace_cache_model.prob_ace_rd_ix_start_state          = prob_ace_rd_ix_start_state;
        m_vseq[<%=i%>].m_ace_cache_model.prob_cache_flush_mode_per_1k        = prob_cache_flush_mode_per_1k;
        m_vseq[<%=i%>].m_ace_cache_model.prob_ace_coh_win_error              = prob_ace_coh_win_error;
        m_vseq[<%=i%>].m_ace_cache_model.prob_of_new_set                     = prob_of_new_set.get_value();
        //FIXME : Check if we need any guards
        <%if((((obj.DutInfo.fnNativeInterface === "ACELITE-E") || 
               (obj.DutInfo.fnNativeInterface === "ACE-LITE")) && 
               (obj.DutInfo.cmpInfo.nDvmSnpInFlight > 0)) || 
               (obj.DutInfo.fnNativeInterface == "ACE")){%>
        <%for(var i = 0; i < obj.DutInfo.nNativeInterfacePorts; i++){%>
            m_vseq[<%=i%>].m_ace_cache_model.prob_ace_snp_resp_error             = mp_env.m_env[<%=i%>].m_axi_master_agent.m_cfg.prob_ace_snp_resp_error;
        <%}%>
        <%}%>
				
        <%for(var i = 0; i < obj.DutInfo.nNativeInterfacePorts; i++){%>
        m_vseq[<%=i%>].get_native_interface_read_chnl_seqr_handles(mp_env.m_env[<%=i%>].m_axi_master_agent.m_read_addr_chnl_seqr, mp_env.m_env[<%=i%>].m_axi_master_agent.m_read_data_chnl_seqr);
        m_vseq[<%=i%>].get_native_interface_write_chnl_seqr_handles(mp_env.m_env[<%=i%>].m_axi_master_agent.m_write_addr_chnl_seqr, mp_env.m_env[<%=i%>].m_axi_master_agent.m_write_data_chnl_seqr, mp_env.m_env[<%=i%>].m_axi_master_agent.m_write_resp_chnl_seqr);
            	
        <%}%>
        <%}%>
        		//m_vseq.get_native_interface_write_chnl_seqr_handles();
   //             m_master_pipelined_seq.m_read_addr_chnl_seqr          = env.m_axi_master_agent.m_read_addr_chnl_seqr;
   //             m_master_pipelined_seq.m_read_data_chnl_seqr          = env.m_axi_master_agent.m_read_data_chnl_seqr;
   //             m_master_pipelined_seq.m_write_addr_chnl_seqr         = env.m_axi_master_agent.m_write_addr_chnl_seqr;
   //             m_master_pipelined_seq.m_write_data_chnl_seqr         = env.m_axi_master_agent.m_write_data_chnl_seqr;
   //             m_master_pipelined_seq.m_write_resp_chnl_seqr         = env.m_axi_master_agent.m_write_resp_chnl_seqr;
   //             m_master_pipelined_seq.m_ace_cache_model              = m_ace_cache_model;
   //             m_master_pipelined_seq.wt_ace_rdnosnp                 = env.m_axi_master_agent.m_cfg.wt_ace_rdnosnp;
   //             m_master_pipelined_seq.wt_ace_rdonce                  = env.m_axi_master_agent.m_cfg.wt_ace_rdonce;
   //             m_master_pipelined_seq.wt_ace_rdshrd                  = env.m_axi_master_agent.m_cfg.wt_ace_rdshrd;
   //             m_master_pipelined_seq.wt_ace_rdcln                   = env.m_axi_master_agent.m_cfg.wt_ace_rdcln;
   //             m_master_pipelined_seq.wt_ace_rdnotshrddty            = env.m_axi_master_agent.m_cfg.wt_ace_rdnotshrddty;
   //             m_master_pipelined_seq.wt_ace_rdunq                   = env.m_axi_master_agent.m_cfg.wt_ace_rdunq;
   //             m_master_pipelined_seq.wt_ace_clnunq                  = env.m_axi_master_agent.m_cfg.wt_ace_clnunq;
   //             m_master_pipelined_seq.wt_ace_mkunq                   = env.m_axi_master_agent.m_cfg.wt_ace_mkunq;
   //             m_master_pipelined_seq.wt_ace_dvm_msg                 = env.m_axi_master_agent.m_cfg.wt_ace_dvm_msg;
   //             m_master_pipelined_seq.wt_ace_dvm_sync                = env.m_axi_master_agent.m_cfg.wt_ace_dvm_sync;
   //             m_master_pipelined_seq.wt_ace_clnshrd                 = env.m_axi_master_agent.m_cfg.wt_ace_clnshrd;
   //             m_master_pipelined_seq.wt_ace_clninvl                 = env.m_axi_master_agent.m_cfg.wt_ace_clninvl;
   //             m_master_pipelined_seq.wt_ace_mkinvl                  = env.m_axi_master_agent.m_cfg.wt_ace_mkinvl;
   //             m_master_pipelined_seq.wt_ace_rd_bar                  = env.m_axi_master_agent.m_cfg.wt_ace_rd_bar;
   //             m_master_pipelined_seq.wt_ace_wrnosnp                 = env.m_axi_master_agent.m_cfg.wt_ace_wrnosnp;
   //             m_master_pipelined_seq.wt_ace_wrunq                   = env.m_axi_master_agent.m_cfg.wt_ace_wrunq;
   //             m_master_pipelined_seq.wt_ace_wrlnunq                 = env.m_axi_master_agent.m_cfg.wt_ace_wrlnunq;
   //             m_master_pipelined_seq.wt_ace_wrcln                   = env.m_axi_master_agent.m_cfg.wt_ace_wrcln;
   //             m_master_pipelined_seq.wt_ace_wrbk                    = env.m_axi_master_agent.m_cfg.wt_ace_wrbk;
   //             m_master_pipelined_seq.wt_ace_evct                    = env.m_axi_master_agent.m_cfg.wt_ace_evct;
   //             m_master_pipelined_seq.wt_ace_wrevct                  = env.m_axi_master_agent.m_cfg.wt_ace_wrevct;
   //             m_master_pipelined_seq.wt_ace_wr_bar                  = env.m_axi_master_agent.m_cfg.wt_ace_wr_bar;
   //             m_master_pipelined_seq.k_num_read_req                 = env.m_axi_master_agent.m_cfg.k_num_read_req;
   //             m_master_pipelined_seq.k_num_write_req                = env.m_axi_master_agent.m_cfg.k_num_write_req;
   //             m_master_pipelined_seq.no_updates                     = env.m_axi_master_agent.m_cfg.no_updates;
   //             m_master_pipelined_seq.wt_ace_atm_str                 = env.m_axi_master_agent.m_cfg.wt_ace_atm_str;
   //             m_master_pipelined_seq.wt_ace_atm_ld                  = env.m_axi_master_agent.m_cfg.wt_ace_atm_ld;
   //             m_master_pipelined_seq.wt_ace_atm_swap                = env.m_axi_master_agent.m_cfg.wt_ace_atm_swap;
   //             m_master_pipelined_seq.wt_ace_atm_comp                = env.m_axi_master_agent.m_cfg.wt_ace_atm_comp;
   //             m_master_pipelined_seq.wt_ace_ptl_stash               = env.m_axi_master_agent.m_cfg.wt_ace_ptl_stash;
   //             m_master_pipelined_seq.wt_ace_full_stash              = env.m_axi_master_agent.m_cfg.wt_ace_full_stash;
   //             m_master_pipelined_seq.wt_ace_shared_stash            = env.m_axi_master_agent.m_cfg.wt_ace_shared_stash;
   //             m_master_pipelined_seq.wt_ace_unq_stash               = env.m_axi_master_agent.m_cfg.wt_ace_unq_stash;
   //             m_master_pipelined_seq.wt_ace_rd_cln_invld            = env.m_axi_master_agent.m_cfg.wt_ace_rd_cln_invld;
   //             m_master_pipelined_seq.wt_ace_rd_make_invld           = env.m_axi_master_agent.m_cfg.wt_ace_rd_make_invld;
   //             m_master_pipelined_seq.wt_ace_clnshrd_pers            = env.m_axi_master_agent.m_cfg.wt_ace_clnshrd_pers;
   //             m_master_pipelined_seq.wt_illegal_op_addr             = wt_illegal_op_addr; 
   //             m_master_pipelined_seq.wt_ace_stash_trans             = 0; // AWSNOOP='b1110 StashOp:StashTranslation is not supported in Ncore 3.x
                <%if((((obj.DutInfo.fnNativeInterface === "ACELITE-E") || (obj.DutInfo.fnNativeInterface === "ACE-LITE")) && (obj.DutInfo.cmpInfo.nDvmSnpInFlight > 0)) || (obj.DutInfo.fnNativeInterface == "ACE")) { %>
        <%for(var i = 0; i < obj.DutInfo.nNativeInterfacePorts; i++){%>
                    m_master_snoop_seq_<%=i%>.m_read_addr_chnl_seqr               = mp_env.m_env[<%=i%>].m_axi_master_agent.m_read_addr_chnl_seqr;
                    m_master_snoop_seq_<%=i%>.m_read_data_chnl_seqr               = mp_env.m_env[<%=i%>].m_axi_master_agent.m_read_data_chnl_seqr;
                    m_master_snoop_seq_<%=i%>.m_snoop_addr_chnl_seqr              = mp_env.m_env[<%=i%>].m_axi_master_agent.m_snoop_addr_chnl_seqr;
                    m_master_snoop_seq_<%=i%>.m_snoop_data_chnl_seqr              = mp_env.m_env[<%=i%>].m_axi_master_agent.m_snoop_data_chnl_seqr;
                    m_master_snoop_seq_<%=i%>.m_snoop_resp_chnl_seqr              = mp_env.m_env[<%=i%>].m_axi_master_agent.m_snoop_resp_chnl_seqr;
                    m_master_snoop_seq_<%=i%>.m_ace_cache_model                     = m_ace_cache_model[<%=i%>]; 
                    // m_master_snoop_seq.prob_ace_snp_resp_error             = env.m_axi_master_agent.m_cfg.prob_ace_snp_resp_error; 
                <%}%>
                <%}%>
				 
            <%if(obj.INHOUSE_APB_VIP){%>
                <%for(let i=0; i<obj.DutInfo.nNativeInterfacePorts; i++) {%>
                default_seq_<%=i%>.model       = mp_env.m_env[0].m_regs;
               <% if(obj.testBench == 'io_aiu') { %>
               `ifndef VCS
                if (k_csr_seq) begin
               `else // `ifndef VCS
                if (k_csr_seq != "") begin
               `endif // `ifndef VCS ... `else ... 
               <% } else {%>
                if (k_csr_seq) begin
               <% } %>
                    csr_seq[<%=i%>].model       = mp_env.m_env[0].m_regs;
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
                        smc_mntop_csr_seq[<%=i%>].model       = mp_env.m_env[0].m_regs;
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
                        mntop_debug_read_write_seq[<%=i%>].model       = mp_env.m_env[0].m_regs;
                    end
                <%}%>
                <%}%>
            <%}%>

            <%if(obj.INHOUSE_APB_VIP){%>
                phase.raise_objection(this, "Start default_seq");
                `uvm_info("run_main", "default_seq started",UVM_NONE)
                <%for(let i=0; i<obj.DutInfo.nNativeInterfacePorts; i++) {%>
                default_seq_<%=i%>.start(mp_env.m_env[0].m_apb_agent.m_apb_sequencer);
                <%}%>
                `uvm_info("run_main", "default_seq finished",UVM_NONE)
                #100ns;
                phase.drop_objection(this, "Finish default_seq");
            <%}%>

            <%if(obj.INHOUSE_APB_VIP){%>
                <%if((((obj.DutInfo.fnNativeInterface === "ACELITE-E") || (obj.DutInfo.fnNativeInterface === "ACE-LITE")) && (obj.DutInfo.cmpInfo.nDvmSnpInFlight > 0)) || (obj.DutInfo.fnNativeInterface == "ACE") || ((obj.DutInfo.fnNativeInterface == "AXI4" || obj.DutInfo.fnNativeInterface == "AXI5") && obj.DutInfo.useCache)) { %>
                    begin //attach seq
                        phase.raise_objection(this, "Start attach_seq");
                        `uvm_info("run_main", "ioaiu_csr_attach_seq_started", UVM_NONE)
                        sysco_attach_seq.model = mp_env.m_env[0].m_regs;
                        sysco_attach_seq.start(mp_env.m_env[0].m_apb_agent.m_apb_sequencer);
                        `uvm_info("run_main", "ioaiu_csr_attach_seq_finished", UVM_NONE)
                        phase.drop_objection(this, "Finish attach_seq");
                    end
                <%}%>
            <%}%>	

            fork 
            begin
                phase.raise_objection(this, "Start AIU m_master_pipelined_seq");
                `uvm_info("run_main", "master_pipelined_seq started",UVM_NONE)
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
                                ev_<%=i%>.wait_ptrigger();
                            <%}%>
                        end
                    join
                    // ev.wait_ptrigger();
                    `uvm_info("run_main","Waiting Completed for CSR seq to set the control register",UVM_NONE)
                end
                main_seq_pre_hook(phase); // virtual task
                for(int i=0;i<main_seq_iter;i++) begin:forloop_main_seq_iter // by default main_seq_iter=1
                    main_seq_iter_pre_hook(phase,i); // virtual task
                    if (!smi_rx_stall_en) begin
                        //m_master_pipelined_seq.start(null);
fork
        <%for(var i = 0; i < obj.DutInfo.nNativeInterfacePorts; i++){%>
						m_vseq[<%=i%>].start(null);
        <%}%>
join
                    end
                    main_seq_iter_post_hook(phase,i); // virtual task
                end:forloop_main_seq_iter
                main_seq_post_hook(phase); // virtual task
                main_seq_hook_end_run_phase(phase); // virtual task

                phase.drop_objection(this, "Finish AIU m_master_pipelined_seq");
                `uvm_info("run_main", "master_pipelined_seq finished",UVM_NONE)
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
                                ev_<%=i%>.wait_ptrigger();
                            <%}%>
                        end
                    join
                    // ev.wait_ptrigger();
                    `uvm_info("run_main","Waiting Completed for CSR seq to set the control register",UVM_NONE)
                end
            end		       
            <%if((((obj.DutInfo.fnNativeInterface === "ACELITE-E") || (obj.DutInfo.fnNativeInterface === "ACE-LITE")) && (obj.DutInfo.cmpInfo.nDvmSnpInFlight > 0)) || (obj.DutInfo.fnNativeInterface == "ACE")) { %>          
        <%for(var i = 0; i < obj.DutInfo.nNativeInterfacePorts; i++){%>
	            m_master_snoop_seq_<%=i%>.start(null);
            <%}%>
            <%}%>

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
                    <%for(var i = 0; i < obj.DutInfo.nNativeInterfacePorts; i++){%>
                    csr_seq[<%=i%>].start(mp_env.m_env[0].m_apb_agent.m_apb_sequencer);
                    <%}%>
                    `uvm_info("run_main", "csr_seq finished",UVM_NONE)
                    phase.drop_objection(this, "Finish csr_seq run phase");
                end
            <%}%>

            join
    endtask : run_phase

   virtual function void report_phase(uvm_phase phase);
     super.report_phase(phase);
   endfunction: report_phase

endclass: unit_test
