
//--------------------------------------------------------
//DCE Container
//--------------------------------------------------------
typedef class ncore_cache_model;
typedef class dce_inflight_txns;

class dce_container extends uvm_object;

  `uvm_object_utils(dce_container)

  //Properties
  ncore_cache_model        m_cachelines_st[$];
  dce_inflight_txns        m_inflight_txns[$];
  bit [WSMIMSGID-1:0]      m_msgid_pool_cmdreqs[][$]; 
  bit [WSMIMSGID-1:0]      m_msgid_pool_updreqs[][$]; 
  addr_width_t             m_unq_cacheline_addrq[$];
  addr_width_t             m_unq_addrq[$];
  addr_width_t             m_unq_addrq_per_sfsetaddr[int][$]; //[set_addr][$]
  smi_seq_item             m_rbureqq[$];
  int                      m_rbreq[int][int];
  bit [WSMIMSGID-1 : 0]    m_random_msgid;
  addr_width_t             m_outstanding_addrq[int][$];
  addr_width_t 			   bit_mask_const = 'h1_FFFF_FFFF_FFFF << ncoreConfigInfo::WCACHE_OFFSET;
  int cmdreqs_msgid_ul;

  //Methods
  extern function new(string name = "dce_container");

  //Invoked by warmup method to load cachelines into model
  extern function void load_cacheline(addr_width_t addr);
  extern function void print_cache_model(bit all, addr_width_t addr = -1);
  extern function int get_unused_msgid(bit cmd_n_upd, int agentid);
  extern function void populate_inflight_txnq(int msgid, int agentid, bit cmd_n_upd_req, eMsgCMD msg_type, addr_width_t addr, bit es, int dce_id, bit awunique);
  extern function void populate_rbureqq(addr_width_t addr, int tm, int att_id, int rb_id, bit [WSMIMSGPRI-1:0] pri, bit [WSMIQOS-1:0] qos);
  extern function void release_msgid(int agentid, int msgid);
  extern function bit cmdrsps_pend_from_dce();
  extern function void update_outstanding_addrq(bit add, int agentid, addr_width_t addr);
  extern function void invoke_silent_cache_state_transition(bit no_invalidation);

  //Internal Methods
  extern function ncore_cache_state_t get_cacheline_st(int agent_id, addr_width_t addr);
  extern function bit cacheline_st_exists_in_any_other_agents(int agent_id, addr_width_t addr, ncore_cache_state_t st);
  extern function void set_cacheline_st(int agent_id, addr_width_t addr, ncore_cache_state_t cacheline_st);
  extern function smi_cmstatus_t get_snprsp_cmstatus(bit [WSMINCOREUNITID-1:0] snooper_funitid, eMsgSNP snp_type, bit [WSMIUP-1:0] up, ncore_cache_state_t snooper_initial_st, bit is_stash_target, bit [WSMINCOREUNITID-1:0] snp_mpf3 ,output ncore_cache_state_t snooper_final_st);
  extern function smi_cmstatus_t get_strrsp_cmstatus(smi_seq_item strreq);
  extern function void predict_master_final_state(int agentid, int smi_msg_id, bit cmstatus_exokay_or_updreq_pass = 0, bit owner_present = 0, bit vld_tgt_identified = 0, ncore_cache_state_t req_state = IX, smi_cmstatus_state_t str_cm_state = 'b000);
  extern function void print_outstanding_addrq(int agentid);
  
endclass: dce_container

//**********************************************************************
function dce_container::new(string name = "dce_container");
  super.new(name);
  m_msgid_pool_cmdreqs  = new[ncoreConfigInfo::NUM_AIUS];
  m_msgid_pool_updreqs  = new[ncoreConfigInfo::NUM_AIUS];
  m_rbreq.delete();
  
  //if (m_unit_args.k_num_coh_cmds.get_value() > m_unit_args.k_num_coh_cmds.get_value() 
  //ratio = 
  cmdreqs_msgid_ul = ((2**WSMIMSGID) * 4) / 5; //80% of avvailable msgids for cmds, remaining 20% for updreqs
  //`uvm_info("DCE CONTAINER", $psprintf("cmdreqs_msgid_ul:%0d", cmdreqs_msgid_ul), UVM_LOW);
  for (int agentid = 0; agentid < ncoreConfigInfo::NUM_AIUS; agentid++) begin
	
	for (int i = 0; i < cmdreqs_msgid_ul; ++i) begin
    	m_msgid_pool_cmdreqs[agentid].push_back(i);
	end 
	for (int i = cmdreqs_msgid_ul; i < 2**WSMIMSGID ; ++i) begin
    	m_msgid_pool_updreqs[agentid].push_back(i);
	end 

  	//`uvm_info("DCE CONTAINER", $psprintf("msgid_pool_size for agentid:%0d :%0d %0d", agentid, m_msgid_pool_cmdreqs[agentid].size(), m_msgid_pool_updreqs[agentid].size()), UVM_LOW);
  end
endfunction: new

//************************************************************************
function void dce_container::update_outstanding_addrq(bit add, int agentid, addr_width_t addr);
	int idxq[$];

	idxq = m_outstanding_addrq[agentid].find_index(item) with (item == addr);
	if (add) begin
		if (idxq.size() != 0) begin
      		`uvm_error("DCE CONTAINER", $psprintf("add: addr:0x%0h already present in outstanding addrq for agent:%0d", addr, agentid));
		end else begin
      		//`uvm_info("DCE CONTAINER", $psprintf("add: addr:0x%0h added to outstanding addrq for agent:%0d current_size:%0d", addr, agentid, m_outstanding_addrq[agentid].size()), UVM_LOW);
			m_outstanding_addrq[agentid].push_back(addr);
		end
	end else begin
		if (idxq.size() != 1) begin
      		`uvm_error("DCE CONTAINER", $psprintf("remove: addr:0x%0h not already present in outstanding addrq for agent:%0d", addr, agentid));
		end else begin
      		//`uvm_info("DCE CONTAINER", $psprintf("remove: addr:0x%0h removed from outstanding addrq for agent:%0d current_size:%0d", addr, agentid, m_outstanding_addrq[agentid].size()), UVM_LOW);
			m_outstanding_addrq[agentid].delete(idxq[0]);
		end
	end
	
	for (int agentid = 0; agentid < ncoreConfigInfo::NUM_AIUS; agentid++) begin
		foreach(m_outstanding_addrq[agentid][i]) begin
			if (m_outstanding_addrq[agentid][i] == addr) begin
      			//`uvm_info("DCE CONTAINER", $psprintf("outstanding agentid:%0d addr: 0x%0h", agentid, m_outstanding_addrq[agentid][i]), UVM_LOW);
			end
		end
	end
endfunction: update_outstanding_addrq

//***********************************
function void dce_container::print_outstanding_addrq(int agentid);
	string s;

    	$sformat(s, "%s Printing outstanding_addrq of size:%0d for agentid:%0d", s, m_outstanding_addrq[agentid].size(), agentid);
		foreach(m_outstanding_addrq[agentid][i]) begin
    	    $sformat(s, "%s %0d:addr:%p", s, i, m_outstanding_addrq[agentid][i]);
      		//	`uvm_info("DCE CONTAINER", $psprintf("outstanding agentid:%0d addr: 0x%0h", agentid, m_outstanding_addrq[agentid][i]), UVM_HIGH);
		end

    	`uvm_info("DCE_CONTAINER", $psprintf("%0s", s), UVM_LOW);
endfunction: print_outstanding_addrq

//*************************************************************************
function void dce_container::load_cacheline(addr_width_t addr);
  ncore_cache_model m_findq[$];
  addr_width_t bit_mask_const;
  addr_width_t cacheline_addr;

  bit_mask_const = 'h1_FFFF_FFFF_FFFF << ncoreConfigInfo::WCACHE_OFFSET;
  cacheline_addr = addr & bit_mask_const;
  
  m_findq = m_cachelines_st.find(item) with (item.get_addr() == cacheline_addr);

  if (m_findq.size() == 0) begin
    ncore_cache_model cacheline;

    cacheline = new();
    cacheline.set_addr(cacheline_addr);
    cacheline.set_cache_state_all_agents(IX);
    m_cachelines_st.push_back(cacheline);
  end
endfunction: load_cacheline

//*************************************************************************
function void dce_container::print_cache_model(bit all, addr_width_t addr = -1);
	string all_s, nonix_s ;
	bit print;

	foreach(m_cachelines_st[i]) begin
        //$sformat(s, "%sm_cache_st_p_agent size: %0d", s, m_cachelines_st[i].m_cache_st_p_agent.size());
        if (m_cachelines_st[i].get_addr() == addr) begin
    	    $sformat(all_s, "%sentry_%0d addr:%p", all_s, i, m_cachelines_st[i].get_addr());
			foreach(m_cachelines_st[i].m_cache_st_p_agent[j]) begin
				$sformat(all_s, "%0s %0d:%0s", all_s, j, m_cachelines_st[i].m_cache_st_p_agent[j].name);
			end
			$sformat(all_s, "%0s\n", all_s);
		end
		if (addr == -1) begin
			print = 0;
			foreach(m_cachelines_st[i].m_cache_st_p_agent[j]) begin
				if (m_cachelines_st[i].m_cache_st_p_agent[j] != IX) begin 
					print = 1;
					break;
				end 
			end
			if (print == 1) begin 
    	    	$sformat(all_s, "%s\nentry_%0d addr:%p", all_s, i, m_cachelines_st[i].get_addr());
				foreach(m_cachelines_st[i].m_cache_st_p_agent[j]) begin
					$sformat(all_s, "%0s %0d:%0s", all_s, j, m_cachelines_st[i].m_cache_st_p_agent[j].name);
				end
			end 
		end
	end

    if (all)
    	`uvm_info("DCE_CONTAINER", $psprintf("cache model contents: \n%0s", all_s), UVM_LOW);
endfunction: print_cache_model

//************************************************************************
function int dce_container::get_unused_msgid(bit cmd_n_upd, int agentid);
  int id;

  if (cmd_n_upd == 1) begin // it is a cmd req
  	if (m_msgid_pool_cmdreqs[agentid].size() == 0) begin
        `uvm_info("DCE CONTAINER", $psprintf("No msgid are available to pop from msgid_pool_cmdreqs for agent:%0d", agentid), UVM_HIGH);
        id = -1;
    end else 
  	    id = m_msgid_pool_cmdreqs[agentid].pop_front();
  end else begin 
  	if (m_msgid_pool_updreqs[agentid].size() == 0) begin
      	`uvm_info("DCE CONTAINER", $psprintf("No msgid are available to pop from msgid_pool_updreqs for agent:%0d", agentid), UVM_HIGH);
        id = -1;
    end else
  	    id = m_msgid_pool_updreqs[agentid].pop_front();
  end

  if (cmd_n_upd) begin
  	//	`uvm_info("DCE_CONTAINER", $psprintf("CMD agentid:%0d msgid:%0d pool_size:%0d", agentid, id, m_msgid_pool_cmdreqs[agentid].size()), UVM_LOW);
  end else begin
  	 //	`uvm_info("DCE_CONTAINER", $psprintf("UPD agentid:%0d msgid:%0d pool_size:%0d", agentid, id, m_msgid_pool_updreqs[agentid].size()), UVM_LOW);
  end

  return id;
endfunction: get_unused_msgid

//************************************************************************
function void dce_container::populate_inflight_txnq(int msgid, int agentid, bit cmd_n_upd_req, eMsgCMD msg_type, addr_width_t addr, bit es, int dce_id, bit awunique);
  int idxq[$];
  dce_inflight_txns m_txn;

  idxq = m_inflight_txns.find_index(x) with (x.is_msgid_inuse() && (x.get_msg_id() == msgid) && (x.get_master_id() == agentid));

  if (idxq.size() != 0) begin
      `uvm_error("DCE CONTAINER", $psprintf("msg_id:0x%0h already in use for agent:%0d", msgid, agentid));
  end
  
  m_txn = new($time, msgid, agentid, cmd_n_upd_req, msg_type, addr, es, dce_id, awunique);
  m_inflight_txns.push_back(m_txn);

endfunction : populate_inflight_txnq

//************************************************************************
function void dce_container::populate_rbureqq(addr_width_t addr, int tm, int att_id, int rb_id, bit [WSMIMSGPRI-1:0] pri, bit [WSMIQOS-1:0] qos);
  int idxq[$];
  int wrong_rbu_targ_id;
  smi_seq_item rbureq;
  int dmi_id;
  int discard;
  bit [WSMINCOREUNITID-1:0] targ_id;

	   rbureq = smi_seq_item::type_id::create("rbureq");
       dmi_id = ncoreConfigInfo::map_addr2dmi_or_dii(addr, discard);

	   if ($value$plusargs("wrong_rbureq_target_id=%d",wrong_rbu_targ_id)) begin
         std::randomize (targ_id) with {targ_id dist {(ncoreConfigInfo::get_dce_funitid(0) ^ {WSMINCOREUNITID{1'b1}}) :/ wrong_rbu_targ_id, ncoreConfigInfo::get_dce_funitid(0) :/ 100-wrong_rbu_targ_id};};
       end else begin
         targ_id = ncoreConfigInfo::get_dce_funitid(0);
       end
	   
	   rbureq.construct_rbusemsg(
			.smi_targ_ncore_unit_id (targ_id),
			.smi_src_ncore_unit_id  (dmi_id),
			.smi_msg_type           (RB_USED),
			.smi_msg_id             (m_random_msgid), //#Cover.DCE.RBUseReq_MsgID
			.smi_msg_tier           ('h0),
			.smi_steer              ('h0),
			.smi_msg_pri            (pri),
			.smi_msg_qos            ('h0),
			.smi_tm                 (tm),
			.smi_rbid               (rb_id),
			.smi_msg_err            ('h0),
			.smi_cmstatus           ('h0),
			.smi_rl                 ('b01)
		);

	   m_rbureqq.push_back(rbureq);
       `uvm_info("RBUREQQ", $psprintf("Predicted RBU Req for reads for rbid: 0x%0h, dmiid:0x%0h attid: 0x%0h", rb_id, dmi_id, att_id), UVM_LOW)

	   m_random_msgid++;
endfunction: populate_rbureqq

//************************************************************************
function void dce_container::release_msgid(int agentid, int msgid);
  int idxq[$];
  addr_width_t bit_mask_const = 'h1_FFFF_FFFF_FFFF << ncoreConfigInfo::WCACHE_OFFSET;
  addr_width_t cacheline_addr;
  
  idxq = m_inflight_txns.find_index(x) with ((x.get_msg_id() == msgid) && (x.get_master_id() == agentid) && x.is_msgid_inuse());

  cacheline_addr = m_inflight_txns[idxq[0]].get_addr() & bit_mask_const;
  
  if (idxq.size() == 0) begin
      `uvm_error("DCE CONTAINER", $psprintf("No msg_id matches for agent:%0d", agentid));
  end else if (idxq.size() > 1) begin 
      `uvm_error("DCE CONTAINER", $psprintf("Multiple msg_id matches for agent:%0d", agentid));
  end else if (m_inflight_txns[idxq[0]].get_strreq_flag()) begin
      `uvm_info("CACHE_MODEL", $psprintf("UPDATE master state CMDREQ: agentid:0x%0h addr:0x%0h master_final_st:%p",  agentid, cacheline_addr, m_inflight_txns[idxq[0]].get_master_final_st()), UVM_LOW)
      set_cacheline_st(agentid, cacheline_addr, m_inflight_txns[idxq[0]].get_master_final_st());
      print_cache_model(1, cacheline_addr);
      m_inflight_txns[idxq[0]].reset_txn();
      m_msgid_pool_cmdreqs[agentid].push_back(msgid);
  end else if (m_inflight_txns[idxq[0]].get_updrsp_flag()) begin
      //`uvm_info("CACHE_MODEL", $psprintf("UPDATE master state UPDREQ: agentid:0x%0h addr:0x%0h master_final_st:%p",  agentid,  m_inflight_txns[idxq[0]].get_addr(), m_inflight_txns[idxq[0]].get_master_final_st()), UVM_LOW)
      //set_cacheline_st(agentid, cacheline_addr, m_inflight_txns[idxq[0]].get_master_final_st());
      //print_cache_model(1, cacheline_addr);
      m_inflight_txns[idxq[0]].reset_txn();
      m_msgid_pool_updreqs[agentid].push_back(msgid);
  end 

endfunction: release_msgid

//*****************************************************************
function bit dce_container::cmdrsps_pend_from_dce();
  foreach (m_inflight_txns[idx]) begin
    if (m_inflight_txns[idx].is_msgid_inuse() && !m_inflight_txns[idx].get_cmdrsp_flag())
      return 0;
  end
  return 1;
endfunction: cmdrsps_pend_from_dce

//******************************************************************
function ncore_cache_state_t dce_container::get_cacheline_st(int agent_id, addr_width_t addr);
  ncore_cache_model foundq[$];

  int cacheid = ncoreConfigInfo::get_cache_id(agent_id);
  foundq = m_cachelines_st.find(x) with (x.get_addr() == addr);
  if (foundq.size() == 0) begin
      `uvm_error("DCE CONTAINER", $psprintf("How come the addr: 0x%0x was not loaded into ncore_cache_model?", addr));
  end else if (foundq.size() > 1) begin
      `uvm_error("DCE CONTAINER", $psprintf("How come the addr: 0x%0x has multiple entries in ncore_cache_model?", addr));
  end else begin
  		
      //`uvm_info("CACHE_MODEL", "Calling get_cache_st from get_cacheline_st", UVM_LOW)
      return foundq[0].get_cache_state(cacheid);
  end

endfunction: get_cacheline_st

//******************************************************************
function bit dce_container::cacheline_st_exists_in_any_other_agents(int agent_id, addr_width_t addr, ncore_cache_state_t st);
  bit exists = 0;
  ncore_cache_model foundq[$];

  foundq = m_cachelines_st.find(x) with (x.get_addr() == addr);
  if (foundq.size() == 0) begin
      `uvm_error("DCE CONTAINER", $psprintf("How come the addr: 0x%0x was not loaded into ncore_cache_model?", addr));
  end else if (foundq.size() > 1) begin
      `uvm_error("DCE CONTAINER", $psprintf("How come the addr: 0x%0x has multiple entries in ncore_cache_model?", addr));
  end else begin
      foreach(foundq[0].m_cache_st_p_agent[i]) begin
		if ((i != agent_id) && (foundq[0].m_cache_st_p_agent[i] == st)) begin
			exists = 1;	
		end
      end
  end

  return exists;
endfunction: cacheline_st_exists_in_any_other_agents

//******************************************************************
function void dce_container::set_cacheline_st(int agent_id, addr_width_t addr, ncore_cache_state_t cacheline_st);
  ncore_cache_model foundq[$];
  int cacheid = ncoreConfigInfo::get_cache_id(agent_id);
  
  foundq = m_cachelines_st.find(x) with (x.get_addr() == addr);
  if (foundq.size() == 0) begin
      `uvm_error("DCE CONTAINER", $psprintf("How come the addr: 0x%0x was not loaded into ncore_cache_model?", addr));
  end else if (foundq.size() > 1) begin
      `uvm_error("DCE CONTAINER", $psprintf("How come the addr: 0x%0x has multiple entries in ncore_cache_model?", addr));
  end else begin
      foundq[0].set_cache_state(cacheid, cacheline_st);
  end

endfunction: set_cacheline_st

//******************************************************************
static function smi_cmstatus_t dce_container::get_snprsp_cmstatus(bit [WSMINCOREUNITID-1:0] snooper_funitid, eMsgSNP snp_type, bit [WSMIUP-1:0] up, ncore_cache_state_t snooper_initial_st, bit is_stash_target, bit [WSMINCOREUNITID-1:0] snp_mpf3 ,output ncore_cache_state_t snooper_final_st);
    ncore_cache_state_t possible_final_stq[$];
    ncore_cache_state_t possible_master_final_stq[$];
    int idx, jdx;
    smi_cmstatus_t cmstatusq[$];
    smi_cmstatus_t cmstatus;
    ncore_cache_state_t master_final_st = IX;
    ncore_cache_state_t snooper_choose_st = IX;
	int agentid = ncoreConfigInfo::agentid_assoc2funitid(snooper_funitid);
	//`uvm_info("DCE_CONT_DBG",$psprintf("agent_id = %d and funit_id = %d",agentid,snooper_funitid), UVM_LOW) 
    possible_final_stq.delete();
    cmstatus = 6'b111111; //To check if any cmstatus is missed and to throw error if cmstatus is 111_111

	case (snp_type)
      SNP_CLN_DTR: begin
		  			  if (ncoreConfigInfo::get_native_interface(snooper_funitid) == ncoreConfigInfo::IO_CACHE_AIU) begin 
							if (snooper_initial_st inside {UD, SD})
								possible_final_stq = {SD};
							if (snooper_initial_st inside {SC, UC})
								possible_final_stq = {SC};
							if (snooper_initial_st inside {IX})
								possible_final_stq = {IX};
					  end else begin 
						  if (snooper_initial_st inside {UD, SD})
							possible_final_stq = {SD, SC, IX};
						  else if (snooper_initial_st == UC || ((snooper_initial_st == SC) && (up == 2'b01 || (up == 2'b11 && (snooper_funitid == snp_mpf3)))))
							possible_final_stq = {SC, IX};
						  else if (snooper_initial_st inside {UCE, UDP, IX, SC})
							possible_final_stq = {IX};
					  end
                      idx = $urandom_range(possible_final_stq.size() - 1);
                      //if (snooper_funitid == 0) idx = 0; //Select SC to accept SnpResp & transition cacheline state to sharer
                      //if (snooper_funitid == 1) idx = 1; //Select IX to silently drop the cacheline
                      //$display("KDB03 dce_cntr:: possible_final_stq=%0p ncoreConfigInfo::get_native_interface(%0d)=%0s", possible_final_stq, snooper_funitid, ncoreConfigInfo::get_native_interface(snooper_funitid));
                      snooper_final_st = possible_final_stq[idx];
                      
					  if ((snooper_initial_st == UC || ((snooper_initial_st == SC) && (up == 2'b01 || (up == 2'b11 && (snooper_funitid == snp_mpf3))))) && ($value$plusargs("snooper_choose_SC_or_IX=%0s",snooper_choose_st)))
							snooper_final_st = snooper_choose_st;
					  if (snooper_initial_st == UD && $test$plusargs("snooper_downgrade_UD_to_SD"))
							snooper_final_st = SD;
                      
	//`uvm_info("DCE_CONT_DBG",$psprintf("snooper_initial_state = %p snooper_final_state selected = %p with snooped agent is %p, up = %p",snooper_initial_st,snooper_final_st,ncoreConfigInfo::get_native_interface(agentid),up), UVM_LOW) 
                      case(snooper_final_st)
                         SD: 	   begin   
                         			   // applies to all responses.
                                       cmstatus = 'b100100; //SnpRespData_SD, CompData_SC
                                   end
                         SC: 	   begin 
                                  	  if (snooper_initial_st inside {UD, SD}) begin 
                       					 cmstatus = 'b110110; //SnpRespData_SC_PD
                                  	  end 
					  else if (snooper_initial_st == UC || ((snooper_initial_st == SC) && (up == 2'b01 || (up == 2'b11 && (snooper_funitid == snp_mpf3))))) begin
					  	if (ncoreConfigInfo::get_native_interface(agentid) == ncoreConfigInfo::ACE_AIU) begin 
                       					cmstatus = 'b110000; //SnpRespData_SC
					  	end
						else if (ncoreConfigInfo::get_native_interface(agentid) == ncoreConfigInfo::IO_CACHE_AIU) begin
                       					cmstatus = 'b110100; //SnpRespData_SC
						end 
						else begin
							cmstatusq.push_back('b110000); //SnpResp_SC                              
	    				 		cmstatusq.push_back('b110100); //SnpRespData_SC                              
							idx = $urandom_range(cmstatusq.size() - 1);
							cmstatus = cmstatusq[idx];
						end 
                                  	  end 
					  else if (snooper_initial_st == SC && (ncoreConfigInfo::get_native_interface(agentid) == ncoreConfigInfo::IO_CACHE_AIU)) begin
						cmstatus = 'b110000;                             
					  end	
				   end
                         IX: 
                                   begin 
				   	if (ncoreConfigInfo::get_native_interface(agentid) == ncoreConfigInfo::IO_CACHE_AIU) begin
				   		cmstatus = 'b000000; // Should add error
					end 
					else if (ncoreConfigInfo::get_native_interface(agentid) == ncoreConfigInfo::ACE_AIU) begin 
						if (snooper_initial_st inside {UD, SD} && up == 2'b01)
					  		cmstatus = 'b001110;  //Dtr-UCln + Dtw-FDty
					  	else if (snooper_initial_st == SD && (up == 2'b00 || up == 2'b11))
					  		cmstatus = 'b000110;  //Dtr-SCln + Dtw-FDty
						else if ((snooper_initial_st == UC && up == 1) || ((snooper_initial_st == SC) && (up == 2'b01 || (up == 2'b11 && (snooper_funitid == snp_mpf3))))) begin
					  		cmstatusq.push_back('b000100);  //Dtr-SCln
					  		if(up == 2'b01) cmstatusq.push_back('b001100);  //Dtr-UCln
							idx = $urandom_range(cmstatusq.size() - 1);
							cmstatus = cmstatusq[idx];
					  	end
						else if (snooper_initial_st inside {IX,SC})
							cmstatus = 'b000000; //SnpResp_I
						end 
					else begin //CHI  
							if (snooper_initial_st inside {SD, UD}) begin 
								if (up == 1) begin 
									cmstatus = 'b001110; //SnpRespData_I_PD
								end 
								else begin 
									cmstatus = 'b000110; //SnpRespData_I_PD
								end
							end 
							else if (snooper_initial_st == UDP) begin
									cmstatus = 'b001110; //SnpRespDataPtl_I_PD
							end 
							else if (snooper_initial_st == UC || ((snooper_initial_st == SC) && (up == 2'b01 || (up == 2'b11 && (snooper_funitid == snp_mpf3))))) begin
								cmstatusq.push_back('b000000); //SnpResp_I
								if(up == 2'b01) cmstatusq.push_back('b001100); //SnpRespData_I
								idx = $urandom_range(cmstatusq.size() - 1);
								cmstatus = cmstatusq[idx];
							end 
							else if (snooper_initial_st == UCE) begin
								cmstatus = 'b000000; //SnpResp_I
							end 
							else if(snooper_initial_st inside {IX,SC}) begin
								cmstatus = 'b000000; //SnpResp_I
							end
					end
				   end
                      endcase
                   end
      SNP_VLD_DTR: begin
					  if (ncoreConfigInfo::get_native_interface(agentid) == ncoreConfigInfo::IO_CACHE_AIU) begin 
						  if (snooper_initial_st inside {UD, SD})
						  	snooper_final_st = SC;
				      	  	  else if (snooper_initial_st inside {SC, UC})
						  	snooper_final_st = SC;
						  else if (snooper_initial_st == IX)
						  	snooper_final_st = IX;
				      end else begin 
						  if (snooper_initial_st inside {UD, SD}) begin
							if (    $test$plusargs("SNPrsp_sharer_data_error_in_cmstatus") 
								 || $test$plusargs("SNPrsp_sharer_non_data_error_in_cmstatus")) begin
							  possible_final_stq = {SD}; //For directed test needed DTR
							end else begin
							  possible_final_stq = {SD, SC, IX};
							end
						  end else if (snooper_initial_st == UC || ((snooper_initial_st == SC) && (up == 2'b01 || (up == 2'b11 && (snooper_funitid == snp_mpf3)))))
							possible_final_stq = {SC, IX};
						  else if (snooper_initial_st inside {UCE, UDP, IX, SC}) // SC is snooped only when silent_cache_state
							possible_final_stq = {IX};
						idx = $urandom_range(possible_final_stq.size() - 1);
						snooper_final_st = possible_final_stq[idx];
				  	  end 
					  
					  if (snooper_initial_st == UD && $test$plusargs("snooper_downgrade_UD_to_SD"))
							snooper_final_st = SD;
                      
                      case(snooper_final_st)
                            SD: 
                                  //           {rv,       rs,        dc,        dt_aiu,    dt_dmi,    snarf}
                                  //cmstatus = ((1 << 5) | (0 << 4) | (0 << 3) | (1 << 2) | (0 << 1) | 0); //SnpRespData_SD                              
                                  cmstatus = 'b100100; //SnpRespData_SD                              
                            SC:  
                                  begin 
                                  	  if (snooper_initial_st inside {UD, SD}) begin 
                       					 //cmstatus = ((1 << 5) | (1 << 4) | (1 << 3) | (1 << 2) | (0 << 1) | 0); //SnpRespData_SC_PD
                       					 cmstatus = 'b111100; //SnpRespData_SC_PD
					  end else if (snooper_initial_st == UC || ((snooper_initial_st == SC) && (up == 2'b01 || (up == 2'b11 && (snooper_funitid == snp_mpf3))))) begin
					  	if (ncoreConfigInfo::get_native_interface(agentid) == ncoreConfigInfo::IO_CACHE_AIU) begin
							if(snooper_initial_st == UC) 
                       						cmstatus = 'b111100;
							else
								cmstatus = 'b110100;
						end else if (ncoreConfigInfo::get_native_interface(agentid) == ncoreConfigInfo::ACE_AIU) begin 
                       					cmstatus = 'b110000;
					  	end else begin
											 //                  {rv,       rs,        dc,        dt_aiu,    dt_dmi,    snarf}
											 //cmstatusq.push_back((1 << 5) | (1 << 4) | (0 << 3) | (0 << 2) | (0 << 1) | 0); //SnpResp_SC                              
											 cmstatusq.push_back('b110000); //SnpResp_SC                              
											 //cmstatusq.push_back((1 << 5) | (1 << 4) | (0 << 3) | (1 << 2) | (0 << 1) | 0); //SnpRespData_SC                              
											 cmstatusq.push_back('b110100); //SnpRespData_SC                              
											 idx = $urandom_range(cmstatusq.size() - 1);
											 cmstatus = cmstatusq[idx];
									 	end
									 end else if (snooper_initial_st == SC) begin 
                       					//cmstatus = ((1 << 5) | (1 << 4) | (0 << 3) | (0 << 2) | (0 << 1) | 0);
                       					cmstatus = ('b110000);
									 end
								  end
                            IX:   
                                  begin
					  				if (ncoreConfigInfo::get_native_interface(agentid) == ncoreConfigInfo::IO_CACHE_AIU) begin 
                       					cmstatus = ((0 << 5) | (0 << 4) | (0 << 3) | (0 << 2) | (0 << 1) | 0);
					  				end else begin 
                                  	  if (snooper_initial_st == SD) begin 
                       					 cmstatus = ((0 << 5) | (0 << 4) | (1 << 3) | (1 << 2) | (0 << 1) | 0); //SnpRespData_I_PD
                                  	  end else if (snooper_initial_st == UD) begin
										 //                 {rv,        rs,        dc,        dt_aiu,    dt_dmi,   snarf}
										 cmstatus = ((0 << 5) | (0 << 4) | (1 << 3) | (1 << 2) | (0 << 1) | 0); //SnpRespData_I_PD
									  end else if (snooper_initial_st == UDP) begin
										 cmstatus = ((0 << 5) | (0 << 4) | (1 << 3) | (1 << 2) | (1 << 1) | 0); //SnpRespDataPtl_I_PD
					  end else if (snooper_initial_st == UC || ((snooper_initial_st == SC) && (up == 2'b01 || (up == 2'b11 && (snooper_funitid == snp_mpf3))))) begin
										 //                 {rv,        rs,        dc,        dt_aiu,    dt_dmi,   snarf}
										 cmstatusq.push_back((0 << 5) | (0 << 4) | (0 << 3) | (0 << 2) | (0 << 1) | 0); //SnpResp_I
										 if(up == 2'b01) cmstatusq.push_back((0 << 5) | (0 << 4) | (1 << 3) | (1 << 2) | (0 << 1) | 0); //SnpRespData_I
										 //CONC-6600 This SnpRsp is possible from ACE snooper if UP=1(unique presence)
        								 //See ConcertoC Mapping excel sheet row71, columnAB
										 if (    (ncoreConfigInfo::get_native_interface(ncoreConfigInfo::agentid_assoc2funitid(snooper_funitid)) == ncoreConfigInfo::ACE_AIU) 
										 	  && (up == 1)) begin
										 	cmstatusq.push_back((0 << 5) | (0 << 4) | (0 << 3) | (1 << 2) | (0 << 1) | 0); //SnpRespData_I
										 end
										 idx = $urandom_range(cmstatusq.size() - 1);
										 cmstatus = cmstatusq[idx];
                                      end else if (snooper_initial_st inside {UCE, IX, SC}) begin
										 cmstatus = ((0 << 5) | (0 << 4) | (0 << 3) | (0 << 2) | (0 << 1) | 0); //SnpResp_I
									  end
									end 
								  end
					   endcase
                   end
      SNP_NOSDINT: begin
	//`uvm_info("DCE_CONT_DBG",$psprintf("Inside SNP_NOSDINT with snooper intial state = %p",snooper_initial_st), UVM_LOW) 
      	  			  
					  if (ncoreConfigInfo::get_native_interface(agentid) == ncoreConfigInfo::IO_CACHE_AIU) begin
						  if (snooper_initial_st inside {UD, SD})
							possible_final_stq = {SD};
						  else if (snooper_initial_st inside {SC, UC})
							possible_final_stq = {SC};
						  else if (snooper_initial_st == IX)
							possible_final_stq = {IX};
					  end else begin 
						  if (snooper_initial_st inside {UD, SD})
							possible_final_stq = {SD, SC, IX};
						  else if (snooper_initial_st == UC || ((snooper_initial_st == SC) && (up == 2'b01 || (up == 2'b11 && (snooper_funitid == snp_mpf3)))))
							possible_final_stq = {SC, IX};
						  else if (snooper_initial_st inside {UCE, UDP, IX, SC}) // SC is snooped only when silent_cache_state
							possible_final_stq = {IX};
                      end 

                      idx = $urandom_range(possible_final_stq.size() - 1);
                      snooper_final_st = possible_final_stq[idx];
  					 
  					  //Table 4-17 Cache state transitions from CHI-B spec
  					  //(ReadNotSharedDirty op is not present in CHI-A
					  //TABLE 5-15 SnpNoSDIntDtr
	//`uvm_info("DCE_CONT_DBG",$psprintf("Inside SNP_NOSDINT with snooper final state selected = %p",snooper_final_st), UVM_LOW) 
                      case(snooper_final_st)
                            SD: 
                                  cmstatus = ((1 << 5) | (0 << 4) | (0 << 3) | (1 << 2) | (0 << 1) | 0); //SnpRespData_SD                              
                            SC:  
                                  begin 
                                  	  if (snooper_initial_st inside {UD, SD}) begin 
                       					 cmstatus = ((1 << 5) | (1 << 4) | (0 << 3) | (1 << 2) | (1 << 1) | 0); //SnpRespData_SC_PD
                                  	  end else if (snooper_initial_st == UC || ((snooper_initial_st == SC) && (up == 2'b01 || (up == 2'b11 && (snooper_funitid == snp_mpf3))))) begin

					  					 if (ncoreConfigInfo::get_native_interface(agentid) == ncoreConfigInfo::IO_CACHE_AIU) begin 
											 cmstatusq.push_back((1 << 5) | (1 << 4) | (0 << 3) | (1 << 2) | (0 << 1) | 0); //SnpRespData_SC                         
										 end else if (ncoreConfigInfo::get_native_interface(agentid) == ncoreConfigInfo::ACE_AIU) begin 
											 cmstatusq.push_back((1 << 5) | (1 << 4) | (0 << 3) | (0 << 2) | (0 << 1) | 0); //SnpRespData_SC                         
					  					 end else begin 
											 cmstatusq.push_back((1 << 5) | (1 << 4) | (0 << 3) | (0 << 2) | (0 << 1) | 0); //SnpResp_SC                              
											 cmstatusq.push_back((1 << 5) | (1 << 4) | (0 << 3) | (1 << 2) | (0 << 1) | 0); //SnpRespData_SC                         
									     end 
										 idx = $urandom_range(cmstatusq.size() - 1);
										 cmstatus = cmstatusq[idx];
                                  	  end else if (snooper_initial_st == SC) begin 
                       					cmstatus = ((1 << 5) | (1 << 4) | (0 << 3) | (0 << 2) | (0 << 1) | 0);
									  end
								  end
                            IX:   
                                  begin 
	//`uvm_info("DCE_CONT_DBG",$psprintf("snooper_initial_state = %p snooper_final_state selected = %p with snooped agent is %p, up = %p",snooper_initial_st,snooper_final_st,ncoreConfigInfo::get_native_interface(agentid),up), UVM_LOW) 
					  				  if (ncoreConfigInfo::get_native_interface(agentid) == ncoreConfigInfo::IO_CACHE_AIU) begin 
										 cmstatus = ((0 << 5) | (0 << 4) | (0 << 3) | (0 << 2) | (0 << 1) | 0); 
									  end else if (ncoreConfigInfo::get_native_interface(agentid) == ncoreConfigInfo::ACE_AIU) begin 
					  				  	 if (snooper_initial_st inside {UD, SD} && up == 1)
					  				  	 	 cmstatus = 'b001100;  //Dtr-UDty
					  				  	 if (snooper_initial_st == SD && (up == 0 || up == 3))
					  				  	 	 cmstatus = 'b000110;  //Dtr-SCln + Dtw-FDty
					  				  	 if ((snooper_initial_st == UC && up == 1) || ((snooper_initial_st == SC) && (up == 2'b01 || (up == 2'b11 && (snooper_funitid == snp_mpf3)))))
					  				  	 	 cmstatus = 'b000100;  //Dtr-SCln
					  				  	 if (snooper_initial_st inside {IX, SC})
					  				  	 	 cmstatus = 'b000000;  //SnpResp_I
									  end else begin //CHI_AIU
										  if (snooper_initial_st inside {SD, UD}) begin 
											 if (up == 1) begin 
												cmstatus = 'b001100; //SnpRespData_I_PD
											 end else begin
												cmstatus = 'b000110; //SnpRespData_I_PD
											 end
										  end else if (snooper_initial_st == UDP) begin
											 cmstatus = ((0 << 5) | (0 << 4) | (1 << 3) | (1 << 2) | (1 << 1) | 0); //SnpRespDataPtl_I_PD
										  end else if (snooper_initial_st == UC || ((snooper_initial_st == SC) && (up == 2'b01 || (up == 2'b11 && (snooper_funitid == snp_mpf3))))) begin 
											 cmstatusq.push_back((0 << 5) | (0 << 4) | (0 << 3) | (0 << 2) | (0 << 1) | 0); //SnpResp_I
											 if(up == 2'b01) cmstatusq.push_back((0 << 5) | (0 << 4) | (1 << 3) | (1 << 2) | (0 << 1) | 0); //SnpRespData_I
											 idx = $urandom_range(cmstatusq.size() - 1);
											 cmstatus = cmstatusq[idx];
										  end else if (snooper_initial_st inside {UCE, IX, SC}) begin
											 cmstatus = ((0 << 5) | (0 << 4) | (0 << 3) | (0 << 2) | (0 << 1) | 0); //SnpResp_I
										  end
								  	  end
								  end
					   endcase
                  end
    SNP_CLN_DTW:  begin //ClnVld, ClnShPer
				      if (snooper_initial_st inside {UD, UC})
                    	possible_final_stq = {UC, SC, IX};
                      else if (snooper_initial_st inside {SD, SC})
                    	possible_final_stq = {SC, IX};
                      else if (snooper_initial_st inside {UCE, UDP, IX})
                    	possible_final_stq = {IX};
                      idx = $urandom_range(possible_final_stq.size() - 1);
                      snooper_final_st = possible_final_stq[idx];
                      case(snooper_final_st)
						UC: begin
									if (ncoreConfigInfo::get_native_interface(agentid) == ncoreConfigInfo::ACE_AIU) begin
                       					cmstatus = ((1 << 5) | (0 << 4) | (0 << 3) | (0 << 2) | (0 << 1) | 0); //SnpResp_UC
									end else begin 
										if (snooper_initial_st == UD)
                       						cmstatus = ((1 << 5) | (0 << 4) | (0 << 3) | (0 << 2) | (1 << 1) | 0); //SnpRespData_UC_PD
                       					else  //UC
                       						cmstatus = ((1 << 5) | (0 << 4) | (0 << 3) | (0 << 2) | (0 << 1) | 0); //SnpResp_UC
                                    end
								  end
						SC: begin
                      				if (snooper_initial_st inside {UC,SD} || ((snooper_initial_st == SC) && (up == 2'b01 || (up == 2'b11 && (snooper_funitid == snp_mpf3))))) begin
                       					cmstatus = ((1 << 5) | (1 << 4) | (0 << 3) | (0 << 2) | (1 << 1) | 0); //SnpRespData_SC_PD
                      				end else begin //SC, UC
                       					cmstatus = ((1 << 5) | (1 << 4) | (0 << 3) | (0 << 2) | (0 << 1) | 0); //SnpResp_SC
                      				end 
								  end
						IX: begin
									if (ncoreConfigInfo::get_native_interface(agentid) == ncoreConfigInfo::IO_CACHE_AIU) begin
                       					cmstatus = ((0 << 5) | (0 << 4) | (0 << 3) | (0 << 2) | (0 << 1) | 0); //SnpResp_I
									end else begin //ACE, CHI snooper
                      					if (snooper_initial_st inside {UC,SD,UDP} || ((snooper_initial_st == SC) && (up == 2'b01 || (up == 2'b11 && (snooper_funitid == snp_mpf3)))))
                       						cmstatus = ((0 << 5) | (0 << 4) | (0 << 3) | (0 << 2) | (1 << 1) | 0); //SnpRespData_I_PD, SnpRespDataPtl_I_PD
                      					else //all others
                       						cmstatus = ((0 << 5) | (0 << 4) | (0 << 3) | (0 << 2) | (0 << 1) | 0); //SnpResp_I
									end
								  end 
                      endcase
    			  end
    	SNP_NITC:  begin
					  if (ncoreConfigInfo::get_native_interface(agentid) == ncoreConfigInfo::IO_CACHE_AIU) begin
						  snooper_final_st = snooper_initial_st;
					  end else begin
						  if (snooper_initial_st == UD)
							possible_final_stq = {UD, SD, SC, IX};
						  else if (snooper_initial_st == SD)
							possible_final_stq = {SD, SC, IX};
						  else if (snooper_initial_st == UC)
							possible_final_stq = {SC, UC, IX};
						  else if (snooper_initial_st == UCE)
							possible_final_stq = {UCE, IX};
						  else if (snooper_initial_st == UDP)
							possible_final_stq = {UDP, IX};
						  else if (snooper_initial_st == IX)
							possible_final_stq = {IX};
						  idx = $urandom_range(possible_final_stq.size() - 1);
						  snooper_final_st = possible_final_stq[idx];
				  	  end
	//`uvm_info("DCE_CONT_DBG",$psprintf("Inside SNP_NITC with snooper final state selected = %p and current CM status is %p",snooper_final_st,cmstatus), UVM_LOW) 
                      case(snooper_final_st)
                      	UD: begin
				if (ncoreConfigInfo::get_native_interface(agentid) inside {ncoreConfigInfo::IO_CACHE_AIU, ncoreConfigInfo::ACE_AIU}) begin
                       			cmstatus = 'b100100;
				end else begin
					cmstatusq.push_back('b100100); //SnpRespData_UD
					cmstatusq.push_back('b100110); //SnpRespDataPtl_UD
					idx = $urandom_range(cmstatusq.size() - 1);
	                                cmstatus = cmstatusq[idx];
				end
                       	end
                      	UDP: begin
                       				cmstatus = ((1 << 5) | (0 << 4) | (0 << 3) | (1 << 2) | (1 << 1) | 0); //SnpRespDataPtl_UD
                       			   end
                      	SD: begin
                       				cmstatus = ((1 << 5) | (0 << 4) | (0 << 3) | (1 << 2) | (0 << 1) | 0); //SnpRespData_SD
                    			  end	
                      	SC: begin
				if (ncoreConfigInfo::get_native_interface(agentid) == ncoreConfigInfo::IO_CACHE_AIU) begin
					if((up == 2'b01 || (up == 2'b11 && (snooper_funitid == snp_mpf3))))
                       				cmstatus = 'b110100;
					else
						cmstatus = 'b110000;
                       		end 
				else begin
					if (snooper_initial_st inside {UD, SD}) begin
						cmstatus = 'b110110; //SnpRespData_SC_PD
					end 
					else begin //SC or UC
						if (ncoreConfigInfo::get_native_interface(agentid) == ncoreConfigInfo::ACE_AIU) begin
							cmstatus = 'b110000; //SnpResp_SC
						end else begin //CHI
							cmstatusq.push_back('b110000); //SnpResp_SC
							cmstatusq.push_back('b110100); //SnpRespData_SC
							idx = $urandom_range(cmstatusq.size() - 1);
							cmstatus = cmstatusq[idx];
						end
					end
				end
                      	      end
			UCE: begin
                       				cmstatus = ((1 << 5) | (0 << 4) | (0 << 3) | (0 << 2) | (0 << 1) | 0); //SnpResp_UC
                        	  	   end
                        UC: begin
					  				if (ncoreConfigInfo::get_native_interface(agentid) == ncoreConfigInfo::IO_CACHE_AIU) begin
                       					cmstatus = ((1 << 5) | (0 << 4) | (0 << 3) | (1 << 2) | (0 << 1) | 0);
					  				end else begin
										cmstatusq.push_back((1 << 5) | (0 << 4) | (0 << 3) | (0 << 2) | (0 << 1) | 0); //SnpResp_UC
										cmstatusq.push_back((1 << 5) | (0 << 4) | (0 << 3) | (1 << 2) | (0 << 1) | 0); //SnpRespData_UC
										idx = $urandom_range(cmstatusq.size() - 1);
                                    	cmstatus = cmstatusq[idx];
									end 
                        	  	  end
                        IX: begin
	//`uvm_info("DCE_CONT_DBG",$psprintf("Inside IX with intial_cache_state = %p and agent = %p",snooper_initial_st,ncoreConfigInfo::get_native_interface(agentid)), UVM_LOW) 
					  				if (ncoreConfigInfo::get_native_interface(agentid) == ncoreConfigInfo::IO_CACHE_AIU) begin
										cmstatus = ((0 << 5) | (0 << 4) | (0 << 3) | (0 << 2) | (0 << 1) | 0); 
					  				end else begin 
										if (snooper_initial_st inside {UD, UDP}) begin
											cmstatus = ((0 << 5) | (0 << 4) | (0 << 3) | (1 << 2) | (1 << 1) | 0); //SnpRespData_I_PD, SnpRespDataPtl_I_PD
										end else if (snooper_initial_st == SD) begin
											cmstatus = ((0 << 5) | (0 << 4) | (0 << 3) | (1 << 2) | (1 << 1) | 0); //SnpRespData_I_PD
										end else if (snooper_initial_st == UC) begin
											cmstatusq.push_back((0 << 5) | (0 << 4) | (0 << 3) | (0 << 2) | (0 << 1) | 0); //SnpResp_I
											cmstatusq.push_back((0 << 5) | (0 << 4) | (0 << 3) | (1 << 2) | (0 << 1) | 0); //SnpRespData_I
											idx = $urandom_range(cmstatusq.size() - 1);
											cmstatus = cmstatusq[idx];
										end else if (snooper_initial_st inside {SC, UCE}) begin
											cmstatus = ((0 << 5) | (0 << 4) | (0 << 3) | (1 << 2) | (1 << 1) | 0); //SnpResp_DataPtl_I_PD
											//cmstatus = 6'b000110;
										end else if (snooper_initial_st == IX) begin
											cmstatus = 6'b000000;
										end	
									end

                        		  end
                      endcase
	//`uvm_info("DCE_CONT_DBG",$psprintf("Inside SNP_NITC with snooper final state selected = %p and after case CM status is %p",snooper_final_st,cmstatus), UVM_LOW) 
    	           end 
    SNP_INV_DTR:   begin
			if(snooper_initial_st == UDP)
                      		cmstatus = ((0 << 5) | (0 << 4) | (1 << 3) | (1 << 2) | (1 << 1) | 0); //SnpRespDataPtl_I_PD
                      	else if(snooper_initial_st inside {UD,SD} && up == 2'b01) 
                      		cmstatus = ((0 << 5) | (0 << 4) | (1 << 3) | (1 << 2) | (0 << 1) | 0); //SnpRespData_I_PD
			else if(snooper_initial_st inside {SD, SC} && up == 2'b11 && (snooper_funitid == snp_mpf3)) //UP == 2'11 issue DTW to DMI instead of DTR to AIU.
                      		cmstatus = ((0 << 5) | (0 << 4) | (0 << 3) | (0 << 2) | (1 << 1) | 0); //SnpRespData_I_PD, SnpRespDataPtl_I_PD, SnpRespData_I
			else if (snooper_initial_st inside {UC,SC} && up == 2'b01) begin
                                 	//                  {rv,        rs,        dc,       dt_aiu,   dt_dmi,    snarf}
                                    cmstatusq.push_back((0 << 5) | (0 << 4) | (0 << 3) | (0 << 2) | (0 << 1) | 0); //SnpResp_I
                                    cmstatusq.push_back((0 << 5) | (0 << 4) | (1 << 3) | (1 << 2) | (0 << 1) | 0); //SnpRespData_I
                                    idx = $urandom_range(cmstatusq.size() - 1);
                                    cmstatus = cmstatusq[idx];
			end
                      	else if(snooper_initial_st inside {SC, UCE, IX}) 
                      		cmstatus = ((0 << 5) | (0 << 4) | (0 << 3) | (0 << 2) | (0 << 1) | 0); //SnpResp_I
    	          end 
    //WrUnqPtl --> SnpCleanInvalid (CHI-A/CHI-B)
    //ClnUnique, CleanInvalid --> SnpCleanInvalid (CHI-A/CHI-B)
    //Atomic --> SnpCleanInvalid (CHI-B only)
    SNP_INV_DTW:  begin
                      case(snooper_initial_st)
                      	UD, UDP, SD: cmstatus = ((0 << 5) | (0 << 4) | (0 << 3) | (0 << 2) | (1 << 1) | 0); //SnpRespData_I_PD, SnpRespDataPtl_I_PD, SnpRespData_I
                      	SC, UC, UCE, IX: cmstatus = ((0 << 5) | (0 << 4) | (0 << 3) | (0 << 2) | (0 << 1) | 0); //SnpResp_I
 					  endcase
    			  end
    //SnpMakeInvalid (CHI-A/CHI-B)
    SNP_INV:      begin
                       //         {rv,       rs,        dc,        dt_aiu,    dt_dmi,    snarf}
                       cmstatus = ((0 << 5) | (0 << 4) | (0 << 3) | (0 << 2) | (0 << 1) | 0);                               
    	          end 
	//CHI - SnpUnique
    SNP_NITCCI:   begin
                      case(snooper_initial_st)
                      	UDP, 
                      	UD, 
                      	SD: cmstatus = ((0 << 5) | (0 << 4) | (0 << 3) | (1 << 2) | (1 << 1) | 0); //SnpRespDataPtl_I_PD, SnpRespData_I_PD 
                      	UC: begin 
                       				//                  {rv,       rs,        dc,        dt_aiu,    dt_dmi,    snarf}
                       				cmstatusq.push_back((0 << 5) | (0 << 4) | (0 << 3) | (0 << 2) | (0 << 1) | 0); //SnpResp_I
							  	  	if (ncoreConfigInfo::get_native_interface(agentid) != ncoreConfigInfo::ACE_AIU)
                       					cmstatusq.push_back((0 << 5) | (0 << 4) | (0 << 3) | (1 << 2) | (0 << 1) | 0); //SnpRespData_I
                                    idx = $urandom_range(cmstatusq.size() - 1);
                                    cmstatus = cmstatusq[idx];
                                  end
                        UCE,
                      	SC, IX: cmstatus = ((0 << 5) | (0 << 4) | (0 << 3) | (0 << 2) | (0 << 1) | 0); //SnpResp_I
                      endcase
    	          end 

    //CHI SnpUnique
    SNP_NITCMI:   begin
                      case(snooper_initial_st)
                      	UDP: cmstatus = ((0 << 5) | (0 << 4) | (0 << 3) | (1 << 2) | (1 << 1) | 0); //SnpRespDataPtl_I_PD 
                      	UD,
                      	SD: 
                      			begin 
							  	  	if (ncoreConfigInfo::get_native_interface(agentid) == ncoreConfigInfo::ACE_AIU)
                      					cmstatus = ((0 << 5) | (0 << 4) | (0 << 3) | (1 << 2) | (1 << 1) | 0); //SnpRespData_I_PD
                      				else 
                      					cmstatus = ((0 << 5) | (0 << 4) | (0 << 3) | (1 << 2) | (0 << 1) | 0); //SnpRespData_I_PD
                      			end 
                      	UC: begin 
                       				//                  {rv,       rs,        dc,        dt_aiu,    dt_dmi,    snarf}
                       				cmstatusq.push_back((0 << 5) | (0 << 4) | (0 << 3) | (0 << 2) | (0 << 1) | 0); //SnpResp_I                      							       
							  	  	if (ncoreConfigInfo::get_native_interface(agentid) != ncoreConfigInfo::ACE_AIU)
                       					cmstatusq.push_back((0 << 5) | (0 << 4) | (0 << 3) | (1 << 2) | (0 << 1) | 0); //SnpRespData_I
                                    idx = $urandom_range(cmstatusq.size() - 1);
                                    cmstatus = cmstatusq[idx];
                                  end
                      	UCE,
                      	SC, IX: 
						begin
                      		cmstatus = ((0 << 5) | (0 << 4) | (0 << 3) | (0 << 2) | (0 << 1) | 0); //SnpResp_I
                    	end
                      endcase
    	          end 

     //StashOnceShared/LD_CCH_SHD
     //---------------------------------- ------------------------------------|----------------------------------- ---------------------------------
     // CHI Spec - Table 4-22 : Snoop response to SnpStashShared              |  CHI Spec - Table 4-17 : Snoop response to SnpShared               -
     //---------------------------------- ------------------------------------|---------------------------------------------------------------------
     // Init  Final    SnpRsp(Tgt)      - SnpRsp(Tgt)    rv,rs,dc,dt[1:0]+snf |  Init  Final    SnpRsp(Oth)         - SnpRsp(Oth)  rv,rs,dc,dt[1:0]-
     //---------------------------------- ------------------------------------|---------------------------------------------------------------------
     // I     I        SnpResp_I_Read   - SnpResp_I_Read   00000 + 1          |  I     I        SnpResp_I           - SnpResp_I             00000  -
     // I     I        SnpResp_I        - SnpResp_I        00000 + 0          |  UC    SC       SnpResp_SC          - SnpResp_SC            11000  -
     // UC    UC       SnpResp_UC       - SnpResp_UC       10000 + 0          |  UC    SC       SnpRespData_SC      - SnpRespData_SC        11001  -
     // UC    UC       SnpResp_I        - SnpResp_UC_Read  10000 + 1          |  UC    I        SnpResp_I           - SnpRespData_I         00001  -
     // UCE   UCE      SnpResp_UC       - SnpResp_UD       10000 + 0          |  UC    I        SnpRespData_I       - SnpRespDataPtl_I_PD   00001  -
     // UCE   UCE      SnpResp_UC_Read  - SnpResp_SC       11000 + 0          |  UCE   I        SnpResp_I           - SnpRespData_SD        10001  -
     // UCE   UCE      SnpResp_I        - SnpResp_SD       10000 + 0          |  UDP   I        SnpRespDataPtl_I_PD - SnpRespData_SC_PD     11001  -
     // UD    UD       SnpResp_UD       -                                     |  UD    SD       SnpRespData_SD      - SnpRespData_I_PD      00001  -
     // UD    UD       SnpResp_I        -                                     |  UD    SC       SnpRespData_SC_PD   -                              -
     // UDP   UDP      SnpResp_UD       -                                     |  UD    I        SnpRespData_I_PD    -                              -
     // UDP   UDP      SnpResp_I        -                                     |  SD    SD       SnpRespData_SD      -                              -
     // SC    SC       SnpResp_SC       -                                     |  SD    SC       SnpRespData_SC_PD   -                              -
     // SC    SC       SnpResp_I        -                                     |  SD    I        SnpRespData_I_PD    -                              -
     // SD    SD       SnpResp_SD       -                                     |  SC    SC       SnpResp_SC          -                              -
     // SD    SD       SnpResp_I        -                                     |  SC    I        SnpResp_I           -                              -
     //---------------------------------- ------------------------------------|---------------------------------------------------------------------
     SNP_STSH_SH: begin 
                      if(is_stash_target) begin
                          case(snooper_initial_st)
                              IX: begin 
                                            //                  {rv,       rs,        dc,        dt_aiu,    dt_dmi,    snarf}
                                            cmstatusq.push_back((0 << 5) | (0 << 4) | (0 << 3) | (0 << 2) | (0 << 1) | 1); //SnpResp_I_Read
                                            cmstatusq.push_back((0 << 5) | (0 << 4) | (0 << 3) | (0 << 2) | (0 << 1) | 0); //SnpResp_I
                                        end
                              UC: begin 
                                            //                  {rv,       rs,        dc,        dt_aiu,    dt_dmi,    snarf}
                                            cmstatusq.push_back((1 << 5) | (0 << 4) | (0 << 3) | (0 << 2) | (0 << 1) | 0); //SnpResp_UC
                                            cmstatusq.push_back((0 << 5) | (0 << 4) | (0 << 3) | (0 << 2) | (0 << 1) | 0); //SnpResp_I
                                        end
                              UCE: begin 
                                            //                  {rv,       rs,        dc,        dt_aiu,    dt_dmi,    snarf}
                                            cmstatusq.push_back((1 << 5) | (0 << 4) | (0 << 3) | (0 << 2) | (0 << 1) | 1); //SnpResp_UC_Read
                                            cmstatusq.push_back((1 << 5) | (0 << 4) | (0 << 3) | (0 << 2) | (0 << 1) | 0); //SnpResp_UC
                                            cmstatusq.push_back((0 << 5) | (0 << 4) | (0 << 3) | (0 << 2) | (0 << 1) | 0); //SnpResp_I
                                        end
                              UD,
                              UDP,
                              SD: begin 
                                            //                  {rv,       rs,        dc,        dt_aiu,    dt_dmi,    snarf}
                                            cmstatusq.push_back((1 << 5) | (0 << 4) | (0 << 3) | (0 << 2) | (0 << 1) | 0); //SnpResp_UD,SnpResp_SD
                                            cmstatusq.push_back((0 << 5) | (0 << 4) | (0 << 3) | (0 << 2) | (0 << 1) | 0); //SnpResp_I
                                        end
                              SC: begin 
                                            //                  {rv,       rs,        dc,        dt_aiu,    dt_dmi,    snarf}
                                            cmstatusq.push_back((1 << 5) | (1 << 4) | (0 << 3) | (0 << 2) | (0 << 1) | 0); //SnpResp_SC
                                            cmstatusq.push_back((0 << 5) | (0 << 4) | (0 << 3) | (0 << 2) | (0 << 1) | 0); //SnpResp_I
                                            cmstatusq.push_back((0 << 5) | (0 << 4) | (0 << 3) | (0 << 2) | (0 << 1) | 1); //SnpResp_SC_Read
                                        end
                          endcase
                          idx = $urandom_range(cmstatusq.size() - 1);
                          cmstatus = cmstatusq[idx];
			   if($test$plusargs("dce_snprsp_snarf1_error_seq"))
			   	cmstatus = 6'b000001;
						  if(cmstatus[0] == 1) begin  //snarf=1
                          	if(cmstatus[5] & !cmstatus[4]) //stash target is the owner
                                 snooper_final_st = UC;
                          	else
                             	 snooper_final_st = SC;
                          end else begin //snarf=0
                              snooper_final_st = snooper_initial_st;
                          end
                      end else begin // Non-Stashing Targets only Owner will be snoopedif 
						  if (ncoreConfigInfo::get_native_interface(agentid) == ncoreConfigInfo::ACE_AIU) begin //See CHI-ConcertoCMapping_0.87 ACE snooper always downgrades to IX
							  snooper_final_st = IX;
						  end else begin 
							  if (snooper_initial_st inside {UD, SD})
								possible_final_stq = {SD, SC, IX};
							  else if (snooper_initial_st inside {SC, UC})
								possible_final_stq = {SC, IX};
							  else if (snooper_initial_st inside {UCE, UDP, IX})
								possible_final_stq = {IX};
							  idx = $urandom_range(possible_final_stq.size() - 1);
							  snooper_final_st = possible_final_stq[idx];
					  	  end

                          case(snooper_final_st)
							  IX:  begin
							  	  			if (ncoreConfigInfo::get_native_interface(agentid) == ncoreConfigInfo::ACE_AIU) begin
												if (snooper_initial_st inside {UD, SD}) begin
                       								cmstatusq.push_back((0 << 5) | (0 << 4) | (0 << 3) | (0 << 2) | (1 << 1) | 0);
                       							end else begin 
                       								cmstatusq.push_back((0 << 5) | (0 << 4) | (0 << 3) | (0 << 2) | (0 << 1) | 0); 
												end
											end else if (ncoreConfigInfo::get_native_interface(agentid) inside {ncoreConfigInfo::CHI_A_AIU, ncoreConfigInfo::CHI_B_AIU}) begin
												if (snooper_initial_st inside {UDP, UD, SD}) begin
                       								cmstatusq.push_back((0 << 5) | (0 << 4) | (0 << 3) | (0 << 2) | (1 << 1) | 0); //SnpRespData_I, SnpRespData_I_PD, SnpRespDataPtl_I_PD
                       							end else if (snooper_initial_st == UC) begin 
                       								cmstatusq.push_back((0 << 5) | (0 << 4) | (0 << 3) | (0 << 2) | (1 << 1) | 0); //SnpRespData_I, SnpRespData_I_PD, SnpRespDataPtl_I_PD
                       								cmstatusq.push_back((0 << 5) | (0 << 4) | (0 << 3) | (0 << 2) | (0 << 1) | 0); //SnpResp_I
												end else begin //SC, UCE, IX
                       								cmstatusq.push_back((0 << 5) | (0 << 4) | (0 << 3) | (0 << 2) | (0 << 1) | 0); //SnpResp_I
												end
							  	  			end else begin //proxyCache
                       							cmstatusq.push_back((0 << 5) | (0 << 4) | (0 << 3) | (0 << 2) | (0 << 1) | 0); //SnpResp_I
							  	  			end 
										 end
							  SC:  begin 
							  	  			if (ncoreConfigInfo::get_native_interface(agentid) inside {ncoreConfigInfo::CHI_A_AIU, ncoreConfigInfo::CHI_B_AIU, ncoreConfigInfo::ACE_AIU}) begin
												if (snooper_initial_st inside {UD, SD}) begin
													cmstatusq.push_back((1 << 5) | (1 << 4) | (0 << 3) | (0 << 2) | (1 << 1) | 0); //SnpRespData_SC, SnpRespData_SC_PD
												end else if (snooper_initial_st == SC) begin
													cmstatusq.push_back((1 << 5) | (1 << 4) | (0 << 3) | (0 << 2) | (0 << 1) | 0); //SnpResp_SC
												end else begin //UC
													cmstatusq.push_back((1 << 5) | (1 << 4) | (0 << 3) | (0 << 2) | (1 << 1) | 0); //SnpRespData_SC, SnpRespData_SC_PD
													cmstatusq.push_back((1 << 5) | (1 << 4) | (0 << 3) | (0 << 2) | (0 << 1) | 0); //SnpResp_SC
												end
											end else begin  //proxyCache
                       							cmstatusq.push_back((1 << 5) | (1 << 4) | (0 << 3) | (0 << 2) | (0 << 1) | 0); //SnpResp_SC
											end
										 end
							  SD:  begin 
							  	  			if (ncoreConfigInfo::get_native_interface(agentid) == ncoreConfigInfo::ACE_AIU) begin
        										cmstatusq.push_back((1 << 5) | (0 << 4) | (0 << 3) | (0 << 2) | (0 << 1) | 0); //SnpRespData_SD
											end else begin //CHI/proxyCache
        										cmstatusq.push_back((1 << 5) | (0 << 4) | (0 << 3) | (0 << 2) | (1 << 1) | 0); //SnpRespData_SD
											end
							  			 end 
						  endcase
                          idx = $urandom_range(cmstatusq.size() - 1);
                          cmstatus = cmstatusq[idx];
                      end //non-stash target
                  end
     //StashOnceUnique/LD_CCH_UNQ
     //---------------------------------- ------------------------------------|----------------------------------- ---------------------------------
     // CHI Spec - Table 4-21 : Snoop response to SnpStashUnique              |  CHI Spec - Table 4-18 : Snoop response to SnpUnique               -
     //---------------------------------- ------------------------------------|---------------------------------------------------------------------
     // Init  Final    SnpRsp(Tgt)      - SnpRsp(Tgt)    rv,rs,dc,dt[1:0]+snf |  Init  Final    SnpRsp(Oth)         - SnpRsp(Oth)  rv,rs,dc,dt[1:0]-
     //---------------------------------- ------------------------------------|---------------------------------------------------------------------
     // I     I        SnpResp_I        - SnpResp_I        00000 + 0          |  I     I        SnpResp_I           - SnpResp_I             00000  -
     // I     I        SnpResp_I_Read   - SnpResp_I_Read   00000 + 1          |  UC    I        SnpResp_I           - SnpRespData_I         00001  -
     // UC    UC       SnpResp_UC       - SnpResp_UC       10000 + 0          |  UC    I        SnpRespData_I       - SnpRespDataPtl_I_PD   00001  -
     // UC    UC       SnpResp_I        - SnpResp_UC_Read  10000 + 1          |  UCE   I        SnpResp_I           - SnpRespData_I_PD      00001  -
     // UCE   UCE      SnpResp_UC       - SnpResp_UD       10000 + 0          |  UDP   I        SnpRespDataPtl_I_PD -                              -
     // UCE   UCE      SnpResp_UC_Read  - SnpResp_SC       11000 + 0          |  UD    I        SnpRespData_I_PD    -                              -
     // UCE   UCE      SnpResp_I        - SnpResp_SC_Read  11000 + 1          |  SD    I        SnpRespData_I_PD    -                              -
     // UD    UD       SnpResp_UD       - SnpResp_SD       10000 + 0          |  SC    I        SnpResp_I           -                              -
     // UD    UD       SnpResp_I        - SnpResp_SD_Read  10000 + 1          |                                     -                              -
     // UDP   UDP      SnpResp_UD       -                                     |                                     -                              -
     // UDP   UDP      SnpResp_I        -                                     |                                     -                              -
     // SC    SC       SnpResp_SC       -                                     |                                     -                              -
     // SC    SC       SnpResp_SC_Read  -                                     |                                     -                              -
     // SC    SC       SnpResp_I        -                                     |                                     -                              -
     // SD    SD       SnpResp_SD       -                                     |                                     -                              -
     // SD    SD       SnpResp_SD_Read  -                                     |                                     -                              -
     // SD    SD       SnpResp_I        -                                     |                                     -                              -
     //---------------------------------- ------------------------------------|---------------------------------------------------------------------
     SNP_STSH_UNQ: begin 
                       if(is_stash_target) begin
                           case(snooper_initial_st)
                               IX: begin 
                                             //                  {rv,       rs,        dc,        dt_aiu,    dt_dmi,    snarf}
                                             cmstatusq.push_back((0 << 5) | (0 << 4) | (0 << 3) | (0 << 2) | (0 << 1) | 1); //SnpResp_I_Read
                                             cmstatusq.push_back((0 << 5) | (0 << 4) | (0 << 3) | (0 << 2) | (0 << 1) | 0); //SnpResp_I
                                         end
                               UC: begin 
                                             //                  {rv,       rs,        dc,        dt_aiu,    dt_dmi,    snarf}
                                             cmstatusq.push_back((1 << 5) | (0 << 4) | (0 << 3) | (0 << 2) | (0 << 1) | 0); //SnpResp_UC
                                             cmstatusq.push_back((0 << 5) | (0 << 4) | (0 << 3) | (0 << 2) | (0 << 1) | 0); //SnpResp_I
                                         end
                               UCE: begin 
                                             //                  {rv,       rs,        dc,        dt_aiu,    dt_dmi,    snarf}
                                             cmstatusq.push_back((1 << 5) | (0 << 4) | (0 << 3) | (0 << 2) | (0 << 1) | 1); //SnpResp_UC_Read
                                             cmstatusq.push_back((1 << 5) | (0 << 4) | (0 << 3) | (0 << 2) | (0 << 1) | 0); //SnpResp_UC
                                             cmstatusq.push_back((0 << 5) | (0 << 4) | (0 << 3) | (0 << 2) | (0 << 1) | 0); //SnpResp_I
                                         end
                               UD, UDP: begin 
                                             //                  {rv,       rs,        dc,        dt_aiu,    dt_dmi,    snarf}
                                             cmstatusq.push_back((1 << 5) | (0 << 4) | (0 << 3) | (0 << 2) | (0 << 1) | 0); //SnpResp_UD
                                             cmstatusq.push_back((0 << 5) | (0 << 4) | (0 << 3) | (0 << 2) | (0 << 1) | 0); //SnpResp_I
                                         end
                               SC: begin 
                                             //                  {rv,       rs,        dc,        dt_aiu,    dt_dmi,    snarf}
                                             cmstatusq.push_back((1 << 5) | (1 << 4) | (0 << 3) | (0 << 2) | (0 << 1) | 0); //SnpResp_SC
                                             cmstatusq.push_back((1 << 5) | (1 << 4) | (0 << 3) | (0 << 2) | (0 << 1) | 1); //SnpResp_SC_Read
                                             cmstatusq.push_back((0 << 5) | (0 << 4) | (0 << 3) | (0 << 2) | (0 << 1) | 0); //SnpResp_I
                                         end
                               SD: begin 
                                             //                  {rv,       rs,        dc,        dt_aiu,    dt_dmi,    snarf}
                                             cmstatusq.push_back((1 << 5) | (0 << 4) | (0 << 3) | (0 << 2) | (0 << 1) | 0); //SnpResp_SD
                                             cmstatusq.push_back((1 << 5) | (0 << 4) | (0 << 3) | (0 << 2) | (0 << 1) | 1); //SnpResp_SD_Read
                                             cmstatusq.push_back((0 << 5) | (0 << 4) | (0 << 3) | (0 << 2) | (0 << 1) | 0); //SnpResp_I
                                         end
                           endcase
                           idx = $urandom_range(cmstatusq.size() - 1);
                           cmstatus = cmstatusq[idx];
			   if($test$plusargs("dce_snprsp_snarf1_error_seq"))
			   	cmstatus = 6'b000001;
						   if (cmstatus[0] == 1) begin//stash accepted
                           		snooper_final_st = UC;
						   end else begin //is stash not accepted, snoopee does not change state
                                snooper_final_st = snooper_initial_st;
						   end
                       end else begin // Non-Stashing Targets
                           case(snooper_initial_st)
                               IX,
                               SC,
                               UCE: begin 
                                             //                  {rv,       rs,        dc,        dt_aiu,    dt_dmi,    snarf}
                                             cmstatusq.push_back((0 << 5) | (0 << 4) | (0 << 3) | (0 << 2) | (0 << 1) | 0); //SnpResp_I
                                         end
                               UC: begin 
                                             //                  {rv,       rs,        dc,        dt_aiu,    dt_dmi,    snarf}
                                             cmstatusq.push_back((0 << 5) | (0 << 4) | (0 << 3) | (0 << 2) | (0 << 1) | 0); //SnpResp_I
                                             cmstatusq.push_back((0 << 5) | (0 << 4) | (0 << 3) | (0 << 2) | (1 << 1) | 0); //SnpRespData_I
                                         end
                               UD, 
                               UDP,
                               SD: begin 
                                             //                  {rv,       rs,        dc,        dt_aiu,    dt_dmi,    snarf}
                                             cmstatusq.push_back((0 << 5) | (0 << 4) | (0 << 3) | (0 << 2) | (1 << 1) | 0); //SnpRespData_I_PD,SnpRespDataPtl_I_PD
                                         end
                           endcase
                           snooper_final_st = IX;
                           idx = $urandom_range(cmstatusq.size() - 1);
                           cmstatus = cmstatusq[idx];
                       end
                  end

     //StashWriteFull/WR_STASH_FULL
     //---------------------------------- ------------------------------------|----------------------------------- ---------------------------------
     // CHI Spec - Table 4-20 : Snoop response to SnpMakeInvalidStash         |  CHI Spec - Table 4-19 : Snoop response to SnpMakeInvalid          -
     //---------------------------------- ------------------------------------|---------------------------------------------------------------------
     // Init  Final    SnpRsp(Tgt)      - SnpRsp(Tgt)    rv,rs,dc,dt[1:0]+snf |  Init  Final    SnpRsp(Oth)         - SnpRsp(Oth)  rv,rs,dc,dt[1:0]-
     //---------------------------------- ------------------------------------|---------------------------------------------------------------------
     // ANY   I        SnpResp_I        - SnpResp_I        00000 + 0/1        |  I     I        SnpResp_I           - SnpResp_I             00000  -
     //---------------------------------- ------------------------------------|---------------------------------------------------------------------
     SNP_INV_STSH: begin 
                       if(is_stash_target) begin
                           //                  {rv,       rs,        dc,        dt_aiu,    dt_dmi,    snarf}
                           cmstatusq.push_back((0 << 5) | (0 << 4) | (0 << 3) | (0 << 2) | (0 << 1) | 1); //SnpResp_I_Read
                           cmstatusq.push_back((0 << 5) | (0 << 4) | (0 << 3) | (0 << 2) | (0 << 1) | 0); //SnpResp_I
                       end else begin // Non-Stashing Targets
                           //                  {rv,       rs,        dc,        dt_aiu,    dt_dmi,    snarf}
                           cmstatusq.push_back((0 << 5) | (0 << 4) | (0 << 3) | (0 << 2) | (0 << 1) | 0); //SnpResp_I
                       end
                       idx = $urandom_range(cmstatusq.size() - 1);
                       cmstatus = cmstatusq[idx];
                       snooper_final_st = (cmstatus[0]==1) ? UD : IX;
                   end
     
     //StashWritePtl/WR_STASH_PTL
     //StashOnceUnique/LD_CCH_UNQ
     //---------------------------------- ---------------------------------------|----------------------------------- ---------------------------------
     // CHI Spec - Table 4-20 : Snoop response to SnpUniqueStash                 |  CHI Spec - Table 4-18 : Snoop response to SnpUnique               -
     //------------------------------------- ------------------------------------|---------------------------------------------------------------------
     // Init  Final    SnpRsp(Tgt)         - SnpRsp(Tgt)    rv,rs,dc,dt[1:0]+snf |  Init  Final    SnpRsp(Oth)         - SnpRsp(Oth)  rv,rs,dc,dt[1:0]-
     //------------------------------------- ------------------------------------|---------------------------------------------------------------------
     // I     I        SnpResp_I           - SnpResp_I             00000 + 0/1   |  I     I        SnpResp_I           - SnpResp_I             00000  -
     // UC    I        SnpRespData_I       - SnpRespData_I*(UP!=01)00000 + 0/1   |  UC    I        SnpResp_I           - SnpRespData_I         00001  -
     // UC    I        SnpResp_I           - SnpRespData_I*(UP==01)00001 + 0/1   |  UC    I        SnpRespData_I       - SnpRespDataPtl_I_PD   00001  -
     // UCE   I        SnpResp_I           - SnpRespDataPtl_I_PD   00001 + 0/1   |  UCE   I        SnpResp_I           - SnpRespData_I_PD      00001  -
     // UD    I        SnpRespData_I_PD    - SnpRespData_I_PD      00001 + 0/1   |  UDP   I        SnpRespDataPtl_I_PD -                              -
     // UDP   I        SnpRespDataPtl_I_PD -                                     |  UD    I        SnpRespData_I_PD    -                              -
     // SC    I        SnpResp_I           -                                     |  SD    I        SnpRespData_I_PD    -                              -
     // SC    I        SnpRespData_I       -                                     |  SC    I        SnpResp_I           -                              -
     // SD    I        SnpRespData_I_PD    -                                     |                                     -                              -
     //---------------------------------- ---------------------------------------|---------------------------------------------------------------------
     SNP_UNQ_STSH: begin 
                       if(is_stash_target) begin
                           case(snooper_initial_st)
                               IX,
                               UCE: begin 
                                             //                  {rv,       rs,        dc,        dt_aiu,    dt_dmi,    snarf}
                                             cmstatusq.push_back((0 << 5) | (0 << 4) | (0 << 3) | (0 << 2) | (0 << 1) | 1); //SnpResp_I Snarf
                                             cmstatusq.push_back((0 << 5) | (0 << 4) | (0 << 3) | (0 << 2) | (0 << 1) | 0); //SnpResp_I
                                         end
                               UC, SC: begin 
                                                     //                  {rv,       rs,        dc,        dt_aiu,    dt_dmi,    snarf}
                                             if(up == 2'b01)  cmstatusq.push_back((0 << 5) | (0 << 4) | (0 << 3) | (0 << 2) | (1 << 1) | 1); //SnpRespData_I*(UP==01) Snarf
                                             if(up == 2'b01)  cmstatusq.push_back((0 << 5) | (0 << 4) | (0 << 3) | (0 << 2) | (1 << 1) | 0); //SnpRespData_I*(UP==01)
                                                     cmstatusq.push_back((0 << 5) | (0 << 4) | (0 << 3) | (0 << 2) | (0 << 1) | 1); //SnpResp_I/SnpRespData_I*(UP!=01) Snarf
                                                     cmstatusq.push_back((0 << 5) | (0 << 4) | (0 << 3) | (0 << 2) | (0 << 1) | 0); //SnpResp_I/SnpRespData_I*(UP!=01)
                                         end
                               UD, 
                               UDP,
                               SD: begin 
                                             //                  {rv,       rs,        dc,        dt_aiu,    dt_dmi,    snarf}
                                             cmstatusq.push_back((0 << 5) | (0 << 4) | (0 << 3) | (0 << 2) | (1 << 1) | 1); //SnpRespData_I_PD/SnpRespDataPtl_I_PD Snarf
                                             cmstatusq.push_back((0 << 5) | (0 << 4) | (0 << 3) | (0 << 2) | (1 << 1) | 0); //SnpRespData_I_PD/SnpRespDataPtl_I_PD
                                         end
                           endcase
                       end else begin // Non-Stashing Targets
                           case(snooper_initial_st)
                               IX,
                               SC,
                               UCE: begin 
                                             //                  {rv,       rs,        dc,        dt_aiu,    dt_dmi,    snarf}
                                             cmstatusq.push_back((0 << 5) | (0 << 4) | (0 << 3) | (0 << 2) | (0 << 1) | 0); //SnpResp_I
                                         end
                               UC: begin 
                                             //                  {rv,       rs,        dc,        dt_aiu,    dt_dmi,    snarf}
                                             cmstatusq.push_back((0 << 5) | (0 << 4) | (0 << 3) | (0 << 2) | (0 << 1) | 0); //SnpResp_I
                                             cmstatusq.push_back((0 << 5) | (0 << 4) | (0 << 3) | (0 << 2) | (1 << 1) | 0); //SnpRespData_I
                                         end
                               UD,
                               UDP,
                               SD: begin 
                                             //                  {rv,       rs,        dc,        dt_aiu,    dt_dmi,    snarf}
                                             cmstatusq.push_back((0 << 5) | (0 << 4) | (0 << 3) | (0 << 2) | (1 << 1) | 0); //SnpRespData_I_PD,SnpRespDataPtl_I_PD
                                         end
                           endcase
                       end
                       idx = $urandom_range(cmstatusq.size() - 1);
                       cmstatus = cmstatusq[idx];
			if($test$plusargs("dce_snprsp_snarf1_error_seq") && is_stash_target)
				cmstatus = 6'b000001;
                       snooper_final_st = (cmstatus[0]==1) ? UD : IX;
                   end
    endcase
 if(cmstatus == 6'b111111 && !$test$plusargs("dir_double_bit_direct_tag_error_test")) begin
	`uvm_error("DCE_CONTAINER",$psprintf("Need to determine the cm status for this case snoop : %p, initial_cache_state %p final_cache_state %p and up %p snooper_type %p",snp_type,snooper_initial_st, snooper_final_st,up,ncoreConfigInfo::get_native_interface(snooper_funitid)));
 end
 else if (cmstatus == 6'b111111 && $test$plusargs("dir_double_bit_direct_tag_error_test")) begin
	cmstatus = 6'b000000;
 end
	if($test$plusargs("enable_random_snprsp_error")) begin
		if(snp_type inside {SNP_INV_DTW, SNP_INV_DTR, SNP_INV, SNP_INV_STSH, SNP_UNQ_STSH, SNP_STSH_UNQ}) begin //Invalidating Snoop Types
			if($urandom(100) > 30) begin
				if($urandom(10) > 6)
					cmstatus = 8'b1000_0100;
				else
					cmstatus = 8'b1000_0011;
			end
		end
		else begin
			if($urandom(100) > 40) begin
				if($urandom(10) > 6)
					cmstatus = 8'b1000_0100;
				else
					cmstatus = 8'b1000_0011;
				if($urandom(10) > 4)
					snooper_final_st = IX;
				else
					snooper_final_st = snooper_initial_st;
			end
		end
	end

 
 `uvm_info("SNPRSP_CMSTATUS", $psprintf("snp_type:%p snooper_initial_st: %p snooper_final_st: %p cmstatus: 0x%0h", snp_type, snooper_initial_st, snooper_final_st, cmstatus), UVM_LOW);
  return cmstatus;

endfunction:get_snprsp_cmstatus 

//*************************************************************
static function smi_cmstatus_t dce_container::get_strrsp_cmstatus(smi_seq_item strreq);



endfunction:get_strrsp_cmstatus 

//*************************************************************
static function void dce_container::predict_master_final_state(int agentid, int smi_msg_id, bit cmstatus_exokay_or_updreq_pass = 0, bit owner_present = 0, bit vld_tgt_identified = 0, ncore_cache_state_t req_state = IX, smi_cmstatus_state_t str_cm_state = 'b000);
    bit updated = 0;
    ncore_cache_state_t possible_final_stq[$];
    ncore_cache_model foundq[$];
    int idx, id, cacheid;
    bit do_not_update = 0;
  	addr_width_t bit_mask_const = ('h1_FFFF_FFFF_FFFF << ncoreConfigInfo::WCACHE_OFFSET);
  	addr_width_t cacheline_addr;

//    foreach(m_inflight_txns[i]) begin
//    	`uvm_info("DBG_INFLIGHT_TXNQ", $psprintf("IDX: %0d %0s", i, m_inflight_txns[i].convert2string()), UVM_LOW);
//    end

	cacheid = ncoreConfigInfo::get_cache_id(agentid);
    `uvm_info("DBG", $psprintf("predict_master_final_st --> msgid: 0x%0h in agentid:%0d cacheid:%0d cmstatus_exokay_or_updreq_pass:%0d owner_present:%0d vld_tgt_identified:%0b", smi_msg_id, agentid, cacheid, cmstatus_exokay_or_updreq_pass, owner_present, vld_tgt_identified), UVM_LOW);

    foreach (m_inflight_txns[idx]) begin
      if (m_inflight_txns[idx].is_msgid_inuse() && (m_inflight_txns[idx].get_msg_id() == smi_msg_id) && (m_inflight_txns[idx].get_master_id() == agentid)) begin
      	cacheline_addr = m_inflight_txns[idx].get_addr() & bit_mask_const;

      	if (m_inflight_txns[idx].m_cmd_n_upd_req) begin  //For CMD_REQs
      	
			case (m_inflight_txns[idx].get_msg_type()) 
				CMD_RD_NITC: begin 
							 foundq = m_cachelines_st.find(x) with (x.get_addr() == cacheline_addr);
						   	 if (foundq.size() != 1) 
							  	`uvm_error("PRDCT_FNL_MSTRST", $psprintf("addr: 0x%0x was not loaded into ncore_cache_model?", cacheline_addr));
							 if (ncoreConfigInfo::get_native_interface(agentid) == ncoreConfigInfo::ACE_AIU) begin
							 	//initial cache-state is unmodified if master is ACE 
								m_inflight_txns[idx].set_master_final_st(foundq[0].get_cache_state(cacheid));
						  	 end else begin 
								m_inflight_txns[idx].set_master_final_st(IX);
					  		 end 

							 end 
				CMD_RD_CLN : begin
								m_inflight_txns[idx].set_master_final_st(UC);
								foundq = m_cachelines_st.find(x) with (x.get_addr() == cacheline_addr);
								if (foundq.size() != 1) 
								   `uvm_error("PRDCT_FNL_MSTRST", $psprintf("addr: 0x%0x was not loaded into ncore_cache_model?", cacheline_addr));
									
								//If RD_CLN hits with requestor in IX, SC and there is no owner present, final state would be SC
								if ((foundq[0].m_cache_st_p_agent[cacheid] inside {SC, IX}) && !owner_present) begin
									m_inflight_txns[idx].set_master_final_st(SC);
									do_not_update = 1;
								end 

								//If RD_CLN hits with requestor in SD and other sharers in SC, no need to update master_state, CMT_REQ == LKP_RSP
								if (foundq[0].m_cache_st_p_agent[cacheid] == SD) begin
								//	`uvm_info("DCE_CONT_DBG_1", $psprintf("value of str_cm_state: %p",str_cm_state),UVM_LOW)
									foreach(foundq[0].m_cache_st_p_agent[i]) begin
										if ((i != cacheid) && (foundq[0].get_cache_state(i) == SC)) begin
											m_inflight_txns[idx].set_master_final_st(SD);
											do_not_update = 1;
											break;
										end
									end
									if(str_cm_state == 'b010) begin		// Added this if there is a silent cache transition and directory didnot snooped the transitioned cache
										m_inflight_txns[idx].set_master_final_st(SD);
										do_not_update = 1;
									end 
								end
								
								if (do_not_update == 0) begin
									foreach(foundq[0].m_cache_st_p_agent[i]) begin
										if ((i != cacheid) && (foundq[0].m_cache_st_p_agent[i] != IX)) begin
											m_inflight_txns[idx].set_master_final_st(SC);
											break;
										end
									end
								end 
							 end
				CMD_RD_VLD : begin
								possible_final_stq = {UD, UC}; 
								id = $urandom_range(possible_final_stq.size() - 1);
								m_inflight_txns[idx].set_master_final_st(possible_final_stq[id]);
								foundq = m_cachelines_st.find(x) with (x.get_addr() == cacheline_addr);
								if (foundq.size() != 1) 
								   `uvm_error("PRDCT_FNL_MSTRST", $psprintf("addr: 0x%0x was not loaded into ncore_cache_model?", cacheline_addr));
								
								foreach(foundq[0].m_cache_st_p_agent[i]) begin
									if ((i != cacheid) && (foundq[0].get_cache_state(i) == SD)) begin
										m_inflight_txns[idx].set_master_final_st(SC);
										break;
									end else if ((i != cacheid) && (foundq[0].get_cache_state(i) == SC)) begin
										m_inflight_txns[idx].set_master_final_st(SD);
									end
								end

								//CONC-6600
								//if snooper downgrades to IX and does not transfer ownership(DC=0) but transfers data(dt_aiu=1) possible for ACE snooper with UP=1
								//requestor gets the line in SC
								if (!owner_present) begin
									m_inflight_txns[idx].set_master_final_st(SC);
								end 
								if(str_cm_state == 'b010) begin		// Added this if there is a silent cache transition and directory didnot snooped the transitioned cache
										m_inflight_txns[idx].set_master_final_st(SD);
										do_not_update = 1;
									end 

							 end
				CMD_CLN_UNQ: begin
								foundq = m_cachelines_st.find(x) with (x.get_addr() == cacheline_addr);
								if (foundq.size() != 1) 
									`uvm_error("PRDCT_FNL_MSTRST", $psprintf("addr: 0x%0x was not loaded into ncore_cache_model?", cacheline_addr));

								//if exmon fail, master_final_state = master_initial_state
								if (m_inflight_txns[idx].m_es && !cmstatus_exokay_or_updreq_pass) begin
								   `uvm_info("PRDCT_FNL_MST_ST", $psprintf("Failed exclusive store - so master_final_state remains un-altered addr:0x%0h", cacheline_addr), UVM_LOW);
									m_inflight_txns[idx].set_master_final_st(foundq[0].get_cache_state(cacheid));
					 				//do nothing return;
								end else begin
									if (ncoreConfigInfo::get_native_interface(agentid) inside {ncoreConfigInfo::CHI_A_AIU, ncoreConfigInfo::CHI_B_AIU})
										possible_final_stq = {UD, UDP, UCE, UC}; 
									else 
										possible_final_stq = {UD, UC}; 
									id = $urandom_range(possible_final_stq.size() - 1);
									m_inflight_txns[idx].set_master_final_st(possible_final_stq[id]);
								end
							 end
				CMD_MK_UNQ:  begin
								m_inflight_txns[idx].set_master_final_st(UD);
							 end
				CMD_RD_UNQ : begin
                                if ($test$plusargs("SNPrsp_sharer_data_error_in_cmstatus") || $test$plusargs("SNPrsp_sharer_non_data_error_in_cmstatus") || $test$plusargs("requestor_in_UD")) begin
								  possible_final_stq = {UD}; //For directed test to achieve SD state
                                end else begin
								  possible_final_stq = {UD, UC};
                                end
								id = $urandom_range(possible_final_stq.size() - 1);
								m_inflight_txns[idx].set_master_final_st(possible_final_stq[id]);
							 end
				CMD_RD_NOT_SHD : begin
									foundq = m_cachelines_st.find(x) with (x.get_addr() == cacheline_addr);
									if (foundq.size() != 1) 
										`uvm_error("PRDCT_FNL_MSTRST", $psprintf("cmd:RdNotShDty addr: 0x%0h was not loaded into ncore_cache_model?", cacheline_addr));
									if (foundq[0].m_cache_st_p_agent[cacheid] == SD) begin
										`uvm_info("PRDCT_FNL_MSTRST", $psprintf("cmd:RdNotShDty addr: 0x%0h issued from SD state-check CMT_REQ, CMT_REQ==LKP_RSP", cacheline_addr), UVM_LOW);
									end

									if (foundq[0].m_cache_st_p_agent[cacheid] != SD) begin
										m_inflight_txns[idx].set_master_final_st(SC);
										if (owner_present == 1) begin //requestor upgrades to UC or UD
								  			possible_final_stq = {UD, UC};
								   	        id = $urandom_range(possible_final_stq.size() - 1);
									        m_inflight_txns[idx].set_master_final_st(possible_final_stq[id]);
										end
										foreach(foundq[0].m_cache_st_p_agent[i]) begin
											if ((i != cacheid) && (foundq[0].get_cache_state(i) inside {SD, SC})) begin
												m_inflight_txns[idx].set_master_final_st(SC);
												break;
											end
										end
									end else begin //requestor is in SD 
										if (owner_present != 1)
											`uvm_info("DCE_BFM", $psprintf("RdNotShdDirty from SD master should retain its ownership CMT_REQ=LKP_RSP"), UVM_LOW);
									    m_inflight_txns[idx].set_master_final_st(SD);
									end 
										
								end
				CMD_WR_BK_PTL, 
				CMD_WR_BK_FULL,
				CMD_WR_EVICT,
				CMD_CLN_INV
							: begin
								  m_inflight_txns[idx].set_master_final_st(IX);
							  end 
				//*********************************************************************
				// WrClnPtl -- 
				// can only be issued by CHI-A master. (For DCE:it means with TOF:1) 
				// master is in UDP or IX when it issues.
				//*********************************************************************
				CMD_WR_CLN_PTL : begin
							  	   foundq = m_cachelines_st.find(x) with (x.get_addr() == cacheline_addr);
								   if (foundq.size() != 1) 
								      `uvm_error("PRDCT_FNL_MSTRST", $psprintf("addr: 0x%0x was not loaded into ncore_cache_model?", cacheline_addr));

								   if (foundq[0].get_cache_state(cacheid) == UDP)
								       m_inflight_txns[idx].set_master_final_st(UCE);
								
							     end
				CMD_WR_CLN_FULL : begin
							  	   foundq = m_cachelines_st.find(x) with (x.get_addr() == cacheline_addr);
								   if (foundq.size() != 1) 
								      `uvm_error("PRDCT_FNL_MSTRST", $psprintf("addr: 0x%0x was not loaded into ncore_cache_model?", cacheline_addr));
									  
									case (foundq[0].get_cache_state(cacheid))
										UC, 
										UCE, 
										UD,
										UDP: m_inflight_txns[idx].set_master_final_st(UC);
										SC,
										SD:  m_inflight_txns[idx].set_master_final_st(SC);
									endcase

							     end
				CMD_WR_UNQ_FULL, 
				CMD_WR_UNQ_PTL:  begin 
									if (	ncoreConfigInfo::get_native_interface(agentid) == ncoreConfigInfo::ACE_AIU
										 && (m_inflight_txns[idx].m_awunique == 0)) begin
										foundq = m_cachelines_st.find(x) with (x.get_addr() == cacheline_addr);
										if (foundq.size() != 1) 
											`uvm_error("PRDCT_FNL_MSTRST", $psprintf("addr: 0x%0x was not loaded into ncore_cache_model?", cacheline_addr));
											  
										if (foundq[0].get_cache_state(cacheid) != IX)
											m_inflight_txns[idx].set_master_final_st(SC);
									end 
								end 
				CMD_CLN_VLD,
				CMD_CLN_SH_PER: begin
							  	   foundq = m_cachelines_st.find(x) with (x.get_addr() == cacheline_addr);
								   if (foundq.size() != 1) 
								      `uvm_error("PRDCT_FNL_MSTRST", $psprintf("addr: 0x%0x was not loaded into ncore_cache_model?", cacheline_addr));
									  
									case (foundq[0].get_cache_state(cacheid))
										UC, 
										UCE, 
										UD,
										UDP: m_inflight_txns[idx].set_master_final_st(UC);
										SC,
										SD:  m_inflight_txns[idx].set_master_final_st(SC);
									endcase

							     end

				CMD_LD_CCH_SH,
				CMD_LD_CCH_UNQ: begin
							  	   foundq = m_cachelines_st.find(x) with (x.get_addr() == cacheline_addr);
								   if (foundq.size() != 1) 
								      `uvm_error("PRDCT_FNL_MSTRST", $psprintf("addr: 0x%0x was not loaded into ncore_cache_model?", cacheline_addr));
								   //always clear the requestor state. 	
								   m_inflight_txns[idx].set_master_final_st(IX);
								end

			endcase 
			if($test$plusargs("en_silent_cache_st_transition") && req_state != IX && m_inflight_txns[idx].get_msg_type() inside {CMD_RD_VLD, CMD_RD_UNQ, CMD_RD_CLN, CMD_RD_NOT_SHD})
				m_inflight_txns[idx].set_master_final_st(req_state);

			updated = 1;
				
      		`uvm_info("MASTER_FINAL_ST", $psprintf("predict_master_final_state --> CMDreq:%0p master_final_st:%0p", m_inflight_txns[idx].get_msg_type(), m_inflight_txns[idx].get_master_final_st()), UVM_LOW);


			break;
		 
		 end //for CMD_REQs
      	 else begin //for UPD_REQs
			m_inflight_txns[idx].set_master_final_st(IX);
			updated = 1;
      	 end //for UPD_REQs
      end //if 
    end // foreach 

//    foreach(m_inflight_txns[0][j]) begin
//    	if (m_inflight_txns[0][j].is_msgid_inuse()) begin
//        	`uvm_info("INFLIGHT_TXNQ_AFTER", $psprintf("addr:%p, msg_type:%p msg_id:0x%0h final_st:%p", m_inflight_txns[0][j].get_addr(), m_inflight_txns[0][j].get_msg_type(), m_inflight_txns[0][j].get_msg_id(), m_inflight_txns[0][j].get_master_final_st), UVM_LOW);
//        end
//    end
    
	if (!updated) begin 
      `uvm_error("MASTER_FINAL_ST", $psprintf("Couldn't update master_final_st"));
    end 
 
    `uvm_info("DCE_CACHE_MODEL", "At STRreq completion: cache model contents: \n", UVM_LOW);
    //print_cache_model(1);
endfunction: predict_master_final_state


//static function void dce_container::predict_master_final_state(int agentid, int smi_msg_id, bit owner_present = 0);
static function void dce_container::invoke_silent_cache_state_transition(bit no_invalidation);
    int cacheline_idx, attempt;
    bit success = 0;
    int agent_idq[$];
    ncore_cache_state_t final_st;
    
    ncore_cache_state_t silent_transition[ncore_cache_state_t][$];

	silent_transition[UD]  = {SD, IX};
	silent_transition[UDP] = {UD, IX};
	silent_transition[UC]  = {UD, SC, IX};
	silent_transition[UCE] = {UD, UDP, IX};
	silent_transition[SC]  = {IX};

	if($test$plusargs("directed_wrclnptl_silent_seq")) begin
		silent_transition[UC] = {IX};
		silent_transition[UD] = {IX};
	end
   

    //`uvm_info("DCE CTR", $psprintf("fn: before invoke silent cache state transition"), UVM_LOW);
    //print_cache_model(1);

    attempt = 0;
    while (success == 0) begin
       cacheline_idx = $urandom_range(m_cachelines_st.size() - 1); 
	   foreach (m_cachelines_st[cacheline_idx].m_cache_st_p_agent[i]) begin
		agent_idq = ncoreConfigInfo::get_agent_ids_assoc2cacheid(i);
		   if (agent_idq.size() != 1)
				`uvm_error("DCE_CONTAINER", $psprintf("fn:get_agent_ids_assoc2cacheid Only one agentid should be associated to the cacheid. agent_idq.size:%0d", agent_idq.size()));
	   	   if (    !(m_cachelines_st[cacheline_idx].m_cache_st_p_agent[i] inside {IX, SD})
	   	   	    && !(m_cachelines_st[cacheline_idx].get_addr() inside {m_outstanding_addrq[agent_idq[0]]})) begin
	   	   	   silent_transition[m_cachelines_st[cacheline_idx].m_cache_st_p_agent[i]].shuffle();
	   	   	   if (no_invalidation && (silent_transition[m_cachelines_st[cacheline_idx].m_cache_st_p_agent[i]][0] == IX)) begin
			       //no sucess
			   end else begin
    			   print_cache_model(1, m_cachelines_st[cacheline_idx].get_addr());
			   	   m_cachelines_st[cacheline_idx].m_cache_st_p_agent[i] = silent_transition[m_cachelines_st[cacheline_idx].m_cache_st_p_agent[i]][0];
    			   print_cache_model(1, m_cachelines_st[cacheline_idx].get_addr());
			   	   success = 1;
			   	   final_st = m_cachelines_st[cacheline_idx].m_cache_st_p_agent[i];
			   	   break;
			   end 
		   end else begin 

		   end
	   end
	   attempt++;
	   if (attempt == 10000) begin
	   	   //`uvm_error("DCE CONTAINER", $psprintf(" Gave up after 200 attempts to make a silent cache state transition"));
	   	   break;
	   end
	end 

    `uvm_info("DCE CTR", $psprintf("fn: after invoke silent cache state transition attempt:%0d success:%0d final_st:%0s", attempt, success, final_st), UVM_LOW);

endfunction: invoke_silent_cache_state_transition

//--------------------------------------------------------
//  DCE Cache State Model
//--------------------------------------------------------

class ncore_cache_model extends uvm_object;
  `uvm_object_utils(ncore_cache_model)

  //Properites
  local addr_width_t        m_addr;
  <% if(obj.testBench == 'dce') { %>
  `ifndef VCS
  local ncore_cache_state_t m_cache_st_p_agent[];
  `else // `ifndef VCS
   ncore_cache_state_t m_cache_st_p_agent[];
  `endif // `ifndef VCS ... `else ... 
  <% } else {%>
  local ncore_cache_state_t m_cache_st_p_agent[];
  <% } %>

  //Properties
  extern function new(string name = "ncore_cache_model");

  extern function void set_addr(addr_width_t addr);
  extern function addr_width_t get_addr();
  
  extern function void set_cache_state(int cacheid, ncore_cache_state_t st);
  extern function void set_cache_state_all_agents(ncore_cache_state_t st);
  extern function ncore_cache_state_t get_cache_state(int cacheid);
  //extern function void print_contents();
endclass: ncore_cache_model

//*********************************************
function ncore_cache_model::new(string name = "ncore_cache_model");
  super.new(name);
  m_cache_st_p_agent = new[ncoreConfigInfo::NUM_CACHES];
endfunction: new

//*********************************************
function void ncore_cache_model::set_addr(addr_width_t addr);
  m_addr = addr;
endfunction: set_addr

//*********************************************
function addr_width_t ncore_cache_model::get_addr();
  return m_addr;
endfunction: get_addr

//*********************************************
function void ncore_cache_model::set_cache_state(int cacheid, ncore_cache_state_t st);

  if (cacheid < m_cache_st_p_agent.size()) begin
  	  m_cache_st_p_agent[cacheid] = st;
  end else begin
      `uvm_error("DCE_CACHE_MODEL_ERROR", $psprintf("set_cache_st:cache_id:%0d is not within m_cache_st_p_agent.size():%0d", cacheid, m_cache_st_p_agent.size()))
  end

endfunction: set_cache_state

//*********************************************
function void ncore_cache_model::set_cache_state_all_agents(ncore_cache_state_t st);

  foreach(m_cache_st_p_agent[i]) begin
  		m_cache_st_p_agent[i] = st;
  end
endfunction: set_cache_state_all_agents


//*********************************************
function ncore_cache_state_t ncore_cache_model::get_cache_state(int cacheid);
   
  if (cacheid < m_cache_st_p_agent.size()) begin
  	  return m_cache_st_p_agent[cacheid];
  end else begin 
      `uvm_error("DCE_CACHE_MODEL_ERROR", $psprintf("get_cache_st:cache_id:%0d is not within m_cache_st_p_agent.size():%0d", cacheid, m_cache_st_p_agent.size()))
  end

endfunction: get_cache_state

//-----------------------------------------------
//DCE Inflight Transactions class 
//  m_msg_id is provided via constructor and
//  remains constant for entire simulation
//-----------------------------------------------

class dce_inflight_txns;

  //Properties
  local time 				 m_time;
  local int                  m_msg_id;
  local int                  m_att_id; //needed to link strreq-strrsp
  local int                  m_rb_id; //needed to link strreq-strrsp
  local eMsgCMD      		 m_msg_type;
  local bit          		 m_msgid_inuse;
  bit 					     m_es;
  bit 					     m_awunique;
  bit               		 m_cmd_n_upd_req;
  local addr_width_t         m_addr;
  local ncore_cache_state_t  m_master_final_st;
  local int                  m_master_id;
  local int                  m_dmi_id;
  local int                  m_dce_id;
  local bit                  m_cmdrsp_rcvd;
  local bit                  m_snpreq_rcvd;
  local bit                  m_mrdreq_rcvd;
  local bit                  m_strreq_rcvd;
  local bit                  m_updrsp_rcvd;
  local bit                  m_rb_usd_rcvd;
  local bit                  m_rb_rls_rcvd;
  local bit                  m_rb_rsv_rcvd;

  //Methods
  extern function new(time t, int msg_id, int master_id, bit cmd_n_upd_req, eMsgCMD msg_type, addr_width_t addr, bit es, int dce_id, bit awunique);
  extern function int get_msg_id();
  extern function int get_master_id();
  extern function bit is_msgid_inuse();
  extern function void reset_txn();

  extern function void set_req_attributes(eMsgCMD msg_type, addr_width_t addr, int dce_id);
  extern function void set_master_final_st(ncore_cache_state_t st);
  extern function bit snpreq_maps_to_cmdreq(eMsgSNP snptype);

  extern function eMsgCMD get_msg_type();
  extern function addr_width_t get_addr();
  extern function int get_att_id();
  extern function int get_rb_id();
  extern function ncore_cache_state_t get_master_final_st();

  extern function void set_cmdrsp_rcvd();
  extern function bit  get_cmdrsp_flag();

  extern function void set_snpreq_rcvd(int att_id, int rb_id);
  extern function bit  get_snpreq_flag();

  extern function void set_mrdreq_rcvd(int att_id, dmi_id);
  extern function bit  get_mrdreq_flag();

  extern function void set_strreq_rcvd(int att_id, int rb_id);
  extern function bit  get_strreq_flag();

  extern function void set_updrsp_rcvd();
  extern function bit  get_updrsp_flag();
  
  extern function void set_rb_rsv_rcvd(int rb_id, int dmi_id);
  extern function bit  get_rb_rsv_flag();

  extern function void set_rb_usd_rcvd();
  extern function bit  get_rb_usd_flag();

  extern function void set_rb_rls_rcvd();
  extern function bit  get_rb_rls_flag();

  extern function string convert2string();
endclass: dce_inflight_txns

//*****************************************
function dce_inflight_txns::new(time t, int msg_id, int master_id, bit cmd_n_upd_req, eMsgCMD msg_type, addr_width_t addr, bit es, int dce_id, bit awunique);
  m_msgid_inuse = 1;
  m_time = t;
  m_msg_id    = msg_id;
  m_master_id = master_id;
  m_cmd_n_upd_req = cmd_n_upd_req;
  m_msg_type  = msg_type;
  m_addr      = addr;
  m_dce_id    = dce_id;
  m_att_id    = 0;
  m_rb_id     = 0;
  m_es        = es;
  m_awunique  = awunique;
  //reset_txn();
endfunction: new

//*****************************************
function int dce_inflight_txns::get_att_id();
	return m_att_id;
endfunction: get_att_id

//*****************************************
function int dce_inflight_txns::get_rb_id();
	return m_rb_id;
endfunction: get_rb_id

//*****************************************
function int dce_inflight_txns::get_msg_id();
  return m_msg_id;
endfunction: get_msg_id

//*****************************************
function int dce_inflight_txns::get_master_id();
  return m_master_id;
endfunction: get_master_id

//*****************************************
function bit dce_inflight_txns::is_msgid_inuse();
  return m_msgid_inuse;
endfunction: is_msgid_inuse

//*****************************************
function addr_width_t dce_inflight_txns::get_addr();
  return m_addr;
endfunction: get_addr

//*****************************************
function void dce_inflight_txns::set_master_final_st(ncore_cache_state_t st);
  m_master_final_st = st;
endfunction: set_master_final_st

//*****************************************
function ncore_cache_state_t dce_inflight_txns::get_master_final_st();
  return m_master_final_st;
endfunction: get_master_final_st

//*****************************************
function void dce_inflight_txns::reset_txn();
  m_msgid_inuse = 0; 
//  m_msg_type    = eCmdRdCln;
//  m_addr        = 0;
//  m_cmdrsp_rcvd = 0; 
//  m_snpreq_rcvd = 0; 
//  m_mrdreq_rcvd = 0; 
//  m_strreq_rcvd = 0; 
endfunction: reset_txn

//*****************************************
function void dce_inflight_txns::set_req_attributes(eMsgCMD msg_type, addr_width_t addr, int dce_id);
  m_msg_type    = msg_type;
  m_addr        = addr;
  m_dce_id      = dce_id;
  m_msgid_inuse = 1;
endfunction: set_req_attributes

//*****************************************
function eMsgCMD dce_inflight_txns::get_msg_type();
  return m_msg_type;
endfunction: get_msg_type

//*****************************************
function void dce_inflight_txns::set_cmdrsp_rcvd();
  `ASSERT(m_msgid_inuse);
  m_cmdrsp_rcvd = 1;
endfunction: set_cmdrsp_rcvd

//*****************************************
function bit  dce_inflight_txns::get_cmdrsp_flag();
  return m_cmdrsp_rcvd;
endfunction: get_cmdrsp_flag

//*****************************************
function void dce_inflight_txns::set_snpreq_rcvd(int att_id, int rb_id);
  `ASSERT(m_msgid_inuse);
  m_snpreq_rcvd = 1;
  m_att_id      = att_id;
  m_rb_id       = rb_id;
endfunction: set_snpreq_rcvd

//*****************************************
function bit  dce_inflight_txns::get_snpreq_flag();
  return m_snpreq_rcvd;
endfunction: get_snpreq_flag

//*****************************************
function void dce_inflight_txns::set_mrdreq_rcvd(int att_id, int dmi_id);
  `ASSERT(m_msgid_inuse);
  m_mrdreq_rcvd = 1;
  m_att_id      = att_id;
  m_dmi_id      = dmi_id;
endfunction: set_mrdreq_rcvd

//*****************************************
function bit  dce_inflight_txns::get_mrdreq_flag();
 return  m_mrdreq_rcvd;
endfunction: get_mrdreq_flag

//*****************************************
function void dce_inflight_txns::set_strreq_rcvd(int att_id, int rb_id);
  `ASSERT(m_msgid_inuse);
  m_strreq_rcvd = 1;
  m_att_id      = att_id;
  m_rb_id       = rb_id;
endfunction: set_strreq_rcvd

//*****************************************
function void dce_inflight_txns::set_updrsp_rcvd();
  `ASSERT(m_msgid_inuse);
  m_updrsp_rcvd = 1;
endfunction: set_updrsp_rcvd

//*****************************************
function bit  dce_inflight_txns::get_strreq_flag();
  return m_strreq_rcvd;
endfunction: get_strreq_flag

//*****************************************
function bit  dce_inflight_txns::get_updrsp_flag();
  return m_updrsp_rcvd;
endfunction: get_updrsp_flag

//*****************************************
function void dce_inflight_txns::set_rb_rsv_rcvd(int rb_id, int dmi_id);
  `ASSERT(m_msgid_inuse);
  m_rb_rsv_rcvd = 1;
  m_rb_id       = rb_id; 
  m_dmi_id      = dmi_id;
endfunction: set_rb_rsv_rcvd

//*****************************************
function bit  dce_inflight_txns::get_rb_rsv_flag();
   return m_rb_rsv_rcvd;
endfunction: get_rb_rsv_flag

//*****************************************
function void dce_inflight_txns::set_rb_usd_rcvd();
  m_rb_usd_rcvd = 1;
endfunction: set_rb_usd_rcvd

//*****************************************
function bit  dce_inflight_txns::get_rb_usd_flag();
  return m_rb_usd_rcvd;
endfunction: get_rb_usd_flag

//*****************************************
function void dce_inflight_txns::set_rb_rls_rcvd();
  `ASSERT(m_msgid_inuse);
  m_rb_rls_rcvd = 1;
endfunction: set_rb_rls_rcvd

//*****************************************
function bit  dce_inflight_txns::get_rb_rls_flag();
  return m_rb_rls_rcvd;
endfunction: get_rb_rls_flag

//*****************************************
function bit dce_inflight_txns::snpreq_maps_to_cmdreq(eMsgSNP snptype);
	eMsgCMD cmdtypeq[$];
	bit maps = 0;

	case(snptype)
		eSnpClnDtr : cmdtypeq = {eCmdRdCln}; 	
		eSnpVldDtr : cmdtypeq = {eCmdRdVld}; 	
		eSnpInvDtr : cmdtypeq = {eCmdRdUnq};
		eSnpNoSDInt: cmdtypeq = {eCmdRdNShD};
		eSnpNITC   : cmdtypeq = {eCmdRdNITC};
		eSnpNITCCI : cmdtypeq = {eCmdRdNITCClnInv};
		eSnpNITCMI : cmdtypeq = {eCmdRdNITCMkInv};

		eSnpClnDtw : cmdtypeq = {eCmdClnVld, 
								 eCmdClnShdPer};
		eSnpInv    : cmdtypeq = {eCmdWrUnqFull, 
								 eCmdMkUnq,
								 eCmdMkInv};

		eSnpInvDtw : cmdtypeq = {eCmdWrUnqPtl, 
								 eCmdClnInv, 
								 eCmdClnUnq, 
								 eCmdRdAtm, 
								 eCmdWrAtm, 
								 eCmdSwAtm, 
								 eCmdCompAtm};
	    eSnpStshShd : cmdtypeq = {eCmdLdCchShd};
	    eSnpStshUnq : cmdtypeq = {eCmdLdCchUnq};
	    eSnpInvStsh : cmdtypeq = {eCmdWrStshFull};
	    eSnpUnqStsh : cmdtypeq = {eCmdWrStshPtl};
	endcase

	if (m_msg_type inside {cmdtypeq})
		maps = 1;

	return maps;
endfunction: snpreq_maps_to_cmdreq

//*****************************************
function string dce_inflight_txns::convert2string();
    string s;

    $sformat(s, "%0s %t msgid_in_use:%b, msg_id:0x%0h master_id:0x%0h cmd_n_upd_req:%0d cmd_type:%p addr:0x%0h att_id:0x%0h rb_id:0x%0h rb_rsv:%0b rb_rls:%0b rb_usd: %0b\n",
             s,
             m_time,
             m_msgid_inuse,
             m_msg_id,
             m_master_id,
             m_cmd_n_upd_req,
             m_msg_type,
             m_addr,
             m_att_id,
             m_rb_id,
             get_rb_rsv_flag(),
             get_rb_rls_flag(),
             get_rb_usd_flag()
             );

    return (s);
endfunction
