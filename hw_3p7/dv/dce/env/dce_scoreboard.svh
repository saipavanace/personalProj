////////////////////////////////////////////////////////////////////////////////
// 
// Author       : Hema Sajja 
// Purpose      : DCE SCOREBOARD 
// Revision     : Initial
//
// [ Browse code using this sections ]
//
// [ Notes ]
// Section1 : SCB Top and UVM Default Methods
// Section2 : SMI Write function
// Section3 : SMI Cmd,Snp,Str,Mrd process functions 
// Section4 : Utility functions 
//
////////////////////////////////////////////////////////////////////////////////

import uvm_pkg::*;
`include "uvm_macros.svh"

`uvm_analysis_imp_decl(_smi_port)
`uvm_analysis_imp_decl(_dm_port)
`uvm_analysis_imp_decl(_tm_port)
`uvm_analysis_imp_decl(_evt_port)
`uvm_analysis_imp_decl(_sb_cmdrsp_port)
`uvm_analysis_imp_decl(_sb_syscorsp_port)
`uvm_analysis_imp_decl(_conc_mux_cmdreq_port)
`uvm_analysis_imp_decl(_arb_cmdreq_port)
`uvm_analysis_imp_decl(_cycle_tracker_port)
//Q-channel port
`uvm_analysis_imp_decl(_q_chnl)

// sf monitor port
<% 
var sf_cnt  = 0;
var plru_en = 0;   
obj.SnoopFilterInfo.forEach(function(bundle,indx, array) {
    sf_cnt++;
    if(bundle.RepPolicy == "PLRU") {
        plru_en = 1;
    }
});%>
<% for(var x = 0; x < sf_cnt; x++){ %>
<% if (obj.testBench == "dce") { %>
`uvm_analysis_imp_decl(_sf_port_in_<%=x%>)
<% if(plru_en == 1) { %>
`uvm_analysis_imp_decl(_plru_mem_wr_port_in_<%=x%>)
<% } %>
<% } %>
<% } %>

////////////////////////////////////////////////////////////////////////////////
// Section1:  SCB TOP and UVM Default Methods
//
//
////////////////////////////////////////////////////////////////////////////////
 <% if(obj.COVER_ON) { %>
    typedef class dce_coverage;
 <% } %>
typedef class dce_env_config;

typedef struct {
    bit                                 mon_vld;
    bit [addrMgrConst::WCACHE_TAG:0]    tagged_addr; //include NS bit on MSB
    bit [addrMgrConst::MAX_PROCS-1:0]   tagged_mon[int];
} tagged_monitor_s;

typedef struct {
    int min;
    int max;
    int avg;
    int sum;
} latency_s;

typedef struct {
    bit [<%=obj.DceInfo[obj.Id].wFUnitId%>-1:0]   dmi_funit_id;
    bit [<%=obj.Widths.Concerto.Ndp.Body.wRBId%>-1:0] RBId_low;
    bit [<%=obj.Widths.Concerto.Ndp.Body.wRBId%>-1:0] RBId_high;
} rbid_s;

parameter int CLK_PERIOD = <%=obj.Clocks[0].params.period%>;
parameter int RBID_RANGE_L = <%=obj.Id%> * <%=obj.DceInfo[obj.Id].nRbsPerDmi%>;
parameter int RBID_RANGE_U = (<%=obj.Id%> * <%=obj.DceInfo[obj.Id].nRbsPerDmi%>) + (<%=obj.DceInfo[obj.Id].nRbsPerDmi%> - 1);


class dce_scb extends uvm_scoreboard;

    `uvm_component_param_utils(dce_scb)
    // perf monitor stall Interface
    virtual <%=obj.BlockId%>_stall_if sb_stall_if;

    //SMI Analysis Port
    uvm_analysis_imp_smi_port #(smi_seq_item, dce_scb) m_smi_port;
    
    //Probe Analysis Ports
    uvm_analysis_imp_dm_port #(dm_seq_item, dce_scb) m_dm_port;
    uvm_analysis_imp_tm_port #(bit [WATTVEC-1:0], dce_scb) m_tm_port;
    uvm_analysis_imp_evt_port #(event_in_t, dce_scb) m_evt_port;
    uvm_analysis_imp_sb_cmdrsp_port #(sb_cmdrsp_s, dce_scb) m_sb_cmdrsp_port;
    uvm_analysis_imp_sb_syscorsp_port #(smi_ncore_unit_id_bit_t, dce_scb) m_sb_syscorsp_port;
    uvm_analysis_imp_conc_mux_cmdreq_port #(probe_cmdreq_s, dce_scb) m_conc_mux_cmdreq_port;
    uvm_analysis_imp_arb_cmdreq_port #(probe_cmdreq_s, dce_scb) m_arb_cmdreq_port;
    uvm_analysis_imp_cycle_tracker_port #(cycle_tracker_s, dce_scb) m_cycle_tracker_port;
    
    //Q-channel port
    uvm_analysis_imp_q_chnl #(q_chnl_seq_item , dce_scb) analysis_q_chnl_port;
    <% for(var x = 0; x < sf_cnt; x++){ %>
    <% if (obj.testBench == "dce") { %>
    uvm_analysis_imp_sf_port_in_<%=x%> #(snoop_filter_seq_item, dce_scb) m_sf_port_in_<%=x%>;
    <% if(plru_en == 1) { %>
    uvm_analysis_imp_plru_mem_wr_port_in_<%=x%> #(snoop_filter_seq_item, dce_scb) m_plru_mem_wr_port_in_<%=x%>;
    <%}%>
    <%}%>
    <%}%>

    //DCE inflight transactions Queue
    dce_scb_txn m_dce_txnq[$];
    dce_scb_txn deleted_recall_txnq[$];

    uvm_reg_data_t mirrored_value;
    uvm_reg  my_register; //vyshak

    int m_attids_in_use[$];
    int m_rbids_in_use[int][$];
    bit [WSMIADDR-1:0] csr_addr_overlap_recall_addr_q[$];
    bit [WSMIADDR-1:0] csr_addr_connectivity_recall_addr;
    //int m_available_credits[string];
    bit [WSMIADDR-1:0] deallocated_address; // Deallocated address to pass cmd in directed test

   // DCE inflight system event transactions
    dce_scb_txn m_dce_sys_txnq[$];
    bit event_disable;
    bit jump_phase;

    //RBIDs per DMI
    rbid_s rbid_range[<%=obj.DceInfo[obj.Id].nDceConnectedDmis%>-1:0];

    //Global dynamic handle for all smi  requests/responses
    smi_seq_item   m_smi_tx_cmdupdreq_pkt, m_smi_rx_cmdupdrsp_pkt;
    smi_seq_item   m_smi_rx_snpreq_pkt, m_smi_tx_snprsp_pkt;
    smi_seq_item   m_smi_rx_mrdreq_pkt, m_smi_tx_mrdrsp_pkt;
    smi_seq_item   m_smi_rx_strreq_pkt, m_smi_tx_strrsp_pkt;
    smi_seq_item   m_smi_rx_rbrreq_pkt, m_smi_tx_rbrrsp_pkt;
    smi_seq_item   m_smi_tx_rbureq_pkt, m_smi_rx_rbursp_pkt;
    smi_seq_item   m_smi_rx_sysreq_pkt, m_smi_tx_sysrsp_pkt; //SysEvent
    smi_seq_item   m_smi_tx_sysreq_pkt, m_smi_rx_sysrsp_pkt; //SysCo
    
    //Global dynamic handle for all dirm requests/responses.
    dm_seq_item m_dm_cohreq_pkt;
    dm_seq_item m_dm_tempreq_pkt;
    dm_seq_item m_dm_updreq_pkt;
    dm_seq_item m_dm_cmtreq_pkt;
    
    dm_seq_item m_dm_lkprsp_pkt;
    dm_seq_item m_dm_recrsp_pkt;
    dm_seq_item m_dm_rtyrsp_pkt;

    //dm_coh_req_pktq
    dm_seq_item m_dm_cohreq_pktq[$];
    dm_seq_item m_dm_updreq_pktq[$];
    
    //Ncore Credits
    dce_credits_check m_credits;

    //Handle for Directory Manager;
    directory_mgr m_dirm_mgr;

    // objection tracker
    bit m_obj_tracker[int];

    <%if (obj.testBench == "dce") {%>
    // plru check related items
    bit                   m_plru_en;
    bit                   m_disable_plru_check_conc13075[addrMgrConst::NUM_SF];
    plru_model_base       m_plru_model[addrMgrConst::NUM_SF];
    snoop_filter_seq_item m_obsv_sf_q[addrMgrConst::NUM_SF][int][$];
    <%}%>
    int                   m_plru_mem_wr_busy_tracker[addrMgrConst::NUM_SF][int][$];
    int                   m_plru_mem_wr_ahead_cnt[addrMgrConst::NUM_SF][int];
    int                   m_vbhit_way_busy[addrMgrConst::NUM_SF][int];
    int                   m_att_way_alloc_map[int];
    
    // SMI error injection statistics
    int  res_smi_corr_err   = 0;
    int  num_smi_corr_err   = 0;
    int  num_smi_uncorr_err = 0;
    int  num_smi_parity_err = 0;  // also uncorrectable

    realtime res_smi_pkt_time_old, res_smi_pkt_time_new;
    int res_mod_dp_corr_error;
    bit res_is_pre_err_pkt;

    event kill_test;
    uvm_event kill_test_1;
    uvm_event_pool ev_pool = uvm_event_pool::get_global_pool();
    uvm_event csr_test_time_out_recall_ev = ev_pool.get("csr_test_time_out_recall_ev");
    uvm_event ev_first_scb_txn = ev_pool.get("ev_first_scb_txn");
    bit [2:0] inj_cntl;

    //Track transactions
    int first_cmd_observed = 0;
    int num_txns;
    int num_coh_reqs;
    int num_upd_reqs;
    int num_rec_reqs;
    int num_snp_reqs;
    int num_dir_hit;
    int num_dir_miss;
    int num_addr_collisions;
    int num_snp_rsp_miss;
    int num_snp_rsp_owner_transfer;
    int src_ncore_unit_id[int];
    int cmd_type[eMsgCMD];
    int upd_type[eMsgUPD];
    int snp_latencyq[$];
    int rbrsv_latencyq[$];
    int rbrls_latencyq[$];
    int mrd_latencyq[$];
    int str_latencyq[$];
    int num_sysreq_attach;
    int num_sysreq_detach;
    
    //Event and SysCo transactions
    bit event_in_req_in_flight;
    bit event_in_req_edge;
    bit event_in_req_buffer;
    bit event_in_err;
    bit prot_timeout_err;

    bit [<%=obj.DceInfo[0].nAius%>-1:0] snoop_enable_reg;
    bit [<%=obj.DceInfo[0].nAius%>-1:0] snoop_enable_reg_prev;
    bit [<%=obj.DceInfo[0].nAius%>-1:0] snoop_enable_reg_sys_rsp;
    int snoop_count [<%=obj.DceInfo[0].nAius%>-1:0];
    int event_count [<%=obj.DceInfo[0].nAius%>-1:0];
    time latest_store_pass_time; //Adding this to fix race condition when req and store pass in same cycle

    //QOS related
    int m_qosEventCounter   = 0;
    int m_qosStarvationMode = 0;
    longint sb_entries_updated_cycle_count = 0;
    bit starvRequest_exists = 0;
    bit sb_empty;
    sb_cmdrsp_s sb_cmdrsp_captured;

    //latency
    latency_s snp, mrd, rbrsv, rbrls, str;

    //Enable-disable bits
    bit m_scb_en, m_cov_en;
    local bit m_checks_en;
    
    //controlled from test knobs
    bit m_vb_recovery_en;
    bit m_dm_output_chks_en;
    bit m_dv_rec_support_en;
    bit m_dv_snpreq_up_chks_en;
    bit m_dv_tgtid_chks_en;
    bit m_dm_dbg;
    smi_msg_id_bit_t smi_msg_id_cmdupd_req_tgt_id_err[smi_msg_id_bit_t];
    smi_msg_id_bit_t smi_msg_id_sys_req_tgt_id_err[smi_msg_id_bit_t];
    int attid_rbu_req_tgt_id_err[int];
    dce_env_config m_env_cfg;
    

    //Edge triggered Events
    event e_txn_comp;
    event e_smi_cmdupd_req, e_smi_cmdupd_rsp;
    event e_smi_snp_req, e_smi_snp_rsp;
    event e_smi_mrd_req, e_smi_mrd_rsp;
    event e_smi_str_req, e_smi_str_rsp;
    event e_smi_rbr_req, e_smi_rbr_rsp;
    event e_smi_rbu_req, e_smi_rbu_rsp;
    event e_smi_sys_event_in_req, e_smi_sys_event_rsp, e_sys_rsp_timeout_err;
    event e_smi_sys_co_req, e_smi_sys_co_rsp;
    event e_dm_cohreq, e_dm_updreq, e_dm_cmtreq, e_dm_tempreq;
    event e_dm_lkprsp, e_dm_recrsp, e_dm_rtyrsp;
    event e_attid_dealloc;
    event e_smi_sys_evt_err;

    bit garbage_dmiid = 0;
    bit clean_exit_due_to_wrong_targetid_SNPrsp = 0;
    bit clean_exit_due_to_wrong_targetid_RBrsp  = 0;
    bit clean_exit_due_to_wrong_targetid_MRDrsp = 0;
    bit clean_exit_due_to_wrong_targetid_STRrsp = 0;

    //exclusive monitor properties
    tagged_monitor_s m_tagged_mon[];
    bit [addrMgrConst::MAX_PROCS-1:0] m_basic_mon[int];

    //attvec alloc-dealloc tracker
    dce_scb_txn m_attvld_aa[int];
    bit [WATTVEC-1:0] m_attvld_vec_prev;

    //queue of all attid that are deallocated but txns not completed
    int m_deallocated_attidq[$];

    //For qos testing
    bit [WSMIMSGID-1:0] sb_cmdrsp_a[bit [WSMITGTID-1:0]][$];
    
    //updreq tracking
    dce_scb_txn m_updreq_txn;
    bit [WSMIADDR:0] m_updreq_aa[int][int];
    event upd_comp_e;
    
    //Veriable for latency measurement
    int latency_collection_snp_q[$];
    int latency_collection_rbr_q[$];
    int latency_collection_mrd_q[$];
    int latency_collection_str_q[$];
    int snp_min_latency[$];
    int snp_max_latency[$];
    int rbr_min_latency[$];
    int rbr_max_latency[$];
    int mrd_min_latency[$];
    int mrd_max_latency[$];
    int str_min_latency[$];
    int str_max_latency[$];
    int snp_latency_sum,snp_avg_latency;
    int rbr_latency_sum,rbr_avg_latency;
    int mrd_latency_sum,mrd_avg_latency;
    int str_latency_sum,str_avg_latency;
    int att_q_size = 0;

    // Need to assign them to json parameter
    int snp_exp_latency = 8;
    int str_exp_latency = 8;
    int mrd_exp_latency = 8;
    int rbr_exp_latency = 8;

    // CSR interface handle
    <%if (obj.testBench != "cust_tb") {%>
     virtual  <%=obj.BlockId%>_probe_if u_csr_probe_vif;
    <%}%>
    
    //RAL Model
    <% if((obj.testBench=='dce') && (obj.INHOUSE_APB_VIP) && 
    ((obj.instanceName) ? (obj.strRtlNamePrefix == obj.instanceName) : (obj.Id=="0")) || (obj.testBench == 'cust_tb'))  { %> 
    <%=obj.BlockId%>_concerto_register_map_pkg::ral_sys_ncore m_regs;
    <%} else if(obj.testBench == "fsys" || obj.testBench == "emu") { %>
    concerto_register_map_pkg::ral_sys_ncore m_regs;
    <% } %>

    <% if(obj.COVER_ON) { %>
    //Coverage collecter handle
    dce_coverage m_cov;
    <% } %>

    //UVM default Methods
    extern function      new(string name = "dce_scb", uvm_component parent = null);
    extern function void build_phase(uvm_phase phase);
    extern function void report_phase(uvm_phase phase);
    extern function void check_phase(uvm_phase phase);
    extern task          run_phase(uvm_phase phase);

    //Analysis Port Write Method
    extern function void write_smi_port(inout smi_seq_item rcvd_pkt);
    extern function void write_dm_port(dm_seq_item rcvd_pkt);
    extern function void write_tm_port(bit [WATTVEC-1:0] attvld_vec_i);
    extern function void write_evt_port(event_in_t sys_event);
    extern function void write_sb_cmdrsp_port(sb_cmdrsp_s sb_cmdrsp);
    extern function void write_sb_syscorsp_port(smi_ncore_unit_id_bit_t syscorsp_trgtid);
    extern function void write_conc_mux_cmdreq_port(probe_cmdreq_s conc_mux_cmdreq);
    extern function void write_arb_cmdreq_port(probe_cmdreq_s arb_cmdreq);
    extern function void write_cycle_tracker_port(cycle_tracker_s cycle_tracker);
    extern function void write_q_chnl(q_chnl_seq_item m_pkt) ;

    <% if (obj.testBench == "dce") { %>
    extern function void check_sf_obsv_item(int rw, int sfid, int way, longint addr, int clear_vbhit_busy, string signature="");
    extern function void alloc_plru_state(int sfid, int way, longint addr, longint busy_ways, longint alloc_ways, string signature="");
    extern function void update_plru_state(int sfid, int way, longint addr, string signature="");
    <% for(var x = 0; x < sf_cnt; x++) { %>
    extern function void write_sf_port_in_<%=x%> (snoop_filter_seq_item sf_item);
    <% if(plru_en == 1) { %>
    extern function void write_plru_mem_wr_port_in_<%=x%> (snoop_filter_seq_item sf_item);
    <% } %>
    <% } %>
    <% } %>

    //Packet Processing Methods
    extern task          process_txn_completion(uvm_phase phase);
    extern task          process_smi_cmdupd_req(uvm_phase phase);
    extern function void process_smi_cmdupd_rsp(uvm_phase phase);
    extern function void process_smi_snp_req();
    extern function void process_smi_snp_rsp(uvm_phase phase);
    extern function void process_dm_cohreq();
    extern function void process_dm_updreq(uvm_phase phase);
    extern function void process_dm_cmtreq(uvm_phase phase);
    extern function void process_dm_lkprsp();
    extern function void process_dm_recrsp(uvm_phase phase);
    extern function void process_dm_rtyrsp();
    extern function void process_smi_mrd_req();
    extern function void process_smi_mrd_rsp(uvm_phase phase);
    extern function void process_smi_str_req();
    extern function void process_smi_str_rsp(uvm_phase phase);
    extern function void process_smi_rbr_req(uvm_phase phase);
    extern function void process_smi_rbr_rsp(uvm_phase phase);
    extern function void process_smi_sys_event_req();
    extern function void process_smi_sys_event_rsp();
    extern function void check_sys_rsp_timeout(bit err_info);
    extern function void process_smi_sys_co_req();
    extern function void process_smi_sys_co_rsp();

    //Utility Functions
    extern function void smi_pktmatch_checks(ref int idxq[$], inout smi_seq_item seq_item, input string act_pkt_type);
    extern function void dirm_pktmatch_checks( inout int idxq[$], inout dm_seq_item seq_item, input string act_pkt_type);
    extern function void latch_dirm_lkp_req_rsp(dm_seq_item req, dm_seq_item rsp);
    extern function bit  print_pend_txns();
    extern function void predict_dm_cohreq_busyvec();
    extern function bit  check_for_completion(int txn_idx, bit verbose=0);
    extern function bit  check_for_attid_deallocation(int txn_idx, bit verbose=0);

    extern function void predict_exmon_result(int txnq_idx, int iid, int share_vec);
    extern function int  match_tm_addr([WSMIADDR:0] addr_w_sec_i);
    extern function void clear_tm_procid(int agentid_i, int procid_i, int exclude_tm_idx_i = -1);
    extern function void set_specific_tm_procid(int tm_idx_i, int agentid_i, int procid_i);
    extern function int  new_tm_avail([WSMIADDR:0] addr_w_sec_i, int agentid_i, int procid_i);
    extern function void update_bm(bit set_n_clear_i, int agentid_i, int procid_i);
    extern function void print_exmonitor_state();
    
    extern function void check_event_in_req(event_in_check check);
    extern function void generate_sys_event_reqs();
    extern function void check_att_size();
    extern function void release_rbid(req_type_t req_type, int dmi_id, int src_id, int att_id, int rbid, string signature);
    extern function void drop_objection(uvm_phase phase, int idx);

    //Latency calculation
    extern task          calculate_latency_snp(ref event snp_req,ref event snp_rsp);
    extern task          calculate_latency_rbr(ref event rbr_req,ref event rbr_rsp);
    extern task          calculate_latency_mrd(ref event mrd_req,ref event mrd_rsp);
    extern task          calculate_latency_str(ref event str_req,ref event str_rsp);
    extern function void print_latency_data();
    extern virtual function void update_resiliency_ce_cnt(inout smi_seq_item m_item);

 endclass

//constructor
function dce_scb::new(string name = "dce_scb", uvm_component parent = null);
    string s;
    int cid;

    super.new(name, parent);
    this.m_scb_en    = 1'b1;
    this.m_cov_en    = 1'b0;
    this.m_checks_en = 1'b1;

    dce_goldenref_model::build();

    //construct tagged monitors;
    m_tagged_mon = new[addrMgrConst::TAGGED_MON_PER_DCE];
    foreach(m_tagged_mon[idx]) begin
        m_tagged_mon[idx].mon_vld = 0;
        m_tagged_mon[idx].tagged_addr = 0;
        for (int i=0; i < addrMgrConst::NUM_AIUS; i++) begin
            if (addrMgrConst::get_native_interface(i) inside {addrMgrConst::CHI_A_AIU, addrMgrConst::CHI_B_AIU, addrMgrConst::CHI_E_AIU, addrMgrConst::ACE_AIU}) begin
                cid = addrMgrConst::get_cache_id(addrMgrConst::get_aiu_funitid(i)); 
                m_tagged_mon[idx].tagged_mon[cid] = 0;
                $sformat(s, "%s m_tagged_mon[%0d].tagged_mon[%0d]:%0b\n", s, idx, cid, m_tagged_mon[idx].tagged_mon[cid]);
            end
        end
    end 
    for (int i=0; i < addrMgrConst::NUM_AIUS; i++) begin
        if (addrMgrConst::get_native_interface(i) inside {addrMgrConst::CHI_A_AIU, addrMgrConst::CHI_B_AIU, addrMgrConst::CHI_E_AIU, addrMgrConst::ACE_AIU}) begin
            cid = addrMgrConst::get_cache_id(addrMgrConst::get_aiu_funitid(i)); 
            m_basic_mon[cid] = 0;
            $sformat(s, "%s m_basic_mon[%0d]:%0b\n", s, cid, m_basic_mon[cid]);
        end
    end
   `uvm_info("DCE SCB", s, UVM_LOW)

    //Populating RBId's per DMI
    <% for(var rb_index = 0; rb_index < obj.DceInfo[obj.Id].hexDceDmiRbOffset.length; rb_index++){%>
        rbid_range[<%=rb_index%>].dmi_funit_id = <%=obj.DceInfo[obj.Id].hexDceConnectedDmiFunitId[rb_index]%>;
        rbid_range[<%=rb_index%>].RBId_low = <%=obj.DceInfo[obj.Id].hexDceDmiRbOffset[rb_index]%>;
        rbid_range[<%=rb_index%>].RBId_high = <%=obj.DceInfo[obj.Id].hexDceDmiRbOffset[rb_index]%> + (<%=obj.DceInfo[obj.Id].nRbsPerDmi%> - 1);
    <%}%>

    // initiating the sf seq item q
    <%if (obj.testBench == "dce") {%>
    m_plru_en = 0;
    for(int i=0; i < addrMgrConst::NUM_SF; i++) begin
        m_disable_plru_check_conc13075[i] = 0;
        if(addrMgrConst::snoop_filters_info[i].filter_type == "TAGFILTER") begin
            for(int j=0; j < addrMgrConst::snoop_filters_info[i].num_ways; j++) begin
                m_obsv_sf_q[i][j]      = {};
                m_vbhit_way_busy[i][j] = 0;
            end

            for(int j=0; j < addrMgrConst::snoop_filters_info[i].num_sets; j++) begin
                m_plru_mem_wr_ahead_cnt[i][j]    = 0;
                m_plru_mem_wr_busy_tracker[i][j] = {};
            end

            if(addrMgrConst::snoop_filters_info[i].rep_policy == "PLRU") begin
               m_plru_en = 1;
            end
        end
    end

    // Ideal way would have been to have this plru model instantiated under the dirextory model.
    // But given the way the directory manager is coded, that is not a possibility for 3.6!
    if(m_plru_en == 1) begin
        <% var x = 0; %>
        <% obj.SnoopFilterInfo.forEach(function(bundle, indx, array) { %>
        m_plru_model[<%=x%>] = plru_model#(<%=bundle.nSets%>, <%=bundle.nWays%>)::new("plru_model[<%=x%>][ways:<%=bundle.nWays%>]");
        <% x = x+1; %>
        <% }) %>
    end
    <%}%>
endfunction: new

//build_phase
function void dce_scb::build_phase(uvm_phase phase);
    super.build_phase(phase);

    //Build analysis port
    m_smi_port                   = new("m_smi_port"                 , this);
    m_dm_port                    = new("m_dm_port"                  , this);
    m_tm_port                    = new("m_tm_port"                  , this);
    m_evt_port                   = new("m_evt_port"                 , this);
    m_sb_cmdrsp_port             = new("m_sb_cmdrsp_port"           , this);
    m_sb_syscorsp_port           = new("m_sb_syscorsp_port"         , this);
    m_conc_mux_cmdreq_port       = new("m_conc_mux_cmdreq_port"     , this);
    m_arb_cmdreq_port            = new("m_arb_cmdreq_port"          , this);
    m_cycle_tracker_port         = new("m_cycle_tracker_port"       , this);
    analysis_q_chnl_port         = new("analysis_q_chnl_port"       , this);

    <% if (obj.testBench == "dce") { %>
    <% for(var x = 0; x < sf_cnt; x++) { %>
    m_sf_port_in_<%=x%>          = new("sf_port_in_<%=x%>"          , this);
    <% if(plru_en == 1) { %>
    m_plru_mem_wr_port_in_<%=x%> = new("plru_mem_wr_port_in_<%=x%>" , this);
    <% } %>
    <% } %>
    <% } %>
    
    //build the dir manager 
    m_dirm_mgr = directory_mgr::type_id::create("dce_directory_mgr");
    m_dirm_mgr.assign_dbg_verbosity(1);
    m_dirm_mgr.en_vb_recovery = m_vb_recovery_en;
    
 <% if(obj.COVER_ON) { %>
    m_cov = new();
 <% } %>
    `uvm_info("DCE SCB", $psprintf("dbg:build_phase event_threshold:%0d", m_env_cfg.m_qoscr_event_threshold), UVM_LOW)
endfunction: build_phase

//run_phase 
task dce_scb::run_phase(uvm_phase phase);
   <% if ((obj.useResiliency) && (obj.testBench != "fsys" && obj.testBench != "cust_tb")) { %>
     bit test_unit_duplication_uecc;
   <% } %>
   int     iid;
   int     sfid;
   longint addr;
   upd_status_t  upd_status;

    // perf minitor:Bound stall_if Interface
    if (!uvm_config_db#(virtual <%=obj.BlockId%>_stall_if)::get(null, "", "<%=obj.BlockId%>_m_top_stall_if", sb_stall_if)) 
    begin
      `uvm_fatal("Ioaiu_scoreboard stall interface error", "virtual interface must be set for stall_if");
    end
    m_credits = dce_credits_check::type_id::create("m_credits");
    `uvm_info("DCE SCB", $psprintf("dbg:run_phase event_threshold:%0d", m_env_cfg.m_qoscr_event_threshold), UVM_LOW)
    if (! $value$plusargs("inj_cntl=%d", inj_cntl)) begin
       inj_cntl = 0;
    end

    if(!$value$plusargs("sys_event_disable=%d", event_disable)) begin
        event_disable = 0;
    end

<% if (obj.testBench != "fsys" && obj.testBench != "cust_tb") { %>
   if(!uvm_config_db#(virtual  <%=obj.BlockId%>_probe_if )::get(null, get_full_name(), "probe_vif",u_csr_probe_vif)) begin
       `uvm_error("NOVIF",{"virtual interface must be set  for :",get_full_name(),".vif"})
   end
<% } %>

<% if (obj.testBench == "fsys") { %>
      if(!uvm_config_db #(virtual <%=obj.BlockId%>_probe_if)::get(null, get_full_name(), "m_<%=obj.BlockId%>_probe_if", u_csr_probe_vif)) begin
        `uvm_error("NOVIF",{"virtual interface must be set  for :",get_full_name(),".vif"})
      end
<% } %>

<%if(obj.COVER_ON && obj.DceInfo[0].fnEnableQos == 1){%>
    m_cov.collect_qoscr_event_threshold(m_env_cfg.m_qoscr_event_threshold);
<%}%>

    if(!this.m_scb_en) begin
        m_checks_en = 1'b0;
        `uvm_info("DCE SCB", "dce scb checks are disabled", UVM_LOW)
    end else begin
        fork
            begin: txn_completion
                forever begin 
                    @(e_txn_comp);
                    process_txn_completion(phase);
                    check_att_size();
                end 
            end

            begin: cmdupd_req
                forever begin
                    @(e_smi_cmdupd_req);
                    process_smi_cmdupd_req(phase);
                end
            end: cmdupd_req

            begin: cmdupd_rsp
                forever begin
                    @(e_smi_cmdupd_rsp);
                    process_smi_cmdupd_rsp(phase);
                end
            end: cmdupd_rsp

            begin: snp_req
                forever begin
                    @(e_smi_snp_req);
                    process_smi_snp_req();
                end
            end: snp_req    
            
            begin: snp_rsp
                forever begin
                    @(e_smi_snp_rsp);
                    process_smi_snp_rsp(phase);
                end
            end: snp_rsp    
            
            begin: mrd_req
                forever begin
                    @(e_smi_mrd_req);
                    process_smi_mrd_req();
                end
            end: mrd_req    
            
            begin: mrd_rsp
                forever begin
                    @(e_smi_mrd_rsp);
                    process_smi_mrd_rsp(phase);
                end
            end: mrd_rsp    

            begin: str_req
                forever begin
                    @(e_smi_str_req);
                    process_smi_str_req();
                end
            end: str_req    
            
            begin: str_rsp
                forever begin
                    @(e_smi_str_rsp);
                    process_smi_str_rsp(phase);
                end
            end: str_rsp

            begin: rbr_req
                forever begin
                    @(e_smi_rbr_req);
                    process_smi_rbr_req(phase);
                end
            end: rbr_req    
            
            begin: rbr_rsp
                forever begin
                    @(e_smi_rbr_rsp);
                    process_smi_rbr_rsp(phase);
                end
            end: rbr_rsp

            begin: coh_req
                forever begin
                    @(e_dm_cohreq);
                    process_dm_cohreq();
                    check_att_size();
                end
            end: coh_req

            <%if (obj.testBench == "dce") {%>
            begin: coh_req_sf_check
                forever begin
                    @(e_dm_cohreq);
                    addr = {m_dm_cohreq_pkt.m_ns, m_dm_cohreq_pkt.m_addr};
                    fork
                    begin
                      automatic longint addr_threaded = addr;
                     <% if(obj.DceInfo[obj.Id].useSramInputFlop) { %>
                      @(u_csr_probe_vif.monitor_cb);
                     <% } %>
                      check_sf_obsv_item(.rw               ( 0), 
                                         .sfid             (-1), 
                                         .way              (-1), 
                                         .addr             (addr_threaded), 
                                         .signature        ("LkupRdChk"),
                                         .clear_vbhit_busy (0));
                    end
                    join_none
                end
            end: coh_req_sf_check
            <%}%>

            begin: temp_req
                forever begin
                    @(e_dm_tempreq);
                end
            end: temp_req
            
            begin: upd_req
                forever begin
                    @(e_dm_updreq);
                    #1; // CONC-13058: Addind delta delay to avoid the race condition between commit and lookup request
                    process_dm_updreq(phase);
                end
            end: upd_req

            //SANJEEV: TOD: CONC-15502: <%if (obj.testBench == "dce") {%>
            //SANJEEV: TOD: CONC-15502: begin: upd_req_sf_check
            //SANJEEV: TOD: CONC-15502:     forever begin
            //SANJEEV: TOD: CONC-15502:         @(e_dm_updreq);
            //SANJEEV: TOD: CONC-15502:         if (!(m_dm_updreq_pkt.m_status inside {UPD_COMP, UPD_FAIL}))
            //SANJEEV: TOD: CONC-15502:         begin
            //SANJEEV: TOD: CONC-15502:           iid = m_dm_updreq_pkt.m_iid;
            //SANJEEV: TOD: CONC-15502:           sfid = addrMgrConst::get_snoopfilter_id(iid >> WSMINCOREPORTID);
            //SANJEEV: TOD: CONC-15502:           addr = {m_dm_updreq_pkt.m_ns, m_dm_updreq_pkt.m_addr};
	    //SANJEEV: TOD: CONC-15502:           upd_status = m_dm_updreq_pkt.m_status;
            //SANJEEV: TOD: CONC-15502:           fork
            //SANJEEV: TOD: CONC-15502:           begin
            //SANJEEV: TOD: CONC-15502:             automatic longint iid_threaded = iid;
            //SANJEEV: TOD: CONC-15502:             automatic longint sfid_threaded = sfid;
            //SANJEEV: TOD: CONC-15502:             automatic longint addr_threaded = addr;
	    //SANJEEV: TOD: CONC-15502:     	automatic upd_status_t  upd_status_threaded = upd_status;
            //SANJEEV: TOD: CONC-15502:             automatic int hit_way;
            //SANJEEV: TOD: CONC-15502:            <% if(obj.DceInfo[obj.Id].useSramInputFlop) { %>
            //SANJEEV: TOD: CONC-15502:             @(u_csr_probe_vif.monitor_cb);
            //SANJEEV: TOD: CONC-15502:            <% } %>
            //SANJEEV: TOD: CONC-15502:             check_sf_obsv_item(.rw               ( 0), 
            //SANJEEV: TOD: CONC-15502:                                .sfid             (sfid_threaded), 
            //SANJEEV: TOD: CONC-15502:                                .way              (-1), 
            //SANJEEV: TOD: CONC-15502:                                .addr             (addr_threaded),
            //SANJEEV: TOD: CONC-15502:                                .signature        ("UpdRdChk"),
            //SANJEEV: TOD: CONC-15502:                                .clear_vbhit_busy (0));
            //SANJEEV: TOD: CONC-15502:             //SANJEEV: Code here
            //SANJEEV: TOD: CONC-15502:     	hit_way = m_dirm_mgr.get_hit_way(addr_threaded, iid_threaded >> WSMINCOREPORTID);
            //SANJEEV: TOD: CONC-15502:             if (upd_status_threaded == UPD_COMP)
            //SANJEEV: TOD: CONC-15502:             begin //#Check.DCE.DM.UPDreq_COMP_DMmodelupdate
            //SANJEEV: TOD: CONC-15502:               if(m_plru_en)
            //SANJEEV: TOD: CONC-15502:               begin
            //SANJEEV: TOD: CONC-15502:                 if(hit_way != -1)
            //SANJEEV: TOD: CONC-15502:                 begin
            //SANJEEV: TOD: CONC-15502:                   //#Check.DCE.v36.PlruUpResponse
            //SANJEEV: TOD: CONC-15502:                   check_sf_obsv_item(.rw               (1), 
            //SANJEEV: TOD: CONC-15502:                                      .sfid             (sfid_threaded), 
            //SANJEEV: TOD: CONC-15502:                                      .way              (hit_way), 
            //SANJEEV: TOD: CONC-15502:                                      .addr             (addr_threaded), 
            //SANJEEV: TOD: CONC-15502:                                      .signature        ("UpdWrChk"),
            //SANJEEV: TOD: CONC-15502:                                      .clear_vbhit_busy (0));
            //SANJEEV: TOD: CONC-15502:     	    end
            //SANJEEV: TOD: CONC-15502:     	  end
            //SANJEEV: TOD: CONC-15502:             end
            //SANJEEV: TOD: CONC-15502:           end
            //SANJEEV: TOD: CONC-15502:           join_none
            //SANJEEV: TOD: CONC-15502:         end
            //SANJEEV: TOD: CONC-15502:     end
            //SANJEEV: TOD: CONC-15502: end: upd_req_sf_check
            //SANJEEV: TOD: CONC-15502: <%}%>
            
            begin: cmt_req
                forever begin
                    @(e_dm_cmtreq);
                    #1; // CONC-13058: Addind delta delay to avoid the race condition between commit and lookup request
                    process_dm_cmtreq(phase);
                end
            end: cmt_req
            
            begin: lkp_rsp
                forever begin
                    @(e_dm_lkprsp);
                    process_dm_lkprsp();
                end
            end: lkp_rsp

            begin: rec_rsp
                forever begin
                    @(e_dm_recrsp);
                    process_dm_recrsp(phase);
                end
            end: rec_rsp
            
            begin: rty_rsp
                forever begin
                    @(e_dm_rtyrsp);
                    process_dm_rtyrsp();
                end
            end: rty_rsp
            
        begin: sys_evt_req
                forever begin
                    @(e_smi_sys_event_in_req);
                    process_smi_sys_event_req();
                end
            end: sys_evt_req
        
       begin: sys_evt_rsp
                forever begin
                    @(e_smi_sys_event_rsp);
                    // Delay to ensure that the Event timeout info is loggged into the DCEUUESR register
                    if(m_smi_tx_sysrsp_pkt.smi_cmstatus == 8'b0100_0000) #5ns; 
                    process_smi_sys_event_rsp();
                end
            end: sys_evt_rsp
        
       begin: sysco_req
                forever begin
                    @(e_smi_sys_co_req);
                    process_smi_sys_co_req();
                end
            end: sysco_req
            
        begin: sysco_rsp
                forever begin
                    @(e_smi_sys_co_rsp);
                    process_smi_sys_co_rsp();
                end
            end: sysco_rsp
        begin: sysevt_error
        forever begin
            @(e_smi_sys_evt_err);
            #CLK_PERIOD;
            check_sys_rsp_timeout(0);
        end
        end: sysevt_error
        join_none
    end

    fork  //Performance monitoring
      begin : SNP
        forever begin
          calculate_latency_snp(e_smi_snp_req,e_smi_snp_rsp);  
        end
      end
      begin : RBR
        forever begin
          calculate_latency_rbr(e_smi_rbr_req,e_smi_rbr_rsp);  
        end
      end
      begin : MRD
        forever begin
          calculate_latency_mrd(e_smi_mrd_req,e_smi_mrd_rsp);  
        end
      end
      begin : STR
        forever begin
          calculate_latency_str(e_smi_str_req,e_smi_str_rsp);  
        end
      end
    join_none  ///Performance monitoring 

    <% if ((obj.useResiliency) && (obj.testBench != "fsys" && obj.testBench != "cust_tb")) { %>
      if ($test$plusargs("expect_mission_fault") || $test$plusargs("uncorr_skid_buffer_test")) begin
      fork
        if($test$plusargs("uncorr_skid_buffer_test")) begin
        forever begin 
          
            wait(jump_phase == 1);
            kill_test_1.wait_trigger();
            `uvm_info("SKIDBUFERROR", $sformatf("Going to jump phase in scb because uncorr error check finished"), UVM_HIGH)
            phase.jump(uvm_report_phase::get());
          end
        end 

        if(!$test$plusargs("uncorr_skid_buffer_test")) begin
        if(!$test$plusargs("test_unit_duplication")) begin
          begin
            forever begin
               #(100*1ns);
               if (u_csr_probe_vif.fault_mission_fault == 0) begin
                  @u_csr_probe_vif.fault_mission_fault;
               end
               `uvm_info($sformatf("%m"), $sformatf("<%=obj.BlockId%> saw mission fault. Kill test"), UVM_NONE)
               -> kill_test;   // otherwise the test will hang and timeout
               `uvm_info($sformatf("%m"), $sformatf("<%=obj.BlockId%> saw mission fault. Jump to report phase"), UVM_NONE)
               phase.jump(uvm_report_phase::get());
            end
          end
        end else begin
          begin
            forever begin
              #(100*1ns);
              uvm_config_db#(bit)::wait_modified(this, "", "test_unit_duplication_uecc");
              `uvm_info(get_name(), "modified value of test_unit_duplication_uecc", UVM_LOW)
              uvm_config_db#(bit)::get(this, "", "test_unit_duplication_uecc", test_unit_duplication_uecc);
              if(test_unit_duplication_uecc) begin
                if(u_csr_probe_vif.fault_mission_fault == 0) begin
                   @u_csr_probe_vif.fault_mission_fault;
                end
                `uvm_info($sformatf("%m"), $sformatf("<%=obj.BlockId%> saw mission fault. Kill test"), UVM_NONE)
                -> kill_test;   // otherwise the test will hang and timeout
                `uvm_info($sformatf("%m"), $sformatf("<%=obj.BlockId%> saw mission fault. Jump to report phase"), UVM_NONE)
                phase.jump(uvm_report_phase::get());
              end
            end
          end
        end 
        end //!$test$plusargs(uncorr_skid_buffer_test)
      join_none
      end
    <% } %>

     begin //RAL mirrored value
        #3000ns;
        if(m_regs == null) begin
            `uvm_info(get_type_name(),"m_regs at sb is null",UVM_LOW);
        end
        my_register = m_regs.get_reg_by_name("DCEUCELR0");
        mirrored_value = my_register.get_mirrored_value();
        `uvm_info("SB",$sformatf("The mirrored value in SB of DCEUCELR0 is %0h",mirrored_value),UVM_LOW)

    end 

endtask: run_phase

//******************************************************
function void dce_scb::check_phase(uvm_phase phase);
    string s;
    bit all_attid_deallocated = 1;

    $sformat(s, "%0s Still allocated ATTIDs at End-Of-Test", s);  
    for (int i=0; i < WATTVEC; i++) begin 
        if (m_attvld_aa.exists(i)) begin 
            $sformat(s, "%0s ATTID:%0d", s, i);  
            all_attid_deallocated = 0;
        end
    end 
    if (all_attid_deallocated == 0 && 
        (!$test$plusargs("wrong_mrdrsp_target_id") &&
         !$test$plusargs("wrong_strrsp_target_id") &&
         !$test$plusargs("wrong_rbrsp_target_id") &&
         !$test$plusargs("k_csr_seq=dce_csr_no_address_hit_seq") &&
         !$test$plusargs("k_csr_seq=dce_csr_address_region_overlap_seq")
        )
       ) begin 
        `uvm_error("DCE_SCB_ERROR", $psprintf("%0s", s))
    end

    if (m_dm_updreq_pktq.size() != 0) begin 
        foreach (m_dm_updreq_pktq[i]) begin 
            $sformat(s, "%0s %0s\n", s, m_dm_updreq_pktq[i].convert2string());
        end
        `uvm_error("DCE_SCB_ERROR", $psprintf("Following UPDreq on DM interface have not received an UPDstatus from DM\n - %0s", s))
    end 

endfunction:check_phase;

//******************************************************
function void dce_scb::report_phase(uvm_phase phase);
    int    q_size=0;
    string s;
    string inf;

    $sformat(s, "%0s \nScoreboard Stats:\nnum_txns:%0d\nnum_coh_reqs:%0d\nnum_upd_reqs:%0d\nnum_rec_reqs:%0d\nnum_snp_reqs:%0d\nnum_dir_hits:%0d num_dir_miss:%0d\nnum_sysreq_attach:%0d\nnum_sysreq_detach:%0d\n", s, num_txns, num_coh_reqs, num_upd_reqs, num_rec_reqs, num_snp_reqs, num_dir_hit, num_dir_miss, num_sysreq_attach, num_sysreq_detach);
    foreach(src_ncore_unit_id[i]) begin
        inf = addrMgrConst::get_native_interface(addrMgrConst::agentid_assoc2funitid(i)).name;
        $sformat(s, "%ssrc_ncore_unit_id:%0d native_interface:%0s %0s num_reqs:%0d\n", s, i, inf, ((inf == "IO_CACHE_AIU") ? ((addrMgrConst::get_cache_id(i) == -1) ? "(0)" : "(1)") : ""), src_ncore_unit_id[i]);
    end
    foreach(cmd_type[i]) begin
        $sformat(s, "%scmd_type:%p occured:%0d\n", s, i, cmd_type[i]);
    end
    foreach(upd_type[i]) begin
        $sformat(s, "%supd_type:%p occured:%0d\n", s, i, upd_type[i]);
    end
    
    //Printing latency statistics
    if($test$plusargs("dce_latency") || $test$plusargs("dce_latency_checks"))   
        print_latency_data();
    
    `uvm_info("DCE SCB", s, UVM_LOW)
    <% if ((obj.useResiliency) && (obj.testBench != "fsys" && obj.testBench != "cust_tb")) { %>
       if($test$plusargs("expect_mission_fault")) begin
         if (u_csr_probe_vif.fault_mission_fault == 0) begin
           `uvm_error({"fault_injector_checker_",get_name()}
             , $sformatf({"expect_mission_fault argument is passed from command line & observed mission_fault=%0d"}
               , u_csr_probe_vif.fault_mission_fault))
         end else begin
           `uvm_info(get_name()
             , $sformatf({"expect_mission_fault argument is passed from command line & observed mission_fault=%0d"}
               , u_csr_probe_vif.fault_mission_fault)
             , UVM_LOW)
         end
       end
    <% } %>


    <%if (obj.testBench == "dce") {%>
    q_size = 0;
    for(int i=0; i < addrMgrConst::NUM_SF; i++) begin
        if(addrMgrConst::snoop_filters_info[i].filter_type == "TAGFILTER") begin
            for(int j=0; j < addrMgrConst::snoop_filters_info[i].num_ways; j++) begin
                q_size += m_obsv_sf_q[i][j].size();
                if(m_obsv_sf_q[i][j].size() > 0) begin
                   `uvm_info(get_name(), $psprintf("[%-35s] Observed Snoop Filter Queue not empty [sf: %2d] [way: %2d] [size: %3d]", "DceScbd-SimEndCheck", i, j, m_obsv_sf_q[i][j].size()), UVM_NONE);
                end
            end
        end
    end
    if($test$plusargs("plruDbg")) begin
        if(q_size > 0) begin
           `uvm_error(get_name(), $psprintf("[%-35s] One or more Snoop Filter Queue not empty!", "DceScbd-SimEndCheck"));
        end
    end
    <%}%> 
endfunction: report_phase

//*************************************************
// Write functions: To get all traffic
// write_smi_port
// write_dirm_port
//*************************************************
function void dce_scb::write_smi_port(inout smi_seq_item rcvd_pkt);
    string s;
    string       msg_type_s;
    eMsgUPD      updreq_type;
    eMsgUpdRsp   updrsp_type;
    eMsgCMD      cmdreq_type;
    eMsgCCmdRsp  cmdrsp_type;
    eMsgSNP      snpreq_type;
    eMsgSnpRsp   snprsp_type;
    eMsgSTR      strreq_type;
    eMsgStrRsp   strrsp_type;
    eMsgMRD      mrdreq_type;
    eMsgMrdRsp   mrdrsp_type;
    eMsgRBReq    rbrreq_type;
    eMsgRBRsp    rbrrsp_type;
    eMsgRBUsed   rbureq_type;
    eMsgRBUseRsp rbursp_type;
    eMsgSysReq   sysreq_type;
    eMsgSysRsp   sysrsp_type;
    smi_seq_item txn_pkt;

   `uvm_info(get_name(), $psprintf("[%-35s] (txnId: -----) {%20s} (src: 0x%02h {%s}) (tgt: 0x%02h) (msgId: 0x%02h) (rmsgId: 0x%02h) (rbid: 0x%02h) (addr: 0x%016h) (cmStatus: 0x%02h) (qos: %3d) (aux: 0x%0h)", "DceScbd-SmiPktIn", rcvd_pkt.type2cmdname(), rcvd_pkt.smi_src_ncore_unit_id, addrMgrConst::get_cache_id_as_string(rcvd_pkt.smi_src_ncore_unit_id), rcvd_pkt.smi_targ_ncore_unit_id, rcvd_pkt.smi_msg_id, rcvd_pkt.smi_rmsg_id, rcvd_pkt.smi_rbid, rcvd_pkt.smi_addr, rcvd_pkt.smi_cmstatus, rcvd_pkt.smi_qos, rcvd_pkt.smi_ndp_aux), UVM_LOW);


    // get error statistics
    if(rcvd_pkt.ndp_corr_error || rcvd_pkt.hdr_corr_error || rcvd_pkt.dp_corr_error) begin
      update_resiliency_ce_cnt(rcvd_pkt);
    end
    num_smi_corr_err      += rcvd_pkt.ndp_corr_error + rcvd_pkt.hdr_corr_error + rcvd_pkt.dp_corr_error;
    num_smi_uncorr_err    += rcvd_pkt.ndp_uncorr_error + rcvd_pkt.hdr_uncorr_error + rcvd_pkt.dp_uncorr_error;
    num_smi_parity_err    += rcvd_pkt.ndp_parity_error + rcvd_pkt.hdr_parity_error + rcvd_pkt.dp_parity_error;

    rcvd_pkt.t_smi_ndp_valid = $time;
    void'($cast(txn_pkt, rcvd_pkt.clone()));
    case(1) 
    (txn_pkt.isUpdMsg()): begin
                               $cast(updreq_type, txn_pkt.smi_msg_type);
                               $sformat(msg_type_s, "%p", updreq_type); 
                           end
    (txn_pkt.isCmdMsg()): begin
                               $cast(cmdreq_type, txn_pkt.smi_msg_type);
                               $sformat(msg_type_s, "%p", cmdreq_type); 
                           end
    (txn_pkt.isSnpMsg()): begin
                               $cast(snpreq_type, txn_pkt.smi_msg_type);
                               $sformat(msg_type_s, "%p", snpreq_type); 
                           end
    (txn_pkt.isStrMsg()): begin
                               $cast(strreq_type, txn_pkt.smi_msg_type);
                               $sformat(msg_type_s, "%p", strreq_type); 
                           end
    (txn_pkt.isMrdMsg()): begin
                               $cast(mrdreq_type, txn_pkt.smi_msg_type);
                               $sformat(msg_type_s, "%p", mrdreq_type); 
                           end
    (txn_pkt.isRbMsg()): begin
                               $cast(rbrreq_type, txn_pkt.smi_msg_type);
                               $sformat(msg_type_s, "%p", rbrreq_type); 
                           end
    (txn_pkt.isRbUseMsg()): begin
                               $cast(rbureq_type, txn_pkt.smi_msg_type);
                               $sformat(msg_type_s, "%p", rbureq_type); 
                           end
    (txn_pkt.isCCmdRspMsg()): begin
                               $cast(cmdrsp_type, txn_pkt.smi_msg_type);
                               $sformat(msg_type_s, "%p", cmdrsp_type); 
                           end
    (txn_pkt.isUpdRspMsg()): begin
                               $cast(updrsp_type, txn_pkt.smi_msg_type);
                               $sformat(msg_type_s, "%p", updrsp_type); 
                           end
    (txn_pkt.isSnpRspMsg()): begin
                               $cast(snprsp_type, txn_pkt.smi_msg_type);
                               $sformat(msg_type_s, "%p", snprsp_type); 
                           end
    (txn_pkt.isStrRspMsg()): begin
                               $cast(strrsp_type, txn_pkt.smi_msg_type);
                               $sformat(msg_type_s, "%p", strrsp_type); 
                           end
    (txn_pkt.isMrdRspMsg()): begin
                               $cast(mrdrsp_type, txn_pkt.smi_msg_type);
                               $sformat(msg_type_s, "%p", mrdrsp_type); 
                           end
    (txn_pkt.isRbRspMsg()): begin
                               $cast(rbrrsp_type, txn_pkt.smi_msg_type);
                               $sformat(msg_type_s, "%p", rbrrsp_type); 
                           end
    (txn_pkt.isRbUseRspMsg()): begin
                               $cast(rbursp_type, txn_pkt.smi_msg_type);
                               $sformat(msg_type_s, "%p", rbursp_type); 
                           end
    (txn_pkt.isSysReqMsg()): begin
                               $cast(sysreq_type, txn_pkt.smi_msg_type);
                               $sformat(msg_type_s, "%p", sysreq_type); 
                           end
    (txn_pkt.isSysRspMsg()): begin
                               $cast(sysrsp_type, txn_pkt.smi_msg_type);
                               $sformat(msg_type_s, "%p", sysrsp_type); 
                           end
    endcase
    
    txn_pkt.unpack_smi_seq_item();
    $sformat(s, "%0s msg_id:%p rmsg_id:%p msg_type:%s %s %s %s \n%s\n",
                 s, 
                 txn_pkt.smi_msg_id, 
                 txn_pkt.smi_rmsg_id, 
                 msg_type_s,
                 txn_pkt.isRbUseMsg() ? $psprintf("dmiid:0x%0h rbid:0x%0h", txn_pkt.smi_src_ncore_unit_id, txn_pkt.smi_rbid) : "",
                 txn_pkt.isRbMsg() ? ((txn_pkt.smi_rtype == 1) ? $psprintf("Reserve dmiid:0x%0h rbid:0x%0h", txn_pkt.smi_targ_ncore_unit_id, txn_pkt.smi_rbid) : $psprintf("Release dmiid:0x%0h rbid:0x%0h", txn_pkt.smi_targ_ncore_unit_id, txn_pkt.smi_rbid)) : "",
                 (txn_pkt.isCmdMsg() || txn_pkt.isUpdMsg() || txn_pkt.isSnpMsg() || txn_pkt.isStrMsg() || txn_pkt.isMrdMsg() || txn_pkt.isRbMsg()) ? $psprintf("addr:0x%X ns:%p", txn_pkt.smi_addr, txn_pkt.smi_ns) : "", 
                 txn_pkt.convert2string());

    //`uvm_info("DCE_SCB", $psprintf("num_smi_uncorr_err:%0d num_smi_parity_err:%0d", num_smi_uncorr_err, num_smi_parity_err), UVM_LOW)
    if (num_smi_uncorr_err>0 || num_smi_parity_err>0) begin
        `uvm_info("DCE_SCB", $psprintf("Received below SMI packet at DCE SCB that has Error num_smi_uncorr_err:%0p num_smi_parity_err:%0p: %0s", num_smi_uncorr_err,num_smi_parity_err, s), UVM_LOW)
      return; // skipping Txn for uncorrectable error
    end else if (garbage_dmiid) begin 
        `uvm_info("DCE_SCB", $psprintf("garbage_dmiid already detected- drop all txns"), UVM_LOW)
        ->e_attid_dealloc; //needed for dce_dm_recall_seq to make progress
        return; 
    end begin 
    `uvm_info("DCE_SCB", $psprintf("Received below SMI packet at DCE SCB: %0s", s), UVM_LOW)
    //`uvm_info("DCE_SCB", $psprintf("StashVld: %0d StashNID:%0d", txn_pkt.smi_mpf1_stash_valid, txn_pkt.smi_mpf1_stash_nid), UVM_LOW)
  
 
    case(1)
        (txn_pkt.isCmdMsg() || txn_pkt.isUpdMsg())         : begin
                                                                   m_smi_tx_cmdupdreq_pkt = txn_pkt;
                                                                   -> e_smi_cmdupd_req; 
                                                               end
        (txn_pkt.isCCmdRspMsg() || txn_pkt.isUpdRspMsg())  : begin
                                                                   m_smi_rx_cmdupdrsp_pkt = txn_pkt;
                                                                   -> e_smi_cmdupd_rsp;
                                                               end 
        txn_pkt.isSnpMsg()                                  : begin
                                                                   m_smi_rx_snpreq_pkt = txn_pkt;
                                                                   -> e_smi_snp_req;
                                                               end 
        txn_pkt.isSnpRspMsg()                               : begin
                                                                   m_smi_tx_snprsp_pkt = txn_pkt;
                                                                   -> e_smi_snp_rsp;
                                                               end 
        txn_pkt.isMrdMsg()                                  : begin
                                                                   m_smi_rx_mrdreq_pkt = txn_pkt;
                                                                   -> e_smi_mrd_req;
                                                               end 
        txn_pkt.isMrdRspMsg()                               : begin
                                                                   m_smi_tx_mrdrsp_pkt = txn_pkt;
                                                                   -> e_smi_mrd_rsp;
                                                               end 
        txn_pkt.isStrMsg()                                  : begin
                                                                   m_smi_rx_strreq_pkt = txn_pkt;
                                                                   -> e_smi_str_req;
                                                               end 
        txn_pkt.isStrRspMsg()                               : begin
                                                                   m_smi_tx_strrsp_pkt = txn_pkt;
                                                                   -> e_smi_str_rsp;
                                                               end 
        txn_pkt.isRbMsg()                                  : begin
                                                                   m_smi_rx_rbrreq_pkt = txn_pkt;
                                                                   -> e_smi_rbr_req;
                                                               end 
        txn_pkt.isRbRspMsg()                               : begin
                                                                   m_smi_tx_rbrrsp_pkt = txn_pkt;
                                                                   -> e_smi_rbr_rsp;
                                                               end 
        txn_pkt.isRbUseMsg()                               : begin
                                                                   m_smi_tx_rbureq_pkt = txn_pkt;
                                                                   -> e_smi_rbu_req;
                                                              end 
        txn_pkt.isRbUseRspMsg()                             : begin
                                                                   m_smi_rx_rbursp_pkt = txn_pkt;
                                                                   -> e_smi_rbu_rsp;
                                                              end 
        (txn_pkt.isSysReqMsg() && (txn_pkt.smi_sysreq_op == 3)) : begin
                                                                   m_smi_rx_sysreq_pkt = txn_pkt;
                                                                   -> e_smi_sys_event_in_req;
                                                  end 
        txn_pkt.isSysRspMsg() && ((txn_pkt.smi_targ_ncore_unit_id == addrMgrConst::get_dce_funitid(<%=obj.Id%>)) || ($test$plusargs("wrong_sysrsp_target_id") && txn_pkt.smi_src_ncore_unit_id != addrMgrConst::get_dce_funitid(<%=obj.Id%>))) : begin
                                                                   m_smi_tx_sysrsp_pkt = txn_pkt;
                                                                   -> e_smi_sys_event_rsp;
                                                  end
    (txn_pkt.isSysReqMsg() && (txn_pkt.smi_sysreq_op inside {1,2})) : begin
                                                                   m_smi_tx_sysreq_pkt = txn_pkt;
                                                                   -> e_smi_sys_co_req;
                                                  end
    txn_pkt.isSysRspMsg() && (txn_pkt.smi_src_ncore_unit_id == addrMgrConst::get_dce_funitid(<%=obj.Id%>)) : begin
                                                                   m_smi_rx_sysrsp_pkt = txn_pkt;
                                                                   -> e_smi_sys_co_rsp;
                                                  end
        default:    
        `uvm_error("DCE_SCB_ERROR", $psprintf("Received unexpected packet on SMI port"))
    endcase

    end
endfunction: write_smi_port

//**********************************************************
function void dce_scb::write_dm_port(dm_seq_item rcvd_pkt);

    if (!(num_smi_uncorr_err>0 || num_smi_parity_err>0))begin
        case (rcvd_pkt.m_access_type)
            DM_CMD_REQ: begin
                       void'($cast(m_dm_cohreq_pkt, rcvd_pkt.clone()));
                      `uvm_info(get_name(), $psprintf("[%-35s] (addr: 0x%016h) (att: 0x%02h, %20s) (msgId: 0x%02h) (access: %20s) (updStat: %20s) (shareVec: 0x%04h) (owner: %1b/0x%02h) (alloc: %1b) (iid: 0x%02h) (sid: 0x%02h)\n%s", "DceScbd-LkupReqInit", rcvd_pkt.m_addr, rcvd_pkt.m_attid, rcvd_pkt.m_attid_state.name(), rcvd_pkt.m_msg_id, rcvd_pkt.m_access_type.name(), rcvd_pkt.m_status.name(), rcvd_pkt.m_sharer_vec, rcvd_pkt.m_owner_val, rcvd_pkt.m_owner_num, rcvd_pkt.m_alloc, rcvd_pkt.m_iid, rcvd_pkt.m_sid, rcvd_pkt.convert2string()), UVM_MEDIUM);
                       //<%if (obj.testBench == "dce") {%>
                       //check_sf_obsv_item(.rw               ( 0), 
                       //                   .sfid             (-1), 
                       //                   .way              (-1), 
                       //                   .addr             ({rcvd_pkt.m_ns, rcvd_pkt.m_addr}), 
                       //                   .signature        ("LkupRdChk"),
                       //                   .clear_vbhit_busy (0));
                       //<%}%>
                       ->e_dm_cohreq;
                     end
            DM_UPD_REQ: begin
                       void'($cast(m_dm_updreq_pkt, rcvd_pkt.clone()));
                       ->e_dm_updreq;
                     end
            DM_CMT_REQ: begin
                       m_dm_cmtreq_pkt = rcvd_pkt;
                       // YR-FIX: add a function call for each valid way as the sf shall send out an entry for each way
                      `uvm_info(get_name(), $psprintf("[%-35s] (addr: 0x%016h) (att: 0x%02h, %20s) (msgId: 0x%02h) (access: %20s) (updStat: %20s) (shareVec: 0x%04h) (owner: %1b/0x%02h)\n%s", "DceScbd-CmtInit", rcvd_pkt.m_addr, rcvd_pkt.m_attid, rcvd_pkt.m_attid_state.name(), rcvd_pkt.m_msg_id, rcvd_pkt.m_access_type.name(), rcvd_pkt.m_status.name(), rcvd_pkt.m_sharer_vec, rcvd_pkt.m_owner_val, rcvd_pkt.m_owner_num, rcvd_pkt.convert2string()), UVM_MEDIUM);
                       ->e_dm_cmtreq;
                     end
            DM_LKP_RSP: begin
                       void'($cast(m_dm_lkprsp_pkt, rcvd_pkt.clone()));
                      `uvm_info(get_name(), $psprintf("[%-35s] (addr: 0x%016h) (att: 0x%02h, %20s) (msgId: 0x%02h) (access: %20s) (updStat: %20s) (shareVec: 0x%04h) (owner: %1b/0x%02h) (iid: 0x%02h) (sid: 0x%02h) (wrReq: %1b)\n%s", "DceScbd-LkupRspInit", rcvd_pkt.m_addr, rcvd_pkt.m_attid, rcvd_pkt.m_attid_state.name(), rcvd_pkt.m_msg_id, rcvd_pkt.m_access_type.name(), rcvd_pkt.m_status.name(), rcvd_pkt.m_sharer_vec, rcvd_pkt.m_owner_val, rcvd_pkt.m_owner_num, rcvd_pkt.m_iid, rcvd_pkt.m_sid, rcvd_pkt.m_wr_required, rcvd_pkt.convert2string()), UVM_MEDIUM);
                       ->e_dm_lkprsp;
                     end
            DM_REC_REQ: begin
                       m_dm_recrsp_pkt = rcvd_pkt;
                      `uvm_info(get_name(), $psprintf("[%-35s] (addr: 0x%016h) (att: 0x%02h, %20s) (msgId: 0x%02h) (access: %20s) (updStat: %20s) (shareVec: 0x%04h) (owner: %1b/0x%02h)\n%s", "DceScbd-RecallReqInit", rcvd_pkt.m_addr, rcvd_pkt.m_attid, rcvd_pkt.m_attid_state.name(), rcvd_pkt.m_msg_id, rcvd_pkt.m_access_type.name(), rcvd_pkt.m_status.name(), rcvd_pkt.m_sharer_vec, rcvd_pkt.m_owner_val, rcvd_pkt.m_owner_num, rcvd_pkt.convert2string()), UVM_MEDIUM);
                       ->e_dm_recrsp;
                     end
            DM_RTY_RSP: begin
                       m_dm_rtyrsp_pkt = rcvd_pkt;
                      `uvm_info(get_name(), $psprintf("[%-35s] (addr: 0x%016h) (att: 0x%02h, %20s) (msgId: 0x%02h) (access: %20s) (updStat: %20s) (shareVec: 0x%04h) (owner: %1b/0x%02h)\n%s", "DceScbd-RetryRspInit", rcvd_pkt.m_addr, rcvd_pkt.m_attid, rcvd_pkt.m_attid_state.name(), rcvd_pkt.m_msg_id, rcvd_pkt.m_access_type.name(), rcvd_pkt.m_status.name(), rcvd_pkt.m_sharer_vec, rcvd_pkt.m_owner_val, rcvd_pkt.m_owner_num, rcvd_pkt.convert2string()), UVM_MEDIUM);
                       ->e_dm_rtyrsp;
                     end
        endcase
    end
endfunction: write_dm_port

//**********************************************************
function void dce_scb::write_tm_port(bit[WATTVEC-1:0] attvld_vec_i);
    string s;
    int jdxq[$], idxq[$];
    int dce_txnq_wakeup_idx, dce_txnq_idx, process_txn=0;

    for(int i = 0; i < WATTVEC; i++) begin

        //check on premature attid deallocation before all SM are completed
        if ((attvld_vec_i[i] == 0) && (m_attvld_vec_prev[i] == 1)) begin
            jdxq = m_dce_txnq.find_index(item) with ((item.m_attid == i) && (item.m_attid_status != ATTID_IS_INACTIVE) && (item.m_objection_dropped == 0));
           `uvm_info(get_name(), $psprintf("[%-35s] att-id [0x%02h] deallocated! (matches: %3d) (attExists: %1b)", "DceScbd-AttTmDealloc", i, jdxq.size(), m_attvld_aa.exists(i)), UVM_LOW);
            foreach(m_dce_txnq[j]) begin
                if((m_dce_txnq[j].m_attid == i) && (m_dce_txnq[j].m_attid_status != ATTID_IS_INACTIVE) && (m_dce_txnq[j].m_objection_dropped == 0)) begin
                   `uvm_info(get_name(), $psprintf("[%-35s] (txnId: %5d) {%20s} (src: 0x%02h {%s}) (tgt: 0x%02h) (msgId: 0x%02h) (attid : 0x%02h) (rbid: 0x%02h) (addr: 0x%016h) (attStat: %25s) (rtlDealloc: %1b) (%10t, %10t, %10t)", "DceScbd-AttCheck", m_dce_txnq[j].m_txn_id, m_dce_txnq[j].m_initcmdupd_req_pkt.type2cmdname(), m_dce_txnq[j].m_initcmdupd_req_pkt.smi_src_ncore_unit_id, addrMgrConst::get_cache_id_as_string(m_dce_txnq[j].m_initcmdupd_req_pkt.smi_src_ncore_unit_id), m_dce_txnq[j].m_initcmdupd_req_pkt.smi_targ_ncore_unit_id, m_dce_txnq[j].m_initcmdupd_req_pkt.smi_msg_id, m_dce_txnq[j].m_attid, m_dce_txnq[j].m_rbid, m_dce_txnq[j].m_initcmdupd_req_pkt.smi_addr, m_dce_txnq[j].m_attid_status.name(), m_dce_txnq[j].rtl_deallocated, m_dce_txnq[j].m_initcmdupd_req_pkt.t_smi_ndp_valid, m_dce_txnq[j].t_conc_mux_cmdreq, m_dce_txnq[j].t_dm_cmdreq), UVM_LOW);
                end
            end

            if (jdxq.size() == 0 || (m_attvld_aa.exists(i) == 0)) begin
                if (num_smi_uncorr_err>0 || num_smi_parity_err>0 || garbage_dmiid)
                    return;
                if ($test$plusargs("wrong_rbureq_target_id")) begin
                    if(m_attvld_aa.exists(i) == 1) begin
                        m_attvld_aa.delete(i);
                        return; 
                    end
                    else
                        `uvm_error("DCE_SCB",$psprintf("Attid should have been deallocated"))
                end

                // CONC-12425 related updated as ATTID_IS_INACTIVE will not show for recall request
                jdxq = m_dce_txnq.find_index(item) with ((item.m_attid == i) && (item.m_req_type == REC_REQ) && (item.m_states["snpreq"].get_valid_count() == 0) && 
                                    (item.m_states["snpreq"].is_complete() &&  item.m_states["snprsp"].is_complete()) && (item.m_attid_status != ATTID_IS_RELEASED));
                if(jdxq.size() == 1) begin
                    dce_txnq_idx = jdxq[0];
                    m_dce_txnq[jdxq[0]].m_attid = i;
                   `uvm_info(get_name(), $psprintf("[%-35s] (txnId: %5d) {%20s} (src: 0x%02h {%s}) (tgt: 0x%02h) (msgId: 0x%02h) (attid : 0x%02h) (rbid: 0x%02h) (addr: 0x%016h) (%10t, %10t)", "DceScbd-AttRelease(1)", m_dce_txnq[jdxq[0]].m_txn_id, m_dce_txnq[jdxq[0]].m_initcmdupd_req_pkt.type2cmdname(), m_dce_txnq[jdxq[0]].m_initcmdupd_req_pkt.smi_src_ncore_unit_id, addrMgrConst::get_cache_id_as_string(m_dce_txnq[jdxq[0]].m_initcmdupd_req_pkt.smi_src_ncore_unit_id), m_dce_txnq[jdxq[0]].m_initcmdupd_req_pkt.smi_targ_ncore_unit_id, m_dce_txnq[jdxq[0]].m_initcmdupd_req_pkt.smi_msg_id, m_dce_txnq[jdxq[0]].m_attid, m_dce_txnq[jdxq[0]].m_rbid, m_dce_txnq[jdxq[0]].m_initcmdupd_req_pkt.smi_addr, m_dce_txnq[jdxq[0]].m_initcmdupd_req_pkt.t_smi_ndp_valid, m_dce_txnq[jdxq[0]].t_conc_mux_cmdreq), UVM_LOW);
                    m_dce_txnq[jdxq[0]].m_attid_status = ATTID_IS_RELEASED;
                    m_attvld_aa[m_dce_txnq[jdxq[0]].m_attid]  = m_dce_txnq[jdxq[0]];
                    `uvm_info("DCE_SCB", $psprintf("Releasing ATTid %d because no snoops expected",m_dce_txnq[jdxq[0]].m_attid),UVM_LOW)
                end else
                    `uvm_error("DCE_SCB", $psprintf("attid deallocation error. [%1d] matches for the deallocated attid:0x%0h. Check pending transactions. RTL Deallocated attid butTB didn't", jdxq.size(), i))
            end else if (jdxq.size() == 1) begin 
                dce_txnq_idx = jdxq[0];
            end else begin 
                // YRAMASAMY: Questions
                // 1. Why do we assume only 2 entries to be in there?
                // 2. What does t_dm_cmdreq == 0 signify?
                //    -> Looks like this is when the dm has not seen a response. But why does it matter?
                // 3. Why are there so many overriding conditions below?
                if (longint'(m_dce_txnq[jdxq[0]].t_dm_cmdreq != 0)) begin 
                    dce_txnq_idx = jdxq[0];
                end else begin 
                    dce_txnq_idx = jdxq[1];
                end

                foreach(jdxq[x]) begin
                    if(m_dce_txnq[jdxq[x]].rtl_deallocated == 0) begin
                        dce_txnq_idx = jdxq[x];
                        break;
                    end
                end 

                for (int k = 0; k < jdxq.size(); k++) begin
                    if (m_dce_txnq[jdxq[k]].rtl_deallocated != 1) begin
                        if (longint'(m_dce_txnq[jdxq[k]].t_dm_cmdreq != 0) && (longint'(m_dce_txnq[jdxq[k]].t_dm_cmdreq) < longint'(m_dce_txnq[dce_txnq_idx].t_dm_cmdreq))) begin
                            dce_txnq_idx = jdxq[k];
                        end
                    end
                end
            end

           `uvm_info("DCE_SCB", $psprintf("Deallocated attid:0x%0h (dec:%0d) matches dce_txnq_idx:%0d %0s", i, i, dce_txnq_idx, ((m_dce_txnq[dce_txnq_idx].m_req_type == CMD_REQ) ? $psprintf("(cmd) addr:%0p ns:%0p", m_dce_txnq[dce_txnq_idx].m_initcmdupd_req_pkt.smi_addr, m_dce_txnq[dce_txnq_idx].m_initcmdupd_req_pkt.smi_ns) : $psprintf("(rec) addr:%0p ns:%0p", m_dce_txnq[dce_txnq_idx].m_dm_pktq[0].m_addr, m_dce_txnq[dce_txnq_idx].m_dm_pktq[0].m_ns))), UVM_LOW)
            m_dce_txnq[dce_txnq_idx].rtl_deallocated = 1;
            if (longint'(m_dce_txnq[dce_txnq_idx].t_dm_cmdreq == 0))
                `uvm_error("DCE_SCB", $psprintf("for the deallocated attid:0x%0h (dec:%0d) t_dm_cmdreq = 0", i, i))

            //if (jdxq.size() == 1) begin
                //#Check.DCE.PrematureAttidDeallocation
            if (check_for_attid_deallocation(dce_txnq_idx) == 0) begin
                //`uvm_error("DCE_SCB", $psprintf("Premature deallocation of attid: 0x%0h (dec:%0d) \n%0s", i, i, m_dce_txnq[jdxq[0]].print_txn(1)))
                `uvm_error("DCE_SCB", $psprintf("Premature deallocation of attid:0x%0h (dec:%0d) at dce_txnq_idx:%0d \n", i, i, dce_txnq_idx))
            end else begin //attid can be deallocated
                if (m_attvld_aa.exists(i) == 0) begin 
                    `uvm_error("DCE_SCB", $psprintf("RTL deallocation of attid:0x%0h (dec:%0d) is seen, but txn not put in m_attvld_aa\n", i, i))
                end else begin //
                    //wakeup the highest priority request that requested DM LKP first
                    if (m_attvld_aa[i].m_req_type == REC_REQ) begin
                        idxq = m_dce_txnq.find_index(item) with ((item.m_req_type == CMD_REQ) &&
                                                                 (item.m_initcmdupd_req_pkt.smi_addr >> addrMgrConst::WCACHE_OFFSET == m_attvld_aa[i].m_dm_pktq[0].m_addr >> addrMgrConst::WCACHE_OFFSET) &&
                                                                 (item.m_initcmdupd_req_pkt.smi_ns   == m_attvld_aa[i].m_dm_pktq[0].m_ns) &&
                                                                 (item.m_attid_status == ATTID_IS_SLEEP)
                                                            );
                    end else if (m_attvld_aa[i].m_req_type == CMD_REQ) begin //CMD_REQ
                        idxq = m_dce_txnq.find_index(item) with ((item.m_req_type == CMD_REQ) &&
                                                                 (item.m_initcmdupd_req_pkt.smi_addr >> addrMgrConst::WCACHE_OFFSET == m_attvld_aa[i].m_initcmdupd_req_pkt.smi_addr >> addrMgrConst::WCACHE_OFFSET) &&
                                                                 (item.m_initcmdupd_req_pkt.smi_ns   == m_attvld_aa[i].m_initcmdupd_req_pkt.smi_ns) &&
                                                                 (item.m_attid_status == ATTID_IS_SLEEP)
                                                            );
                    end

                    if (idxq.size() > 0) begin
                        //`uvm_info("DCE_SCB", $psprintf("size:%0d first entry txnq_idx:%0d dm_time:%0t int_val:%0d attid:0x%0h attid_status:%0p", idxq.size(), idxq[0], m_dce_txnq[idxq[0]].t_dm_cmdreq, longint'(m_dce_txnq[idxq[0]].t_dm_cmdreq), m_dce_txnq[idxq[0]].m_attid, m_dce_txnq[idxq[0]].m_attid_status), UVM_LOW)
                        if (idxq.size() == 1) begin
                            `uvm_info("DCE_SCB", $psprintf("Wake up dce_txnq_idx: %0d attid: 0x%0h on attid:0x%0h dealloc", idxq[0], m_dce_txnq[idxq[0]].m_attid, i), UVM_LOW)
                            m_dce_txnq[idxq[0]].m_attid_status = ATTID_IS_WAKEUP;
                        end else begin //idxq.size > 1
                            dce_txnq_wakeup_idx = idxq[0];
                            for(int k=1; k<idxq.size(); k++) begin
                                //`uvm_info("DCE_SCB", $psprintf("idx:%0d txnq_idx:%0d dm_time:%0t int_val:%0d attid:0x%0h attid_status:%0p", k, idxq[k], m_dce_txnq[idxq[k]].t_dm_cmdreq, longint'(m_dce_txnq[idxq[k]].t_dm_cmdreq), m_dce_txnq[idxq[k]].m_attid, m_dce_txnq[idxq[k]].m_attid_status), UVM_LOW)
                                if (longint'(m_dce_txnq[idxq[k]].t_dm_cmdreq) < longint'(m_dce_txnq[dce_txnq_wakeup_idx].t_dm_cmdreq)) begin
                                    dce_txnq_wakeup_idx = idxq[k];
                                    //`uvm_info("DCE_SCB", $psprintf("picked_idx:%0d txnq_idx:%0d", k, idxq[k]), UVM_LOW)
                                end
                            end
                            `uvm_info("DCE_SCB", $psprintf("Wake up dce_txnq_idx: %0d attid: 0x%0h on attid:0x%0h dealloc", dce_txnq_wakeup_idx, m_dce_txnq[dce_txnq_wakeup_idx].m_attid, i), UVM_LOW)
                            m_dce_txnq[dce_txnq_wakeup_idx].m_attid_status = ATTID_IS_WAKEUP;
                        end
                    end

                    m_dirm_mgr.clear_busy_on_attid_dealloc({m_attvld_aa[i].m_initcmdupd_req_pkt.smi_ns, m_attvld_aa[i].m_initcmdupd_req_pkt.smi_addr});
                   `uvm_info(get_name(), $psprintf("[%-35s] (txnId: %5d) {%20s} (src: 0x%02h {%s}) (tgt: 0x%02h) (msgId: 0x%02h) (attid : 0x%02h) (rbid: 0x%02h) (addr: 0x%016h)", "DceScbd-AttDealloc", m_attvld_aa[i].m_txn_id, m_attvld_aa[i].m_initcmdupd_req_pkt.type2cmdname(), m_attvld_aa[i].m_initcmdupd_req_pkt.smi_src_ncore_unit_id, addrMgrConst::get_cache_id_as_string(m_attvld_aa[i].m_initcmdupd_req_pkt.smi_src_ncore_unit_id), m_attvld_aa[i].m_initcmdupd_req_pkt.smi_targ_ncore_unit_id, m_attvld_aa[i].m_initcmdupd_req_pkt.smi_msg_id, m_attvld_aa[i].m_attid, m_attvld_aa[i].m_rbid, m_attvld_aa[i].m_initcmdupd_req_pkt.smi_addr), UVM_LOW);
                    m_attvld_aa.delete(i);

                    //check that the entry in dce_txnq is still valid
                    if ((m_dce_txnq[dce_txnq_idx].m_attid != i) || (m_dce_txnq[dce_txnq_idx].m_attid_status == ATTID_IS_INACTIVE)) begin
                       `uvm_error("DCE_SCB", $psprintf("attid:0x%0h (dec:%0d) gets prematurely removed from dce_txnq during attid deallocation", i, i))
                    end else begin 
                       `uvm_info("DCE_SCB", $psprintf("attid:0x%0h (dec:%0d) can be removed from dce_txnq event triggered (dceTxnIdx: %1d)\n%s", i, i, dce_txnq_idx,m_dce_txnq[dce_txnq_idx].convert2string()), UVM_LOW)
                        m_deallocated_attidq.push_back(i);
                        m_dce_txnq[dce_txnq_idx].m_attid_deleted_time = $time;
                        process_txn = 1;
                    end
                end //entry exists in m_attvld_aa
            end //DV agrees on attid deallocation
            //end //jdxq.size == 1 i.e there is a matching entry in dce_txnq for the deallocated attid
            //else begin 
            //  `uvm_error("DCE_SCB", $psprintf("%0d matches for the deallocated attid:0x%0h (dec:%0d)", jdxq.size(), i, i))
            //end
        end //attid deallocation 
    end //loop through all attids

    if(process_txn == 1) begin
        -> e_txn_comp;
    end

    foreach(m_attvld_aa[i]) begin
        $sformat(s, "%0s %0d(addr:0x%0h ns:%0b)", s, i, m_attvld_aa[i].m_initcmdupd_req_pkt.smi_addr, m_attvld_aa[i].m_initcmdupd_req_pkt.smi_ns);
    end
    
    //`uvm_info("DCE_SCB", $psprintf("Waiting to be deallocated attids: %0s", s), UVM_LOW)
    
    //save this to previous
    m_attvld_vec_prev = attvld_vec_i;
endfunction: write_tm_port

function void dce_scb::write_cycle_tracker_port(cycle_tracker_s cycle_tracker);
    int fnd_idxq[$], fnd_jdxq[$], fnd_dce_txnq_idxq[$], sb_entriesq[$], fnd_dce_sys_co_txn_idxq[$];
    string s;
    bit sb_entries_update_needed = 0;
    //`uvm_info("DCE SCB", $psprintf("CYCLE_TRACKER BEGIN: time:%0t cycle_count:%0d sb_empty:%0b event_counter:%0d", cycle_tracker.m_time, cycle_tracker.m_cycle_count, sb_empty, m_qosEventCounter), UVM_LOW)

    foreach (m_dce_txnq[idx]) begin
        if (m_dce_txnq[idx].m_garbage_dmiid &&
            m_dce_txnq[idx].m_req_type == REC_REQ
           ) begin 
            m_dce_txnq[idx].m_states["rbureq"].clear_expect();
            m_dce_txnq[idx].m_states["rbursp"].clear_expect();
            m_dce_txnq[idx].m_states["rbureq"].set_complete();
            m_dce_txnq[idx].m_states["rbursp"].set_complete();
        end 
    end
    snoop_enable_reg_prev = snoop_enable_reg;
    fnd_dce_sys_co_txn_idxq = m_dce_txnq.find_index(item) with (item.m_req_type == SYSCO_REQ && item.m_states["sysrsp"].is_complete() == 0);
    if(fnd_dce_sys_co_txn_idxq.size != 0) begin //Added this to stay in Sync with RTL
        foreach(fnd_dce_sys_co_txn_idxq[x]) begin
            if((($time - m_dce_txnq[fnd_dce_sys_co_txn_idxq[x]].t_sysreq_process) / CLK_PERIOD) inside {3,4}) begin
                if(m_dce_txnq[fnd_dce_sys_co_txn_idxq[x]].m_initsys_co_req_pkt.smi_sysreq_op == 1) begin
                    snoop_enable_reg[m_dce_txnq[fnd_dce_sys_co_txn_idxq[x]].m_initsys_co_req_pkt.smi_src_ncore_unit_id] = 1'b1;
                    snoop_enable_reg_sys_rsp[m_dce_txnq[fnd_dce_sys_co_txn_idxq[x]].m_initsys_co_req_pkt.smi_src_ncore_unit_id] = 1;
                end else if(m_dce_txnq[fnd_dce_sys_co_txn_idxq[x]].m_initsys_co_req_pkt.smi_sysreq_op == 2)
                    snoop_enable_reg[m_dce_txnq[fnd_dce_sys_co_txn_idxq[x]].m_initsys_co_req_pkt.smi_src_ncore_unit_id] = 1'b0;
                else
                    `uvm_error("DCE_SCB",$psprintf("Need to debug"))
                m_dce_txnq[fnd_dce_sys_co_txn_idxq[x]].t_sysreq_process = 0;
                `uvm_info("DCE_SCB",$psprintf("Updating snoop_enable_reg to %p, agent = %d cache_id = %d",snoop_enable_reg,m_dce_txnq[fnd_dce_sys_co_txn_idxq[x]].m_initsys_co_req_pkt.smi_src_ncore_unit_id,addrMgrConst::get_cache_id(m_dce_txnq[fnd_dce_sys_co_txn_idxq[x]].m_initsys_co_req_pkt.smi_src_ncore_unit_id)),UVM_LOW)
            end
        end
    end
    

    //Only if QOS is enabled
    if ((m_qosStarvationMode == 0) && (addrMgrConst::get_highest_qos() != 0) && (m_env_cfg.m_qoscr_event_threshold != 0)) begin

        if (cycle_tracker.m_cycle_count == (sb_entries_updated_cycle_count + 1)) begin 
            m_qosEventCounter = 0;
            if (starvRequest_exists == 1) begin 
                m_qosStarvationMode = 1; //we have entered starvation mode.
                starvRequest_exists = 0;
                //perf monitor
                sb_stall_if.perf_count_events["Number_of_QoS_Starvations"].push_back(1);
            end
        end else if ((sb_cmdrsp_captured.m_cycle_count > 0) && (cycle_tracker.m_cycle_count == (sb_cmdrsp_captured.m_cycle_count + 1))) begin
            
            if (sb_empty == 0) begin 
                m_qosEventCounter = m_qosEventCounter + 1;
            end
            fnd_dce_txnq_idxq = m_dce_txnq.find_index(item) with (
              (item.m_req_type == CMD_REQ) &&
              (item.m_initcmdupd_req_pkt.smi_src_ncore_unit_id == (sb_cmdrsp_captured.tgtid >> WSMINCOREPORTID)) &&
              (item.m_initcmdupd_req_pkt.smi_msg_id            == sb_cmdrsp_captured.rmsgid) && 
              (item.m_states["cmdupdrsp"].is_valid() == 0) &&
              (item.m_states["cmdupdrsp"].is_complete() == 0) );
        
            if (fnd_dce_txnq_idxq.size() == 0 && garbage_dmiid)
                return;
            //Checks for SB Probe CmdUpd Rsp Pkt to make sure it maps to only one entry in dce_scb_txnq
            if (fnd_dce_txnq_idxq.size() != 1 && !$test$plusargs("uncorr_skid_buffer_test")) begin 
                `uvm_error("DCE SCB", $sformatf("%0d matches Skid Buffer Probe CmdRsp Captured", fnd_dce_txnq_idxq.size()))
            end 
        end 
        if (m_qosEventCounter == m_env_cfg.m_qoscr_event_threshold) begin
            sb_entries_update_needed = 1;
        end
        sb_entriesq = m_dce_txnq.find_index(item) with (   (item.m_req_type == CMD_REQ)
                                                        && (item.t_conc_mux_cmdreq > 0)
                                                        && (item.arb_valid == 1)
                                                        && (item.m_states["sb_cmdrsp"].is_valid() == 0)
                                                        && (item.m_states["sb_cmdrsp"].is_complete() == 0));
        
        sb_empty = (sb_entriesq.size() == 0) ? 1 : 0;
        //`uvm_info("DCE SCB", $sformatf("CYCLE_TRACKER -- sb_entries size:%0d event_counter:%0d", sb_entriesq.size(), m_qosEventCounter), UVM_LOW)
    end

    if (sb_entries_update_needed == 1) begin 

        //`uvm_info("DCE SCB", $psprintf("Skid Buffer CMD_RSP_CAPTURED: cyc_cnt:%0d, master_funitid:%p, msgid:%p starv_mode:%0d sb_entries_upd_needed:%0d sb_empty:%0b", sb_cmdrsp_captured.m_cycle_count, sb_cmdrsp_captured.tgtid >> WSMINCOREPORTID, sb_cmdrsp_captured.rmsgid, sb_cmdrsp_captured.starv_mode, sb_entries_update_needed, sb_empty), UVM_LOW)



        //find all active requests with starvOverflow=0
        fnd_idxq = m_dce_txnq.find_index(item) with (      (item.m_req_type == CMD_REQ)
                                                        && (    (item.m_initcmdupd_req_pkt.smi_msg_id != m_dce_txnq[fnd_dce_txnq_idxq[0]].m_initcmdupd_req_pkt.smi_msg_id)                                              || (item.m_initcmdupd_req_pkt.smi_src_ncore_unit_id != m_dce_txnq[fnd_dce_txnq_idxq[0]].m_initcmdupd_req_pkt.smi_src_ncore_unit_id))
                                                        && (item.m_initcmdupd_req_pkt.t_smi_ndp_valid <= sb_cmdrsp_captured.m_time)
                                                        && (item.t_conc_mux_cmdreq > 0 && (item.t_conc_mux_cmdreq <= sb_cmdrsp_captured.m_time))
                                                        && (item.arb_valid == 1)
                                                        && (item.m_states["sb_cmdrsp"].is_valid() == 0)
                                                        && (item.m_states["sb_cmdrsp"].is_complete() == 0)
                                                        && (item.m_starvOverflow == 0));
            
        //find all active requests with starvOverflow=1
        fnd_jdxq = m_dce_txnq.find_index(item) with (      (item.m_req_type == CMD_REQ)
                                                        && (    (item.m_initcmdupd_req_pkt.smi_msg_id != m_dce_txnq[fnd_dce_txnq_idxq[0]].m_initcmdupd_req_pkt.smi_msg_id)                                              || (item.m_initcmdupd_req_pkt.smi_src_ncore_unit_id != m_dce_txnq[fnd_dce_txnq_idxq[0]].m_initcmdupd_req_pkt.smi_src_ncore_unit_id))
                                                            && (item.m_initcmdupd_req_pkt.t_smi_ndp_valid < sb_cmdrsp_captured.m_time)
                                                            && (item.arb_valid == 1)
                                                            && (item.m_states["sb_cmdrsp"].is_valid() == 0)
                                                            && (item.m_states["sb_cmdrsp"].is_complete() == 0)
                                                            && (item.m_starvOverflow == 1)
                                                            && (item.m_starvRequest == 0));


        if (fnd_idxq.size() != 0) begin 
            s = "";
            foreach(fnd_idxq[i]) begin 
                $sformat(s, "%0s idx:%0d srcid:0x%0h msgid:0x%0h smi_pri:0x%0h starvOverflow:%0d starvRequest:%0d\n", s, i, m_dce_txnq[fnd_idxq[i]].m_initcmdupd_req_pkt.smi_src_ncore_unit_id,m_dce_txnq[fnd_idxq[i]].m_initcmdupd_req_pkt.smi_msg_id, m_dce_txnq[fnd_idxq[i]].m_initcmdupd_req_pkt.smi_msg_pri, m_dce_txnq[fnd_idxq[i]].m_starvOverflow, m_dce_txnq[fnd_idxq[i]].m_starvRequest); 
            end
            //`uvm_info("DCE_SCB" , $psprintf("List of active requests with starvOverflow=0 that would be marked as starvOverflow request\n %0s", s), UVM_LOW)
            for(int i = 0; i < fnd_idxq.size(); i++)
                m_dce_txnq[fnd_idxq[i]].m_starvOverflow = 1;
        end else begin 
            //`uvm_info("DCE_SCB" , "No active requests with starvOverflow=0", UVM_LOW)
        end
            
        if (fnd_jdxq.size() != 0) begin 
            s = "";
            foreach(fnd_jdxq[i]) begin 
                $sformat(s, "%0s idx:%0d srcid:0x%0h msgid:0x%0h smi_pri:0x%0h starvOverflow:%0d starvRequest:%0d\n", s, i, m_dce_txnq[fnd_jdxq[i]].m_initcmdupd_req_pkt.smi_src_ncore_unit_id,m_dce_txnq[fnd_jdxq[i]].m_initcmdupd_req_pkt.smi_msg_id, m_dce_txnq[fnd_jdxq[i]].m_initcmdupd_req_pkt.smi_msg_pri, m_dce_txnq[fnd_jdxq[i]].m_starvOverflow, m_dce_txnq[fnd_jdxq[i]].m_starvRequest); 
            end
            //`uvm_info("DCE_SCB" , $psprintf("List of active requests with starvOverflow=1 that would be marked starvRequest\n %0s", s), UVM_LOW)
            for(int i = 0; i < fnd_jdxq.size(); i++)
                m_dce_txnq[fnd_jdxq[i]].m_starvRequest = 1;
            starvRequest_exists = 1;
        end else begin 
            //`uvm_info("DCE_SCB" , "No active requests with starvOverflow=1", UVM_LOW)
        end
        sb_entries_updated_cycle_count = cycle_tracker.m_cycle_count;
    end

    //`uvm_info("DCE SCB", $psprintf("CYCLE_TRACKER END: event_counter:%0d", m_qosEventCounter), UVM_LOW)
endfunction: write_cycle_tracker_port

//*********************************************************************
function void dce_scb::write_conc_mux_cmdreq_port(probe_cmdreq_s conc_mux_cmdreq);
    int idxq[$];    

    if ($test$plusargs("wrong_cmdreq_target_id") || $test$plusargs("wrong_updreq_target_id") || garbage_dmiid) begin
        return;
    end
    //`uvm_info("DCE SCB", $sformatf("%t conc_mux_cmdreq: cyc_cnt:%0d, iid:0x%0h, msg_id:0x%0h, addr:0x%0h ns:%0b msg_type:%0p", conc_mux_cmdreq.m_time, conc_mux_cmdreq.cycle_count, conc_mux_cmdreq.iid, conc_mux_cmdreq.msg_id,  conc_mux_cmdreq.addr, conc_mux_cmdreq.ns, conc_mux_cmdreq.cm_type), UVM_LOW)

    idxq = m_dce_txnq.find_index(item) with (
        (item.m_initcmdupd_req_pkt.smi_msg_id            == conc_mux_cmdreq.msg_id) &&
        (item.m_initcmdupd_req_pkt.smi_addr              == conc_mux_cmdreq.addr) &&
        (item.m_initcmdupd_req_pkt.smi_ns                == conc_mux_cmdreq.ns) &&
        (item.m_initcmdupd_req_pkt.smi_src_ncore_unit_id == (conc_mux_cmdreq.iid >> WSMINCOREPORTID)) &&
        (item.m_initcmdupd_req_pkt.smi_msg_type          == conc_mux_cmdreq.cm_type) &&
        (item.t_dm_cmdreq == 0));

        //foreach(m_dce_txnq[i]) begin 
        //  `uvm_info("DCE SCB", $sformatf("msg_id:%0p addr:%0p ns:%0p src_id:%0p msg_type:%0p t_dm:%0p", 
        //      m_dce_txnq[i].m_initcmdupd_req_pkt.smi_msg_id,
        //      m_dce_txnq[i].m_initcmdupd_req_pkt.smi_addr,
        //      m_dce_txnq[i].m_initcmdupd_req_pkt.smi_ns,
        //      m_dce_txnq[i].m_initcmdupd_req_pkt.smi_src_ncore_unit_id,
        //      m_dce_txnq[i].m_initcmdupd_req_pkt.smi_msg_type,
        //      m_dce_txnq[i].t_dm_cmdreq), UVM_LOW)
        //end

    if (idxq.size() == 0 || idxq.size() > 1) begin
        foreach(m_dce_txnq[k]) begin
         `uvm_info(get_name(), $psprintf("[%-35s] [cmd: %25s] [src: 0x%02h] [msgId: 0x%02h] [msgType: 0x%02h] [ns: %1b] [addr: 0x%016h]", "DceScbd-ConcMuxDbg", m_dce_txnq[k].m_initcmdupd_req_pkt.type2cmdname(), m_dce_txnq[k].m_initcmdupd_req_pkt.smi_src_ncore_unit_id, m_dce_txnq[k].m_initcmdupd_req_pkt.smi_msg_id, m_dce_txnq[k].m_initcmdupd_req_pkt.smi_msg_type, m_dce_txnq[k].m_initcmdupd_req_pkt.smi_ns, m_dce_txnq[k].m_initcmdupd_req_pkt.smi_addr), UVM_NONE); 
        end
        `uvm_error("DCE SCB", $sformatf("%0d matches in dce_txnq for conc_mux_cmdreq (src: 0x%02h {%s}) (cmType: 0x%02h) (msgId: 0x%02h) (addr: 0x%016h) (ns: 0x%1b)", idxq.size(), (conc_mux_cmdreq.iid >> WSMINCOREPORTID), addrMgrConst::get_cache_id_as_string(conc_mux_cmdreq.iid >> WSMINCOREPORTID), conc_mux_cmdreq.cm_type, conc_mux_cmdreq.msg_id, conc_mux_cmdreq.addr, conc_mux_cmdreq.ns))
    end

    m_dce_txnq[idxq[0]].t_conc_mux_cmdreq = conc_mux_cmdreq.m_time;
endfunction: write_conc_mux_cmdreq_port 
//*********************************************************************

function void dce_scb::write_arb_cmdreq_port(probe_cmdreq_s arb_cmdreq);
    int idxq[$];    

    if ($test$plusargs("wrong_cmdreq_target_id") || $test$plusargs("wrong_updreq_target_id") || garbage_dmiid || $test$plusargs("uncorr_skid_buffer_test")) begin
        return;
    end

    idxq = m_dce_txnq.find_index(item) with (
        (item.m_initcmdupd_req_pkt.smi_msg_id            == arb_cmdreq.msg_id) &&
        (item.m_initcmdupd_req_pkt.smi_addr              == arb_cmdreq.addr) &&
        (item.m_initcmdupd_req_pkt.smi_ns            == arb_cmdreq.ns) &&
        (item.arb_valid                      == 0) &&
        (item.m_initcmdupd_req_pkt.smi_src_ncore_unit_id     == (arb_cmdreq.iid >> WSMINCOREPORTID)) &&
        (item.m_initcmdupd_req_pkt.smi_msg_type          == arb_cmdreq.cm_type));

    if (idxq.size() == 0 || idxq.size() > 1) 
        `uvm_error("DCE SCB", $sformatf("%0d matches in dce_txnq for arb_cmdreq", idxq.size()))

    m_dce_txnq[idxq[0]].arb_valid = 1'b1;
    m_dce_txnq[idxq[0]].arb_valid_time = arb_cmdreq.m_time;

        //`uvm_info("DCE_SCB_ARB", $psprintf("%t arb_cmdreq: cyc_cnt:%0d, iid:0x%0h, msg_id:0x%0h, addr:0x%0h ns:%0b msg_type:%0p", arb_cmdreq.m_time, arb_cmdreq.cycle_count, arb_cmdreq.iid, arb_cmdreq.msg_id,  arb_cmdreq.addr, arb_cmdreq.ns, arb_cmdreq.cm_type), UVM_LOW)

endfunction: write_arb_cmdreq_port  
//*********************************************************************
function void dce_scb::write_sb_syscorsp_port(smi_ncore_unit_id_bit_t syscorsp_trgtid);
    int idxq[$];
    int sys_reqsq[$];
    
    idxq = m_dce_txnq.find_index(item) with (
          item.m_initsys_co_req_pkt.smi_src_ncore_unit_id == syscorsp_trgtid &&
         !item.m_states["sb_sysrsp"].is_complete() );
    
    if(idxq.size() != 1) begin
        `uvm_error("DCE_SCB",$psprintf("Error in SysRsp write port. Likely there's a pending previous SysRsp idxq.size()=%0d", idxq.size()))
    end
    if(snoop_count[syscorsp_trgtid] != 0 && snoop_enable_reg[syscorsp_trgtid] == 1'b0 && event_count[syscorsp_trgtid] != 0) begin  //Adding snoop_enable to differentiate btw attach rsp or detach rsp
    `uvm_info("DCE_SCB_SNPCO",$psprintf("snoop_count[%d] = %d",syscorsp_trgtid,snoop_count[syscorsp_trgtid]),UVM_LOW)
    foreach(m_dce_txnq[x]) begin
        if(m_dce_txnq[x].m_expsnp_req_pktq.size() > 0) begin
            foreach(m_dce_txnq[x].m_expsnp_req_pktq[y]) begin
                if(m_dce_txnq[x].m_expsnp_req_pktq[y].smi_targ_ncore_unit_id == syscorsp_trgtid)
                    `uvm_info("DCE_SCB",$psprintf("%s",m_dce_txnq[x].print_txn(1)),UVM_LOW)
            end
        end
    end
        
            `uvm_error("DCE SCB", $psprintf("Recieved SysCoRsp before snoop count is 0"));
    end

    if(m_dce_txnq[idxq[0]].m_initsys_co_req_pkt.smi_sysreq_op == 1) begin
        snoop_enable_reg_sys_rsp[syscorsp_trgtid] = 1;
    end
    else if(m_dce_txnq[idxq[0]].m_initsys_co_req_pkt.smi_sysreq_op == 2) begin
        snoop_enable_reg_sys_rsp[syscorsp_trgtid] = 0;
    end

    m_dce_txnq[idxq[0]].m_states["sb_sysrsp"].set_valid($time);
    
    sys_reqsq = m_dce_txnq.find_first_index(item) with (item.m_req_type == SYSCO_REQ && !item.m_states["sb_sysrsp"].is_complete());
    if(sys_reqsq.size() == 1) begin
        if(m_dce_txnq[sys_reqsq[0]].m_initsys_co_req_pkt.smi_sysreq_op == 1)
            snoop_enable_reg[m_dce_txnq[sys_reqsq[0]].m_initsys_co_req_pkt.smi_src_ncore_unit_id] = 1'b1;
        else if(m_dce_txnq[sys_reqsq[0]].m_initsys_co_req_pkt.smi_sysreq_op == 2)
            snoop_enable_reg[m_dce_txnq[sys_reqsq[0]].m_initsys_co_req_pkt.smi_src_ncore_unit_id] = 1'b0;   
    `uvm_info("DCE_SCB",$psprintf("Updating snoop_enable_reg to %p after prev eSysRsp, agentid = %d cache_id = %d",snoop_enable_reg,m_dce_txnq[sys_reqsq[0]].m_initsys_co_req_pkt.smi_src_ncore_unit_id,addrMgrConst::get_cache_id(m_dce_txnq[sys_reqsq[0]].m_initsys_co_req_pkt.smi_src_ncore_unit_id)),UVM_LOW)
    end 

    if(m_dce_txnq[idxq[0]].m_states["sysrsp"].is_complete) begin
        m_dce_txnq.delete(idxq[0]);
    end
endfunction: write_sb_syscorsp_port 
//*********************************************************************

function void dce_scb::write_sb_cmdrsp_port(sb_cmdrsp_s sb_cmdrsp);
    int fnd_idxq[$], fnd_jdxq[$], fnd_kdxq[$], txn_idxq[$];
    bit [WSMITGTID-1:0] masterid;
    string qos, s;
    masterid = sb_cmdrsp.tgtid >> WSMINCOREPORTID;

    //`uvm_info("DCE SCB", $psprintf("BEGIN dbg:write_sb_cmdrsp_port event_threshold:%0d event_counter:%0d sb_empty:%0b", m_env_cfg.m_qoscr_event_threshold, m_qosEventCounter, sb_empty), UVM_LOW)
    //`uvm_info("DCE SCB", $sformatf("Skid Buffer CMD_RSP: cyc_cnt:%0d, tgt_ncore_unitid:%p, rmsgid:%p starv_mode:%0d", sb_cmdrsp.m_cycle_count, masterid, sb_cmdrsp.rmsgid, sb_cmdrsp.starv_mode), UVM_LOW)

    if ((m_env_cfg.m_qoscr_event_threshold == 0) && (sb_cmdrsp.starv_mode == 1)) begin 
        `uvm_error("DCE SCB", $sformatf("Skid Buffer CMD_RSP: starv_mode:%0d when QOSCR.EventThreshold:%0d", sb_cmdrsp.starv_mode, m_env_cfg.m_qoscr_event_threshold))
    end 
    
    txn_idxq = m_dce_txnq.find_index(item) with (
          item.m_initcmdupd_req_pkt.smi_src_ncore_unit_id == masterid &&
          item.m_initcmdupd_req_pkt.smi_msg_id        == sb_cmdrsp.rmsgid && 
     (item.m_states["cmdupdrsp"].is_valid() == 0) &&
         !item.m_states["cmdupdrsp"].is_complete());
    
    if (txn_idxq.size() == 0 && garbage_dmiid)
        return; 
    //Checks for SB Probe CmdUpd Rsp Pkt to make sure it maps to only one entry in dce_scb_txnq
    if (txn_idxq.size() != 1 && !$test$plusargs("uncorr_skid_buffer_test")) begin 
        `uvm_error("DCE SCB", $sformatf("%0d matches Skid Buffer Probe CmdRsp", txn_idxq.size()))
    end 

    //Exclude QOS checks for a starv mode request 
    if (sb_cmdrsp.starv_mode == 0) begin
        //QOS checks -------------------- begin 
        fnd_idxq = m_dce_txnq.find_index(item) with ((item.m_req_type == CMD_REQ)
                            && (item.m_initcmdupd_req_pkt.smi_msg_pri < m_dce_txnq[txn_idxq[0]].m_initcmdupd_req_pkt.smi_msg_pri)
                            && (item.m_initcmdupd_req_pkt.t_smi_ndp_valid < sb_cmdrsp.m_time)
                            && (item.m_states["sb_cmdrsp"].is_valid() == 0)
                            && (item.m_states["sb_cmdrsp"].is_complete() == 0)
                            && (item.t_conc_mux_cmdreq > 0 && (item.t_conc_mux_cmdreq < sb_cmdrsp.m_time)) //CONC-7215 requests will get into competition based on pri only after they are out of conc_mux
                            && (item.arb_valid == 1 && item.arb_valid_time != $time));

        //Check1: If there are other CMDreqs with lower smi_pri i.e higher priority, then this CmdRsp should not have been issued before them.
        //#Check.DCE.QOS.sb_cmdrsp.Check1
        if (fnd_idxq.size() != 0) begin 
            s = "";
            foreach(fnd_idxq[i]) begin 
                $sformat(s, "%0s idx:%0d srcid:0x%0h msgid:0x%0h smi_pri:0x%0h starvOverflow:%0d starvRequest:%0d and arb_valid:%0d\n", s, i, m_dce_txnq[fnd_idxq[i]].m_initcmdupd_req_pkt.smi_src_ncore_unit_id,m_dce_txnq[fnd_idxq[i]].m_initcmdupd_req_pkt.smi_msg_id, m_dce_txnq[fnd_idxq[i]].m_initcmdupd_req_pkt.smi_msg_pri, m_dce_txnq[fnd_idxq[i]].m_starvOverflow, m_dce_txnq[fnd_idxq[i]].m_starvRequest, m_dce_txnq[fnd_idxq[i]].arb_valid);    
            end
            `uvm_info("DCE_SCB" , $psprintf("%0s", s), UVM_LOW)
            `uvm_error(get_full_name(),$psprintf("CmdRsp with smi_pri:0x%0h ordered before other %0d txns with higher priority", m_dce_txnq[txn_idxq[0]].m_initcmdupd_req_pkt.smi_msg_pri, fnd_idxq.size()))
        end

        fnd_idxq.delete();

        //Check2: If there are other CMDreqs with same smi_pri, the oldest CMDreq should get the CMDrsp
        //#Check.DCE.QOS.sb_cmdrsp.Check2
        fnd_idxq = m_dce_txnq.find_index(item) with (    (item.m_req_type == CMD_REQ)
                                                      && (item.m_initcmdupd_req_pkt.smi_msg_pri == m_dce_txnq[txn_idxq[0]].m_initcmdupd_req_pkt.smi_msg_pri)
                                                      && ((item.m_initcmdupd_req_pkt.smi_msg_id != m_dce_txnq[txn_idxq[0]].m_initcmdupd_req_pkt.smi_msg_id)                                                                     || (item.m_initcmdupd_req_pkt.smi_src_ncore_unit_id != m_dce_txnq[txn_idxq[0]].m_initcmdupd_req_pkt.smi_src_ncore_unit_id))
                                                      && (item.m_initcmdupd_req_pkt.t_smi_ndp_valid < sb_cmdrsp.m_time)
                                                      && (item.m_states["sb_cmdrsp"].is_valid() == 0)
                                                      && (item.m_states["sb_cmdrsp"].is_complete() == 0));

        if (fnd_idxq.size() != 0 && !$test$plusargs("uncorr_skid_buffer_test")) begin
            if (txn_idxq[0] > fnd_idxq[0]) begin
                s = "";
                $sformat(s, "%0s srcid:0x%0h msgid:0x%0h smi_pri:0x%0h starvOverflow:%0d starvRequest:%0d\n", s, m_dce_txnq[fnd_idxq[0]].m_initcmdupd_req_pkt.smi_src_ncore_unit_id, m_dce_txnq[fnd_idxq[0]].m_initcmdupd_req_pkt.smi_msg_id, m_dce_txnq[fnd_idxq[0]].m_initcmdupd_req_pkt.smi_msg_pri, m_dce_txnq[fnd_idxq[0]].m_starvOverflow, m_dce_txnq[fnd_idxq[0]].m_starvRequest );  
                //`uvm_info("DCE_SCB" , $psprintf("%0s", s), UVM_LOW)
                `uvm_error(get_full_name(),$psprintf("CmdRsp is not issued for the oldest txn at idx:%0d with the same smi_pri:0x%0h before current CmdRsp for txn at %0d", fnd_idxq[0], m_dce_txnq[txn_idxq[0]].m_initcmdupd_req_pkt.smi_msg_pri, txn_idxq[0]))
            end
        end
        //QOS checks -----------------------------------------end

        //if we are in starvation Mode - starv_mode request should have been issued.
        //#Check.DCE.QOS.StarvationMode
        if (m_qosStarvationMode == 1) begin 
            `uvm_error(get_full_name(),$psprintf("starvRequest is not being issued when we are in starvationMode"))
        end
        sb_cmdrsp_captured.tgtid         = sb_cmdrsp.tgtid;
        sb_cmdrsp_captured.rmsgid        = sb_cmdrsp.rmsgid;
        sb_cmdrsp_captured.starv_mode        = sb_cmdrsp.starv_mode;
        sb_cmdrsp_captured.m_time        = sb_cmdrsp.m_time;
        sb_cmdrsp_captured.m_cycle_count     = sb_cmdrsp.m_cycle_count;

        //This means a race situation where the cycle we marked StarvedRequest, that one StarvedRequest is sent out, and we have no more StarvedRequests, so we are back to normalMode. Deassert starvRequest_exists 
        if (m_dce_txnq[txn_idxq[0]].m_starvRequest == 1) begin
            //`uvm_info("DCE_SCB" , $psprintf("We hit the race condition"), UVM_LOW)
            fnd_kdxq =  m_dce_txnq.find_index(item) with (      (item.m_req_type == CMD_REQ)
                                                        && (    (item.m_initcmdupd_req_pkt.smi_msg_id != m_dce_txnq[txn_idxq[0]].m_initcmdupd_req_pkt.smi_msg_id)                                                                                     || (item.m_initcmdupd_req_pkt.smi_src_ncore_unit_id != m_dce_txnq[txn_idxq[0]].m_initcmdupd_req_pkt.smi_src_ncore_unit_id))
                                                            && (item.m_initcmdupd_req_pkt.t_smi_ndp_valid < sb_cmdrsp.m_time)
                                                            && (item.m_states["sb_cmdrsp"].is_valid() == 0)
                                                            && (item.m_states["sb_cmdrsp"].is_complete() == 0)
                                                            && (item.m_starvRequest == 1));
            if (fnd_kdxq.size() == 0) begin 
                starvRequest_exists = 0;    
                //`uvm_info("DCE_SCB" , $psprintf("Since there are no more starvedRequests go back to normal mode"), UVM_LOW)
            end

        end


    end//checks only for !starv_mode request 
    else begin //checks for starvRequest
            //if we are in Normal Mode - starv_mode request should not have been issued.
            //#Check.DCE.QOS.NormalMode
            if(!$test$plusargs("uncorr_skid_buffer_test")) begin 
            if (m_qosStarvationMode == 0) begin 
                `uvm_error(get_full_name(),$psprintf("starvRequest is being issued when we are in NormalMode"))
            end

            //check that a starvRequest was issued when in starvation mode
            if (m_dce_txnq[txn_idxq[0]].m_starvRequest != 1) begin
                `uvm_error(get_full_name(),$psprintf("a starvRequest was not issued in qosstarvationMode"))
            end

            fnd_kdxq = m_dce_txnq.find_index(item) with (      (item.m_req_type == CMD_REQ)
                                                            && ( (item.m_initcmdupd_req_pkt.smi_msg_id != m_dce_txnq[txn_idxq[0]].m_initcmdupd_req_pkt.smi_msg_id)                                                                           || (item.m_initcmdupd_req_pkt.smi_src_ncore_unit_id != m_dce_txnq[txn_idxq[0]].m_initcmdupd_req_pkt.smi_src_ncore_unit_id))
                                                            && (item.m_initcmdupd_req_pkt.t_smi_ndp_valid < sb_cmdrsp.m_time)
                                                            && (item.m_states["sb_cmdrsp"].is_valid() == 0)
                                                            && (item.m_states["sb_cmdrsp"].is_complete() == 0)
                                                            && (item.m_starvRequest == 1));

            if (fnd_kdxq.size() != 0) begin 
                s = "";
                foreach(fnd_kdxq[i]) begin 
                    $sformat(s, "%0s idx:%0d srcid:0x%0h msgid:0x%0h smi_pri:0x%0h starvOverflow:%0d starvRequest:%0d\n", s, i, m_dce_txnq[fnd_kdxq[i]].m_initcmdupd_req_pkt.smi_src_ncore_unit_id,m_dce_txnq[fnd_kdxq[i]].m_initcmdupd_req_pkt.smi_msg_id, m_dce_txnq[fnd_kdxq[i]].m_initcmdupd_req_pkt.smi_msg_pri, m_dce_txnq[fnd_kdxq[i]].m_starvOverflow, m_dce_txnq[fnd_kdxq[i]].m_starvRequest );    
                end
                //`uvm_info("DCE_SCB" , $psprintf("List of other active requests with starvRequest=1 so we stay in starvationMode\n %0s", s), UVM_LOW)
            end else begin
                m_qosStarvationMode = 0;
                //`uvm_info("DCE_SCB" , $psprintf("Since there are no other active requests with starvRequest=1 switch to qosNormalMode"), UVM_LOW)
            end
            end
    end

    if (sb_cmdrsp_a.exists(masterid)) begin
        fnd_idxq = sb_cmdrsp_a[masterid].find_index(item) with (item == sb_cmdrsp.rmsgid);
        if (fnd_idxq.size() == 0) begin
            sb_cmdrsp_a[masterid].push_back(sb_cmdrsp.rmsgid);
        end else begin
            //CONC-6568
            `uvm_error("DCE SCB", $sformatf("AIU with srcid:0x%0h reused msgid:0x%0h", sb_cmdrsp.tgtid, sb_cmdrsp.rmsgid))
        end
    end else begin 
        sb_cmdrsp_a[masterid].push_back(sb_cmdrsp.rmsgid);
    end
    qos = "";

    //some debug prints
    $sformat(qos, "%s masterid-0x%0h msgids in queue-", qos, masterid);
    foreach(sb_cmdrsp_a[masterid][i]) begin 
        $sformat(qos, "%s 0x%0h", qos, sb_cmdrsp_a[masterid][i]);
    end 

    m_dce_txnq[txn_idxq[0]].m_states["sb_cmdrsp"].set_valid($time);
    
    //`uvm_info("DCE SCB", $psprintf("END dbg:write_sb_cmdrsp_port event_threshold:%0d event_counter:%0d", m_env_cfg.m_qoscr_event_threshold, m_qosEventCounter), UVM_LOW)

endfunction: write_sb_cmdrsp_port

//**********************************************************
// Q Channel
//**********************************************************
function void dce_scb::write_q_chnl(q_chnl_seq_item m_pkt);
  q_chnl_seq_item m_packet;
  q_chnl_seq_item m_packet_tmp;
  dce_scb_txn     txn;

  m_packet = new();

  $cast(m_packet_tmp, m_pkt);
  m_packet.copy(m_packet_tmp);
      `uvm_info("Q_Channel_resp_chnl", $sformatf("Entered..."), UVM_HIGH)
  //If power_down request has been accepted, at that time no outstanding transaction should be there
  if(m_packet.QACCEPTn == 'b0 && m_packet.QREQn == 'b0 && m_packet.QACTIVE == 'b0) begin
    `uvm_info("Q_Channel_resp_chnl", $sformatf("Q_Channel : Checking WTT and RTT Queue should be empty when Q Channel Req receives Accept."), UVM_HIGH)
    if (m_dce_txnq.size != 0) begin
      `uvm_error("<%=obj.BlockId%>:print_m_dce_txnq_q", $sformatf("Command queue is not empty when rtl asserted QACCEPTn"))
    end
    else begin
      `uvm_info("<%=obj.BlockId%>:print_m_dce_txnq_q", $sformatf("Command queue is empty"), UVM_MEDIUM)
    end
  end

endfunction : write_q_chnl
//**********************************************************
//System_in_event
//**********************************************************
function void dce_scb::write_evt_port(event_in_t sys_event);
    int queue_size;
    int x = 0;

    if(sys_event == req) begin
        //$display("KDB before DceScbd-SysEvtReq event_disable=%0d m_dce_sys_txnq.size=%0d", event_disable, m_dce_sys_txnq.size());
        `uvm_info(get_name(), $psprintf("[%-35s] [event: %p]", "DceScbd-SysEvtRpt", sys_event), UVM_LOW);
        event_in_req_in_flight = 1;
        if(($time/latest_store_pass_time) == 1) begin
            generate_sys_event_reqs();  
        end 
        //$display("KDB after  DceScbd-SysEvtReq event_disable=%0d m_dce_sys_txnq.size=%0d", event_disable, m_dce_sys_txnq.size());
    end
    else if(sys_event == ack) begin
        //$display("KDB before DceScbd-SysEvtReq event_disable=%0d m_dce_sys_txnq.size=%0d", event_disable, m_dce_sys_txnq.size());
       `uvm_info(get_name(), $psprintf("[%-35s] [event: %p] [reqQ: %1d]", "DceScbd-SysEvtRpt", sys_event, m_dce_sys_txnq.size()), UVM_LOW);
        if (event_in_req_in_flight != 1) begin
            `uvm_error("<%=obj.BlockId%>: DCE_SCB_Event_in_ack", $psprintf("Received invalid sys event ack without req"))
        end
        else begin
            event_in_req_in_flight = 0;
            if(m_dce_sys_txnq.size() !=0 ) begin
                if(m_dce_sys_txnq[0].m_states["sysrsp"].is_complete() && event_disable == 0) begin
                    if(m_dce_sys_txnq[0].m_states["sysreq"].is_complete()) begin
                        m_dce_sys_txnq.delete(0);
                    end
                    else begin
                        queue_size = m_dce_sys_txnq[0].m_expsys_event_req_pktq_<%=obj.BlockId%>.size();
                        for(int i = 0; i < queue_size;i++) begin
                            if((m_dce_sys_txnq[0].snoop_enable_reg_txn[m_dce_sys_txnq[0].m_expsys_event_req_pktq_<%=obj.BlockId%>[x].smi_targ_ncore_unit_id] == 0) && m_dce_sys_txnq[0].m_states["sysrsp"].is_complete()) begin
                                m_dce_sys_txnq[0].m_expsys_event_req_pktq_<%=obj.BlockId%>.delete(x);
                                m_dce_sys_txnq[0].m_states["sysreq"].clear_one_expect;
                            end
                        end
                        if(m_dce_sys_txnq[0].m_expsys_event_req_pktq_<%=obj.BlockId%>.size() != 0 && m_dce_sys_txnq[0].m_states["sysrsp"].is_complete()) begin
                            `uvm_error("<%=obj.BlockId%>: DCE_SCB_Event_in_ack", $psprintf("Still DCE need to recieve %p Sys Rsps",m_dce_sys_txnq[0].m_expsys_event_req_pktq_<%=obj.BlockId%>.size()))
                        end
                        else
                            m_dce_sys_txnq.delete(0);
                    end
                end
                else if(event_in_err == 1 && event_disable == 0) begin
                    event_in_err = 0;
                                    //check_sys_rsp_timeout(0);
                    -> e_smi_sys_evt_err;
                end
                else if(!m_dce_sys_txnq[0].m_states["sysreq"].is_complete() && event_disable == 0) begin
                    m_dce_sys_txnq[0].snoop_enable_reg_txn = snoop_enable_reg;
                    m_dce_sys_txnq[0].repredict_sys_evt_req();
                    if(m_dce_sys_txnq[0].m_states["sysreq"].get_expect_count() == 0) begin
                        m_dce_sys_txnq.delete(0);
                    end
                    else begin
                        `uvm_info(get_name(), $psprintf("KDB Expected SysReq.count=%0d \n SysReq Pkt::%0p", m_dce_sys_txnq[0].m_states["sysreq"].get_expect_count(), m_dce_sys_txnq[0]), UVM_LOW);
                        `uvm_error("<%=obj.BlockId%>: DCE_SCB_Event_in_ack",$psprintf("event ack seen before all sysrsp were recieved"))
                    end
                end
                else begin
                    `uvm_error("<%=obj.BlockId%>: DCE_SCB_Event_in_ack", $psprintf("Still DCE need to recieve %p Sys Rsps",m_dce_sys_txnq[0].m_expsys_event_req_pktq_<%=obj.BlockId%>.size()))
                end
            end
        end
    end
    else if(sys_event == err) begin
       `uvm_info(get_name(), $psprintf("[%-35s] [event: %p]", "DceScbd-SysEvtRpt", sys_event), UVM_LOW);
        event_in_err = 1;
        prot_timeout_err = 1;
    end 
    else
       `uvm_error("<%=obj.BlockId%>: DCE_SCB_Event_in_ack", $psprintf("Received invalid sys event"))
endfunction : write_evt_port

//*********************************************************
// Processing task/functions 
//*********************************************************
task dce_scb::process_txn_completion(uvm_phase phase);
    int idxq[$], jdxq[$];
    int completed_dce_txnq_idxq[$];

    for(int i = 0; i < m_dce_txnq.size(); i++) begin
        /*
        idxq = m_deallocated_attidq.find_index(item) with (item == m_dce_txnq[i].m_attid);
        if(idxq.size() > 0) begin
           `uvm_info(get_name(), $psprintf("[%-35s] (txnId: %5d) {%20s} (src: 0x%02h {%s}) (tgt: 0x%02h) (msgId: 0x%02h) (attid : 0x%02h) (rbid: 0x%02h) (addr: 0x%016h) (attStat: %25s) (rtlDealloc: %1b) (compl:%1b | matches:%-2d | obj:%1b)", "DceScbd-DeallocQCheck", m_dce_txnq[i].m_txn_id, m_dce_txnq[i].m_initcmdupd_req_pkt.type2cmdname(), m_dce_txnq[i].m_initcmdupd_req_pkt.smi_src_ncore_unit_id, addrMgrConst::get_cache_id_as_string(m_dce_txnq[i].m_initcmdupd_req_pkt.smi_src_ncore_unit_id), m_dce_txnq[i].m_initcmdupd_req_pkt.smi_targ_ncore_unit_id, m_dce_txnq[i].m_initcmdupd_req_pkt.smi_msg_id, m_dce_txnq[i].m_attid, m_dce_txnq[i].m_rbid, m_dce_txnq[i].m_initcmdupd_req_pkt.smi_addr, m_dce_txnq[i].m_attid_status.name(), m_dce_txnq[i].rtl_deallocated, check_for_completion(i,1), idxq.size(), m_dce_txnq[i].m_objection_dropped), UVM_LOW);
        end
        */

        if(check_for_completion(i,1) && (m_dce_txnq[i].m_attid inside {m_deallocated_attidq}) && m_dce_txnq[i].m_attid_status != ATTID_IS_INACTIVE && (m_dce_txnq[i].m_objection_dropped == 0)) begin 
            <% if(obj.COVER_ON) { %>
            m_cov.collect_dce_scb_txn(m_dce_txnq[i]);
            <% } %>

            drop_objection(phase, i);
            idxq = m_deallocated_attidq.find_index(item) with (item == m_dce_txnq[i].m_attid);

            //Its ok if the attid is in deallocq multiple times, it happens if the previous one did not complete due to waiting on rbureq and attid got reallocated to new one and that one now deallocated.
            //if (idxq.size() != 1)
            //  `uvm_error("DCE_SCB", $psprintf("m_deallocated_attidq has %0d matches for attid:0x%0h (dec:%0d)", idxq.size(), m_dce_txnq[i].m_attid, m_dce_txnq[i].m_attid));
            m_deallocated_attidq.delete(idxq[0]);
           `uvm_info(get_name(), $psprintf("[%-35s] (txnId: %5d) {%20s} (src: 0x%02h {%s}) (tgt: 0x%02h) (msgId: 0x%02h) (attid : 0x%02h) (rbid: 0x%02h) (addr: 0x%016h) (attStat: %25s) (rtlDealloc: %1b) (%10t, %10t, %10t)", "DceScbd-DeallocQDelete", m_dce_txnq[i].m_txn_id, m_dce_txnq[i].m_initcmdupd_req_pkt.type2cmdname(), m_dce_txnq[i].m_initcmdupd_req_pkt.smi_src_ncore_unit_id, addrMgrConst::get_cache_id_as_string(m_dce_txnq[i].m_initcmdupd_req_pkt.smi_src_ncore_unit_id), m_dce_txnq[i].m_initcmdupd_req_pkt.smi_targ_ncore_unit_id, m_dce_txnq[i].m_initcmdupd_req_pkt.smi_msg_id, m_dce_txnq[i].m_attid, m_dce_txnq[i].m_rbid, m_dce_txnq[i].m_initcmdupd_req_pkt.smi_addr, m_dce_txnq[i].m_attid_status.name(), m_dce_txnq[i].rtl_deallocated, m_dce_txnq[i].m_initcmdupd_req_pkt.t_smi_ndp_valid, m_dce_txnq[i].t_conc_mux_cmdreq, m_dce_txnq[i].t_dm_cmdreq), UVM_LOW);
            deallocated_address = m_dce_txnq[i].m_initcmdupd_req_pkt.smi_addr;  

            // YRAMASAMY
            // CONC-12275
            // Queuing up dce txn for deletion only of rbr-rsp has completed even
            // when internal release has happened. We will waive the check for the
            // internally released rbr-rsp in end of simulation check
            if(m_dce_txnq[i].m_states.exists("rbrrsp") && m_dce_txnq[i].m_states.exists("rbrreq")) begin
                if(m_dce_txnq[i].m_states["rbrrsp"].is_complete() && m_dce_txnq[i].m_states["rbrreq"].is_complete()) begin
                    completed_dce_txnq_idxq.push_back(i);
                end
            end
            else begin
                completed_dce_txnq_idxq.push_back(i);
            end

            //TODO: update this event to e_txn_comp
            ->e_attid_dealloc;
        end
    end

    //remove the txnq
    deleted_recall_txnq.delete();
    for(int i = (completed_dce_txnq_idxq.size()-1); i >= 0; i--) begin
        if(m_dce_txnq[completed_dce_txnq_idxq[i]].m_req_type == REC_REQ) begin
           m_dce_txnq[completed_dce_txnq_idxq[i]].m_attid_release_cycle = $time;
           m_dce_txnq[completed_dce_txnq_idxq[i]].m_attid_deleted_time = 0;
           deleted_recall_txnq.push_back(m_dce_txnq[completed_dce_txnq_idxq[i]]);
          `uvm_info("DCE_SCB", $psprintf("Pushing Deleted attid = %0d into deleted recall queue",deleted_recall_txnq[0].m_attid), UVM_LOW)
        end
       `uvm_info(get_name(), $psprintf("[%-35s] (txnId: %5d) {%20s} (src: 0x%02h {%s}) (tgt: 0x%02h) (msgId: 0x%02h) (attid : 0x%02h) (rbid: 0x%02h) (addr: 0x%016h) (%10t, %10t)", "DceScbd-TxnQDel(1)", m_dce_txnq[completed_dce_txnq_idxq[i]].m_txn_id, m_dce_txnq[completed_dce_txnq_idxq[i]].m_initcmdupd_req_pkt.type2cmdname(), m_dce_txnq[completed_dce_txnq_idxq[i]].m_initcmdupd_req_pkt.smi_src_ncore_unit_id, addrMgrConst::get_cache_id_as_string(m_dce_txnq[completed_dce_txnq_idxq[i]].m_initcmdupd_req_pkt.smi_src_ncore_unit_id), m_dce_txnq[completed_dce_txnq_idxq[i]].m_initcmdupd_req_pkt.smi_targ_ncore_unit_id, m_dce_txnq[completed_dce_txnq_idxq[i]].m_initcmdupd_req_pkt.smi_msg_id, m_dce_txnq[completed_dce_txnq_idxq[i]].m_attid, m_dce_txnq[completed_dce_txnq_idxq[i]].m_rbid, m_dce_txnq[completed_dce_txnq_idxq[i]].m_initcmdupd_req_pkt.smi_addr, m_dce_txnq[completed_dce_txnq_idxq[i]].m_initcmdupd_req_pkt.t_smi_ndp_valid, m_dce_txnq[completed_dce_txnq_idxq[i]].t_conc_mux_cmdreq), UVM_LOW);
        m_dce_txnq.delete(completed_dce_txnq_idxq[i]);
    end 
endtask: process_txn_completion

task dce_scb::process_smi_cmdupd_req(uvm_phase phase);
    bit         ex_op, ex_ld, ex_st;
    int         dce_funitidsq[$];
    int         aiu_funitidsq[$];
    string      txn_msg;
    string      state;
    dce_scb_txn scb_txn;
    
    
    if ($test$plusargs("wrong_cmdreq_target_id") || $test$plusargs("wrong_updreq_target_id")) begin
      if (m_smi_tx_cmdupdreq_pkt.smi_targ_ncore_unit_id !== addrMgrConst::get_dce_funitid(0)) begin
        smi_msg_id_cmdupd_req_tgt_id_err[m_smi_tx_cmdupdreq_pkt.smi_msg_id] = m_smi_tx_cmdupdreq_pkt.smi_msg_id;
        `uvm_info("WRONG_TGT_ID", $sformatf("Since request is dropped by DCE block, no need to save the txn - return early"), UVM_LOW)
        return; 
      end
    end
    
    aiu_funitidsq.delete();
    foreach(addrMgrConst::aiu_ids[i]) begin 
        aiu_funitidsq.push_back(addrMgrConst::funit_ids[addrMgrConst::aiu_ids[i]]);
    end
    
    dce_funitidsq.delete();
    foreach(addrMgrConst::dce_ids[i]) begin 
        dce_funitidsq.push_back(addrMgrConst::funit_ids[addrMgrConst::dce_ids[i]]);
    end

    //#Check.DCE.CmdReq.SrcId
    if (((m_smi_tx_cmdupdreq_pkt.smi_src_id >> WSMINCOREPORTID) inside {aiu_funitidsq}) == 0)
        `uvm_error("DCE_WRONG_SRC_ID", $sformatf("CMDreq/UPDreq src id does not match any of the AIU FUnit Ids"))

    //#Check.DCE.CmdReq.TgtFUnitId
    if (((m_smi_tx_cmdupdreq_pkt.smi_targ_id >> WSMINCOREPORTID) inside {dce_funitidsq}) == 0)
        `uvm_error("DCE_WRONG_TGT_ID", $sformatf("CMDreq/UPDreq target id does not match any of the DCE FUnit Ids"))
    
    if(snoop_enable_reg_sys_rsp[m_smi_tx_cmdupdreq_pkt.smi_src_ncore_unit_id] == 0 &&
         (addrMgrConst::get_native_interface(addrMgrConst::get_aiu_funitid(m_smi_tx_cmdupdreq_pkt.smi_src_ncore_unit_id)) inside {addrMgrConst::ACE_AIU, addrMgrConst::CHI_A_AIU, addrMgrConst::CHI_B_AIU, addrMgrConst::CHI_E_AIU} ||
         (addrMgrConst::get_native_interface(addrMgrConst::get_aiu_funitid(m_smi_tx_cmdupdreq_pkt.smi_src_ncore_unit_id)) == addrMgrConst::IO_CACHE_AIU && !m_smi_tx_cmdupdreq_pkt.isCmdMsg())|| //CONC-13212 allow updreq from proxy also when detach
         (addrMgrConst::get_native_interface(addrMgrConst::get_aiu_funitid(m_smi_tx_cmdupdreq_pkt.smi_src_ncore_unit_id)) == addrMgrConst:: ACE_LITE_E_AIU && addrMgrConst::is_owo_enable(addrMgrConst::get_aiu_funitid(m_smi_tx_cmdupdreq_pkt.smi_src_ncore_unit_id))))) begin
        `uvm_error(get_name(),$psprintf("Coherent request %0s sent from detached agent_id=0x%0h %0s", m_smi_tx_cmdupdreq_pkt.smi_msg_type, addrMgrConst::get_aiu_funitid(m_smi_tx_cmdupdreq_pkt.smi_src_ncore_unit_id), addrMgrConst::get_native_interface(addrMgrConst::get_aiu_funitid(m_smi_tx_cmdupdreq_pkt.smi_src_ncore_unit_id))))
        end

    $sformat(txn_msg, "%s txn_agentid_0x%0h(%0p)_msgid_0x%0h", txn_msg, addrMgrConst::agentid_assoc2funitid(m_smi_tx_cmdupdreq_pkt.smi_src_ncore_unit_id), addrMgrConst::get_native_interface(addrMgrConst::agentid_assoc2funitid(m_smi_tx_cmdupdreq_pkt.smi_src_ncore_unit_id)), m_smi_tx_cmdupdreq_pkt.smi_msg_id);

    //Constructing scb_txn with cmd_req info
    scb_txn = new(txn_msg);
    scb_txn.assign_parameters_and_handles(m_credits, m_dm_output_chks_en, m_dv_snpreq_up_chks_en, m_dv_tgtid_chks_en);
    //pass handle to the dir_manager
    scb_txn.m_dirm_mgr = this.m_dirm_mgr;
    
    m_smi_tx_cmdupdreq_pkt.t_smi_ndp_valid = $time;
    scb_txn.t_cmdreq = $time;

    scb_txn.snoop_enable_reg_txn = snoop_enable_reg;
    scb_txn.save_cmdupd_req(m_smi_tx_cmdupdreq_pkt);

    <% if(obj.COVER_ON) { %>
    //pass handle to coverage 
    scb_txn.m_cov = m_cov; 
    <% } %>
    
    m_dce_txnq.push_back(scb_txn);
    `uvm_info("DCE_SCB", $psprintf("%s", scb_txn.print_txn(0)), UVM_LOW);

    ex_op = m_dce_txnq[m_dce_txnq.size()-1].is_exclusive_operation(ex_ld, ex_st);
   `uvm_info(get_name(), $psprintf("[%-35s] (txnId: %5d) {%20s} (src: 0x%02h {%s}) (tgt: 0x%02h) (msgId: 0x%02h) (attid : 0x%02h) (rbid: 0x%02h) (addr: 0x%016h) (exLd: %1b) (exSt: %1b) (%10t, %10t)", "DceScbd-TxnInitCmd", m_dce_txnq[m_dce_txnq.size()-1].m_txn_id, m_dce_txnq[m_dce_txnq.size()-1].m_initcmdupd_req_pkt.type2cmdname(), m_dce_txnq[m_dce_txnq.size()-1].m_initcmdupd_req_pkt.smi_src_ncore_unit_id, addrMgrConst::get_cache_id_as_string(m_dce_txnq[m_dce_txnq.size()-1].m_initcmdupd_req_pkt.smi_src_ncore_unit_id), m_dce_txnq[m_dce_txnq.size()-1].m_initcmdupd_req_pkt.smi_targ_ncore_unit_id, m_dce_txnq[m_dce_txnq.size()-1].m_initcmdupd_req_pkt.smi_msg_id, m_dce_txnq[m_dce_txnq.size()-1].m_attid, m_dce_txnq[m_dce_txnq.size()-1].m_rbid, m_dce_txnq[m_dce_txnq.size()-1].m_initcmdupd_req_pkt.smi_addr, ex_ld, ex_st, m_dce_txnq[m_dce_txnq.size()-1].m_initcmdupd_req_pkt.t_smi_ndp_valid, m_dce_txnq[m_dce_txnq.size()-1].t_conc_mux_cmdreq), UVM_LOW);
    
    //Raise objection 
    phase.raise_objection(this, {txn_msg, " raise objection"});
    m_obj_tracker[m_dce_txnq[m_dce_txnq.size()-1].m_txn_id] = 0;

    num_txns++;
    if(first_cmd_observed == 0) begin
        first_cmd_observed = 1;
        ev_first_scb_txn.trigger();
    end
    if (m_smi_tx_cmdupdreq_pkt.isCmdMsg()) 
        num_coh_reqs++;
    else 
        num_upd_reqs++;

    src_ncore_unit_id[m_smi_tx_cmdupdreq_pkt.smi_src_ncore_unit_id]++;

    if (m_smi_tx_cmdupdreq_pkt.isCmdMsg()) begin
        if (cmd_type.exists(m_smi_tx_cmdupdreq_pkt.smi_msg_type)) begin 
            cmd_type[m_smi_tx_cmdupdreq_pkt.smi_msg_type]++;
        end else begin 
            cmd_type[m_smi_tx_cmdupdreq_pkt.smi_msg_type] = 1;
        end
    end else begin
        if (upd_type.exists(m_smi_tx_cmdupdreq_pkt.smi_msg_type)) begin 
            upd_type[m_smi_tx_cmdupdreq_pkt.smi_msg_type]++;
        end else begin 
            upd_type[m_smi_tx_cmdupdreq_pkt.smi_msg_type] = 1;
        end
    end

    `uvm_info("DCE SCB",$psprintf("%0s is put into dce_txnq, current_qsize: %0d \nTXN:%0d %0s",scb_txn.get_name(), m_dce_txnq.size(), num_txns, scb_txn.print_txn(0)), UVM_LOW)
endtask: process_smi_cmdupd_req

//************************************************************
function void dce_scb::process_smi_cmdupd_rsp(uvm_phase phase);
    int idxq[$], idq[$], jdxq[$];
    int fnd_idxq[$];
    string attids, s;
    
    //#Check.DCE.CmdRsp.RmsgId 
    idxq = m_dce_txnq.find_index(item) with (
          item.m_initcmdupd_req_pkt.smi_src_ncore_unit_id == m_smi_rx_cmdupdrsp_pkt.smi_targ_ncore_unit_id &&
          item.m_initcmdupd_req_pkt.smi_msg_id == m_smi_rx_cmdupdrsp_pkt.smi_rmsg_id && 
         !item.m_states["cmdupdrsp"].is_complete() );

    if (idxq.size() == 0 && 
        ((clean_exit_due_to_wrong_targetid_MRDrsp == 1) ||
         (clean_exit_due_to_wrong_targetid_SNPrsp == 1) ||
         (clean_exit_due_to_wrong_targetid_STRrsp == 1) ||
         (clean_exit_due_to_wrong_targetid_RBrsp == 1) ||
         (clean_exit_due_to_wrong_targetid_STRrsp == 1) ||
        (garbage_dmiid)
        ))
        return;
    
    //Checks for CmdUpd Rsp Pkt
    smi_pktmatch_checks(idxq, m_smi_rx_cmdupdrsp_pkt, "SMI_RX_CmdUpd_Rsp");

    if ($test$plusargs("wrong_cmdreq_target_id") || 
        $test$plusargs("wrong_updreq_target_id") ||
        $test$plusargs("wrong_mrdrsp_target_id")
    ) begin
        if (m_smi_rx_cmdupdrsp_pkt.smi_rmsg_id inside {smi_msg_id_cmdupd_req_tgt_id_err}) begin
           `uvm_error(get_full_name(),$sformatf("DCE not dropping CMDREQ/UPDREQ for target error with cmdupdreq_smi_msg_id = %0h",m_smi_rx_cmdupdrsp_pkt.smi_rmsg_id))
           smi_msg_id_cmdupd_req_tgt_id_err.delete(m_smi_rx_cmdupdrsp_pkt.smi_rmsg_id);
        end
    end

    //set valid and check
    m_dce_txnq[idxq[0]].m_states["cmdupdrsp"].set_valid($time);
    m_dce_txnq[idxq[0]].check_cmdupd_rsp(m_smi_rx_cmdupdrsp_pkt); //TODO: Update what fields to check for CmdUpd Rsp?? 
    `uvm_info("DCE_SCB", $psprintf("%s", m_dce_txnq[idxq[0]].print_txn(0)), UVM_LOW);
    
    //Check for completion
    if (check_for_completion(idxq[0])) begin 
        if (m_dce_txnq[idxq[0]].m_req_type == UPD_REQ) begin
            <% if(obj.COVER_ON) { %>
            m_cov.collect_dce_scb_txn(m_dce_txnq[idxq[0]]);
            <% } %>

            //save this upd_transation since it is needed by cachemodel to predict master update based on updreq pass/fail
            void'($cast(m_updreq_txn, m_dce_txnq[idxq[0]].clone()));
           `uvm_info(get_name(), $psprintf("[%-35s] (txnId: %5d) {%20s} (src: 0x%02h {%s}) (tgt: 0x%02h) (msgId: 0x%02h) (attid : 0x%02h) (rbid: 0x%02h) (addr: 0x%016h) (%10t, %10t)", "DceScbd-TxnQDel(2)", m_dce_txnq[idxq[0]].m_txn_id, m_dce_txnq[idxq[0]].m_initcmdupd_req_pkt.type2cmdname(), m_dce_txnq[idxq[0]].m_initcmdupd_req_pkt.smi_src_ncore_unit_id, addrMgrConst::get_cache_id_as_string(m_dce_txnq[idxq[0]].m_initcmdupd_req_pkt.smi_src_ncore_unit_id), m_dce_txnq[idxq[0]].m_initcmdupd_req_pkt.smi_targ_ncore_unit_id, m_dce_txnq[idxq[0]].m_initcmdupd_req_pkt.smi_msg_id, m_dce_txnq[idxq[0]].m_attid, m_dce_txnq[idxq[0]].m_rbid, m_dce_txnq[idxq[0]].m_initcmdupd_req_pkt.smi_addr, m_dce_txnq[idxq[0]].m_initcmdupd_req_pkt.t_smi_ndp_valid, m_dce_txnq[idxq[0]].t_conc_mux_cmdreq), UVM_LOW);
            drop_objection(phase, idxq[0]);
            m_dce_txnq.delete(idxq[0]);
            -> e_attid_dealloc;
        end else begin 
            -> e_txn_comp;
        end
    end else begin
        //`uvm_info("DBG", $psprintf("On CMDUPD_RSP %0s not deleted from dce_txnq", m_dce_txnq[idxq[0]].print_txn(1)), UVM_LOW);  
    end

endfunction: process_smi_cmdupd_rsp


//***********************************************************
function void dce_scb::process_smi_snp_req();
    string s, credits_msg;
    dce_scb_txn rec_txns[$];
    int idxq[$], snp_idxq[$];
    int snp_latency;
    int available_credits;

    if (clean_exit_due_to_wrong_targetid_RBrsp)
        return;

    idxq = m_dce_txnq.find_index(item) with ( 
        item.m_initcmdupd_req_pkt.smi_addr == m_smi_rx_snpreq_pkt.smi_addr   && 
        item.m_initcmdupd_req_pkt.smi_ns   == m_smi_rx_snpreq_pkt.smi_ns     && 
        item.m_attid                       == m_smi_rx_snpreq_pkt.smi_msg_id &&
        item.m_attid_status inside {ATTID_IS_ACTIVE, ATTID_IS_WAKEUP}        &&
        !item.m_states["snpreq"].is_complete());

    if (idxq.size() == 0) begin

        idxq = m_dce_txnq.find_index(item) with (
                         (item.m_req_type == REC_REQ) &&
                         (item.m_dm_pktq[0].m_addr == m_smi_rx_snpreq_pkt.smi_addr) &&
                         (item.m_dm_pktq[0].m_ns   == m_smi_rx_snpreq_pkt.smi_ns) &&
                          !item.m_states["snpreq"].is_complete());
        if(idxq.size() > 1) begin

                idxq = m_dce_txnq.find_index(item) with (
                             (item.m_req_type == REC_REQ) &&
                             (item.m_dm_pktq[0].m_addr == m_smi_rx_snpreq_pkt.smi_addr) &&
                             (item.m_dm_pktq[0].m_ns   == m_smi_rx_snpreq_pkt.smi_ns) &&
                             (item.m_attid             == m_smi_rx_snpreq_pkt.smi_msg_id) &&
                              !item.m_states["snpreq"].is_complete());
        end
    end 

    if (idxq.size() == 0 && garbage_dmiid)
        return;

    smi_pktmatch_checks(idxq, m_smi_rx_snpreq_pkt, "SMI Snp Req");
    
    foreach(m_dce_txnq[x]) begin
    if(m_dce_txnq[x].m_req_type == CMD_REQ && m_dce_txnq[x].m_attid_status inside {ATTID_IS_ACTIVE, ATTID_IS_WAKEUP}) begin
        if(m_dce_txnq[x].m_expsnp_req_pktq.size() != 0) begin
            if(m_dce_txnq[x].m_attid != m_smi_rx_snpreq_pkt.smi_msg_id) begin
                snp_idxq = m_dce_txnq[x].m_expsnp_req_pktq.find_index(item) with ( 
                        item.smi_addr == m_smi_rx_snpreq_pkt.smi_addr   && 
                        item.smi_ns   == m_smi_rx_snpreq_pkt.smi_ns &&
                    item.smi_targ_ncore_unit_id == m_smi_rx_snpreq_pkt.smi_targ_ncore_unit_id);
                if(snp_idxq.size != 0)
                    `uvm_error("DCE SCB",$psprintf("SnpReq matched with active SnpReq in attid = %d", m_dce_txnq[x].m_attid))
            end
        end
    end
    if(m_dce_txnq[x].m_req_type == REC_REQ && m_dce_txnq[x].m_attid_status == ATTID_IS_ACTIVE) begin
        if(m_dce_txnq[x].m_expsnp_req_pktq.size() != 0) begin
            if(m_dce_txnq[x].m_attid != m_smi_rx_snpreq_pkt.smi_msg_id) begin
                snp_idxq = m_dce_txnq[x].m_expsnp_req_pktq.find_index(item) with ( 
                        item.smi_addr == m_smi_rx_snpreq_pkt.smi_addr   && 
                        item.smi_ns   == m_smi_rx_snpreq_pkt.smi_ns &&
                    item.smi_targ_ncore_unit_id == m_smi_rx_snpreq_pkt.smi_targ_ncore_unit_id);
                if(snp_idxq.size != 0)
                    `uvm_error("DCE SCB",$psprintf("SnpReq matched with active SnpReq in attid = %d", m_dce_txnq[x].m_attid))
            end
        end
    end
    end

    `uvm_info("DCE_SCB", $psprintf("DCE_UID:%0d: SNP_REQ: %s", m_dce_txnq[idxq[0]].m_txn_id, m_smi_rx_snpreq_pkt.convert2string()), UVM_LOW);

    m_dce_txnq[idxq[0]].m_states["snpreq"].set_valid($time);
    m_dce_txnq[idxq[0]].check_snp_req(m_smi_rx_snpreq_pkt);

    m_dce_txnq[idxq[0]].time_struct.snp_req = $time;

    if(snoop_enable_reg_sys_rsp[m_smi_rx_snpreq_pkt.smi_targ_ncore_unit_id] == 0) begin
    `uvm_error("DCE SCB",$psprintf("Snoop is being sent to detached agent after eSysRsp"))
    end

    snoop_count[m_smi_rx_snpreq_pkt.smi_targ_ncore_unit_id]++;
    `uvm_info("DCE_SCB_SNPCO",$psprintf("snoop_count[%d] = %d",m_smi_rx_snpreq_pkt.smi_targ_ncore_unit_id,snoop_count[m_smi_rx_snpreq_pkt.smi_targ_ncore_unit_id]),UVM_LOW)

    //store snp latency CMD --> SNP
    if (m_dce_txnq[idxq[0]].m_req_type == CMD_REQ) begin 
        snp_latency = ($time - m_dce_txnq[idxq[0]].t_cmdreq) / CLK_PERIOD;
        snp_latencyq.push_back(snp_latency);
       `uvm_info("DBG LATENCY", $psprintf("clk_period:%0t time_snp:%0t time_cmd:%0t snp_latency: %0d", CLK_PERIOD, $time, m_dce_txnq[idxq[0]].t_cmdreq, snp_latency), UVM_LOW);  
    end
    //`uvm_info("DBG", $sformatf("snp_latencyq size:%0d", snp_latencyq.size()), UVM_LOW)

    //increment num_snps
    num_snp_reqs++;
    
    //Credits code
    //#Check.DCE.SnpReq.CreditCheck
    $sformat(credits_msg, "dce%0d_aiu%0d_nSnpInFlight", addrMgrConst::get_dce_funitid(<%=obj.Id%>), m_smi_rx_snpreq_pkt.smi_targ_ncore_unit_id); 
    m_credits.get_credit(credits_msg, available_credits);
    
    <% if(obj.COVER_ON) { %>
        m_cov.collect_snp_mrd_credits_info(1, available_credits);
    <% } %>

endfunction: process_smi_snp_req

//***********************************************************
function void dce_scb::process_smi_snp_rsp(uvm_phase phase);
    string credits_msg;
    int idxq[$];
    int dce_txnq_wakeup_idx, available_credits;


    idxq = m_dce_txnq.find_index(item) with (item.smi_snprsp_maps_to_req(m_smi_tx_snprsp_pkt) &&
                                             (item.m_states["snpreq"].is_valid() >= 1) &&
                                             !item.m_states["snprsp"].is_complete() &&
                                             (item.m_attid == m_smi_tx_snprsp_pkt.smi_rmsg_id));
    
    if (idxq.size == 0 && clean_exit_due_to_wrong_targetid_RBrsp) begin
        return;
    end 

    `uvm_info("DCE_SCB", $psprintf("DCE_UID:%0d: SNP_RESP: %s", m_dce_txnq[idxq[0]].m_txn_id, m_smi_tx_snprsp_pkt.convert2string()), UVM_LOW);
    smi_pktmatch_checks(idxq, m_smi_tx_snprsp_pkt, "SMI Snoop Rsp");

    if ($test$plusargs("wrong_snprsp_target_id")) begin
      if (m_smi_tx_snprsp_pkt.smi_targ_ncore_unit_id !== addrMgrConst::get_dce_funitid(0)) begin
         clean_exit_due_to_wrong_targetid_SNPrsp = 1;

        `uvm_info("DCE SCB", $psprintf("wrong target id for SNPrsp - DCE drops SNPrsp so early return"), UVM_LOW);
        //set completes for rbursp since this request is dropped by DCE and hence rbu_rsp wont be issued.

        foreach(m_dce_txnq[idxq[0]].m_states[idx]) begin
            if (!m_dce_txnq[idxq[0]].m_states[idx].is_complete()) begin
                m_dce_txnq[idxq[0]].m_states[idx].clear_expect();
                m_dce_txnq[idxq[0]].m_states[idx].set_complete();
            end
        end

        //Check for completion
        if (check_for_completion(idxq[0],1)) begin
           `uvm_info(get_name(), $psprintf("[%-35s] (txnId: %5d) {%20s} (src: 0x%02h {%s}) (tgt: 0x%02h) (msgId: 0x%02h) (attid : 0x%02h) (rbid: 0x%02h) (addr: 0x%016h) (%10t, %10t)", "DceScbd-TxnQDel(3)", m_dce_txnq[idxq[0]].m_txn_id, m_dce_txnq[idxq[0]].m_initcmdupd_req_pkt.type2cmdname(), m_dce_txnq[idxq[0]].m_initcmdupd_req_pkt.smi_src_ncore_unit_id, addrMgrConst::get_cache_id_as_string(m_dce_txnq[idxq[0]].m_initcmdupd_req_pkt.smi_src_ncore_unit_id), m_dce_txnq[idxq[0]].m_initcmdupd_req_pkt.smi_targ_ncore_unit_id, m_dce_txnq[idxq[0]].m_initcmdupd_req_pkt.smi_msg_id, m_dce_txnq[idxq[0]].m_attid, m_dce_txnq[idxq[0]].m_rbid, m_dce_txnq[idxq[0]].m_initcmdupd_req_pkt.smi_addr, m_dce_txnq[idxq[0]].m_initcmdupd_req_pkt.t_smi_ndp_valid, m_dce_txnq[idxq[0]].t_conc_mux_cmdreq), UVM_LOW);
            drop_objection(phase, idxq[0]);
            m_dce_txnq.delete(idxq[0]);
            ->e_attid_dealloc;
        end
 
        return;
      end
    end

    //Credits code
    $sformat(credits_msg, "dce%0d_aiu%0d_nSnpInFlight", addrMgrConst::get_dce_funitid(<%=obj.Id%>), m_smi_tx_snprsp_pkt.smi_src_ncore_unit_id); 
    m_credits.put_credit(credits_msg, available_credits);
    
    <% if(obj.COVER_ON) { %>
    m_cov.collect_snp_mrd_credits_info(1, available_credits);
    <% } %>
    
    m_dce_txnq[idxq[0]].m_states["snprsp"].set_valid($time);
    m_dce_txnq[idxq[0]].save_snprsp(m_smi_tx_snprsp_pkt);

    m_dce_txnq[idxq[0]].t_last_snprsp = $time;
    m_dce_txnq[idxq[0]].time_struct.snp_rsp = $time;
    snoop_count[m_smi_tx_snprsp_pkt.smi_src_ncore_unit_id]--;
   `uvm_info("DCE_SCB_SNPCO",$psprintf("snoop_count[%d] = %d",m_smi_tx_snprsp_pkt.smi_src_ncore_unit_id,snoop_count[m_smi_tx_snprsp_pkt.smi_src_ncore_unit_id]),UVM_HIGH)

    if(m_dce_txnq[idxq[0]].get_aggregated_snprsp_cmstatus()) begin
        if(m_dce_txnq[idxq[0]].agg_snprsp_cmstatus[3] && m_dce_txnq[idxq[0]].agg_snprsp_cmstatus[2]) begin //cmstatus[2] : DT[1](dt_aiu) and cmstatus[3] : DC
            num_snp_rsp_owner_transfer++;
            sb_stall_if.perf_count_events["Snopp_rsp_Owner_transfer"].push_back(1);
        end 
        if(m_dce_txnq[idxq[0]].agg_snprsp_cmstatus[2] == 0 && m_dce_txnq[idxq[0]].agg_snprsp_cmstatus[1] == 0 && m_dce_txnq[idxq[0]].owner_present) begin //cmstatus[2] : DT[1](dt_aiu) and cmstatus[1] : DT[0](dt_dmi)
            num_snp_rsp_miss++;
            sb_stall_if.perf_count_events["Snoop_rsp_miss"].push_back(1);
        end 

        // YRAMASAMY
        // CONC-12275
        // reason for adding a state variable m_internal_rbr_release is to ensure the fsys bench doesnt hang when rbr-req doesnt
        // see a rbr-rsp, which can happen when there is an internal release
        if((m_dce_txnq[idxq[0]].agg_snprsp_cmstatus[1] == 0)) begin
            m_dce_txnq[idxq[0]].m_internal_rbr_release = 1;
           `uvm_info(get_name(), $psprintf("[%-35s] (txnId: %5d) {%20s} (src: 0x%02h {%s}) (tgt: 0x%02h) (msgId: 0x%02h) (attid : 0x%02h) (rbid: 0x%02h) (addr: 0x%016h) (%10t, %10t)", "DceScbd-IntRelease", m_dce_txnq[idxq[0]].m_txn_id, m_dce_txnq[idxq[0]].m_initcmdupd_req_pkt.type2cmdname(), m_dce_txnq[idxq[0]].m_initcmdupd_req_pkt.smi_src_ncore_unit_id, addrMgrConst::get_cache_id_as_string(m_dce_txnq[idxq[0]].m_initcmdupd_req_pkt.smi_src_ncore_unit_id), m_dce_txnq[idxq[0]].m_initcmdupd_req_pkt.smi_targ_ncore_unit_id, m_dce_txnq[idxq[0]].m_initcmdupd_req_pkt.smi_msg_id, m_dce_txnq[idxq[0]].m_attid, m_dce_txnq[idxq[0]].m_rbid, m_dce_txnq[idxq[0]].m_initcmdupd_req_pkt.smi_addr, m_dce_txnq[idxq[0]].m_initcmdupd_req_pkt.t_smi_ndp_valid, m_dce_txnq[idxq[0]].t_conc_mux_cmdreq), UVM_LOW);
            <% if(obj.COVER_ON) { %>
            m_cov.cg_rbid_updates_v36.sample(.rbid(m_dce_txnq[idxq[0]].m_rbid[WSMIRBID-2:0]), .gid(m_dce_txnq[idxq[0]].m_rbid >> (WSMIRBID-1)), .req0_rsp1(0), .internal_release(1)); 
            <% } %>
        end

        // CONC-11806: Improved RBID updates 
        // Adding code to predict RBRsp RBID GID after aggr_snprsp[DT_DMI] = 1
        // YRAMASAMY
        // I dont think we need to release rbid as the gid would still need a rbr-rsp to be cleared. 
        // Also for any rbrReq, it has to be accompnied by a rbrRsp to restore gid, which is added as part of rbrReq processing function
        // Question: Can RBR-Req get sent after snoopRsp is received due to Concerto mux congestion?
        /*
        if(m_dce_txnq[idxq[0]].agg_snprsp_cmstatus[1] == 1) begin
            m_dce_txnq[idxq[0]].predict_rb_rsp(m_dce_txnq[idxq[0]].m_rbid[WSMIRBID-1]);
        end
        else begin
            release_rbid(.dmi_id(m_dce_txnq[idxq[0]].m_exprbr_req_pktq[0].smi_targ_ncore_unit_id), .src_id(m_dce_txnq[idxq[0]].m_exprbr_req_pktq[0].smi_src_ncore_unit_id), .att_id(m_dce_txnq[idxq[0]].m_exprbr_req_pktq[0].smi_msg_id), .rbid(m_dce_txnq[idxq[0]].m_rbid), .signature("DceScbd-RbrSnpRelease"));
        end
        */
    end
 
    //wakeup pending ops if any on attid dealloc.
    //#Check.DCE.v36.RBReq.AttRelease
    if (check_for_attid_deallocation(idxq[0])) begin
        m_attvld_aa[m_dce_txnq[idxq[0]].m_attid]  = m_dce_txnq[idxq[0]];
       `uvm_info(get_name(), $psprintf("[%-35s] (txnId: %5d) {%20s} (src: 0x%02h {%s}) (tgt: 0x%02h) (msgId: 0x%02h) (attid : 0x%02h) (rbid: 0x%02h) (addr: 0x%016h) (%10t, %10t)", "DceScbd-AttRelease(2)", m_dce_txnq[idxq[0]].m_txn_id, m_dce_txnq[idxq[0]].m_initcmdupd_req_pkt.type2cmdname(), m_dce_txnq[idxq[0]].m_initcmdupd_req_pkt.smi_src_ncore_unit_id, addrMgrConst::get_cache_id_as_string(m_dce_txnq[idxq[0]].m_initcmdupd_req_pkt.smi_src_ncore_unit_id), m_dce_txnq[idxq[0]].m_initcmdupd_req_pkt.smi_targ_ncore_unit_id, m_dce_txnq[idxq[0]].m_initcmdupd_req_pkt.smi_msg_id, m_dce_txnq[idxq[0]].m_attid, m_dce_txnq[idxq[0]].m_rbid, m_dce_txnq[idxq[0]].m_initcmdupd_req_pkt.smi_addr, m_dce_txnq[idxq[0]].m_initcmdupd_req_pkt.t_smi_ndp_valid, m_dce_txnq[idxq[0]].t_conc_mux_cmdreq), UVM_LOW);
        m_dce_txnq[idxq[0]].m_attid_status        = ATTID_IS_RELEASED;
        m_dce_txnq[idxq[0]].m_attid_release_cycle = $time;
    end 

endfunction: process_smi_snp_rsp

//***********************************************************
function void dce_scb::process_smi_rbr_req(uvm_phase phase);
    int    idxq[$];
    int    rbidxq[$];
    int    rbrsv_latency, rbrls_latency, available_credits;
    int    dmi_rb_index;
    string rbids;

    //#Check.DCE.RBReq_MsgId
    //#Check.DCE.RBReq_TargetId
    // Changes for CONC-12425
    if(m_smi_rx_rbrreq_pkt.smi_rtype == 1) begin // RBR_Reserve_Req
        // YRAMASAMY: finding matches among att deallocated item
        idxq =  m_dce_txnq.find_index(item) with (
                item.m_attid_status               == ATTID_IS_RELEASED                          && 
                item.m_dmiid                      == m_smi_rx_rbrreq_pkt.smi_targ_ncore_unit_id &&
                item.m_attid                      == m_smi_rx_rbrreq_pkt.smi_msg_id             &&
                item.m_rbid                       == m_smi_rx_rbrreq_pkt.smi_rbid               &&
                item.m_rbid_status                == RBID_RESERVED                              &&
                // YRAMASAMY: checking for potentially rbid assigned by snpreq/strreq as multiple of them could get att-released wihtout rbid matchin
               (item.m_states["snpreq"].is_complete() || item.m_states["strreq"].is_complete()) &&                                              
               !item.m_states["rbrreq"].is_complete()                                           &&
               ((item.m_req_type == CMD_REQ && item.m_initcmdupd_req_pkt.smi_addr == m_smi_rx_rbrreq_pkt.smi_addr && item.m_initcmdupd_req_pkt.smi_ns == m_smi_rx_rbrreq_pkt.smi_ns) ||
                (item.m_req_type == REC_REQ && item.m_dm_pktq[0].m_addr           == m_smi_rx_rbrreq_pkt.smi_addr && item.m_dm_pktq[0].m_ns           == m_smi_rx_rbrreq_pkt.smi_ns)));

        // YRAMASAMY: if no mtach, find any active xtn to which the rbr req matches
        if(idxq.size() == 0) begin
            idxq =  m_dce_txnq.find_index(item) with (
                    item.m_attid_status inside {ATTID_IS_ACTIVE, ATTID_IS_WAKEUP}                   &&
                    item.m_dmiid                      == m_smi_rx_rbrreq_pkt.smi_targ_ncore_unit_id &&
                    item.m_attid                      == m_smi_rx_rbrreq_pkt.smi_msg_id             &&
                   !item.m_states["rbrreq"].is_complete()                                           &&
                   ((item.m_req_type == CMD_REQ && item.m_initcmdupd_req_pkt.smi_addr == m_smi_rx_rbrreq_pkt.smi_addr && item.m_initcmdupd_req_pkt.smi_ns == m_smi_rx_rbrreq_pkt.smi_ns) ||
                    (item.m_req_type == REC_REQ && item.m_dm_pktq[0].m_addr           == m_smi_rx_rbrreq_pkt.smi_addr && item.m_dm_pktq[0].m_ns           == m_smi_rx_rbrreq_pkt.smi_ns)));
        end

        <% if(obj.COVER_ON) { %>
        m_cov.cg_rbid_updates_v36.sample(.rbid(m_smi_rx_rbrreq_pkt.smi_rbid[WSMIRBID-2:0]), .gid(m_smi_rx_rbrreq_pkt.smi_rbid >> (WSMIRBID-1)), .req0_rsp1(0), .internal_release(0)); 
        <% } %>

        // Old code
        // RTL's dmiid computation is garbage due to no_address hit. Hence dont use m_dmiid for comparison to go past fail. CONC-6276
        // assign RTL's dmiid to DV expectation to go past all matches
        if (idxq.size() == 0 && 
            ($test$plusargs("k_csr_seq=dce_csr_no_address_hit_seq") ||
            ($test$plusargs("k_csr_seq=dce_csr_address_region_overlap_seq")))) begin 
            garbage_dmiid = 1;
            idxq = m_dce_txnq.find_index(item) with (
                         (item.m_req_type          == REC_REQ)                      &&
                         (item.m_dm_pktq[0].m_addr == m_smi_rx_rbrreq_pkt.smi_addr) &&
                         (item.m_dm_pktq[0].m_ns   == m_smi_rx_rbrreq_pkt.smi_ns)   &&
                         (item.m_states["rbrreq"].get_valid_count() == 0)           &&
                          !item.m_states["rbrreq"].is_complete());
        end
    end
    else begin
        // CONC-11806: Improved RBID updates 
        //#Check.DCE.v36.RBReq.NoRelease
       `uvm_error(get_name(), $psprintf("[%-35s] Unexpected RBR release req!", "DceScbd-RbReqProc"));
    end

    if (idxq.size() == 0 && 
        (clean_exit_due_to_wrong_targetid_RBrsp  ||
         clean_exit_due_to_wrong_targetid_SNPrsp ||
         clean_exit_due_to_wrong_targetid_STRrsp ||
         garbage_dmiid)
       )
        return;

    // YRAMASAMY: first cut matching incase multiple att-released entries are there which can cause multiple matches
    if(idxq.size() == 0) begin
        idxq = m_dce_txnq.find_index(item) with (
                item.m_req_type                    == CMD_REQ                                    &&
                item.m_initcmdupd_req_pkt.smi_addr == m_smi_rx_rbrreq_pkt.smi_addr               &&
                item.m_initcmdupd_req_pkt.smi_ns   == m_smi_rx_rbrreq_pkt.smi_ns                 &&
                item.m_attid                       == m_smi_rx_rbrreq_pkt.smi_msg_id             &&
                item.m_dmiid                       == m_smi_rx_rbrreq_pkt.smi_targ_ncore_unit_id &&
                // YRAMASAMY: checking for potentially rbid assigned by snpreq/strreq as multiple of them could get att-released wihtout rbid matchin
                item.m_rbid                        == m_smi_rx_rbrreq_pkt.smi_rbid               &&
                item.m_rbid_status                 == RBID_RESERVED                              &&
                (item.m_states["snpreq"].is_complete() || item.m_states["strreq"].is_complete()) &&                                              
                // YRAMASAMY: Improved RBID update: ATT can be released as jammed concMux can potentially delay rbrreq being sent after releasing ATT entry
                item.m_attid_status inside {ATTID_IS_ACTIVE, ATTID_IS_WAKEUP, ATTID_IS_RELEASED} && 
                // YRAMASAMY: Question-Can the below happen? Meaning, RBReq showing up when is_expect of rbrreq is '0'?
                !item.m_states["rbrreq"].is_expect());                                              
    end

    // YRAMASAMY: if no match in the above condition, we just find regular match for the rbreq
    if(idxq.size() == 0) begin
        idxq = m_dce_txnq.find_index(item) with (
                item.m_req_type                    == CMD_REQ                                    &&
                item.m_initcmdupd_req_pkt.smi_addr == m_smi_rx_rbrreq_pkt.smi_addr               &&
                item.m_initcmdupd_req_pkt.smi_ns   == m_smi_rx_rbrreq_pkt.smi_ns                 &&
                item.m_attid                       == m_smi_rx_rbrreq_pkt.smi_msg_id             &&
                item.m_dmiid                       == m_smi_rx_rbrreq_pkt.smi_targ_ncore_unit_id &&
                // YRAMASAMY: Improved RBID update: ATT can be released as jammed concMux can potentially delay rbrreq being sent after releasing ATT entry
                item.m_attid_status inside {ATTID_IS_ACTIVE, ATTID_IS_WAKEUP, ATTID_IS_RELEASED} && 
                // YRAMASAMY: Question-Can the below happen? Meaning, RBReq showing up when is_expect of rbrreq is '0'?
                !item.m_states["rbrreq"].is_expect());                                              

        /* CONC-11806:Improved RBID
        if(idxq.size() == 1) begin
            //m_dce_txnq[idxq[0]].predict_rb_rsv_rls_req();
            // YRAMASAMY
            // I dont think we need to release rbid as the gid would still need a rbr-rsp to be cleared
            //release_rbid(.dmi_id(m_smi_rx_rbrreq_pkt.smi_targ_ncore_unit_id), .src_id(m_smi_rx_rbrreq_pkt.smi_src_ncore_unit_id), .att_id(m_smi_rx_rbrreq_pkt.smi_msg_id), .rbid(m_smi_rx_rbrreq_pkt.smi_rmsg_id), .signature("DceScbd-RbidIntRelease"));
        end
        */
    end

    `uvm_info("DCE_SCB", $psprintf("DCE_UID:%0d: RBR_REQ: %s", m_dce_txnq[idxq[0]].m_txn_id, m_smi_rx_rbrreq_pkt.convert2string()), UVM_LOW);
    //check for rsp2req match
    smi_pktmatch_checks(idxq, m_smi_rx_rbrreq_pkt, "SMI RBR Req");

    //match the DV's dmiid to RTL expectation, so that the transactions are grabbed correctly
    if (garbage_dmiid == 1) begin 
        m_dce_txnq[idxq[0]].m_dmiid = m_smi_rx_rbrreq_pkt.smi_targ_ncore_unit_id;
        m_dce_txnq[idxq[0]].m_garbage_dmiid = 1;
        `uvm_info("DCE SCB", $psprintf("garbage_dmiid encountered for below txn\n %0s",m_dce_txnq[idxq[0]].print_txn(1)), UVM_LOW);
        `uvm_info("DCE SCB", $psprintf("Deleting all pending %0d txns",m_dce_txnq.size()), UVM_LOW);
        for (int i = m_dce_txnq.size()-1; i >= 0; i--) begin
            drop_objection(phase, i);
            m_dce_txnq.delete(i);
        end
        ->e_attid_dealloc;
        return;
    end

    $sformat(rbids, "%s At RBREQ rbids in use before RBreq update for dmiid:0x%0h size:%0d", rbids, m_smi_rx_rbrreq_pkt.smi_targ_ncore_unit_id, m_rbids_in_use[m_smi_rx_rbrreq_pkt.smi_targ_ncore_unit_id].size());
    $sformat(rbids, "%s in_use_rbids are--", rbids);
    for(int i = 0; i < m_rbids_in_use[m_smi_rx_rbrreq_pkt.smi_targ_ncore_unit_id].size(); i++) begin
         $sformat(rbids, "%0s %0d ", rbids, m_rbids_in_use[m_smi_rx_rbrreq_pkt.smi_targ_ncore_unit_id][i]);
    end 
    
    `uvm_info("DCE SCB", $psprintf("%s", rbids), UVM_LOW);

    //RBId Index
    for(int i=0; i < <%=obj.DceInfo[obj.Id].nDceConnectedDmis%>;i++) begin
        if(m_smi_rx_rbrreq_pkt.smi_targ_ncore_unit_id == rbid_range[i].dmi_funit_id) begin
            dmi_rb_index = i;
        end
    end

    //rbid checks *********************************************************** 
    //disable rbid checks when k_csr_seq=dce_csr_no_address_hit_seq is run since RTL's dmiid is garbage anyways. CONC-6276
    if (m_dce_txnq[idxq[0]].m_garbage_dmiid == 0) begin 
        //#Check.DCE.RBReqRBID_Range
        if (    m_smi_rx_rbrreq_pkt.smi_rbid[<%=obj.Widths.Concerto.Ndp.Body.wRBId%>-2:0] > rbid_range[dmi_rb_index].RBId_high
             || m_smi_rx_rbrreq_pkt.smi_rbid[<%=obj.Widths.Concerto.Ndp.Body.wRBId%>-2:0] < rbid_range[dmi_rb_index].RBId_low) begin
              `uvm_error("DCE SCB", $psprintf("RBID:%0d(gid:%1b) is out of bounds for dmi:%0d, nRbsPerDmi:%0d RBID_RANGE_L:%0d RBID_RANGE_U:%0d", m_smi_rx_rbrreq_pkt.smi_rbid[<%=obj.Widths.Concerto.Ndp.Body.wRBId%>-2:0], m_smi_rx_rbrreq_pkt.smi_rbid[<%=obj.Widths.Concerto.Ndp.Body.wRBId%>-1], rbid_range[dmi_rb_index].dmi_funit_id,<%=obj.DceInfo[0].nRbsPerDmi%>, rbid_range[dmi_rb_index].RBId_high, rbid_range[dmi_rb_index].RBId_low));
        end

        //#Check.DCE.RBReq.RBIDAvailabilityCheck
        // CONC-11806: Improved RBID updates 
        if (m_smi_rx_rbrreq_pkt.smi_rbid inside {m_rbids_in_use[m_smi_rx_rbrreq_pkt.smi_targ_ncore_unit_id]}) begin
            `uvm_error("DCE SCB", $psprintf("RBID: 0x%0h is already in use", m_smi_rx_rbrreq_pkt.smi_rbid));
        end else begin
            m_rbids_in_use[m_smi_rx_rbrreq_pkt.smi_targ_ncore_unit_id].push_back(m_smi_rx_rbrreq_pkt.smi_rbid);
           `uvm_info("DCE SCB",$psprintf("At RBREQ after push dmiid:0x%0h size:%0d", m_smi_rx_rbrreq_pkt.smi_targ_ncore_unit_id, m_rbids_in_use[m_smi_rx_rbrreq_pkt.smi_targ_ncore_unit_id].size()), UVM_LOW);
        end
    end
    //rbid checks ************************************************************
   
    rbids = "";
    $sformat(rbids, "%s At RBREQ rbids in use after RBreq update for dmiid:0x%0h size:%0d", rbids, m_smi_rx_rbrreq_pkt.smi_targ_ncore_unit_id, m_rbids_in_use[m_smi_rx_rbrreq_pkt.smi_targ_ncore_unit_id].size());

    
    $sformat(rbids, "%s in_use_rbids are--", rbids);
    for(int i = 0; i < m_rbids_in_use[m_smi_rx_rbrreq_pkt.smi_targ_ncore_unit_id].size(); i++) begin
         $sformat(rbids, "%0s %0d ", rbids, m_rbids_in_use[m_smi_rx_rbrreq_pkt.smi_targ_ncore_unit_id][i]);
    end 
    
    `uvm_info("DCE SCB", $psprintf("%s", rbids), UVM_LOW);

    //Compare rbr request
    m_dce_txnq[idxq[0]].m_states["rbrreq"].set_valid($time);
    m_dce_txnq[idxq[0]].check_rbr_req(m_smi_rx_rbrreq_pkt);

    //store RBR latency CMD --> RB_RSV
    if (m_dce_txnq[idxq[0]].m_req_type == CMD_REQ) begin 
        rbrsv_latency = ($time - m_dce_txnq[idxq[0]].t_cmdreq) / CLK_PERIOD;
        rbrsv_latencyq.push_back(rbrsv_latency);
        m_dce_txnq[idxq[0]].time_struct.rbrsv_req = $time; 
       `uvm_info("DBG LATENCY", $psprintf("clk_period:%0t time_rbrsv:%0t time_cmd:%0t rbrsv_latency: %0d", CLK_PERIOD, $time, m_dce_txnq[idxq[0]].t_cmdreq, rbrsv_latency), UVM_LOW);  
    end
   // `uvm_info("DBG", $sformatf("rbrsv_latencyq size:%0d", rbrsv_latencyq.size()), UVM_LOW)

    <% if(obj.COVER_ON) { %>
        available_credits = <%=obj.DceInfo[0].nRbsPerDmi%> - m_rbids_in_use[m_smi_rx_rbrreq_pkt.smi_targ_ncore_unit_id].size();
        m_cov.collect_rbid_credits_info(RB_RSV, available_credits);
    <% } %>
endfunction: process_smi_rbr_req

//***********************************************************
function void dce_scb::process_smi_rbr_rsp(uvm_phase phase);
    int         idxq[$], idq[$], jdxq[$];
    int         dce_txnq_wakeup_idx, available_credits;
    string      attids;
    dce_scb_txn txn1q[$], txn2q[$];
    
    if (num_smi_uncorr_err>0 || num_smi_parity_err>0) begin
        return;
    end

    if ($test$plusargs("wrong_rbrsp_target_id") && (m_smi_tx_rbrrsp_pkt.smi_targ_ncore_unit_id !== addrMgrConst::get_dce_funitid(0))) begin
         clean_exit_due_to_wrong_targetid_RBrsp = 1;
    end

    txn1q = m_dce_txnq.find(item) with (
            !item.m_states["rbrrsp"].is_complete() &&
            (item.m_states["rbrreq"].is_complete() || (item.m_states["rbrreq"].get_valid_count() == 1)));

    if(txn1q.size() == 0 && (   clean_exit_due_to_wrong_targetid_RBrsp
                             || clean_exit_due_to_wrong_targetid_SNPrsp
                             || clean_exit_due_to_wrong_targetid_STRrsp)) begin 
        return;
    end else if (txn1q.size() == 0) begin
       `uvm_error("DCE SCB", "No pending txns in dce_txnq waiting on rbrrsp");
    end
    
    //RTL's dmiid computation is garbage due to no_address hit. Hence dont use DV's m_dmiid to compare. CONC-6276
    //#Check.DCE.RBRsp_InitiatorId
    //#Check.DCE.RBRsp_RMsgId
    txn2q = txn1q.find(item) with (
            (item.m_attid_status inside {ATTID_IS_ACTIVE, ATTID_IS_WAKEUP, ATTID_IS_RELEASED}) &&
            (item.m_rbid  == m_smi_tx_rbrrsp_pkt.smi_rbid) &&
            (item.m_dmiid == m_smi_tx_rbrrsp_pkt.smi_src_ncore_unit_id)); 

    if(txn2q.size() > 1) begin
       foreach(txn2q[k]) begin
           `uvm_info(get_name(), $psprintf("[%-35s] {%20s} (src: 0x%02h {%s}) (tgt: 0x%02h) (msgId: 0x%02h) (attid : 0x%02h) (rbid: 0x%02h) (addr: 0x%016h) (%10t, %10t)\n%s", "DceScbd-RbrRspErrMatch", txn2q[k].m_initcmdupd_req_pkt.type2cmdname(), txn2q[k].m_initcmdupd_req_pkt.smi_src_ncore_unit_id, addrMgrConst::get_cache_id_as_string(txn2q[k].m_initcmdupd_req_pkt.smi_src_ncore_unit_id), txn2q[k].m_initcmdupd_req_pkt.smi_targ_ncore_unit_id, txn2q[k].m_initcmdupd_req_pkt.smi_msg_id, txn2q[k].m_attid, txn2q[k].m_rbid, txn2q[k].m_initcmdupd_req_pkt.smi_addr, txn2q[k].m_initcmdupd_req_pkt.t_smi_ndp_valid, txn2q[k].t_conc_mux_cmdreq, txn2q[k].m_initcmdupd_req_pkt.convert2string()), UVM_NONE);
       end
       //#Check.DCE.v36.RBReq.InternalRelease
       //#Check.DCE.v36.RBReq.RBIDAlloc
      `uvm_error("DCE SCB", $psprintf("Multiple rbrreq pkts matching for single rbrrsp!\n%s", m_smi_tx_rbrrsp_pkt.convert2string()));
    end
    else if(txn2q.size() == 0) begin
       foreach(txn1q[k]) begin
           `uvm_info(get_name(), $psprintf("[%-35s] {%20s} (src: 0x%02h {%s}) (tgt: 0x%02h) (msgId: 0x%02h) (attid : 0x%02h) (rbid: 0x%02h) (addr: 0x%016h) (%10t, %10t)\n%s", "DceScbd-RbrRspErrMatch", txn1q[k].m_initcmdupd_req_pkt.type2cmdname(), txn1q[k].m_initcmdupd_req_pkt.smi_src_ncore_unit_id, addrMgrConst::get_cache_id_as_string(txn1q[k].m_initcmdupd_req_pkt.smi_src_ncore_unit_id), txn1q[k].m_initcmdupd_req_pkt.smi_targ_ncore_unit_id, txn1q[k].m_initcmdupd_req_pkt.smi_msg_id, txn1q[k].m_attid, txn1q[k].m_rbid, txn1q[k].m_initcmdupd_req_pkt.smi_addr, txn1q[k].m_initcmdupd_req_pkt.t_smi_ndp_valid, txn1q[k].t_conc_mux_cmdreq, txn1q[k].m_initcmdupd_req_pkt.convert2string()), UVM_NONE);
       end
      `uvm_error("DCE SCB", $psprintf("No rbrreq pkts matching for single rbrrsp!\n%s", m_smi_tx_rbrrsp_pkt.convert2string()));
    end

    // CONC-11806: Improved RBID update
    release_rbid(.req_type(txn2q[0].m_req_type), .dmi_id(m_smi_tx_rbrrsp_pkt.smi_src_ncore_unit_id), .src_id(m_smi_tx_rbrrsp_pkt.smi_targ_ncore_unit_id), .rbid(m_smi_tx_rbrrsp_pkt.smi_rbid), .att_id(txn2q[0].m_attid), .signature("DceScbd-RbRspRbidDealloc"));
    <% if(obj.COVER_ON) { %>
    m_cov.cg_rbid_updates_v36.sample(.rbid(m_smi_tx_rbrrsp_pkt.smi_rbid[WSMIRBID-2:0]), .gid(m_smi_tx_rbrrsp_pkt.smi_rbid >> (WSMIRBID-1)), .req0_rsp1(1), .internal_release(0)); 
    <% } %>

    if (txn2q[0].m_req_type == CMD_REQ) begin 
        idxq = m_dce_txnq.find_index(item) with (
               (item.m_req_type                      == CMD_REQ) &&
               (item.m_attid_status                  == txn2q[0].m_attid_status) &&
               (item.m_attid                         == txn2q[0].m_attid) &&
               (item.m_rbid_status                   == RBID_RESERVED) &&
               (item.m_rbid                          == txn2q[0].m_rbid) &&
               (item.m_dmiid                         == txn2q[0].m_dmiid) &&
               (item.m_initcmdupd_req_pkt.smi_msg_id == txn2q[0].m_initcmdupd_req_pkt.smi_msg_id) &&
               (item.m_initcmdupd_req_pkt.smi_src_id == txn2q[0].m_initcmdupd_req_pkt.smi_src_id));
    end else if (txn2q[0].m_req_type == REC_REQ) begin     
         idxq = m_dce_txnq.find_index(item) with (
                (item.m_attid_status inside {ATTID_IS_ACTIVE, ATTID_IS_RELEASED}) &&
                (item.m_req_type                     == REC_REQ) &&
                (item.m_attid                        == txn2q[0].m_attid) &&
                (item.m_rbid_status                  == RBID_RESERVED) &&
                (item.m_rbid                         == txn2q[0].m_rbid) &&
                (item.m_dmiid                        == txn2q[0].m_dmiid));
    end 

    // CONC-12968: 
    // For Improved RBID update, there can be more than one transactions in the queue due to internal release.
    // Hence, picking the first match
    if(idxq.size() > 0) begin
        idxq = {idxq[0]};
    end

    `uvm_info("DCE_SCB", $psprintf("DCE_UID:%0d: RBR_RESP: %s", m_dce_txnq[idxq[0]].m_txn_id, m_smi_tx_rbrrsp_pkt.convert2string()), UVM_LOW);
    // Save rbr_rsp
    m_dce_txnq[idxq[0]].m_states["rbrrsp"].set_valid($time);
    m_dce_txnq[idxq[0]].save_rbrrsp(m_smi_tx_rbrrsp_pkt);
    
    smi_pktmatch_checks(idxq, m_smi_tx_rbrrsp_pkt, "SMI RBR Rsp");
   
    if(m_dce_txnq[idxq[0]].m_states["rbrrsp"].get_valid_count() == 1) begin
        m_dce_txnq[idxq[0]].time_struct.rbrsv_rsp = $time;
    end
    else if(m_dce_txnq[idxq[0]].m_states["rbrrsp"].get_valid_count() == 2) begin
       `uvm_error(get_name(), $psprintf("[%-35s] Unexpected valid count of 2 for rbr rsp! Possible scbd issue", "DceScbd-RbRspProc"));
    end
    
    //Check for completion
   `uvm_info("DCE_RB_DBG",$psprintf("%t",m_dce_txnq[idxq[0]].m_attid_release_cycle),UVM_LOW) 
    if (check_for_completion(idxq[0],1)) begin
        <% if(obj.COVER_ON) { %>
        m_cov.collect_dce_scb_txn(m_dce_txnq[idxq[0]]);
        <% } %>

       `uvm_info(get_name(), $psprintf("[%-35s] (txnId: %5d) {%20s} (src: 0x%02h {%s}) (tgt: 0x%02h) (msgId: 0x%02h) (attid : 0x%02h) (rbid: 0x%02h) (addr: 0x%016h) (%10t, %10t)", "DceScbd-TxnQDel(4)", m_dce_txnq[idxq[0]].m_txn_id, m_dce_txnq[idxq[0]].m_initcmdupd_req_pkt.type2cmdname(), m_dce_txnq[idxq[0]].m_initcmdupd_req_pkt.smi_src_ncore_unit_id, addrMgrConst::get_cache_id_as_string(m_dce_txnq[idxq[0]].m_initcmdupd_req_pkt.smi_src_ncore_unit_id), m_dce_txnq[idxq[0]].m_initcmdupd_req_pkt.smi_targ_ncore_unit_id, m_dce_txnq[idxq[0]].m_initcmdupd_req_pkt.smi_msg_id, m_dce_txnq[idxq[0]].m_attid, m_dce_txnq[idxq[0]].m_rbid, m_dce_txnq[idxq[0]].m_initcmdupd_req_pkt.smi_addr, m_dce_txnq[idxq[0]].m_initcmdupd_req_pkt.t_smi_ndp_valid, m_dce_txnq[idxq[0]].t_conc_mux_cmdreq), UVM_LOW);
        drop_objection(phase, idxq[0]);
        m_dce_txnq.delete(idxq[0]);
        ->e_attid_dealloc; //reusing same event to tell dce_mst_seq that the rbrrsp is completed and single_step can proceed
    end

    // older comment: explicitly delete txn since RTL does not deallocate the ATTID but this txn is dropped.
    else if (clean_exit_due_to_wrong_targetid_RBrsp == 1) begin 
        drop_objection(phase, idxq[0]);
        m_dce_txnq.delete(idxq[0]);
    end

    <% if(obj.COVER_ON) { %>
        available_credits = <%=obj.DceInfo[0].nRbsPerDmi%> - m_rbids_in_use[m_smi_rx_rbrreq_pkt.smi_targ_ncore_unit_id].size();
        m_cov.collect_rbid_credits_info(RB_RSV, available_credits);
    <% } %>

    /* This code is obsolete in 3.6 as attid is deallocated before RBRsp can come! Reason being the new RBRsp contains the RBID in itself!
    // until 3.4 comment: wakeup pending ops if any on attid dealloc.
    if (check_for_attid_deallocation(idxq[0])) begin
                                                
        if (m_dce_txnq[idxq[0]].m_req_type == REC_REQ) begin
                jdxq = m_dce_txnq.find_index(item) with (  (item.m_initcmdupd_req_pkt.smi_addr >> addrMgrConst::WCACHE_OFFSET == m_dce_txnq[idxq[0]].m_dm_pktq[0].m_addr >> addrMgrConst::WCACHE_OFFSET) &&
                                                           (item.m_initcmdupd_req_pkt.smi_ns   == m_dce_txnq[idxq[0]].m_dm_pktq[0].m_ns) &&
                                                           (item.m_attid_status == ATTID_IS_SLEEP)
                                                        );
        end else begin
                jdxq = m_dce_txnq.find_index(item) with (  (item.m_initcmdupd_req_pkt.smi_addr >> addrMgrConst::WCACHE_OFFSET == m_dce_txnq[idxq[0]].m_initcmdupd_req_pkt.smi_addr >> addrMgrConst::WCACHE_OFFSET) &&
                                                           (item.m_initcmdupd_req_pkt.smi_ns   == m_dce_txnq[idxq[0]].m_initcmdupd_req_pkt.smi_ns) &&
                                                           (item.m_attid_status == ATTID_IS_SLEEP)
                                                        );
        end

        m_attvld_aa[m_dce_txnq[idxq[0]].m_attid]  = m_dce_txnq[idxq[0]];
        m_dce_txnq[idxq[0]].m_attid_status        = ATTID_IS_RELEASED;
        m_dce_txnq[idxq[0]].m_attid_release_cycle = $time;
    end
    */
endfunction: process_smi_rbr_rsp

//***********************************************************
function void dce_scb::process_smi_str_req();
    string s;
    int idxq[$];
    int snp_rsp_data_err_idx[$];
    int snp_rsp_data_dt_aiu_idx[$];
    int snp_rsp_non_data_dt_aiu_idx[$];
    int snp_rsp_non_data_err_idx[$];
    int snp_rsp_data_err_idx_with_dt_aiu[$];
    int str_latency;
    
    $sformat(s, "%s\n", super.convert2string());
    $sformat(s, "%s@ %t: ", s, $time());
   
    //#Check.DCE.StrReq_TargetId 
    //#Check.DCE.StrReq_RMsgId
    idxq = m_dce_txnq.find_index(item) with (
        item.m_initcmdupd_req_pkt.smi_msg_id == m_smi_rx_strreq_pkt.smi_rmsg_id  &&
        item.m_initcmdupd_req_pkt.smi_src_ncore_unit_id == m_smi_rx_strreq_pkt.smi_targ_ncore_unit_id &&
        (item.m_attid_status inside {ATTID_IS_ACTIVE, ATTID_IS_WAKEUP}) &&
         item.m_states["strreq"].is_expect() &&
        !item.m_states["strreq"].is_complete());
    
    if ( idxq.size() == 0 && 
         (      clean_exit_due_to_wrong_targetid_RBrsp
            ||  clean_exit_due_to_wrong_targetid_MRDrsp || garbage_dmiid))
        return;
    
    `uvm_info("DCE_SCB", $psprintf("DCE_UID:%0d: STR_REQ: %s", m_dce_txnq[idxq[0]].m_txn_id, m_smi_rx_strreq_pkt.convert2string()), UVM_LOW);
    //check for rsp2req match
    smi_pktmatch_checks(idxq, m_smi_rx_strreq_pkt, "SMI STR Req");
    
    if ($test$plusargs("SNPrsp_data_error_in_cmstatus") || $test$plusargs("SNPrsp_sharer_data_error_in_cmstatus")) begin
      snp_rsp_data_err_idx = m_dce_txnq[idxq[0]].m_drvsnp_rsp_pktq.find_index(item) with (item.smi_cmstatus === 8'b1000_0011); 
      snp_rsp_data_dt_aiu_idx = m_dce_txnq[idxq[0]].m_drvsnp_rsp_pktq.find_index(item) with ((item.smi_cmstatus_err == 0) && (item.smi_cmstatus_dt_aiu == 1)); 
      if ((snp_rsp_data_err_idx.size() != 0) && (snp_rsp_data_dt_aiu_idx.size() == 0)) begin
        if (m_smi_rx_strreq_pkt.smi_cmstatus !== 8'b10_0_00_011 && !dce_goldenref_model::is_stash_read(m_dce_txnq[idxq[0]].m_cmd_type) && !$test$plusargs("dce_snprsp_snarf1_error_seq") && !dce_goldenref_model::is_stash_write(m_dce_txnq[idxq[0]].m_cmd_type)) begin 
          `uvm_error(get_full_name(),$sformatf("DCE should sent STRreq with data error in smi_cmstatus, actual smi_cmstatus = 0x%0x",m_smi_rx_strreq_pkt.smi_cmstatus))
        end
      end else if (snp_rsp_data_dt_aiu_idx.size() == 1) begin
        if (m_smi_rx_strreq_pkt.smi_cmstatus_err === 1) begin
          `uvm_error(get_full_name(),$sformatf("DCE should not sent STRreq with data error in smi_cmstatus, actual smi_cmstatus = 0x%0x",m_smi_rx_strreq_pkt.smi_cmstatus))
        end
      end
    end
    if ($test$plusargs("SNPrsp_non_data_error_in_cmstatus") || $test$plusargs("SNPrsp_sharer_non_data_error_in_cmstatus")) begin
      snp_rsp_non_data_err_idx = m_dce_txnq[idxq[0]].m_drvsnp_rsp_pktq.find_index(item) with (item.smi_cmstatus === 8'b10_0_00_100); 
      snp_rsp_non_data_dt_aiu_idx = m_dce_txnq[idxq[0]].m_drvsnp_rsp_pktq.find_index(item) with ((item.smi_cmstatus_err == 0) && (item.smi_cmstatus_dt_aiu == 1)); 
      if (snp_rsp_non_data_err_idx.size() != 0 && (snp_rsp_non_data_dt_aiu_idx.size() == 0)) begin
        if (m_smi_rx_strreq_pkt.smi_cmstatus !== 8'b10_0_00_100) begin
          `uvm_error(get_full_name(),$sformatf("DCE should sent STRreq with non-data (Address) error in smi_cmstatus, actual smi_cmstatus = 0x%0x",m_smi_rx_strreq_pkt.smi_cmstatus))
        end
      end else if (snp_rsp_non_data_err_idx.size() == 1) begin
        if (m_smi_rx_strreq_pkt.smi_cmstatus_err === 1) begin
          `uvm_error(get_full_name(),$sformatf("DCE should not sent STRreq with non-data (Address) error in smi_cmstatus, actual smi_cmstatus = 0x%0x",m_smi_rx_strreq_pkt.smi_cmstatus))
        end
      end
    end
    if ($test$plusargs("Mrdrsp_data_err_in_cmstatus")) begin
      if (m_dce_txnq[idxq[0]].m_initcmdupd_req_pkt.smi_msg_type != CMD_RD_NITC_CLN_INV && m_dce_txnq[idxq[0]].m_states["mrdreq"].is_complete() && m_dce_txnq[idxq[0]].m_initcmdupd_req_pkt.smi_msg_type inside {CMD_CLN_SH_PER, CMD_CLN_VLD, CMD_CLN_INV, CMD_MK_INV}) begin // there won't be error passing from mrdRsp to strReq for cmdtype 0x26 (CMD_RD_NITC_CLN_INV) CONC-7422.
        if ((m_smi_rx_strreq_pkt.smi_cmstatus !== 8'b10_0_00_011 || !m_dce_txnq[idxq[0]].m_states["mrdrsp"].is_complete()) && m_dce_txnq[idxq[0]].m_drvmrd_rsp_pkt.smi_cmstatus === 8'b10_0_00_011) begin 
          `uvm_error(get_full_name(),$sformatf("DCE should sent STRreq with data error in smi_cmstatus, actual smi_cmstatus = 0x%0x",m_smi_rx_strreq_pkt.smi_cmstatus))
        end
      end
    end
    if ($test$plusargs("Mrdrsp_address_err_in_cmstatus")) begin
      if (m_dce_txnq[idxq[0]].m_initcmdupd_req_pkt.smi_msg_type != CMD_RD_NITC_CLN_INV && m_dce_txnq[idxq[0]].m_states["mrdreq"].is_complete() && m_dce_txnq[idxq[0]].m_initcmdupd_req_pkt.smi_msg_type inside {CMD_CLN_SH_PER, CMD_CLN_VLD, CMD_CLN_INV, CMD_MK_INV}) begin
        if ((m_smi_rx_strreq_pkt.smi_cmstatus !== 8'b10_0_00_100 || !m_dce_txnq[idxq[0]].m_states["mrdrsp"].is_complete()) && m_dce_txnq[idxq[0]].m_drvmrd_rsp_pkt.smi_cmstatus === 8'b10_0_00_100) begin 
          `uvm_error(get_full_name(),$sformatf("DCE should sent STRreq with address error in smi_cmstatus, actual smi_cmstatus = 0x%0x",m_smi_rx_strreq_pkt.smi_cmstatus))
        end
      end
    end
    
    //Compare and check str Request
    m_dce_txnq[idxq[0]].m_states["strreq"].set_valid($time);
    m_dce_txnq[idxq[0]].check_str_req(m_smi_rx_strreq_pkt);
    m_dce_txnq[idxq[0]].time_struct.str_req = $time; 

    //STR latency
    if (m_dce_txnq[idxq[0]].m_req_type == CMD_REQ) begin 
        str_latency = (m_dce_txnq[idxq[0]].t_mrdrsp      > 0) ? ($time - m_dce_txnq[idxq[0]].t_mrdrsp     ) / CLK_PERIOD :
                      (m_dce_txnq[idxq[0]].t_last_snprsp > 0) ? ($time - m_dce_txnq[idxq[0]].t_last_snprsp) / CLK_PERIOD : ($time - m_dce_txnq[idxq[0]].t_cmdreq) / CLK_PERIOD;
        str_latencyq.push_back(str_latency);
       `uvm_info("DBG LATENCY", $psprintf("clk_period:%0t time_str:%0t time_cmd:%0t str_latency: %0d", CLK_PERIOD, $time, m_dce_txnq[idxq[0]].m_initcmdupd_req_pkt.t_smi_ndp_valid, str_latency), UVM_LOW);  
    end

endfunction: process_smi_str_req

//***********************************************************
function void dce_scb::process_smi_str_rsp(uvm_phase phase);
    int idxq[$], idq[$], jdxq[$];
    dce_scb_txn txn1q[$];
    dce_scb_txn txn2q[$];
    string attids;
    int dce_txnq_wakeup_idx;
    
    if (num_smi_uncorr_err>0 || num_smi_parity_err>0) begin
        return;
    end


    if (   clean_exit_due_to_wrong_targetid_RBrsp 
        || clean_exit_due_to_wrong_targetid_MRDrsp)
        return;

    if ($test$plusargs("wrong_strrsp_target_id") && (m_smi_tx_strrsp_pkt.smi_targ_ncore_unit_id !== addrMgrConst::get_dce_funitid(0))) begin
         clean_exit_due_to_wrong_targetid_STRrsp = 1;
    end

    txn1q = m_dce_txnq.find(item) with (
          !item.m_states["strrsp"].is_complete() &&
           item.m_states["strreq"].is_complete()); 

    //`uvm_info("DCE SCB", $psprintf("txn1q_size: %d", txn1q.size()), UVM_LOW);
    
    txn2q = txn1q.find(item) with (
            item.m_expstr_req_pkt.smi_msg_id == m_smi_tx_strrsp_pkt.smi_rmsg_id);

    if (txn2q.size() != 1)
        `uvm_error("DCE SCB", "Multiple or No Str Req pkts matching for single Str Rsp");

    idxq = m_dce_txnq.find_index(item) with (
            (item.m_req_type == CMD_REQ) &&
            item.m_initcmdupd_req_pkt.smi_msg_id == txn2q[0].m_initcmdupd_req_pkt.smi_msg_id &&
            item.m_initcmdupd_req_pkt.smi_src_id == txn2q[0].m_initcmdupd_req_pkt.smi_src_id && 
            item.m_attid                         == txn2q[0].m_attid &&
            !item.m_states["strrsp"].is_complete() &&
             item.m_states["strreq"].is_complete());
    
    `uvm_info("DCE_SCB", $psprintf("DCE_UID:%0d: STR_RESP: %s", m_dce_txnq[idxq[0]].m_txn_id, m_smi_tx_strrsp_pkt.convert2string()), UVM_LOW);
    smi_pktmatch_checks(idxq, m_smi_tx_strrsp_pkt, "SMI STR Rsp");

    //Save str_rsp
    m_dce_txnq[idxq[0]].m_states["strrsp"].set_valid($time);
    m_dce_txnq[idxq[0]].save_strrsp(m_smi_tx_strrsp_pkt);

    //wakeup pending ops if any on attid dealloc.
    if (check_for_attid_deallocation(idxq[0])) begin
        m_attvld_aa[m_dce_txnq[idxq[0]].m_attid]  = m_dce_txnq[idxq[0]];
       `uvm_info(get_name(), $psprintf("[%-35s] (txnId: %5d) {%20s} (src: 0x%02h {%s}) (tgt: 0x%02h) (msgId: 0x%02h) (attid : 0x%02h) (rbid: 0x%02h) (addr: 0x%016h) (%10t, %10t)", "DceScbd-AttRelease(3)", m_dce_txnq[idxq[0]].m_txn_id, m_dce_txnq[idxq[0]].m_initcmdupd_req_pkt.type2cmdname(), m_dce_txnq[idxq[0]].m_initcmdupd_req_pkt.smi_src_ncore_unit_id, addrMgrConst::get_cache_id_as_string(m_dce_txnq[idxq[0]].m_initcmdupd_req_pkt.smi_src_ncore_unit_id), m_dce_txnq[idxq[0]].m_initcmdupd_req_pkt.smi_targ_ncore_unit_id, m_dce_txnq[idxq[0]].m_initcmdupd_req_pkt.smi_msg_id, m_dce_txnq[idxq[0]].m_attid, m_dce_txnq[idxq[0]].m_rbid, m_dce_txnq[idxq[0]].m_initcmdupd_req_pkt.smi_addr, m_dce_txnq[idxq[0]].m_initcmdupd_req_pkt.t_smi_ndp_valid, m_dce_txnq[idxq[0]].t_conc_mux_cmdreq), UVM_LOW);
        m_dce_txnq[idxq[0]].m_attid_status        = ATTID_IS_RELEASED;
        m_dce_txnq[idxq[0]].m_attid_release_cycle = $time;
    end 
    
    //explicitly delete txn since RTL does not deallocate the ATTID but this txn is dropped.
    if (clean_exit_due_to_wrong_targetid_STRrsp == 1) begin 
        drop_objection(phase, idxq[0]);
        m_dce_txnq.delete(idxq[0]);
    end

endfunction: process_smi_str_rsp

//***********************************************************
function void dce_scb::process_smi_mrd_rsp(uvm_phase phase);
    int idxq[$],idq[$], jdxq[$];
    dce_scb_txn txn1q[$];
    dce_scb_txn txn2q[$];
    string credits_msg, attids;
    int available_credits, dce_txnq_wakeup_idx;

    if (num_smi_uncorr_err>0 || num_smi_parity_err>0) begin
        return;
    end
    
    if ($test$plusargs("wrong_mrdrsp_target_id") && (m_smi_tx_mrdrsp_pkt.smi_targ_ncore_unit_id !== addrMgrConst::get_dce_funitid(0))) begin
         clean_exit_due_to_wrong_targetid_MRDrsp = 1;
    end


    txn1q = m_dce_txnq.find(item) with (
         !item.m_states["mrdrsp"].is_complete() &&
          (item.m_states["mrdreq"].is_complete() || (item.m_states["mrdreq"].get_valid_count() == 1))); 

    txn2q = txn1q.find(item) with (
         item.m_expmrd_req_pkt.smi_msg_id == m_smi_tx_mrdrsp_pkt.smi_rmsg_id &&
         item.m_expmrd_req_pkt.smi_targ_ncore_unit_id == m_smi_tx_mrdrsp_pkt.smi_src_ncore_unit_id);

    if (txn2q.size() != 1) begin 
         if ( clean_exit_due_to_wrong_targetid_STRrsp == 1 ||
              clean_exit_due_to_wrong_targetid_RBrsp == 1)
             return;
        `uvm_error("DCE SCB", "Multiple or No Mrd Req pkts matching for single Mrd Rsp");
    end

    idxq = m_dce_txnq.find_index(item) with (
            item.m_initcmdupd_req_pkt.smi_msg_id == txn2q[0].m_initcmdupd_req_pkt.smi_msg_id &&
            item.m_initcmdupd_req_pkt.smi_src_id == txn2q[0].m_initcmdupd_req_pkt.smi_src_id &&
            item.m_attid                         == txn2q[0].m_attid &&
            !item.m_states["mrdrsp"].is_complete() &&
             item.m_states["mrdreq"].is_complete());
    
    `uvm_info("DCE_SCB", $psprintf("DCE_UID:%0d: MRD_RESP: %s", m_dce_txnq[idxq[0]].m_txn_id, m_smi_tx_mrdrsp_pkt.convert2string()), UVM_LOW);
    smi_pktmatch_checks(idxq, m_smi_tx_mrdrsp_pkt, "SMI MRD Rsp");
   
    //Save mrd_rsp
    m_dce_txnq[idxq[0]].m_states["mrdrsp"].set_valid($time);
    m_dce_txnq[idxq[0]].save_mrdrsp(m_smi_tx_mrdrsp_pkt);

    //Credits code
    $sformat(credits_msg, "dce%0d_dmi%0d_nMrdInFlight", addrMgrConst::get_dce_funitid(<%=obj.Id%>), m_smi_tx_mrdrsp_pkt.smi_src_ncore_unit_id);
    m_credits.put_credit(credits_msg, available_credits);

    <% if(obj.COVER_ON) { %>
        m_cov.collect_snp_mrd_credits_info(0, available_credits);
    <% } %>

    m_dce_txnq[idxq[0]].t_mrdrsp = $time;
    if (check_for_attid_deallocation(idxq[0])) begin
        m_attvld_aa[m_dce_txnq[idxq[0]].m_attid]  = m_dce_txnq[idxq[0]];
       `uvm_info(get_name(), $psprintf("[%-35s] (txnId: %5d) {%20s} (src: 0x%02h {%s}) (tgt: 0x%02h) (msgId: 0x%02h) (attid : 0x%02h) (rbid: 0x%02h) (addr: 0x%016h) (%10t, %10t)", "DceScbd-AttRelease(4)", m_dce_txnq[idxq[0]].m_txn_id, m_dce_txnq[idxq[0]].m_initcmdupd_req_pkt.type2cmdname(), m_dce_txnq[idxq[0]].m_initcmdupd_req_pkt.smi_src_ncore_unit_id, addrMgrConst::get_cache_id_as_string(m_dce_txnq[idxq[0]].m_initcmdupd_req_pkt.smi_src_ncore_unit_id), m_dce_txnq[idxq[0]].m_initcmdupd_req_pkt.smi_targ_ncore_unit_id, m_dce_txnq[idxq[0]].m_initcmdupd_req_pkt.smi_msg_id, m_dce_txnq[idxq[0]].m_attid, m_dce_txnq[idxq[0]].m_rbid, m_dce_txnq[idxq[0]].m_initcmdupd_req_pkt.smi_addr, m_dce_txnq[idxq[0]].m_initcmdupd_req_pkt.t_smi_ndp_valid, m_dce_txnq[idxq[0]].t_conc_mux_cmdreq), UVM_LOW);
        m_dce_txnq[idxq[0]].m_attid_status        = ATTID_IS_RELEASED;
        m_dce_txnq[idxq[0]].m_attid_release_cycle = $time;
    end 

    //explicitly delete txn since RTL does not deallocate the ATTID but this txn is dropped.
    if (clean_exit_due_to_wrong_targetid_MRDrsp == 1) begin 
        drop_objection(phase, idxq[0]);
        m_dce_txnq.delete(idxq[0]);
    end

endfunction:process_smi_mrd_rsp

//***********************************************************
function void dce_scb::process_smi_mrd_req();
    string credits_msg;
    int idxq[$];
    int mrd_latency;
    int available_credits;

    if (clean_exit_due_to_wrong_targetid_STRrsp || 
        clean_exit_due_to_wrong_targetid_RBrsp)
        return;
    
    //#Check.DCE.MrdReq_AddrNS
    //#Check.DCE.MrdReq_ATTId
    idxq = m_dce_txnq.find_index(item) with (
        item.m_initcmdupd_req_pkt.smi_addr   == m_smi_rx_mrdreq_pkt.smi_addr            &&
        item.m_initcmdupd_req_pkt.smi_ns     == m_smi_rx_mrdreq_pkt.smi_ns              &&
        item.m_attid                         == m_smi_rx_mrdreq_pkt.smi_msg_id          &&
        item.m_attid_status inside {ATTID_IS_ACTIVE, ATTID_IS_WAKEUP}                   &&
        !item.m_states["mrdreq"].is_complete());
    
    if(idxq.size() == 0) begin
        idxq = m_dce_txnq.find_index(item) with (
                item.m_initcmdupd_req_pkt.smi_addr   == m_smi_rx_mrdreq_pkt.smi_addr            &&
                item.m_initcmdupd_req_pkt.smi_ns     == m_smi_rx_mrdreq_pkt.smi_ns              &&
                item.m_attid                         == m_smi_rx_mrdreq_pkt.smi_msg_id          &&
                item.m_attid_status inside {ATTID_IS_ACTIVE, ATTID_IS_WAKEUP}                   &&
                !item.m_states["mrdreq"].is_expect());
        if(idxq.size() == 1) begin
            m_dce_txnq[idxq[0]].snoop_enable_reg_txn = snoop_enable_reg;
            m_dce_txnq[idxq[0]].repredict_snp_mrd_reqs();
            idxq = m_dce_txnq.find_index(item) with (
                     item.m_initcmdupd_req_pkt.smi_addr   == m_smi_rx_mrdreq_pkt.smi_addr            &&
                     item.m_initcmdupd_req_pkt.smi_ns     == m_smi_rx_mrdreq_pkt.smi_ns              &&
                     item.m_attid                         == m_smi_rx_mrdreq_pkt.smi_msg_id          &&
                     item.m_attid_status inside {ATTID_IS_ACTIVE, ATTID_IS_WAKEUP}                   &&
                     !item.m_states["mrdreq"].is_complete());   
        end

    end

    `uvm_info("DCE_SCB", $psprintf("DCE_UID:%0d: MRD_REQ: %s", m_dce_txnq[idxq[0]].m_txn_id, m_smi_rx_mrdreq_pkt.convert2string()), UVM_LOW);
    //check for rsp2req match
    smi_pktmatch_checks(idxq, m_smi_rx_mrdreq_pkt, "SMI MRD Req");
    
    //Compare mrd request
    m_dce_txnq[idxq[0]].m_states["mrdreq"].set_valid($time);
    m_dce_txnq[idxq[0]].check_mrd_req(m_smi_rx_mrdreq_pkt);

    //MRD latency
    if (m_dce_txnq[idxq[0]].m_req_type == CMD_REQ) begin 
        mrd_latency = ($time - m_dce_txnq[idxq[0]].m_initcmdupd_req_pkt.t_smi_ndp_valid) / CLK_PERIOD;
        mrd_latency = (m_dce_txnq[idxq[0]].t_last_snprsp > 0) ? ($time - m_dce_txnq[idxq[0]].t_last_snprsp) / CLK_PERIOD : ($time - m_dce_txnq[idxq[0]].t_cmdreq) / CLK_PERIOD;
        mrd_latencyq.push_back(mrd_latency);
       `uvm_info("DBG LATENCY", $psprintf("clk_period:%0t time_mrd:%0t time_cmd:%0t mrd_latency: %0d", CLK_PERIOD, $time, m_dce_txnq[idxq[0]].m_initcmdupd_req_pkt.t_smi_ndp_valid, mrd_latency), UVM_LOW);  
    end

    //Credits code
    //#Check.DCE.MrdReq_CreditCheck
    //#Check.DCE.MrdReq.CreditCheck
    $sformat(credits_msg, "dce%0d_dmi%0d_nMrdInFlight", addrMgrConst::get_dce_funitid(<%=obj.Id%>), m_smi_rx_mrdreq_pkt.smi_targ_ncore_unit_id);
    m_credits.get_credit(credits_msg, available_credits);
    
 <% if(obj.COVER_ON) { %>
    m_cov.collect_snp_mrd_credits_info(0, available_credits);
 <% } %>

endfunction:process_smi_mrd_req

//***********************************************************
function void dce_scb::process_dm_cohreq();
    string s, attids, qos;
    int active_attid_matchq[$], active_addr_matchq[$], inactive_addr_matchq[$], sleep_addr_matchq[$], wakeup_addr_matchq[$], dm_cohreq_matchq[$], released_addr_matchq[$], dealloc_addr_matchq[$], recall_addr_matchq[$], deleted_recall_addr_matchq[$], released_recall_addr_matchq[$];
    int dm_cohreq_active_matchq[$];
    int idxq[$];
    int cmd_rsp_time_checkq[$];
    int active_wakeup_addr_attid_matchq[$];
    bit [WSMIADDR - 1 : 0] offset_aligned_addr_prev_req; 
    bit [WSMIADDR - 1 : 0] offset_aligned_addr_cur_req;
    int set_index_prev_req;
    int set_index_cur_req;
    bit [WSMIMSGID-1:0] msgid;
    bit [WSMITGTID-1:0] masterid;
    bit [WSMIMSGPRI-1:0] pri;
    int fnd_idxq[$];
    int way_cnt, set_idx;
    int agent_idq[$];
    dce_scb_txn txn_matchq[$], inactive_addr_queue[$];
    tag_snoop_filter tag_sf;

    //#Check.DCE.DM.CmdReqATTIDChk1
    // Check if any ACTIVE transaction with same ATT_ID is present or not.
    active_attid_matchq = m_dce_txnq.find_index(item) with ( ((item.m_initcmdupd_req_pkt.smi_addr != m_dm_cohreq_pkt.m_addr) ||
                                                              (item.m_initcmdupd_req_pkt.smi_ns   != m_dm_cohreq_pkt.m_ns) )&&
                                                              (item.m_attid  == m_dm_cohreq_pkt.m_attid) &&
                                                               item.m_initcmdupd_req_pkt.isCmdMsg() &&
                                                              (item.m_attid_status inside {ATTID_IS_ACTIVE, ATTID_IS_WAKEUP}));
    if(active_attid_matchq.size() >=1) begin
        `uvm_info("DCE_SCB", $psprintf("Received Dir Request @{ACT}: %s", m_dm_cohreq_pkt.convert2string()), UVM_LOW);
        `uvm_error("DCE_SCB", $psprintf("ACTIVE transaction(s) : %0d with same attid:0x%0h already present", active_attid_matchq.size(),m_dm_cohreq_pkt.m_attid))
    end
    //#Check.DCE.DM.CmdReqActive 
    active_addr_matchq = m_dce_txnq.find_index(item) with (   (item.m_initcmdupd_req_pkt.smi_addr >> addrMgrConst::WCACHE_OFFSET == m_dm_cohreq_pkt.m_addr >> addrMgrConst::WCACHE_OFFSET) &&
                                                              (item.m_initcmdupd_req_pkt.smi_ns   == m_dm_cohreq_pkt.m_ns) &&
                                                               item.m_initcmdupd_req_pkt.isCmdMsg() &&
                                                              (item.m_attid_status == ATTID_IS_ACTIVE));
    
                                                              
    recall_addr_matchq = m_dce_txnq.find_index(item) with ( (item.m_req_type == REC_REQ) && 
                                (item.m_dm_pktq[0].m_addr >> addrMgrConst::WCACHE_OFFSET == m_dm_cohreq_pkt.m_addr >> addrMgrConst::WCACHE_OFFSET) &&
                                                                (item.m_dm_pktq[0].m_ns == m_dm_cohreq_pkt.m_ns) &&
                                                                <% if(obj.DceInfo[obj.Id].useSramInputFlop) { %>
                                                                //CONC-16189,CONC-16081 adding +1 to the equation of cycle_counts as new cycle p0+ has been added to DM in Ncore3.7
                                                                (item.m_dm_pktq[0].m_cycle_count != m_dm_cohreq_pkt.m_cycle_count + 2) && //Corner case where we get recall req to the same address the (next+1) cycle after the DIR_CMD this is handled by DM (RTL) by retry.
                                                                <% } else { %>
                                                                (item.m_dm_pktq[0].m_cycle_count != m_dm_cohreq_pkt.m_cycle_count + 1) && //Corner case where we get recall req to the same address the next cycle after the DIR_CMD this is handled by DM (RTL) by retry.
                                                                <% } %>
                                            (item.m_attid_status != ATTID_IS_RELEASED));

    /*foreach(m_dce_txnq[x]) begin
        if(m_dce_txnq[x].m_req_type == REC_REQ)
            `uvm_info("DCE_SCB",$psprintf("DCE_MUL_REC, Req_type = %p, att_id = %p,req_addr = %p and att_status = %p, released_rtl = %d",m_dce_txnq[x].m_req_type, m_dce_txnq[x].m_attid,m_dce_txnq[x].m_dm_pktq[0].m_addr, m_dce_txnq[x].m_attid_status,m_dce_txnq[x].rtl_deallocated),UVM_LOW)
    end
    `uvm_info("DCE_SCB",$psprintf("deallocated queue = %p", m_deallocated_attidq),UVM_LOW)*/

    active_wakeup_addr_attid_matchq = m_dce_txnq.find_index(item) with (   (item.m_initcmdupd_req_pkt.smi_addr >> addrMgrConst::WCACHE_OFFSET == m_dm_cohreq_pkt.m_addr >> addrMgrConst::WCACHE_OFFSET) &&
                                                                           (item.m_initcmdupd_req_pkt.smi_ns   == m_dm_cohreq_pkt.m_ns) &&
                                                                            item.m_initcmdupd_req_pkt.isCmdMsg() &&
                                                                           (item.m_attid_status inside {ATTID_IS_ACTIVE, ATTID_IS_WAKEUP}) &&
                                                                           (item.m_attid == m_dm_cohreq_pkt.m_attid));
   //#Check.DCE.DM.CmdReqWakeup 
    wakeup_addr_matchq = m_dce_txnq.find_index(item) with (   (item.m_initcmdupd_req_pkt.smi_addr >> addrMgrConst::WCACHE_OFFSET == m_dm_cohreq_pkt.m_addr >> addrMgrConst::WCACHE_OFFSET) &&
                                                              (item.m_initcmdupd_req_pkt.smi_ns   == m_dm_cohreq_pkt.m_ns) &&
                                                               item.m_initcmdupd_req_pkt.isCmdMsg() &&
                                                              (item.m_attid_status == ATTID_IS_WAKEUP));

    inactive_addr_matchq = m_dce_txnq.find_index(item) with (   (item.m_initcmdupd_req_pkt.smi_addr == m_dm_cohreq_pkt.m_addr) &&
                                                                (item.m_initcmdupd_req_pkt.smi_ns   == m_dm_cohreq_pkt.m_ns) &&
                                                                (item.m_initcmdupd_req_pkt.smi_msg_type == m_dm_cohreq_pkt.m_type) && // added to resolve attid allocation in case of multiple txn of different tyoes
                                                                (item.m_initcmdupd_req_pkt.smi_src_ncore_unit_id == m_dm_cohreq_pkt.m_iid >> WSMINCOREPORTID) &&
                                                                 item.m_initcmdupd_req_pkt.isCmdMsg() &&
                                                                (item.m_attid_status == ATTID_IS_INACTIVE));
    //#Check.DCE.DM.CmdReqSleep
    sleep_addr_matchq = m_dce_txnq.find_index(item) with (   (item.m_initcmdupd_req_pkt.smi_addr >> addrMgrConst::WCACHE_OFFSET == m_dm_cohreq_pkt.m_addr >> addrMgrConst::WCACHE_OFFSET) &&
                                                             (item.m_initcmdupd_req_pkt.smi_ns   == m_dm_cohreq_pkt.m_ns) &&
                                                              item.m_initcmdupd_req_pkt.isCmdMsg() &&
                                                             (item.m_attid_status == ATTID_IS_SLEEP));

    //HS: We needed this to cover the corner case where a old matching(addr) attid is released in the same cycle as the later request does a cohreq. There is a race condition here, and rtl recognizes the cohreq made as a SLEEP req, and dv needs to match that. 
    //CONC-14874::CONC-15568
    <% if(obj.DceInfo[obj.Id].useSramInputFlop) { %>
    //P0Plus pipline stage delays P1 by one cycle
    released_addr_matchq = m_dce_txnq.find_index(item) with (   (item.m_initcmdupd_req_pkt.smi_addr >> addrMgrConst::WCACHE_OFFSET == m_dm_cohreq_pkt.m_addr >> addrMgrConst::WCACHE_OFFSET) &&
                                                                (item.m_initcmdupd_req_pkt.smi_ns   == m_dm_cohreq_pkt.m_ns) &&
                                                                (item.m_initcmdupd_req_pkt.isCmdMsg()) &&
                                                                (item.m_attid_status == ATTID_IS_RELEASED) &&
                                                                (item.m_attid_release_cycle == (m_dm_cohreq_pkt.m_time +  <%=obj.Clocks[0].params.period%> - 1)));
    <%} else { %>
    released_addr_matchq = m_dce_txnq.find_index(item) with (   (item.m_initcmdupd_req_pkt.smi_addr >> addrMgrConst::WCACHE_OFFSET == m_dm_cohreq_pkt.m_addr >> addrMgrConst::WCACHE_OFFSET) &&
                                                                (item.m_initcmdupd_req_pkt.smi_ns   == m_dm_cohreq_pkt.m_ns) &&
                                                                (item.m_initcmdupd_req_pkt.isCmdMsg()) &&
                                                                (item.m_attid_status == ATTID_IS_RELEASED) &&
                                                                (item.m_attid_release_cycle == m_dm_cohreq_pkt.m_time));
    <% } %>

   released_recall_addr_matchq = m_dce_txnq.find_index(item) with ((item.m_req_type == REC_REQ) && 
                                (item.m_dm_pktq[0].m_addr >> addrMgrConst::WCACHE_OFFSET == m_dm_cohreq_pkt.m_addr >> addrMgrConst::WCACHE_OFFSET) &&
                                                                (item.m_dm_pktq[0].m_ns == m_dm_cohreq_pkt.m_ns) &&
                                                                (item.m_attid_status == ATTID_IS_RELEASED) &&
                                                                (item.rtl_deallocated != 1));
                                //(!(item.m_attid inside {m_deallocated_attidq})));
                                //((!(item.m_attid inside {m_deallocated_attidq})) || item.m_attid_deleted_time == $time));
    /*if(released_recall_addr_matchq.size() != 0)
        `uvm_info("DCE_SCB",$psprintf("Matched recall att_id = %p, status = %p,deleted_time = %p, address = %p",m_dce_txnq[released_recall_addr_matchq[0]].m_attid,m_dce_txnq[released_recall_addr_matchq[0]].m_attid_status,m_dce_txnq[released_recall_addr_matchq[0]].m_attid_deleted_time,m_dce_txnq[released_recall_addr_matchq[0]].m_dm_pktq[0].m_addr),UVM_LOW)
    if(deleted_recall_txnq.size() != 0)
    `uvm_info("DCE_SCB",$psprintf("deleted recall attid = %p deleted_time = %p, address = %p", deleted_recall_txnq[0].m_attid, deleted_recall_txnq[0].m_attid_deleted_time, deleted_recall_txnq[0].m_dm_pktq[0].m_addr),UVM_LOW)*/
    

    /*deleted_recall_addr_matchq = deleted_recall_txnq.find_index(item) with ((item.m_req_type == REC_REQ) && 
                                (item.m_dm_pktq[0].m_addr >> addrMgrConst::WCACHE_OFFSET == m_dm_cohreq_pkt.m_addr >> addrMgrConst::WCACHE_OFFSET) &&
                                                                (item.m_dm_pktq[0].m_ns == m_dm_cohreq_pkt.m_ns) &&
                                                                (item.m_attid_status == ATTID_IS_RELEASED) &&
                                                                (item.m_attid_release_cycle == $time));*/
    
    dealloc_addr_matchq = m_attvld_aa.find_index(item) with (   (item.m_initcmdupd_req_pkt.smi_addr >> addrMgrConst::WCACHE_OFFSET == m_dm_cohreq_pkt.m_addr >> addrMgrConst::WCACHE_OFFSET) &&
                                                                (item.m_initcmdupd_req_pkt.smi_ns   == m_dm_cohreq_pkt.m_ns));
    
    dm_cohreq_matchq = m_dm_cohreq_pktq.find_index(item) with(  (item.m_addr >> addrMgrConst::WCACHE_OFFSET == m_dm_cohreq_pkt.m_addr >> addrMgrConst::WCACHE_OFFSET) &&
                                                                (item.m_ns   == m_dm_cohreq_pkt.m_ns) &&
                                                                (item.m_attid_state == SLEEP) &&
                                                                (item.m_attid == m_dm_cohreq_pkt.m_attid));
    
    dm_cohreq_active_matchq = m_dm_cohreq_pktq.find_index(item) with(  (item.m_addr >> addrMgrConst::WCACHE_OFFSET == m_dm_cohreq_pkt.m_addr >> addrMgrConst::WCACHE_OFFSET) &&
                                                                        (item.m_ns   == m_dm_cohreq_pkt.m_ns) &&
                                                                        (item.m_attid_state == ACTIVE) &&
                                                                        (item.m_attid == m_dm_cohreq_pkt.m_attid));

    `uvm_info("DCE_SCB", $psprintf("activeq: %0d, recallq: %0d, inactiveq:%0d, sleepq:%0d, wakeq:%0d cohreqq:%0d release_addr_matchq:%0d released_recall_addr_matchq = %0d, deleted_recall_addr_matchq:%0d dealloc_addr_matchq:%0d", active_addr_matchq.size(), recall_addr_matchq.size(), inactive_addr_matchq.size(), sleep_addr_matchq.size(), wakeup_addr_matchq.size(), dm_cohreq_matchq.size(), released_addr_matchq.size(), released_recall_addr_matchq.size() ,deleted_recall_addr_matchq.size(),dealloc_addr_matchq.size()), UVM_LOW)
    //if(recall_addr_matchq.size() == 1)
    //`uvm_info("DCE_SCB_DBG",$psprintf("recall_addr_match_q:%p", m_dce_txnq[recall_addr_matchq[0]]),UVM_LOW)
    //if(wakeup_addr_matchq.size() == 1)
    //`uvm_info("DCE_SCB_DBG",$psprintf("wakeup_addr_match_q:%p", m_dce_txnq[wakeup_addr_matchq[0]]),UVM_LOW)
//    if (sleep_addr_matchq.size() == 1) begin
//      `uvm_info("DBG", $psprintf("matching sleepq txn: %0d", m_dce_txnq[sleep_addr_matchq[0]].print_txn(1)), UVM_LOW)
//    end
    if (active_wakeup_addr_attid_matchq.size() == 1) begin //this is an active request already that got retried. Hence we set the status as ACTIVE, as it already got ACTIVE before 
                                                           //this is a wakeup request that got woken up due to a conflicting attid deallocating.
    //#Check.DCE.DM.CmdReqType
        m_dce_txnq[active_wakeup_addr_attid_matchq[0]].save_attid_for_rd_stash_ops(m_dm_cohreq_pkt);
        if (recall_addr_matchq.size() >= 1 || released_recall_addr_matchq.size() == 1) begin //if a recall request is in pipe but the regular request to sleep.
            m_dce_txnq[active_wakeup_addr_attid_matchq[0]].m_attid_status = ATTID_IS_SLEEP;
            m_dm_cohreq_pkt.m_attid_state = SLEEP;
        end else begin
            if (m_dce_txnq[active_wakeup_addr_attid_matchq[0]].m_attid_status == ATTID_IS_ACTIVE)
                m_dm_cohreq_pkt.m_attid_state = ACTIVE;
            if (m_dce_txnq[active_wakeup_addr_attid_matchq[0]].m_attid_status == ATTID_IS_WAKEUP)
                m_dm_cohreq_pkt.m_attid_state = WAKEUP;
        end
    end else if ((inactive_addr_matchq.size() >= 1) && (dm_cohreq_matchq.size() == 0)) begin  //a new request (could be made active or put to sleep)
        //QOS checks -- since it is the 1st pass of the request for dm_coh_req
        //Check to make sure the smi_cmd_rsp was already issued/ or issued in the same cycle.
        //#Check.DCE.QOS.dm_cmdreq_after_sb_cmdrsp
        if (inactive_addr_matchq.size() == 1) begin 
            masterid = m_dce_txnq[inactive_addr_matchq[0]].m_initcmdupd_req_pkt.smi_src_ncore_unit_id;
            msgid    = m_dce_txnq[inactive_addr_matchq[0]].m_initcmdupd_req_pkt.smi_msg_id;
            pri      = m_dce_txnq[inactive_addr_matchq[0]].m_initcmdupd_req_pkt.smi_msg_pri;
        end else begin
            /*foreach (inactive_addr_matchq[i]) begin 
                txn_matchq.push_back(m_dce_txnq[inactive_addr_matchq[i]]); 
            end
            foreach (txn_matchq[i]) begin 
                `uvm_info("DCE_SCB", $psprintf("txn_matchq masterid:0x%0h msgid:0x%0h pri:0x%0h", txn_matchq[i].m_initcmdupd_req_pkt.smi_src_ncore_unit_id, txn_matchq[i].m_initcmdupd_req_pkt.smi_msg_id, txn_matchq[i].m_initcmdupd_req_pkt.smi_msg_pri), UVM_LOW);
            end
            `uvm_error("DCE_SCB", $psprintf("CmdReq matches multiple requests in inactive_txnsq"));*/

            inactive_addr_queue = m_dce_txnq.find(item) with (   (item.m_initcmdupd_req_pkt.smi_addr == m_dm_cohreq_pkt.m_addr) &&
                                                                (item.m_initcmdupd_req_pkt.smi_ns   == m_dm_cohreq_pkt.m_ns) &&
                                                                (item.m_initcmdupd_req_pkt.smi_msg_type == m_dm_cohreq_pkt.m_type) && // added to resolve attid allocation in case of multiple txn of different tyoes
                                                                (item.m_initcmdupd_req_pkt.smi_src_ncore_unit_id == m_dm_cohreq_pkt.m_iid >> WSMINCOREPORTID) &&
                                                                 item.m_initcmdupd_req_pkt.isCmdMsg() &&
                                                                (item.m_attid_status == ATTID_IS_INACTIVE));

            inactive_addr_queue.sort(item) with (item.t_conc_mux_cmdreq);       
            masterid = inactive_addr_queue[0].m_initcmdupd_req_pkt.smi_src_ncore_unit_id;
            msgid    = inactive_addr_queue[0].m_initcmdupd_req_pkt.smi_msg_id;
            pri  = inactive_addr_queue[0].m_initcmdupd_req_pkt.smi_msg_pri;
        end
    
        
        <%if(obj.DceInfo[0].fnEnableQos == 1){%>
            if(sb_cmdrsp_a.exists(masterid) && inactive_addr_matchq.size() > 1) begin
                    inactive_addr_queue = m_dce_txnq.find(item) with ((item.m_initcmdupd_req_pkt.smi_addr == m_dm_cohreq_pkt.m_addr) &&
                                                                (item.m_initcmdupd_req_pkt.smi_ns   == m_dm_cohreq_pkt.m_ns) &&
                                                                (item.m_initcmdupd_req_pkt.smi_msg_type == m_dm_cohreq_pkt.m_type) &&
                                                                (item.m_initcmdupd_req_pkt.smi_msg_id == m_dm_cohreq_pkt.m_msg_id) &&
                                                                (item.m_initcmdupd_req_pkt.smi_src_ncore_unit_id == m_dm_cohreq_pkt.m_iid >> WSMINCOREPORTID) &&
                                                                 item.m_initcmdupd_req_pkt.isCmdMsg() &&
                                                                (item.m_attid_status == ATTID_IS_INACTIVE));        
                    masterid = inactive_addr_queue[0].m_initcmdupd_req_pkt.smi_src_ncore_unit_id;
                    msgid    = inactive_addr_queue[0].m_initcmdupd_req_pkt.smi_msg_id;
                    pri  = inactive_addr_queue[0].m_initcmdupd_req_pkt.smi_msg_pri;
                    inactive_addr_matchq = m_dce_txnq.find_index(item) with ((item.m_initcmdupd_req_pkt.smi_addr == inactive_addr_queue[0].m_initcmdupd_req_pkt.smi_addr) &&
                                                                (item.m_initcmdupd_req_pkt.smi_ns   == inactive_addr_queue[0].m_initcmdupd_req_pkt.smi_ns) &&
                                                                (item.m_initcmdupd_req_pkt.smi_msg_pri   == inactive_addr_queue[0].m_initcmdupd_req_pkt.smi_msg_pri) &&
                                                                (item.m_initcmdupd_req_pkt.smi_msg_id   == inactive_addr_queue[0].m_initcmdupd_req_pkt.smi_msg_id) &&
                                                                (item.m_initcmdupd_req_pkt.smi_msg_type == inactive_addr_queue[0].m_initcmdupd_req_pkt.smi_msg_type) &&
                                                                (item.m_initcmdupd_req_pkt.smi_src_ncore_unit_id == inactive_addr_queue[0].m_initcmdupd_req_pkt.smi_src_ncore_unit_id) &&
                                                                 item.m_initcmdupd_req_pkt.isCmdMsg() &&
                                                                (item.m_attid_status == ATTID_IS_INACTIVE));
                    
            end     
        <%}%>
        if (sb_cmdrsp_a.exists(masterid)) begin 
            if (msgid inside {sb_cmdrsp_a[masterid]}) begin 
                `uvm_info("DCE_SCB", $psprintf("CMDreq Ordering Check as per QOS Passed masterid:0x%0h msgid:0x%0h pri:0x%0h", masterid, msgid, pri), UVM_LOW);
                fnd_idxq = sb_cmdrsp_a[masterid].find_index(item) with (item == msgid);
                if (fnd_idxq.size() != 1)
                    `uvm_error("DCE_SCB", $psprintf("Multiple entries of same msgid in sb_cmdrsp tracking queue"));

                sb_cmdrsp_a[masterid].delete(fnd_idxq[0]);
            end else begin 
                `uvm_info("DCE_SCB", $psprintf("CMDreq Ordering Error for masterid:0x%0h msgid:0x%0h pri:0x%0h\n%s",  masterid, msgid, pri, m_dm_cohreq_pkt.convert2string()), UVM_LOW);
                
                qos = "";
                $sformat(qos, "%s masterid-0x%0h msgids in queue-", qos, masterid);
                foreach(sb_cmdrsp_a[masterid][i]) begin 
                    $sformat(qos, "%s 0x%0h", qos, sb_cmdrsp_a[masterid][i]);
                end 
                `uvm_info("DCE_SCB", $psprintf("%s", qos), UVM_LOW)
                //CONC-6568
                `uvm_error("DCE_SCB", $psprintf("CMDreq ordering error - msgid not present in sb_cmdrsp tracking queue"));
            end 
        end else begin 
            `uvm_info("DCE_SCB", $psprintf("CMDreq Ordering Error: %s", m_dm_cohreq_pkt.convert2string()), UVM_LOW);
            qos = "";
            $sformat(qos, "%s masterid-0x%0h msgids in queue-", qos, masterid);
            foreach(sb_cmdrsp_a[masterid][i]) begin 
                $sformat(qos, "%s 0x%0h", qos, sb_cmdrsp_a[masterid][i]);   
            end 
            `uvm_info("DCE_SCB", $psprintf("%s", qos), UVM_LOW)
            //CONC-6568
            `uvm_error("DCE_SCB", $psprintf("CMDreq ordering error - masterid not present in sb_cmdrsp tracking queue"));
        end 
        //QOS checks *****************************************************

        if (active_addr_matchq.size() > 1) begin 
            `uvm_error("DCE_SCB", $psprintf("activeq.size: %d should always be either 0 or 1", active_addr_matchq.size()))
        end else if (    (active_addr_matchq.size() == 1)
                      || (recall_addr_matchq.size() >= 1)
                      || (released_addr_matchq.size() == 1)
                      || (released_recall_addr_matchq.size() == 1)
                      || (deleted_recall_addr_matchq.size() == 1)
                      || (dealloc_addr_matchq.size() == 1)
                      || (sleep_addr_matchq.size() >= 1) //there are prior requests with matching cacheline that is sleeping.
                      || (wakeup_addr_matchq.size() >= 1) ) begin //put new request to sleep
            m_dm_cohreq_pkt.m_attid_state = SLEEP;
            m_dce_txnq[inactive_addr_matchq[0]].m_attid_status = ATTID_IS_SLEEP;
            m_dce_txnq[inactive_addr_matchq[0]].m_attid        = m_dm_cohreq_pkt.m_attid;
           `uvm_info(get_name(), $psprintf("[%-35s] (txnId: %5d) {%20s} (src: 0x%02h {%s}) (tgt: 0x%02h) (msgId: 0x%02h) (attid : 0x%02h) (rbid: 0x%02h) (addr: 0x%016h) (%10t, %10t)", "DceScbd-AttAlloc(Sleep)", m_dce_txnq[inactive_addr_matchq[0]].m_txn_id, m_dce_txnq[inactive_addr_matchq[0]].m_initcmdupd_req_pkt.type2cmdname(), m_dce_txnq[inactive_addr_matchq[0]].m_initcmdupd_req_pkt.smi_src_ncore_unit_id, addrMgrConst::get_cache_id_as_string(m_dce_txnq[inactive_addr_matchq[0]].m_initcmdupd_req_pkt.smi_src_ncore_unit_id), m_dce_txnq[inactive_addr_matchq[0]].m_initcmdupd_req_pkt.smi_targ_ncore_unit_id, m_dce_txnq[inactive_addr_matchq[0]].m_initcmdupd_req_pkt.smi_msg_id, m_dce_txnq[inactive_addr_matchq[0]].m_attid, m_dce_txnq[inactive_addr_matchq[0]].m_rbid, m_dce_txnq[inactive_addr_matchq[0]].m_initcmdupd_req_pkt.smi_addr, m_dce_txnq[inactive_addr_matchq[0]].m_initcmdupd_req_pkt.t_smi_ndp_valid, m_dce_txnq[inactive_addr_matchq[0]].t_conc_mux_cmdreq), UVM_LOW);
            if (m_dce_txnq[inactive_addr_matchq[0]].t_dm_cmdreq != 0) begin 
                `uvm_error("DCE_SCB", $psprintf("this is not 1st pass of the cohreq- it was put to sleep before at %0t", m_dce_txnq[inactive_addr_matchq[0]].t_dm_cmdreq))
            end else begin 
                m_dce_txnq[inactive_addr_matchq[0]].t_dm_cmdreq = $time;
            end
        end else begin //new request is active
            m_dm_cohreq_pkt.m_attid_state = ACTIVE;
            m_dce_txnq[inactive_addr_matchq[0]].save_attid_for_rd_stash_ops(m_dm_cohreq_pkt);
            m_dce_txnq[inactive_addr_matchq[0]].m_attid_status = ATTID_IS_ACTIVE;
            m_dce_txnq[inactive_addr_matchq[0]].m_attid        = m_dm_cohreq_pkt.m_attid;
           `uvm_info(get_name(), $psprintf("[%-35s] (txnId: %5d) {%20s} (src: 0x%02h {%s}) (tgt: 0x%02h) (msgId: 0x%02h) (attid : 0x%02h) (rbid: 0x%02h) (addr: 0x%016h) (%10t, %10t)", "DceScbd-AttAlloc(Active)", m_dce_txnq[inactive_addr_matchq[0]].m_txn_id, m_dce_txnq[inactive_addr_matchq[0]].m_initcmdupd_req_pkt.type2cmdname(), m_dce_txnq[inactive_addr_matchq[0]].m_initcmdupd_req_pkt.smi_src_ncore_unit_id, addrMgrConst::get_cache_id_as_string(m_dce_txnq[inactive_addr_matchq[0]].m_initcmdupd_req_pkt.smi_src_ncore_unit_id), m_dce_txnq[inactive_addr_matchq[0]].m_initcmdupd_req_pkt.smi_targ_ncore_unit_id, m_dce_txnq[inactive_addr_matchq[0]].m_initcmdupd_req_pkt.smi_msg_id, m_dce_txnq[inactive_addr_matchq[0]].m_attid, m_dce_txnq[inactive_addr_matchq[0]].m_rbid, m_dce_txnq[inactive_addr_matchq[0]].m_initcmdupd_req_pkt.smi_addr, m_dce_txnq[inactive_addr_matchq[0]].m_initcmdupd_req_pkt.t_smi_ndp_valid, m_dce_txnq[inactive_addr_matchq[0]].t_conc_mux_cmdreq), UVM_LOW);
            m_dce_txnq[inactive_addr_matchq[0]].t_dm_cmdreq    = $time;
        end 
    end else if ((dm_cohreq_matchq.size() >= 1) && (recall_addr_matchq.size() == 0)) begin // sleep-->wake request / sleep-->sleep(due to recall)-->wakeup request
        //`uvm_info("DBG4", "I'm here", UVM_LOW);
        m_dm_cohreq_pkt.m_attid_state = WAKEUP;
        //in sleep_addr_matchq, cohreqs with matching cacheline addr but occuring after this cohreq_pkt are also grabbed, but thats ok since we know that sleep_addr_matchq[0] is this request
        if (sleep_addr_matchq.size() >= 1) begin
            //`uvm_info("DBG", $psprintf("attid:0x%0h is woken up at dm_cohreq function", m_dce_txnq[sleep_addr_matchq[0]].m_attid), UVM_LOW);
            //m_dce_txnq[sleep_addr_matchq[0]].m_attid_status = ATTID_IS_WAKEUP;
            m_dce_txnq[sleep_addr_matchq[0]].save_attid_for_rd_stash_ops(m_dm_cohreq_pkt);
        end
    end

    m_dm_cohreq_pkt.m_set_index   = m_dirm_mgr.set_index_for_cacheline(m_dm_cohreq_pkt.m_addr, m_dm_cohreq_pkt.m_filter_num);  //#Check.DCE.DM.CmdReqFilterNum
    m_dm_cohreq_pkt.m_iid_cacheid = addrMgrConst::get_cache_id(m_dm_cohreq_pkt.m_iid >> WSMINCOREPORTID); //#Check.DCE.DM.CmdReqIID 
    m_dm_cohreq_pkt.m_sid_cacheid = addrMgrConst::get_cache_id(m_dm_cohreq_pkt.m_sid >> WSMINCOREPORTID); 
    m_dm_cohreq_pkt.m_busy_vec_dv = m_dm_cohreq_pkt.m_busy_vec; 
    if (m_dm_cohreq_pktq.size() != 0) begin
        for(int i = 0; i < addrMgrConst::NUM_SF; i++) begin
            offset_aligned_addr_prev_req = m_dirm_mgr.offset_align_cacheline(m_dm_cohreq_pktq[m_dm_cohreq_pktq.size() - 1].m_addr);
            offset_aligned_addr_cur_req  = m_dirm_mgr.offset_align_cacheline(m_dm_cohreq_pkt.m_addr);
            set_index_prev_req           = m_dirm_mgr.set_index_for_cacheline(offset_aligned_addr_prev_req, i);
            set_index_cur_req            = m_dirm_mgr.set_index_for_cacheline(offset_aligned_addr_cur_req, i);
            if ((set_index_cur_req             == set_index_prev_req) && 
                (m_dm_cohreq_pkt.m_cycle_count == m_dm_cohreq_pktq[m_dm_cohreq_pktq.size() - 1].m_cycle_count + 1)) begin
                m_dm_cohreq_pkt.m_pipelined_req_sfvec[i] = 1;
            end
        end
    end
    m_dm_cohreq_pkt.m_pipelined_req = (m_dm_cohreq_pkt.m_pipelined_req_sfvec == 0) ? 0 : 1;
   `uvm_info("DCE_SCB", $psprintf("Received Dir Request @{ACT}: %s", m_dm_cohreq_pkt.convert2string()), UVM_LOW);
    <% if(obj.COVER_ON) { %>
    m_cov.collect_back_back_cmd_upd_reqs(m_dm_cohreq_pkt);
    <%}%>
     cmd_rsp_time_checkq = m_dce_txnq.find_index(item) with ((item.m_initcmdupd_req_pkt.smi_addr == m_dm_cohreq_pkt.m_addr) &&
                                                                (item.m_initcmdupd_req_pkt.smi_ns   == m_dm_cohreq_pkt.m_ns) &&
                                                                (item.m_initcmdupd_req_pkt.smi_msg_type == m_dm_cohreq_pkt.m_type) &&
                                                                (item.m_initcmdupd_req_pkt.smi_src_ncore_unit_id == m_dm_cohreq_pkt.m_iid >> WSMINCOREPORTID) &&
                                                                 item.m_initcmdupd_req_pkt.isCmdMsg());
    if(cmd_rsp_time_checkq.size != 0) begin
        if((m_dce_txnq[cmd_rsp_time_checkq[0]].m_expcmdupd_rsp_pkt.t_smi_ndp_valid != 0) && (m_dce_txnq[cmd_rsp_time_checkq[0]].m_expcmdupd_rsp_pkt.t_smi_ndp_valid != m_dce_txnq[cmd_rsp_time_checkq[0]].t_dm_cmdreq) && (m_dce_txnq[cmd_rsp_time_checkq[0]].m_expcmdupd_rsp_pkt.t_smi_ndp_valid < m_dce_txnq[cmd_rsp_time_checkq[0]].t_dm_cmdreq))
            `uvm_error("DCE_SCB", $psprintf("Command Rsp was issued at %t and Dir_req was at %t Cmdrsp should be after DIR_REQ",m_dce_txnq[cmd_rsp_time_checkq[0]].m_expcmdupd_rsp_pkt.t_smi_ndp_valid,m_dce_txnq[cmd_rsp_time_checkq[0]].t_dm_cmdreq))
    end
    
    if(m_dm_cohreq_pkt.m_cancel == 1) begin
        num_addr_collisions++;    
        sb_stall_if.perf_count_events["Address_Collisions"].push_back(1);
    end
    
    if(dce_goldenref_model::is_stash_request(m_dm_cohreq_pkt.m_type) && m_dm_cohreq_pkt.m_sid_cacheid != -1) begin
        agent_idq = addrMgrConst::get_agent_ids_assoc2cacheid(m_dm_cohreq_pkt.m_sid_cacheid);
        if(snoop_enable_reg[agent_idq[0]] == 1)
            m_dm_cohreq_pkt.stash_target_id_detached = 0;
        else
            m_dm_cohreq_pkt.stash_target_id_detached = 1;
       `uvm_info("DCE_SCB_DBG",$psprintf("m_dm_cohreq_pkt.stash_target_id_detached = %p",m_dm_cohreq_pkt.stash_target_id_detached),UVM_LOW)
    end
    m_dm_cohreq_pktq.push_back(m_dm_cohreq_pkt);
    
    if(deleted_recall_addr_matchq.size() == 1) begin
        idxq = m_dce_txnq.find_index(item) with ((item.m_req_type == CMD_REQ) &&
                            (item.m_initcmdupd_req_pkt.smi_addr >> addrMgrConst::WCACHE_OFFSET == deleted_recall_txnq[deleted_recall_addr_matchq[0]].m_dm_pktq[0].m_addr >> addrMgrConst::WCACHE_OFFSET) &&
                            (item.m_initcmdupd_req_pkt.smi_ns   == deleted_recall_txnq[deleted_recall_addr_matchq[0]].m_dm_pktq[0].m_ns) &&
                            (item.m_attid_status == ATTID_IS_SLEEP));

        if (idxq.size() == 1) begin
            `uvm_info("DCE_SCB", $psprintf("Wake up dce_txnq_idx: %0d attid: 0x%0h on previous recall at attid:0x%0h dealloc", idxq[0], m_dce_txnq[idxq[0]].m_attid,deleted_recall_txnq[deleted_recall_addr_matchq[0]].m_attid), UVM_LOW)
            m_dce_txnq[idxq[0]].m_attid_status = ATTID_IS_WAKEUP;   
        end
    end

    // CONC-13058
    // Moving the way alloc calculation logic into the lookup req task to get past race condition
    m_att_way_alloc_map[m_dm_cohreq_pkt.m_attid] = 0;
    way_cnt = 0;
    set_idx = 0;

    for(int sf_idx=0; sf_idx < addrMgrConst::NUM_SF; sf_idx++) begin
        tag_sf  = m_dirm_mgr.get_tag_sf_handle(sf_idx);
        set_idx = addrMgrConst::get_sf_set_index(sf_idx, {m_dm_cohreq_pkt.m_ns, m_dm_cohreq_pkt.m_addr});
        m_att_way_alloc_map[m_dm_cohreq_pkt.m_attid] = m_att_way_alloc_map[m_dm_cohreq_pkt.m_attid] | (tag_sf.get_alloc_way_vector(set_idx) << way_cnt);
       `uvm_info(get_name(), $psprintf("[%-35s] [attid: 0x%02h] [sf: %2d] [ways: %2d] [wayCnt: %2d] [setIdx: 0x%08h] [cummAllocWays: 0x%10h] [thisAllocWays: 0x%10h]", "DceScbd-AllocWayChk", m_dm_cohreq_pkt.m_attid, sf_idx, tag_sf.num_ways, way_cnt, set_idx, m_att_way_alloc_map[m_dm_cohreq_pkt.m_attid], tag_sf.get_alloc_way_vector(set_idx)), UVM_HIGH);  
        way_cnt = way_cnt + tag_sf.num_ways;
    end
endfunction: process_dm_cohreq

//***********************************************************
function void dce_scb::process_dm_updreq(uvm_phase phase);
    int idxq[$], sf_id, set_idx, hit_way, alloc_ways_before_upd, alloc_ways_after_upd;
    dm_seq_item m_dm_updreq_pkt_temp;
    tag_snoop_filter tag_sf;

   `uvm_info(get_name(), $psprintf("[%-35s] (addr: 0x%016h) (att: 0x%02h, %20s) (msgId: 0x%02h) (access: %20s) (updStat: %20s) (cc: %0d) (statusCc: %0d) (shareVec: 0x%04h) (owner: %1b/0x%02h)\n%s", "DceScbd-UpdInit", m_dm_updreq_pkt.m_addr, m_dm_updreq_pkt.m_attid, m_dm_updreq_pkt.m_attid_state.name(), m_dm_updreq_pkt.m_msg_id, m_dm_updreq_pkt.m_access_type.name(), m_dm_updreq_pkt.m_status.name(), m_dm_updreq_pkt.m_cycle_count, m_dm_updreq_pkt.m_status_cycle_count, m_dm_updreq_pkt.m_sharer_vec, m_dm_updreq_pkt.m_owner_val, m_dm_updreq_pkt.m_owner_num, m_dm_updreq_pkt.convert2string()), UVM_MEDIUM);
    
    //CONC-16312, CONC-16170, updates regards to monitor upd_req_status_valid to capture upd_req_status
    //Now montor only sends the upd_req_pkt after receiving upd_req_status in P2 cycle of pipeline.
    //FOllowing code is no longer required as only one dm_ap.write is made in dce_probe_monitor for upd_req_pkt
    //It means upd_status is not available yet. Just push the updreq_pkt into q and wait for upd_status
    //if (!(m_dm_updreq_pkt.m_status inside {UPD_COMP, UPD_FAIL})) begin
    //    m_dm_updreq_pktq.push_back(m_dm_updreq_pkt);
    //    //SANJEEV: Fix it with CONC-15502: <%if (obj.testBench == "dce") {%>
    //    //SANJEEV: Fix it with CONC-15502: check_sf_obsv_item(.rw               ( 0), 
    //    //SANJEEV: Fix it with CONC-15502:                    .sfid             (addrMgrConst::get_snoopfilter_id(m_dm_updreq_pkt.m_iid >> WSMINCOREPORTID)), 
    //    //SANJEEV: Fix it with CONC-15502:                    .way              (-1), 
    //    //SANJEEV: Fix it with CONC-15502:                    .addr             ({m_dm_updreq_pkt.m_ns, m_dm_updreq_pkt.m_addr}),
    //    //SANJEEV: Fix it with CONC-15502:                    .signature        ("UpdRdChk"),
    //    //SANJEEV: Fix it with CONC-15502:                    .clear_vbhit_busy (0));
    //    //SANJEEV: Fix it with CONC-15502: <%}%>
    //    return;
    //end else if (m_dm_updreq_pkt.m_status inside {UPD_COMP, UPD_FAIL}) begin
    //    if (m_dm_updreq_pktq.size() != 0) begin
    //        m_dm_updreq_pkt_temp = m_dm_updreq_pktq.pop_front();
    //        m_dm_updreq_pkt_temp.m_status = m_dm_updreq_pkt.m_status;
    //        m_dm_updreq_pkt_temp.m_status_cycle_count = m_dm_updreq_pkt.m_status_cycle_count;
    //        void'($cast(m_dm_updreq_pkt, m_dm_updreq_pkt_temp.clone()));
    //        m_dm_updreq_pkt.m_iid_cacheid = addrMgrConst::get_cache_id(m_dm_updreq_pkt.m_iid >> WSMINCOREPORTID); 
    //    end
    //    `uvm_info("DCE_SCB", $psprintf("Received Dir Request @{ACT}: %s", m_dm_updreq_pkt.convert2string()), UVM_LOW);
    //end
    m_dm_updreq_pkt.m_iid_cacheid = addrMgrConst::get_cache_id(m_dm_updreq_pkt.m_iid >> WSMINCOREPORTID); 
    `uvm_info("DCE_SCB", $psprintf("Received Dir Request @{ACT}: %s", m_dm_updreq_pkt.convert2string()), UVM_LOW);
    
    idxq = m_dce_txnq.find_index(item) with (
        (item.m_initcmdupd_req_pkt.smi_addr   == m_dm_updreq_pkt.m_addr) &&
        (item.m_initcmdupd_req_pkt.smi_ns     == m_dm_updreq_pkt.m_ns  ) &&
        (((item.m_initcmdupd_req_pkt.smi_src_id >> WSMINCOREPORTID) << WSMINCOREPORTID) == m_dm_updreq_pkt.m_iid) &&
         item.m_initcmdupd_req_pkt.isUpdMsg() &&
       !item.m_states["dirreq"].is_complete());

    //there could be back-to-back UpdInv from same agentid, cacheline_addr since the cache_model is not updated until DM_UPD_REQ, so disble this check and just match with the ldest one.
    //#Check.DCE.DM.UPDreq_attributes
    if (idxq.size() == 0) begin
        dirm_pktmatch_checks(idxq, m_dm_updreq_pkt, "DM_UPD_REQ"); //#Check.DCE.DM.UPDReq_attributes
    end
        
    m_dce_txnq[idxq[0]].m_states["dirreq"].set_valid(m_dm_updreq_pkt.m_time);
    sf_id   = addrMgrConst::get_snoopfilter_id(m_dm_updreq_pkt.m_iid >> WSMINCOREPORTID);
    tag_sf  = m_dirm_mgr.get_tag_sf_handle(sf_id);
    set_idx = addrMgrConst::get_sf_set_index(sf_id, {m_dm_updreq_pkt.m_ns, m_dm_updreq_pkt.m_addr});

    //update DM_model on directory request only if UPD is successful CONC-6467
    if (m_dm_updreq_pkt.m_status == UPD_COMP) begin //#Check.DCE.DM.UPDreq_COMP_DMmodelupdate
        alloc_ways_before_upd = tag_sf.get_alloc_way_vector(set_idx);
        hit_way = m_dirm_mgr.update_request({m_dm_updreq_pkt.m_ns, m_dm_updreq_pkt.m_addr}, (m_dm_updreq_pkt.m_iid >> WSMINCOREPORTID), 1);
        alloc_ways_after_upd = tag_sf.get_alloc_way_vector(set_idx);
        m_updreq_aa[m_dce_txnq[idxq[0]].m_initcmdupd_req_pkt.smi_src_ncore_unit_id][m_dce_txnq[idxq[0]].m_initcmdupd_req_pkt.smi_msg_id] = {m_dm_updreq_pkt.m_ns, m_dm_updreq_pkt.m_addr};
       `uvm_info(get_name(), $psprintf("[%-35s] (txnId: %5d) {%20s} (src: 0x%02h {%s}) (tgt: 0x%02h) (msgId: 0x%02h) (attid : ----) (rbid: ----) (addr: 0x%016h) (att: 0x%02h, %20s) (msgId: 0x%02h) (access: %20s) (updStat: %20s) (iid: 0x%02h) (sfId: %2d) (setIndex: 0x%08h) (hitWay: %2d) (allocWays: 0x%08h -> 0x%08h)\n%s", "DceScbd-UpdPass", m_dce_txnq[idxq[0]].m_txn_id, m_dce_txnq[idxq[0]].m_initcmdupd_req_pkt.type2cmdname(), m_dce_txnq[idxq[0]].m_initcmdupd_req_pkt.smi_src_ncore_unit_id, addrMgrConst::get_cache_id_as_string(m_dce_txnq[idxq[0]].m_initcmdupd_req_pkt.smi_src_ncore_unit_id), m_dce_txnq[idxq[0]].m_initcmdupd_req_pkt.smi_targ_ncore_unit_id, m_dce_txnq[idxq[0]].m_initcmdupd_req_pkt.smi_msg_id, m_dm_updreq_pkt.m_addr, m_dm_updreq_pkt.m_attid, m_dm_updreq_pkt.m_attid_state.name(), m_dm_updreq_pkt.m_msg_id, m_dm_updreq_pkt.m_access_type.name(), m_dm_updreq_pkt.m_status.name(), m_dm_updreq_pkt.m_iid, sf_id, set_idx, hit_way, alloc_ways_before_upd, alloc_ways_after_upd, m_dm_updreq_pkt.convert2string()), UVM_LOW);

        <%if (obj.testBench == "dce") {%>
        // plru checks and updates
        if(m_plru_en) begin
            if(hit_way != -1) begin
                //SANJEEV: Fix it with CONC-15502: //#Check.DCE.v36.PlruUpResponse
                //SANJEEV: Fix it with CONC-15502: check_sf_obsv_item(.rw               (1), 
                //SANJEEV: Fix it with CONC-15502:                    .sfid             (addrMgrConst::get_snoopfilter_id(m_dm_updreq_pkt.m_iid >> WSMINCOREPORTID)), 
                //SANJEEV: Fix it with CONC-15502:                    .way              (hit_way), 
                //SANJEEV: Fix it with CONC-15502:                    .addr             ({m_dm_updreq_pkt.m_ns, m_dm_updreq_pkt.m_addr}), 
                //SANJEEV: Fix it with CONC-15502:                    .signature        ("UpdWrChk"),
                //SANJEEV: Fix it with CONC-15502:                    .clear_vbhit_busy (0));

                // CONC-12837
                // Dont update plru state when we update as it basically invalidates its own entry, meaning it was not accessed to be reused which sounds fair
            end
        end
        <%}%>
        ->upd_comp_e;
    end else if (m_dm_updreq_pkt.m_status == UPD_FAIL) begin //#Check.DCE.DM.UPDreq_FAIL_NoDMmodelupdate 
        alloc_ways_before_upd = tag_sf.get_alloc_way_vector(set_idx);
        hit_way = m_dirm_mgr.update_request({m_dm_updreq_pkt.m_ns, m_dm_updreq_pkt.m_addr}, (m_dm_updreq_pkt.m_iid >> WSMINCOREPORTID), 0);
        alloc_ways_after_upd = tag_sf.get_alloc_way_vector(set_idx);
       `uvm_info(get_name(), $psprintf("[%-35s] (txnId: %5d) {%20s} (src: 0x%02h {%s}) (tgt: 0x%02h) (msgId: 0x%02h) (attid : ----) (rbid: ----) (addr: 0x%016h) (att: 0x%02h, %20s) (msgId: 0x%02h) (access: %20s) (updStat: %20s) (iid: 0x%02h) (sfId: %2d) (setIndex: 0x%08h) (hitWay: %2d) (allocWays: 0x%08h -> 0x%08h)\n%s", "DceScbd-UpdFail", m_dce_txnq[idxq[0]].m_txn_id, m_dce_txnq[idxq[0]].m_initcmdupd_req_pkt.type2cmdname(), m_dce_txnq[idxq[0]].m_initcmdupd_req_pkt.smi_src_ncore_unit_id, addrMgrConst::get_cache_id_as_string(m_dce_txnq[idxq[0]].m_initcmdupd_req_pkt.smi_src_ncore_unit_id), m_dce_txnq[idxq[0]].m_initcmdupd_req_pkt.smi_targ_ncore_unit_id, m_dce_txnq[idxq[0]].m_initcmdupd_req_pkt.smi_msg_id, m_dm_updreq_pkt.m_addr, m_dm_updreq_pkt.m_attid, m_dm_updreq_pkt.m_attid_state.name(), m_dm_updreq_pkt.m_msg_id, m_dm_updreq_pkt.m_access_type.name(), m_dm_updreq_pkt.m_status.name(), m_dm_updreq_pkt.m_iid, sf_id, set_idx, hit_way, alloc_ways_before_upd, alloc_ways_after_upd, m_dm_updreq_pkt.convert2string()), UVM_LOW);
    end else begin 
        `uvm_error("DCE SCB", $psprintf("m_upd_status:%p not expected", m_dm_updreq_pkt.m_status))
    end 
    
    //sample DM coverage data.
    <% if(obj.COVER_ON) { %>
    //Only look at RTL signal for coverage collection
    m_dirm_mgr.collect_dm_coverage();
    m_cov.collect_dirm_scenario(m_dirm_mgr);
    m_cov.collect_back_back_cmd_upd_reqs(m_dm_updreq_pkt);
    <% } %>
    
    //Check for completion
    if (check_for_completion(idxq[0])) begin
        <% if(obj.COVER_ON) { %>
        m_cov.collect_dce_scb_txn(m_dce_txnq[idxq[0]]);
        <% } %>

       `uvm_info(get_name(), $psprintf("[%-35s] (txnId: %5d) {%20s} (src: 0x%02h {%s}) (tgt: 0x%02h) (msgId: 0x%02h) (attid : 0x%02h) (rbid: 0x%02h) (addr: 0x%016h) (%10t, %10t)", "DceScbd-TxnQDel(5)", m_dce_txnq[idxq[0]].m_txn_id, m_dce_txnq[idxq[0]].m_initcmdupd_req_pkt.type2cmdname(), m_dce_txnq[idxq[0]].m_initcmdupd_req_pkt.smi_src_ncore_unit_id, addrMgrConst::get_cache_id_as_string(m_dce_txnq[idxq[0]].m_initcmdupd_req_pkt.smi_src_ncore_unit_id), m_dce_txnq[idxq[0]].m_initcmdupd_req_pkt.smi_targ_ncore_unit_id, m_dce_txnq[idxq[0]].m_initcmdupd_req_pkt.smi_msg_id, m_dce_txnq[idxq[0]].m_attid, m_dce_txnq[idxq[0]].m_rbid, m_dce_txnq[idxq[0]].m_initcmdupd_req_pkt.smi_addr, m_dce_txnq[idxq[0]].m_initcmdupd_req_pkt.t_smi_ndp_valid, m_dce_txnq[idxq[0]].t_conc_mux_cmdreq), UVM_LOW);
        drop_objection(phase, idxq[0]);
        m_dce_txnq.delete(idxq[0]);
        ->e_attid_dealloc; //reusing same event to tell dce_mst_seq that the upd req is completed and single_step can proceed
    end else begin
        //`uvm_info("DBG", $psprintf("On DM_UPD_REQ %0s not deleted from dce_txnq", m_dce_txnq[idxq[0]].print_txn(1)), UVM_LOW);  
    end
endfunction: process_dm_updreq

//***********************************************************
function void dce_scb::process_dm_cmtreq(uvm_phase phase);
    string s;
    int idxq[$], jdxq[$];
    int dce_txnq_wakeup_idx, way_vec, sfid_sel;
    dm_seq_item cmd_req;
    tag_snoop_filter tag_sf;

    if (garbage_dmiid)
        return;

    idxq = m_dce_txnq.find_index(item) with (
            item.m_initcmdupd_req_pkt.smi_addr              == m_dm_cmtreq_pkt.m_addr &&
            item.m_initcmdupd_req_pkt.smi_ns                == m_dm_cmtreq_pkt.m_ns   &&
            (item.m_attid_status inside {ATTID_IS_ACTIVE, ATTID_IS_WAKEUP}) &&
           !item.m_states["dirreq"].is_complete() &&
            item.m_states["dirrsp"].is_complete());

    if (idxq.size() == 0 && (clean_exit_due_to_wrong_targetid_RBrsp == 1 || clean_exit_due_to_wrong_targetid_MRDrsp == 1)) begin
        return;
        end 

    if(idxq.size() == 0) begin // debug
        idxq = m_dce_txnq.find_index(item) with (
            item.m_initcmdupd_req_pkt.smi_addr              == m_dm_cmtreq_pkt.m_addr &&
            item.m_initcmdupd_req_pkt.smi_ns                == m_dm_cmtreq_pkt.m_ns   &&
            (item.m_attid_status inside {ATTID_IS_ACTIVE, ATTID_IS_WAKEUP}) &&
            item.m_states["dirrsp"].is_complete());
        
        m_dce_txnq[idxq[0]].snoop_enable_reg_txn = snoop_enable_reg;
        m_dce_txnq[idxq[0]].repredict_snp_mrd_reqs;
    
        idxq = m_dce_txnq.find_index(item) with (
            item.m_initcmdupd_req_pkt.smi_addr              == m_dm_cmtreq_pkt.m_addr &&
            item.m_initcmdupd_req_pkt.smi_ns                == m_dm_cmtreq_pkt.m_ns   &&
            (item.m_attid_status inside {ATTID_IS_ACTIVE, ATTID_IS_WAKEUP}) &&
           !item.m_states["dirreq"].is_complete() &&
            item.m_states["dirrsp"].is_complete());
        
        if(idxq.size() == 0) begin
            idxq = m_dce_txnq.find_index(item) with (
                        item.m_initcmdupd_req_pkt.smi_addr              == m_dm_cmtreq_pkt.m_addr &&
                        item.m_initcmdupd_req_pkt.smi_ns                == m_dm_cmtreq_pkt.m_ns   &&
                        (item.m_attid_status inside {ATTID_IS_ACTIVE, ATTID_IS_WAKEUP}) &&
                        item.m_states["dirrsp"].is_complete());
    
            m_dm_cmtreq_pkt.m_attid = m_dce_txnq[idxq[0]].m_attid; 
           `uvm_error("DCE SCB",$psprintf("@{ACT}: Received unexpected dm cmtreq. No matches in m_dce_txnq. pkt: %s", m_dm_cmtreq_pkt.convert2string()))
        end
    end

    dirm_pktmatch_checks(idxq, m_dm_cmtreq_pkt, "DM_CMT_REQ");
    m_dm_cmtreq_pkt.m_attid = m_dce_txnq[idxq[0]].m_attid; 

   `uvm_info("DCE SCB", $psprintf("@{ACT}: Received dm cmtreq pkt: %s", m_dm_cmtreq_pkt.convert2string()), UVM_LOW)

   `uvm_info(get_name(), $psprintf("[%-35s] (txnId: %5d) {%20s} (src: 0x%02h {%s}) (tgt: 0x%02h) (msgId: 0x%02h) (attid : 0x%02h) (rbid: 0x%02h) (addr: 0x%016h) (att: 0x%02h, %20s) (msgId: 0x%02h) (access: %20s) (updStat: %20s) (shareVec: 0x%04h) (owner: %1b/0x%02h) (wayVec: 0x%08h) (changeVec: 0x%04h)\n%s", "DceScbd-CmtReq", m_dce_txnq[idxq[0]].m_txn_id, m_dce_txnq[idxq[0]].m_initcmdupd_req_pkt.type2cmdname(), m_dce_txnq[idxq[0]].m_initcmdupd_req_pkt.smi_src_ncore_unit_id, addrMgrConst::get_cache_id_as_string(m_dce_txnq[idxq[0]].m_initcmdupd_req_pkt.smi_src_ncore_unit_id), m_dce_txnq[idxq[0]].m_initcmdupd_req_pkt.smi_targ_ncore_unit_id, m_dce_txnq[idxq[0]].m_initcmdupd_req_pkt.smi_msg_id, m_dce_txnq[idxq[0]].m_attid, m_dce_txnq[idxq[0]].m_rbid, m_dm_cmtreq_pkt.m_addr, m_dm_cmtreq_pkt.m_attid, m_dm_cmtreq_pkt.m_attid_state.name(), m_dm_cmtreq_pkt.m_msg_id, m_dm_cmtreq_pkt.m_access_type.name(), m_dm_cmtreq_pkt.m_status.name(), m_dm_cmtreq_pkt.m_sharer_vec, m_dm_cmtreq_pkt.m_owner_val, m_dm_cmtreq_pkt.m_owner_num, m_dm_cmtreq_pkt.m_way_vec_or_mask, m_dm_cmtreq_pkt.m_change_vec, m_dm_cmtreq_pkt.convert2string()), UVM_LOW);
    m_dce_txnq[idxq[0]].m_states["dirreq"].set_valid(m_dm_cmtreq_pkt.m_time);

    <%if (obj.testBench == "dce") {%>
    // hashing checks
    way_vec = m_dce_txnq[idxq[0]].dm_lkprsp.m_way_vec_or_mask;
    for(int sf_idx=0; sf_idx < addrMgrConst::NUM_SF; sf_idx++) begin
        sfid_sel = 0;
        foreach(addrMgrConst::funit2sf_slice[funit_idx]) begin
            if((m_dm_cmtreq_pkt.m_change_vec[funit_idx] == 1) && (addrMgrConst::funit2sf_slice[funit_idx] == sf_idx)) begin
                sfid_sel = 1;
                break;
            end
        end

        // YRAMASAMY: Is this check valid? Need to check with Boon
        tag_sf = m_dirm_mgr.get_tag_sf_handle(sf_idx);
        if((sfid_sel == 1) && (way_vec & ((1 << tag_sf.num_ways) -1)) > 0) begin
             //#Check.DCE.v36.PlruUpResponse
             check_sf_obsv_item(.rw               (1), 
                                .sfid             (sf_idx), 
                                .way              (m_dirm_mgr.get_waynum(sf_idx, m_dce_txnq[idxq[0]].dm_lkprsp.m_way_vec_or_mask)), 
                                .addr             ({m_dce_txnq[idxq[0]].dm_lkprsp.m_ns, m_dce_txnq[idxq[0]].dm_lkprsp.m_addr}), 
                                .signature        ("CmtWrChk"),
                                .clear_vbhit_busy (1));
        end
        way_vec = way_vec >> tag_sf.num_ways;
    end
    <%}%>

    <% if(obj.COVER_ON) { %>
    m_cov.collect_back_back_cmd_upd_reqs(m_dm_cmtreq_pkt);
    <%}%>

    m_dce_txnq[idxq[0]].check_dm_req_txn(m_dm_cmtreq_pkt);
    m_dce_txnq[idxq[0]].time_struct.dm_write = $time; 

    //wakeup pending ops if any on attid dealloc.
    if (check_for_attid_deallocation(idxq[0])) begin
        jdxq = m_dce_txnq.find_index(item) with (  (item.m_initcmdupd_req_pkt.smi_addr >> addrMgrConst::WCACHE_OFFSET == m_dce_txnq[idxq[0]].m_initcmdupd_req_pkt.smi_addr >> addrMgrConst::WCACHE_OFFSET) &&
                                                   (item.m_initcmdupd_req_pkt.smi_ns   == m_dce_txnq[idxq[0]].m_initcmdupd_req_pkt.smi_ns) &&
                                                   (item.m_attid_status == ATTID_IS_SLEEP)
                                                );

        m_attvld_aa[m_dce_txnq[idxq[0]].m_attid]  = m_dce_txnq[idxq[0]];
       `uvm_info(get_name(), $psprintf("[%-35s] (txnId: %5d) {%20s} (src: 0x%02h {%s}) (tgt: 0x%02h) (msgId: 0x%02h) (attid : 0x%02h) (rbid: 0x%02h) (addr: 0x%016h) (%10t, %10t)", "DceScbd-AttRelease(5)", m_dce_txnq[idxq[0]].m_txn_id, m_dce_txnq[idxq[0]].m_initcmdupd_req_pkt.type2cmdname(), m_dce_txnq[idxq[0]].m_initcmdupd_req_pkt.smi_src_ncore_unit_id, addrMgrConst::get_cache_id_as_string(m_dce_txnq[idxq[0]].m_initcmdupd_req_pkt.smi_src_ncore_unit_id), m_dce_txnq[idxq[0]].m_initcmdupd_req_pkt.smi_targ_ncore_unit_id, m_dce_txnq[idxq[0]].m_initcmdupd_req_pkt.smi_msg_id, m_dce_txnq[idxq[0]].m_attid, m_dce_txnq[idxq[0]].m_rbid, m_dce_txnq[idxq[0]].m_initcmdupd_req_pkt.smi_addr, m_dce_txnq[idxq[0]].m_initcmdupd_req_pkt.t_smi_ndp_valid, m_dce_txnq[idxq[0]].t_conc_mux_cmdreq), UVM_LOW);
        m_dce_txnq[idxq[0]].m_attid_status        = ATTID_IS_RELEASED;
        m_dce_txnq[idxq[0]].m_attid_release_cycle = $time;
    end 
    
endfunction: process_dm_cmtreq

//***********************************************************
function void dce_scb::process_dm_lkprsp();
    int idxq[$], jdxq[$], way_cnt, sf_id, set_idx, commit_funit_id, way;
    bit match_active = 0;
    bit match_wakeup = 0;
    bit ignore, addr_match;
    int alloc_ways, busy_vec, sharer_vec_mask;
    string s;
    tag_snoop_filter tag_sf;

    //#Check.DCE.dm_CmdRsp_attid
    idxq = m_dm_cohreq_pktq.find_index(item) with (item.m_attid == m_dm_lkprsp_pkt.m_attid);

    s = "";

    if (idxq.size() == 1) begin
        if (m_dm_cohreq_pktq[idxq[0]].m_attid_state == ACTIVE) begin 
            match_active = 1;
        end else if (m_dm_cohreq_pktq[idxq[0]].m_attid_state == WAKEUP) begin
            match_wakeup = 1;
        end else if (m_dm_cohreq_pktq[idxq[0]].m_attid_state == SLEEP) begin
            m_dm_lkprsp_pkt.m_attid_state = SLEEP;
        end
        else begin
            `uvm_error("DCE_SCB", $psprintf("matching outstanding cohreq_pkt with attid_state:%s not expected",m_dm_cohreq_pktq[idxq[0]].m_attid_state));
        end 
    end else if (idxq.size() == 2) begin
        if ((m_dm_cohreq_pktq[idxq[0]].m_attid_state == SLEEP) && (m_dm_cohreq_pktq[idxq[1]].m_attid_state == WAKEUP)) begin
            match_wakeup = 1;
        end else if ((m_dm_cohreq_pktq[idxq[0]].m_attid_state == SLEEP) && (m_dm_cohreq_pktq[idxq[1]].m_attid_state == SLEEP)) begin //happens if a WAKEUP(already woken up) request is put to sleep again due to a recall see CONC-5564
            m_dm_lkprsp_pkt.m_attid_state = SLEEP;
        end else begin
            `uvm_error("DCE_SCB", $psprintf("matching outstanding cohreq_pkts for attid:0x%0h with attid_state_0:%s attid_state_1:%s not expected", m_dm_cohreq_pktq[idxq[0]].m_attid, m_dm_cohreq_pktq[idxq[0]].m_attid_state.name, m_dm_cohreq_pktq[idxq[1]].m_attid_state.name));
        end
    end else if (idxq.size() == 3) begin //occurs when an already woken up request is put to sleep by a recall and finally wakes up after recall completes
        if ((m_dm_cohreq_pktq[idxq[0]].m_attid_state == SLEEP) && (m_dm_cohreq_pktq[idxq[1]].m_attid_state == SLEEP) && (m_dm_cohreq_pktq[idxq[2]].m_attid_state == WAKEUP)) begin
            match_wakeup = 1;
        end else begin
            `uvm_error("DCE_SCB", $psprintf("matching outstanding cohreq_pkts with attid_state_0:%s attid_state_1:%s attid_state_2:%s not expected", m_dm_cohreq_pktq[idxq[0]].m_attid_state.name, m_dm_cohreq_pktq[idxq[1]].m_attid_state.name, m_dm_cohreq_pktq[idxq[2]].m_attid_state.name));
        end
    end else begin
    //HS 03-16-21 DM CMDreq could be put to SLEEP any number of times due to a conflicting REC_REQ, but should eventually WAKEUP before LKP_RSP is seen on DM interface.
        foreach(idxq[i]) begin 
            $sformat(s, "%s %s", s, m_dm_cohreq_pktq[idxq[i]].m_attid_state);
        end
        if (m_dm_cohreq_pktq[idxq[idxq.size()-1]].m_attid_state == WAKEUP)
            match_wakeup = 1;
        else 
            `uvm_error("DCE_SCB", $psprintf("For attid:%0d, LKP_RSP is received when cohreq_pkt states are -- %0s ", idxq.size(), m_dm_lkprsp_pkt.m_attid, s));
    end
    s = "";

    if((match_active == 1) || (match_wakeup == 1)) begin
        if (match_active)
            m_dm_lkprsp_pkt.m_attid_state = ACTIVE;
        else if (match_wakeup)
            m_dm_lkprsp_pkt.m_attid_state = WAKEUP;
        

        jdxq = m_dce_txnq.find_index(item) with (
                    item.m_initcmdupd_req_pkt.isCmdMsg() &&
                    item.m_attid        == m_dm_lkprsp_pkt.m_attid  &&
                    (item.m_initcmdupd_req_pkt.smi_src_ncore_unit_id == (m_dm_cohreq_pktq[idxq[idxq.size()-1]].m_iid >> WSMINCOREPORTID)) &&
                    (item.m_attid_status inside {ATTID_IS_ACTIVE, ATTID_IS_WAKEUP})  &&
                    !item.m_states["dirreq"].is_complete() && 
                    !item.m_states["dirrsp"].is_complete());

        //below if condition is needed if there were retries before this LKP_RSP.
        if (jdxq.size() == 0) begin
            jdxq.delete();
            jdxq = m_dce_txnq.find_index(item) with (
                        item.m_initcmdupd_req_pkt.isCmdMsg() &&
                        item.m_attid        == m_dm_lkprsp_pkt.m_attid  &&
                        (item.m_initcmdupd_req_pkt.smi_src_ncore_unit_id == (m_dm_cohreq_pktq[idxq[idxq.size()-1]].m_iid >> WSMINCOREPORTID)) &&
                        (item.m_attid_status inside {ATTID_IS_ACTIVE, ATTID_IS_WAKEUP})  &&
                        !item.m_states["dirreq"].is_complete() && 
                        (item.m_states["dirrsp"].get_valid_count() >= 1));
            //`uvm_info("LKPRSP_DBG2", $psprintf("size: %0d", jdxq.size()), UVM_LOW)
        end
    
        m_dm_lkprsp_pkt.m_alloc      = m_dm_cohreq_pktq[idxq[idxq.size()-1]].m_alloc;
        m_dm_lkprsp_pkt.m_type       = m_dm_cohreq_pktq[idxq[idxq.size()-1]].m_type;
        m_dm_lkprsp_pkt.m_filter_num = m_dm_cohreq_pktq[idxq[idxq.size()-1]].m_filter_num;
        m_dm_lkprsp_pkt.m_set_index  = m_dm_cohreq_pktq[idxq[idxq.size()-1]].m_set_index;
        m_dm_lkprsp_pkt.m_addr       = m_dm_cohreq_pktq[idxq[idxq.size()-1]].m_addr;
        m_dm_lkprsp_pkt.m_ns         = m_dm_cohreq_pktq[idxq[idxq.size()-1]].m_ns;
        m_dm_lkprsp_pkt.m_sid        = m_dm_cohreq_pktq[idxq[idxq.size()-1]].m_sid;
        m_dm_lkprsp_pkt.m_iid        = m_dm_cohreq_pktq[idxq[idxq.size()-1]].m_iid;
        m_dm_lkprsp_pkt.m_busy_vec   = m_dm_cohreq_pktq[idxq[idxq.size()-1]].m_busy_vec;
        if (m_dm_lkprsp_pkt.m_alloc == 1) begin
            m_dm_lkprsp_pkt.m_way = m_dirm_mgr.get_waynum(m_dm_lkprsp_pkt.m_filter_num, m_dm_lkprsp_pkt.m_way_vec_or_mask);
        end
       `uvm_info("DCE SCB", $psprintf("Received Dir Response @{ACT}: %s", m_dm_lkprsp_pkt.convert2string()), UVM_LOW);
        
        <% if(obj.COVER_ON) { %>
        m_cov.collect_back_to_back_allocs(m_dm_lkprsp_pkt, (m_dm_cohreq_pktq[idxq[idxq.size()-1]].m_iid >> WSMINCOREPORTID));
        m_cov.collect_back_to_back_non_allocs(m_dm_lkprsp_pkt, (m_dm_cohreq_pktq[idxq[idxq.size()-1]].m_iid >> WSMINCOREPORTID));
        <%}%>

        //#Check.DCE.v36.ReverseAddrHash
        dirm_pktmatch_checks(jdxq, m_dm_lkprsp_pkt, "DM LKP_RSP");
        if ($test$plusargs("dce_addr_aliasing_seq")) begin
            if(!m_dm_lkprsp_pkt.is_dm_miss())
               `uvm_error("DCE_SCB",$psprintf("addr_aliasing_test should be a dm_miss"))
        end

        //if there is error on dm_lkp_rsp, set expect for strreq and clear all other expects except strreq and strrsp -- See CONC-6771
        if (m_dm_lkprsp_pkt.m_error == 1) begin 
            `uvm_info("DCE SCB", $psprintf("DM_LKP_RSP has error"), UVM_LOW)
            foreach(m_dce_txnq[jdxq[0]].m_states[idx]) begin
                if (!(m_dce_txnq[jdxq[0]].m_states[idx].get_name() inside {"strreq", "strrsp"})) begin
                    m_dce_txnq[jdxq[0]].m_states[idx].set_complete();
                end
            end
        end
       
        //this needs to be computed before COH_REQ is checked
        if (m_dce_txnq[jdxq[0]].is_exclusive_operation(ignore, ignore)) begin
            $sformat(s, "%s\n basic_mon:%0p", s, m_basic_mon);
            foreach(m_tagged_mon[idx]) begin
                $sformat(s, "%s\n mon_idx:%0d mon_vld:%0b tagaddr:0x%0h tagged_mon:%0p", s, idx, m_tagged_mon[idx].mon_vld, m_tagged_mon[idx].tagged_addr, m_tagged_mon[idx].tagged_mon);
            end
            `uvm_info("DCE SCB", $psprintf("Exclusive/Basic monitors info before update of %p with addr:0x%0h cacheline_addr:0x%0h: %s", m_dce_txnq[jdxq[0]].m_cmd_type, {m_dce_txnq[jdxq[0]].m_initcmdupd_req_pkt.smi_ns, m_dce_txnq[jdxq[0]].m_initcmdupd_req_pkt.smi_addr}, {m_dce_txnq[jdxq[0]].m_initcmdupd_req_pkt.smi_ns, m_dce_txnq[jdxq[0]].m_initcmdupd_req_pkt.smi_addr} >> addrMgrConst::WCACHE_OFFSET, s), UVM_LOW)
            
            //#Check.DCE.ExMon.MonUpdOnLkpRsp
            predict_exmon_result(jdxq[0], m_dm_cohreq_pktq[idxq[idxq.size()-1]].m_iid_cacheid, m_dm_lkprsp_pkt.m_sharer_vec);
            s = "";
            $sformat(s, "%s\n basic_mon:%0p", s, m_basic_mon);
            
            foreach(m_tagged_mon[idx]) begin
                $sformat(s, "%s\n mon_idx:%0d mon_vld:%0b tagaddr:0x%0h tagged_mon:%0p", s, idx, m_tagged_mon[idx].mon_vld, m_tagged_mon[idx].tagged_addr, m_tagged_mon[idx].tagged_mon);
            end
            `uvm_info("DCE SCB", $psprintf("Exclusive/Basic monitors info after update of %p: %s", m_dce_txnq[jdxq[0]].m_cmd_type, s), UVM_LOW)
        end

        foreach (m_dm_cohreq_pktq[i]) begin
            //updated as per CONC-5167
            if ((m_dm_cohreq_pktq[i].m_pipelined_req == 1) && (m_dm_cohreq_pktq[i].m_cycle_count == m_dm_lkprsp_pkt.m_cycle_count - 1)) begin 
                addr_match = ((m_dm_cohreq_pktq[i].m_addr >> addrMgrConst::WCACHE_OFFSET == m_dce_txnq[jdxq[0]].m_initcmdupd_req_pkt.smi_addr >> addrMgrConst::WCACHE_OFFSET) && (m_dm_cohreq_pktq[i].m_ns == m_dce_txnq[jdxq[0]].m_initcmdupd_req_pkt.smi_ns)) ? 1 : 0;
                m_dm_cohreq_pktq[i].m_busy_vec_dv = (addr_match == 1) ? ((m_dm_cohreq_pktq[i].m_wakeup == 0) ? (m_dm_cohreq_pktq[i].m_busy_vec | m_dm_lkprsp_pkt.m_way_vec_or_mask) : m_dm_cohreq_pktq[i].m_busy_vec) : (m_dm_cohreq_pktq[i].m_busy_vec | m_dm_lkprsp_pkt.m_way_vec_or_mask); 

                //`uvm_info("UPD_DM_COH_REQ", $psprintf("%s", m_dm_cohreq_pktq[i].convert2string()), UVM_LOW);
            end
        end
    
        m_dce_txnq[jdxq[0]].snoop_enable_reg_txn = snoop_enable_reg;
        foreach(snoop_enable_reg[x]) begin
            if(snoop_enable_reg[x] == 1)
                `uvm_info("DCE_SCB_DBG",$psprintf("cacheid attached = %p", addrMgrConst::get_cache_id(x)),UVM_LOW)
        end

        //check_coh_req
        // YRAMASAMY: Can this be simplified? Just do the last else block always?
        if (idxq.size() == 1) begin
            m_dce_txnq[jdxq[0]].m_states["dirreq"].set_valid(m_dm_cohreq_pktq[idxq[0]].m_time);
            m_dce_txnq[jdxq[0]].check_dm_req_txn(m_dm_cohreq_pktq[idxq[0]]);
            m_dm_cohreq_pktq.delete(idxq[0]);
        end else if (idxq.size() == 2) begin
            m_dce_txnq[jdxq[0]].m_states["dirreq"].set_valid(m_dm_cohreq_pktq[idxq[1]].m_time);
            m_dce_txnq[jdxq[0]].check_dm_req_txn(m_dm_cohreq_pktq[idxq[1]]);
            m_dm_cohreq_pktq.delete(idxq[1]);
            m_dm_cohreq_pktq.delete(idxq[0]);
        end else if (idxq.size() == 3) begin
            m_dce_txnq[jdxq[0]].m_states["dirreq"].set_valid(m_dm_cohreq_pktq[idxq[2]].m_time);
            m_dce_txnq[jdxq[0]].check_dm_req_txn(m_dm_cohreq_pktq[idxq[2]]);
            m_dm_cohreq_pktq.delete(idxq[2]);
            m_dm_cohreq_pktq.delete(idxq[1]);
            m_dm_cohreq_pktq.delete(idxq[0]);
        end else begin 
            m_dce_txnq[jdxq[0]].m_states["dirreq"].set_valid(m_dm_cohreq_pktq[idxq[idxq.size()-1]].m_time);
            m_dce_txnq[jdxq[0]].check_dm_req_txn(m_dm_cohreq_pktq[idxq[idxq.size()-1]]);
            for(int k = idxq.size()-1; k >= 0; k--) begin
                m_dm_cohreq_pktq.delete(idxq[k]);
            end
        end 

        commit_funit_id = dce_goldenref_model::is_stash_request(m_dm_lkprsp_pkt.m_type) ? m_dm_lkprsp_pkt.m_sid : m_dm_lkprsp_pkt.m_iid;
        alloc_ways      = m_att_way_alloc_map[m_dm_lkprsp_pkt.m_attid];
        busy_vec        = m_dm_lkprsp_pkt.m_busy_vec;
        sf_id           = addrMgrConst::get_snoopfilter_id(commit_funit_id >> WSMINCOREPORTID);
        set_idx         = addrMgrConst::get_sf_set_index(sf_id, {m_dm_lkprsp_pkt.m_ns, m_dm_lkprsp_pkt.m_addr});
       `uvm_info(get_name(), $psprintf("[%-35s] (txnId: %5d) {%20s} (src: 0x%02h {%s}) (tgt: 0x%02h) (msgId: 0x%02h) (attid : 0x%02h) (rbid: 0x%02h) (addr: 0x%016h) (att: 0x%02h, %10s) (msgId: 0x%02h) (access: %10s) (vbhit: 0x%02h) (shareVec: 0x%04h) (owner: %1b/0x%02h) (wayVec: 0x%10h) (busyVec: 0x%10h) (wrReq: %2d) (allocCmd: %1d) (iid: %2d) (sid: %2d) (cmtIid: %2d) (sfId: %2d) (setIndex: 0x%08h) (way: %2d) (allocWays: 0x%08h)\n%s", "DceScbd-LkupRsp", m_dce_txnq[jdxq[0]].m_txn_id, m_dce_txnq[jdxq[0]].m_initcmdupd_req_pkt.type2cmdname(), m_dce_txnq[jdxq[0]].m_initcmdupd_req_pkt.smi_src_ncore_unit_id, addrMgrConst::get_cache_id_as_string(m_dce_txnq[jdxq[0]].m_initcmdupd_req_pkt.smi_src_ncore_unit_id), m_dce_txnq[jdxq[0]].m_initcmdupd_req_pkt.smi_targ_ncore_unit_id, m_dce_txnq[jdxq[0]].m_initcmdupd_req_pkt.smi_msg_id, m_dce_txnq[jdxq[0]].m_attid, m_dce_txnq[jdxq[0]].m_rbid, m_dm_lkprsp_pkt.m_addr, m_dm_lkprsp_pkt.m_attid, m_dm_lkprsp_pkt.m_attid_state.name(), m_dm_lkprsp_pkt.m_msg_id, m_dm_lkprsp_pkt.m_access_type.name(), m_dm_lkprsp_pkt.m_rtl_vbhit_sfvec, m_dm_lkprsp_pkt.m_sharer_vec, m_dm_lkprsp_pkt.m_owner_val, m_dm_lkprsp_pkt.m_owner_num, m_dm_lkprsp_pkt.m_way_vec_or_mask, m_dm_lkprsp_pkt.m_busy_vec, m_dm_lkprsp_pkt.m_wr_required, m_dm_lkprsp_pkt.m_alloc, m_dm_lkprsp_pkt.m_iid, m_dm_lkprsp_pkt.m_sid, commit_funit_id, sf_id, set_idx, m_dm_lkprsp_pkt.m_way, alloc_ways, m_dm_lkprsp_pkt.convert2string()), UVM_LOW);

        m_dce_txnq[jdxq[0]].m_states["dirrsp"].set_valid(m_dm_lkprsp_pkt.m_time);
        m_dce_txnq[jdxq[0]].save_dm_rsp_txn(m_dm_lkprsp_pkt);

        <%if (obj.testBench == "dce") {%>
        for(int sf_idx=0; sf_idx < addrMgrConst::NUM_SF; sf_idx++) begin
            way    = m_dirm_mgr.get_waynum(sf_idx, m_dm_lkprsp_pkt.m_way_vec_or_mask);
            tag_sf = m_dirm_mgr.get_tag_sf_handle(sf_idx);
            sharer_vec_mask = '0;
            foreach(addrMgrConst::funit2sf_slice[aiu_idx]) begin                
                if(addrMgrConst::get_cache_id(aiu_idx) >= 0) begin
                    sharer_vec_mask[addrMgrConst::get_cache_id(aiu_idx)] = (addrMgrConst::funit2sf_slice[aiu_idx] == sf_idx);
                end
            end
           `uvm_info(get_name(), $psprintf("[%-35s] (txnId: %5d) {%20s} (src: 0x%02h {%s}) (tgt: 0x%02h) (msgId: 0x%02h) (attid : 0x%02h) (rbid: 0x%02h) (addr: 0x%016h) (att: 0x%02h, %10s) (sfId: %2d) (wayNum: %2d) (sharerVecMask: 0x%08h)", "DceScbd-LkupRsp (Dbg)", m_dce_txnq[jdxq[0]].m_txn_id, m_dce_txnq[jdxq[0]].m_initcmdupd_req_pkt.type2cmdname(), m_dce_txnq[jdxq[0]].m_initcmdupd_req_pkt.smi_src_ncore_unit_id, addrMgrConst::get_cache_id_as_string(m_dce_txnq[jdxq[0]].m_initcmdupd_req_pkt.smi_src_ncore_unit_id), m_dce_txnq[jdxq[0]].m_initcmdupd_req_pkt.smi_targ_ncore_unit_id, m_dce_txnq[jdxq[0]].m_initcmdupd_req_pkt.smi_msg_id, m_dce_txnq[jdxq[0]].m_attid, m_dce_txnq[jdxq[0]].m_rbid, m_dm_lkprsp_pkt.m_addr, m_dm_lkprsp_pkt.m_attid, m_dm_lkprsp_pkt.m_attid_state.name(), sf_idx, way, sharer_vec_mask), UVM_LOW);

            // plru checks
            if(m_plru_en) begin
                if(m_dm_lkprsp_pkt.m_alloc == 1) begin
                    if((m_dm_lkprsp_pkt.m_sharer_vec & sharer_vec_mask) > 0) begin
                        if((m_dm_lkprsp_pkt.m_rtl_vbhit_sfvec[sf_idx] == 0) || (addrMgrConst::get_snoopfilter_id(commit_funit_id >> WSMINCOREPORTID) == sf_idx)) begin
                            if(m_disable_plru_check_conc13075[sf_idx] == 0) begin // CONC-13075: disabling the check after first mismatch due to victim buffer model issue
                                update_plru_state(.sfid     (sf_idx), 
                                                  .way      (way),
                                                  .addr     ({m_dm_lkprsp_pkt.m_ns, m_dm_lkprsp_pkt.m_addr}),
                                                  .signature("(Alloc)"));
                            end
                        end
                    end
                    else if(way >= 0) begin // CONC-12972: Disabling this plru state update as plru commits shall match wit hthe way vector
                        if(m_disable_plru_check_conc13075[sf_idx] == 0) begin // CONC-13075: disabling the check after first mismatch due to victim buffer model issue
                            alloc_plru_state(.sfid      (sf_idx), 
                                             .way       (way),
                                             .addr      ({m_dm_lkprsp_pkt.m_ns, m_dm_lkprsp_pkt.m_addr}),
                                             .busy_ways (busy_vec & ((1 << tag_sf.num_ways)-1)),
                                             .alloc_ways(alloc_ways & ((1 << tag_sf.num_ways)-1)),
                                             .signature("(Alloc)"));
                        end
                    end
                end
                else begin
                    if((m_dm_lkprsp_pkt.m_sharer_vec & sharer_vec_mask) > 0) begin
                        if(m_dm_lkprsp_pkt.m_rtl_vbhit_sfvec[sf_idx] == 0) begin
                            if(m_disable_plru_check_conc13075[sf_idx] == 0) begin // CONC-13075: disabling the check after first mismatch due to victim buffer model issue
                                update_plru_state(.sfid     (sf_idx), 
                                                  .way      (way),
                                                  .addr     ({m_dm_lkprsp_pkt.m_ns, m_dm_lkprsp_pkt.m_addr}),
                                                  .signature("(nonAlloc)"));
                            end
                        end
                    end
                end
            end
            busy_vec   = busy_vec   >> tag_sf.num_ways;
            alloc_ways = alloc_ways >> tag_sf.num_ways;

            // updating the vbhit busy vector
            if(m_dm_lkprsp_pkt.m_rtl_vbhit_sfvec[sf_idx] == 1) begin
                m_vbhit_way_busy[sf_idx][addrMgrConst::get_sf_set_index(sf_idx, {m_dm_lkprsp_pkt.m_ns, m_dm_lkprsp_pkt.m_addr})][way] = 1;
            end
        end
        <%}%>

        if (m_dm_lkprsp_pkt.m_sharer_vec != 0 ) begin
            num_dir_hit++;
            sb_stall_if.perf_count_events["SF_hit"].push_back(1);
        end else begin
            num_dir_miss++;
            sb_stall_if.perf_count_events["SF_miss"].push_back(1); 
        end
    end else begin
        `uvm_info("DCE SCB", $psprintf("IGNORE Received Dir Response @{ACT}: %s", m_dm_lkprsp_pkt.convert2string()), UVM_LOW);
        if(idxq.size()==1 && ((m_dm_cohreq_pktq[idxq[0]].m_attid_state==SLEEP)^m_dm_cohreq_pktq[idxq[0]].m_cancel))
            `uvm_error("DCE SCB", $psprintf("Dir Request for above Response has cancel :%0b and attid_state:%0s",m_dm_cohreq_pktq[idxq[0]].m_cancel,m_dm_cohreq_pktq[idxq[0]].m_attid_state));
    end
endfunction: process_dm_lkprsp

//**********************************************************************
function void dce_scb::process_dm_recrsp(uvm_phase phase);
    int rl_idxq[$], vl_idxq[$];
    tag_snoop_filter tag_sf;
    dm_seq_item exprec_pkt;
    int num_cacheing_agents, recreq_sfid;
    dce_scb_txn scb_txn;
    string rec_msg, s;
    tag_snoop_filter_t recall_entry;
    int idxq[$];
    bit matched = 0;
    int dmi_index = 0;
    int recall_qos;

    $sformat(rec_msg, "%s recreq_0x%0h", rec_msg, m_dm_recrsp_pkt.m_addr);
    
    //For CSR seq to check recall addr.
    csr_addr_overlap_recall_addr_q.push_back(m_dm_recrsp_pkt.m_addr);
    csr_test_time_out_recall_ev.trigger();

   `uvm_info("DCE SCB", $psprintf("Received Dir Recall Request : %0s", m_dm_recrsp_pkt.convert2string()), UVM_LOW)
    m_dirm_mgr.populate_vb_list();
    m_dirm_mgr.populate_recall_list();
    m_dirm_mgr.populate_tf_list({m_dm_recrsp_pkt.m_ns, m_dm_recrsp_pkt.m_addr});
   
    if ((m_dirm_mgr.recall_list.size() == 0) && (m_dirm_mgr.vb_list.size() == 0) && (m_dirm_mgr.tf_list.size() == 0)) begin
        `uvm_error("DCE SCB", $psprintf("recall list and vb list  and tf list empty Received Unexpected Dir Recall Response: %0s", m_dm_recrsp_pkt.convert2string()))
    end 

    rl_idxq = m_dirm_mgr.recall_list.find_index(item) with ((item.recall_entry.cacheline[WSMIADDR-1:0] == m_dm_recrsp_pkt.m_addr) && (item.recall_entry.cacheline[WSMIADDR] == m_dm_recrsp_pkt.m_ns));
    vl_idxq = m_dirm_mgr.vb_list.find_index(item) with ((item.recall_entry.cacheline[WSMIADDR-1:0] == m_dm_recrsp_pkt.m_addr) && (item.recall_entry.cacheline[WSMIADDR] == m_dm_recrsp_pkt.m_ns));
            
    if (rl_idxq.size() > 0) begin
        foreach(rl_idxq[k]) begin
            exprec_pkt = new("recrsp");
            exprec_pkt.m_access_type = DM_REC_REQ;
            exprec_pkt.m_addr        = m_dirm_mgr.recall_list[rl_idxq[k]].recall_entry.cacheline[WSMIADDR - 1 : 0];
            exprec_pkt.m_ns          = m_dirm_mgr.recall_list[rl_idxq[k]].recall_entry.cacheline[WSMIADDR];
            num_cacheing_agents      = 0;
            for(int i = 0; i < addrMgrConst::NUM_SF; i++) begin
                tag_sf = m_dirm_mgr.get_tag_sf_handle(i);
                if (m_dirm_mgr.recall_list[rl_idxq[k]].tag_filter_id != i) begin
                    num_cacheing_agents += tag_sf.get_num_cacheing_agents();
                end else begin
                    for(int j = 0; j < tag_sf.get_num_cacheing_agents(); j++) begin
                        if (m_dirm_mgr.recall_list[rl_idxq[k]].recall_entry.validity[j] == 1) begin
                            exprec_pkt.m_sharer_vec |= 1 << num_cacheing_agents;    
                        end 
                        if (m_dirm_mgr.recall_list[rl_idxq[k]].recall_entry.ownership[j] == 1) begin
                            exprec_pkt.m_owner_val = 1;     
                            exprec_pkt.m_owner_num = num_cacheing_agents;       
                        end 
                        num_cacheing_agents++;
                    end
                end
            end
            //`uvm_info("DCE SCB", $psprintf("recall_list_exprec_pkt: %0s", exprec_pkt.convert2string()), UVM_LOW)
            if (exprec_pkt.m_owner_val  == m_dm_recrsp_pkt.m_owner_val &&
                exprec_pkt.m_owner_num  == m_dm_recrsp_pkt.m_owner_num &&
                exprec_pkt.m_sharer_vec == m_dm_recrsp_pkt.m_sharer_vec) begin 
                matched = 1;
                //`uvm_info("DCE SCB", $psprintf("SF:%0d matched entry in recall_list", m_dirm_mgr.recall_list[rl_idxq[k]].tag_filter_id), UVM_LOW)
                recreq_sfid = m_dirm_mgr.recall_list[rl_idxq[k]].tag_filter_id;
                tag_sf      = m_dirm_mgr.get_tag_sf_handle(recreq_sfid);
                //#Check.DCE.dm_recall_addr_del_from_filter
                tag_sf.recall_entry.entry_status = ENTRY_INVALID;
                break;
            end
        end //loop through all entries in recall_list.
    end // if recall_list has address matching entries.
                
    if (matched == 0) begin //no entry in recall list matches REC_REQ
        if (vl_idxq.size() > 0) begin 
            foreach(vl_idxq[k]) begin
                exprec_pkt = new("recrsp");
                exprec_pkt.m_access_type = DM_REC_REQ;
                exprec_pkt.m_addr        = m_dirm_mgr.vb_list[vl_idxq[k]].recall_entry.cacheline[WSMIADDR - 1 : 0];
                exprec_pkt.m_ns          = m_dirm_mgr.vb_list[vl_idxq[k]].recall_entry.cacheline[WSMIADDR];
                num_cacheing_agents = 0;
                for(int i = 0; i < addrMgrConst::NUM_SF; i++) begin
                    tag_sf = m_dirm_mgr.get_tag_sf_handle(i);
                    if (m_dirm_mgr.vb_list[vl_idxq[k]].tag_filter_id != i) begin
                        num_cacheing_agents += tag_sf.get_num_cacheing_agents();
                    end else begin
                        for(int j = 0; j < tag_sf.get_num_cacheing_agents(); j++) begin
                            if (m_dirm_mgr.vb_list[vl_idxq[k]].recall_entry.validity[j] == 1) begin
                                exprec_pkt.m_sharer_vec |= 1 << num_cacheing_agents;    
                            end 
                            if (m_dirm_mgr.vb_list[vl_idxq[k]].recall_entry.ownership[j] == 1) begin
                                exprec_pkt.m_owner_val = 1;     
                                exprec_pkt.m_owner_num = num_cacheing_agents;       
                            end 
                            num_cacheing_agents++;
                        end
                    end
                end 
                //`uvm_info("DCE SCB", $psprintf("vblist_exprec_pkt: %0s",exprec_pkt.convert2string()), UVM_LOW)
                if (exprec_pkt.m_owner_val  == m_dm_recrsp_pkt.m_owner_val &&
                    exprec_pkt.m_owner_num  == m_dm_recrsp_pkt.m_owner_num &&
                    exprec_pkt.m_sharer_vec == m_dm_recrsp_pkt.m_sharer_vec) begin 
                    matched = 1;
                    //`uvm_info("DCE SCB", $psprintf("SF:%0d matched entry in vb_list", m_dirm_mgr.vb_list[vl_idxq[k]].tag_filter_id), UVM_LOW)
                    recreq_sfid = m_dirm_mgr.vb_list[vl_idxq[k]].tag_filter_id;
                    //#Check.DCE.dm_recall_addr_del_from_filter
                    m_dirm_mgr.delete_entry_in_vb(m_dirm_mgr.vb_list[vl_idxq[k]].recall_entry.cacheline, recreq_sfid); 
                    break;
                end 
            end // loop through all entries in vb_list -- since entry could be in multiple sf
        end  //if vb_list has address matching entries.
    end //if matched == 0

    if ((matched == 0) && (m_dirm_mgr.tf_list.size() > 0)) begin //with vb recovery enabled, the entry could also be in one of the filters.
        foreach(m_dirm_mgr.tf_list[k]) begin
            exprec_pkt = new("recrsp");
            exprec_pkt.m_access_type = DM_REC_REQ;
            exprec_pkt.m_addr        = m_dirm_mgr.tf_list[k].recall_entry.cacheline[WSMIADDR - 1 : 0];
            exprec_pkt.m_ns          = m_dirm_mgr.tf_list[k].recall_entry.cacheline[WSMIADDR];
            num_cacheing_agents = 0;
            for(int i = 0; i < addrMgrConst::NUM_SF; i++) begin
                tag_sf = m_dirm_mgr.get_tag_sf_handle(i);
                if (m_dirm_mgr.tf_list[k].tag_filter_id != i) begin
                    num_cacheing_agents += tag_sf.get_num_cacheing_agents();
                end else begin
                    for(int j = 0; j < tag_sf.get_num_cacheing_agents(); j++) begin
                        if (m_dirm_mgr.tf_list[k].recall_entry.validity[j] == 1) begin
                            exprec_pkt.m_sharer_vec |= 1 << num_cacheing_agents;    
                        end 
                        if (m_dirm_mgr.tf_list[k].recall_entry.ownership[j] == 1) begin
                            exprec_pkt.m_owner_val = 1;     
                            exprec_pkt.m_owner_num = num_cacheing_agents;       
                        end 
                        num_cacheing_agents++;
                    end
                end
            end 
            //`uvm_info("DCE SCB", $psprintf("tflist_exprec_pkt: %0s",exprec_pkt.convert2string()), UVM_LOW)
            if (exprec_pkt.m_owner_val  == m_dm_recrsp_pkt.m_owner_val &&
                exprec_pkt.m_owner_num  == m_dm_recrsp_pkt.m_owner_num &&
                exprec_pkt.m_sharer_vec == m_dm_recrsp_pkt.m_sharer_vec) begin 
                matched = 1;
                //`uvm_info("DCE SCB", $psprintf("SF:%0d matched entry in tf_list", m_dirm_mgr.tf_list[k].tag_filter_id), UVM_LOW)
                recreq_sfid = m_dirm_mgr.tf_list[k].tag_filter_id;
                //#Check.DCE.dm_recall_addr_del_from_filter
                m_dirm_mgr.delete_entry_in_tf(m_dirm_mgr.tf_list[k].recall_entry.cacheline, m_dirm_mgr.tf_list[k].tag_filter_id);
                break;
            end
        end //loop through all entries in tf list
    end //if matched ==0 
                
    //#Check.DCE.dm_recall_req_addr_ns
    //#Check.DCE.dm_recall_req_attributes
    //recall_req addr was not found in dm model, or the attributes did not match, so fire an error.
    if (matched == 0)
        `uvm_error("DCE SCB", $psprintf("Unexpected Dir Recall Request: %0s", m_dm_recrsp_pkt.convert2string()))

    if (($test$plusargs("k_csr_seq=dce_csr_address_region_overlap_seq") ||
         $test$plusargs("k_csr_seq=dce_csr_no_address_hit_seq")) && 
          (garbage_dmiid == 1)
       ) begin
        `uvm_info("DCE SCB", $psprintf("Exit early on REC_REQ due to garbage_dmiid"), UVM_LOW)
        return;
    end

    recall_qos = m_env_cfg.m_use_evict_qos ? m_env_cfg.m_evict_qos : ((addrMgrConst::get_highest_qos() != 0) ? 'hf : 'h0);
    <% if(obj.COVER_ON) { %>
    tag_sf = m_dirm_mgr.get_tag_sf_handle(recreq_sfid);
    tag_sf.obsrvd_recreq = 1;
    m_dirm_mgr.collect_dm_coverage();
    m_cov.collect_dirm_scenario(m_dirm_mgr);
    m_cov.collect_recall_qos(m_env_cfg.m_use_evict_qos, recall_qos);
    <% } %>

    scb_txn = new(rec_msg);
    scb_txn.snoop_enable_reg_txn = snoop_enable_reg_prev;
    scb_txn.save_recall_req(.recreq(m_dm_recrsp_pkt), .recall_qos(recall_qos)); // CONC-13159
    foreach(DMI_FUNIT_IDS[x]) begin
        if(DMI_FUNIT_IDS[x] == scb_txn.m_dmiid)
            dmi_index = x;
    end

  //SANJEEV: For CONC-14089: Fetching the DCE-DMI connectivity from Ncore config as SMI type provides random values. Ideally, either SMI type or NCore config should be updated with the relevant information to avoid changes to the DCE-TB. 
  <% if(obj.testBench=='dce')  { %> 
    if(DMI_CONNECTIVITY[dmi_index] == 0 && $test$plusargs("connectivity_test")) begin
    `uvm_info("DCE SCB", $psprintf("dmi_index = %d and scb_txn.m_dmiid = %d and DMI_CONNECTIVITY[dmi_index] = %d",dmi_index,scb_txn.m_dmiid,DMI_CONNECTIVITY[dmi_index]), UVM_LOW)
        if(csr_addr_connectivity_recall_addr == 0)
            csr_addr_connectivity_recall_addr = m_dm_recrsp_pkt.m_addr; 
        return;
    end
    <%} else { %>
    if((addrMgrConst::dce_dmi_connectivity_vec[<%=obj.Id%>][dmi_index] == 0) && $test$plusargs("connectivity_testing")) begin
    `uvm_info("DCE SCB", $psprintf("dmi_index = %d and scb_txn.m_dmiid = %d and addrMgrConst::dce_dmi_connectivity_vec[<%=obj.Id%>][dmi_index] = %d",dmi_index,scb_txn.m_dmiid,addrMgrConst::dce_dmi_connectivity_vec[<%=obj.Id%>][dmi_index]), UVM_LOW)
        if(csr_addr_connectivity_recall_addr == 0)
            csr_addr_connectivity_recall_addr = m_dm_recrsp_pkt.m_addr; 
        return;
    end
    <% } %>

    foreach(m_dce_txnq[x]) begin
        if(m_dce_txnq[x].m_req_type == REC_REQ) begin
            if((m_dce_txnq[x].m_dm_pktq[0].m_addr == scb_txn.m_dm_pktq[0].m_addr) && (m_dce_txnq[x].m_dm_pktq[0].m_ns == scb_txn.m_dm_pktq[0].m_ns)) begin
                `uvm_info("DCE_RECALL", $psprintf("Found multiple recalls with same address and matched with att entry = %d",m_dce_txnq[x].m_attid),UVM_LOW)
            end
        end
        if(m_dce_txnq[x].m_req_type == CMD_REQ) begin
            if(m_dce_txnq[x].m_attid_status inside {ATTID_IS_ACTIVE, ATTID_IS_WAKEUP} && m_dce_txnq[x].m_states["dirreq"].is_complete() && m_dce_txnq[x].m_states["dirrsp"].is_expect()) begin
                if((m_dce_txnq[x].m_initcmdupd_req_pkt.smi_addr >> addrMgrConst::WCACHE_OFFSET) == (scb_txn.m_dm_pktq[0].m_addr >> addrMgrConst::WCACHE_OFFSET) && (m_dce_txnq[x].m_initcmdupd_req_pkt.smi_ns == scb_txn.m_dm_pktq[0].m_ns)) begin
                    `uvm_error("DCE SCB",$psprintf("Recall hit active command request in att_id = %d",m_dce_txnq[x].m_attid))
                end
            end
        end
    end
    m_dce_txnq.push_back(scb_txn);
    sb_stall_if.perf_count_events["SF_recall"].push_back(1);
    phase.raise_objection(this, {rec_msg, " raise objection"});
    m_obj_tracker[m_dce_txnq[m_dce_txnq.size()-1].m_txn_id] = 0;

   `uvm_info(get_name(), $psprintf("[%-35s] (txnId: %5d) {%20s} (src: ----) (tgt: ----) (msgId: ----) (attid : 0x%02h) (rbid: ----) (addr: 0x%016h)\n", "DceScbd-TxnInitRec", m_dce_txnq[m_dce_txnq.size()-1].m_txn_id, m_dce_txnq[m_dce_txnq.size()-1].m_req_type.name(), m_dce_txnq[m_dce_txnq.size()-1].m_attid, m_dce_txnq[m_dce_txnq.size()-1].m_dm_pktq[0].m_addr), UVM_LOW);

    num_txns++;
    num_rec_reqs++;
    m_dce_txnq[m_dce_txnq.size()-1].m_attid = m_dm_recrsp_pkt.m_attid;
   `uvm_info(get_name(), $psprintf("[%-35s] (txnId: %5d) {%20s} (src: 0x%02h {%s}) (tgt: 0x%02h) (msgId: 0x%02h) (attid : 0x%02h) (rbid: 0x%02h) (addr: 0x%016h) (%10t, %10t)", "DceScbd-AttAlloc(Recall)", m_dce_txnq[m_dce_txnq.size()-1].m_txn_id, m_dce_txnq[m_dce_txnq.size()-1].m_initcmdupd_req_pkt.type2cmdname(), m_dce_txnq[m_dce_txnq.size()-1].m_initcmdupd_req_pkt.smi_src_ncore_unit_id, addrMgrConst::get_cache_id_as_string(m_dce_txnq[m_dce_txnq.size()-1].m_initcmdupd_req_pkt.smi_src_ncore_unit_id), m_dce_txnq[m_dce_txnq.size()-1].m_initcmdupd_req_pkt.smi_targ_ncore_unit_id, m_dce_txnq[m_dce_txnq.size()-1].m_initcmdupd_req_pkt.smi_msg_id, m_dce_txnq[m_dce_txnq.size()-1].m_attid, m_dce_txnq[m_dce_txnq.size()-1].m_rbid, m_dce_txnq[m_dce_txnq.size()-1].m_initcmdupd_req_pkt.smi_addr, m_dce_txnq[m_dce_txnq.size()-1].m_initcmdupd_req_pkt.t_smi_ndp_valid, m_dce_txnq[m_dce_txnq.size()-1].t_conc_mux_cmdreq), UVM_LOW);

    `uvm_info("DCE SCB",$psprintf("%0s is put into dce_txnq, current_qsize: %0d \nTXN:%0d %0s",scb_txn.get_name(), m_dce_txnq.size(),num_txns, scb_txn.print_txn(0)), UVM_LOW)

endfunction: process_dm_recrsp

//***********************************************************************
function void dce_scb::process_dm_rtyrsp();
    int idxq[$], jdxq[$];
    bit match = 0;
    
    if (garbage_dmiid)
        return;
    
    `uvm_info("DCE SCB", $psprintf("Received Dir Retry Response: %0s", m_dm_rtyrsp_pkt.convert2string()), UVM_LOW);
    
    idxq = m_dm_cohreq_pktq.find_index(item) with (item.m_attid == m_dm_rtyrsp_pkt.m_attid);
    if (idxq.size() == 1) begin
        //coh_req SLEEP --> WAKEUP --> RETRY--> WAKEUP --> RETRY
        //ACTIVE --> RETRY
        //SLEEP --> RETRY
        if (m_dm_cohreq_pktq[idxq[0]].m_attid_state inside {ACTIVE, SLEEP, WAKEUP}) begin 
            match = 1;
        end
        else begin
            `uvm_error("DCE_SCB", $psprintf("matching only one outstanding cohreq_pkt with attid_state:%s for RTY_RSP not expected",m_dm_cohreq_pktq[idxq[0]].m_attid_state));
        end 
    end else if (idxq.size() == 2) begin
        if ((m_dm_cohreq_pktq[idxq[0]].m_attid_state == SLEEP) && (m_dm_cohreq_pktq[idxq[1]].m_attid_state inside {SLEEP, WAKEUP})) begin //A wakeup=1 request is predicted with attid_state=SLEEP when there is a recall req collision CONC-5564
            match = 1;
        end else begin
            `uvm_error("DCE_SCB", $psprintf("matching two outstanding cohreq_pkts with attid_state_0:%s attid_state_1:%s for RTY_RSP not expected", m_dm_cohreq_pktq[idxq[0]].m_attid_state.name, m_dm_cohreq_pktq[idxq[1]].m_attid_state.name));
        end 
    end else if (idxq.size() == 3) begin
        if ((m_dm_cohreq_pktq[idxq[0]].m_attid_state == SLEEP) && (m_dm_cohreq_pktq[idxq[1]].m_attid_state == SLEEP) && (m_dm_cohreq_pktq[idxq[2]].m_attid_state inside {WAKEUP,SLEEP})) begin 
            //1st SLEEP due to collison with an earlier request, 2nd SLEEP due to collision with a RECALL, and then 3rd WAKEUP but it got retried due to "lets say all ways full"
            match = 1;
        end else begin
            `uvm_error("DCE_SCB", $psprintf("matching three outstanding cohreq_pkts with attid_state_0:%s attid_state_1:%s attid_state_2:%s for RTY_RSP not expected", m_dm_cohreq_pktq[idxq[0]].m_attid_state.name, m_dm_cohreq_pktq[idxq[1]].m_attid_state.name, m_dm_cohreq_pktq[idxq[2]].m_attid_state.name));
        end 
    end else if (idxq.size() == 4) begin
            if ((m_dm_cohreq_pktq[idxq[0]].m_attid_state == SLEEP) && (m_dm_cohreq_pktq[idxq[1]].m_attid_state == SLEEP) && (m_dm_cohreq_pktq[idxq[2]].m_attid_state == SLEEP) && (m_dm_cohreq_pktq[idxq[3]].m_attid_state == WAKEUP)) 
        match = 1;
        else
            `uvm_error("DCE_SCB", $psprintf("For RTY_RSP pkt matching dm_cohreq_pktq.size: %0d Wake up is expected ", idxq.size));
    end else if (idxq.size() > 4) begin //Adding below code because of allowing multiple Recalls
            //`uvm_error("DCE_SCB", $psprintf("For RTY_RSP pkt matching dm_cohreq_pktq.size: %0d is not expected ", idxq.size));
        if(m_dm_cohreq_pktq[idxq[idxq.size() - 1]].m_attid_state == WAKEUP)
                match = 1;
        else
            `uvm_error("DCE_SCB", $psprintf("For RTY_RSP pkt matching dm_cohreq_pktq.size: %0d Wake up is expected ", idxq.size));
    end else
        `uvm_error("DCE_SCB", $psprintf("No matching coherent request for the retry and matchq.size = %0d",idxq.size));
        

    if (match == 1) begin
        jdxq = m_dce_txnq.find_index(item) with (
                    item.m_initcmdupd_req_pkt.isCmdMsg() &&
                    item.m_attid        == m_dm_rtyrsp_pkt.m_attid  &&
                    (item.m_attid_status inside {ATTID_IS_ACTIVE, ATTID_IS_WAKEUP, ATTID_IS_SLEEP})  &&
                    !item.m_states["dirreq"].is_complete() 
                    );
        
        dirm_pktmatch_checks(jdxq, m_dm_rtyrsp_pkt, "DM RTY_RSP");
        
        //check_coh_req
        if (idxq.size() == 1) begin
            m_dce_txnq[jdxq[0]].m_states["dirreq"].set_valid(m_dm_cohreq_pktq[idxq[0]].m_time);
            m_dce_txnq[jdxq[0]].check_dm_req_txn(m_dm_cohreq_pktq[idxq[0]]);
            m_dm_cohreq_pktq.delete(idxq[0]);
        end else if (idxq.size() == 2) begin
            m_dce_txnq[jdxq[0]].m_states["dirreq"].set_valid(m_dm_cohreq_pktq[idxq[1]].m_time);
            m_dce_txnq[jdxq[0]].check_dm_req_txn(m_dm_cohreq_pktq[idxq[1]]);
            m_dm_cohreq_pktq.delete(idxq[1]);
            m_dm_cohreq_pktq.delete(idxq[0]);
        end else if (idxq.size() == 3) begin
            m_dce_txnq[jdxq[0]].m_states["dirreq"].set_valid(m_dm_cohreq_pktq[idxq[2]].m_time);
            m_dce_txnq[jdxq[0]].check_dm_req_txn(m_dm_cohreq_pktq[idxq[2]]);
            m_dm_cohreq_pktq.delete(idxq[2]);
            m_dm_cohreq_pktq.delete(idxq[1]);
            m_dm_cohreq_pktq.delete(idxq[0]);
        end else if (idxq.size() == 4) begin
            m_dce_txnq[jdxq[0]].m_states["dirreq"].set_valid(m_dm_cohreq_pktq[idxq[3]].m_time);
            m_dce_txnq[jdxq[0]].check_dm_req_txn(m_dm_cohreq_pktq[idxq[3]]);
            m_dm_cohreq_pktq.delete(idxq[3]);
            m_dm_cohreq_pktq.delete(idxq[2]);
            m_dm_cohreq_pktq.delete(idxq[1]);
            m_dm_cohreq_pktq.delete(idxq[0]);
        end else if (idxq.size() > 4) begin
            m_dce_txnq[jdxq[0]].m_states["dirreq"].set_valid(m_dm_cohreq_pktq[idxq[idxq.size() - 1]].m_time);
            m_dce_txnq[jdxq[0]].check_dm_req_txn(m_dm_cohreq_pktq[idxq[idxq.size() - 1]]);
        for(int i = (idxq.size() - 1); i == 0; i--) begin
            `uvm_info("DCE SCB", $psprintf(" Inside idxq > 4 and i = %d and indxq size = %d",i,idxq.size()),UVM_LOW);
                m_dm_cohreq_pktq.delete(idxq[i]);
        end
    end
        
        m_dce_txnq[jdxq[0]].m_states["dirrsp"].set_valid(m_dm_rtyrsp_pkt.m_time);
        m_dce_txnq[jdxq[0]].save_dm_rsp_txn(m_dm_rtyrsp_pkt);

    end else begin
        //#Check.DCE.dm_rtyreq_attid_match
        `uvm_error("DCE SCB", $psprintf("Received Dir Retry Response does not match any outstanding Dir Coh Req pkts @{ACT}: %s", m_dm_lkprsp_pkt.convert2string()));
    end
endfunction: process_dm_rtyrsp

//***********************************************************************
function void dce_scb::process_smi_sys_event_req();
    if(event_disable == 0) begin
        if(m_dce_sys_txnq.size() != 0) begin
            m_dce_sys_txnq[0].snoop_enable_reg_txn = snoop_enable_reg;
            m_dce_sys_txnq[0].check_sys_event_req(m_smi_rx_sysreq_pkt);
            m_dce_sys_txnq[0].sys_event_cov_txn.sysreq_event = 1'b1;
            m_dce_sys_txnq[0].sys_event_cov_txn.sysreq_event_opcode = m_smi_rx_sysreq_pkt.smi_sysreq_op;
            event_count[m_smi_rx_sysreq_pkt.smi_targ_ncore_unit_id] = 1;
        end
        else
           `uvm_error("DCE SCB", $psprintf("SysReq.Event was not predicted"));
        end
    else
       `uvm_error("DCE SCB", $psprintf("Event Sender is disabled, Event sender should not send sysreq.event"));
endfunction: process_smi_sys_event_req

//***********************************************************************
function void dce_scb::process_smi_sys_event_rsp();

    if ($test$plusargs("wrong_sysrsp_target_id")) begin
        if (m_smi_tx_sysrsp_pkt.smi_targ_ncore_unit_id !== addrMgrConst::get_dce_funitid(0)) begin
            `uvm_info("WRONG_TGT_ID", $sformatf("Since request is dropped by DCE block, no need to save the txn - return early"), UVM_LOW)
            return; 
        end
    end

    if(event_disable == 0) begin
        if(m_smi_tx_sysrsp_pkt.smi_cmstatus == 8'b0100_0000) begin
              check_sys_rsp_timeout(1);
        end

        if($test$plusargs("en_dce_ev_protocol_timeout")) begin
            if(m_dce_sys_txnq.size() == 0)
                return;
        end  

        m_dce_sys_txnq[0].process_sys_event_rsp(m_smi_tx_sysrsp_pkt);
        event_count[m_smi_tx_sysrsp_pkt.smi_src_ncore_unit_id] = 0;
        m_dce_sys_txnq[0].sys_event_cov_txn.sysrsp_event = 1'b1;
        m_dce_sys_txnq[0].sys_event_cov_txn.cm_status = m_smi_tx_sysrsp_pkt.smi_cmstatus;
        <% if(obj.COVER_ON) { %>
        m_cov.collect_sys_event_cov(m_dce_sys_txnq[0]);
        <% } %>
        end 
    else
       `uvm_error("DCE SCB", $psprintf("Event Sender is disabled, Event sender should not recieve sysrsp because sysreq was not sent"));
endfunction: process_smi_sys_event_rsp

//***********************************************************************
function void dce_scb::check_sys_rsp_timeout(bit err_info);
    <% if (obj.testBench != "cust_tb") {%>
    if(u_csr_probe_vif.uedr_timeout_err_det_en) begin
        if(u_csr_probe_vif.uesr_err_type == 'hA && u_csr_probe_vif.uesr_errvld == 1'b1 && u_csr_probe_vif.uesr_err_info == err_info) begin
            if(u_csr_probe_vif.ueir_timeout_irq_en) begin
                if(!u_csr_probe_vif.IRQ_UC) begin
                    `uvm_error("<%=obj.BlockId%>_scb_error", $psprintf("Expected IRQ_UC to be set"))
                end
            end 
            else begin
                if(u_csr_probe_vif.IRQ_UC) begin
                    `uvm_error("<%=obj.BlockId%>_scb_error", $psprintf("Interrupt Triggered when interrupt is disabled"))
                end
            end
        end 
        else begin
        `uvm_error("<%=obj.BlockId%>_scb_error", $psprintf("Right Error values are not set after triggering a timeout Err Type : %0h, Err valid : %0b, Err Info : %0b", u_csr_probe_vif.uesr_err_type, u_csr_probe_vif.uesr_errvld, u_csr_probe_vif.uesr_err_info))
        end
    end 
    else begin
        if(u_csr_probe_vif.uesr_err_type == 'hA && u_csr_probe_vif.uesr_errvld == 1'b1 && u_csr_probe_vif.uesr_err_info == err_info) begin
            `uvm_error("<%=obj.BlockId%>_scb_error", $psprintf("Error valid set when error is not enabled"))
        end
    end
    m_dce_sys_txnq[0].sys_event_cov_txn.timeout_err_det_en = u_csr_probe_vif.uedr_timeout_err_det_en;
    m_dce_sys_txnq[0].sys_event_cov_txn.timeout_err_int_en = u_csr_probe_vif.ueir_timeout_irq_en;
    m_dce_sys_txnq[0].sys_event_cov_txn.uesr_err_type = u_csr_probe_vif.uesr_err_type;
    m_dce_sys_txnq[0].sys_event_cov_txn.err_valid = u_csr_probe_vif.uesr_errvld;
    m_dce_sys_txnq[0].sys_event_cov_txn.irq_uc = u_csr_probe_vif.IRQ_UC;
    m_dce_sys_txnq[0].sys_event_cov_txn.timeout_threshold = u_csr_probe_vif.timeout_threshold;
    <% } %>

<% if(obj.COVER_ON) { %>
    m_cov.collect_sys_event_cov(m_dce_sys_txnq[0]);
<% } %>
    m_dce_sys_txnq.delete(0);

endfunction: check_sys_rsp_timeout

//***********************************************************************

function void dce_scb::process_smi_sys_co_req();
    int dce_funitidsq[$];
    int aiu_funitidsq[$];
    dce_scb_txn scb_txn;
    int sys_reqsq[$];

    aiu_funitidsq.delete();
    foreach(addrMgrConst::aiu_ids[i]) begin 
        aiu_funitidsq.push_back(addrMgrConst::funit_ids[addrMgrConst::aiu_ids[i]]);
    end
    
    dce_funitidsq.delete();
    foreach(addrMgrConst::dce_ids[i]) begin 
        dce_funitidsq.push_back(addrMgrConst::funit_ids[addrMgrConst::dce_ids[i]]);
    end

    if ($test$plusargs("wrong_sysreq_target_id")) begin
            if (m_smi_tx_sysreq_pkt.smi_targ_ncore_unit_id !== addrMgrConst::get_dce_funitid(0)) begin
                smi_msg_id_sys_req_tgt_id_err[m_smi_tx_sysreq_pkt.smi_msg_id] = m_smi_tx_sysreq_pkt.smi_msg_id;
                `uvm_info("WRONG_TGT_ID", $sformatf("Since request is dropped by DCE block, no need to save the txn - return early"), UVM_LOW)
                return; 
            end
     end

    
    if (((m_smi_tx_sysreq_pkt.smi_src_id >> WSMINCOREPORTID) inside {aiu_funitidsq}) == 0 && addrMgrConst::get_cache_id(m_smi_tx_sysreq_pkt.smi_src_id) < 0)
        `uvm_error("DCE_WRONG_SRC_ID", $sformatf(" SysReq src id does not match any of the coherent AIU FUnit Ids"))

    if (((m_smi_tx_sysreq_pkt.smi_targ_id >> WSMINCOREPORTID) inside {dce_funitidsq}) == 0)
        `uvm_error("DCE_WRONG_TGT_ID", $sformatf(" SysReq target id does not match any of the DCE FUnit Ids"))

    scb_txn = new("sysco_req");
        m_smi_tx_sysreq_pkt.t_smi_ndp_valid = $time;
        scb_txn.save_sys_co_req(m_smi_tx_sysreq_pkt);
    `uvm_info("DCE_SCB", $psprintf("%s", scb_txn.print_txn(0)), UVM_LOW);
    

    if(m_smi_tx_sysreq_pkt.smi_sysreq_op == 1) begin // attach
        num_sysreq_attach++;
    end
    else if(m_smi_tx_sysreq_pkt.smi_sysreq_op == 2) begin // detach
        num_sysreq_detach++;
        
        foreach(m_dce_txnq[i]) begin
            if(m_dce_txnq[i].m_initcmdupd_req_pkt.smi_src_ncore_unit_id == m_smi_tx_sysreq_pkt.smi_src_ncore_unit_id && m_dce_txnq[i].m_attid_status != ATTID_IS_RELEASED && m_dce_txnq[i].m_req_type inside {CMD_REQ, UPD_REQ})
            begin
                if(!m_dce_txnq[i].m_states["strrsp"].is_complete()) begin
                    `uvm_error("DCE SCB", $psprintf("There are pending transactions for agent which sent a Detach %s",m_dce_txnq[i].print_txn(1)));
                end
            end
        end             
        
        if(snoop_enable_reg[m_smi_tx_sysreq_pkt.smi_src_ncore_unit_id] == 1'b1) begin
        //  snoop_enable_reg[m_smi_tx_sysreq_pkt.smi_src_ncore_unit_id] = 1'b0; // Need to check    
        end
        else
            `uvm_error("DCE SCB", $psprintf("The agent %d was never attached", m_smi_tx_sysreq_pkt.smi_src_ncore_unit_id));
    end
    else
            `uvm_error("DCE SCB", $psprintf("Invalid sysreq_op : %d",m_smi_tx_sysreq_pkt.smi_sysreq_op));

    sys_reqsq = m_dce_txnq.find_index(item) with (item.m_req_type == SYSCO_REQ && !item.m_states["sb_sysrsp"].is_complete());
    if(sys_reqsq.size() >= 1) begin
        scb_txn.t_sysreq_process = 0;
    end else begin
        scb_txn.t_sysreq_process = $time;
    end
    
    m_dce_txnq.push_back(scb_txn);
   `uvm_info(get_name(), $psprintf("[%-35s] (txnId: %5d) {%20s} (src: 0x%02h {%s}) (tgt: 0x%02h) (msgId: 0x%02h) (attid : 0x%02h) (rbid: 0x%02h) (addr: 0x%016h) (%10t, %10t)", "DceScbd-TxnInitSysReq", m_dce_txnq[m_dce_txnq.size()-1].m_txn_id, m_dce_txnq[m_dce_txnq.size()-1].m_initcmdupd_req_pkt.type2cmdname(), m_dce_txnq[m_dce_txnq.size()-1].m_initcmdupd_req_pkt.smi_src_ncore_unit_id, addrMgrConst::get_cache_id_as_string(m_dce_txnq[m_dce_txnq.size()-1].m_initcmdupd_req_pkt.smi_src_ncore_unit_id), m_dce_txnq[m_dce_txnq.size()-1].m_initcmdupd_req_pkt.smi_targ_ncore_unit_id, m_dce_txnq[m_dce_txnq.size()-1].m_initcmdupd_req_pkt.smi_msg_id, m_dce_txnq[m_dce_txnq.size()-1].m_attid, m_dce_txnq[m_dce_txnq.size()-1].m_rbid, m_dce_txnq[m_dce_txnq.size()-1].m_initcmdupd_req_pkt.smi_addr, m_dce_txnq[m_dce_txnq.size()-1].m_initcmdupd_req_pkt.t_smi_ndp_valid, m_dce_txnq[m_dce_txnq.size()-1].t_conc_mux_cmdreq), UVM_LOW);

    // YR: Checking for the below sequence is a patch fix and that is the best
    //     that can be done with the state of this environment
    if($test$plusargs("directed_attach_detach_seq")) begin
        if(first_cmd_observed == 0) begin
            first_cmd_observed = 1;
            ev_first_scb_txn.trigger();
        end
    end
endfunction: process_smi_sys_co_req

//***********************************************************************
function void dce_scb::process_smi_sys_co_rsp();
    int idxq[$];
    int sys_reqsq[$];
    
    if ($test$plusargs("wrong_sysreq_target_id")) begin
            if (m_smi_rx_sysrsp_pkt.smi_rmsg_id inside {smi_msg_id_sys_req_tgt_id_err}) begin
                `uvm_error(get_full_name(),$sformatf("DCE not dropping SYSREQ for target error with sysreq_smi_msg_id = %0h",m_smi_rx_sysrsp_pkt.smi_rmsg_id))
                smi_msg_id_sys_req_tgt_id_err.delete(m_smi_rx_sysrsp_pkt.smi_rmsg_id);
            end
        end

    idxq = m_dce_txnq.find_first_index(item) with (
          item.m_initsys_co_req_pkt.smi_src_ncore_unit_id == m_smi_rx_sysrsp_pkt.smi_targ_ncore_unit_id &&
         !item.m_states["sysrsp"].is_complete() );
    m_dce_txnq[idxq[0]].m_states["sysrsp"].set_valid($time);    
    m_dce_txnq[idxq[0]].check_sys_co_rsp(m_smi_rx_sysrsp_pkt);
    `uvm_info("DCE_SCB", $psprintf("DCE_UID:%0d: SYS_RESP: %s", m_dce_txnq[idxq[0]].m_txn_id, m_smi_rx_sysrsp_pkt.convert2string()), UVM_LOW);

 <% if(obj.COVER_ON) { %>
    m_cov.collect_dce_scb_txn(m_dce_txnq[idxq[0]]);
 <% } %>

    if(m_dce_txnq[idxq[0]].m_states["sb_sysrsp"].is_complete) begin
        m_dce_txnq.delete(idxq[0]);
    end
endfunction: process_smi_sys_co_rsp

//***********************************************************************


/////////////////////////////////////////////////////////////////////
// Section4: Utility Functions
//
////////////////////////////////////////////////////////////////////

//***********************************************************
function bit dce_scb::check_for_attid_deallocation(int txn_idx, bit verbose=0);
    bit complete  = 1;
    string status = "{pending:";
 
    foreach(m_dce_txnq[txn_idx].m_states[idx]) begin
        // YRAMASAMY: Improved RBID update
        // ATT shall get deallocated without waiting for RBRsp as RSRsp has RBID in it
        // ATT might get deallocated before RBReq gets sent due to jammed up ConcMux! However,
        // this will not cause false pass as the m_dce_Txnq will not get removed until an expected
        // RBReq/RBRsp has come back!
        if (!(m_dce_txnq[txn_idx].m_states[idx].get_name() inside {"cmdupdrsp", "rbureq", "rbursp", "rbrreq", "rbrrsp"})) begin
            complete &= m_dce_txnq[txn_idx].m_states[idx].is_complete();
            status    = m_dce_txnq[txn_idx].m_states[idx].is_complete() ? status : $psprintf("%s  - %10s    -", status, idx);
        end
    end
    status = $psprintf("%s  }", status);

    if(verbose == 1) begin
        if(complete) begin
           `uvm_info(get_name(), $psprintf("[%-35s] (txnId: %5d) {%20s} (src: 0x%02h {%s}) (tgt: 0x%02h) (msgId: 0x%02h) (attid : 0x%02h) (rbid: 0x%02h) (addr: 0x%016h) (%10t, %10t) { status:  - %-13s -  }", "DceScbd-ChkAttDealloc", m_dce_txnq[txn_idx].m_txn_id, m_dce_txnq[txn_idx].m_initcmdupd_req_pkt.type2cmdname(), m_dce_txnq[txn_idx].m_initcmdupd_req_pkt.smi_src_ncore_unit_id, addrMgrConst::get_cache_id_as_string(m_dce_txnq[txn_idx].m_initcmdupd_req_pkt.smi_src_ncore_unit_id), m_dce_txnq[txn_idx].m_initcmdupd_req_pkt.smi_targ_ncore_unit_id, m_dce_txnq[txn_idx].m_initcmdupd_req_pkt.smi_msg_id, m_dce_txnq[txn_idx].m_attid, m_dce_txnq[txn_idx].m_rbid, m_dce_txnq[txn_idx].m_initcmdupd_req_pkt.smi_addr, m_dce_txnq[txn_idx].m_initcmdupd_req_pkt.t_smi_ndp_valid, m_dce_txnq[txn_idx].t_conc_mux_cmdreq, "allDone"), UVM_LOW);
        end
        else begin
           `uvm_info(get_name(), $psprintf("[%-35s] (txnId: %5d) {%20s} (src: 0x%02h {%s}) (tgt: 0x%02h) (msgId: 0x%02h) (attid : 0x%02h) (rbid: 0x%02h) (addr: 0x%016h) (%10t, %10t) %s", "DceScbd-ChkAttDealloc", m_dce_txnq[txn_idx].m_txn_id, m_dce_txnq[txn_idx].m_initcmdupd_req_pkt.type2cmdname(), m_dce_txnq[txn_idx].m_initcmdupd_req_pkt.smi_src_ncore_unit_id, addrMgrConst::get_cache_id_as_string(m_dce_txnq[txn_idx].m_initcmdupd_req_pkt.smi_src_ncore_unit_id), m_dce_txnq[txn_idx].m_initcmdupd_req_pkt.smi_targ_ncore_unit_id, m_dce_txnq[txn_idx].m_initcmdupd_req_pkt.smi_msg_id, m_dce_txnq[txn_idx].m_attid, m_dce_txnq[txn_idx].m_rbid, m_dce_txnq[txn_idx].m_initcmdupd_req_pkt.smi_addr, m_dce_txnq[txn_idx].m_initcmdupd_req_pkt.t_smi_ndp_valid, m_dce_txnq[txn_idx].t_conc_mux_cmdreq, status), UVM_LOW);
        end
    end

    return complete;
endfunction: check_for_attid_deallocation

//***********************************************************
function bit dce_scb::check_for_completion(int txn_idx, bit verbose=0);
    // YRAMASAMY  : 3.6 change (not sure how it passed in 3.4!)
    //              Reason for this change being to ensure RTL deallocation
    //              is observed. Else when RTL deallocation happens, scoreboard
    //              wont have a copy and hence a error is flagged!
    // CONC-12430 : Accommodating the target id erros during which the scbd
    //              needs to drop the objection as RTL shall assume it is a
    //              unrecoverable error
    bit    complete = m_dce_txnq[txn_idx].rtl_deallocated     |
                      clean_exit_due_to_wrong_targetid_RBrsp  |
                      clean_exit_due_to_wrong_targetid_SNPrsp |
                      clean_exit_due_to_wrong_targetid_MRDrsp |
                      clean_exit_due_to_wrong_targetid_STRrsp ;
    string status   = "{pending:";
 
    foreach(m_dce_txnq[txn_idx].m_states[idx]) begin
        // YRAMASAMY
        // CONC-12275
        // reason for adding a state variable m_internal_rbr_release is to ensure the fsys bench doesnt hang when rbr-req doesnt
        // see a rbr-rsp, which can happen when there is an internal release. Doing this makes this scbd drop the objection and not
        // wait for rbr-rsp
        complete &= (idx == "rbrrsp") ? 
                    (m_dce_txnq[txn_idx].m_states[idx].is_complete() | m_dce_txnq[txn_idx].m_internal_rbr_release) : 
                    m_dce_txnq[txn_idx].m_states[idx].is_complete();

        if((idx == "rbrrsp") && !(m_dce_txnq[txn_idx].m_states[idx].is_complete() | m_dce_txnq[txn_idx].m_internal_rbr_release)) begin
            status = $psprintf("%s  - %10s(%1d) -", status, idx, m_dce_txnq[txn_idx].m_internal_rbr_release);
        end
        else if((idx != "rbrrsp") && !m_dce_txnq[txn_idx].m_states[idx].is_complete()) begin
            status = $psprintf("%s  - %10s    -", status, idx);
        end
    end
    status = $psprintf("%s  }", status);

    if(verbose == 1) begin
        if(complete) begin
           `uvm_info(get_name(), $psprintf("[%-35s] (txnId: %5d) {%20s} (src: 0x%02h {%s}) (tgt: 0x%02h) (msgId: 0x%02h) (attid : 0x%02h) (rbid: 0x%02h) (addr: 0x%016h) (%10t, %10t) { status:  - %-13s -  }", "DceScbd-ChkCompletion", m_dce_txnq[txn_idx].m_txn_id, m_dce_txnq[txn_idx].m_initcmdupd_req_pkt.type2cmdname(), m_dce_txnq[txn_idx].m_initcmdupd_req_pkt.smi_src_ncore_unit_id, addrMgrConst::get_cache_id_as_string(m_dce_txnq[txn_idx].m_initcmdupd_req_pkt.smi_src_ncore_unit_id), m_dce_txnq[txn_idx].m_initcmdupd_req_pkt.smi_targ_ncore_unit_id, m_dce_txnq[txn_idx].m_initcmdupd_req_pkt.smi_msg_id, m_dce_txnq[txn_idx].m_attid, m_dce_txnq[txn_idx].m_rbid, m_dce_txnq[txn_idx].m_initcmdupd_req_pkt.smi_addr, m_dce_txnq[txn_idx].m_initcmdupd_req_pkt.t_smi_ndp_valid, m_dce_txnq[txn_idx].t_conc_mux_cmdreq, "allDone"), UVM_HIGH);
        end
        else begin
           `uvm_info(get_name(), $psprintf("[%-35s] (txnId: %5d) {%20s} (src: 0x%02h {%s}) (tgt: 0x%02h) (msgId: 0x%02h) (attid : 0x%02h) (rbid: 0x%02h) (addr: 0x%016h) (%10t, %10t) %s", "DceScbd-ChkCompletion", m_dce_txnq[txn_idx].m_txn_id, m_dce_txnq[txn_idx].m_initcmdupd_req_pkt.type2cmdname(), m_dce_txnq[txn_idx].m_initcmdupd_req_pkt.smi_src_ncore_unit_id, addrMgrConst::get_cache_id_as_string(m_dce_txnq[txn_idx].m_initcmdupd_req_pkt.smi_src_ncore_unit_id), m_dce_txnq[txn_idx].m_initcmdupd_req_pkt.smi_targ_ncore_unit_id, m_dce_txnq[txn_idx].m_initcmdupd_req_pkt.smi_msg_id, m_dce_txnq[txn_idx].m_attid, m_dce_txnq[txn_idx].m_rbid, m_dce_txnq[txn_idx].m_initcmdupd_req_pkt.smi_addr, m_dce_txnq[txn_idx].m_initcmdupd_req_pkt.t_smi_ndp_valid, m_dce_txnq[txn_idx].t_conc_mux_cmdreq, status), UVM_HIGH);
        end
    end

    return complete;
endfunction: check_for_completion

//***********************************************************
function void dce_scb::latch_dirm_lkp_req_rsp(dm_seq_item req, dm_seq_item rsp);
    int idxq[$];

endfunction: latch_dirm_lkp_req_rsp

//******************************************************
function void dce_scb::dirm_pktmatch_checks(
    inout int idxq[$],
    inout dm_seq_item seq_item,
    input string act_pkt_type);

    string s;
    if((idxq.size() == 0)) begin
        `uvm_error("DCE SCB", $psprintf("@{ACT}: Received unexpected %s pkt: %s", act_pkt_type, seq_item.convert2string()));
    end else if(idxq.size() > 1) begin

        $sformat(s, "%s @{ACT}: For actual %s pkt multiple pkt matches are observed: %s\n",
            s, act_pkt_type, seq_item.convert2string());
        $sformat(s, "%s @{EXP}: Multiple pkts are:\n", s);
        foreach(idxq[idx]) begin
            $sformat(s, "%s req_pkt%0d: %s", s, idx,m_dce_txnq[idxq[idx]].print_txn(0));
        end
        `uvm_info("DCE SCB", s, UVM_LOW)
        `uvm_error("DCE SCB", $psprintf("Multiple {EXP} matches observed for {ACT} %s pkt", act_pkt_type))
    end

endfunction: dirm_pktmatch_checks

//**********************************************
function void dce_scb::smi_pktmatch_checks(
    ref int             idxq[$],
    inout smi_seq_item  seq_item,
    input string        act_pkt_type);

    string s;
    if(idxq.size() == 0) begin
        `uvm_error("DCE SCB", $psprintf("@{ACT}: Received unexpected %s pkt: %s", act_pkt_type, seq_item.convert2string()));
    end else if (act_pkt_type == "SMI RBU Rsp" && idxq.size() == 2) begin
        //It is possible that two requests(attids) with same RBID and DMIID are waiting to issue RBUreq. Just match with the 1st arriving RBUreq.
        if (m_dce_txnq[idxq[1]].m_states["rbureq"].m_time_seenq[0] < m_dce_txnq[idxq[0]].m_states["rbureq"].m_time_seenq[0])
            idxq[0] = idxq[1];
    end else if(idxq.size() > 1) begin
        $sformat(s, "%s @{ACT}: For actual %s pkt multiple dce_scb_txnq pkt matches are observed: %s\n",
            s, act_pkt_type, seq_item.convert2string());
        $sformat(s, "%s @{EXP}: Multiple dce_scb_txnq pkts are:\n", s);
        foreach(idxq[idx]) begin
            $sformat(s, "%s req_pkt%0d: %s", s, idx, m_dce_txnq[idxq[idx]].print_txn(0));
        end
        `uvm_info("DCE SCB", s, UVM_LOW)
        `uvm_error("DCE SCB", $psprintf("Multiple {EXP} matches observed for {ACT} %s pkt", act_pkt_type))
    end
endfunction: smi_pktmatch_checks

//********************************************
function bit dce_scb::print_pend_txns();
    int         open_obj = 0;
    bit         q_non_empty;
    string      s = "";
    dce_scb_txn non_int_rel_txns[$];
  
    foreach(m_obj_tracker[i]) begin
        if(m_obj_tracker[i] == 0) begin
            if(m_obj_tracker[i] == 0) begin
                open_obj++;
               `uvm_info(get_name(), $psprintf("[%-35s] open objection observed for txn_id [%4d]", "DceScbd-ObjTracker", i), UVM_NONE);
            end
        end
    end
   `uvm_info(get_name(), $psprintf("[%-35s] total opn objection noticed: [%4d]", "DceScbd-ObjTracker", open_obj), UVM_NONE);

    // YRAMASAMY
    // CONC-12275
    // Now that the check_for_completion accommodates m_internal_rbr_release in evaluating
    // completion and there by dropping objection, we are ignoring such txns from being
    // technically pending as from a system point of view, they may not get rbr-rsp
    non_int_rel_txns = m_dce_txnq.find(item) with (
                       ((item.m_internal_rbr_release == 0) && (!item.m_states["rbrrsp"].is_complete())) ||
                       (item.m_objection_dropped == 0));

    if(non_int_rel_txns.size() == 0) begin
        $sformat(s, "%s\nNo pending transactions in dce scoreboard \n", s);
        q_non_empty = 0;
    end else begin
        $sformat(s, "%s \n %0d Pending Transactions in dce scoreboard\n", s, non_int_rel_txns.size());
        $sformat(s, "%s \n BEGIN ===================================================================== BEGIN \n", s);
        foreach(non_int_rel_txns[idx]) begin
            $sformat(s, "%0s %0d: %s", s, idx, non_int_rel_txns[idx].print_txn(1));
        end
        $sformat(s, "%s \n END ===================================================================== END \n", s);

        $sformat(s, "%s\n basic_mon:%p", s, m_basic_mon);
        foreach(m_tagged_mon[idx]) begin
            $sformat(s, "%s\n mon_idx:%0d mon_vld:%0b tagaddr:0x%0h tagged_mon:%0p", s, idx, m_tagged_mon[idx].mon_vld, m_tagged_mon[idx].tagged_addr, m_tagged_mon[idx].tagged_mon);
        end
        q_non_empty = 1;
    end
    
    `uvm_info("DCE SCB", s, UVM_LOW)
    return(q_non_empty);
endfunction: print_pend_txns

//********************************************
function void dce_scb::predict_dm_cohreq_busyvec();
    int sfid;
    bit [WSFWAYVEC-1:0] busy_vec;
    bit [WSFSETIDX-1:0] req_setidx, setidx;
    dm_seq_item lkprsp_pktq[$];
    int idxq[$];

    `uvm_info("DCE_SCB", $psprintf("Received Temp Dir Request @{ACT}: %s", m_dm_tempreq_pkt.convert2string()), UVM_LOW);

    for(int sfid = 0; sfid < addrMgrConst::NUM_SF; sfid++) begin
        req_setidx = m_dirm_mgr.set_index_for_cacheline(m_dm_tempreq_pkt.m_addr, sfid);
        //`uvm_info("BUSY_VEC_DBG", $psprintf("sfid:%0d addr:0x%0h req_setidx:0x%0h", sfid, m_dm_tempreq_pkt.m_addr, req_setidx), UVM_LOW)
    
        foreach(m_dce_txnq[i]) begin
            if (m_dce_txnq[i].m_attid_status != ATTID_IS_RELEASED) begin
                setidx = m_dirm_mgr.set_index_for_cacheline(m_dce_txnq[i].m_initcmdupd_req_pkt.smi_addr, sfid);
            //`uvm_info("BUSY_VEC_DBG", $psprintf("i:%0d attid:0x%0h sfid:%0d addr:0x%0h setidx:0x%0h", i, m_dce_txnq[i].m_attid, sfid, m_dce_txnq[i].m_initcmdupd_req_pkt.smi_addr, setidx), UVM_LOW)
                if ((setidx == req_setidx) && m_dce_txnq[i].m_states["dirrsp"].is_complete()) begin
                    //`uvm_info("DCE SCB", $psprintf("set_address match txnq_idx:%0d sfid:%0d", i, sfid), UVM_LOW)
                    lkprsp_pktq = m_dce_txnq[i].m_dm_pktq.find(item) with ((item.m_access_type == DM_LKP_RSP));
                    if (lkprsp_pktq.size() >= 1) begin 
                        `uvm_info("DCE SCB", $psprintf("dce_txnq: set_idx match attid:0x%0h sfid:%0d ORing way_vec: 0x%0h", m_dce_txnq[i].m_attid, sfid, lkprsp_pktq[lkprsp_pktq.size()-1].m_way_vec_or_mask), UVM_LOW)
                        busy_vec |= lkprsp_pktq[lkprsp_pktq.size() - 1].m_way_vec_or_mask;
                    end
                end
            end
        end

        foreach (m_attvld_aa[i]) begin
            setidx = m_dirm_mgr.set_index_for_cacheline(m_attvld_aa[i].m_initcmdupd_req_pkt.smi_addr, sfid);
            if (setidx == req_setidx) begin
                lkprsp_pktq = m_attvld_aa[i].m_dm_pktq.find(item) with (item.m_access_type == DM_LKP_RSP);
                `uvm_info("DCE SCB", $psprintf("attvld_aa: set_idx match attid:0x%0h sfid:%0d ORing way_vec: 0x%0h", i, sfid, lkprsp_pktq[lkprsp_pktq.size()-1].m_way_vec_or_mask), UVM_LOW)
                busy_vec |= lkprsp_pktq[lkprsp_pktq.size() - 1].m_way_vec_or_mask;
            end
        end
    end
    
    idxq = m_dce_txnq.find_index(item) with ((item.m_initcmdupd_req_pkt.smi_addr == m_dm_tempreq_pkt.m_addr) &&
                                             (item.m_initcmdupd_req_pkt.smi_ns   == m_dm_tempreq_pkt.m_ns) &&
                                             (item.m_initcmdupd_req_pkt.smi_src_ncore_unit_id == (m_dm_tempreq_pkt.m_iid >> WSMINCOREPORTID)) &&
                                             (item.m_initcmdupd_req_pkt.smi_msg_type == m_dm_tempreq_pkt.m_type) &&
                                             ((item.m_attid_status != ATTID_IS_INACTIVE) && (item.m_attid == m_dm_tempreq_pkt.m_attid)) &&
                                             item.m_initcmdupd_req_pkt.isCmdMsg() &&
                                             !item.m_states["dirreq"].is_complete());
    
    if (idxq.size() == 0) 
        idxq = m_dce_txnq.find_index(item) with ((item.m_initcmdupd_req_pkt.smi_addr == m_dm_tempreq_pkt.m_addr) &&
                                                 (item.m_initcmdupd_req_pkt.smi_ns   == m_dm_tempreq_pkt.m_ns) &&
                                                 (item.m_initcmdupd_req_pkt.smi_src_ncore_unit_id == (m_dm_tempreq_pkt.m_iid >> WSMINCOREPORTID)) &&
                                                 (item.m_initcmdupd_req_pkt.smi_msg_type == m_dm_tempreq_pkt.m_type) &&
                                                 (item.m_attid_status == ATTID_IS_INACTIVE) &&
                                                 item.m_initcmdupd_req_pkt.isCmdMsg() &&
                                                 !item.m_states["dirreq"].is_complete());

    //There could be multiple ops in skid buffer waiting to make a COH_REQ, just pick the 1st one.
    if (idxq.size() == 0) begin
        `uvm_error("DCE_SCB", $psprintf("matching dm_txnq_size:%0d not expected",idxq.size()));
    end else begin
        foreach(m_dce_txnq[idxq[0]].m_dm_pktq[i]) begin
            if(m_dce_txnq[idxq[0]].m_dm_pktq[i].m_access_type == DM_CMD_REQ)
                m_dce_txnq[idxq[0]].m_dm_pktq[i].m_busy_vec = busy_vec;
        end
    end

endfunction: predict_dm_cohreq_busyvec

//********************************************************************
//  refer DCE Testplan: Exclusive Monitors for intended behavior 
//******************************************************************
function void dce_scb::predict_exmon_result(int txnq_idx, int iid, int share_vec);
    int tagmon_idx = -1;
    int mpf2_vld, proc_id = 0;
    int agent_id, cache_id, idxq[$];
    bit ex_load, ex_store, ex_op, count, sharer_match;
    string s;
    
    ex_op        = m_dce_txnq[txnq_idx].is_exclusive_operation(ex_load, ex_store);
    proc_id      = m_dce_txnq[txnq_idx].m_initcmdupd_req_pkt.smi_mpf2_flowid;
    mpf2_vld     = m_dce_txnq[txnq_idx].m_initcmdupd_req_pkt.smi_mpf2_flowid_valid;
    agent_id     = addrMgrConst::agentid_assoc2funitid(m_dce_txnq[txnq_idx].m_initcmdupd_req_pkt.smi_src_ncore_unit_id);
    cache_id     = addrMgrConst::get_cache_id(m_dce_txnq[txnq_idx].m_initcmdupd_req_pkt.smi_src_ncore_unit_id); 
    sharer_match = |(share_vec & (1 << iid));

   `uvm_info("DCE SCB EXMON", $psprintf("agent_id:%0d funit_id:%0d cache_id:%0d proc_id:%0d", agent_id, m_dce_txnq[txnq_idx].m_initcmdupd_req_pkt.smi_src_ncore_unit_id, cache_id, proc_id), UVM_LOW)
    
    tagmon_idx = match_tm_addr({m_dce_txnq[txnq_idx].m_initcmdupd_req_pkt.smi_ns, m_dce_txnq[txnq_idx].m_initcmdupd_req_pkt.smi_addr});
    //*********************************************
    // On ex_load:proc_id bit in basic monitor
    //  set --> if addr does not match any tagged address and no tagged monitors are available
    // cleared --> all other cases.
    //*********************************************
    if (ex_load == 1) begin
        
        //some tagmon is already tagged with that cacheline address, so update the proc_id bit for this specific ex_load
        if (tagmon_idx != -1) begin
             
             //clear proc_id in all other exmon and basic monitor
             clear_tm_procid(cache_id, proc_id, tagmon_idx);
             update_bm(0, cache_id, proc_id);
             
             //set proc_id in that matched TM
             set_specific_tm_procid(tagmon_idx, cache_id, proc_id);
             m_dce_txnq[txnq_idx].m_exmon_type = EXMON_TAGMON;

            `uvm_info(get_name(), $psprintf("[%-35s] (txnId: %5d) {%20s} (src: 0x%02h {%s}) (tgt: 0x%02h) (msgId: 0x%02h) (attid : 0x%02h) (rbid: 0x%02h) (addr: 0x%016h) (ns: %1b) (tagAddr: 0x%016h) (tagMon: 0x%02h) (agentId: 0x%02h [0x%02h]) (procId: 0x%03h) (mpf2Vld: %1d)", "DceScbd-ExmonLoadTagMatch", m_dce_txnq[txnq_idx].m_txn_id, m_dce_txnq[txnq_idx].m_initcmdupd_req_pkt.type2cmdname(), m_dce_txnq[txnq_idx].m_initcmdupd_req_pkt.smi_src_ncore_unit_id, addrMgrConst::get_cache_id_as_string(m_dce_txnq[txnq_idx].m_initcmdupd_req_pkt.smi_src_ncore_unit_id), m_dce_txnq[txnq_idx].m_initcmdupd_req_pkt.smi_targ_ncore_unit_id, m_dce_txnq[txnq_idx].m_initcmdupd_req_pkt.smi_msg_id, m_dce_txnq[txnq_idx].m_attid, m_dce_txnq[txnq_idx].m_rbid, m_dce_txnq[txnq_idx].m_initcmdupd_req_pkt.smi_addr, m_dce_txnq[txnq_idx].m_initcmdupd_req_pkt.smi_ns, {m_dce_txnq[txnq_idx].m_initcmdupd_req_pkt.smi_ns, m_dce_txnq[txnq_idx].m_initcmdupd_req_pkt.smi_addr} >> addrMgrConst::WCACHE_OFFSET, tagmon_idx, agent_id, cache_id, proc_id, mpf2_vld), UVM_LOW);

             <% if(obj.COVER_ON) { %>
             m_cov.collect_exmon_scenario(agent_id, proc_id, m_dce_txnq[txnq_idx].m_cmd_type, EXLD_MATCH_TMADDR);
             <% } %>

        end else begin //a tagged monitor is available (no proc is performing exclusive access on the tagged addr. i.e no valid bits are set
             tagmon_idx = new_tm_avail({m_dce_txnq[txnq_idx].m_initcmdupd_req_pkt.smi_ns, m_dce_txnq[txnq_idx].m_initcmdupd_req_pkt.smi_addr}, cache_id, proc_id);
             if(tagmon_idx != -1) begin //found an empty tagged monitor
                //clear proc_id in all other TMs and BM
                clear_tm_procid(cache_id, proc_id, tagmon_idx);
                update_bm(0, cache_id, proc_id);
                m_dce_txnq[txnq_idx].m_exmon_type = EXMON_TAGMON;

               `uvm_info(get_name(), $psprintf("[%-35s] (txnId: %5d) {%20s} (src: 0x%02h {%s}) (tgt: 0x%02h) (msgId: 0x%02h) (attid : 0x%02h) (rbid: 0x%02h) (addr: 0x%016h) (ns: %1b) (tagAddr: 0x%016h) (tagMon: 0x%02h) (agentId: 0x%02h [0x%02h]) (procId: 0x%03h) (mpf2Vld: %1d)", "DceScbd-ExmonLoadTagAvail", m_dce_txnq[txnq_idx].m_txn_id, m_dce_txnq[txnq_idx].m_initcmdupd_req_pkt.type2cmdname(), m_dce_txnq[txnq_idx].m_initcmdupd_req_pkt.smi_src_ncore_unit_id, addrMgrConst::get_cache_id_as_string(m_dce_txnq[txnq_idx].m_initcmdupd_req_pkt.smi_src_ncore_unit_id), m_dce_txnq[txnq_idx].m_initcmdupd_req_pkt.smi_targ_ncore_unit_id, m_dce_txnq[txnq_idx].m_initcmdupd_req_pkt.smi_msg_id, m_dce_txnq[txnq_idx].m_attid, m_dce_txnq[txnq_idx].m_rbid, m_dce_txnq[txnq_idx].m_initcmdupd_req_pkt.smi_addr, m_dce_txnq[txnq_idx].m_initcmdupd_req_pkt.smi_ns, {m_dce_txnq[txnq_idx].m_initcmdupd_req_pkt.smi_ns, m_dce_txnq[txnq_idx].m_initcmdupd_req_pkt.smi_addr} >> addrMgrConst::WCACHE_OFFSET, tagmon_idx, agent_id, cache_id, proc_id, mpf2_vld), UVM_LOW);
                
                <% if(obj.COVER_ON) { %>
                m_cov.collect_exmon_scenario(agent_id, proc_id, m_dce_txnq[txnq_idx].m_cmd_type, EXLD_NOMATCH_TMADDR_OTHER_TM_AVAILABLE);
                <% } %>

             end else begin
                //Row[0]
                //clear proc_id in all other TMs
                clear_tm_procid(cache_id, proc_id);

                //set proc_id bit in BM
                update_bm(1, cache_id, proc_id);
                m_dce_txnq[txnq_idx].m_exmon_type = EXMON_BASICMON;

               `uvm_info(get_name(), $psprintf("[%-35s] (txnId: %5d) {%20s} (src: 0x%02h {%s}) (tgt: 0x%02h) (msgId: 0x%02h) (attid : 0x%02h) (rbid: 0x%02h) (addr: 0x%016h) (ns: %1b) (tagAddr: 0x%016h) (tagMon: ----) (agentId: 0x%02h [0x%02h]) (procId: 0x%03h) (mpf2Vld: %1d)", "DceScbd-ExmonLoadBasicMon", m_dce_txnq[txnq_idx].m_txn_id, m_dce_txnq[txnq_idx].m_initcmdupd_req_pkt.type2cmdname(), m_dce_txnq[txnq_idx].m_initcmdupd_req_pkt.smi_src_ncore_unit_id, addrMgrConst::get_cache_id_as_string(m_dce_txnq[txnq_idx].m_initcmdupd_req_pkt.smi_src_ncore_unit_id), m_dce_txnq[txnq_idx].m_initcmdupd_req_pkt.smi_targ_ncore_unit_id, m_dce_txnq[txnq_idx].m_initcmdupd_req_pkt.smi_msg_id, m_dce_txnq[txnq_idx].m_attid, m_dce_txnq[txnq_idx].m_rbid, m_dce_txnq[txnq_idx].m_initcmdupd_req_pkt.smi_addr, m_dce_txnq[txnq_idx].m_initcmdupd_req_pkt.smi_ns, {m_dce_txnq[txnq_idx].m_initcmdupd_req_pkt.smi_ns, m_dce_txnq[txnq_idx].m_initcmdupd_req_pkt.smi_addr} >> addrMgrConst::WCACHE_OFFSET, agent_id, cache_id, proc_id, mpf2_vld), UVM_LOW);

                <% if(obj.COVER_ON) { %>
                m_cov.collect_exmon_scenario(agent_id, proc_id, m_dce_txnq[txnq_idx].m_cmd_type, EXLD_NOMATCH_TMADDR_OTHER_TM_NOT_AVAILABLE);
                <% } %>
             end
        end
        m_dce_txnq[txnq_idx].m_exmon_status = EXMON_PASS;
    end 
    //*********************************************
    // On ex_store:proc_id bit in basic monitor
    //  set --> If the message address matches a tagged , addrMgrConst::get_cache_id(m_dce_txnq[txnq_idx].m_initcmdupd_req_pkt.smi_src_ncore_unit_id)address and the valid bit for that processor in the tagged monitor is set, i.e on EX_PASS
    //          If the message address does not match a tagged address and the valid bit for that processor in the basic monitor is set, i.e on EX_PASS
    // cleared --> all other cases.
    //*********************************************
    else if (ex_store == 1) begin
        // CONC-12556
        // adding the logic that fails exclusive store when the cacheline is not valid in the src of the exclusive store command
        //#Check.DCE.v36.ChiEExMonUpdate
        if(sharer_match == 0) begin

            if(tagmon_idx != -1) begin
                m_dce_txnq[txnq_idx].m_exmon_status = EXMON_FAIL;
                m_dce_txnq[txnq_idx].m_exmon_type   = EXMON_TAGMON;

                clear_tm_procid(cache_id, proc_id, tagmon_idx);
                set_specific_tm_procid(tagmon_idx, cache_id, proc_id);
                update_bm(0, cache_id, proc_id);

               `uvm_info(get_name(), $psprintf("[%-35s] (txnId: %5d) {%20s} (src: 0x%02h {%s}) (tgt: 0x%02h) (msgId: 0x%02h) (attid : 0x%02h) (rbid: 0x%02h) (addr: 0x%016h) (ns: %1b) (tagAddr: 0x%016h) (tagMon: 0x%02h) (agentId: 0x%02h [0x%02h]) (procId: 0x%03h) (mpf2Vld: %1d) (iid: 0x%02h) (shareVec: 0x%06h) (sharerMatch: %1b)", "DceScbd-ExmonFailNoShr-SetTagMatch", m_dce_txnq[txnq_idx].m_txn_id, m_dce_txnq[txnq_idx].m_initcmdupd_req_pkt.type2cmdname(), m_dce_txnq[txnq_idx].m_initcmdupd_req_pkt.smi_src_ncore_unit_id, addrMgrConst::get_cache_id_as_string(m_dce_txnq[txnq_idx].m_initcmdupd_req_pkt.smi_src_ncore_unit_id), m_dce_txnq[txnq_idx].m_initcmdupd_req_pkt.smi_targ_ncore_unit_id, m_dce_txnq[txnq_idx].m_initcmdupd_req_pkt.smi_msg_id, m_dce_txnq[txnq_idx].m_attid, m_dce_txnq[txnq_idx].m_rbid, m_dce_txnq[txnq_idx].m_initcmdupd_req_pkt.smi_addr, m_dce_txnq[txnq_idx].m_initcmdupd_req_pkt.smi_ns, {m_dce_txnq[txnq_idx].m_initcmdupd_req_pkt.smi_ns, m_dce_txnq[txnq_idx].m_initcmdupd_req_pkt.smi_addr} >> addrMgrConst::WCACHE_OFFSET, tagmon_idx, agent_id, cache_id, proc_id, mpf2_vld, iid, share_vec, sharer_match), UVM_LOW);

                // FIXME: YRAMASAY - fix the coverage collection
                <% if(obj.COVER_ON) { %>
                m_cov.collect_exmon_scenario(agent_id, proc_id, m_dce_txnq[txnq_idx].m_cmd_type, EXST_MATCH_TMADDR_NO_TMVLD);
                <% } %>
            end
            else begin
                tagmon_idx = new_tm_avail({m_dce_txnq[txnq_idx].m_initcmdupd_req_pkt.smi_ns, m_dce_txnq[txnq_idx].m_initcmdupd_req_pkt.smi_addr}, cache_id, proc_id);

                if(tagmon_idx != -1) begin
                    clear_tm_procid(cache_id, proc_id, tagmon_idx);
                    update_bm(0, cache_id, proc_id);
                    m_dce_txnq[txnq_idx].m_exmon_status = EXMON_FAIL;
                    m_dce_txnq[txnq_idx].m_exmon_type   = EXMON_TAGMON;
                    
                   `uvm_info(get_name(), $psprintf("[%-35s] (txnId: %5d) {%20s} (src: 0x%02h {%s}) (tgt: 0x%02h) (msgId: 0x%02h) (attid : 0x%02h) (rbid: 0x%02h) (addr: 0x%016h) (ns: %1b) (tagAddr: 0x%016h) (tagMon: 0x%02h) (agentId: 0x%02h [0x%02h]) (procId: 0x%03h) (mpf2Vld: %1d) (iid: 0x%02h) (shareVec: 0x%06h) (sharerMatch: %1b)", "DceScbd-ExmonFailNoShr-NewTag", m_dce_txnq[txnq_idx].m_txn_id, m_dce_txnq[txnq_idx].m_initcmdupd_req_pkt.type2cmdname(), m_dce_txnq[txnq_idx].m_initcmdupd_req_pkt.smi_src_ncore_unit_id, addrMgrConst::get_cache_id_as_string(m_dce_txnq[txnq_idx].m_initcmdupd_req_pkt.smi_src_ncore_unit_id), m_dce_txnq[txnq_idx].m_initcmdupd_req_pkt.smi_targ_ncore_unit_id, m_dce_txnq[txnq_idx].m_initcmdupd_req_pkt.smi_msg_id, m_dce_txnq[txnq_idx].m_attid, m_dce_txnq[txnq_idx].m_rbid, m_dce_txnq[txnq_idx].m_initcmdupd_req_pkt.smi_addr, m_dce_txnq[txnq_idx].m_initcmdupd_req_pkt.smi_ns, {m_dce_txnq[txnq_idx].m_initcmdupd_req_pkt.smi_ns, m_dce_txnq[txnq_idx].m_initcmdupd_req_pkt.smi_addr} >> addrMgrConst::WCACHE_OFFSET, tagmon_idx, agent_id, cache_id, proc_id, mpf2_vld, iid, share_vec, sharer_match), UVM_LOW);

                    // FIXME: YRAMASAY - fix the coverage collection
                    <% if(obj.COVER_ON) { %>
                    m_cov.collect_exmon_scenario(agent_id, proc_id, m_dce_txnq[txnq_idx].m_cmd_type, EXST_NOMATCH_TMADDR_NO_BMVLD_OTHER_TM_AVAILABLE);
                    <% } %>

                end else begin
                    clear_tm_procid(cache_id, proc_id, tagmon_idx);
                    update_bm(1, cache_id, proc_id);
                    m_dce_txnq[txnq_idx].m_exmon_status = EXMON_FAIL;
                    m_dce_txnq[txnq_idx].m_exmon_type   = EXMON_BASICMON;

                   `uvm_info(get_name(), $psprintf("[%-35s] (txnId: %5d) {%20s} (src: 0x%02h {%s}) (tgt: 0x%02h) (msgId: 0x%02h) (attid : 0x%02h) (rbid: 0x%02h) (addr: 0x%016h) (ns: %1b) (tagAddr: 0x%016h) (tagMon: 0x%02h) (agentId: 0x%02h [0x%02h]) (procId: 0x%03h) (mpf2Vld: %1d) (iid: 0x%02h) (shareVec: 0x%06h) (sharerMatch: %1b)", "DceScbd-ExmonFailNoShr-SetBasicMon", m_dce_txnq[txnq_idx].m_txn_id, m_dce_txnq[txnq_idx].m_initcmdupd_req_pkt.type2cmdname(), m_dce_txnq[txnq_idx].m_initcmdupd_req_pkt.smi_src_ncore_unit_id, addrMgrConst::get_cache_id_as_string(m_dce_txnq[txnq_idx].m_initcmdupd_req_pkt.smi_src_ncore_unit_id), m_dce_txnq[txnq_idx].m_initcmdupd_req_pkt.smi_targ_ncore_unit_id, m_dce_txnq[txnq_idx].m_initcmdupd_req_pkt.smi_msg_id, m_dce_txnq[txnq_idx].m_attid, m_dce_txnq[txnq_idx].m_rbid, m_dce_txnq[txnq_idx].m_initcmdupd_req_pkt.smi_addr, m_dce_txnq[txnq_idx].m_initcmdupd_req_pkt.smi_ns, {m_dce_txnq[txnq_idx].m_initcmdupd_req_pkt.smi_ns, m_dce_txnq[txnq_idx].m_initcmdupd_req_pkt.smi_addr} >> addrMgrConst::WCACHE_OFFSET, tagmon_idx, agent_id, cache_id, proc_id, mpf2_vld, iid, share_vec, sharer_match), UVM_LOW);

                    // FIXME: YRAMASAY - fix the coverage collection
                    <% if(obj.COVER_ON) { %>
                    m_cov.collect_exmon_scenario(agent_id, proc_id, m_dce_txnq[txnq_idx].m_cmd_type, EXST_NOMATCH_TMADDR_NO_BMVLD_OTHER_TM_NOT_AVAILABLE);
                    <% } %>
                end
            end
        end
        else begin
            //some tagmon is already tagged with that cacheline address
            if(tagmon_idx != -1) begin
                if(m_tagged_mon[tagmon_idx].tagged_mon[cache_id][proc_id]) begin //proc_id bit is set in matching tagged monitors
                    //On STREX PASS, clear the proc_id and all the other proc_id bits of the tagged monitor. In short, clear the entire monitor
                    foreach(m_tagged_mon[tagmon_idx].tagged_mon[i]) begin
                        m_tagged_mon[tagmon_idx].tagged_mon[i] = 0;
                    end

                    //Set the proc_id bit in basic monitor
                    update_bm(1, cache_id, proc_id);
                    m_dce_txnq[txnq_idx].m_exmon_status = EXMON_PASS;
                    m_dce_txnq[txnq_idx].m_exmon_type   = EXMON_TAGMON;
                    generate_sys_event_reqs();
                    latest_store_pass_time = $time;

                   `uvm_info(get_name(), $psprintf("[%-35s] (txnId: %5d) {%20s} (src: 0x%02h {%s}) (tgt: 0x%02h) (msgId: 0x%02h) (attid : 0x%02h) (rbid: 0x%02h) (addr: 0x%016h) (ns: %1b) (tagAddr: 0x%016h) (tagMon: 0x%02h) (agentId: 0x%02h [0x%02h]) (procId: 0x%03h) (mpf2Vld: %1d) (iid: 0x%02h) (shareVec: 0x%06h) (sharerMatch: %1b)", "DceScbd-ExmonPass-TagMatch", m_dce_txnq[txnq_idx].m_txn_id, m_dce_txnq[txnq_idx].m_initcmdupd_req_pkt.type2cmdname(), m_dce_txnq[txnq_idx].m_initcmdupd_req_pkt.smi_src_ncore_unit_id, addrMgrConst::get_cache_id_as_string(m_dce_txnq[txnq_idx].m_initcmdupd_req_pkt.smi_src_ncore_unit_id), m_dce_txnq[txnq_idx].m_initcmdupd_req_pkt.smi_targ_ncore_unit_id, m_dce_txnq[txnq_idx].m_initcmdupd_req_pkt.smi_msg_id, m_dce_txnq[txnq_idx].m_attid, m_dce_txnq[txnq_idx].m_rbid, m_dce_txnq[txnq_idx].m_initcmdupd_req_pkt.smi_addr, m_dce_txnq[txnq_idx].m_initcmdupd_req_pkt.smi_ns, {m_dce_txnq[txnq_idx].m_initcmdupd_req_pkt.smi_ns, m_dce_txnq[txnq_idx].m_initcmdupd_req_pkt.smi_addr} >> addrMgrConst::WCACHE_OFFSET, tagmon_idx, agent_id, cache_id, proc_id, mpf2_vld, iid, share_vec, sharer_match), UVM_LOW);

                    <% if(obj.COVER_ON) { %>
                    m_cov.collect_exmon_scenario(agent_id, proc_id, m_dce_txnq[txnq_idx].m_cmd_type, EXST_MATCH_TMADDR_TMVLD);
                    <% } %>

                end else begin //proc_id bit is not set in the tagged monitor 
                    //Row[6]
                    clear_tm_procid(cache_id, proc_id, tagmon_idx);
                    set_specific_tm_procid(tagmon_idx, cache_id, proc_id);
                    update_bm(0, cache_id, proc_id);
                    m_dce_txnq[txnq_idx].m_exmon_status = EXMON_FAIL;
                    m_dce_txnq[txnq_idx].m_exmon_type   = EXMON_TAGMON;

                   `uvm_info(get_name(), $psprintf("[%-35s] (txnId: %5d) {%20s} (src: 0x%02h {%s}) (tgt: 0x%02h) (msgId: 0x%02h) (attid : 0x%02h) (rbid: 0x%02h) (addr: 0x%016h) (ns: %1b) (tagAddr: 0x%016h) (tagMon: 0x%02h) (agentId: 0x%02h [0x%02h]) (procId: 0x%03h) (mpf2Vld: %1d) (iid: 0x%02h) (shareVec: 0x%06h) (sharerMatch: %1b)", "DceScbd-ExmonFail-SetTagMatch", m_dce_txnq[txnq_idx].m_txn_id, m_dce_txnq[txnq_idx].m_initcmdupd_req_pkt.type2cmdname(), m_dce_txnq[txnq_idx].m_initcmdupd_req_pkt.smi_src_ncore_unit_id, addrMgrConst::get_cache_id_as_string(m_dce_txnq[txnq_idx].m_initcmdupd_req_pkt.smi_src_ncore_unit_id), m_dce_txnq[txnq_idx].m_initcmdupd_req_pkt.smi_targ_ncore_unit_id, m_dce_txnq[txnq_idx].m_initcmdupd_req_pkt.smi_msg_id, m_dce_txnq[txnq_idx].m_attid, m_dce_txnq[txnq_idx].m_rbid, m_dce_txnq[txnq_idx].m_initcmdupd_req_pkt.smi_addr, m_dce_txnq[txnq_idx].m_initcmdupd_req_pkt.smi_ns, {m_dce_txnq[txnq_idx].m_initcmdupd_req_pkt.smi_ns, m_dce_txnq[txnq_idx].m_initcmdupd_req_pkt.smi_addr} >> addrMgrConst::WCACHE_OFFSET, tagmon_idx, agent_id, cache_id, proc_id, mpf2_vld, iid, share_vec, sharer_match), UVM_LOW);

                    <% if(obj.COVER_ON) { %>
                    m_cov.collect_exmon_scenario(agent_id, proc_id, m_dce_txnq[txnq_idx].m_cmd_type, EXST_MATCH_TMADDR_NO_TMVLD);
                    <% } %>
                end
            end else begin //none of the tagged monitors is tagged with that cacheline address
                if (m_basic_mon[cache_id][proc_id]) begin
                    //On STREX PASS, clear all the other proc_id bits of the basic monitor, but keep the [cache_id, proc_id] pair bit set
                    foreach(m_basic_mon[i]) begin
                        m_basic_mon[i] = 0;
                    end
                    m_basic_mon[cache_id][proc_id] = 1;

                    m_dce_txnq[txnq_idx].m_exmon_status = EXMON_PASS;
                    m_dce_txnq[txnq_idx].m_exmon_type   = EXMON_BASICMON;
                    generate_sys_event_reqs();
                    latest_store_pass_time = $time;

                   `uvm_info(get_name(), $psprintf("[%-35s] (txnId: %5d) {%20s} (src: 0x%02h {%s}) (tgt: 0x%02h) (msgId: 0x%02h) (attid : 0x%02h) (rbid: 0x%02h) (addr: 0x%016h) (ns: %1b) (tagAddr: 0x%016h) (tagMon: ----) (agentId: 0x%02h [0x%02h]) (procId: 0x%03h) (mpf2Vld: %1d) (iid: 0x%02h) (shareVec: 0x%06h) (sharerMatch: %1b)", "DceScbd-ExmonPass-BasicMon", m_dce_txnq[txnq_idx].m_txn_id, m_dce_txnq[txnq_idx].m_initcmdupd_req_pkt.type2cmdname(), m_dce_txnq[txnq_idx].m_initcmdupd_req_pkt.smi_src_ncore_unit_id, addrMgrConst::get_cache_id_as_string(m_dce_txnq[txnq_idx].m_initcmdupd_req_pkt.smi_src_ncore_unit_id), m_dce_txnq[txnq_idx].m_initcmdupd_req_pkt.smi_targ_ncore_unit_id, m_dce_txnq[txnq_idx].m_initcmdupd_req_pkt.smi_msg_id, m_dce_txnq[txnq_idx].m_attid, m_dce_txnq[txnq_idx].m_rbid, m_dce_txnq[txnq_idx].m_initcmdupd_req_pkt.smi_addr, m_dce_txnq[txnq_idx].m_initcmdupd_req_pkt.smi_ns, {m_dce_txnq[txnq_idx].m_initcmdupd_req_pkt.smi_ns, m_dce_txnq[txnq_idx].m_initcmdupd_req_pkt.smi_addr} >> addrMgrConst::WCACHE_OFFSET, agent_id, cache_id, proc_id, mpf2_vld, iid, share_vec, sharer_match), UVM_LOW);

                    <% if(obj.COVER_ON) { %>
                    m_cov.collect_exmon_scenario(agent_id, proc_id, m_dce_txnq[txnq_idx].m_cmd_type, EXST_NOMATCH_TMADDR_BMVLD);
                    <% } %>

                end else begin 
                    tagmon_idx = new_tm_avail({m_dce_txnq[txnq_idx].m_initcmdupd_req_pkt.smi_ns, m_dce_txnq[txnq_idx].m_initcmdupd_req_pkt.smi_addr}, cache_id, proc_id);

                    if(tagmon_idx != -1) begin
                        //Row[4]
                        clear_tm_procid(cache_id, proc_id, tagmon_idx);
                        update_bm(0, cache_id, proc_id);
                        m_dce_txnq[txnq_idx].m_exmon_status = EXMON_FAIL;
                        m_dce_txnq[txnq_idx].m_exmon_type   = EXMON_TAGMON;

                       `uvm_info(get_name(), $psprintf("[%-35s] (txnId: %5d) {%20s} (src: 0x%02h {%s}) (tgt: 0x%02h) (msgId: 0x%02h) (attid : 0x%02h) (rbid: 0x%02h) (addr: 0x%016h) (ns: %1b) (tagAddr: 0x%016h) (tagMon: ----) (agentId: 0x%02h [0x%02h]) (procId: 0x%03h) (mpf2Vld: %1d) (iid: 0x%02h) (shareVec: 0x%06h) (sharerMatch: %1b)", "DceScbd-ExmonFail-NewTag", m_dce_txnq[txnq_idx].m_txn_id, m_dce_txnq[txnq_idx].m_initcmdupd_req_pkt.type2cmdname(), m_dce_txnq[txnq_idx].m_initcmdupd_req_pkt.smi_src_ncore_unit_id, addrMgrConst::get_cache_id_as_string(m_dce_txnq[txnq_idx].m_initcmdupd_req_pkt.smi_src_ncore_unit_id), m_dce_txnq[txnq_idx].m_initcmdupd_req_pkt.smi_targ_ncore_unit_id, m_dce_txnq[txnq_idx].m_initcmdupd_req_pkt.smi_msg_id, m_dce_txnq[txnq_idx].m_attid, m_dce_txnq[txnq_idx].m_rbid, m_dce_txnq[txnq_idx].m_initcmdupd_req_pkt.smi_addr, m_dce_txnq[txnq_idx].m_initcmdupd_req_pkt.smi_ns, {m_dce_txnq[txnq_idx].m_initcmdupd_req_pkt.smi_ns, m_dce_txnq[txnq_idx].m_initcmdupd_req_pkt.smi_addr} >> addrMgrConst::WCACHE_OFFSET, agent_id, cache_id, proc_id, mpf2_vld, iid, share_vec, sharer_match), UVM_LOW);
                        
                        <% if(obj.COVER_ON) { %>
                        m_cov.collect_exmon_scenario(agent_id, proc_id, m_dce_txnq[txnq_idx].m_cmd_type, EXST_NOMATCH_TMADDR_NO_BMVLD_OTHER_TM_AVAILABLE);
                        <% } %>

                    end else begin
                        //Row[3]
                        clear_tm_procid(cache_id, proc_id, tagmon_idx);
                        update_bm(1, cache_id, proc_id);
                        m_dce_txnq[txnq_idx].m_exmon_status = EXMON_FAIL;
                        m_dce_txnq[txnq_idx].m_exmon_type   = EXMON_BASICMON;

                       `uvm_info(get_name(), $psprintf("[%-35s] (txnId: %5d) {%20s} (src: 0x%02h {%s}) (tgt: 0x%02h) (msgId: 0x%02h) (attid : 0x%02h) (rbid: 0x%02h) (addr: 0x%016h) (ns: %1b) (tagAddr: 0x%016h) (tagMon: ----) (agentId: 0x%02h [0x%02h]) (procId: 0x%03h) (mpf2Vld: %1d) (iid: 0x%02h) (shareVec: 0x%06h) (sharerMatch: %1b)", "DceScbd-ExmonFail-SetBasicMon", m_dce_txnq[txnq_idx].m_txn_id, m_dce_txnq[txnq_idx].m_initcmdupd_req_pkt.type2cmdname(), m_dce_txnq[txnq_idx].m_initcmdupd_req_pkt.smi_src_ncore_unit_id, addrMgrConst::get_cache_id_as_string(m_dce_txnq[txnq_idx].m_initcmdupd_req_pkt.smi_src_ncore_unit_id), m_dce_txnq[txnq_idx].m_initcmdupd_req_pkt.smi_targ_ncore_unit_id, m_dce_txnq[txnq_idx].m_initcmdupd_req_pkt.smi_msg_id, m_dce_txnq[txnq_idx].m_attid, m_dce_txnq[txnq_idx].m_rbid, m_dce_txnq[txnq_idx].m_initcmdupd_req_pkt.smi_addr, m_dce_txnq[txnq_idx].m_initcmdupd_req_pkt.smi_ns, {m_dce_txnq[txnq_idx].m_initcmdupd_req_pkt.smi_ns, m_dce_txnq[txnq_idx].m_initcmdupd_req_pkt.smi_addr} >> addrMgrConst::WCACHE_OFFSET, agent_id, cache_id, proc_id, mpf2_vld, iid, share_vec, sharer_match), UVM_LOW);

                        <% if(obj.COVER_ON) { %>
                        m_cov.collect_exmon_scenario(agent_id, proc_id, m_dce_txnq[txnq_idx].m_cmd_type, EXST_NOMATCH_TMADDR_NO_BMVLD_OTHER_TM_NOT_AVAILABLE);
                        <% } %>
                    end
                end
            end 
        end
    end

    if(ex_load | ex_store) begin
        print_exmonitor_state();
    end

    // CONC-12556
    // Undoing the earlier update as Arch team has suggested a cleaner fix for the issue that caused this problem
endfunction:predict_exmon_result

//Method returns true if address matches with one of tagged monitor address
function int dce_scb::match_tm_addr([WSMIADDR:0] addr_w_sec_i);
    int tagmon_idx = -1;

    foreach(m_tagged_mon[idx]) begin
        //`uvm_info("DBG", $psprintf("match tm_addr idx:%0d in_addr: 0x%0h tagged_addr:0x%0h tagged_mon:%0b", idx, m_dirm_mgr.offset_align_cacheline(addr_w_sec_i), m_tagged_mon[idx].tagged_addr, m_tagged_mon[idx].tagged_mon), UVM_LOW)
        if(addr_w_sec_i >> addrMgrConst::WCACHE_OFFSET == m_tagged_mon[idx].tagged_addr) begin
            foreach (m_tagged_mon[idx].tagged_mon[i]) begin
                if (m_tagged_mon[idx].tagged_mon[i] != 0) begin
                    tagmon_idx = idx;
                    break;
                end
            end
        end
    end

    return(tagmon_idx);
endfunction: match_tm_addr

//Method clear proc_id bit in all TM expect excluded TM
function void dce_scb::clear_tm_procid(int agentid_i, int procid_i, int exclude_tm_idx_i = -1);
    bit mon_vld;

    foreach(m_tagged_mon[idx]) begin
        mon_vld = 0;
        if(idx != exclude_tm_idx_i) begin
            m_tagged_mon[idx].tagged_mon[agentid_i][procid_i] = 1'b0;
        end 
        foreach (m_tagged_mon[idx].tagged_mon[jdx]) begin
            if (m_tagged_mon[idx].tagged_mon[jdx] != 0) begin
                mon_vld = 1;
            end
        end
        if (mon_vld == 0)
            m_tagged_mon[idx].mon_vld = 0;
    end
endfunction: clear_tm_procid

//Set proc_id for specific tm_idx
function void dce_scb::set_specific_tm_procid(int tm_idx_i, int agentid_i, int procid_i);
    m_tagged_mon[tm_idx_i].tagged_mon[agentid_i][procid_i] = 1'b1;
    m_tagged_mon[tm_idx_i].mon_vld = 1;
endfunction: set_specific_tm_procid

function void dce_scb::print_exmonitor_state();
    bit    agent_avail;
    string status;

    foreach(m_tagged_mon[idx]) begin
        status = "";
        foreach(m_tagged_mon[idx].tagged_mon[jdx]) begin
            agent_avail = 0;
            for(int j=0; j < 32; j++) begin
                if(m_tagged_mon[idx].tagged_mon[jdx][j]) begin
                    status      = (agent_avail == 0) ? $psprintf("%s { agentId [0x%02h] : [0x%02h]", status, jdx, j) : $psprintf("%s [0x%02h]", status, j);
                    agent_avail = 1;
                end
            end
            if(agent_avail) begin
                status = $psprintf("%s }", status);
            end
        end
        status = (status.len() > 0) ? $psprintf("[Addr: 0x%016h] %s", m_tagged_mon[idx].tagged_addr, status) : " --- empty ---";
       `uvm_info(get_name(), $psprintf("[%-35s]                %s", $psprintf("DceScbd-ExmonStat-TagMon[0x%02h]", idx), status), UVM_LOW);
    end

    status = "";
    foreach(m_basic_mon[idx]) begin
        agent_avail = 0;
        for(int j=0; j < 32; j++) begin
            if(m_basic_mon[idx][j]) begin
                status      = (agent_avail == 0) ? $psprintf("%s { agentId [0x%02h] : [0x%02h]", status, idx, j) : $psprintf("%s [0x%02h]", status, j);
                agent_avail = 1;
            end
        end
        if(agent_avail) begin
            status = $psprintf("%s }", status);
        end
    end
    status = (status.len() > 0) ? $psprintf("[Addr:       ------      ] %s", status) : " --- empty --- ";
   `uvm_info(get_name(), $psprintf("[%-35s]                %s", "DceScbd-ExmonStat-BasicMon", status), UVM_LOW);
endfunction: print_exmonitor_state

//Set/clear proc_id for basic monitor
function void dce_scb::update_bm(bit set_n_clear_i, int agentid_i, int procid_i);
    m_basic_mon[agentid_i][procid_i] = set_n_clear_i;
endfunction: update_bm

//Method iterates over all Tagged monitor to find a available Tagged monitor
//If there is one then it will set the proc_id bit and write address and returns the actual index. Else returns -1
function int dce_scb::new_tm_avail([WSMIADDR:0] addr_w_sec_i, int agentid_i, int procid_i);
    int exists = -1;
    int prev_tagmon_state;
    
    `uvm_info("DBG", $psprintf("fn: new_tm_avail addr: 0x%0h agentid:%0d procid:%0d", addr_w_sec_i, agentid_i, procid_i), UVM_LOW)
    foreach(m_tagged_mon[idx]) begin
        bit available = 1;
        foreach (m_tagged_mon[idx].tagged_mon[i]) begin
            if (m_tagged_mon[idx].tagged_mon[i] != 0) begin
                available = 0;
                break;
            end
        end
        if (available == 1) begin 
            exists = idx;
            prev_tagmon_state = m_tagged_mon[idx].tagged_mon[agentid_i];
            m_tagged_mon[idx].tagged_addr = addr_w_sec_i >> addrMgrConst::WCACHE_OFFSET;
            m_tagged_mon[idx].tagged_mon[agentid_i][procid_i] = 1'b1;
            m_tagged_mon[idx].mon_vld = 1;

            if(prev_tagmon_state == m_tagged_mon[idx].tagged_mon[agentid_i]) begin
               `uvm_warning(get_name(), $psprintf("[%-35s] looks like a stimulus issue! [agentId: 0x%02h] [procId: 0x%03h] [maxProc: %d]", "DceScbd-ProcIdBeyondMax", agentid_i, procid_i, addrMgrConst::MAX_PROCS));
            end
            break;
        end
    end
//        
//        if(m_tagged_mon[idx].tagged_mon == 0) begin
//            exists = idx;
//            m_tagged_mon[idx].tagged_addr = m_dirm_mgr.offset_align_cacheline(addr_w_sec_i);
//            m_tagged_mon[idx].tagged_mon[procid_i] = 1'b1;
//            break;
//        end
//    end
    return(exists);
endfunction: new_tm_avail


//Task : Calculate Latency for SNP command
task dce_scb::calculate_latency_snp(ref event snp_req,ref event snp_rsp);  
  int snp_req_time,snp_rsp_time,snp_latency;
    @(snp_req);
    snp_req_time = $time;
    @(snp_rsp);
    snp_rsp_time = $time;
    snp_latency  = snp_rsp_time - snp_req_time;
    latency_collection_snp_q.push_back(snp_latency);  
endtask

//Task : Calculate Latency for RBR command
task dce_scb::calculate_latency_rbr(ref event rbr_req,ref event rbr_rsp);  
  int rbr_req_time,rbr_rsp_time,rbr_latency;
    @(rbr_req);
    rbr_req_time = $time;
    @(rbr_rsp);
    rbr_rsp_time = $time;
    rbr_latency  = rbr_rsp_time - rbr_req_time;
    latency_collection_rbr_q.push_back(rbr_latency);  
endtask

//Task : Calculate Latency for MRD command
task dce_scb::calculate_latency_mrd(ref event mrd_req,ref event mrd_rsp);  
  int mrd_req_time,mrd_rsp_time,mrd_latency;
    @(mrd_req);
    mrd_req_time = $time;
    @(mrd_rsp);
    mrd_rsp_time = $time;
    mrd_latency  = mrd_rsp_time - mrd_req_time;
    latency_collection_mrd_q.push_back(mrd_latency);  
endtask

//Task : Calculate Latency for STR command
task dce_scb::calculate_latency_str(ref event str_req,ref event str_rsp);  
  int str_req_time,str_rsp_time,str_latency;
    @(str_req);
    str_req_time = $time;
    @(str_rsp);
    str_rsp_time = $time;
    str_latency  = str_rsp_time - str_req_time;
    latency_collection_str_q.push_back(str_latency);  
endtask

//function : Print Latency data for commands
function void dce_scb::print_latency_data();
  string s;
 // int snp_latency_sum, snp_latency_avg, snp_laten
  //Printig SNP command min,max and average latency.  
  snp.min = snp_latencyq[0];
  snp.max = snp_latencyq[0];
  foreach(snp_latencyq[i]) begin
    snp.sum = snp.sum + snp_latencyq[i];
    if (snp_latencyq[i] > snp.max)
       snp.max = snp_latencyq[i];
    if (snp_latencyq[i] < snp.min)
       snp.min = snp_latencyq[i];
  end  
  snp.avg = snp.sum/snp_latencyq.size();
  $sformat(s, "%s\nSNP: Num of commands %0d, Latency Min : %0d, Max : %0d, Avg : %0d\n", s, snp_latencyq.size(), snp.min, snp.max, snp.avg);

  //Printig RBR RSV command min,max and average latency.  
  rbrsv.min = rbrsv_latencyq[0];
  rbrsv.max = rbrsv_latencyq[0];
  foreach(rbrsv_latencyq[i]) begin
    rbrsv.sum = rbrsv.sum + rbrsv_latencyq[i];
    if (rbrsv_latencyq[i] > rbrsv.max)
       rbrsv.max = rbrsv_latencyq[i];
    if (rbrsv_latencyq[i] < rbrsv.min)
       rbrsv.min = rbrsv_latencyq[i];
  end  
  rbrsv.avg = rbrsv.sum/rbrsv_latencyq.size();
  $sformat(s, "%sRB_RSV: Num of commands %0d, Latency Min : %0d, Max : %0d, Avg : %0d\n", s, rbrsv_latencyq.size(), rbrsv.min, rbrsv.max, rbrsv.avg);

  //Printig RBR RLS command min,max and average latency.  
  rbrls.min = rbrls_latencyq[0];
  rbrls.max = rbrls_latencyq[0];
  foreach(rbrls_latencyq[i]) begin
    rbrls.sum = rbrls.sum + rbrls_latencyq[i];
    if (rbrls_latencyq[i] > rbrls.max)
       rbrls.max = rbrls_latencyq[i];
    if (rbrls_latencyq[i] < rbrls.min)
       rbrls.min = rbrls_latencyq[i];
  end  
  rbrls.avg = rbrls.sum/rbrls_latencyq.size();
  $sformat(s, "%sRB_RLS: Num of commands %0d, Latency Min : %0d, Max : %0d, Avg : %0d\n", s, rbrls_latencyq.size(), rbrls.min, rbrls.max, rbrls.avg);

  //mrd latency
  mrd.min = mrd_latencyq[0];
  mrd.max = mrd_latencyq[0];
  foreach(mrd_latencyq[i]) begin
    mrd.sum = mrd.sum + mrd_latencyq[i];
    if (mrd_latencyq[i] > mrd.max)
       mrd.max = mrd_latencyq[i];
    if (mrd_latencyq[i] < mrd.min)
       mrd.min = mrd_latencyq[i];
  end  
  mrd.avg = mrd.sum/mrd_latencyq.size();
  $sformat(s, "%sMRD: Num of commands %0d, Latency Min : %0d, Max : %0d, Avg : %0d\n", s, mrd_latencyq.size(), mrd.min, mrd.max, mrd.avg);

  //STR latency
  str.min = str_latencyq[0];
  str.max = str_latencyq[0];
  foreach(str_latencyq[i]) begin
    str.sum = str.sum + str_latencyq[i];
    if (str_latencyq[i] > str.max)
       str.max = str_latencyq[i];
    if (str_latencyq[i] < str.min)
       str.min = str_latencyq[i];
  end  
  str.avg = str.sum/str_latencyq.size();
  $sformat(s, "%sSTR: Num of commands %0d, Latency Min : %0d, Max : %0d, Avg : %0d\n", s, str_latencyq.size(), str.min, str.max, str.avg);

  `uvm_info("DCE SCB", s, UVM_LOW)

    if($test$plusargs("dce_latency_checks")) begin
        if(snp.min > snp_exp_latency)
                `uvm_error("DCE Latency", $psprintf("Expected min SnpReq Latency = %d and measured min SnpReq Latency = %d",snp_exp_latency,snp.min))
        if(str.min > str_exp_latency)
                `uvm_error("DCE Latency", $psprintf("Expected min StrReq Latency = %d and measured min StrReq Latency = %d",str_exp_latency,str.min))
        if(mrd.min > mrd_exp_latency)
                `uvm_error("DCE Latency", $psprintf("Expected min MrdReq Latency = %d and measured min MrdReq Latency = %d",mrd_exp_latency,mrd.min))
        if(rbrsv.min > rbr_exp_latency)
                `uvm_error("DCE Latency", $psprintf("Expected min RbrReq Latency = %d and measured min RbrReq Latency = %d",rbr_exp_latency,rbrsv.min))
    end
endfunction

function void dce_scb::update_resiliency_ce_cnt(inout smi_seq_item m_item);
<%  if ((obj.useResiliency) && (obj.testBench != "fsys" && obj.testBench != "cust_tb")) { %>
  int tmp_dp_corr_error;
  string func_s = "update_resiliency_ce_cnt";

  `uvm_info({func_s}, $sformatf("time1 new=%0t, old=%0t", res_smi_pkt_time_new, res_smi_pkt_time_old), UVM_DEBUG);
  res_smi_pkt_time_new = $realtime;
  if(res_smi_pkt_time_new != res_smi_pkt_time_old) begin
    // get error statistics
    if(m_item.ndp_corr_error || m_item.hdr_corr_error || m_item.dp_corr_error_eb) begin
      res_smi_corr_err++;
      if(m_item.dp_corr_error_eb) begin
        res_smi_corr_err = res_smi_corr_err + (m_item.dp_corr_error_eb-1);
        res_mod_dp_corr_error = m_item.dp_corr_error_eb;
        `uvm_info({func_s}, $sformatf("(if/if)tmp_dp_corr_error=%0d, this.res_mod_dp_corr_error=%0d", tmp_dp_corr_error, this.res_mod_dp_corr_error), UVM_DEBUG);
      end
      res_is_pre_err_pkt = 1'b1;
      `uvm_info({func_s}, $sformatf("new smi_pkt(if). res_smi_corr_err=%0d, res_is_pre_err_pkt=%0d", res_smi_corr_err, res_is_pre_err_pkt), UVM_DEBUG);
    end else begin
      res_is_pre_err_pkt = 1'b0;
    end
    `uvm_info({func_s}, $sformatf("time2 new=%0t, old=%0t", res_smi_pkt_time_new, res_smi_pkt_time_old), UVM_DEBUG);
  end else begin
    if(res_is_pre_err_pkt) begin
      if(m_item.dp_corr_error_eb) begin
        tmp_dp_corr_error = m_item.dp_corr_error_eb - this.res_mod_dp_corr_error;
        if(tmp_dp_corr_error < 0)
          tmp_dp_corr_error = 1'b0;
        else
          this.res_mod_dp_corr_error = this.res_mod_dp_corr_error + tmp_dp_corr_error;
        `uvm_info({func_s}, $sformatf("(else/if)tmp_dp_corr_error=%0d, this.res_mod_dp_corr_error=%0d", tmp_dp_corr_error, this.res_mod_dp_corr_error), UVM_DEBUG);
        res_smi_corr_err = res_smi_corr_err + tmp_dp_corr_error;
      end
      `uvm_info({func_s}, $sformatf("new smi_pkt(else/if). res_smi_corr_err=%0d, res_is_pre_err_pkt=%0d", res_smi_corr_err, res_is_pre_err_pkt), UVM_DEBUG);
    end else begin
      if(m_item.ndp_corr_error || m_item.hdr_corr_error || m_item.dp_corr_error_eb) begin
        res_smi_corr_err++;
        if(m_item.dp_corr_error_eb) begin
          res_smi_corr_err = res_smi_corr_err + (m_item.dp_corr_error_eb-1);
          res_mod_dp_corr_error = m_item.dp_corr_error_eb;
          `uvm_info({func_s}, $sformatf("(else/else)tmp_dp_corr_error=%0d, this.res_mod_dp_corr_error=%0d", tmp_dp_corr_error, this.res_mod_dp_corr_error), UVM_DEBUG);
        end
        res_is_pre_err_pkt = 1'b1;
      end
      `uvm_info({func_s}, $sformatf("new smi_pkt(else/else). res_smi_corr_err=%0d, res_is_pre_err_pkt=%0d", res_smi_corr_err, res_is_pre_err_pkt), UVM_DEBUG);
    end
    `uvm_info({func_s}, $sformatf("time3 new=%0t, old=%0t", res_smi_pkt_time_new, res_smi_pkt_time_old), UVM_DEBUG);
  end
  res_smi_pkt_time_old = res_smi_pkt_time_new;
  `uvm_info({func_s}, $sformatf("time4 new=%0t, old=%0t", res_smi_pkt_time_new, res_smi_pkt_time_old), UVM_DEBUG);
<% } %>
endfunction : update_resiliency_ce_cnt


function void dce_scb::check_event_in_req(event_in_check check);
    int flag;
    `uvm_info("DCE_SCB",$psprintf("check = %p,event_in_req_in_flight = %p, event_in_req_edge = %p, event_in_req_buffer = %p",check,event_in_req_in_flight,event_in_req_edge,event_in_req_buffer),UVM_LOW)
    if((check == valid) && (event_in_req_in_flight == 0) && (event_in_req_edge == 1))
            `uvm_error("<%=obj.BlockId%>: DCE_SCB_Event_in_req", $psprintf("Predicted event_in_req == 1 and actual event_in_req == 0 "))
    else if((check == invalid) && (event_in_req_in_flight == 1) && (event_in_req_edge == 1) && (event_in_req_buffer == 0))
            `uvm_error("<%=obj.BlockId%>: DCE_SCB_Event_in_req", $psprintf("Predicted event_in_req == 0 and actual event_in_req == 1 "))
    else if((check == valid) && (event_in_req_in_flight inside {0,1}) && (event_in_req_edge == 0)) // adding 0 for the case where ack is high and store pass scenario so the request will be buffered and event_in_req goes high next clk
        event_in_req_buffer = 1;
    else if(event_in_req_in_flight == 0 && event_in_req_buffer == 0) begin
        if(flag ==1)
            event_in_req_edge = 1;
        else
            flag = 1;
    end
    else begin
        event_in_req_edge = 0;
        flag = 0;
    end

endfunction : check_event_in_req

function void dce_scb::generate_sys_event_reqs();
    dce_scb_txn m_dce_sys_txn;
    if(event_disable == 0) begin
        if(m_dce_sys_txnq.size() < 3 && ((event_in_req_in_flight == 1 && m_dce_sys_txnq.size() != 0) || (event_in_req_in_flight == 0 && m_dce_sys_txnq.size() == 0))) begin 
            m_dce_sys_txn = new("m_dce_txn");
            m_dce_sys_txn.m_req_type = SYSCO_REQ; //KDB:Check if this should be differentiated as SYS_REQ instead of SYSCO_REQ
            m_dce_sys_txn.snoop_enable_reg_txn = snoop_enable_reg;
            m_dce_sys_txn.t_sysreq_process = $time;
            //#Check.DCE.v36.SysEventAllDves
            m_dce_sys_txn.predict_sys_evt_req();
            m_dce_sys_txnq.push_back(m_dce_sys_txn);
        end
        else if(m_dce_sys_txnq.size() == 1 && event_in_req_in_flight == 0) begin
            if(($time - m_dce_sys_txnq[0].t_sysreq_process)/CLK_PERIOD == 1) begin
                m_dce_sys_txn = new("m_dce_txn");
                m_dce_sys_txn.m_req_type = SYSCO_REQ; //KDB:Check if this should be differentiated as SYS_REQ instead of SYSCO_REQ
                m_dce_sys_txn.snoop_enable_reg_txn = snoop_enable_reg;
                m_dce_sys_txn.t_sysreq_process = $time;
                //#Check.DCE.v36.SysEventAllDves
                m_dce_sys_txn.predict_sys_evt_req();
                m_dce_sys_txnq.push_back(m_dce_sys_txn);
            end 
        end 
        
    end
endfunction : generate_sys_event_reqs

function void dce_scb::check_att_size();
  int att_q_size_tmp = 0;
  int att_entries_nb = <%=obj.DceInfo[obj.Id].nAttCtrlEntries%>;

  foreach (m_dce_txnq[i]) begin
    if (!(m_dce_txnq[i].m_attid_status inside {ATTID_IS_INACTIVE,ATTID_IS_RELEASED})) begin
      att_q_size_tmp ++;
    end
  end
  `uvm_info("DCE_SCB",$sformatf("att_q_size_tmp = %0d and att_q_size = %0d",att_q_size_tmp,att_q_size),UVM_MEDIUM)
  if (att_q_size_tmp > att_entries_nb)
    att_q_size_tmp = att_entries_nb;
    
  if (att_q_size_tmp != att_q_size) begin
    att_q_size = att_q_size_tmp;
    sb_stall_if.perf_count_events["Active_ATT_entries"].push_back(att_q_size);
  end
endfunction : check_att_size

function void dce_scb::release_rbid(req_type_t req_type, int dmi_id, int src_id, int att_id, int rbid, string signature);
    int rbid_q[$];
    
    rbid_q = m_rbids_in_use[dmi_id].find_index(x) with (x == rbid);
    if(rbid_q.size() == 1) begin
	    m_rbids_in_use[dmi_id].delete(rbid_q[0]);
       `uvm_info(get_name(), $psprintf("[%-35s] {req: %15s} rbid[0x%02h(%1b)] released for attid[0x%02h]... [src: 0x%02h] [tgt: 0x%02h] [attid: 0x%02h]", signature, req_type.name(), rbid[WSMIRBID-2:0], rbid[WSMIRBID-1], att_id, src_id, dmi_id, att_id), UVM_LOW);
    end else if (rbid_q.size() == 0) begin 
        // YRAMASAMY: Isnt this possible when snoop response comes after rbr-req is sent?
       `uvm_error(get_name(), $psprintf("[%-35s] {req: %15s} rbid[0x%02h(%1b)] for attid[0x%02h] not found! [src: 0x%02h] [tgt: 0x%02h] [attid: 0x%02h]", signature, req_type.name(), rbid[WSMIRBID-2:0], rbid[WSMIRBID-1], att_id, src_id, dmi_id, att_id));
    end else if (rbid_q.size() > 1) begin
       `uvm_error(get_name(), $psprintf("[%-35s] {req: %15s} too many rbid[0x%02h(%1b)] for attid[0x%02h] found! [src: 0x%02h] [tgt: 0x%02h] [attid: 0x%02h]", signature, req_type.name(), rbid[WSMIRBID-2:0], rbid[WSMIRBID-1], att_id, src_id, dmi_id, att_id));
    end
endfunction: release_rbid

// YRAMASAMY
// CONC-12275
// Added this function to centralize dropping objection. Reason being,
// m_dce_txnq shall have a copy of txn even after dropping objection as opposed to
// deleting them to handle rbr-rsp with minimal changes
function void dce_scb::drop_objection(uvm_phase phase, int idx);
   `uvm_info(get_name(), $psprintf("[%-35s] (txnId: %5d) {%20s} (src: 0x%02h {%s}) (tgt: 0x%02h) (msgId: 0x%02h) (attid : 0x%02h) (rbid: 0x%02h) (addr: 0x%016h) (objStat: %1b)", "DceScbd-ObjDrop", m_dce_txnq[idx].m_txn_id, m_dce_txnq[idx].m_initcmdupd_req_pkt.type2cmdname(), m_dce_txnq[idx].m_initcmdupd_req_pkt.smi_src_ncore_unit_id, addrMgrConst::get_cache_id_as_string(m_dce_txnq[idx].m_initcmdupd_req_pkt.smi_src_ncore_unit_id), m_dce_txnq[idx].m_initcmdupd_req_pkt.smi_targ_ncore_unit_id, m_dce_txnq[idx].m_initcmdupd_req_pkt.smi_msg_id, m_dce_txnq[idx].m_attid, m_dce_txnq[idx].m_rbid, m_dce_txnq[idx].m_initcmdupd_req_pkt.smi_addr, m_dce_txnq[idx].m_objection_dropped), UVM_LOW);
    if(m_dce_txnq[idx].m_objection_dropped == 0) begin
        phase.drop_objection(this, {m_dce_txnq[idx].m_initcmdupd_req_pkt.get_name(), "drop objection"});
        m_obj_tracker[m_dce_txnq[idx].m_txn_id] = 1;
    end
    m_dce_txnq[idx].m_objection_dropped = 1;
endfunction: drop_objection

<%if (obj.testBench == "dce") {%>
//#Check.DCE.v36.PlruChipEn
//#Check.DCE.v36.PlruWriteEn
//#Check.DCE.v36.PlruAddrMatch
//#Check.DCE.v36.PlruUniqueAccess
function void dce_scb::check_sf_obsv_item(int rw, int sfid, int way, longint addr, int clear_vbhit_busy, string signature="");
    int match_idx[$], set_idx;

    if(rw == 0) begin
        for(int i=0; i < addrMgrConst::NUM_SF; i++) begin
            if((sfid == -1) || (sfid == i)) begin
                set_idx = addrMgrConst::get_sf_set_index(i, addr);
                for(int j=0; j < addrMgrConst::snoop_filters_info[i].num_ways; j++) begin
                    match_idx = {};
                    match_idx = m_obsv_sf_q[i][j].find_index(item) with ((item.m_way       ==       j) &&
                                                                         (item.m_rd0_wr1   ==       0) &&
                                                                         (item.m_set_index == set_idx));
                    //#Check.DCE.v36.AddrHash
                    if(match_idx.size() == 0) begin
                       `uvm_error(get_name(), $psprintf("[%35s] [addr: 0x%016h] [sf: %2d] [way: %2d] [set_index: 0x%04h]", $psprintf("DceScbd-SfReadNoMatch(%s)", signature), addr, i, j, set_idx));
                    end
                    else begin
                       `uvm_info(get_name(), $psprintf("[%35s] [addr: 0x%016h] [sf: %2d] [way: %2d] [set_index: 0x%04h]", $psprintf("DceScbd-SfReadMatch(%s)", signature), addr, i, j, set_idx), UVM_DEBUG);
                        m_obsv_sf_q[i][j].delete(match_idx[0]);
                    end
                end
            end
        end
    end
    else begin
        set_idx   = addrMgrConst::get_sf_set_index(sfid, addr);
        match_idx = {};
        match_idx = m_obsv_sf_q[sfid][way].find_index(item) with ((item.m_way       ==     way) &&
                                                                  (item.m_rd0_wr1   ==       1) &&
                                                                  (item.m_set_index == set_idx));
        if(clear_vbhit_busy == 1) begin
            m_vbhit_way_busy[sfid][set_idx][way] = 0;
        end

        if(match_idx.size() == 0) begin
            // demoting this to a warning as there is an issue with victim buffer prediction
            // and also adding hashing checks assumes the victim buffer design is golden
           `uvm_warning(get_name(), $psprintf("[%35s] [addr: 0x%016h] [sf: %2d] [way: %2d] [set_index: 0x%04h] (lookback 300ns for the actual error timing!)", $psprintf("DceScbd-SfWriteNoMatch(%s)", signature), addr, sfid, way, set_idx));
        end
        else begin
           `uvm_info(get_name(), $psprintf("[%35s] [addr: 0x%016h] [sf: %2d] [way: %2d] [set_index: 0x%04h]", $psprintf("DceScbd-SfWriteMatch(%s)", signature), addr, sfid, way, set_idx), UVM_DEBUG);
            m_obsv_sf_q[sfid][way].delete(match_idx[0]);
        end
    end
endfunction: check_sf_obsv_item

function void dce_scb::alloc_plru_state(int sfid, int way, longint addr, longint busy_ways, longint alloc_ways, string signature="");
    int set_idx, way_mismatch, plru_ram_wr_busy, dm_model_busy, cumm_busy_ways;
    tag_snoop_filter tag_sf;

    if(sfid < 0) begin
       `uvm_error(get_name(), $psprintf("[%-35s] noticed a commit for a non-coherrent agent!", $psprintf("DceScbd-PlruValidateErr %s", signature)));
    end
    else begin
        tag_sf  = m_dirm_mgr.get_tag_sf_handle(sfid);
        set_idx = addrMgrConst::get_sf_set_index(sfid, addr);

        dm_model_busy    = (tag_sf.get_busy_way_vector(set_idx) & ~(1 << way));
        plru_ram_wr_busy = 0;
        for(int i=0; i < m_plru_mem_wr_busy_tracker[sfid][set_idx].size(); i++) begin
            plru_ram_wr_busy[m_plru_mem_wr_busy_tracker[sfid][set_idx][i]] = 1;
        end
        cumm_busy_ways   = busy_ways | dm_model_busy | m_vbhit_way_busy[sfid][set_idx] | plru_ram_wr_busy;

       `uvm_info(get_name(), $psprintf("[%-35s] [sfid: 0x%02h] [addr: 0x%016h >> setIdx: 0x%08h] [way: %2d] [rspBusy: 0x%08h] [dmModelBusy: 0x%08h] [vbhitBusy: 0x%08h] [plruWrBusy: %2d >> 0x%08h] [allocWays: 0x%08h]", $psprintf("DceScbd-SfPlruCheck %s", signature), sfid, addr, set_idx, way, busy_ways, dm_model_busy, m_vbhit_way_busy[sfid][set_idx], m_plru_mem_wr_busy_tracker[sfid][set_idx].size(), plru_ram_wr_busy, alloc_ways), UVM_MEDIUM);
        // Reason for including busy ways for computing the unalloc ways is:-
        //   - We compute alloc ways at lkup req stage to be accurate
        //   - But, an earlier lkup req which has not received response at that time would not show up in alloc ways. However,
        //     the busy vector compuration does takes that into account and hence reusing that logic
        way_mismatch = m_plru_model[sfid].check_plru_logic(.set_index(set_idx), .evicted_way(way), .busy_ways(cumm_busy_ways), .unalloc_ways(~(alloc_ways | cumm_busy_ways)), .donot_error_on_mismatch(1));

        // CONC-13075
        if((way_mismatch == 1) && (addrMgrConst::snoop_filters_info[sfid].victim_entries > 0)) begin
           `uvm_info(get_name(), $psprintf("[%-35s] disabling plru check [sfid: 0x%02h] [victimEntries: %1d]", "DceScbd-SfPlruCheckOff", sfid, addrMgrConst::snoop_filters_info[sfid].victim_entries), UVM_NONE);
            m_disable_plru_check_conc13075[sfid] = 1;
        end

        if(m_plru_mem_wr_ahead_cnt[sfid][set_idx] > 0) begin
            m_plru_mem_wr_ahead_cnt[sfid][set_idx]--;
        end
        else begin
            m_plru_mem_wr_busy_tracker[sfid][set_idx].push_back(way);
        end
    end
endfunction: alloc_plru_state

function void dce_scb::update_plru_state(int sfid, int way, longint addr, string signature="");
    int set_idx;

    if(sfid < 0) begin
       `uvm_error(get_name(), $psprintf("[%-35s] noticed a commit for a non-coherrent agent!", $psprintf("DceScbd-PlruValidateErr %s", signature)));
    end
    else begin
        set_idx = addrMgrConst::get_sf_set_index(sfid, addr);
       `uvm_info(get_name(), $psprintf("[%-35s] [sfid: 0x%02h] [addr: 0x%016h >> setIdx: 0x%08h] [mru: %2d]", $psprintf("DceScbd-SfPlruUpdOnHit %s", signature), sfid, addr, set_idx, way), UVM_MEDIUM);
        m_plru_model[sfid].update_plru_state_on_hit(.set_index(set_idx), .hit_way(way));

        if(m_plru_mem_wr_ahead_cnt[sfid][set_idx] > 0) begin
            m_plru_mem_wr_ahead_cnt[sfid][set_idx]--;
        end
        else begin
            m_plru_mem_wr_busy_tracker[sfid][set_idx].push_back(way);
        end
    end
endfunction: update_plru_state

// sf monitor port function
<% for(var x = 0; x < sf_cnt; x++){ %>
function void dce_scb::write_sf_port_in_<%=x%> (snoop_filter_seq_item sf_item);
    int this_sf_id = <%=x%>;
    int match_idx[$];
    
   `uvm_info(get_name(), $psprintf("[%-35s] %s", "DceScbd-SfPort[<%=x%>]-In", sf_item.convert2string()), UVM_DEBUG);
    m_obsv_sf_q[this_sf_id][sf_item.m_way].push_back(sf_item);

    <% if(obj.COVER_ON) { %>
    if(sf_item.m_rd0_wr1) begin
        m_cov.cg_sf_access_v36.sample(.sf_id(<%=x%>), .set_idx(sf_item.m_set_index));
    end
    <% } %>
endfunction: write_sf_port_in_<%=x%>

<% if(plru_en == 1) { %>
function void dce_scb::write_plru_mem_wr_port_in_<%=x%> (snoop_filter_seq_item sf_item);
    int this_sf_id = <%=x%>;
    
    if(m_plru_mem_wr_busy_tracker[this_sf_id][sf_item.m_set_index].size() > 0) begin
        m_plru_mem_wr_busy_tracker[this_sf_id][sf_item.m_set_index].pop_front();
    end
    else begin
        m_plru_mem_wr_ahead_cnt[this_sf_id][sf_item.m_set_index]++;
       `uvm_info(get_name(), $psprintf("[%-35s] %s", $psprintf("DceScbd-SfPlruMemWrAhead[<%=x%>]-In[#%2d]", m_plru_mem_wr_ahead_cnt[this_sf_id][sf_item.m_set_index]), sf_item.convert2string()), UVM_HIGH);
    end
endfunction: write_plru_mem_wr_port_in_<%=x%>
<% } %>
<% } %>
<% } %>
