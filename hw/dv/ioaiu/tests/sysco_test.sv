`include "base_test.sv"
class sysco_test extends base_test;

	`uvm_component_utils(sysco_test)
  	ace_cache_model  m_ace_cache_model[<%=obj.DutInfo.nNativeInterfacePorts%>];
	ioaiu_csr_attach_seq_0 attach_seq, reattach_seq;
	ioaiu_csr_detach_seq_0 detach_seq;
    <%for ( let i=0; i<obj.DutInfo.nNativeInterfacePorts; i++) {%>
        io_aiu_default_reset_seq_<%=i%> default_seq_<%=i%>;
    <%}%>
  	int random_delay;
	bit enable_attach_error, enable_detach_error;

    uvm_event_pool ev_pool 			= uvm_event_pool::get_global_pool();
    <%for ( let i=0; i<obj.DutInfo.nNativeInterfacePorts; i++) {%>
    uvm_event ev_random_traffic_done_<%=i%> = ev_pool.get("ev_random_traffic_done_<%=i%>");
    <%}%>
<%if((obj.DutInfo.orderedWriteObservation == true) || (obj.fnNativeInterface === "ACELITE-E" && (obj.DutInfo.cmpInfo.nDvmSnpInFlight > 0)) || (obj.fnNativeInterface == "ACE") || ((obj.fnNativeInterface == "AXI4" || obj.fnNativeInterface == "AXI5") && (obj.DutInfo.useCache))) { %>
    uvm_event ev_agent_is_attached		= ev_pool.get("ev_agent_is_attached_<%=obj.DutInfo.FUnitId%>");
    uvm_event ev_agent_is_detached  	= ev_pool.get("ev_agent_is_detached_<%=obj.DutInfo.FUnitId%>");
    uvm_event ev_agent_is_attach_error	= ev_pool.get("ev_agent_is_attach_error_<%=obj.DutInfo.FUnitId%>");
	uvm_event ev_agent_is_detach_error  = ev_pool.get("ev_agent_is_detach_error_<%=obj.DutInfo.FUnitId%>");
	uvm_event ev_sysco_all_sys_req_sent = ev_pool.get("ev_sysco_all_sys_req_sent_<%=obj.DutInfo.FUnitId%>");

<% } %>					
	uvm_event ev_start_detach_seq   = ev_pool.get("ev_start_detach_seq");

  	//new
	function new(string name = "sysco_test", uvm_component parent=null);
    	super.new(name,parent);
	endfunction: new

	//build_phase
	virtual function void build_phase(uvm_phase phase);
		super.build_phase(phase);
    
    	//uvm_config_db#(ioaiu_env)::set(this,"*","env_handle",env);

	`ifndef USE_VIP_SNPS  
        <%for(var i = 0; i < obj.DutInfo.nNativeInterfacePorts; i++){%>
    	m_ace_cache_model[<%=i%>] = new();
        <%}%>
	`endif

	//instantiate the csr seq
<% if (obj.INHOUSE_APB_VIP) { %>
	     <%for(let i = 0; i < obj.DutInfo.nNativeInterfacePorts; i++){%>

		default_seq_<%=i%> = io_aiu_default_reset_seq_<%=i%>::type_id::create("default_seq_<%=i%>");
    
    	default_seq_<%=i%>.dvm_resp_order = this.dvm_resp_order;
    	default_seq_<%=i%>.tctrlr  = this.tctrlr;
    	default_seq_<%=i%>.topcr0  = this.topcr0;
    	default_seq_<%=i%>.topcr1  = this.topcr1;
    	default_seq_<%=i%>.tubr  = this.tubr;
    	default_seq_<%=i%>.tubmr = this.tubmr;
		<% if (obj.DutInfo.useCache) {%>
		//TMP legacy remove when scorebaord updated on case lookupen=0
		default_seq_<%=i%>.ccp_lookupen  = 1;
		default_seq_<%=i%>.ccp_allocen   = 1;
		<%}%>
		<%}%>
	    //run the attach sequence by default.
        attach_seq = ioaiu_csr_attach_seq_0::type_id::create("ioaiu_csr_attach_seq");
        reattach_seq = ioaiu_csr_attach_seq_0::type_id::create("ioaiu_csr_reattach_seq");
        detach_seq = ioaiu_csr_detach_seq_0::type_id::create("ioaiu_csr_detach_seq");
<% } %>
		if($test$plusargs("enable_attach_error")) begin 
			enable_attach_error = 1'b1;
		end else begin
			enable_attach_error = 1'b0;
		end

		if($test$plusargs("enable_detach_error")) begin 
			enable_detach_error = 1'b1;
		end else begin
			enable_detach_error = 1'b0;
		end

		if (enable_attach_error || enable_detach_error) begin 
		<%if(obj.NO_SMI === undefined) { %>
		<% var NSMIIFTX = obj.nSmiTx;
		for (var i = 0; i < NSMIIFTX; i++)
			for (var j = 0; j < obj.AiuInfo[0].smiPortParams.tx[i].params.fnMsgClass.length; j++) { 
				if("sys_rsp_tx_" == obj.AiuInfo[0].smiPortParams.tx[i].params.fnMsgClass[j]) {%>
					m_smi_agent_cfg.m_smi<%=i%>_tx_port_config.k_delay_min.set_value(100);
					m_smi_agent_cfg.m_smi<%=i%>_tx_port_config.k_delay_max.set_value(1000);
					m_smi_agent_cfg.m_smi<%=i%>_tx_port_config.k_burst_pct.set_value(0);
				<% } %>
			<% } %>
		<% } %>
		end
	endfunction : build_phase
  

	//run_phase
	task run_phase (uvm_phase phase);

`ifndef USE_VIP_SNPS  
		axi_master_pipelined_seq nc_txns_before_attach[<%=obj.DutInfo.nNativeInterfacePorts%>];
     	axi_master_pipelined_seq nc_txns_after_detach[<%=obj.DutInfo.nNativeInterfacePorts%>];
     	axi_master_pipelined_seq all_txns_after_attach[<%=obj.DutInfo.nNativeInterfacePorts%>];
     	axi_master_pipelined_seq all_txns_after_reattach[<%=obj.DutInfo.nNativeInterfacePorts%>];
<% if(obj.fnNativeInterface == 'ACE') { %>
		ace_master_cache_flush_seq ace_cache_flush_seq;
<% } %>
<% if (obj.DutInfo.useCache) { %>
    <%for ( let i=0; i<obj.DutInfo.nNativeInterfacePorts; i++) {%>
	ioaiu_csr_flush_all_seq_<%=i%> iocache_flushall_seq_<%=i%>;
    <%}%>
<% } %>

`endif

/*<%if((((obj.fnNativeInterface === "ACELITE-E") || (obj.fnNativeInterface === "ACE-LITE")) && (obj.DutInfo.cmpInfo.nDvmSnpInFlight > 0)) || (obj.fnNativeInterface == "ACE")) { %>
		axi_master_snoop_seq m_master_snoop_seq[<%=obj.DutInfo.nNativeInterfacePorts%>];
<%for(var i = 0; i < obj.DutInfo.nNativeInterfacePorts; i++){%>
		m_master_snoop_seq[<%=i%>] = axi_master_snoop_seq::type_id::create("m_master_snoop_seq_<%=i%>");
<% } %>
<% } %>*/

`ifndef USE_VIP_SNPS  
<%for(var i = 0; i < obj.DutInfo.nNativeInterfacePorts; i++){%>
		nc_txns_before_attach[<%=i%>]     	  = axi_master_pipelined_seq::type_id::create("nc_txns_before_attach_<%=i%>");
		nc_txns_before_attach[<%=i%>].core_id = <%=i%>;
		nc_txns_after_detach[<%=i%>] 	  = axi_master_pipelined_seq::type_id::create("nc_txns_after_detach_<%=i%>");
		nc_txns_after_detach[<%=i%>].core_id = <%=i%>;
		all_txns_after_attach[<%=i%>]   = axi_master_pipelined_seq::type_id::create("all_txns_after_attach_<%=i%>");
		all_txns_after_attach[<%=i%>].core_id = <%=i%>;
		all_txns_after_reattach[<%=i%>] = axi_master_pipelined_seq::type_id::create("all_txns_after_reattach_<%=i%>");
		all_txns_after_reattach[<%=i%>].core_id = <%=i%>;
<% if (obj.DutInfo.useCache) { %>
        iocache_flushall_seq_<%=i%> = ioaiu_csr_flush_all_seq_<%=i%>::type_id::create("iocache_flushall_seq_<%=i%>");
<% } %>
<% } %>
<% if(obj.fnNativeInterface == 'ACE') { %>
		ace_cache_flush_seq        = ace_master_cache_flush_seq::type_id::create("ace_cache_flush_seq");
      	ace_cache_flush_seq.m_write_addr_chnl_seqr     = mp_env.m_env[0].m_axi_master_agent.m_write_addr_chnl_seqr;
      	ace_cache_flush_seq.m_write_data_chnl_seqr     = mp_env.m_env[0].m_axi_master_agent.m_write_data_chnl_seqr;
      	ace_cache_flush_seq.m_write_resp_chnl_seqr     = mp_env.m_env[0].m_axi_master_agent.m_write_resp_chnl_seqr;
      	ace_cache_flush_seq.m_ace_cache_model          = m_ace_cache_model[0];
<% } %>
`endif
<%for(var i = 0; i < obj.DutInfo.nNativeInterfacePorts; i++){%>
    	uvm_config_db#(ioaiu_scoreboard)::set(uvm_root::get(), "*", "ioaiu_scb_<%=i%>", mp_env.m_env[<%=i%>].m_scb);
<%}%>

		super.run_phase(phase);

        <%for(var i = 0; i < obj.DutInfo.nNativeInterfacePorts; i++){%>
		m_ace_cache_model[<%=i%>].prob_unq_cln_to_unq_dirty           = prob_unq_cln_to_unq_dirty;
      	m_ace_cache_model[<%=i%>].prob_unq_cln_to_invalid             = prob_unq_cln_to_invalid;
      	m_ace_cache_model[<%=i%>].total_outstanding_coh_writes        = total_outstanding_coh_writes;
      	m_ace_cache_model[<%=i%>].total_min_ace_cache_size            = total_min_ace_cache_size;
      	m_ace_cache_model[<%=i%>].total_max_ace_cache_size            = total_max_ace_cache_size;
      	m_ace_cache_model[<%=i%>].size_of_wr_queue_before_flush       = size_of_wr_queue_before_flush;
      	m_ace_cache_model[<%=i%>].wt_expected_end_state               = wt_expected_end_state;
      	m_ace_cache_model[<%=i%>].wt_legal_end_state_with_sf          = wt_legal_end_state_with_sf;
      	m_ace_cache_model[<%=i%>].wt_legal_end_state_without_sf       = wt_legal_end_state_without_sf;
      	m_ace_cache_model[<%=i%>].wt_expected_start_state             = wt_expected_start_state;
      	m_ace_cache_model[<%=i%>].wt_legal_start_state                = wt_legal_start_state;
      	m_ace_cache_model[<%=i%>].wt_lose_cache_line_on_snps          = wt_lose_cache_line_on_snps;
      	m_ace_cache_model[<%=i%>].wt_keep_drty_cache_line_on_snps     = wt_keep_drty_cache_line_on_snps;
      	m_ace_cache_model[<%=i%>].prob_respond_to_snoop_coll_with_wr  = prob_respond_to_snoop_coll_with_wr;
      	m_ace_cache_model[<%=i%>].prob_was_unique_snp_resp            = prob_was_unique_snp_resp;
      	m_ace_cache_model[<%=i%>].prob_was_unique_always0_snp_resp    = prob_was_unique_always0_snp_resp;
      	m_ace_cache_model[<%=i%>].prob_dataxfer_snp_resp_on_clean_hit = prob_dataxfer_snp_resp_on_clean_hit;
      	m_ace_cache_model[<%=i%>].prob_ace_wr_ix_start_state          = prob_ace_wr_ix_start_state;
      	m_ace_cache_model[<%=i%>].prob_ace_rd_ix_start_state          = prob_ace_rd_ix_start_state;
      	m_ace_cache_model[<%=i%>].prob_cache_flush_mode_per_1k        = prob_cache_flush_mode_per_1k;
      	m_ace_cache_model[<%=i%>].prob_ace_coh_win_error              = prob_ace_coh_win_error;
      	m_ace_cache_model[<%=i%>].prob_of_new_set                     = prob_of_new_set.get_value();

	`ifndef USE_VIP_SNPS  
      	nc_txns_before_attach[<%=i%>].m_read_addr_chnl_seqr     = mp_env.m_env[<%=i%>].m_axi_master_agent.m_read_addr_chnl_seqr;
      	nc_txns_before_attach[<%=i%>].m_read_data_chnl_seqr     = mp_env.m_env[<%=i%>].m_axi_master_agent.m_read_data_chnl_seqr;
      	nc_txns_before_attach[<%=i%>].m_write_addr_chnl_seqr    = mp_env.m_env[<%=i%>].m_axi_master_agent.m_write_addr_chnl_seqr;
      	nc_txns_before_attach[<%=i%>].m_write_data_chnl_seqr    = mp_env.m_env[<%=i%>].m_axi_master_agent.m_write_data_chnl_seqr;
      	nc_txns_before_attach[<%=i%>].m_write_resp_chnl_seqr    = mp_env.m_env[<%=i%>].m_axi_master_agent.m_write_resp_chnl_seqr;
      	nc_txns_before_attach[<%=i%>].m_ace_cache_model         = m_ace_cache_model[<%=i%>];
        nc_txns_before_attach[<%=i%>].k_num_read_req            = mp_env.m_env[<%=i%>].m_axi_master_agent.m_cfg.k_num_read_req;
		nc_txns_before_attach[<%=i%>].k_num_write_req           = mp_env.m_env[<%=i%>].m_axi_master_agent.m_cfg.k_num_write_req;


    	nc_txns_before_attach[<%=i%>].wt_ace_rdnosnp            	 = 100;
    	nc_txns_before_attach[<%=i%>].wt_ace_rdonce             	 = 0;
      	nc_txns_before_attach[<%=i%>].wt_ace_rdshrd                  = 0;
      	nc_txns_before_attach[<%=i%>].wt_ace_rdcln                   = 0;
      	nc_txns_before_attach[<%=i%>].wt_ace_rdnotshrddty            = 0;
      	nc_txns_before_attach[<%=i%>].wt_ace_rdunq                   = 0;
      	nc_txns_before_attach[<%=i%>].wt_ace_clnunq                  = 0;
      	nc_txns_before_attach[<%=i%>].wt_ace_mkunq                   = 0;
      	nc_txns_before_attach[<%=i%>].wt_ace_dvm_msg                 = 0;
      	nc_txns_before_attach[<%=i%>].wt_ace_clnshrd                 = 0;
      	nc_txns_before_attach[<%=i%>].wt_ace_clninvl                 = 0;
      	nc_txns_before_attach[<%=i%>].wt_ace_mkinvl                  = 0;
      	nc_txns_before_attach[<%=i%>].wt_ace_rd_bar                  = 0;
    	nc_txns_before_attach[<%=i%>].wt_ace_wrunq                   = 0;
    	nc_txns_before_attach[<%=i%>].wt_ace_wrlnunq                 = 0;
    	nc_txns_before_attach[<%=i%>].wt_ace_wrnosnp                 = 100;
      	nc_txns_before_attach[<%=i%>].wt_ace_wrcln                   = 0;
      	nc_txns_before_attach[<%=i%>].wt_ace_wrbk                    = 0;
      	nc_txns_before_attach[<%=i%>].wt_ace_evct                    = 0;
      	nc_txns_before_attach[<%=i%>].wt_ace_wrevct                  = 0;
      	nc_txns_before_attach[<%=i%>].wt_ace_wr_bar                  = 0;
      	nc_txns_before_attach[<%=i%>].no_updates                     = 1;
      	nc_txns_before_attach[<%=i%>].wt_ace_atm_str                 = 0;
      	nc_txns_before_attach[<%=i%>].wt_ace_atm_ld                  = 0;
      	nc_txns_before_attach[<%=i%>].wt_ace_atm_swap                = 0;
      	nc_txns_before_attach[<%=i%>].wt_ace_atm_comp                = 0;
      	nc_txns_before_attach[<%=i%>].wt_ace_ptl_stash               = 0;
      	nc_txns_before_attach[<%=i%>].wt_ace_full_stash              = 0;
      	nc_txns_before_attach[<%=i%>].wt_ace_shared_stash            = 0;
      	nc_txns_before_attach[<%=i%>].wt_ace_unq_stash               = 0;
      	nc_txns_before_attach[<%=i%>].wt_ace_rd_cln_invld            = 0;
      	nc_txns_before_attach[<%=i%>].wt_ace_rd_make_invld           = 0;
      	nc_txns_before_attach[<%=i%>].wt_ace_clnshrd_pers            = 0;
      	nc_txns_before_attach[<%=i%>].wt_illegal_op_addr             = 0; 
      	nc_txns_before_attach[<%=i%>].wt_ace_stash_trans             = 0;

      	nc_txns_after_detach[<%=i%>].m_read_addr_chnl_seqr     = mp_env.m_env[<%=i%>].m_axi_master_agent.m_read_addr_chnl_seqr;
      	nc_txns_after_detach[<%=i%>].m_read_data_chnl_seqr     = mp_env.m_env[<%=i%>].m_axi_master_agent.m_read_data_chnl_seqr;
      	nc_txns_after_detach[<%=i%>].m_write_addr_chnl_seqr    = mp_env.m_env[<%=i%>].m_axi_master_agent.m_write_addr_chnl_seqr;
      	nc_txns_after_detach[<%=i%>].m_write_data_chnl_seqr    = mp_env.m_env[<%=i%>].m_axi_master_agent.m_write_data_chnl_seqr;
      	nc_txns_after_detach[<%=i%>].m_write_resp_chnl_seqr    = mp_env.m_env[<%=i%>].m_axi_master_agent.m_write_resp_chnl_seqr;
      	nc_txns_after_detach[<%=i%>].m_ace_cache_model         = m_ace_cache_model[<%=i%>];
        nc_txns_after_detach[<%=i%>].k_num_read_req            = mp_env.m_env[<%=i%>].m_axi_master_agent.m_cfg.k_num_read_req;
		nc_txns_after_detach[<%=i%>].k_num_write_req           = mp_env.m_env[<%=i%>].m_axi_master_agent.m_cfg.k_num_write_req;

<% if (obj.fnNativeInterface == "AXI4" || obj.fnNativeInterface == "AXI5") { %>
   <% if (obj.NcMode == 0) { %>
   		// AXI4 NcMode (non-coherent mode) = 0, only send coherent traffic
    	nc_txns_after_detach[<%=i%>].wt_ace_rdnosnp            = 0;
    	nc_txns_after_detach[<%=i%>].wt_ace_rdonce             = 0;
   <% } else { %>
   // AXI4 NcMode (non-coherent mode) = 1, only send non-coherent traffic
        nc_txns_after_detach[<%=i%>].wt_ace_rdnosnp            = 100;
        nc_txns_after_detach[<%=i%>].wt_ace_rdonce             = 0;
   <% } %>
<% } else { %>
    	nc_txns_after_detach[<%=i%>].wt_ace_rdnosnp            = 100;
    	nc_txns_after_detach[<%=i%>].wt_ace_rdonce             = 0;
<% } %>					  
      	nc_txns_after_detach[<%=i%>].wt_ace_rdshrd                  = 0;
      	nc_txns_after_detach[<%=i%>].wt_ace_rdcln                   = 0;
      	nc_txns_after_detach[<%=i%>].wt_ace_rdnotshrddty            = 0;
      	nc_txns_after_detach[<%=i%>].wt_ace_rdunq                   = 0;
      	nc_txns_after_detach[<%=i%>].wt_ace_clnunq                  = 0;
      	nc_txns_after_detach[<%=i%>].wt_ace_mkunq                   = 0;
      	nc_txns_after_detach[<%=i%>].wt_ace_dvm_msg                 = 0;
      	nc_txns_after_detach[<%=i%>].wt_ace_clnshrd                 = 0;
      	nc_txns_after_detach[<%=i%>].wt_ace_clninvl                 = 0;
      	nc_txns_after_detach[<%=i%>].wt_ace_mkinvl                  = 0;
      	nc_txns_after_detach[<%=i%>].wt_ace_rd_bar                  = 0;
<% if (obj.fnNativeInterface == "AXI4" || obj.fnNativeInterface == "AXI5") { %>
   <% if (obj.NcMode == 0) { %>
   		// AXI4 NcMode (non-coherent mode) = 0, only send coherent traffic
    	nc_txns_after_detach[<%=i%>].wt_ace_wrnosnp                 = 0;
    	nc_txns_after_detach[<%=i%>].wt_ace_wrunq                   = 0;
   <% } else { %>
   // AXI4 NcMode (non-coherent mode) = 1, only send non-coherent traffic
   	nc_txns_after_detach[<%=i%>].wt_ace_wrnosnp                 = 100;
    	nc_txns_after_detach[<%=i%>].wt_ace_wrunq                   = 0;
   <% } %>
    	nc_txns_after_detach[<%=i%>].wt_ace_wrlnunq                 = 0;
<% } else { %>
    	nc_txns_after_detach[<%=i%>].wt_ace_wrnosnp                 = 100;
    	nc_txns_after_detach[<%=i%>].wt_ace_wrunq                   = 0;
    	nc_txns_after_detach[<%=i%>].wt_ace_wrlnunq                 = 0;
<% } %>					  
     	nc_txns_after_detach[<%=i%>].wt_ace_wrunq                   = 0;
      	nc_txns_after_detach[<%=i%>].wt_ace_wrlnunq                 = 0;
      	nc_txns_after_detach[<%=i%>].wt_ace_wrcln                   = 0;
      	nc_txns_after_detach[<%=i%>].wt_ace_wrbk                    = 0;
      	nc_txns_after_detach[<%=i%>].wt_ace_evct                    = 0;
      	nc_txns_after_detach[<%=i%>].wt_ace_wrevct                  = 0;
      	nc_txns_after_detach[<%=i%>].wt_ace_wr_bar                  = 0;
      	nc_txns_after_detach[<%=i%>].no_updates                     = 1;
      	nc_txns_after_detach[<%=i%>].wt_ace_atm_str                 = 0;
      	nc_txns_after_detach[<%=i%>].wt_ace_atm_ld                  = 0;
      	nc_txns_after_detach[<%=i%>].wt_ace_atm_swap                = 0;
      	nc_txns_after_detach[<%=i%>].wt_ace_atm_comp                = 0;
      	nc_txns_after_detach[<%=i%>].wt_ace_ptl_stash               = 0;
      	nc_txns_after_detach[<%=i%>].wt_ace_full_stash              = 0;
      	nc_txns_after_detach[<%=i%>].wt_ace_shared_stash            = 0;
      	nc_txns_after_detach[<%=i%>].wt_ace_unq_stash               = 0;
      	nc_txns_after_detach[<%=i%>].wt_ace_rd_cln_invld            = 0;
      	nc_txns_after_detach[<%=i%>].wt_ace_rd_make_invld           = 0;
      	nc_txns_after_detach[<%=i%>].wt_ace_clnshrd_pers            = 0;
      	nc_txns_after_detach[<%=i%>].wt_illegal_op_addr             = 0; 
      	nc_txns_after_detach[<%=i%>].wt_ace_stash_trans             = 0;

		all_txns_after_attach[<%=i%>].m_read_addr_chnl_seqr          = mp_env.m_env[<%=i%>].m_axi_master_agent.m_read_addr_chnl_seqr;
		all_txns_after_attach[<%=i%>].m_read_data_chnl_seqr          = mp_env.m_env[<%=i%>].m_axi_master_agent.m_read_data_chnl_seqr;
        all_txns_after_attach[<%=i%>].m_write_addr_chnl_seqr         = mp_env.m_env[<%=i%>].m_axi_master_agent.m_write_addr_chnl_seqr;
        all_txns_after_attach[<%=i%>].m_write_data_chnl_seqr         = mp_env.m_env[<%=i%>].m_axi_master_agent.m_write_data_chnl_seqr;
        all_txns_after_attach[<%=i%>].m_write_resp_chnl_seqr         = mp_env.m_env[<%=i%>].m_axi_master_agent.m_write_resp_chnl_seqr;
        all_txns_after_attach[<%=i%>].m_ace_cache_model              = m_ace_cache_model[<%=i%>];
        all_txns_after_attach[<%=i%>].wt_ace_rdnosnp                 = mp_env.m_env[<%=i%>].m_axi_master_agent.m_cfg.wt_ace_rdnosnp;
        all_txns_after_attach[<%=i%>].wt_ace_rdonce                  = mp_env.m_env[<%=i%>].m_axi_master_agent.m_cfg.wt_ace_rdonce;
        all_txns_after_attach[<%=i%>].wt_ace_rdshrd                  = mp_env.m_env[<%=i%>].m_axi_master_agent.m_cfg.wt_ace_rdshrd;
        all_txns_after_attach[<%=i%>].wt_ace_rdcln                   = mp_env.m_env[<%=i%>].m_axi_master_agent.m_cfg.wt_ace_rdcln;
        all_txns_after_attach[<%=i%>].wt_ace_rdnotshrddty            = mp_env.m_env[<%=i%>].m_axi_master_agent.m_cfg.wt_ace_rdnotshrddty;
        all_txns_after_attach[<%=i%>].wt_ace_rdunq                   = mp_env.m_env[<%=i%>].m_axi_master_agent.m_cfg.wt_ace_rdunq;
        all_txns_after_attach[<%=i%>].wt_ace_clnunq                  = mp_env.m_env[<%=i%>].m_axi_master_agent.m_cfg.wt_ace_clnunq;
        all_txns_after_attach[<%=i%>].wt_ace_mkunq                   = mp_env.m_env[<%=i%>].m_axi_master_agent.m_cfg.wt_ace_mkunq;
        all_txns_after_attach[<%=i%>].wt_ace_dvm_msg                 = mp_env.m_env[<%=i%>].m_axi_master_agent.m_cfg.wt_ace_dvm_msg;
        all_txns_after_attach[<%=i%>].wt_ace_dvm_sync                = mp_env.m_env[<%=i%>].m_axi_master_agent.m_cfg.wt_ace_dvm_sync;
        all_txns_after_attach[<%=i%>].wt_ace_clnshrd                 = mp_env.m_env[<%=i%>].m_axi_master_agent.m_cfg.wt_ace_clnshrd;
        all_txns_after_attach[<%=i%>].wt_ace_clninvl                 = mp_env.m_env[<%=i%>].m_axi_master_agent.m_cfg.wt_ace_clninvl;
        all_txns_after_attach[<%=i%>].wt_ace_mkinvl                  = mp_env.m_env[<%=i%>].m_axi_master_agent.m_cfg.wt_ace_mkinvl;
        all_txns_after_attach[<%=i%>].wt_ace_rd_bar                  = mp_env.m_env[<%=i%>].m_axi_master_agent.m_cfg.wt_ace_rd_bar;
        all_txns_after_attach[<%=i%>].wt_ace_wrnosnp                 = mp_env.m_env[<%=i%>].m_axi_master_agent.m_cfg.wt_ace_wrnosnp;
        all_txns_after_attach[<%=i%>].wt_ace_wrunq                   = mp_env.m_env[<%=i%>].m_axi_master_agent.m_cfg.wt_ace_wrunq;
        all_txns_after_attach[<%=i%>].wt_ace_wrlnunq                 = mp_env.m_env[<%=i%>].m_axi_master_agent.m_cfg.wt_ace_wrlnunq;
        all_txns_after_attach[<%=i%>].wt_ace_wrcln                   = mp_env.m_env[<%=i%>].m_axi_master_agent.m_cfg.wt_ace_wrcln;
        all_txns_after_attach[<%=i%>].wt_ace_wrbk                    = mp_env.m_env[<%=i%>].m_axi_master_agent.m_cfg.wt_ace_wrbk;
        all_txns_after_attach[<%=i%>].wt_ace_evct                    = mp_env.m_env[<%=i%>].m_axi_master_agent.m_cfg.wt_ace_evct;
        all_txns_after_attach[<%=i%>].wt_ace_wrevct                  = mp_env.m_env[<%=i%>].m_axi_master_agent.m_cfg.wt_ace_wrevct;
        all_txns_after_attach[<%=i%>].wt_ace_wr_bar                  = mp_env.m_env[<%=i%>].m_axi_master_agent.m_cfg.wt_ace_wr_bar;
        all_txns_after_attach[<%=i%>].k_num_read_req                 = mp_env.m_env[<%=i%>].m_axi_master_agent.m_cfg.k_num_read_req;
	all_txns_after_attach[<%=i%>].k_num_write_req                = mp_env.m_env[<%=i%>].m_axi_master_agent.m_cfg.k_num_write_req;
	all_txns_after_attach[<%=i%>].no_updates                     = mp_env.m_env[<%=i%>].m_axi_master_agent.m_cfg.no_updates;
	all_txns_after_attach[<%=i%>].wt_ace_atm_str                 = mp_env.m_env[<%=i%>].m_axi_master_agent.m_cfg.wt_ace_atm_str;
	all_txns_after_attach[<%=i%>].wt_ace_atm_ld                  = mp_env.m_env[<%=i%>].m_axi_master_agent.m_cfg.wt_ace_atm_ld;
	all_txns_after_attach[<%=i%>].wt_ace_atm_swap                = mp_env.m_env[<%=i%>].m_axi_master_agent.m_cfg.wt_ace_atm_swap;
	all_txns_after_attach[<%=i%>].wt_ace_atm_comp                = mp_env.m_env[<%=i%>].m_axi_master_agent.m_cfg.wt_ace_atm_comp;
	all_txns_after_attach[<%=i%>].wt_ace_ptl_stash               = mp_env.m_env[<%=i%>].m_axi_master_agent.m_cfg.wt_ace_ptl_stash;
	all_txns_after_attach[<%=i%>].wt_ace_full_stash              = mp_env.m_env[<%=i%>].m_axi_master_agent.m_cfg.wt_ace_full_stash;
	all_txns_after_attach[<%=i%>].wt_ace_shared_stash            = mp_env.m_env[<%=i%>].m_axi_master_agent.m_cfg.wt_ace_shared_stash;
	all_txns_after_attach[<%=i%>].wt_ace_unq_stash               = mp_env.m_env[<%=i%>].m_axi_master_agent.m_cfg.wt_ace_unq_stash;
	all_txns_after_attach[<%=i%>].wt_ace_rd_cln_invld            = mp_env.m_env[<%=i%>].m_axi_master_agent.m_cfg.wt_ace_rd_cln_invld;
	all_txns_after_attach[<%=i%>].wt_ace_rd_make_invld           = mp_env.m_env[<%=i%>].m_axi_master_agent.m_cfg.wt_ace_rd_make_invld;
	all_txns_after_attach[<%=i%>].wt_ace_clnshrd_pers            = mp_env.m_env[<%=i%>].m_axi_master_agent.m_cfg.wt_ace_clnshrd_pers;
	all_txns_after_attach[<%=i%>].wt_illegal_op_addr             = wt_illegal_op_addr; 
     	all_txns_after_attach[<%=i%>].wt_ace_stash_trans             = 0; // AWSNOOP='b1110 StashOp:StashTranslation is not supported in Ncore 3.x


	all_txns_after_reattach[<%=i%>].m_read_addr_chnl_seqr          = mp_env.m_env[<%=i%>].m_axi_master_agent.m_read_addr_chnl_seqr;
	all_txns_after_reattach[<%=i%>].m_read_data_chnl_seqr          = mp_env.m_env[<%=i%>].m_axi_master_agent.m_read_data_chnl_seqr;
        all_txns_after_reattach[<%=i%>].m_write_addr_chnl_seqr         = mp_env.m_env[<%=i%>].m_axi_master_agent.m_write_addr_chnl_seqr;
        all_txns_after_reattach[<%=i%>].m_write_data_chnl_seqr         = mp_env.m_env[<%=i%>].m_axi_master_agent.m_write_data_chnl_seqr;
        all_txns_after_reattach[<%=i%>].m_write_resp_chnl_seqr         = mp_env.m_env[<%=i%>].m_axi_master_agent.m_write_resp_chnl_seqr;
        all_txns_after_reattach[<%=i%>].m_ace_cache_model              = m_ace_cache_model[<%=i%>];
        all_txns_after_reattach[<%=i%>].wt_ace_rdnosnp                 = mp_env.m_env[<%=i%>].m_axi_master_agent.m_cfg.wt_ace_rdnosnp;
        all_txns_after_reattach[<%=i%>].wt_ace_rdonce                  = mp_env.m_env[<%=i%>].m_axi_master_agent.m_cfg.wt_ace_rdonce;
        all_txns_after_reattach[<%=i%>].wt_ace_rdshrd                  = mp_env.m_env[<%=i%>].m_axi_master_agent.m_cfg.wt_ace_rdshrd;
        all_txns_after_reattach[<%=i%>].wt_ace_rdcln                   = mp_env.m_env[<%=i%>].m_axi_master_agent.m_cfg.wt_ace_rdcln;
        all_txns_after_reattach[<%=i%>].wt_ace_rdnotshrddty            = mp_env.m_env[<%=i%>].m_axi_master_agent.m_cfg.wt_ace_rdnotshrddty;
        all_txns_after_reattach[<%=i%>].wt_ace_rdunq                   = mp_env.m_env[<%=i%>].m_axi_master_agent.m_cfg.wt_ace_rdunq;
        all_txns_after_reattach[<%=i%>].wt_ace_clnunq                  = mp_env.m_env[<%=i%>].m_axi_master_agent.m_cfg.wt_ace_clnunq;
        all_txns_after_reattach[<%=i%>].wt_ace_mkunq                   = mp_env.m_env[<%=i%>].m_axi_master_agent.m_cfg.wt_ace_mkunq;
        all_txns_after_reattach[<%=i%>].wt_ace_dvm_msg                 = mp_env.m_env[<%=i%>].m_axi_master_agent.m_cfg.wt_ace_dvm_msg;
        all_txns_after_reattach[<%=i%>].wt_ace_dvm_sync                = mp_env.m_env[<%=i%>].m_axi_master_agent.m_cfg.wt_ace_dvm_sync;
        all_txns_after_reattach[<%=i%>].wt_ace_clnshrd                 = mp_env.m_env[<%=i%>].m_axi_master_agent.m_cfg.wt_ace_clnshrd;
        all_txns_after_reattach[<%=i%>].wt_ace_clninvl                 = mp_env.m_env[<%=i%>].m_axi_master_agent.m_cfg.wt_ace_clninvl;
        all_txns_after_reattach[<%=i%>].wt_ace_mkinvl                  = mp_env.m_env[<%=i%>].m_axi_master_agent.m_cfg.wt_ace_mkinvl;
        all_txns_after_reattach[<%=i%>].wt_ace_rd_bar                  = mp_env.m_env[<%=i%>].m_axi_master_agent.m_cfg.wt_ace_rd_bar;
        all_txns_after_reattach[<%=i%>].wt_ace_wrnosnp                 = mp_env.m_env[<%=i%>].m_axi_master_agent.m_cfg.wt_ace_wrnosnp;
        all_txns_after_reattach[<%=i%>].wt_ace_wrunq                   = mp_env.m_env[<%=i%>].m_axi_master_agent.m_cfg.wt_ace_wrunq;
        all_txns_after_reattach[<%=i%>].wt_ace_wrlnunq                 = mp_env.m_env[<%=i%>].m_axi_master_agent.m_cfg.wt_ace_wrlnunq;
        all_txns_after_reattach[<%=i%>].wt_ace_wrcln                   = mp_env.m_env[<%=i%>].m_axi_master_agent.m_cfg.wt_ace_wrcln;
        all_txns_after_reattach[<%=i%>].wt_ace_wrbk                    = mp_env.m_env[<%=i%>].m_axi_master_agent.m_cfg.wt_ace_wrbk;
        all_txns_after_reattach[<%=i%>].wt_ace_evct                    = mp_env.m_env[<%=i%>].m_axi_master_agent.m_cfg.wt_ace_evct;
        all_txns_after_reattach[<%=i%>].wt_ace_wrevct                  = mp_env.m_env[<%=i%>].m_axi_master_agent.m_cfg.wt_ace_wrevct;
        all_txns_after_reattach[<%=i%>].wt_ace_wr_bar                  = mp_env.m_env[<%=i%>].m_axi_master_agent.m_cfg.wt_ace_wr_bar;
        all_txns_after_reattach[<%=i%>].k_num_read_req                 = mp_env.m_env[<%=i%>].m_axi_master_agent.m_cfg.k_num_read_req;
	all_txns_after_reattach[<%=i%>].k_num_write_req                = mp_env.m_env[<%=i%>].m_axi_master_agent.m_cfg.k_num_write_req;
	all_txns_after_reattach[<%=i%>].no_updates                     = mp_env.m_env[<%=i%>].m_axi_master_agent.m_cfg.no_updates;
	all_txns_after_reattach[<%=i%>].wt_ace_atm_str                 = mp_env.m_env[<%=i%>].m_axi_master_agent.m_cfg.wt_ace_atm_str;
	all_txns_after_reattach[<%=i%>].wt_ace_atm_ld                  = mp_env.m_env[<%=i%>].m_axi_master_agent.m_cfg.wt_ace_atm_ld;
	all_txns_after_reattach[<%=i%>].wt_ace_atm_swap                = mp_env.m_env[<%=i%>].m_axi_master_agent.m_cfg.wt_ace_atm_swap;
	all_txns_after_reattach[<%=i%>].wt_ace_atm_comp                = mp_env.m_env[<%=i%>].m_axi_master_agent.m_cfg.wt_ace_atm_comp;
	all_txns_after_reattach[<%=i%>].wt_ace_ptl_stash               = mp_env.m_env[<%=i%>].m_axi_master_agent.m_cfg.wt_ace_ptl_stash;
	all_txns_after_reattach[<%=i%>].wt_ace_full_stash              = mp_env.m_env[<%=i%>].m_axi_master_agent.m_cfg.wt_ace_full_stash;
	all_txns_after_reattach[<%=i%>].wt_ace_shared_stash            = mp_env.m_env[<%=i%>].m_axi_master_agent.m_cfg.wt_ace_shared_stash;
	all_txns_after_reattach[<%=i%>].wt_ace_unq_stash               = mp_env.m_env[<%=i%>].m_axi_master_agent.m_cfg.wt_ace_unq_stash;
	all_txns_after_reattach[<%=i%>].wt_ace_rd_cln_invld            = mp_env.m_env[<%=i%>].m_axi_master_agent.m_cfg.wt_ace_rd_cln_invld;
	all_txns_after_reattach[<%=i%>].wt_ace_rd_make_invld           = mp_env.m_env[<%=i%>].m_axi_master_agent.m_cfg.wt_ace_rd_make_invld;
	all_txns_after_reattach[<%=i%>].wt_ace_clnshrd_pers            = mp_env.m_env[<%=i%>].m_axi_master_agent.m_cfg.wt_ace_clnshrd_pers;
	all_txns_after_reattach[<%=i%>].wt_illegal_op_addr             = wt_illegal_op_addr; 
     	all_txns_after_reattach[<%=i%>].wt_ace_stash_trans             = 0; // AWSNOOP='b1110 StashOp:StashTranslation is not supported in Ncore 3.x
`endif

/*<%if((((obj.fnNativeInterface === "ACELITE-E") || (obj.fnNativeInterface === "ACE-LITE")) && (obj.DutInfo.cmpInfo.nDvmSnpInFlight > 0)) || (obj.fnNativeInterface == "ACE")) { %>
      	m_master_snoop_seq[<%=i%>].m_read_addr_chnl_seqr               = mp_env.m_env[<%=i%>].m_axi_master_agent.m_read_addr_chnl_seqr;
      	m_master_snoop_seq[<%=i%>].m_read_data_chnl_seqr               = mp_env.m_env[<%=i%>].m_axi_master_agent.m_read_data_chnl_seqr;
      	m_master_snoop_seq[<%=i%>].m_snoop_addr_chnl_seqr              = mp_env.m_env[<%=i%>].m_axi_master_agent.m_snoop_addr_chnl_seqr;
      	m_master_snoop_seq[<%=i%>].m_snoop_data_chnl_seqr              = mp_env.m_env[<%=i%>].m_axi_master_agent.m_snoop_data_chnl_seqr;
      	m_master_snoop_seq[<%=i%>].m_snoop_resp_chnl_seqr              = mp_env.m_env[<%=i%>].m_axi_master_agent.m_snoop_resp_chnl_seqr;
      	m_master_snoop_seq[<%=i%>].m_ace_cache_model                   = m_ace_cache_model[<%=i%>]; 
      	// m_master_snoop_seq.prob_ace_snp_resp_error             = mp_env.m_env[<%=i%>].m_axi_master_agent.m_cfg.prob_ace_snp_resp_error; 
<% } %>*/
<% } %>

<% if (obj.INHOUSE_APB_VIP) { %>
	     <%for(let i = 0; i < obj.DutInfo.nNativeInterfacePorts; i++){%>
    	default_seq_<%=i%>.model        = mp_env.m_env[0].m_regs;
	    <%}%>
    	attach_seq.model         = mp_env.m_env[0].m_regs;
    	reattach_seq.model       = mp_env.m_env[0].m_regs;
    	detach_seq.model         = mp_env.m_env[0].m_regs;


<%for(var i = 0; i < obj.DutInfo.nNativeInterfacePorts; i++){%>
    	attach_seq.scb_en[<%=i%>]  	  = m_env_cfg[<%=i%>].has_scoreboard;
		reattach_seq.scb_en[<%=i%>]	  = m_env_cfg[<%=i%>].has_scoreboard; 
		detach_seq.scb_en[<%=i%>]	  = m_env_cfg[<%=i%>].has_scoreboard; 
    	
    	attach_seq.ioaiu_scb[<%=i%>] 	= mp_env.m_env[<%=i%>].m_scb;
    	reattach_seq.ioaiu_scb[<%=i%>]  = mp_env.m_env[<%=i%>].m_scb;
    	detach_seq.ioaiu_scb[<%=i%>]  	= mp_env.m_env[<%=i%>].m_scb;
<% } %>


`ifndef USE_VIP_SNPS  
<% if (obj.DutInfo.useCache) { %>
<%for(var i = 0; i < obj.DutInfo.nNativeInterfacePorts; i++){%>
    	iocache_flushall_seq_<%=i%>.model  = mp_env.m_env[0].m_regs;
<% } %>
<% } %>
`endif
<% } %>
 
<% if(obj.INHOUSE_APB_VIP) { %>
     	`uvm_info("run_main", "default_seq started",UVM_NONE)
     	phase.raise_objection(this, "Start default_seq");
     	fork
	<%for(let i = 0; i < obj.DutInfo.nNativeInterfacePorts; i++){%>
			default_seq_<%=i%>.start(mp_env.m_env[0].m_apb_agent.m_apb_sequencer);
	<%}%>
     	join
     	#100ns;
     	phase.drop_objection(this, "Finish default_seq");
      	`uvm_info("run_main", "default_seq finished",UVM_NONE)
<% } %>

	fork
<%if((((obj.fnNativeInterface === "ACELITE-E") || (obj.fnNativeInterface === "ACE-LITE")) && (obj.DutInfo.cmpInfo.nDvmSnpInFlight > 0)) || (obj.fnNativeInterface == "ACE")) { %>
		/*snoop channel sequence on nativeInterface*/
	/*	begin 
			`uvm_info("run_main", "master_snoop_seq started",UVM_NONE)
			fork
			<%for(var i = 0; i < obj.DutInfo.nNativeInterfacePorts; i++){%>
				m_master_snoop_seq[<%=i%>].start(null);
			<% } %>
        	join
			`uvm_info("run_main", "master_snoop_seq finished",UVM_NONE)
		end */
<% } %>		

		/* below thread forks off noncoh cmds and attach seq*/
		begin
			fork
				`ifndef USE_VIP_SNPS  
				begin //nc_txns_before_attach 
					`uvm_info("run_main", "nc_txns_before_attach started",UVM_NONE)
					phase.raise_objection(this, "Start AIU noncoh_cmds_only_master_seq");
                    fork
        			<%for(var i = 0; i < obj.DutInfo.nNativeInterfacePorts; i++){%>
						nc_txns_before_attach[<%=i%>].start(null);
        			<%}%>
                	join
					phase.drop_objection(this, "Finish AIU noncoh_cmds_only_master_seq");
					`uvm_info("run_main", "nc_txns_before_attach finished",UVM_NONE)
				end
				`endif

				begin //attach-thread
					<%if (obj.INHOUSE_APB_VIP) { %>
					<%if((obj.DutInfo.orderedWriteObservation == true) || ((obj.fnNativeInterface === "ACELITE-E") && (obj.DutInfo.cmpInfo.nDvmSnpInFlight > 0)) ||
					(obj.fnNativeInterface == "ACE") || ((obj.fnNativeInterface == "AXI4" || obj.fnNativeInterface == "AXI5") && obj.DutInfo.useCache)) { %>
					random_delay = $urandom_range(100, 10);
					#(<%=obj.Clocks[0].params.period%>ps * random_delay); //wait for random cycles
					`uvm_info("run_main", "ioaiu_csr_attach_seq_started", UVM_NONE)
					phase.raise_objection(this, "Start attach_seq");
					attach_seq.start(mp_env.m_env[0].m_apb_agent.m_apb_sequencer);
					`uvm_info("run_main", "ioaiu_csr_attach_seq_finished", UVM_NONE)
					phase.drop_objection(this, "Finish attach_seq");
					<% } %>
					<% } %>					
				end

			join
			`uvm_info("run_main", "thread1:nc_txns_before_attach_seq and attach_seq done",UVM_NONE)
		end

		begin //coherent and noncoherent cmds 
		`ifndef USE_VIP_SNPS  
			if( ! enable_attach_error) begin 
				<%if((obj.DutInfo.orderedWriteObservation == true) || ((obj.fnNativeInterface === "ACELITE-E") && (obj.DutInfo.cmpInfo.nDvmSnpInFlight > 0)) ||
				(obj.fnNativeInterface == "ACE") || ((obj.fnNativeInterface == "AXI4" || obj.fnNativeInterface == "AXI5") && (obj.DutInfo.useCache))) { %>
				ev_agent_is_attached.wait_trigger();
				<% } %>					
				
				`uvm_info("run_main", "all_txns_after_attach started",UVM_NONE)
				phase.raise_objection(this, "Start all_txns_after_attach seq");
				fork
        		<%for(var i = 0; i < obj.DutInfo.nNativeInterfacePorts; i++){%>
					all_txns_after_attach[<%=i%>].start(null);
				<% } %>					
				join
				phase.drop_objection(this, "Finish all_txns_after_attach seq");
				`uvm_info("run_main", "all_txns_after_attach  finished",UVM_NONE)
	
				<%if(   ((obj.fnNativeInterface === "ACELITE-E") && (obj.DutInfo.cmpInfo.nDvmSnpInFlight > 0)) ||
					(obj.DutInfo.orderedWriteObservation == true) ||
					(obj.fnNativeInterface == "ACE") || 
					((obj.fnNativeInterface == "AXI4" || obj.fnNativeInterface == "AXI5") && obj.DutInfo.useCache)) { %>
				ev_start_detach_seq.trigger();
				<% } %>
			end
			`uvm_info("run_main", "thread2:all_txns_after_attach_seq done",UVM_NONE)
        `endif
		end

		begin //detach thread

<% if((obj.DutInfo.orderedWriteObservation == true) || ((obj.fnNativeInterface === "ACELITE-E") && (obj.DutInfo.cmpInfo.nDvmSnpInFlight > 0)) || (obj.fnNativeInterface == "ACE") || ((obj.fnNativeInterface == "AXI4" || obj.fnNativeInterface == "AXI5") && obj.DutInfo.useCache)) { %>
			if ($test$plusargs("enable_detach_seq")) begin
				ev_start_detach_seq.wait_trigger();
				<%if(obj.fnNativeInterface === "ACE") {%>
							`ifndef USE_VIP_SNPS  
					//cache flush sequence for ACE processor
					random_delay = $urandom_range(50, 10);
					#(<%=obj.Clocks[0].params.period%>ps * random_delay); //wait for random cycles
					`uvm_info("run_main", "ace_cache_flush_seq started", UVM_NONE)
					phase.raise_objection(this, "Start ace_cache_flush_seq");
					ace_cache_flush_seq.start(null);
					phase.drop_objection(this, "Finish ace_cache_flush_seq");
					`uvm_info("run_main", "ace_cache_flush_seq finished", UVM_NONE)
							`endif
				<% } %>

`ifndef USE_VIP_SNPS  
	<% if (obj.INHOUSE_APB_VIP && obj.DutInfo.useCache) { %>
					//cache flush sequence for IO cache
					random_delay = $urandom_range(50, 10);
					#(<%=obj.Clocks[0].params.period%>ps * random_delay); //wait for random cycles
				
					`uvm_info("run_main", "iocache_flushall_seq started", UVM_NONE)
					phase.raise_objection(this, "Start iocache_flushall_seq");
					fork
        				<%for(var i = 0; i < obj.DutInfo.nNativeInterfacePorts; i++){%>
						iocache_flushall_seq_<%=i%>.disable_check = 1;	
						iocache_flushall_seq_<%=i%>.start(mp_env.m_env[0].m_apb_agent.m_apb_sequencer);
						<% } %>					
					join
					phase.drop_objection(this, "Finish iocache_flushall_seq");
					`uvm_info("run_main", "iocache_flushall_seq finished", UVM_NONE)
	<% } %>
`endif
					random_delay = $urandom_range(50, 1);
					#(<%=obj.Clocks[0].params.period%>ps * random_delay); //wait for random cycles

					phase.raise_objection(this, "Start detach_seq");
    				`uvm_info("run_main", "ioaiu_csr_detach_seq_started", UVM_NONE)
    				detach_seq.start(mp_env.m_env[0].m_apb_agent.m_apb_sequencer);
					`uvm_info("run_main", "ioaiu_csr_detach_seq_finished", UVM_NONE)
					phase.drop_objection(this, "Finish detach_seq");
			end//if ($test$plusargs("enable_detach_seq") || enable_attach_error) 
<% } %>		
			`uvm_info("run_main", "thread3:detach_seq done",UVM_NONE)
		end //detach thread
		
		begin //reattach thread

<%if((obj.DutInfo.orderedWriteObservation == true) || ((obj.fnNativeInterface === "ACELITE-E") && (obj.DutInfo.cmpInfo.nDvmSnpInFlight > 0)) || (obj.fnNativeInterface == "ACE") || ((obj.fnNativeInterface == "AXI4" || obj.fnNativeInterface == "AXI5") && (obj.DutInfo.useCache))) { %>

			fork
				`ifndef USE_VIP_SNPS  
				if ($test$plusargs("enable_reattach_seq")) begin //nc_txns_after_detach
					ev_agent_is_detached.wait_trigger();
					`uvm_info("run_main", "nc_txns_after_detach started",UVM_NONE)
					phase.raise_objection(this, "Start AIU noncoh_cmds_only_master_seq");
                    fork
        			<%for(var i = 0; i < obj.DutInfo.nNativeInterfacePorts; i++){%>
						nc_txns_after_detach[<%=i%>].start(null);
        			<%}%>
                	join
					phase.drop_objection(this, "Finish AIU noncoh_cmds_only_master_seq");
					`uvm_info("run_main", "nc_txns_after_detach finished",UVM_NONE)
				end
        		`endif

<% if (obj.INHOUSE_APB_VIP) { %>
				if ($test$plusargs("enable_reattach_seq")) begin //reattach seq
					ev_agent_is_detached.wait_trigger();
					random_delay = $urandom_range(100, 10);
					#(<%=obj.Clocks[0].params.period%>ps * random_delay); //wait for random cycles
        			phase.raise_objection(this, "Start reattach_seq");
            		`uvm_info("run_main", "ioaiu_csr_reattach_seq_started", UVM_NONE)
            		reattach_seq.start(mp_env.m_env[0].m_apb_agent.m_apb_sequencer);
            		`uvm_info("run_main", "ioaiu_csr_reattach_seq_finished", UVM_NONE)
             		phase.drop_objection(this, "Finish reattach_seq");
				end
<% } %>
			join

<% } %>		
			`uvm_info("run_main", "thread4:reattach_seq done",UVM_NONE)
		end //reattach done

		if ($test$plusargs("enable_reattach_seq")) begin //coherent and noncoherent cmds after reattach
		`ifndef USE_VIP_SNPS  
<%if((obj.DutInfo.orderedWriteObservation == true) || ((obj.fnNativeInterface === "ACELITE-E") && (obj.DutInfo.cmpInfo.nDvmSnpInFlight > 0)) || (obj.fnNativeInterface == "ACE") || ((obj.fnNativeInterface == "AXI4" || obj.fnNativeInterface == "AXI5") && (obj.DutInfo.useCache))) { %>
			ev_agent_is_detached.wait_trigger();
			ev_agent_is_attached.wait_trigger();
<% } %>					
			phase.raise_objection(this, "Start AIU all_txns_after_reattach");
			`uvm_info("run_main", "all_txns_after_reattach started",UVM_NONE)
			fork
        	<%for(var i = 0; i < obj.DutInfo.nNativeInterfacePorts; i++){%>
				all_txns_after_reattach[<%=i%>].start(null);
			<% } %>					
			join
			`uvm_info("run_main", "all_txns_after_reattach finished",UVM_NONE)
			phase.drop_objection(this, "Finish AIU all_txns_after_reattach");
        `endif
			
			`uvm_info("run_main", "thread5:all_txns_after_reattach done",UVM_NONE)
		end

		//begin //In case of attach-error, wait for all sys req sent for next iteration
		//	<%if((((obj.fnNativeInterface === "ACELITE-E") || (obj.fnNativeInterface === "ACE-LITE")) && (obj.DutInfo.cmpInfo.nDvmSnpInFlight > 0)) || (obj.fnNativeInterface == "ACE") || ((obj.fnNativeInterface == "AXI4") && (obj.DutInfo.useCache))) { %>
		//	if (enable_attach_error) begin
		//		phase.raise_objection(this, "Start waiting for all sys req to be sent for next iteration");
		//		ev_agent_is_attach_error.wait_trigger();

		//		if (enable_detach_error) begin
		//			ev_agent_is_detach_error.wait_trigger();
		//		end else begin
		//			ev_agent_is_detached.wait_trigger();					
		//		end

		//		ev_sysco_all_sys_req_sent.wait_trigger();
		//		phase.drop_objection(this, "Finish waiting for all sys req now sent for next iteration");
		//	end
		//	<% } %>					
		//end

	join
	
	begin
		`uvm_info("run_main", "track TransActv started",UVM_NONE)
		phase.raise_objection(this, "Start waiting for TransActv == 0");

		fork
		<%for(var i = 0; i < obj.DutInfo.nNativeInterfacePorts; i++){%>
			begin
				`uvm_info("run_main", "wait for transActv[<%=i%>] de-asserted",UVM_NONE)
				wait(u_csr_probe_vif[<%=+i%>].TransActv == 0);
				`uvm_info("run_main", "transActv[<%=i%>] de-asserted",UVM_NONE)
			end
        <%}%>
		join

		phase.drop_objection(this, "Finish waiting for TransActv == 0");
		`uvm_info("run_main", "track TransActv finished",UVM_NONE)
	end
	endtask : run_phase

	//report_phase
	virtual function void report_phase(uvm_phase phase);
		super.report_phase(phase);
	endfunction: report_phase

endclass: sysco_test


