<%
var num_procs = 0;

obj.AiuInfo.forEach(function(bundle) {
    if (bundle.nProcs > num_procs) {
        num_procs = bundle.nProcs;
    }
});
%>

parameter MAX_NUM_PROCS_PER_AIU = <%=num_procs%>;

//DCE SMI Master Base Sequence
//
//Author: 

class dce_mst_base_seq extends uvm_sequence#(smi_seq_item);

  `uvm_object_utils(dce_mst_base_seq)

  //Properties
  uvm_phase         m_phase;
  dce_container     m_dce_cntr;
  addr_trans_mgr    m_addr_mgr;
  credit_maint_pool m_credit_pool;
  dce_unit_args     m_unit_args;

  smi_sequencer  m_smi_tx_port;
  smi_sequencer  m_smi_rx_port;
  dce_scb        m_scb;
  int            m_cmds_issued;
  int        sys_rsps_recieved;
  event          e_single_step;
  event          e_scrub_routine;
  bit            m_stop_cmd_issue;
  uvm_event_pool ev_pool = uvm_event_pool::get_global_pool();
  uvm_event ev_last_cmdreq_issued = ev_pool.get("ev_last_cmdreq_issued");
  uvm_event ev_last_scb_txn = ev_pool.get("ev_last_scb_txn");
  uvm_event ev_first_scb_txn = ev_pool.get("ev_first_scb_txn");

  //Local flags
  bit m_handles_fwded;  
  bit m_seqrs_fwded;
  int m_connected_agentq[$];
  int m_ch_agentq[$];
  int m_nc_agentq[$];
  int m_wr_stash_masterq[$];
  int m_stash_targetq[$];
  int m_chib_agentq[$];
  int m_chia_agentq[$];
  int m_ace_agentq[$];
  int m_proxy_cache_agentq[$];
  int m_wrclnptl_masterq[$];
  int m_exc_masterq[$];
  int count_unq_addr = 0;
  int count_unq_upd_addr = 0;
  int attached_agent_queue[$];
  int total_rsps_expected; 
  bit stop_attach_detach_flag = 0;
  int update_agentq[$]; 
  
  //masterq for update reqs
  int m_updreq_masterq[$];
  int m_cmdupdreqs_issued;
  int credits_pend;
  int m_agentid;

  bit [WSMIMSGID-1:0] msg_id;
  int signed_msg_id; 
  eMsgCMD      cmd_type; 
  addr_width_t bit_mask_const = 'h1_FFFF_FFFF_FFFF << addrMgrConst::WCACHE_OFFSET;
  addr_width_t cacheline_addr;
  
  //Randomize fields modified every time when randomize method is invoked
  rand bit                     r_pk_ch_agent;
  rand int                     r_aiu_funitid;
  rand bit [1:0]               r_stash_tgt_type;
  rand smi_seq_item            r_cmdupd_item;
  addrMgrConst::addrq          user_addrq;
  int                          sf_setaddr;
  int                          addr_pool_size;
  int                          sysreq_inflight[$];

  //Semaphore for attach-detach sync
  semaphore attach_detach_s[addrMgrConst::NUM_AIUS];

  //Methods
  extern function new(string name = "dce_mst_base_seq");
  extern function void get_handles(ref uvm_phase phase, ref dce_container container, ref dce_unit_args unit_args);
  extern function void get_seqrs(const ref smi_sequencer tx_port, const ref smi_sequencer rx_port);
  extern task invoke_scrub_routine();

  //Internal methods
  extern task send_cmdreq_txns();
  extern task send_updreq_txns();
  extern task send_sysreq_txns();
  extern task receive_cmdupdrsp_txns(int num_scrub_routine_txns = -1, int num_directed_test_txns = -1);
  extern task send_directed_cmdreq_txn(int requestor_aiu_funitid_i, addr_width_t addr_i, eMsgCMD cmd_type_i, int delay_value = -1);
  extern task send_directed_updreq_txn(int requestor_aiu_funitid_i, addr_width_t addr_i, int delay_value= -1);
  extern task populate_unique_addrq(); //had to change to task to introduce delay.
  extern task update_cache_model_updreq();
  extern task send_sysreq_attach(int agent_id = -1);
  extern task send_sysreq_detach(int agent_id = -1);

  //Internal helper methods
  extern function bit  is_cachable_agent(int id);

  //invoked before smi_seq_item is constructed 
  extern function void populate_available_agentsq();
  extern function void assign_cmdmsg_fields(input bit [WSMIMSGID-1:0] msg_id, input addr_width_t addr, ref smi_seq_item seq_item);
  extern function bit  is_master_in_legal_state(input int agentid, input addr_width_t addr);
  extern task wait_for_sysrsp();

 extern function bit  pick_addr_given_state(input ncore_cache_state_t stq[$], output addr_width_t addr, output int agentid);

  constraint c_pk_ch_agent {
    if (m_ch_agentq.size()) {
      r_pk_ch_agent dist {
        1 := m_unit_args.k_pck_ch_agent_pct.get_value(),
        0 := 100 - m_unit_args.k_pck_ch_agent_pct.get_value()
      };
    } else {
      r_pk_ch_agent == 0;
    }
  }

  //#Cover.DCE.CmdReq.SrcId
  //#Cover.DCE.UpdReq.SrcId
  constraint c_agentid {
    if (r_pk_ch_agent) 
      r_aiu_funitid inside {m_ch_agentq};
    else 
      r_aiu_funitid inside {m_nc_agentq};
    solve r_pk_ch_agent before r_aiu_funitid;
  }

  constraint c_concerto_msg {
    r_cmdupd_item.smi_msg_type dist {
      //reads
      eCmdRdCln         := m_unit_args.k_cmd_rd_cln_pct.get_value(),
      eCmdRdNShD        := m_unit_args.k_cmd_rd_not_shd_pct.get_value(),
      eCmdRdVld         := m_unit_args.k_cmd_rd_vld_pct.get_value(),
      eCmdRdUnq         := m_unit_args.k_cmd_rd_unq_pct.get_value(),
      eCmdRdNITC        := m_unit_args.k_cmd_rd_nitc_pct.get_value(),
      eCmdRdNITCClnInv  := m_unit_args.k_cmd_rd_nitc_clninv_pct.get_value(),
      eCmdRdNITCMkInv   := m_unit_args.k_cmd_rd_nitc_mkinv_pct.get_value(),

      //nonstash writes
      eCmdWrUnqPtl       := m_unit_args.k_cmd_wr_unq_ptl_pct.get_value(),
      eCmdWrUnqFull      := m_unit_args.k_cmd_wr_unq_full_pct.get_value(),
      eCmdWrClnPtl       := m_unit_args.k_cmd_wr_cln_ptl_pct.get_value(),
      eCmdWrClnFull      := m_unit_args.k_cmd_wr_cln_full_pct.get_value(),
      eCmdWrBkPtl        := m_unit_args.k_cmd_wr_bk_ptl_pct.get_value(),
      eCmdWrBkFull       := m_unit_args.k_cmd_wr_bk_full_pct.get_value(),
      eCmdWrEvict        := m_unit_args.k_cmd_wr_evct_pct.get_value(),

      //dataless
      eCmdEvict          := m_unit_args.k_cmd_evct_pct.get_value(),
      
      //atomics
      eCmdWrAtm          := m_unit_args.k_cmd_wr_atm_pct.get_value(),
      eCmdRdAtm          := m_unit_args.k_cmd_rd_atm_pct.get_value(),
      eCmdSwAtm          := m_unit_args.k_cmd_swp_atm_pct.get_value(),
      eCmdCompAtm        := m_unit_args.k_cmd_cmp_atm_pct.get_value(),

      //stash writes 
      eCmdWrStshPtl  := m_unit_args.k_cmd_wr_stsh_ptl_pct.get_value(),
      eCmdWrStshFull := m_unit_args.k_cmd_wr_stsh_full_pct.get_value(),
     
      //cleaning cmds
      eCmdClnUnq    := m_unit_args.k_cmd_cln_unq_pct.get_value(),
      eCmdClnVld    := m_unit_args.k_cmd_cln_vld_pct.get_value(),
      eCmdClnShdPer := m_unit_args.k_cmd_cln_shd_per_pct.get_value(),
      eCmdClnInv    := m_unit_args.k_cmd_cln_inv_pct.get_value(),

      //make cmds
      eCmdMkUnq     := m_unit_args.k_cmd_mk_unq_pct.get_value(),
      eCmdMkInv     := m_unit_args.k_cmd_mk_inv_pct.get_value(),
     
      //stashing reads 
      eCmdLdCchShd  := m_unit_args.k_cmd_ldcch_shd_pct.get_value(),
      eCmdLdCchUnq  := m_unit_args.k_cmd_ldcch_unq_pct.get_value()

    };
     
      (r_pk_ch_agent == 0) -> !(r_cmdupd_item.smi_msg_type inside {eCmdRdVld, 
                                                                   eCmdRdCln, 
                                                                   eCmdRdNShD, 
                                                                   eCmdRdUnq, 
                                                                   eCmdClnUnq, 
                                                                   eCmdMkUnq, 
                                                                   eCmdWrClnPtl, 
                                                                   eCmdWrClnFull, 
                                                                   eCmdWrBkPtl, 
                                                                   eCmdWrBkFull, 
                                                                   eCmdWrEvict,
                                                                   eCmdEvict});
    r_cmdupd_item.smi_msg_type inside {eCmdRdCln, eCmdRdNShD, eCmdRdVld, eCmdRdUnq, eCmdRdNITC, eCmdRdNITCClnInv, eCmdRdNITCMkInv, eCmdWrUnqPtl, eCmdWrUnqFull, eCmdWrClnPtl, eCmdWrClnFull, eCmdWrBkPtl, eCmdWrBkFull, eCmdWrEvict, eCmdEvict, eCmdWrAtm, eCmdRdAtm, eCmdSwAtm, eCmdCompAtm, eCmdWrStshPtl, eCmdWrStshFull, eCmdClnUnq, eCmdClnVld, eCmdClnShdPer, eCmdClnInv, eCmdMkUnq, eCmdMkInv, eCmdLdCchShd, eCmdLdCchUnq};

      solve r_pk_ch_agent before r_cmdupd_item.smi_msg_type;
  }


  //#Stimulus.DCE.CmdReq.Mpf1_awunq
  constraint c_awunique {
      if ((r_cmdupd_item.smi_msg_type inside {eCmdWrUnqFull, eCmdWrUnqPtl}) && (r_aiu_funitid inside {m_ace_agentq})) {
         r_cmdupd_item.smi_mpf1_awunique dist {
            1 := m_unit_args.k_awunique_pct.get_value(),
            0 := 100 - m_unit_args.k_awunique_pct.get_value()
         };
      }
  }

  //#Stimulus.DCE.CmdReq.Pri
  constraint c_qos_priority {
    r_cmdupd_item.smi_msg_pri == addrMgrConst::qos_mapping(r_cmdupd_item.smi_qos);
  }
  
  //#Stimulus.DCE.CmdReq.Size
  constraint c_smi_size {
    r_cmdupd_item.smi_size != 7; //3'b111 is reserved
  }

  constraint c_es {
     if (r_cmdupd_item.smi_msg_type inside {eCmdRdVld, eCmdRdCln, eCmdRdNShD, eCmdClnUnq}) {
         r_cmdupd_item.smi_es dist {
            1 := m_unit_args.k_exc_pct.get_value(),
            0 := 100 - m_unit_args.k_exc_pct.get_value()
         };
     } else if (r_cmdupd_item.smi_msg_type inside {eCmdRdAtm, eCmdWrAtm, eCmdSwAtm, eCmdCompAtm}) {
         r_cmdupd_item.smi_es dist {
            1 := 50,
            0 := 50
         };
     } else {
         r_cmdupd_item.smi_es == 0;
     }
     if ((r_cmdupd_item.smi_msg_type inside {eCmdRdVld, eCmdRdCln, eCmdRdNShD, eCmdClnUnq}) && (r_cmdupd_item.smi_es == 1)) {
        r_aiu_funitid inside {m_exc_masterq};
     }
     solve r_cmdupd_item.smi_msg_type before r_cmdupd_item.smi_es;
     solve r_cmdupd_item.smi_es       before r_aiu_funitid;
  }

   //#Stimulus.DCE.CmdReq.Mpf2
   constraint c_excops_mpf2_params {
    (r_cmdupd_item.smi_msg_type inside {eCmdRdVld, eCmdRdCln, eCmdRdNShD, eCmdClnUnq} && r_cmdupd_item.smi_es == 1) -> (r_cmdupd_item.smi_mpf2_flowid_valid == 1);
    (r_cmdupd_item.smi_msg_type inside {eCmdRdVld, eCmdRdCln, eCmdRdNShD, eCmdClnUnq} && r_cmdupd_item.smi_es == 1) -> (r_cmdupd_item.smi_mpf2_flowid < MAX_NUM_PROCS_PER_AIU);
     solve r_cmdupd_item.smi_es before r_cmdupd_item.smi_mpf2_flowid_valid;
     solve r_cmdupd_item.smi_es before r_cmdupd_item.smi_mpf2_flowid;
   }

   //#Stimulus.DCE.CmdReq.Tof
   constraint c_tof {
     if (addrMgrConst::get_native_interface(addrMgrConst::agentid_assoc2funitid(r_aiu_funitid)) inside {addrMgrConst::CHI_A_AIU, addrMgrConst::CHI_B_AIU}) {
        r_cmdupd_item.smi_tof == SMI_TOF_CHI; //CHI ordering model
     } else if (addrMgrConst::get_native_interface(addrMgrConst::agentid_assoc2funitid(r_aiu_funitid)) inside {addrMgrConst::ACE_AIU, addrMgrConst::ACE_LITE_AIU, addrMgrConst::ACE_LITE_AIU, addrMgrConst::ACE_LITE_E_AIU}) {
        r_cmdupd_item.smi_tof == SMI_TOF_ACE; //ACE ordering model
     } else if (addrMgrConst::get_native_interface(addrMgrConst::agentid_assoc2funitid(r_aiu_funitid)) inside {addrMgrConst::AXI_AIU, addrMgrConst::IO_CACHE_AIU}) {
        r_cmdupd_item.smi_tof == SMI_TOF_AXI; //AXI ordering model
     }
   }

   constraint c_msgtype_funitid {
     (r_cmdupd_item.smi_msg_type inside {eCmdWrClnFull}) -> (r_aiu_funitid inside {m_chib_agentq});
     (r_cmdupd_item.smi_msg_type inside {eCmdWrClnPtl}) -> (r_aiu_funitid inside {m_chia_agentq});
     (r_cmdupd_item.smi_msg_type inside {eCmdWrStshPtl, eCmdWrStshFull}) -> (r_aiu_funitid inside {m_wr_stash_masterq});
     (r_cmdupd_item.smi_msg_type inside {eCmdLdCchShd, eCmdLdCchUnq}) -> ((r_aiu_funitid inside {m_wr_stash_masterq}) || (r_aiu_funitid inside {m_chib_agentq}));
     (r_cmdupd_item.smi_msg_type inside {eCmdRdNITCClnInv, eCmdRdNITCMkInv}) -> !(r_aiu_funitid inside {m_ace_agentq}) && !(r_aiu_funitid inside {m_proxy_cache_agentq});
     //CCMP spec v 0.90 Section 9.4.1 AXI I/O AIU Tables
     //#Stimulus.DCE.proxyCache_CmdRedType
     !(r_cmdupd_item.smi_msg_type inside {eCmdRdNITC, eCmdRdVld, eCmdRdUnq, eCmdMkUnq, eCmdWrUnqPtl, eCmdWrUnqFull,eUpdInv}) -> !(r_aiu_funitid inside {m_proxy_cache_agentq});
     solve r_cmdupd_item.smi_msg_type before r_aiu_funitid;
  }

  //#Stimulus.DCE.CmdReq.Mpf1
  constraint c_stashing {
    if (r_cmdupd_item.smi_msg_type inside {eCmdWrStshPtl, eCmdWrStshFull, eCmdLdCchShd, eCmdLdCchUnq}) {
        r_cmdupd_item.smi_mpf1_stash_valid dist {1 := 95, 0 := 5};
        r_stash_tgt_type dist {0 := 94, 1 := 3, 2 := 3, 3 := 0};
        (r_stash_tgt_type == 0) -> r_cmdupd_item.smi_mpf1_stash_nid inside {m_stash_targetq};
        (r_stash_tgt_type == 1) -> (r_cmdupd_item.smi_mpf1_stash_nid inside {m_ch_agentq}) && !(r_cmdupd_item.smi_mpf1_stash_nid inside {m_stash_targetq});
        (r_stash_tgt_type == 2) -> (r_cmdupd_item.smi_mpf1_stash_nid inside {m_nc_agentq});
        (r_cmdupd_item.smi_mpf1_stash_valid == 1) -> r_cmdupd_item.smi_mpf1_stash_nid != r_aiu_funitid;
    }
   solve r_cmdupd_item.smi_msg_type before r_cmdupd_item.smi_mpf1_stash_valid;
   solve r_cmdupd_item.smi_msg_type before r_cmdupd_item.smi_mpf1_stash_nid;
   solve r_aiu_funitid before r_cmdupd_item.smi_mpf1_stash_nid;
  }

endclass: dce_mst_base_seq

//*************************************************
function dce_mst_base_seq::new(string name = "dce_mst_base_seq");
  super.new(name);

  m_credit_pool = credit_maint_pool::GetInstance();
  m_addr_mgr    = addr_trans_mgr::get_instance();
  r_cmdupd_item    = new();
  m_cmdupdreqs_issued = 0;


  for (int i = 0; i < <%=obj.DceInfo[obj.Id].hexDceConnectedCaFunitId.length%>; ++i) begin
    m_connected_agentq.push_back(CONNECTED_CACHING_FUNIT_IDS[i]);
  end
  
  for (int i = 0; i < addrMgrConst::NUM_AIUS; ++i) begin
    //initialize attach-detach semaphore for each aiu
    attach_detach_s[addrMgrConst::get_aiu_funitid(i)] = new(1);
    //populate masterq for update reqs
    if ( addrMgrConst::get_native_interface(i) == addrMgrConst::ACE_AIU ||
         addrMgrConst::get_native_interface(i) == addrMgrConst::CHI_A_AIU ||
         addrMgrConst::get_native_interface(i) == addrMgrConst::CHI_B_AIU ||
         addrMgrConst::get_native_interface(i) == addrMgrConst::IO_CACHE_AIU) begin
        m_updreq_masterq.push_back(addrMgrConst::get_aiu_funitid(i));
        m_ch_agentq.push_back(addrMgrConst::get_aiu_funitid(i));
        if ($test$plusargs("single_cacheable_master") && (m_ch_agentq.size() == 1)) begin
            break;
        end
    end
  end
  
endfunction: new

//*************************************************
function void dce_mst_base_seq::get_handles(ref uvm_phase phase, ref dce_container container, ref dce_unit_args unit_args);

  m_phase     = phase;
  m_dce_cntr  = container;
  m_unit_args = unit_args;
  m_handles_fwded = 1;
endfunction: get_handles

//************************************************
function void dce_mst_base_seq::get_seqrs(const ref smi_sequencer tx_port, const ref smi_sequencer rx_port);

  m_smi_tx_port = tx_port;
  m_smi_rx_port = rx_port;
  m_seqrs_fwded = 1;
endfunction: get_seqrs

task dce_mst_base_seq::send_updreq_txns();
    smi_seq      updreq_seq;
    smi_seq_item updreq_seq_item;
    int          delay;
    bit [WSMINCOREUNITID-1:0] targ_id;
    ncore_cache_state_t st[$];
    bit [WSMIQOS-1:0] random_smi_qos;
    int indxq[$];
    int count = 0;
    int try = 0;

    for (int i = 1; i <= m_unit_args.k_num_upd_cmds.get_value(); ++i) begin
        int agentid, aiu_funitid, idx;
        int itr = 0;
        addr_width_t addr;
        addr_width_t addrq[$];
        m_updreq_masterq.delete();
        
        m_phase.raise_objection(m_smi_tx_port, $psprintf("updreq_txnid_%0d", i));

        updreq_seq       = smi_seq::type_id::create("smi_sequence");
        updreq_seq_item  = smi_seq_item::type_id::create("smi_seq_item");

        if (!$test$plusargs("k_slow_smi1_rx_port")) begin
        //1. insert some random delay
        delay = $urandom_range(100, 1);
        #(<%=obj.Clocks[0].params.period%>ps * delay); //wait for random cycles
        end

        //Fix SANJEEV: CONC-15401, populate the eligible list of masters after the delay due to the use of knob k_slow_smi1_rx_port in above condition
    	for (int i = 0; i < addrMgrConst::NUM_AIUS; ++i)
        begin
    	  if ( (addrMgrConst::get_native_interface(i) == addrMgrConst::ACE_AIU) ||
    	       (addrMgrConst::get_native_interface(i) == addrMgrConst::CHI_A_AIU) ||
    	       (addrMgrConst::get_native_interface(i) == addrMgrConst::CHI_B_AIU) ||
    	       (addrMgrConst::get_native_interface(i) == addrMgrConst::IO_CACHE_AIU)
             )
          begin
    	    indxq = attached_agent_queue.find_index(x) with (x == i);
    	    if(indxq.size() != 0 && !(i inside {sysreq_inflight}))
	    begin
    	        m_updreq_masterq.push_back(addrMgrConst::get_aiu_funitid(i));
    	    end
    	  end
    	end

        while(m_updreq_masterq.size() == 0) begin
            #(<%=obj.Clocks[0].params.period%>ps * 20);
            if(count != 1000) //Adding this to avoid going over 1000
                count++;
            if(count == 1000) begin // Adding this to finish expected upds
                if(attached_agent_queue.size() == 0 && sysreq_inflight.size() == 0) begin
                    send_sysreq_attach(CACHING_AIU_FUNIT_IDS[$urandom_range(<%=obj.DceInfo[0].nCachingAgents%>-1,0)]);
                    count = 0;
                end
            end
            for (int i = 0; i < addrMgrConst::NUM_AIUS; ++i) begin
                if ( addrMgrConst::get_native_interface(i) == addrMgrConst::ACE_AIU ||
                addrMgrConst::get_native_interface(i) == addrMgrConst::CHI_A_AIU ||
                addrMgrConst::get_native_interface(i) == addrMgrConst::CHI_B_AIU ||
                addrMgrConst::get_native_interface(i) == addrMgrConst::IO_CACHE_AIU) begin
                    indxq = attached_agent_queue.find_index(x) with (x == i);
                    if(indxq.size() != 0 && !(i inside {sysreq_inflight})) begin
                        m_updreq_masterq.push_back(addrMgrConst::get_aiu_funitid(i));
                    end
                end
            end
        end
        if (m_unit_args.k_no_addr_conflicts.get_value() == 0) begin
            idx = $urandom_range(m_updreq_masterq.size() - 1);
            agentid     = m_updreq_masterq[idx];
            aiu_funitid = m_updreq_masterq[idx];
            update_agentq.push_back(agentid);
            //2. pick an address and agentid for a agent with a cacheable valid-state
            st = {UC, UCE, UD, UDP, SD, SC};
            while (pick_addr_given_state(st, cacheline_addr, agentid) == 0) begin
                if (itr == 5000) begin 
                    st.push_front(IX);
                    itr = 0;
                end else begin
                    if ((st[0] == IX) && (itr == 1))
                        void'(st.pop_front());
                    itr++;
                end 
                delay = $urandom_range(100, 1);
                #(<%=obj.Clocks[0].params.period%>ps * delay); //wait for random cycles
            end
            addrq = m_dce_cntr.m_unq_addrq.find(item) with ((item & bit_mask_const) == cacheline_addr);
            if (addrq.size() != 1)
                `uvm_error("DCE_UPD_BURST_SEQ", $psprintf("addrq.size: %0d in a addr conflict test", addrq.size()));
                addr = addrq[0];
            aiu_funitid = agentid;
        end else begin 
            idx = $urandom_range(m_updreq_masterq.size() - 1);
            agentid     = m_updreq_masterq[idx];
            aiu_funitid = m_updreq_masterq[idx];
            do 
            begin
                if(count_unq_upd_addr != 9998) begin
                    do  
                    begin
                        addr = m_addr_mgr.gen_coh_addr(addrMgrConst::get_dce_funitid(0), 1);
                        if(count_unq_upd_addr == 9998) begin
                            #(<%=obj.Clocks[0].params.period%>ps * 10);
                            break;
                        end
                        count_unq_upd_addr++;
                    end
                    while (addr >> addrMgrConst::WCACHE_OFFSET inside {m_dce_cntr.m_unq_addrq});
                end
                else begin
                    addr = m_addr_mgr.gen_coh_addr(addrMgrConst::get_dce_funitid(0), 1);
                    count_unq_upd_addr = 8000;
                end
            end
            while ((addr & bit_mask_const) inside {m_dce_cntr.m_outstanding_addrq[agentid]});
        end
                
        //3. print current aiu cache-model state for address
        cacheline_addr = addr & bit_mask_const;
        //m_dce_cntr.print_cache_model(1, cacheline_addr);
            
        signed_msg_id = m_dce_cntr.get_unused_msgid(0, agentid);
        while (signed_msg_id == -1) begin
            #(<%=obj.Clocks[0].params.period%>ps * 15); // Wait for 15 cycles
            signed_msg_id = m_dce_cntr.get_unused_msgid(0, agentid);
            try++; //keeps a count of how many times we enter this while-loop
            if (try == 2000) begin
                `uvm_error("DCE_MST_SEQ", "Trying to get into infinite loop. msg_id not available for upd_req after 2000 tries");
                break;
            end
            try++;
        end
        try = 0;
        //4. get an un-used msg_id
        msg_id = signed_msg_id; // Assign the positive msg_id
            
        //5. populate smi_seq_item fields.
        if ($test$plusargs("wrong_updreq_target_id")) begin
            targ_id = (addrMgrConst::get_dce_funitid(0) ^ {WSMINCOREUNITID{1'b1}});
        end else begin
            targ_id = addrMgrConst::get_dce_funitid(0);
        end
        
        random_smi_qos = $urandom_range(2**WSMIQOS-1 , 0);
        updreq_seq_item.construct_updmsg(
            .smi_targ_ncore_unit_id(targ_id),
            .smi_src_ncore_unit_id(aiu_funitid),
            .smi_msg_type(eUpdInv),
            .smi_msg_id(msg_id),
            .smi_msg_tier('h0),
            .smi_steer('h0),
            .smi_msg_pri(addrMgrConst::qos_mapping(random_smi_qos)),
            .smi_msg_qos('h0), //this is part of header. driven by legato. so ignore. 
            .smi_msg_err('h0),
                .smi_tm('h0),
            .smi_cmstatus('h0),
            .smi_addr(addr[addrMgrConst::ADDR_WIDTH - 1 : 0]),
            .smi_ns(addr[addrMgrConst::W_SEC_ADDR - 1]),
            .smi_qos(random_smi_qos)
        );
        
        //6. populate in-flight txnq and outstanding addrq
        m_dce_cntr.populate_inflight_txnq( msg_id, agentid, 0, cmd_type, addr, 0, addrMgrConst::get_dce_funitid(0), 0);
        `uvm_info("DCE_MST_DEBUG", $psprintf("Call from send upd req to update addrq addr: %p and agent: %p",addr,agentid), UVM_MEDIUM)
        m_dce_cntr.update_outstanding_addrq(1, agentid, (addr & bit_mask_const));

        //7.Issue txn
        updreq_seq_item.pack_smi_seq_item();
        updreq_seq.m_seq_item = updreq_seq_item;
        updreq_seq.m_seq_item.unpack_smi_seq_item();
        //`uvm_info("DCE_UPDREQ_BURST_SEQ", $psprintf("TXN:%0d Sending data:%0s", i, updreq_seq.m_seq_item.convert2string()), UVM_LOW)
        updreq_seq.return_response(m_smi_tx_port);

        m_cmdupdreqs_issued++;
        m_phase.drop_objection(m_smi_tx_port, $psprintf("updreq_txnid_%0d", i));
        //`uvm_info("DCE_UPDREQ_BURST_SEQ", $psprintf("Loop variable End:%0d agentid:%0d addr:%0p", i, agentid, addr), UVM_LOW)
        `uvm_info("SEND_UPDREQ_TXNS", $psprintf("UpdReqs Sent:%0d", i), UVM_LOW)
        if ((m_unit_args.k_num_coh_cmds.get_value() == 0) && (i == m_unit_args.k_num_upd_cmds.get_value()))
            ev_last_cmdreq_issued.trigger();
    end //for loop

endtask: send_updreq_txns

task dce_mst_base_seq::update_cache_model_updreq();

    if (m_scb != null) begin 
        forever 
            begin
            @(m_scb.upd_comp_e);
            if (m_scb.m_updreq_aa.size() > 0) begin
                foreach(m_scb.m_updreq_aa[key_agentid]) begin 
                    if(m_scb.m_updreq_aa[key_agentid].size() > 0) begin
                        foreach(m_scb.m_updreq_aa[key_agentid][key_msgid]) begin 
                            `uvm_info("DCE_BFM", $psprintf("UpdReq agentid:%0d msgid:0x%0h value:0x%0h", key_agentid, key_msgid, m_scb.m_updreq_aa[key_agentid][key_msgid]), UVM_MEDIUM)
                            cacheline_addr = m_scb.m_updreq_aa[key_agentid][key_msgid] & bit_mask_const;
                            m_dce_cntr.set_cacheline_st(key_agentid, cacheline_addr, IX);
                            m_dce_cntr.print_cache_model(1, cacheline_addr);
                        end
                    end
                end
                m_scb.m_updreq_aa.delete;
            end else begin 
                `uvm_error("DCE_BFM", $psprintf("m_scb.m_updreq_aa is not populated"))
            end
            end//forever block
    end//scb not null

endtask: update_cache_model_updreq
//*************************************************************************
task dce_mst_base_seq::send_cmdreq_txns();
  smi_seq_item seq_item;
  smi_seq      tmp_seq;

  //`uvm_info("DCE MST SEQ", $psprintf("upd_pct: %0s", m_unit_args.k_upd_pct.convert2string()), UVM_LOW)
  `uvm_info("DCE MST SEQ", $psprintf("ntxns smi msgs num_coh_cmds %0d", m_unit_args.k_num_coh_cmds.get_value()), UVM_MEDIUM)
  //`uvm_info("DCE MST SEQ", $psprintf("ntxns smi msgs-- Start sending data"), UVM_LOW)
  for (int i = 1; i <= m_unit_args.k_num_coh_cmds.get_value(); ++i) begin
    string credits_msg;
    int used = 0;
    int unused = 0;
    bit success = 0;
    int itr = 0;
    int try = 0;
    string s;
    int agentid;
    addr_width_t addr;
    m_phase.raise_objection(m_smi_tx_port, "cmdreq");
    //`uvm_info("DCE_CMD_REQ_BURST_SEQ", $psprintf("Loop variable Begin:%0d", i), UVM_LOW)
    tmp_seq      = smi_seq::type_id::create("smi_sequence");
    seq_item     = smi_seq_item::type_id::create("smi_seq_item");
    if (i > 1 && $test$plusargs("single_step")) begin
        //`uvm_info("DCE_MST_SEQ", "waiting on single_step trigger", UVM_NONE)
        @e_single_step;
        #(<%=obj.Clocks[0].params.period%>ps * 15);
       //`uvm_info("DCE_MST_SEQ", "single_step event triggered"n, UVM_NONE)
    end
    if (!$test$plusargs("k_slow_smi1_rx_port")) begin
            #(<%=obj.Clocks[0].params.period%>ps);
    end
    do 
    begin
        if (!$test$plusargs("k_slow_smi1_rx_port")) begin
                #(<%=obj.Clocks[0].params.period%>ps * 10);
        end
        populate_available_agentsq();
    end 
    while ((m_ch_agentq.size() == 0) && (m_nc_agentq.size() == 0)); 

    if ($test$plusargs("exc_ops_only")) begin
       //`uvm_info("DCE_MST_SEQ", "this is exc ops only test", UVM_LOW);
       if (m_exc_masterq.size() == 0) begin
            while (m_exc_masterq.size() == 0) begin
                #(<%=obj.Clocks[0].params.period%>ps * 10);
                populate_available_agentsq();
            end
       end
    end
    if ($test$plusargs("cacheable_master_ops_only") && (m_ch_agentq.size() == 0)) begin
        while (m_ch_agentq.size() == 0) begin
            #(<%=obj.Clocks[0].params.period%>ps * 10);
            populate_available_agentsq();
        end
    end
    
    if (($test$plusargs("wrstshfull_dm_miss") || 
         $test$plusargs("wrstashfull_dm_miss") ||
         $test$plusargs("wrstashptl_dm_miss") ||
         $test$plusargs("wrstashptl_dm_hit")    
        ) && (m_wr_stash_masterq.size() == 0)) begin
        while (m_wr_stash_masterq.size() == 0) begin
            #(<%=obj.Clocks[0].params.period%>ps * 10);
            populate_available_agentsq();
        end
    end
    
    if (($test$plusargs("ldcchshd_dm_hit") || 
         $test$plusargs("ldcchshd_dm_miss") ||
         $test$plusargs("ldcchunq_dm_miss") ||
         $test$plusargs("ldcchunq_dm_hit")  
        ) && (m_chib_agentq.size() == 0) && (m_wr_stash_masterq.size() == 0)) begin
        while ((m_chib_agentq.size() == 0) && (m_wr_stash_masterq.size() == 0)) begin
            #(<%=obj.Clocks[0].params.period%>ps * 10);
            populate_available_agentsq();
        end
    end
    c_pk_ch_agent.constraint_mode(1);
    c_agentid.constraint_mode(1);
    c_concerto_msg.constraint_mode(1);
    //if (this.randomize() with {(r_aiu_funitid inside {attached_agent_queue, m_nc_agentq});} == 0) begin
    if (this.randomize() == 0) begin
       `uvm_error("DCE_MST_SEQ", "Randomization failed 1");
    end else begin
       //`uvm_info("DBG_RAND", $psprintf("k_pk_ch_agent_pct:%0d r_pk_ch_agent:%0d m_ch_agentq.size:%0d", m_unit_args.k_pck_ch_agent_pct.get_value(), r_pk_ch_agent, m_ch_agentq.size()), UVM_NONE)
    end 
       `uvm_info(get_name(), $psprintf("[%-35s] (rPkChAgent: %1d) (rFunit: 0x%02h) (cmd: %25s) (msgId: 0x%02h) (chAgentQ: %0p)", "DceMstSeq-CmdRandOut", r_pk_ch_agent, r_aiu_funitid, r_cmdupd_item.type2cmdname(), msg_id, m_ch_agentq), UVM_HIGH);
  
    agentid = addrMgrConst::agentid_assoc2funitid(r_aiu_funitid);
    //for addr_conflicts test, grab a address from the m_unq_addrq
    if (m_unit_args.k_no_addr_conflicts.get_value() == 0) begin
        if (m_dce_cntr.m_unq_addrq.size() == 0) 
           `uvm_error("DCE_MST_SEQ", "m_unq_addrq cannot be empty for a addr_conflicts test.");

        do begin   
            try++; //keeps a count of how many times we enter this loop
            if (try == 40000) begin
               `uvm_error("DCE_MST_SEQ", "Trying to get into infinite loop");
                break;
            end else if (try % 20 == 0) begin //after every 20 tries, wait for 10 cycle. This is to allow time for some addresses to become aavailable
                #(<%=obj.Clocks[0].params.period%>ps * 10);
            end

            if (itr == m_dce_cntr.m_unq_addrq.size()) begin // looked through the entire unq_addrq for a good address for an already randomized cmd_item, couldnt find one so randomizing cmd_item again.
                itr = 0;
                do begin
                    populate_available_agentsq();
                    #(<%=obj.Clocks[0].params.period%>ps * 10);
                end while (    ((m_ch_agentq.size() == 0) && (m_nc_agentq.size() == 0))
                            || (($test$plusargs("ldcchshd_dm_hit") || 
                                 $test$plusargs("ldcchshd_dm_miss") ||
                                 $test$plusargs("ldcchunq_dm_hit") ||
                                 $test$plusargs("ldcchunq_dm_miss")
                                ) && (!m_chib_agentq.size() && !m_wr_stash_masterq.size())) //make sure there is a master that can issue read stash (CHI-B or ACE-LITE-E)
                            || (($test$plusargs("wrstshfull_dm_hit") || 
                                 $test$plusargs("wrstshfull_dm_miss") ||
                                 $test$plusargs("wrstshptl_dm_hit") ||
                                 $test$plusargs("wrstshptl_dm_miss")
                                ) && !m_wr_stash_masterq.size()) //make sure there is a master that can issue write stash (ACE-LITE-E)
                          ); 

                c_pk_ch_agent.constraint_mode(1);
                c_agentid.constraint_mode(1);
                c_concerto_msg.constraint_mode(1);
                if ($test$plusargs("cacheable_master_ops_only") && (m_ch_agentq.size() == 0)) begin
                    while (m_ch_agentq.size() == 0) begin
                        #(<%=obj.Clocks[0].params.period%>ps * 10);
                        populate_available_agentsq();
                       `uvm_info("DCE_MST_DBG",$psprintf("attached_agent_queue = %p and sysreq_in_flight = %p",attached_agent_queue,sysreq_inflight),UVM_MEDIUM)
                    end
                end

                //if (this.randomize() with {(r_aiu_funitid inside {attached_agent_queue, m_nc_agentq});} == 0) begin
                if (this.randomize() == 0) begin
                    `uvm_info("DCE_MST_DBG",$psprintf("attached_agent_queue = %p and sysreq_in_flight = %p",attached_agent_queue,sysreq_inflight),UVM_NONE)
                    `uvm_error("DCE_MST_SEQ", "Randomization failed 2");
                end 
                agentid = addrMgrConst::agentid_assoc2funitid(r_aiu_funitid);
            end
            else begin  // Adding this else for the itr==addr.size(), there can be UPD while this is done which can change r_aiu_funitid so copy random1 value here in else (change related to SysCo)
                r_aiu_funitid = agentid;
            end

            //*****pick addr*******
            if ($test$plusargs("single_sfset")) begin
                m_dce_cntr.m_unq_addrq_per_sfsetaddr[sf_setaddr].shuffle();
                addr = m_dce_cntr.m_unq_addrq_per_sfsetaddr[sf_setaddr][0];
            end else begin
                m_dce_cntr.m_unq_addrq.shuffle();
                addr = m_dce_cntr.m_unq_addrq[0];
            end
            //*****pick addr*******
            itr++; //keep a count of how many times we tried to get a good addr, given an already randomized cmd item
            //`uvm_info("DBG", $psprintf("itr:%0d try:%0d agentid:%0d addr:0x%0h op:%0p master_legal_state:%0d in_outstanding_addrq:%0d oq_size:%0d", itr, try, agentid, addr, r_cmdupd_item.smi_msg_type, is_master_in_legal_state(agentid, addr), ((addr & bit_mask_const) inside {m_dce_cntr.m_outstanding_addrq[agentid]}), m_dce_cntr.m_outstanding_addrq[agentid].size()), UVM_LOW)
        end while (!is_master_in_legal_state(agentid, addr) || ((addr & bit_mask_const) inside {m_dce_cntr.m_outstanding_addrq[agentid]}));
        try = 0;
    end 
    //for no_addr_conflicts test generate addresses on the fly
    else begin
        do begin
            if(count_unq_addr != 9998) begin
                do  
                    begin
                        addr = m_addr_mgr.gen_coh_addr(addrMgrConst::get_dce_funitid(0), 1);
                        if(count_unq_addr == 9998) begin
                            #(<%=obj.Clocks[0].params.period%>ps * 10);
                            break;
                        end
                        count_unq_addr++;
                    end
                while ((addr >> addrMgrConst::WCACHE_OFFSET) inside {m_dce_cntr.m_unq_addrq});
            end
            if(count_unq_addr == 9998) begin
                do
                    begin
                        addr = m_addr_mgr.gen_coh_addr(addrMgrConst::get_dce_funitid(0), 1);
                        m_dce_cntr.load_cacheline(addr);
                        if (this.randomize() == 0) begin
                                `uvm_error("DCE_MST_SEQ", "Randomization failed in no_addr_conflict");
                        end
                            agentid = addrMgrConst::agentid_assoc2funitid(r_aiu_funitid);
                    end
                while(!is_master_in_legal_state(agentid, addr));
                count_unq_addr = 8000;
            end
        end
        while((addr & bit_mask_const) inside {m_dce_cntr.m_outstanding_addrq[agentid]});
        m_dce_cntr.load_cacheline(addr);
        m_dce_cntr.m_unq_addrq.push_back(addr >> addrMgrConst::WCACHE_OFFSET);
        m_dce_cntr.m_unq_addrq.shuffle();
        
    end

    //`uvm_info("DCE MST SEQ CMDREQ", $psprintf("before r_aiu_funitid:%0d agentid:%0d", r_aiu_funitid, agentid), UVM_LOW)
    cacheline_addr = addr & bit_mask_const;
    m_dce_cntr.print_cache_model(1, cacheline_addr);
    agentid = addrMgrConst::agentid_assoc2funitid(r_aiu_funitid);
    //`uvm_info("DCE MST SEQ CMDREQ", $psprintf("after r_aiu_funitid:%0d agentid:%0d", r_aiu_funitid, agentid), UVM_LOW)
//    foreach(m_dce_cntr.m_inflight_txns[0][j]) begin
//      if (m_dce_cntr.m_inflight_txns[0][j].is_msgid_inuse()) begin
//          `uvm_info("INFLIGHT_TXNQ_MST_SEQ", $psprintf("addr:%p, msg_type:%p msg_id:0x%0h", m_dce_cntr.m_inflight_txns[0][j].get_addr(), m_dce_cntr.m_inflight_txns[0][j].get_msg_type(), m_dce_cntr.m_inflight_txns[0][j].get_msg_id()), UVM_HIGH);
//           used++;
//      end else begin
//           unused++;
//      end
//    end
//    `uvm_info("DCE MST SEQ", $psprintf("used: %0d unused:%0d", used, unused), UVM_HIGH)
  
    signed_msg_id = m_dce_cntr.get_unused_msgid(1, agentid);
    while (signed_msg_id == -1) begin
        #(<%=obj.Clocks[0].params.period%>ps * 15); // Wait for 15 cycles
        signed_msg_id = m_dce_cntr.get_unused_msgid(1, agentid);
        try++; //keeps a count of how many times we enter this while-loop
        if (try == 2000) begin
            `uvm_error("DCE_MST_SEQ", "Trying to get into infinite loop. msg_id not available for cmd_req after 2000 tries");
            break;
        end
        try++;
    end
    try = 0;
    msg_id = signed_msg_id; // Assign the positive msg_id

    assign_cmdmsg_fields(msg_id, addr, seq_item);

    if(r_cmdupd_item.isUpdMsg()) begin
        m_dce_cntr.populate_inflight_txnq( msg_id, agentid, 0, cmd_type, addr, 0, addrMgrConst::get_dce_funitid(0), 0);
    end else begin
        $cast(cmd_type, r_cmdupd_item.smi_msg_type);
        m_dce_cntr.populate_inflight_txnq( msg_id, agentid, 1, cmd_type, addr, r_cmdupd_item.smi_es, addrMgrConst::get_dce_funitid(0), r_cmdupd_item.smi_mpf1_awunique);
    end

    s = "";
    foreach(m_dce_cntr.m_outstanding_addrq[agentid][k]) begin
        $sformat(s, "%0s 0x%0h ", s, m_dce_cntr.m_outstanding_addrq[agentid][k]);   
    end
    `uvm_info("DCE MST SEQ CMD_REQ", $psprintf("for agentid:%0d outstanding_addrq\n%0s", agentid, s), UVM_MEDIUM)
    s = "";
    //`uvm_info("DCE_CMD_BURST_SEQ", $psprintf("picked addr:%0p agentid:%0d", addr, agentid), UVM_LOW);
    `uvm_info("DCE_MST_DEBUG", $psprintf("Call from send cmd req to update addrq addr: %0h and agent: %0d",addr,agentid), UVM_MEDIUM)
    
    m_dce_cntr.update_outstanding_addrq(1, agentid, (addr & bit_mask_const));

    seq_item.pack_smi_seq_item();

    tmp_seq.m_seq_item = seq_item;
    tmp_seq.m_seq_item.unpack_smi_seq_item();
    //`uvm_info("DCE_CMDREQ_BURST_SEQ", $psprintf("TXN:%0d Sending data:%0s", i, tmp_seq.m_seq_item.convert2string()), UVM_LOW)
    
    //Initiate seq-seqr interaction
    if(r_cmdupd_item.isCmdMsg()) begin
        $sformat(credits_msg, "aiu%0d_nCmdInFlight", tmp_seq.m_seq_item.smi_src_ncore_unit_id);
        m_credit_pool.get_credit(credits_msg, credits_pend);
    end
    //`uvm_info("DCE MST SEQ", $psprintf("credit_pend for %0s after used: %0d", credits_msg, credits_pend), UVM_LOW)
    
    tmp_seq.return_response(m_smi_tx_port);
    m_cmdupdreqs_issued++;
                
    m_phase.drop_objection(m_smi_tx_port, "cmdreq");
    `uvm_info("SEND_CMDREQ_TXNS", $psprintf("CmdReqs Sent:%0d", i), UVM_LOW)

    if (i == m_unit_args.k_num_coh_cmds.get_value()) begin 
        #(<%=obj.Clocks[0].params.period%>ps * 30000);
        if (    (m_unit_args.k_slow_dmi_rsp_port.get_value() == 1)
             || ($test$plusargs("k_slow_smi2_rx_port"))) 
            #(<%=obj.Clocks[0].params.period%>ps * 5000000);
        ev_last_cmdreq_issued.trigger();
    end 
  end

  //`uvm_info("DCE MST SEQ", $psprintf("ntxns smi msgs-- Complete sending data"), UVM_LOW)
endtask: send_cmdreq_txns


//*****************************************************************************
task dce_mst_base_seq::receive_cmdupdrsp_txns(int num_scrub_routine_txns = -1, int num_directed_test_txns = -1);
    smi_seq_item rsp_item;
    string credits_msg;
    int idxq[$];
    int rsps_received = 0;
    int aiu_agentid;
    int agent_indxq[$];
    int upd_indxq[$];

    if ($test$plusargs("inject_smi_uncorr_error")) begin
        rsps_received++;
    end else if ($test$plusargs("wrong_cmdreq_target_id") || $test$plusargs("wrong_updreq_target_id") || $test$plusargs("wrong_sysreq_target_id")) begin
        return;
    end
    
    if ($test$plusargs("user_addr_for_csr")) 
        total_rsps_expected = m_cmds_issued;
    else if (num_scrub_routine_txns != -1) 
        total_rsps_expected = num_scrub_routine_txns;
    else if (num_directed_test_txns != -1)
        total_rsps_expected = num_directed_test_txns;
    else 
        total_rsps_expected = m_unit_args.k_num_coh_cmds.get_value() + m_unit_args.k_num_upd_cmds.get_value();

  `uvm_info("DCE_MST_SEQ", $psprintf("tsk:receive_cmdupd_txns:%0d", total_rsps_expected), UVM_LOW)
  //#Check.DCE.CmdUpdRspsReceived
  m_phase.raise_objection(m_smi_rx_port, "cmdupdrsp");
    do 
    begin
        m_smi_rx_port.m_rx_analysis_fifo.get(rsp_item);
 
        rsp_item.unpack_smi_seq_item();
        rsps_received++;
        if(rsps_received == 1 && (rsp_item.smi_conc_msg_class != eConcMsgSysRsp || $test$plusargs("directed_attach_detach_seq"))) begin
            ev_first_scb_txn.trigger(); 
        end
        if (rsp_item.smi_conc_msg_class == eConcMsgUpdRsp) begin
              aiu_agentid = addrMgrConst::agentid_assoc2funitid(rsp_item.smi_targ_ncore_unit_id);
                  idxq = m_dce_cntr.m_inflight_txns.find_index(x) with (x.is_msgid_inuse() && (x.get_msg_id() == rsp_item.smi_rmsg_id) && (x.get_master_id() == addrMgrConst::agentid_assoc2funitid(rsp_item.smi_targ_ncore_unit_id)) && !x.m_cmd_n_upd_req);
              
              //Check inly one entry exists
              if (idxq.size() == 0)
                `uvm_error("DCE MST SEQ", "No match for UpdRsp")
              else if (idxq.size() > 1)
                `uvm_error("DCE MST SEQ", "More than one match for UpdRsp")
        
        upd_indxq = update_agentq.find_index(x) with (x == addrMgrConst::agentid_assoc2funitid(rsp_item.smi_targ_ncore_unit_id));
        if(upd_indxq.size != 0)
            update_agentq.delete(upd_indxq[0]);
              m_dce_cntr.m_inflight_txns[idxq[0]].set_updrsp_rcvd();
              m_dce_cntr.release_msgid(aiu_agentid, rsp_item.smi_rmsg_id);
              m_dce_cntr.update_outstanding_addrq(0, aiu_agentid, (m_dce_cntr.m_inflight_txns[idxq[0]].get_addr() & bit_mask_const));
          end
          else if(rsp_item.smi_conc_msg_class == eConcMsgSysRsp) begin
            sys_rsps_recieved++;
            agent_indxq = sysreq_inflight.find_index(item) with (item == rsp_item.smi_targ_ncore_unit_id);
            sysreq_inflight.delete(agent_indxq[0]);
            if(!$test$plusargs("directed_attach_detach_seq"))
                rsps_received--;    
          end 
          else begin
            if ($test$plusargs("disable_creditchks") == 0) begin
                $sformat(credits_msg, "aiu%0d_nCmdInFlight", rsp_item.smi_targ_ncore_unit_id);
                m_credit_pool.put_credit(credits_msg, credits_pend);
            end
          end
        if(rsps_received == (total_rsps_expected - 5))
            stop_attach_detach_flag = 1;
    end 
    while (rsps_received != total_rsps_expected);
  if (m_scb != null) begin
    while (m_scb.m_dce_txnq.size() > 0) begin
      #<%=obj.Clocks[0].params.period%>ps;
        //`uvm_info("DCE_MST_BASE_SEQ", $psprintf("Waiting to trigger %d",m_scb.m_dce_txnq.size()), UVM_LOW)
    end
  end
        ev_last_scb_txn.trigger();
  
  m_phase.drop_objection(m_smi_rx_port, "cmdupdrsp");
  `uvm_info("DCE_MST_BASE_SEQ", $psprintf("fn:receive_cmdupdrsp_txns objection dropped"), UVM_LOW)
endtask: receive_cmdupdrsp_txns

//****************************************************************************
function void dce_mst_base_seq::populate_available_agentsq();

  m_ch_agentq.delete();
  m_nc_agentq.delete();
  m_chib_agentq.delete();
  m_chia_agentq.delete();
  m_wr_stash_masterq.delete();
  m_stash_targetq.delete();
  m_wrclnptl_masterq.delete();
  m_exc_masterq.delete();
  m_proxy_cache_agentq.delete();

    if ($test$plusargs("single_cacheable_master")) begin
        for (int i = 0; i < addrMgrConst::NUM_AIUS; ++i) begin
            int indxq[$];
            if(addrMgrConst::get_native_interface(i) inside {addrMgrConst::ACE_AIU, addrMgrConst::CHI_A_AIU, addrMgrConst::CHI_B_AIU, addrMgrConst::IO_CACHE_AIU}) begin
                indxq = attached_agent_queue.find_index(x) with (x == i);
                    if(indxq.size() != 0) begin
                        m_ch_agentq.push_back(addrMgrConst::get_aiu_funitid(i));
                        return;
                    end
            end
        end
    end

    for (int i = 0; i < addrMgrConst::NUM_AIUS; ++i) begin
            string credits_msg;
            int indxq[$];
            
            $sformat(credits_msg, "aiu%0d_nCmdInFlight", addrMgrConst::get_aiu_funitid(i));
            //if (m_credit_pool.peek_credits_available(credits_msg) && (addrMgrConst::get_aiu_funitid(i) inside {m_connected_agentq})) begin
            if (m_credit_pool.peek_credits_available(credits_msg)) begin
                if ( addrMgrConst::get_native_interface(i) == addrMgrConst::ACE_AIU ||
                     addrMgrConst::get_native_interface(i) == addrMgrConst::CHI_A_AIU ||
                     addrMgrConst::get_native_interface(i) == addrMgrConst::CHI_B_AIU ||
                     addrMgrConst::get_native_interface(i) == addrMgrConst::IO_CACHE_AIU) begin
                    indxq = attached_agent_queue.find_index(x) with (x == i);
                        if(indxq.size() != 0 && !(i inside {sysreq_inflight})) begin
                            m_ch_agentq.push_back(addrMgrConst::get_aiu_funitid(i));
                        end
                end
                else
                  m_nc_agentq.push_back(addrMgrConst::get_aiu_funitid(i));
                if (addrMgrConst::get_native_interface(i) inside {addrMgrConst::ACE_LITE_E_AIU})
                  m_wr_stash_masterq.push_back(addrMgrConst::get_aiu_funitid(i));

                if ((addrMgrConst::get_native_interface(i) == addrMgrConst::CHI_B_AIU) && addrMgrConst::is_stash_enable(i)) begin
                  indxq = attached_agent_queue.find_index(x) with (x == i);
                    if(indxq.size() != 0 && !(i inside {sysreq_inflight})) begin
                        m_stash_targetq.push_back(addrMgrConst::get_aiu_funitid(i));
                        m_chib_agentq.push_back(addrMgrConst::get_aiu_funitid(i));
                        m_exc_masterq.push_back(addrMgrConst::get_aiu_funitid(i));
                    end
                end
                if ((addrMgrConst::get_native_interface(i) == addrMgrConst::CHI_A_AIU) && !addrMgrConst::is_stash_enable(i)) begin
                  indxq = attached_agent_queue.find_index(x) with (x == i);
                    if(indxq.size() != 0 && !(i inside {sysreq_inflight})) begin
                        m_wrclnptl_masterq.push_back(addrMgrConst::get_aiu_funitid(i));
                        m_chia_agentq.push_back(addrMgrConst::get_aiu_funitid(i));
                        m_exc_masterq.push_back(addrMgrConst::get_aiu_funitid(i));
                    end
                end
                if (addrMgrConst::get_native_interface(i) == addrMgrConst::ACE_AIU) begin
                  indxq = attached_agent_queue.find_index(x) with (x == i);
                    if(indxq.size() != 0 && !(i inside {sysreq_inflight})) begin
                        m_exc_masterq.push_back(addrMgrConst::get_aiu_funitid(i));
                        m_ace_agentq.push_back(addrMgrConst::get_aiu_funitid(i));
                    end
                end
                if (addrMgrConst::get_native_interface(i) == addrMgrConst::IO_CACHE_AIU) begin
                  indxq = attached_agent_queue.find_index(x) with (x == i);
                    if(indxq.size() != 0 && !(i inside {sysreq_inflight})) begin
                        m_proxy_cache_agentq.push_back(addrMgrConst::get_aiu_funitid(i));
                    end
                end
            end
      end
    
    if($test$plusargs("dce_addr_aliasing_seq")) begin
        m_ch_agentq.delete();
        for(int i = 0; i < addrMgrConst::NUM_AIUS; ++i) begin
            if(addrMgrConst::get_snoopfilter_id(i) == 0) // Because we are trying to hit SF0
                m_ch_agentq.push_back(addrMgrConst::get_aiu_funitid(i));
        end //End for loop
    end // end dce_addr_aliasing_seq

  //`uvm_info("DCE MST SEQ", $psprintf("ch_agentq_size: %0d nc_agentq_size: %0d wr_stash_masterq_size: %0d stash_targetq_size:%0d exc_masterq_size:%0d", m_ch_agentq.size(), m_nc_agentq.size(), m_wr_stash_masterq.size(), m_stash_targetq.size(), m_exc_masterq.size()), UVM_LOW) 
endfunction: populate_available_agentsq

//****************************************************************************
function bit dce_mst_base_seq::pick_addr_given_state(input ncore_cache_state_t stq[$], output addr_width_t addr, output int agentid);
  bit success = 0;
  ncore_cache_model fndq[$];
  addr_width_t outstanding_addrq[$];
  addr_width_t cacheline_addr;
  int cacheid;
  string s;

  //`uvm_info("DCE MST SEQ", $psprintf("Inside fn pick address given state -- BEGIN"), UVM_LOW)
  //m_dce_cntr.print_cache_model(1);

  m_updreq_masterq.shuffle();
  for(int i=0; i < m_updreq_masterq.size(); i++) begin
    outstanding_addrq.delete();
    s = "";
    //m_dce_cntr.print_outstanding_addrq(m_updreq_masterq[i]);
    foreach (m_dce_cntr.m_outstanding_addrq[m_updreq_masterq[i]][j]) begin 
        cacheline_addr = m_dce_cntr.m_outstanding_addrq[m_updreq_masterq[i]][j] & bit_mask_const;
        outstanding_addrq.push_back(cacheline_addr);
    end 
    foreach(outstanding_addrq[k]) begin 
        $sformat(s, "%0s 0x%0h ", s, outstanding_addrq[k]); 
    end
    //`uvm_info("DCE MST SEQ", $psprintf("for agentid:%0d outstanding_cacheline_addrq\n%0s", m_updreq_masterq[i], s), UVM_LOW)
    cacheid = addrMgrConst::get_cache_id(m_updreq_masterq[i]);
    fndq = m_dce_cntr.m_cachelines_st.find(x) with ((x.m_cache_st_p_agent[cacheid] inside {stq}) && !(x.get_addr() inside {outstanding_addrq}));
    if (fndq.size() > 0) begin
        agentid = m_updreq_masterq[i];
        success = 1;
        break;
    end
  end

  if (success == 1) begin
    fndq.shuffle();
    addr = fndq[0].get_addr();
  end 
    
  //`uvm_info("DCE MST SEQ", $psprintf("Inside fn pick address given state -- END agentid:%0d", agentid), UVM_LOW)
  return success;

endfunction:pick_addr_given_state

//********************************************************
function bit dce_mst_base_seq::is_cachable_agent(int id);
  return (
    addrMgrConst::get_native_interface(id) == addrMgrConst::ACE_AIU ||
    addrMgrConst::get_native_interface(id) == addrMgrConst::IO_CACHE_AIU ||
    addrMgrConst::get_native_interface(id) == addrMgrConst::CHI_A_AIU ||
    addrMgrConst::get_native_interface(id) == addrMgrConst::CHI_B_AIU) ? 1 : 0;
endfunction: is_cachable_agent

//********************************************************
// send_directed_cmd_request
//********************************************************
task dce_mst_base_seq::send_directed_cmdreq_txn(int requestor_aiu_funitid_i,
                                                         addr_width_t addr_i,
                                                         eMsgCMD      cmd_type_i,
                                                         int          delay_value = -1 
                                                         );
    smi_seq_item cmdreq_seq_item;
    smi_seq      cmdreq_seq;
    bit success;
    string credits_msg;
    int agentid, delay;
    int try = 0;
    
    m_phase.raise_objection(m_smi_tx_port, "cmdreq");
    
    cmdreq_seq      = smi_seq::type_id::create("smi_sequence");
    cmdreq_seq_item = smi_seq_item::type_id::create("smi_seq_item");
    
    if(delay_value == -1)       
        delay = $urandom_range(100, 1);
    else
        delay = delay_value;
        //`uvm_info("DCE_DBG_DELAY", $psprintf("Delay_value = %d",delay), UVM_LOW)
    #(<%=obj.Clocks[0].params.period%>ps * delay); //wait for random cycles

    agentid = addrMgrConst::agentid_assoc2funitid(requestor_aiu_funitid_i);
    cacheline_addr = addr_i & bit_mask_const;
    //m_dce_cntr.print_cache_model(1, cacheline_addr);
    signed_msg_id = m_dce_cntr.get_unused_msgid(1, agentid);
    while (signed_msg_id == -1) begin
        #(<%=obj.Clocks[0].params.period%>ps * 15); // Wait for 15 cycles
        signed_msg_id = m_dce_cntr.get_unused_msgid(1, agentid);
        try++; //keeps a count of how many times we enter this while-loop
        if (try == 2000) begin
            `uvm_error("DCE_MST_SEQ", "Trying to get into infinite loop. msg_id not available for directed_cmd_req after 2000 tries");
            break;
        end
        try++;
    end
    try = 0;
    msg_id = signed_msg_id; // Assign the positive msg_id

    c_pk_ch_agent.constraint_mode(0);
    c_agentid.constraint_mode(0);
    c_concerto_msg.constraint_mode(0);
    success = this.randomize() with {r_cmdupd_item.smi_msg_type == cmd_type_i;
                    r_aiu_funitid == requestor_aiu_funitid_i;
                                    };
    
    if (success == 0) begin
        $stacktrace();
       `uvm_info(get_name(), $psprintf("[%-35s] [cmd: %s] [reqAiutId: 0x%02h] [chiAAgents: %p]", "DceMstSeq-DirCmdRandErr", cmd_type_i.name(), requestor_aiu_funitid_i, m_chia_agentq), UVM_NONE);
       `uvm_error("DCE_MST_SEQ", "Send_directed_cmdreq_seq -- Randomization failed");
    end else begin 
        //`uvm_info("DCE_MST_SEQ", $psprintf("Send_directed_cmdreq_seq smi_mpf1_awunique--%0b", r_cmdupd_item.smi_mpf1_awunique), UVM_LOW)
    end
    if (cmd_type_i == eCmdLdCchShd) begin
        r_cmdupd_item.smi_mpf1_stash_nid = 1;
    end
    if ($test$plusargs("SNPrsp_sharer_data_error_in_cmstatus") || $test$plusargs("SNPrsp_sharer_non_data_error_in_cmstatus")) begin
        r_cmdupd_item.smi_qos = 0;
        r_cmdupd_item.smi_msg_pri = 7;
    end
    if ($test$plusargs("SNPrsp_data_error_in_cmstatus") || $test$plusargs("wrong_sysrsp_target_id")) begin
        if(r_cmdupd_item.smi_mpf2_flowid_valid == 1) begin
            r_cmdupd_item.smi_mpf2_flowid = 0;
        end
    end

    assign_cmdmsg_fields(msg_id, addr_i, cmdreq_seq_item);
    m_dce_cntr.populate_inflight_txnq( msg_id, agentid, 1, cmd_type_i, addr_i, r_cmdupd_item.smi_es, addrMgrConst::get_dce_funitid(0), r_cmdupd_item.smi_mpf1_awunique);
    m_dce_cntr.update_outstanding_addrq(1, agentid, (addr_i & bit_mask_const));

    cmdreq_seq_item.pack_smi_seq_item();

    cmdreq_seq.m_seq_item = cmdreq_seq_item;
    cmdreq_seq.m_seq_item.unpack_smi_seq_item();
    //`uvm_info("DCE_CMDREQ_TXN", $psprintf("Sending data:%0s", cmdreq_seq.m_seq_item.convert2string()), UVM_LOW)
  
    if ($test$plusargs("disable_creditchks") == 0) begin
        $sformat(credits_msg, "aiu%0d_nCmdInFlight", cmdreq_seq.m_seq_item.smi_src_ncore_unit_id);
        m_credit_pool.get_credit(credits_msg, credits_pend);
    end

    cmdreq_seq.return_response(m_smi_tx_port);
                
    m_phase.drop_objection(m_smi_tx_port, "cmdreq");

endtask: send_directed_cmdreq_txn



//********************************************************
// send_directed_upd_request
//********************************************************
task dce_mst_base_seq::send_directed_updreq_txn(int requestor_aiu_funitid_i,
                                                         addr_width_t addr_i,
                                                         int          delay_value = -1
                                                         );
    smi_seq_item updreq_seq_item;
    smi_seq      updreq_seq;
    bit success;
    int agentid, delay;
    int try = 0;
    
    m_phase.raise_objection(m_smi_tx_port, "updreq");
    
    updreq_seq      = smi_seq::type_id::create("smi_sequence");
    updreq_seq_item = smi_seq_item::type_id::create("smi_seq_item");
    
    if(delay_value == -1)       
        delay = $urandom_range(100, 1);
    else
        delay = delay_value;
        //`uvm_info("DCE_DBG_DELAY", $psprintf("Delay_value = %d",delay), UVM_LOW)
    #(<%=obj.Clocks[0].params.period%>ps * delay); //wait for random cycles

    agentid = addrMgrConst::agentid_assoc2funitid(requestor_aiu_funitid_i);
    cacheline_addr = addr_i & bit_mask_const;
    //m_dce_cntr.print_cache_model(1, cacheline_addr);
    signed_msg_id = m_dce_cntr.get_unused_msgid(0, agentid);
    while (signed_msg_id == -1) begin
        #(<%=obj.Clocks[0].params.period%>ps * 15); // Wait for 15 cycles
        signed_msg_id = m_dce_cntr.get_unused_msgid(0, agentid);
        try++; //keeps a count of how many times we enter this while-loop
        if (try == 2000) begin
            `uvm_error("DCE_MST_SEQ", "Trying to get into infinite loop. msg_id not available for directed_upd_req after 2000 tries");
            break;
        end
        try++;
    end
    try = 0;
    msg_id = signed_msg_id; // Assign the positive msg_id


    c_pk_ch_agent.constraint_mode(0);
    c_agentid.constraint_mode(0);
    c_concerto_msg.constraint_mode(0);
   /* success = this.randomize() with {r_cmdupd_item.smi_msg_type == smi_msg_type_bit_t'(UPD_INV);
                    r_aiu_funitid == requestor_aiu_funitid_i;
                    (r_aiu_funitid inside {attached_agent_queue, m_nc_agentq});
                                    };
    */
    success = this.randomize() with {r_cmdupd_item.smi_msg_type == smi_msg_type_bit_t'(UPD_INV);
                    r_aiu_funitid == requestor_aiu_funitid_i;
                                    };
    
    if (success == 0) begin
       `uvm_error("DCE_MST_SEQ", "Send_directed_updreq_seq -- Randomization failed");
    end else begin 
    end

    assign_cmdmsg_fields(msg_id, addr_i, updreq_seq_item);
    m_dce_cntr.populate_inflight_txnq( msg_id, agentid, 0, cmd_type, addr_i, r_cmdupd_item.smi_es, addrMgrConst::get_dce_funitid(0), 0);
    m_dce_cntr.update_outstanding_addrq(1, agentid, (addr_i & bit_mask_const));

    updreq_seq_item.pack_smi_seq_item();

    updreq_seq.m_seq_item = updreq_seq_item;
    updreq_seq.m_seq_item.unpack_smi_seq_item();
    `uvm_info("DCE_DIRECTED_UPDREQ_TXN", $psprintf("Sending data:%0s", updreq_seq.m_seq_item.convert2string()), UVM_LOW)
  
    updreq_seq.return_response(m_smi_tx_port);
                
    m_phase.drop_objection(m_smi_tx_port, "updreq");

endtask: send_directed_updreq_txn

//********************************************************
task dce_mst_base_seq::send_sysreq_attach(int agent_id = -1);

    smi_seq_item sys_req_attach;
    smi_seq      sysreq_seq;
    int index[$];
    int targ_id = 0;
    int try = 0;
        
    if ($test$plusargs("wrong_sysreq_target_id")) begin
        targ_id = (addrMgrConst::get_dce_funitid(0) ^ {WSMINCOREUNITID{1'b1}});
        agent_id = 0;
    end 
    else
            targ_id = addrMgrConst::get_dce_funitid(0);
        
    if(agent_id == -1) begin    
        for(int i = 0; i < <%=obj.DceInfo[0].nCachingAgents%>; i++ ) begin
            
            agent_id = CACHING_AIU_FUNIT_IDS[i];
            attach_detach_s[addrMgrConst::get_aiu_funitid(agent_id)].get(1);
            m_phase.raise_objection(m_smi_tx_port, "sysreq");
            
            sysreq_seq      = smi_seq::type_id::create("smi_sequence");
            sys_req_attach = smi_seq_item::type_id::create("smi_seq_item");
    
            sys_req_attach = new("sys_req_attach");
            sys_req_attach.construct_sysmsg(
                    .smi_targ_ncore_unit_id (addrMgrConst::get_dce_funitid(0)),
                    .smi_src_ncore_unit_id  (agent_id),
                    .smi_msg_type           (SYS_REQ),
                    .smi_msg_id             (0),
                    .smi_msg_tier           (0),
                    .smi_steer              (0),
                    .smi_msg_pri            (0),
                    .smi_msg_qos            (0),
                    .smi_rmsg_id            (0),
                    .smi_msg_err            (0),
                    .smi_cmstatus           (0),
                    .smi_sysreq_op          (1),
                    .smi_ndp_aux            (0)
                );
            sys_req_attach.pack_smi_seq_item();

            sysreq_seq.m_seq_item = sys_req_attach;
            sysreq_seq.m_seq_item.unpack_smi_seq_item();
    
            `uvm_info("DCE_SYSREQ_TXN", $psprintf("Sending attach and data:%0s", sysreq_seq.m_seq_item.convert2string()), UVM_LOW)
            sysreq_seq.return_response(m_smi_tx_port);
                
            attached_agent_queue.push_back(addrMgrConst::get_aiu_funitid(agent_id));
            m_phase.drop_objection(m_smi_tx_port, "sysreq");
            sysreq_inflight.push_back(addrMgrConst::get_aiu_funitid(agent_id));
            attach_detach_s[addrMgrConst::get_aiu_funitid(agent_id)].put(1);
        end
    end
    else begin
        attach_detach_s[addrMgrConst::get_aiu_funitid(agent_id)].get(1);
        //if (sysreq_inflight.find with (item == addrMgrConst::get_aiu_funitid(agent_id)) != null) begin
        while(sysreq_inflight.size() != 0)
        begin
            #(<%=obj.Clocks[0].params.period%>ps * 20);
            try++;
        end
        //end else begin
        m_phase.raise_objection(m_smi_tx_port, "sysreq");

        sysreq_seq      = smi_seq::type_id::create("smi_sequence");
        sys_req_attach = smi_seq_item::type_id::create("smi_seq_item"); 
        sys_req_attach = new("sys_req_attach");

        sys_req_attach.construct_sysmsg(
                .smi_targ_ncore_unit_id (targ_id),
                .smi_src_ncore_unit_id  (agent_id),
                .smi_msg_type           (SYS_REQ),
                .smi_msg_id             (0),
                .smi_msg_tier           (0),
                .smi_steer              (0),
                .smi_msg_pri            (0),
                .smi_msg_qos            (0),
                .smi_rmsg_id            (0),
                .smi_msg_err            (0),
                .smi_cmstatus           (0),
                .smi_sysreq_op          (1),
                .smi_ndp_aux            (0)
            );
        sys_req_attach.pack_smi_seq_item();

        sysreq_seq.m_seq_item = sys_req_attach;
        sysreq_seq.m_seq_item.unpack_smi_seq_item();

        `uvm_info("DCE_SYSREQ_TXN", $psprintf("Sending attach and data:%0s", sysreq_seq.m_seq_item.convert2string()), UVM_LOW)
        sysreq_seq.return_response(m_smi_tx_port);

        attached_agent_queue.push_back(addrMgrConst::get_aiu_funitid(agent_id));
        m_phase.drop_objection(m_smi_tx_port, "sysreq");    
        sysreq_inflight.push_back(addrMgrConst::get_aiu_funitid(agent_id));
        attach_detach_s[addrMgrConst::get_aiu_funitid(agent_id)].put(1);
        //end
    end


endtask: send_sysreq_attach

//********************************************************

task dce_mst_base_seq::send_sysreq_detach(int agent_id = -1);
    ncore_cache_state_t cache_state;
    addr_width_t cache_line_address;
    smi_seq_item sys_req_detach;
    smi_seq      sysreq_seq;
    int index[$];
    int inflight_q[$];
    
    index = attached_agent_queue.find_index(item) with (item == addrMgrConst::get_aiu_funitid(agent_id));
    if(index.size() == 0)begin
        `uvm_error("DCE_MST_SEQ", $psprintf("send_sysreq_detach -- agent_id=%0h not found in attached_agent_queue", agent_id));
    end
    attach_detach_s[addrMgrConst::get_aiu_funitid(agent_id)].get(1);
    attached_agent_queue.delete(index[0]);
    if(m_scb == null) begin
        inflight_q = m_dce_cntr.m_inflight_txns.find_index(x) with (x.get_master_id() == agent_id && x.is_msgid_inuse());
        while(inflight_q.size() != 0)
        begin
            #(<%=obj.Clocks[0].params.period%>ps * 20);
            inflight_q = m_dce_cntr.m_inflight_txns.find_index(x) with (x.get_master_id() == agent_id && x.is_msgid_inuse());
        
        end
    end
    else begin
        inflight_q = m_dce_cntr.m_inflight_txns.find_index(x) with (x.get_master_id() == agent_id && x.is_msgid_inuse());
        while(inflight_q.size() != 0)
        begin
            #(<%=obj.Clocks[0].params.period%>ps * 20);
            inflight_q = m_dce_cntr.m_inflight_txns.find_index(x) with (x.get_master_id() == agent_id && x.is_msgid_inuse());
        
        end
            #(<%=obj.Clocks[0].params.period%>ps * 20);
        inflight_q = m_scb.m_dce_txnq.find_index(item) with (item.m_initcmdupd_req_pkt.smi_src_ncore_unit_id == addrMgrConst::get_aiu_funitid(agent_id) && item.m_attid_status != ATTID_IS_RELEASED);
        while(inflight_q.size() != 0)
        begin
            #(<%=obj.Clocks[0].params.period%>ps * 20);
            inflight_q = m_scb.m_dce_txnq.find_index(item) with (item.m_initcmdupd_req_pkt.smi_src_ncore_unit_id == addrMgrConst::get_aiu_funitid(agent_id) && item.m_attid_status != ATTID_IS_RELEASED);
        
        end
    end
    inflight_q = update_agentq.find_index(x) with (x == agent_id); 
    while(inflight_q.size() != 0)
    begin
        #(<%=obj.Clocks[0].params.period%>ps * 5);
        inflight_q = update_agentq.find_index(x) with (x == agent_id); 
    end
    while(m_dce_cntr.m_outstanding_addrq[agent_id].size() != 0)
    begin
        #(<%=obj.Clocks[0].params.period%>ps * 20);
    end
    m_dce_cntr.print_outstanding_addrq(agent_id);
    foreach(m_dce_cntr.m_cachelines_st[x]) begin
        cache_line_address = m_dce_cntr.m_cachelines_st[x].get_addr();
        cache_state = m_dce_cntr.get_cacheline_st(agent_id,cache_line_address);
        if(cache_state inside {UD, UDP, UC, UCE, SC}) begin
            m_dce_cntr.set_cacheline_st(agent_id, cache_line_address,IX);
        end
        else if(cache_state == SD)begin
            if(addrMgrConst::get_native_interface(agent_id) == addrMgrConst::IO_CACHE_AIU) begin
                send_directed_updreq_txn(agent_id, cache_line_address);
                //m_dce_cntr.set_cacheline_st(agent_id, cache_line_address,IX);
            end
            else
                send_directed_cmdreq_txn(agent_id, cache_line_address, eCmdWrBkFull);
            total_rsps_expected++;
        end
        else if(cache_state == IX) begin
        //need not do anything  
        end
        else
            `uvm_error("DCE_MST_DETACH_ERROR",$psprintf("Invalid cache state = %p",cache_state))    

    end
    if(m_scb == null) begin
        inflight_q = m_dce_cntr.m_inflight_txns.find_index(x) with (x.get_master_id() == agent_id && x.is_msgid_inuse());
        while(inflight_q.size() != 0)
        begin
            #100ns;
            inflight_q = m_dce_cntr.m_inflight_txns.find_index(x) with (x.get_master_id() == agent_id && x.is_msgid_inuse());
        
        end
    end
    else begin
        inflight_q = m_dce_cntr.m_inflight_txns.find_index(x) with (x.get_master_id() == agent_id && x.is_msgid_inuse());
        while(inflight_q.size() != 0)
        begin
            #100ns;
            inflight_q = m_dce_cntr.m_inflight_txns.find_index(x) with (x.get_master_id() == agent_id && x.is_msgid_inuse());
        
        end
        #(<%=obj.Clocks[0].params.period%>ps * 20);
        inflight_q = m_scb.m_dce_txnq.find_index(item) with (item.m_initcmdupd_req_pkt.smi_src_ncore_unit_id == addrMgrConst::get_aiu_funitid(agent_id) && item.m_attid_status != ATTID_IS_RELEASED);
        while(inflight_q.size() != 0)
        begin
            #100ns;
            inflight_q = m_scb.m_dce_txnq.find_index(item) with (item.m_initcmdupd_req_pkt.smi_src_ncore_unit_id == addrMgrConst::get_aiu_funitid(agent_id) && item.m_attid_status != ATTID_IS_RELEASED);
        
        end
    end

    m_phase.raise_objection(m_smi_tx_port, "sysreq");

    sysreq_seq      = smi_seq::type_id::create("smi_sequence");
    sys_req_detach = smi_seq_item::type_id::create("smi_seq_item"); 
    sys_req_detach = new("sys_req_detach");
    sys_req_detach.construct_sysmsg(
            .smi_targ_ncore_unit_id (addrMgrConst::get_dce_funitid(0)),
            .smi_src_ncore_unit_id  (addrMgrConst::get_aiu_funitid(agent_id)),
            .smi_msg_type           (SYS_REQ),
            .smi_msg_id             (0),
            .smi_msg_tier           (0),
            .smi_steer              (0),
            .smi_msg_pri            (0),
            .smi_msg_qos            (0),
            .smi_rmsg_id            (0),
            .smi_msg_err            (0),
            .smi_cmstatus           (0),
            .smi_sysreq_op          (2),
            .smi_ndp_aux            (0)
        );
    sys_req_detach.pack_smi_seq_item();
    sysreq_seq.m_seq_item = sys_req_detach;
    sysreq_seq.m_seq_item.unpack_smi_seq_item();
    `uvm_info("DCE_SYSREQ_TXN", $psprintf("Sending detach and data:%0s", sysreq_seq.m_seq_item.convert2string()), UVM_LOW)

    sysreq_seq.return_response(m_smi_tx_port);
    m_phase.drop_objection(m_smi_tx_port, "sysreq");
    sysreq_inflight.push_back(addrMgrConst::get_aiu_funitid(agent_id));
    attach_detach_s[addrMgrConst::get_aiu_funitid(agent_id)].put(1);

endtask: send_sysreq_detach
//*************************************************************************
task dce_mst_base_seq::send_sysreq_txns();
    
    int delay;
    int itr;
    int agent_id;
    int new_agent_id;
    int indexq[$];
    
    if ($test$plusargs("enable_attach_detach")) begin
        itr = $urandom_range(30,10);
        
        for(int i = 0; i < itr; i++) begin
            delay   = $urandom_range(5000, 1);
            do begin
                agent_id    = CACHING_AIU_FUNIT_IDS[$urandom_range(<%=obj.DceInfo[0].nCachingAgents%>-1,0)];
                #(<%=obj.Clocks[0].params.period%>ps * 100);
            end
            while(agent_id inside {sysreq_inflight});
            #(<%=obj.Clocks[0].params.period%>ps * delay);
            if(stop_attach_detach_flag == 1)
                break;
            indexq = attached_agent_queue.find_index(item) with (item == agent_id);
            if(indexq.size() == 1 && !($test$plusargs("exc_ops_only") || $test$plusargs("cacheable_master_ops_only"))) begin
                send_sysreq_detach(agent_id);       
            end
            else if(indexq.size() == 0) begin
                send_sysreq_attach(agent_id);       
            end
            else if($test$plusargs("exc_ops_only") || $test$plusargs("cacheable_master_ops_only")) begin
                if($test$plusargs("exc_ops_only")) begin
                    if(m_exc_masterq.size() > 1) begin
                        send_sysreq_detach(agent_id);
                    end
                    else begin
                        if(m_proxy_cache_agentq.size() != 0) begin
                            send_sysreq_detach(m_proxy_cache_agentq[$urandom_range(m_proxy_cache_agentq.size()-1,0)]);
                        end 
                    end
                end
                if($test$plusargs("cacheable_master_ops_only")) begin
                    if(attached_agent_queue.size() > 1) begin
                        send_sysreq_detach(agent_id);
                    end
                end 
            end
        end 
        
    end

endtask: send_sysreq_txns

//********************************************************
function void dce_mst_base_seq::assign_cmdmsg_fields( input bit [WSMIMSGID-1:0] msg_id, input addr_width_t addr, ref smi_seq_item seq_item);
  int discard;
  bit [WSMINCOREUNITID-1:0] targ_id;

  if (r_cmdupd_item.isUpdMsg()) begin

    if ($test$plusargs("wrong_updreq_target_id")) begin
      targ_id = (addrMgrConst::get_dce_funitid(0) ^ {WSMINCOREUNITID{1'b1}});
    end else begin
        //#Cover.DCE.UpdReq.TgtFUnitId
      targ_id = addrMgrConst::get_dce_funitid(0);
    end
    
    seq_item.construct_updmsg(
            .smi_targ_ncore_unit_id(targ_id),
            .smi_src_ncore_unit_id(r_aiu_funitid), //#Cover.DCE.CmdReq.SrcId
            .smi_msg_type(r_cmdupd_item.smi_msg_type),
            .smi_msg_id(msg_id),
            .smi_msg_tier(r_cmdupd_item.smi_msg_tier),
            .smi_steer(r_cmdupd_item.smi_steer),
            .smi_msg_pri(r_cmdupd_item.smi_msg_pri), 
            .smi_msg_qos('h0), //this is part of header. driven by legato. so ignore. 
            .smi_msg_err('h0),
            .smi_tm('h0),
            .smi_cmstatus(r_cmdupd_item.smi_cmstatus),
            .smi_addr(addr[addrMgrConst::ADDR_WIDTH - 1 : 0]),
            .smi_ns(addr[addrMgrConst::W_SEC_ADDR - 1]),
            .smi_qos(r_cmdupd_item.smi_qos)
        );


  end else begin 

        if ($test$plusargs("wrong_cmdreq_target_id")) begin
          targ_id = (addrMgrConst::get_dce_funitid(0) ^ {WSMINCOREUNITID{1'b1}});
        end else begin
          //#Cover.DCE.CmdReq.TgtFUnitId
          targ_id = addrMgrConst::get_dce_funitid(0);
        end
        
       `uvm_info(get_name(), $psprintf("[%-35s] (rPkChAgent: %1d) (rFunit: 0x%02h) (cmd: %25s) (msgId: 0x%02h) (chAgentQ: %0p)", "DceMstSeq-CmdInit", r_pk_ch_agent, r_aiu_funitid, r_cmdupd_item.type2cmdname(), msg_id, m_ch_agentq), UVM_HIGH);
        seq_item.construct_cmdmsg(
          .smi_targ_ncore_unit_id(targ_id),
          .smi_src_ncore_unit_id(r_aiu_funitid), //#Cover.DCE.CmdReq.SrcId
          .smi_msg_type(r_cmdupd_item.smi_msg_type),
          .smi_msg_id(msg_id),
          .smi_msg_tier(r_cmdupd_item.smi_msg_tier),
          .smi_steer(r_cmdupd_item.smi_steer),
          .smi_msg_pri(r_cmdupd_item.smi_msg_pri),
          .smi_msg_qos('h0), //this is part of header. driven by legato. so ignore. 
          .smi_msg_err(0),
          .smi_cmstatus('h0), //#Stimulus.DCE.CmdReq.Cmstatus
          .smi_addr(addr[addrMgrConst::ADDR_WIDTH - 1 : 0]),
          .smi_vz(r_cmdupd_item.smi_vz),
          .smi_ac(r_cmdupd_item.smi_ac),
          .smi_ca(r_cmdupd_item.smi_ca),
          .smi_ch('h1), //#Stimulus.DCE.CmdReq.CoherencyRequirement 
          .smi_st('h0), //#Stimulus.DCE.CmdReq.StorageType
          .smi_en(r_cmdupd_item.smi_en),
          .smi_es(r_cmdupd_item.smi_es),
          .smi_ns(addr[addrMgrConst::W_SEC_ADDR - 1]),
          .smi_pr(r_cmdupd_item.smi_pr),
          .smi_order(r_cmdupd_item.smi_order),
          .smi_lk(r_cmdupd_item.smi_lk),
          .smi_rl('b01), //#Stimulus.DCE.CmdReq.ResponseLevel
          .smi_tm(r_cmdupd_item.smi_tm),
          .smi_mpf1_stash_valid(r_cmdupd_item.smi_mpf1_stash_valid),
          .smi_mpf1_stash_nid(r_cmdupd_item.smi_mpf1_stash_nid),
          .smi_mpf1_argv(r_cmdupd_item.smi_mpf1_argv),  //#Stimulus.DCE.CmdReq.Mpf1 
          .smi_mpf1_burst_type(0),
          .smi_mpf1_alength(0),
          .smi_mpf1_asize(0),
          .smi_mpf1_awunique(r_cmdupd_item.smi_mpf1_awunique),
          .smi_mpf2_stash_valid(r_cmdupd_item.smi_mpf2_stash_valid),
          .smi_mpf2_stash_lpid(0),
          .smi_mpf2_flowid_valid(r_cmdupd_item.smi_mpf2_flowid_valid),
          .smi_mpf2_flowid(r_cmdupd_item.smi_mpf2_flowid),
          .smi_size(r_cmdupd_item.smi_size),
          .smi_intfsize(r_cmdupd_item.smi_intfsize),
          .smi_dest_id(addrMgrConst::map_addr2dmi_or_dii(addr[addrMgrConst::ADDR_WIDTH - 1 : 0], discard)), //#Stimulus.DCE.CmdReq.DId
          .smi_tof(r_cmdupd_item.smi_tof),
          .smi_qos(r_cmdupd_item.smi_qos), 
          .smi_ndp_aux(r_cmdupd_item.smi_ndp_aux)
        );
  end
endfunction: assign_cmdmsg_fields

//********************************************************
function bit dce_mst_base_seq::is_master_in_legal_state( int agentid, addr_width_t addr);
    bit legal = 1;
    addr_width_t cacheline_addr = addr & bit_mask_const;

    //***************************************************
    // CHI-B Table 4-13, 4-14 indicates  
    //   --> initial cache state for Stashing Reads and Writes is IX. dce bfm allows initial state SC, UC, UD as well since they could silently go to IX at master
    //***************************************************
    case (r_cmdupd_item.smi_msg_type)
        //RdCln is not initiated by proxyCache
        //RdCln can only be initiated from CHI-A/CHI-B with IX,UCE initial states
        //RdCln can by initiated from ACE with any initial states.
        CMD_RD_CLN:     if (    !(m_dce_cntr.get_cacheline_st(agentid, cacheline_addr) inside {IX, UCE}) 
                             && (addrMgrConst::get_native_interface(agentid) inside {addrMgrConst::CHI_A_AIU, addrMgrConst::CHI_B_AIU}))
                        legal = 0;

                        //ReadOnce can only be initiated from IX state of a IOAIU w/ proxyCache
        CMD_RD_NITC:    if (   ((m_dce_cntr.get_cacheline_st(agentid, cacheline_addr) != IX) && (addrMgrConst::get_native_interface(agentid) == addrMgrConst::IO_CACHE_AIU))
                                    //ReadOnce cannot be initiated from SD state of a CHI master
                            || ((m_dce_cntr.get_cacheline_st(agentid, cacheline_addr) == SD) && (r_cmdupd_item.smi_tof == 1)))
                                legal = 0;
        CMD_RD_NITC_CLN_INV,
        CMD_RD_NITC_MK_INV: if (   (addrMgrConst::get_native_interface(agentid) inside {addrMgrConst::IO_CACHE_AIU, addrMgrConst::ACE_AIU})  //Should not be initiated by ACE or IOAIU w/ proxy cache
                                || (m_dce_cntr.get_cacheline_st(agentid, cacheline_addr) == SD))//master initial state cannot be SD
                                legal = 0;

        CMD_WR_UNQ_FULL,
        CMD_WR_UNQ_PTL,
        CMD_EVICT,
        CMD_LD_CCH_SH,
        CMD_LD_CCH_UNQ,
        CMD_WR_STSH_FULL,
        CMD_WR_STSH_PTL:    if (m_dce_cntr.get_cacheline_st(agentid, cacheline_addr) inside {SD})
                                legal = 0;

        //Table 4-13 Cache state transitions at the Requester for Dataless request transactions
        //ClnShared and CleanSharedPersist should always be issued from either Clean or Invalid requestor initial state.
        CMD_CLN_VLD,
        CMD_CLN_SH_PER:     if (m_dce_cntr.get_cacheline_st(agentid, cacheline_addr) inside {SD, UD})
                                legal = 0;

        CMD_WR_BK_PTL,
        CMD_WR_EVICT:       if (m_dce_cntr.get_cacheline_st(agentid, cacheline_addr) inside {IX, SC, SD})
                                legal = 0;
        CMD_WR_BK_FULL,
        CMD_WR_CLN_FULL:    if (m_dce_cntr.get_cacheline_st(agentid, cacheline_addr) inside {IX, SC}) 
                                legal = 0;
    
        //ARM CHI-A Table 4-10 Requestor cache state transitions for write request transitions 
        CMD_WR_CLN_PTL:     if (!(m_dce_cntr.get_cacheline_st(agentid, cacheline_addr) inside {UDP, IX})) begin
                                legal = 0;
                            end
    endcase
    
    return legal; 

endfunction: is_master_in_legal_state

//*********************************************************
// Invoke scrub routine
//*********************************************************
task dce_mst_base_seq::invoke_scrub_routine();
    int delay, idx;
    
    m_phase.raise_objection(this, "scrub_routine");
    
    delay = $urandom_range(100, 10);
    #(<%=obj.Clocks[0].params.period%>ps * delay); //wait for random cycles

    while (    (m_cmdupdreqs_issued != (m_unit_args.k_num_coh_cmds.get_value() + m_unit_args.k_num_upd_cmds.get_value()))
            || ((m_scb.num_coh_reqs + m_scb.num_upd_reqs) != (m_unit_args.k_num_coh_cmds.get_value() + m_unit_args.k_num_upd_cmds.get_value()))
            || (m_scb.m_dce_txnq.size() > 0)) begin
        #<%=obj.Clocks[0].params.period%>ps;
        //`uvm_info("DCE_MST_BASE_SEQ", $psprintf("scrub routine current stats m_cmdupdreqs_issued--%0d num_coh_reqs--%0d num_upd_reqs--%0d", m_cmdupdreqs_issued, m_unit_args.k_num_coh_cmds.get_value(), m_unit_args.k_num_upd_cmds.get_value()), UVM_LOW)
    end
    
    delay = $urandom_range(100, 10);
    #(<%=obj.Clocks[0].params.period%>ps * delay); //wait for random cycles

    `uvm_info("DCE_MST_BASE_SEQ", $psprintf(" print cache model before initiating scrub routine num_address:%0d", m_dce_cntr.m_cachelines_st.size()), UVM_LOW)
    m_dce_cntr.print_cache_model(1);

    //#Check.DCE.ScrubRoutine 
    fork
    foreach(m_dce_cntr.m_cachelines_st[i]) begin
        do
        begin
            populate_available_agentsq();
            #(<%=obj.Clocks[0].params.period%>ps * 10);
        end
        while ((m_ch_agentq.size() == 0) && (m_nc_agentq.size() == 0));

        if (m_ch_agentq.size() > 0) begin
            idx = $urandom_range(m_ch_agentq.size() - 1);
            send_directed_cmdreq_txn(m_ch_agentq[idx], m_dce_cntr.m_cachelines_st[i].get_addr(), eCmdRdVld);
        end else if (m_nc_agentq.size() > 0) begin 
            idx = $urandom_range(m_nc_agentq.size() - 1);
            send_directed_cmdreq_txn(m_nc_agentq[idx], m_dce_cntr.m_cachelines_st[i].get_addr(), eCmdRdNITC);
        end
        //`uvm_info("DCE_MST_BASE_SEQ", $psprintf("Sent scrub routine txn:%0d", i+1), UVM_LOW)
        -> e_scrub_routine;
    end
    begin
        @(e_scrub_routine);
        receive_cmdupdrsp_txns(m_dce_cntr.m_cachelines_st.size());
    end
    join_any

    m_phase.drop_objection(this, "scrub_routine");

endtask: invoke_scrub_routine
//*********************************************************
//  Initialize addressq
//*********************************************************
task dce_mst_base_seq::populate_unique_addrq();
    addr_width_t addr, tmp_addr;
    addr_width_t tmp_addrq[$];
    int addr_loaded = 0;
    int max_num_addr = 0;
    int num_addr;
    string s;
    bit [addrMgrConst::WSFSETIDX-1:0] set_addrq[int][addrMgrConst::NUM_SF][$]; //mem_region_idx --> [sfid][set_addr]
    int max_num_setaddr;
    bit already_present;
    int picked_setaddrq_idx;
    int dmi_id;
    int mid;
    int itr = 0;
    int i = 0;
    int ign;
    bit [addrMgrConst::WSFSETIDX-1:0] set_index_bits;
    bit [addrMgrConst::WCACHE_OFFSET-1:0] block_offset_mask = 2 ** addrMgrConst::WCACHE_OFFSET - 1;
    bit [addrMgrConst::WCACHE_OFFSET-1:0] block_offset;  
    bit [addrMgrConst::WCACHE_OFFSET:0] new_block_offset;
    int dmiid_queue[$];
    int discard;
    int idxq[$];

    if ($test$plusargs("dce_addr_aliasing_seq")) begin
        int loop_count = 0;
        int itr;
        int midq[$];
        m_dce_cntr.m_unq_addrq.delete();
        for(int i =0; i < addrMgrConst::snoop_filters_info[0].num_ways; i++) begin
            do begin
                loop_count++;
                if(loop_count == 8000) begin
                    #<%=obj.Clocks[0].params.period%>ps; //add a cycle delay to avoid hitting [ADDR MGR] Hitting possible 0-time infinite loop since we tried to call gen_coh_addr 10000 times in the same cycle.
                    itr++;
                    loop_count = 0;
                end
                addr = m_addr_mgr.gen_coh_addr(addrMgrConst::get_dce_funitid(0), 1);
                if(itr == 20)
                    `uvm_error("DCE_MST_ALIASING", $psprintf("Known fail could not get set 0 after so many tries"))
            end
            while(addrMgrConst::get_sf_set_index(0, addr) != 0);
            void'(addrMgrConst::map_addr2dmi_or_dii(addr[addrMgrConst::ADDR_WIDTH - 1 : 0], mid));
            
            if(addr inside {m_dce_cntr.m_unq_addrq})
                i = i - 1;
            else begin
                for(set_index_bits = 0 ; set_index_bits < addrMgrConst::snoop_filters_info[0].num_sets ; set_index_bits++) begin
                    do 
                    begin
                    if(mid == -1) begin
                            addr = m_addr_mgr.gen_coh_addr(addrMgrConst::get_dce_funitid(0), 1);
                    end
                    foreach (addrMgrConst::sf_set_sel[0].pri_bits[idx]) begin
                        addr[addrMgrConst::sf_set_sel[0].pri_bits[idx]] = set_index_bits[idx];
                    end
                    void'(addrMgrConst::map_addr2dmi_or_dii(addr[addrMgrConst::ADDR_WIDTH - 1 : 0], mid));
                    end
                    while(mid == -1);
                    if(addrMgrConst::get_sf_set_index(0, addr) == set_index_bits) begin
                        m_dce_cntr.load_cacheline(addr);
                        m_dce_cntr.m_unq_addrq.push_back(addr);
                    end
                    else
                        `uvm_error("ADDR_GEN_ERROR", $psprintf("expected set index: %p, actual set index: %p",set_index_bits,addrMgrConst::get_sf_set_index(0, addr)))
                end //sets for loop
            end // else end
        end //ways for loop
         // debug 
        foreach(m_dce_cntr.m_unq_addrq[idx])
    //  `uvm_info("DCE_MST_Debug", $psprintf("set index value from addr: %p and addr: %p", addrMgrConst::get_sf_set_index(0, m_dce_cntr.m_unq_addrq[idx]),m_dce_cntr.m_unq_addrq[idx]),UVM_LOW) 
        
        return;
        `uvm_info("DCE_MST_SEQ","Finished generating address for address aliasing test", UVM_MEDIUM) 
        
    end // dce_addr_aliasing_seq if end


    if ($test$plusargs("dce_fix_index")) begin
      m_addr_mgr.set_dce_sf_fix_index_in_user_addrq(addrMgrConst::get_dce_funitid(0), user_addrq, ign);
      `uvm_info(get_full_name(), $sformatf("Address queue Size:%0d : %0p", user_addrq.size(), user_addrq), UVM_NONE)
    end

    if ($test$plusargs("single_step")) begin
        max_num_addr = 1;
        m_unit_args.k_no_addr_conflicts.set_value(0);
    end else begin 
        if (m_unit_args.k_no_addr_conflicts.get_value()) begin
            max_num_addr = m_unit_args.k_num_coh_cmds.get_value();
        end else begin
            max_num_addr = m_unit_args.k_max_num_addr.get_value();
        end 
        max_num_setaddr = m_unit_args.k_max_num_setaddr.get_value();
    end 
    `uvm_info("DCE_MST_BASE_SEQ", $psprintf("fn:initialize_inuse_addresses Start --> no_addr_conflict:%0d max_num_addr:%0d num_setaddr:%0d num_coh_cmds:%0d num_upd_cmds:%0d useraddrq.size:%0d", m_unit_args.k_no_addr_conflicts.get_value(), max_num_addr, max_num_setaddr, m_unit_args.k_num_coh_cmds.get_value(), m_unit_args.k_num_upd_cmds.get_value(), user_addrq.size()), UVM_MEDIUM)


    //initialize all to be used address only for addr_conflicts test. For no_addr_conflicts test generate addresses on the fly in fn: initiate_ntxns_smi_msgs
    if (m_unit_args.k_no_addr_conflicts.get_value() == 0) begin

        if($test$plusargs("user_addr_for_csr") ||
           $test$plusargs("user_addrq")) begin
            max_num_addr = user_addrq.size();
        end 

        while (addr_loaded != max_num_addr) begin

            if( $test$plusargs("user_addr_for_csr") || 
                $test$plusargs("user_addrq")) begin
                addr = user_addrq.pop_front();
            end else begin //normal test

                if (itr == 8999) begin
                    max_num_setaddr++;
                    itr = 0;
                    `uvm_info("DCE_MST_SEQ", $psprintf("incremented max_num_setaddr:%0d after 9000 tries to create a new address in existing sets", max_num_setaddr), UVM_MEDIUM);
                    #<%=obj.Clocks[0].params.period%>ps; //add a cycle delay to avoid hitting [ADDR MGR] Hitting possible 0-time infinite loop since we tried to call gen_coh_addr 10000 times in the same cycle.

                    //*****************debug -- to know what set_addr were picked till now**************//
                    s = "";
                    foreach(set_addrq[mid]) begin
                        $sformat(s, "%0s\nmid:%0d\t", s, mid);
                        foreach(set_addrq[mid][i]) begin
                            $sformat(s, "%0s SFID:%0d ", s, i);
                            foreach(set_addrq[mid][i][j]) begin
                                $sformat(s, "%0s 0x%0h ", s, set_addrq[mid][i][j]);
                            end
                        end
                    end
                    $sformat(s, "%s\n", s);

                    //`uvm_info("DCE_MST_SEQ", $psprintf("%0s", s), UVM_LOW);
                    s = "";
                    //*****************debug -- to know what set_addr were picked till now**************//
                end

                addr = m_addr_mgr.gen_coh_addr(addrMgrConst::get_dce_funitid(0), 1);
                void'(addrMgrConst::map_addr2dmi_or_dii(addr[addrMgrConst::ADDR_WIDTH - 1 : 0], mid));
                //`uvm_info("DCE_MST_SEQ", $psprintf("===itr:%0d addr_loaded:%0d=== gen_coh_addr:%p, set_addr[sfid:0]:%p", itr, addr_loaded, addr, addrMgrConst::get_sf_set_index(0, addr)), UVM_LOW);
                if (set_addrq.exists(mid) == 0) begin //mid was accessed first time
                    //`uvm_info("DCE_MST_SEQ", $psprintf("===itr:%0d addr_loaded:%0d=== mid:%0d accessed 1st time", itr, addr_loaded, mid), UVM_LOW);
                    for (int sidx = 0; sidx < addrMgrConst::NUM_SF; sidx++) begin
                        set_addrq[mid][sidx] = {};
                        set_addrq[mid][sidx].push_back(addrMgrConst::get_sf_set_index(sidx, addr));
                    end
                end else begin //mid exists  
                    //`uvm_info("DCE_MST_SEQ", $psprintf("===itr:%0d addr_loaded:%0d=== mid:%0d already present", itr, addr_loaded, mid), UVM_LOW);
                    if (set_addrq[mid][0].size() < max_num_setaddr) begin
                        //addr = m_addr_mgr.gen_coh_addr(addrMgrConst::get_dce_funitid(0), 1);
                        already_present = 0;
                        for (int sidx = 0; sidx < addrMgrConst::NUM_SF; sidx++) begin
                            if (addrMgrConst::get_sf_set_index(sidx, addr) inside {set_addrq[mid][sidx]}) begin
                                already_present = 1;
                                break;
                            end
                        end
                        if (already_present == 0) begin 
                            for (int sidx = 0; sidx < addrMgrConst::NUM_SF; sidx++)
                                set_addrq[mid][sidx].push_back(addrMgrConst::get_sf_set_index(sidx, addr));
                        end
                    end else begin //set_addrq[mid][0].size() == max_num_setaddr
                        s = "";
                        foreach(set_addrq[mid]) begin
                            $sformat(s, "%0s\nmid:%0d\t", s, mid);
                            foreach(set_addrq[mid][i]) begin
                                $sformat(s, "%0s SFID:%0d ", s, i);
                                foreach(set_addrq[mid][i][j]) begin
                                    $sformat(s, "%0s 0x%0h ", s, set_addrq[mid][i][j]);
                                end
                            end
                        end
                        `uvm_info("DCE_MST_SEQ", $psprintf("%0s", s), UVM_MEDIUM);

                        //pick a random setaddr from set_addrq and manipulate the generated addr so that the set_addr == set_addr from the setaddrq
                        picked_setaddrq_idx = $urandom_range(set_addrq[mid][0].size() - 1);
                        for (int sidx = 0; sidx < addrMgrConst::NUM_SF; sidx++) begin
                            //`uvm_info("DCE_MST_SEQ", $psprintf("===itr:%0d num_addr_loaded:%0d=== picked_setaddrq_idx:%0d picked_setaddr_sf0:0x%0h sf_set_sel[%0d].pri_bits.size: %0d addr:0x%0h", itr, addr_loaded, picked_setaddrq_idx, set_addrq[mid][0][picked_setaddrq_idx], sidx, addrMgrConst::sf_set_sel[sidx].pri_bits.size(), addr), UVM_LOW);
                            foreach (addrMgrConst::sf_set_sel[sidx].pri_bits[idx]) begin
                                addr[addrMgrConst::sf_set_sel[sidx].pri_bits[idx]] = set_addrq[mid][sidx][picked_setaddrq_idx][idx];
                                //`uvm_info("DCE_MST_SEQ", $psprintf("sidx:%0d pri_bit:%0d pri_bit_val:%0d", sidx, addrMgrConst::sf_set_sel[sidx].pri_bits[idx], set_addrq[mid][sidx][picked_setaddrq_idx][idx]), UVM_LOW)
                            end 
                        //`uvm_info("DCE_MST_SEQ", $psprintf("===itr:%0d num_addr_loaded:%0d=== updated addr for SF:%0d -- 0x%0h", itr, addr_loaded, sidx, addr), UVM_LOW);
                        end
                        for (int sidx = 0; sidx < addrMgrConst::NUM_SF; sidx++) begin
                            if (addrMgrConst::get_sf_set_index(sidx, addr) != set_addrq[mid][sidx][picked_setaddrq_idx]) begin 
                                `uvm_error("DCE_MST_SEQ", $psprintf("updated addr:0x%0h, SF%0d set_addr:0x%0h picked_setaddr:0x%0h", addr, sidx, addrMgrConst::get_sf_set_index(sidx, addr),set_addrq[mid][sidx][picked_setaddrq_idx]));
                            end
                        end 
                    //`uvm_info("DCE_MST_SEQ", $psprintf("===itr:%0d addr_loaded:%0d=== updated addr:0x%0h successfully, set_addr_0:0x%0h", itr, addr_loaded, addr, addrMgrConst::get_sf_set_index(0, addr)), UVM_LOW);
                    end //set_addrq[mid][0].size() == max_num_setaddr
                end //mid exists
                itr++;
            end //normal test
            //void'(addrMgrConst::map_addr2dmi_or_dii(addr[addrMgrConst::ADDR_WIDTH - 1 : 0], mid));
            cacheline_addr = addr & bit_mask_const;
            if ((cacheline_addr inside {m_dce_cntr.m_unq_cacheline_addrq}) == 0) begin
                m_dce_cntr.load_cacheline(addr);
                m_dce_cntr.m_unq_cacheline_addrq.push_back(cacheline_addr);
                m_dce_cntr.m_unq_addrq.push_back(addr);
                addr_loaded++;
                if (m_dce_cntr.m_unq_addrq_per_sfsetaddr.exists(addrMgrConst::get_sf_set_index(0, addr))) begin 
                    m_dce_cntr.m_unq_addrq_per_sfsetaddr[addrMgrConst::get_sf_set_index(0, addr)].push_back(addr);
                end else begin 
                    m_dce_cntr.m_unq_addrq_per_sfsetaddr[addrMgrConst::get_sf_set_index(0, addr)] = {};
                    m_dce_cntr.m_unq_addrq_per_sfsetaddr[addrMgrConst::get_sf_set_index(0, addr)].push_back(addr);
                end
            end
        end //while addr_loaded == max_num_addr
        //all addresses are populated into m_unq_addrq and m_unq_addrq_per_sfsetaddr

        s = "";
        foreach(set_addrq[mid]) begin
            $sformat(s, "%0s\nmid:%0d\t", s, mid);
            foreach(set_addrq[mid][i]) begin
                $sformat(s, "%0s SFID:%0d ", s, i);
                foreach(set_addrq[mid][i][j]) begin
                    $sformat(s, "%0s 0x%0h ", s, set_addrq[mid][i][j]);
                end
            end
        end
        $sformat(s, "%s", s);
        //`uvm_info("DCE_MST_SEQ", $psprintf("%0s", s), UVM_LOW);

        s = "";
        foreach(m_dce_cntr.m_unq_addrq_per_sfsetaddr[i]) begin
            $sformat(s, "%0s \nset_addr:0x%0h (num_addr:%0d) --> ", s, i, m_dce_cntr.m_unq_addrq_per_sfsetaddr[i].size());
            foreach(m_dce_cntr.m_unq_addrq_per_sfsetaddr[i][j]) begin
                $sformat(s, "%0s 0x%0h ", s, m_dce_cntr.m_unq_addrq_per_sfsetaddr[i][j]);
            end
        end
        `uvm_info("DCE_MST_SEQ", $psprintf("%0s", s), UVM_MEDIUM);

        addr_pool_size = 0;
        foreach (m_dce_cntr.m_unq_addrq_per_sfsetaddr[i]) begin 
            if (m_dce_cntr.m_unq_addrq_per_sfsetaddr[i].size() > addr_pool_size) begin 
                addr_pool_size = m_dce_cntr.m_unq_addrq_per_sfsetaddr[i].size();
                sf_setaddr     = i; 
            end 
        end
        `uvm_info("DCE MST SEQ", $psprintf("single_sfset -- sf_setaddr:0x%0h addr_pool_size:%0d", sf_setaddr, addr_pool_size), UVM_MEDIUM)

    end //if no_addr_conflicts == 0
    
    `uvm_info("DCE MST SEQ", $psprintf("unq_addrq_size:%0d", m_dce_cntr.m_unq_addrq.size()), UVM_MEDIUM)
    if ($test$plusargs("en_multiple_addr_within_cacheline")) begin
        foreach (m_dce_cntr.m_unq_addrq[i]) begin 
            block_offset = m_dce_cntr.m_unq_addrq[i] & block_offset_mask;
            itr = 0;
            num_addr = $urandom_range(1,3);
            //`uvm_info("DCE_MST_SEQ", $psprintf("addr:0x%0h block_offset:%0h block_offset_mask:%0h num_addr:%0d", m_dce_cntr.m_unq_addrq[i], block_offset, block_offset_mask, num_addr), UVM_LOW);
            while (itr < num_addr) begin 
                new_block_offset = $urandom_range(block_offset_mask);   
                if (new_block_offset != block_offset) begin
                    tmp_addr = ((m_dce_cntr.m_unq_addrq[i] >> addrMgrConst::WCACHE_OFFSET) << addrMgrConst::WCACHE_OFFSET) + new_block_offset;
                    tmp_addrq.push_back(tmp_addr);
                    //`uvm_info("DCE_MST_SEQ", $psprintf("new_block_offset:0x%0h tmp_addr:0x%0h", new_block_offset, tmp_addr), UVM_LOW);
                    itr = itr + 1;
                end
            end
            //`uvm_info("DCE_MST_SEQ", $psprintf("tmp_addrq.size:%0d", tmp_addrq.size()), UVM_LOW);
            //`uvm_error("DCE_MST_SEQ", "Error out intentionally");
    //      while (new_block_offset <= block_offset_mask) begin 
    //          if (new_block_offset != block_offset) begin
    //              tmp_addr = ((m_dce_cntr.m_unq_addrq[i] >> addrMgrConst::WCACHE_OFFSET) << addrMgrConst::WCACHE_OFFSET) + new_block_offset;
    //              tmp_addrq.push_back(tmp_addr);
    //              //`uvm_info("DCE_MST_SEQ", $psprintf("new_block_offset:0x%0h tmp_addr:0x%0h", new_block_offset, tmp_addr), UVM_LOW);
    //          end
    //          new_block_offset = new_block_offset + 1;
    //      end 
        end 
        foreach(tmp_addrq[i]) begin
            m_dce_cntr.m_unq_addrq.push_back(tmp_addrq[i]);
        end
    end
    if($test$plusargs("connectivity_test")) begin
        foreach(m_dce_cntr.m_unq_addrq[i]) begin
            dmi_id = addrMgrConst::map_addr2dmi_or_dii(m_dce_cntr.m_unq_addrq[i], discard);
            idxq = dmiid_queue.find_index(item) with (item == dmi_id);
            if(idxq.size() == 0)
                dmiid_queue.push_back(dmi_id);
        end
        if(dmiid_queue.size() < <%=obj.DceInfo[0].nDmis%>) begin
            foreach(DMI_FUNIT_IDS[x]) begin
                if(DMI_FUNIT_IDS[x] inside {dmiid_queue} && DMI_CONNECTIVITY[x] == 0)
                    return;
            end
            foreach(DMI_FUNIT_IDS[x]) begin
                if(DMI_FUNIT_IDS[x] inside {dmiid_queue} && DMI_CONNECTIVITY[x] == 1) begin
                    DMI_CONNECTIVITY[x] = 0;
                    return;
                end
            end
            
        end
    end
        
    `uvm_info("DCE_MST_BASE_SEQ", $psprintf("fn:initialize_inuse_addresses End --> max_num_addr:%0d num_setaddr:%0d num_coh_cmds:%0d num_upd_cmds:%0d unq_addrq_size:%0d", max_num_addr, max_num_setaddr, m_unit_args.k_num_coh_cmds.get_value(), m_unit_args.k_num_upd_cmds.get_value(), m_dce_cntr.m_unq_addrq.size()), UVM_MEDIUM)


endtask: populate_unique_addrq
//*********************************************************
task dce_mst_base_seq::wait_for_sysrsp();//Adding this task to wait for all the agents to be attached before Starting to send CMDs/UPDs

        if($test$plusargs("wrong_cmdreq_target_id") || $test$plusargs("wrong_updreq_target_id") || $test$plusargs("inject_smi_uncorr_error")) begin
            #(<%=obj.Clocks[0].params.period%>ps * 300);
            sysreq_inflight.delete();
            return;
        end
        #(<%=obj.Clocks[0].params.period%>ps * 10);
            while (sysreq_inflight.size() > 0) begin
                #<%=obj.Clocks[0].params.period%>ps;
            end
    
endtask: wait_for_sysrsp
