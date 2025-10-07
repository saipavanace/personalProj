//Typedefs
typedef enum int {RBID_RESERVED, RBID_UNRESERVED} rbid_status_t;
typedef enum int {EXMON_NONE, EXMON_TAGMON, EXMON_BASICMON} exmon_type_t;

<% if(obj.COVER_ON) { %>
typedef class dce_coverage;
<% } %>


//State used to track particular attid in ATT module
//ATTID_IS_INACTIVE: txn still not observed at ATT module insterface
//ATTID_IS_ACTIVE:   txn active in ATT module
//ATTID_IS_SLEEP:    txn in sleep in ATT module. wakes up depending on the attid chain
//ATTID_IS_RELEASED: txn is committed in drectory and ATT module deallocated the attid
//                   This is end of the transaction and pkt must be deleted from the queues
//                   (10/19/16) This state was added to avoid race condition between STRrsp
//                   observed by TB and commit req from ATT->DIRM happening on same cyce.
//                   This state is used to serliaze the corner case
typedef enum int {
    ATTID_IS_INACTIVE, ATTID_IS_ACTIVE, ATTID_IS_SLEEP, ATTID_IS_RELEASED, ATTID_IS_WAKEUP} attid_status_t;

typedef enum bit {
    EXMON_FAIL, EXMON_PASS} exmon_status_t;

typedef enum int {
    CMD_REQ, UPD_REQ, REC_REQ, SYSCO_REQ} req_type_t;
    
typedef struct{
    time    snp_req;
    time    snp_rsp;
    time    rbrsv_req;
    time    rbrls_req;
    time    rbu_req;
    time    str_req;
    time    dm_write;
    time    rbu_rsp;
    time    rbrsv_rsp;
    time    rbrls_rsp;
} smi_cmds_time_struct_t;

typedef struct {
    bit [1:0]  sysreq_event_opcode;
    bit        sysreq_event;
    bit        sysrsp_event;
    bit [7:0]  cm_status;
    bit        timeout_err_det_en;
    bit        timeout_err_int_en;
    bit [3:0]  uesr_err_type;
    bit        err_valid;
    bit        irq_uc;
    bit [30:0] timeout_threshold;
} sys_event_cov_s;

typedef enum int {
    DtrDataInv, DtrDataSCln, DtrDataSDty, DtrDataUCln, DtrDataUDty, NoDtr} dtr_type_t;


//DCE scoreboard transaction item.
class dce_scb_txn extends uvm_object;

    `uvm_object_param_utils(dce_scb_txn)

    //////////////////////////////////////////////////////////////
    //Properties
    //////////////////////////////////////////////////////////////
    // txn id for keeping track of txn
    static int m_txn_cntr = 0;
    int        m_txn_id;

    //SMI req/rsp seq items
    smi_seq_item m_initcmdupd_req_pkt; 
    smi_seq_item m_expcmdupd_rsp_pkt;
    
    smi_seq_item m_expmrd_req_pkt;
    smi_seq_item m_drvmrd_rsp_pkt;
    
    smi_seq_item m_expstr_req_pkt;
    smi_seq_item m_drvstr_rsp_pkt;

    smi_seq_item m_exprbr_req_pktq[$];
    smi_seq_item m_drvrbr_rsp_pktq[$];
    
    smi_seq_item m_drvrbu_req_pkt;
    smi_seq_item m_exprbu_rsp_pkt;
    
    smi_seq_item m_expsnp_req_pktq[$];
    smi_seq_item m_drvsnp_rsp_pktq[$];
    
    // EVENT transaction items
    smi_seq_item m_expsys_event_req_pktq_<%=obj.BlockId%>[$];
    smi_seq_item m_initsys_co_req_pkt;
    smi_seq_item m_expsys_co_rsp_pkt;
    bit [<%=obj.DceInfo[0].nAius%>-1:0] snoop_enable_reg_txn;

    extern function void predict_sys_evt_req();
    extern function void repredict_sys_evt_req();
    extern function void check_sys_event_req(const ref smi_seq_item seq_item);
    extern function void process_sys_event_rsp(const ref smi_seq_item seq_item);
    extern function void save_sys_co_req(const ref smi_seq_item seq_item);
    extern function void check_sys_co_req(const ref smi_seq_item seq_item);
    extern function void check_sys_co_rsp(const ref smi_seq_item seq_item);
    //////////////////////////////////////////////////////////////

    dm_seq_item m_dm_pktq[$];
    dm_seq_item dm_lkprsp; // Added this to keep a copy of unmodified DM CMD RSP Pkt   

    state_check_item m_states[string];
    int sf_set_index[$];

    // YRAMASAMY
    // CONC-12275
    // reason for adding a state variable m_internal_rbr_release is to ensure the fsys bench doesnt hang when rbr-req doesnt
    // see a rbr-rsp, which can happen when there is an internal release
    bit m_internal_rbr_release;
    bit m_objection_dropped;

    smi_cmds_time_struct_t time_struct;
    sys_event_cov_s sys_event_cov_txn;
    dtr_type_t dtrreq;
    
    //Handle for Directory Manager;
    directory_mgr m_dirm_mgr;

 <% if(obj.COVER_ON) { %>
        dce_coverage m_cov;
 <% } %>
    
    //Static properties to map cmdreq2snpreq
    static eMsgSNP cmdreq2owner_snp[eMsgCMD];
    static eMsgSNP cmdreq2sharer_snp[eMsgCMD];

    //Static property to map cmdreq2mrdreq
    //2-D Rows: msgType; Colom: {SR, CV}
    //CV is 2-bit, [1:0] 0-False, [1, 2]-True 3-Uncertain
    //TS is 1-bit, [2]   0-NC (not constrained, 1-CI (clean unless invalid)
    //Refer table: 77 in CMPS spec revB DCE sec, Mrd sub-section
    static eMsgCMD cmdreq2mrdreq[eMsgMRD][bit [2:0]];

    //Misc status information
    req_type_t        m_req_type;
    attid_status_t    m_attid_status;
    rbid_status_t     m_rbid_status;
    exmon_type_t      m_exmon_type;
    exmon_status_t    m_exmon_status;
    int               m_attid;
    int               m_rbid;
    int               m_iid_cacheid;
    int               m_sid_cacheid;
    int               m_dmiid;
    bit               m_garbage_dmiid;
    bit               ex_store;
    bit               ex_load;
    bit               rtl_deallocated;
    bit               arb_valid = 'b0;
    time              arb_valid_time;

    int               m_attid_release_cycle;
    time              m_attid_deleted_time;
    eMsgCMD           m_cmd_type;
    time              t_dm_cmdreq;
    time              t_conc_mux_cmdreq;
    bit [7:0]         agg_snprsp_cmstatus;
    bit               owner_present;
    bit               credit_zero_err;
    time              t_sysreq_process;
    bit [$clog2(addrMgrConst::NUM_CACHES)-1:0] owner_cacheid = 'h0;

    // timeStamps of states to monitor latency checks
    time              t_cmdreq;
    time              t_mrdrsp;
    time              t_last_snprsp;

    //Credits check Data structure.
    //Class constructed in score-board and passed over to this class.
    //Single instance for all inflight transactions
    dce_credits_check m_credits;

    local bit m_dm_chks_en;
    local bit m_up_chks_en;
    local bit m_mpf1_tgtid_chks_en;

    local bit m_disable_check;
        
    //error flags
    bit SNPrsp_data_or_address_error_in_cmstatus;

    //qos settings
    bit m_starvOverflow = 0;
    bit m_starvRequest  = 0;

    //API Methods
    //constructor
    extern function new(string name = "dce_scb_txn");
    extern function void assign_parameters_and_handles(const ref dce_credits_check credits_i, bit dm_chks_en_i, bit up_chks_en_i, bit mpf1_tgtid_chks_en_i);
    //Static method to preload static DS
    extern static function void preload_static_data_structures();

    //coverts object info to string
    extern function string print_txn(verbose = 1);
    extern function string convert_snps2string();
    //Method to store cmd req/rsp
    extern function void save_cmdupd_req(const ref smi_seq_item seq_item);
    extern function void check_cmdupd_req(const ref smi_seq_item seq_item);
    extern function void save_recall_req(int recall_qos, const ref dm_seq_item recreq);
    extern function void check_dm_req_txn(const ref dm_seq_item item);
    extern function void save_dm_rsp_txn(const ref dm_seq_item item);
    extern function void save_snprsp(const ref smi_seq_item seq_item);
    extern function void save_strrsp(const ref smi_seq_item seq_item);
    extern function void save_mrdrsp(const ref smi_seq_item seq_item);
    extern function void save_rbrrsp(const ref smi_seq_item seq_item);
    extern function void save_rbureq(const ref smi_seq_item seq_item);

    extern function void check_cmdupd_rsp(const ref smi_seq_item seq_item);
    extern function void check_rbu_rsp(const ref smi_seq_item seq_item);
    extern function void check_snp_req(const ref smi_seq_item seq_item);
    extern function void check_str_req(const ref smi_seq_item seq_item);
    extern function void check_mrd_req(const ref smi_seq_item seq_item);
    extern function void check_rbr_req(const ref smi_seq_item seq_item);
   
    extern function void predict_dm_cmt_req();
    extern function void predict_mrd_req_stash_ops();
    extern function void predict_mrd_req();
    extern function void predict_zero_mrd_credits();
    extern function void predict_rbr_snp_req(int idx=0);
    extern function void predict_rbr_snp_req_stash_ops(int idx=0);
    extern function void predict_snp_req_rd_stash_ops();
    extern function void predict_rbr_snp_req_recall_ops(int recall_qos);
    extern function void predict_str_req();
    extern function void predict_rb_rsv_rls_req();
    extern function void predict_rb_rsp();
    extern function void repredict_snp_mrd_reqs();
    extern function bit smi_snprsp_maps_to_req(const ref smi_seq_item seq_item);
    extern function bit requestor_dirlkp_state_is_SC(const ref dm_seq_item lkprsp);
    extern function bit requestor_dirlkp_state_is_valid(const ref dm_seq_item lkprsp);
    extern function bit is_exclusive_operation(output bit ex_load, output bit ex_store);
    extern function void save_attid_for_rd_stash_ops(const ref dm_seq_item item);
    extern function bit get_aggregated_snprsp_cmstatus();
endclass    

//constructor
function dce_scb_txn::new(string name = "dce_scb_txn");
    super.new(name);
    m_txn_cntr++;
    m_txn_id               = m_txn_cntr;
    t_cmdreq               = 0;
    t_mrdrsp               = 0;
    t_last_snprsp          = 0;
    m_objection_dropped    = 0;
    m_internal_rbr_release = 0;
    m_states["cmdupdrsp"]  = new("cmdupdrsp");
    m_states["sb_cmdrsp"]  = new("sb_cmdrsp");
    m_states["snpreq"]     = new("snpreq");
    m_states["snprsp"]     = new("snprsp");
    m_states["strreq"]     = new("strreq");
    m_states["strrsp"]     = new("strrsp");
    m_states["mrdreq"]     = new("mrdreq");
    m_states["mrdrsp"]     = new("mrdrsp");
    m_states["rbrreq"]     = new("rbrreq");
    m_states["rbrrsp"]     = new("rbrrsp");
    m_states["rbureq"]     = new("rbureq");
    m_states["rbursp"]     = new("rbursp");
    m_states["dirreq"]     = new("dirreq");
    m_states["dirrsp"]     = new("dirrsp");
    m_states["sysreq"]     = new("sysreq");
    m_states["sysrsp"]     = new("sysrsp");
    m_states["sb_sysrsp"]  = new("sb_sysrsp");

    // YRAMASAMY-FIX/HACK
    // setting the rbureq and rbursp to be complete all the time as it is not supported in 3.6
    m_states["rbureq"].set_complete();
    m_states["rbursp"].set_complete();
endfunction: new

//assign ncore credits check handle
function void dce_scb_txn::assign_parameters_and_handles(const ref dce_credits_check credits_i, bit dm_chks_en_i, bit up_chks_en_i, bit mpf1_tgtid_chks_en_i);
    this.m_credits            = credits_i;
    //this.m_dm_chks_en         = dm_chks_en_i;
    //this.m_up_chks_en         = up_chks_en_i;
    //this.m_mpf1_tgtid_chks_en = mpf1_tgtid_chks_en_i;
    
    //always enable mpf1_tgtid_chks, up_chks
    this.m_mpf1_tgtid_chks_en = 1;
    this.m_up_chks_en         = 1;
    this.m_dm_chks_en         = 1;
    this.m_disable_check      = 1;

    if ($test$plusargs("disable_dm_chks")) begin
        this.m_dm_chks_en         = 0;
    end 

endfunction: assign_parameters_and_handles

//method preloads static data structures. Refer to table 67, scetion 6.2.1
function void dce_scb_txn::preload_static_data_structures();
endfunction

//*******************************************************************************************
function string dce_scb_txn::print_txn(verbose = 1);
    bit [WSMIADDR - 1 : 0] offset_aligned_addr; 
    bit [31:0]             set_index;
    int                    discard;
    string                 s, status[time][string];
    eMsgUPD                upd_type;

    if (m_req_type inside {CMD_REQ, UPD_REQ}) begin //incoming SMI txn
        if (m_initcmdupd_req_pkt.isCmdMsg()) begin
            $cast(m_cmd_type, m_initcmdupd_req_pkt.smi_msg_type);
        end else if(m_initcmdupd_req_pkt.isUpdMsg()) begin
            $cast(upd_type, m_initcmdupd_req_pkt.smi_msg_type);
        end

        $sformat(s, "DCE_UID:%0d: %0s_REQ: %0s (txnId: %1d) SMI_Time:%0t CONCMux_Time:%0t DM_Time:%0t RTL_Dealloc:%1d Exmon:%s Internal_Release:%1b ObjDrop:%1b %0s %s addr:0x%0h ns:%p %s %s %s %s %s\n",
                     m_txn_id,
                     m_initcmdupd_req_pkt.isCmdMsg() ? "CMD" : "UPD",
                     s, 
                     m_txn_id,
                     m_initcmdupd_req_pkt.t_smi_ndp_valid,
                     t_conc_mux_cmdreq,
                     t_dm_cmdreq,
                     rtl_deallocated,
                     m_exmon_type.name(),
                     m_internal_rbr_release,
                     m_objection_dropped,
                     get_name(), 
                     m_initcmdupd_req_pkt.isCmdMsg() ? $psprintf("%p", m_cmd_type) : $psprintf("%p", upd_type),
                     m_initcmdupd_req_pkt.smi_addr, 
                     m_initcmdupd_req_pkt.smi_ns, 
                     m_initcmdupd_req_pkt.isCmdMsg() ? $psprintf("att_status:%s", m_attid_status) : "",
                     m_initcmdupd_req_pkt.isCmdMsg() ? ((m_attid_status == ATTID_IS_INACTIVE) ? "" : ((m_attid_status == ATTID_IS_RELEASED) ? $psprintf("attid:0x%0h attid_release_cycle:%0d", m_attid, m_attid_release_cycle) : $psprintf("attid:0x%0h", m_attid))) : "",
                     m_initcmdupd_req_pkt.isCmdMsg() ? $psprintf("rbid_status:%s", m_rbid_status) : "",
                     m_initcmdupd_req_pkt.isCmdMsg() ? ((m_rbid_status == RBID_RESERVED) ? $psprintf("rbid: 0x%0h (g:%0b)dmiid: 0x%0h", m_rbid, m_garbage_dmiid, m_dmiid) : $psprintf("dmiid: 0x%0h", m_dmiid)) : "",
                     m_initcmdupd_req_pkt.isCmdMsg() ? $psprintf("smi_msg_pri:0x%0h", m_initcmdupd_req_pkt.smi_msg_pri) : ""
                );
    end else if (m_req_type == REC_REQ) begin
        $sformat(s, "DCE_UID:%0d: REC_REQ: %0s Time:%0t RTL_Dealloc:%1d %0s %0s %0s %0s %0s %0s\n",
                     m_txn_id,
                     s, 
                     m_dm_pktq[0].m_time,
                     rtl_deallocated,
                     get_name(), 
                     m_dm_pktq[0].convert2string(),
                     $psprintf("att_status:%s", m_attid_status),
                     (m_attid_status == ATTID_IS_INACTIVE) ? "" : ((m_attid_status == ATTID_IS_RELEASED) ? $psprintf("attid:0x%0h attid_release_cycle:%0d", m_attid, m_attid_release_cycle) : $psprintf("attid:0x%0h", m_attid)),
                     $psprintf("rbid_status:%s", m_rbid_status),
                     (m_rbid_status == RBID_RESERVED) ? $psprintf("rbid: 0x%0h (g:%0b)dmiid: 0x%0h", m_rbid, m_garbage_dmiid, m_dmiid) : $psprintf("(g:%0b)dmiid: 0x%0h", m_garbage_dmiid, m_dmiid)
                );
    end else if (m_req_type == SYSCO_REQ) begin
        $sformat(s,"DCE_UID:%0d: SYS_REQ: %s ReqType:%s.%s SMI_TIME: %0t, agent_id = %d\n",m_txn_id, s,m_req_type,((m_initsys_co_req_pkt.smi_sysreq_op inside {1,2}) ? ((m_initsys_co_req_pkt.smi_sysreq_op == 1) ? $psprintf("ATTACH") : $psprintf("DETACH")) : " "),m_initsys_co_req_pkt.t_smi_ndp_valid,m_initsys_co_req_pkt.smi_src_ncore_unit_id);
    
    end
   
    foreach(sf_set_index[i]) begin
        $sformat(s, "%0s SF%0d: 0x%0h\t", s, i, sf_set_index[i]);
    end

    $sformat(s, "%s\n", s);
    if (verbose == 1) begin
        foreach(m_states[key]) begin
          if (m_states[key].is_complete() == 0) begin
             $sformat(s, "%s %s:", s, key);
             $sformat(s, "%s %s\n", s, m_states[key].convert2string());
          end 
        end
        foreach(m_states[key]) begin
          if (m_states[key].is_complete() == 1) begin
             $sformat(s, "%s %s:", s, key);
             $sformat(s, "%s %s\n", s, m_states[key].convert2string());
          end 
        end
    end

    return(s);
endfunction: print_txn

//*******************************************************************************************
function string dce_scb_txn::convert_snps2string();
    string s;
    smi_seq_item snp_rspq[$];

    if(m_expsnp_req_pktq.size() == 0) begin
        $sformat(s, "%s SnpReq: NO SNOOPS SENT", s);
    end else begin
        foreach(m_expsnp_req_pktq[idx]) begin
            $sformat(s, "%s SnpReq: %s", s, m_expsnp_req_pktq[idx].convert2string());

            snp_rspq = m_drvsnp_rsp_pktq.find(item) with (
                item.smi_msg_id == m_expsnp_req_pktq[idx].smi_msg_id);

            if(snp_rspq.size() == 0) 
                $sformat(s, "%s SnpRsp: NOT RECEIVED", s);
            else
                $sformat(s, "%s SnpRsp: %s", s, snp_rspq[0].convert2string());
        end
    end

    return(s);
endfunction: convert_snps2string

//*****************************************************************************************
function void dce_scb_txn::save_recall_req(int recall_qos, const ref dm_seq_item recreq);
    int discard;

    m_req_type      = REC_REQ;   
    m_attid_status  = ATTID_IS_ACTIVE; // CONC-12425 related update as for recall the att entry gets active soon after starting it
    m_rbid_status   = RBID_UNRESERVED;
    m_exmon_type    = EXMON_NONE;
    m_attid         = recreq.m_attid;
    rtl_deallocated = 0;
    m_dmiid         = addrMgrConst::map_addr2dmi_or_dii(recreq.m_addr, discard);
    m_dm_pktq.push_back(recreq);

    //need this to prevent access to null reference
    m_initcmdupd_req_pkt = new("dummy");
    m_initsys_co_req_pkt = new("dummy");

    //set completes for all states that do no make sense for recall ops
    m_states["cmdupdrsp"].set_complete();
    m_states["sb_cmdrsp"].set_complete();
    
    m_states["dirreq"].set_complete();
    m_states["dirrsp"].set_complete();
    
    m_states["strreq"].set_complete();
    m_states["strrsp"].set_complete();
    
    m_states["mrdreq"].set_complete();
    m_states["mrdrsp"].set_complete();
    m_states["sysreq"].set_complete();
    m_states["sysrsp"].set_complete();
    m_states["sb_sysrsp"].set_complete();
    if($test$plusargs("k_csr_seq=dce_csr_no_address_hit_seq") || $test$plusargs("k_csr_seq=dce_csr_address_region_overlap_seq")) begin
        m_states["snpreq"].set_complete();
        m_states["snprsp"].set_complete();
        m_states["rbrreq"].set_complete();
        m_states["rbrrsp"].set_complete();
        m_states["rbureq"].set_complete();
        m_states["rbursp"].set_complete();
        return;
    end 
    predict_rbr_snp_req_recall_ops(recall_qos);
endfunction: save_recall_req

//*****************************************************************************************
function void dce_scb_txn::save_cmdupd_req(const ref smi_seq_item seq_item);
    dm_seq_item coh_req, upd_req, lkp_rsp; 
    int discard;
    bit ign;
    bit [WSMIADDR - 1 : 0] offset_aligned_addr; 

    void'($cast(m_initcmdupd_req_pkt, seq_item.clone()));
    m_initsys_co_req_pkt = new("dummy");

    //check cmdupd_req pkt -- used to catch full sys bug of illegal CMDreq to DCE block. 
    check_cmdupd_req(m_initcmdupd_req_pkt);

    //populate initial cmdupd_req_pkt
    if (m_initcmdupd_req_pkt.isCmdMsg()) begin 
        m_req_type = CMD_REQ;
        rtl_deallocated = 0;
        $cast(m_cmd_type, m_initcmdupd_req_pkt.smi_msg_type);
        void'(this.is_exclusive_operation(ex_load, ex_store));
    end else begin
        m_req_type = UPD_REQ;
        rtl_deallocated = 1; // YRAMASAMY: because no att allocation happens
    end
    m_initcmdupd_req_pkt.t_smi_ndp_valid = $time;
    t_dm_cmdreq   = 0;
    m_iid_cacheid = addrMgrConst::get_cache_id(m_initcmdupd_req_pkt.smi_src_ncore_unit_id); 
    m_sid_cacheid = addrMgrConst::get_cache_id(m_initcmdupd_req_pkt.smi_mpf1_stash_nid); 
    m_dmiid = m_initcmdupd_req_pkt.smi_dest_id;

    for(int i = 0; i < addrMgrConst::NUM_SF; i++) begin
        if (m_initcmdupd_req_pkt != null)
            offset_aligned_addr = m_dirm_mgr.offset_align_cacheline(m_initcmdupd_req_pkt.smi_addr);
        else 
            offset_aligned_addr = m_dirm_mgr.offset_align_cacheline(m_dm_pktq[0].m_addr);
        sf_set_index[i]         = m_dirm_mgr.set_index_for_cacheline(offset_aligned_addr, i);
    end

    //rbid initialization
    m_rbid_status = RBID_UNRESERVED;

    //create expected cmdupd_rsp_pkt 
    //#Check.DCE.CmdUpdRsp
    m_states["cmdupdrsp"].set_expect();
    if (m_initcmdupd_req_pkt.isCmdMsg())
        m_states["sb_cmdrsp"].set_expect();
    else
        m_states["sb_cmdrsp"].set_complete();

    m_states["sysreq"].set_complete();
    m_states["sysrsp"].set_complete();
    m_states["sb_sysrsp"].set_complete();

    m_expcmdupd_rsp_pkt = new("cmdupdrsp");
    m_expcmdupd_rsp_pkt.t_smi_ndp_valid = 0;

    //#Check.DCE.CmdRsp.InitiatorId
    m_expcmdupd_rsp_pkt.construct_ccmdrsp(
                                        .smi_targ_ncore_unit_id (m_initcmdupd_req_pkt.smi_src_ncore_unit_id),  //#Check.DCE.CmdUpdRsp.TargId
                                        .smi_src_ncore_unit_id  (m_initcmdupd_req_pkt.smi_targ_ncore_unit_id), //#Check.DCE.CmdUpdRsp.SrcId
                                        .smi_msg_type           (m_initcmdupd_req_pkt.isCmdMsg() ? C_CMD_RSP : UPD_RSP),
                                        .smi_msg_id             ('h0),
                                        .smi_msg_tier           ('h0),
                                        .smi_steer              ('h0),
                                        .smi_msg_pri            (m_initcmdupd_req_pkt.smi_msg_pri),
                                        .smi_msg_qos            ('h0),
                                        .smi_tm                 (m_initcmdupd_req_pkt.smi_tm), //#Check.DCE.CmdUpdRsp.rmsgid
                                        .smi_rmsg_id            (m_initcmdupd_req_pkt.smi_msg_id), //#Check.DCE.CmdUpdRsp.rmsgid
                                        .smi_msg_err            ('h0),
                                        .smi_cmstatus           ('h0)  //#Check.DCE.CmdUpdRsp.Cmstatus
                                        );

        if (m_initcmdupd_req_pkt.isCmdMsg()) begin
        //setup expect for directory request
        m_states["dirreq"].set_expect();
        coh_req = new("dm_coh_req");
        coh_req.m_access_type = DM_CMD_REQ;
        coh_req.m_iid         = m_initcmdupd_req_pkt.smi_src_id;
        coh_req.m_addr        = m_initcmdupd_req_pkt.smi_addr;
        coh_req.m_ns          = m_initcmdupd_req_pkt.smi_ns;
            
        $cast(coh_req.m_type, m_initcmdupd_req_pkt.smi_msg_type);
        
        if (dce_goldenref_model::is_master_allocating_req(coh_req.m_type)) begin
            coh_req.m_alloc = 1;
            coh_req.m_filter_num  = addrMgrConst::get_snoopfilter_id(m_initcmdupd_req_pkt.smi_src_ncore_unit_id);
        end 
        //#Check.DCE.StashReq.Alloc 
        //#Check.DCE.StashReq.Sid
        else if (      dce_goldenref_model::is_stash_request(coh_req.m_type)
                        && m_initcmdupd_req_pkt.smi_mpf1_stash_valid
                        && (m_initcmdupd_req_pkt.smi_mpf1_stash_nid inside {addrMgrConst::stash_nids,addrMgrConst::stash_nids_ace_aius})
                        && addrMgrConst::is_stash_enable(addrMgrConst::agentid_assoc2funitid(m_initcmdupd_req_pkt.smi_mpf1_stash_nid))
                        && snoop_enable_reg_txn[addrMgrConst::agentid_assoc2funitid(m_initcmdupd_req_pkt.smi_mpf1_stash_nid)] == 1) begin
            coh_req.m_alloc = 1;
            coh_req.m_filter_num  =  addrMgrConst::get_snoopfilter_id(m_initcmdupd_req_pkt.smi_mpf1_stash_nid);
            coh_req.m_sid         =  m_initcmdupd_req_pkt.smi_mpf1_stash_nid << WSMINCOREPORTID;
        end else begin
            coh_req.m_alloc = 0;
            coh_req.m_filter_num = 0;
        end

        m_dm_pktq.push_back(coh_req);
    end else begin
        //#Check.DCE.UpdReq.DMUpdReq
        m_states["dirreq"].set_expect();
        upd_req = new("dm_upd_req");
        upd_req.m_access_type = DM_UPD_REQ;
        upd_req.m_iid         = (m_initcmdupd_req_pkt.smi_src_id >> WSMINCOREPORTID) << WSMINCOREPORTID;
        upd_req.m_addr        = m_initcmdupd_req_pkt.smi_addr;
        upd_req.m_ns          = m_initcmdupd_req_pkt.smi_ns;
        m_dm_pktq.push_back(upd_req);
    end 
  
    if (m_initcmdupd_req_pkt.isUpdMsg()) begin
        //set completes for all other DM & TM transactions for update requests.
        m_states["dirrsp"].set_complete();

        m_states["strreq"].set_complete();
        m_states["strrsp"].set_complete();

        m_states["snpreq"].set_complete();
        m_states["snprsp"].set_complete();
        
        m_states["mrdreq"].set_complete();
        m_states["mrdrsp"].set_complete();
        
        m_states["rbrreq"].set_complete();
        // CLEANUP
        m_states["rbrrsp"].set_complete();

        m_states["rbureq"].set_complete();
        m_states["rbursp"].set_complete();
    end

endfunction: save_cmdupd_req

//**************************************************************************
function void dce_scb_txn::check_cmdupd_req(const ref smi_seq_item seq_item);
    int dummy_load,dummy_store;

    if (dce_goldenref_model::is_stash_request(m_cmd_type)) begin
        if (seq_item.smi_mpf1_stash_valid && (seq_item.smi_mpf1_stash_nid == seq_item.smi_src_ncore_unit_id))
            `uvm_error("DCE SCB ERROR", "DCE gets an invalid stash command. Check stash src_id and mpf1 stash params - stash master_id == stash target_id");
        if (seq_item.smi_mpf1_stash_valid && !(seq_item.smi_mpf1_stash_nid inside {addrMgrConst::funit_ids}))
            `uvm_error("DCE SCB ERROR", "DCE gets an invalid stash command. Check stash src_id and mpf1 stash params - stash target_id != funit_id of any agents in the system");
    end

    if((seq_item.smi_msg_type inside {CMD_RD_VLD, CMD_RD_CLN, CMD_RD_NOT_SHD,CMD_CLN_UNQ}) && (m_initcmdupd_req_pkt.smi_es == 1)) begin
        if(seq_item.smi_mpf2_flowid_valid == 0) begin
            `uvm_error("DCE SCB ERROR",$psprintf("smi_mpf2_flowid_valid = %p for an exclusive operation",seq_item.smi_mpf2_flowid_valid))
        end
    end 
endfunction: check_cmdupd_req


//**************************************************************************
function void dce_scb_txn::check_cmdupd_rsp(const ref smi_seq_item seq_item);

    m_expcmdupd_rsp_pkt.smi_ndp_len = w_UPD_REQ_NDP;

    m_expcmdupd_rsp_pkt.compare(seq_item);
    m_expcmdupd_rsp_pkt.copy(seq_item);
    m_expcmdupd_rsp_pkt.t_smi_ndp_valid = $time;

endfunction: check_cmdupd_rsp

//**************************************************************************
function void dce_scb_txn::check_dm_req_txn(const ref dm_seq_item item);
    dm_seq_item dm_rsp; 
    dm_seq_item lkprsp_pktq[$]; 
    bit [addrMgrConst::NUM_CACHES-1:0] ov;
    bit [addrMgrConst::NUM_CACHES-1:0] sv;
    int evict_wayq[$], hit_wayq[$];
    bit [WSFWAYVEC-1:0] way_vec;
    bit [addrMgrConst::NUM_SF-1:0] eviction_needed_sfvec;
    bit [addrMgrConst::NUM_SF-1:0] vbhit_sfvec, tfhit_sfvec;
  
    //if ((item.m_attid_state == SLEEP) || SNPrsp_data_or_address_error_in_cmstatus) begin
    if ((item.m_attid_state == SLEEP)) begin
        //Skip COH_REQ checks since TM is not required to drive correct values. The DM request will come back.
        //If an error CMstatus was received on SNPrsp, the CMT_REQ is garbage. SO skip checks.
    end else begin
        if (item.m_access_type == DM_CMT_REQ) begin 
            lkprsp_pktq = m_dm_pktq.find(item) with (item.m_access_type == DM_LKP_RSP);

            foreach(m_dm_pktq[i]) begin
               `uvm_info(get_name(), $psprintf("[%-35s] (txnId: %5d) {%20s} (src: 0x%02h {%s}) (tgt: 0x%02h) (msgId: 0x%02h) (attid : 0x%02h) (rbid: 0x%02h) (addr: 0x%016h) (att: 0x%02h, %20s) (msgId: 0x%02h) (access: %20s) (updStat: %20s) (shareVec: 0x%04h) (owner: %1b/0x%02h) (error: %1d)\n%s", $psprintf("DceScbd-CmtReq-dmReqQChk(%2d/%2d)", i, m_dm_pktq.size()), m_txn_id, m_initcmdupd_req_pkt.type2cmdname(), m_initcmdupd_req_pkt.smi_src_ncore_unit_id, addrMgrConst::get_cache_id_as_string(m_initcmdupd_req_pkt.smi_src_ncore_unit_id), m_initcmdupd_req_pkt.smi_targ_ncore_unit_id, m_initcmdupd_req_pkt.smi_msg_id, m_attid, m_rbid, m_dm_pktq[i].m_addr, m_dm_pktq[i].m_attid, m_dm_pktq[i].m_attid_state.name(), m_dm_pktq[i].m_msg_id, m_dm_pktq[i].m_access_type.name(), m_dm_pktq[i].m_status.name(), m_dm_pktq[i].m_sharer_vec, m_dm_pktq[i].m_owner_val, m_dm_pktq[i].m_owner_num, lkprsp_pktq[0].m_error, m_dm_pktq[i].convert2string()), UVM_LOW);
            end

            if (lkprsp_pktq[0].m_error == 0) begin 
                //#Check.DCE.DM.WrAddrNS
                //#Check.DCE.DM.WrWayVec
                //#Check.DCE.DM.WrInfo
                //#Check.DCE.DM.WrChangeVec
                m_dm_pktq[m_dm_pktq.size() - 1].compare(item);
            end
        end else begin
            if(dce_goldenref_model::is_stash_request(m_cmd_type)) begin // Adding this to check alloc bit
                if (    m_initcmdupd_req_pkt.smi_mpf1_stash_valid
                    && (m_initcmdupd_req_pkt.smi_mpf1_stash_nid inside {addrMgrConst::stash_nids,addrMgrConst::stash_nids_ace_aius})
                    && addrMgrConst::is_stash_enable(addrMgrConst::agentid_assoc2funitid(m_initcmdupd_req_pkt.smi_mpf1_stash_nid))
                    && item.stash_target_id_detached == 0) begin
                        m_dm_pktq[m_dm_pktq.size() - 1].m_alloc = 1;
                            m_dm_pktq[m_dm_pktq.size() - 1].m_filter_num  =  addrMgrConst::get_snoopfilter_id(m_initcmdupd_req_pkt.smi_mpf1_stash_nid);
                            m_dm_pktq[m_dm_pktq.size() - 1].m_sid         =  m_initcmdupd_req_pkt.smi_mpf1_stash_nid << WSMINCOREPORTID;
                end else begin
                        m_dm_pktq[m_dm_pktq.size() - 1].m_alloc = 0;
                        m_dm_pktq[m_dm_pktq.size() - 1].m_filter_num = 0;
                end
            end
            m_dm_pktq[m_dm_pktq.size() - 1].compare(item);
        end 
    end
    
    m_dm_pktq[m_dm_pktq.size() - 1].copy(item);

    //set expect for directory response
    if (item.m_access_type == DM_CMD_REQ) begin
//#Check.DCE.DM.CmdReqAddrNS
//#Check.DCE.DM.CmdReqAlloc
        if (m_dm_chks_en) begin 
            m_dirm_mgr.lookup_request({item.m_ns, item.m_addr}, (((dce_goldenref_model::is_stash_request(m_cmd_type)) ? item.m_sid : item.m_iid )>> WSMINCOREPORTID), item.m_alloc, item.m_filter_num, item.m_busy_vec, item.m_busy_vec_dv, item.m_pipelined_req_sfvec, ov, sv, way_vec, eviction_needed_sfvec, evict_wayq, vbhit_sfvec, tfhit_sfvec, hit_wayq); 
        end
        
        m_states["dirrsp"].set_expect();
        dm_rsp = new("dm_lkp_rsp");

        dm_rsp.m_access_type = DM_LKP_RSP;
        dm_rsp.m_alloc = item.m_alloc;
        dm_rsp.m_addr = item.m_addr;
        dm_rsp.m_ns   = item.m_ns;
        dm_rsp.m_type = item.m_type;
        dm_rsp.m_alloc = item.m_alloc;

        //Post-processing olv and slv for dce_scb to consume
        if ($onehot(ov) == 1) begin
            dm_rsp.m_owner_val = 1;
            dm_rsp.m_owner_num = 0;
            while (ov != 0) begin
                if ((ov & 'h1) == 0) begin
                    ov = ov >> 1;
                    dm_rsp.m_owner_num++;
                end else begin
                    break;
                end
            end
            dm_rsp.m_sharer_vec = sv | (1 << dm_rsp.m_owner_num);
        end else begin
            dm_rsp.m_sharer_vec = sv;
        end
        dm_rsp.m_way_vec_or_mask       = way_vec;
        //dm_rsp.m_vhit                  = vb_hit;
        // Remove CONC-5362 //dm_rsp.m_vhit                  = (vbhit_sfvec != 0) ? 1 : 0;
        dm_rsp.m_wr_required           = (vbhit_sfvec != 0) || (eviction_needed_sfvec != 0) || (item.m_alloc & !item.m_cancel) ? 1 : 0;
        dm_rsp.m_predicted_eviction    = (eviction_needed_sfvec != 0) ? 1 : 0;
        dm_rsp.m_eviction_needed_sfvec = eviction_needed_sfvec;
        dm_rsp.m_evict_wayq            = evict_wayq;
        dm_rsp.m_vbhit_sfvec           = vbhit_sfvec;
        dm_rsp.m_tfhit_sfvec           = tfhit_sfvec;
        dm_rsp.m_hit_wayq              = hit_wayq;

        m_dm_pktq.push_back(dm_rsp);

    end else if (item.m_access_type == DM_CMT_REQ) begin
    
        ov = (item.m_owner_val == 1) ? (1 << item.m_owner_num) : 'h0;
        sv = (item.m_owner_val == 1) ? item.m_sharer_vec & ~(1 << item.m_owner_num) : item.m_sharer_vec;

        //update directory information on a cmt_req
        if (m_dm_chks_en) begin 
            m_dirm_mgr.commit_request({m_initcmdupd_req_pkt.smi_ns, m_initcmdupd_req_pkt.smi_addr}, ov, sv, item.m_change_vec, item.m_way_vec_or_mask); 
            m_dirm_mgr.print_all_ways({m_initcmdupd_req_pkt.smi_ns, m_initcmdupd_req_pkt.smi_addr});
        end 

    end
endfunction: check_dm_req_txn

//**************************************************************************
function void dce_scb_txn::predict_dm_cmt_req();
    dm_seq_item lkprsp_pktq[$], cohreq_pktq[$]; 
    smi_seq_item snprsp_owner_pktq[$], snprsp_tgt_pktq[$];
    dm_seq_item cmt_req;
    bit [WSMICMSTATUS - 1:0] aggregate_cmstatus = 0; 
    bit aggregate_dc = 0;
    bit aggregate_rs = 0;
    bit aggregate_rv = 0;
    bit aggregate_dt_dmi = 0;
    bit aggregate_dt_aiu = 0;
    bit dt_done = 0;
    bit snarf;
    bit [addrMgrConst::NUM_CACHES-1:0] change_vec_new;
    bit [addrMgrConst::NUM_CACHES-1:0] change_vec_old;
    int agent_idq[$], requestor_cache_id, snooper_agentid;
    bit snprsp_error;

    lkprsp_pktq = m_dm_pktq.find(item) with (item.m_access_type == DM_LKP_RSP);
    cohreq_pktq = m_dm_pktq.find(item) with (item.m_access_type == DM_CMD_REQ);

    if(credit_zero_err == 1) begin
        return;
    end

    if (lkprsp_pktq.size != 1)
        `uvm_error("DCE_SCB_TXN", $psprintf("Multiple DM LKP_RSP not possible (size: %1d)", lkprsp_pktq.size()));
    
    agent_idq = addrMgrConst::get_agent_ids_assoc2cacheid(lkprsp_pktq[0].m_owner_num);
    if(lkprsp_pktq[0].m_owner_val == 1 && snoop_enable_reg_txn[agent_idq[0]] == 0) begin
        lkprsp_pktq[0].m_owner_val = 0;
        lkprsp_pktq[0].m_owner_num = 0;
    end

    foreach(lkprsp_pktq[0].m_sharer_vec[x]) begin
        agent_idq = addrMgrConst::get_agent_ids_assoc2cacheid(x);
        if(lkprsp_pktq[0].m_sharer_vec[x] == 1 && snoop_enable_reg_txn[agent_idq[0]] == 0) begin
            lkprsp_pktq[0].m_sharer_vec[x] = 0;
        end
    end
    
    if (lkprsp_pktq[0].is_dm_miss() && !dce_goldenref_model::is_stash_request(m_cmd_type)) begin
        if (cohreq_pktq[cohreq_pktq.size() - 1].m_alloc) begin
            m_states["dirreq"].set_expect();
            cmt_req = new("cmt_req");
            cmt_req.m_access_type     = DM_CMT_REQ;
            cmt_req.m_way_vec_or_mask = lkprsp_pktq[0].m_way_vec_or_mask;
            cmt_req.m_addr            = m_initcmdupd_req_pkt.smi_addr;
            cmt_req.m_ns              = m_initcmdupd_req_pkt.smi_ns;

            if ((ex_store == 1) && (m_exmon_status == EXMON_FAIL)) begin
                cmt_req.m_owner_val       = lkprsp_pktq[0].m_owner_val;
                cmt_req.m_owner_num       = lkprsp_pktq[0].m_owner_num;
                cmt_req.m_sharer_vec      = lkprsp_pktq[0].m_sharer_vec;
                cmt_req.m_change_vec      = lkprsp_pktq[0].m_sharer_vec;
            end else begin 
                cmt_req.m_owner_val       = 1;
                cmt_req.m_owner_num       = m_iid_cacheid;
                cmt_req.m_sharer_vec      = 1 << m_iid_cacheid;
                cmt_req.m_change_vec      = 1 << m_iid_cacheid;
            end 
            m_dm_pktq.push_back(cmt_req);
           `uvm_info(get_name(), $psprintf("[%-35s] (txnId: %5d) {%20s} (src: 0x%02h {%s}) (tgt: 0x%02h) (msgId: 0x%02h) (attid : 0x%02h) (rbid: 0x%02h) (addr: 0x%016h) (att: 0x%02h, %20s) (msgId: 0x%02h) (access: %20s) (updStat: %20s) (shareVec: 0x%04h) (owner: %1b/0x%02h)\n%s", "DceScbd-CmtPred-1", m_txn_id, m_initcmdupd_req_pkt.type2cmdname(), m_initcmdupd_req_pkt.smi_src_ncore_unit_id, addrMgrConst::get_cache_id_as_string(m_initcmdupd_req_pkt.smi_src_ncore_unit_id), m_initcmdupd_req_pkt.smi_targ_ncore_unit_id, m_initcmdupd_req_pkt.smi_msg_id, m_attid, m_rbid, cmt_req.m_addr, cmt_req.m_attid, cmt_req.m_attid_state.name(), cmt_req.m_msg_id, cmt_req.m_access_type.name(), cmt_req.m_status.name(), cmt_req.m_sharer_vec, cmt_req.m_owner_val, cmt_req.m_owner_num, cmt_req.convert2string()), UVM_MEDIUM);
        end
        else if(lkprsp_pktq[0].m_sharer_vec != dm_lkprsp.m_sharer_vec) begin
            m_states["dirreq"].set_expect();
            cmt_req = new("cmt_req");
            cmt_req.m_access_type     = DM_CMT_REQ;
            cmt_req.m_way_vec_or_mask = lkprsp_pktq[0].m_way_vec_or_mask;
            cmt_req.m_addr            = m_initcmdupd_req_pkt.smi_addr;
            cmt_req.m_ns              = m_initcmdupd_req_pkt.smi_ns;
            cmt_req.m_owner_val       = lkprsp_pktq[0].m_owner_val;
            cmt_req.m_owner_num       = lkprsp_pktq[0].m_owner_num;
            cmt_req.m_sharer_vec      = lkprsp_pktq[0].m_sharer_vec;
            cmt_req.m_change_vec      = dm_lkprsp.m_sharer_vec;
            m_dm_pktq.push_back(cmt_req);       
           `uvm_info(get_name(), $psprintf("[%-35s] (txnId: %5d) {%20s} (src: 0x%02h {%s}) (tgt: 0x%02h) (msgId: 0x%02h) (attid : 0x%02h) (rbid: 0x%02h) (addr: 0x%016h) (att: 0x%02h, %20s) (msgId: 0x%02h) (access: %20s) (updStat: %20s) (shareVec: 0x%04h) (owner: %1b/0x%02h)\n%s", "DceScbd-CmtPred-2", m_txn_id, m_initcmdupd_req_pkt.type2cmdname(), m_initcmdupd_req_pkt.smi_src_ncore_unit_id, addrMgrConst::get_cache_id_as_string(m_initcmdupd_req_pkt.smi_src_ncore_unit_id), m_initcmdupd_req_pkt.smi_targ_ncore_unit_id, m_initcmdupd_req_pkt.smi_msg_id, m_attid, m_rbid, cmt_req.m_addr, cmt_req.m_attid, cmt_req.m_attid_state.name(), cmt_req.m_msg_id, cmt_req.m_access_type.name(), cmt_req.m_status.name(), cmt_req.m_sharer_vec, cmt_req.m_owner_val, cmt_req.m_owner_num, cmt_req.convert2string()), UVM_MEDIUM);
        end

        if (cohreq_pktq[cohreq_pktq.size - 1].m_alloc && m_states["dirreq"].is_complete() && !dce_goldenref_model::is_stash_request(m_cmd_type)) begin
            `uvm_error("DCE SCB", "Commit_req not predicted for master_alloc txn");
        end
    end else if (    !lkprsp_pktq[0].is_dm_miss() 
                  && (m_states["snpreq"].get_valid_count() == 0) 
                  &&  m_states["snpreq"].is_complete() 
                  &&  m_states["snprsp"].is_complete()
                ) begin //dm_hit with agent_id already valid, no snps required, write needed to complete the swap between vc and tag_entry if applicable
    
        if( !lkprsp_pktq[0].m_wr_required && // For dm_hit scenario m_wr_required reflects the VB_hit(old m_vhit)
            (   (ex_store && (m_exmon_status == EXMON_FAIL))
             || (    (m_cmd_type inside {
                                       CMD_WR_CLN_FULL,
                                       CMD_WR_BK_PTL,
                                       CMD_WR_BK_FULL,
                                       CMD_WR_EVICT,
                                       CMD_EVICT,
                                       CMD_RD_ATM,
                                       CMD_WR_ATM,
                                       CMD_SW_ATM,
                                       CMD_CMP_ATM})
                  && ( (    (lkprsp_pktq[0].m_sharer_vec | (1 << m_iid_cacheid)) != lkprsp_pktq[0].m_sharer_vec)
                         || (m_iid_cacheid == -1))) //Skip dir cmt_req prediction if requestor is not valid 
             || ((m_cmd_type == CMD_RD_NITC) && 
                ((m_initcmdupd_req_pkt.smi_tof == 2) && (m_iid_cacheid != -1) && !(requestor_dirlkp_state_is_SC(lkprsp_pktq[0]) && $onehot(lkprsp_pktq[0].m_sharer_vec))) //CmdRdNITC from ACE-master with requestor only valid and in SC, do not skip, els skip
                || !requestor_dirlkp_state_is_valid(lkprsp_pktq[0]) //CmdRdNITC from any-master and requestor is invalid skip dir update
                )
             || (    (m_cmd_type == CMD_WR_CLN_FULL) && 
                     (    (lkprsp_pktq[0].m_owner_val && (m_iid_cacheid == lkprsp_pktq[0].m_owner_num) && $onehot(lkprsp_pktq[0].m_sharer_vec)) //A WR_CLN_FULL from owner(UC, UD) with no other sharers doesnt need SF update.
                       || requestor_dirlkp_state_is_SC(lkprsp_pktq[0])))
             || (m_cmd_type inside {CMD_WR_CLN_PTL, CMD_CLN_VLD, CMD_CLN_SH_PER}) //Always skip CMT_REQ. See attachment in bug 4805 for WR_CLN_PTL.
             || (dce_goldenref_model::is_stash_request(m_cmd_type) && (cohreq_pktq[cohreq_pktq.size - 1].m_alloc == 0) && !requestor_dirlkp_state_is_valid(lkprsp_pktq[0])) //rd stash with 'no tgt identified' does not issue snps/rbr so is a no-op 
             || ((m_cmd_type inside {CMD_WR_UNQ_FULL, CMD_WR_UNQ_PTL}) && (m_initcmdupd_req_pkt.smi_tof == 2) && (m_iid_cacheid != -1) && (m_initcmdupd_req_pkt.smi_mpf1_awunique == 0) && requestor_dirlkp_state_is_SC(lkprsp_pktq[0])) //WrUnqFull/Ptl from ACE that hits in dir as SC, and AWUNIQUE=0
           )
          ) begin

            if(lkprsp_pktq[0].m_sharer_vec != dm_lkprsp.m_sharer_vec && !dce_goldenref_model::is_stash_request(m_cmd_type)) begin
                m_states["dirreq"].set_expect();
                        cmt_req = new("cmt_req");
                        cmt_req.m_access_type = DM_CMT_REQ;
                        cmt_req.m_way_vec_or_mask = lkprsp_pktq[0].m_way_vec_or_mask;
                        cmt_req.m_addr            = m_initcmdupd_req_pkt.smi_addr;
                        cmt_req.m_ns              = m_initcmdupd_req_pkt.smi_ns;
                cmt_req.m_owner_val   = lkprsp_pktq[0].m_owner_val;
                cmt_req.m_owner_num   = lkprsp_pktq[0].m_owner_num;
                cmt_req.m_sharer_vec      = lkprsp_pktq[0].m_sharer_vec;
                cmt_req.m_change_vec      = dm_lkprsp.m_sharer_vec ^ lkprsp_pktq[0].m_sharer_vec;
                m_dm_pktq.push_back(cmt_req);
               `uvm_info(get_name(), $psprintf("[%-35s] (txnId: %5d) {%20s} (src: 0x%02h {%s}) (tgt: 0x%02h) (msgId: 0x%02h) (attid : 0x%02h) (rbid: 0x%02h) (addr: 0x%016h) (att: 0x%02h, %20s) (msgId: 0x%02h) (access: %20s) (updStat: %20s) (shareVec: 0x%04h) (owner: %1b/0x%02h)\n%s", "DceScbd-CmtPred-3", m_txn_id, m_initcmdupd_req_pkt.type2cmdname(), m_initcmdupd_req_pkt.smi_src_ncore_unit_id, addrMgrConst::get_cache_id_as_string(m_initcmdupd_req_pkt.smi_src_ncore_unit_id), m_initcmdupd_req_pkt.smi_targ_ncore_unit_id, m_initcmdupd_req_pkt.smi_msg_id, m_attid, m_rbid, cmt_req.m_addr, cmt_req.m_attid, cmt_req.m_attid_state.name(), cmt_req.m_msg_id, cmt_req.m_access_type.name(), cmt_req.m_status.name(), cmt_req.m_sharer_vec, cmt_req.m_owner_val, cmt_req.m_owner_num, cmt_req.convert2string()), UVM_MEDIUM);
            end

            //skip prediction
        end else begin //predict dir cmt_req
            m_states["dirreq"].set_expect();
            cmt_req = new("cmt_req");
            cmt_req.m_access_type     = DM_CMT_REQ;
            cmt_req.m_way_vec_or_mask = lkprsp_pktq[0].m_way_vec_or_mask;
            cmt_req.m_addr            = m_initcmdupd_req_pkt.smi_addr;
            cmt_req.m_ns              = m_initcmdupd_req_pkt.smi_ns;
    
            case(m_cmd_type) 
                CMD_RD_NITC:
                            begin
                                //not an ACE ordering model then clear requestor. If ACE ordering model, no state change. Will get to default case.
                                if (m_initcmdupd_req_pkt.smi_tof != 'h2) begin                                  
                                    cmt_req.m_owner_val  = 0;
                                    cmt_req.m_owner_num  = 0;
                                    cmt_req.m_sharer_vec = lkprsp_pktq[0].m_sharer_vec & ~(1 << m_iid_cacheid);
                                    cmt_req.m_change_vec = (lkprsp_pktq[0].m_sharer_vec == ((1 << m_iid_cacheid) | lkprsp_pktq[0].m_sharer_vec)) ? (1 << m_iid_cacheid) : 0;
                                end else if (   (m_iid_cacheid != -1) 
                                             && requestor_dirlkp_state_is_SC(lkprsp_pktq[0]) 
                                             && $onehot(lkprsp_pktq[0].m_sharer_vec)) begin // we get here implies it is ACE requestor and requestor is only valid and in SC so it gets promoted to UC
                                    cmt_req.m_owner_val  = 1;
                                    cmt_req.m_owner_num  = m_iid_cacheid;
                                    cmt_req.m_sharer_vec = lkprsp_pktq[0].m_sharer_vec;
                                    cmt_req.m_change_vec = lkprsp_pktq[0].m_sharer_vec;
                                end else begin //all non-ACE tof=2 like ACE-LITE/ACE-LITE-E
                                    cmt_req.m_owner_val  = lkprsp_pktq[0].m_owner_val;
                                    cmt_req.m_owner_num  = lkprsp_pktq[0].m_owner_num;
                                    cmt_req.m_sharer_vec = lkprsp_pktq[0].m_sharer_vec;
                                    cmt_req.m_change_vec = lkprsp_pktq[0].m_sharer_vec;
                                end
                            end
                CMD_RD_ATM,
                CMD_WR_ATM,
                CMD_SW_ATM,
                CMD_CMP_ATM:
                            begin
                                cmt_req.m_owner_val  = 0;
                                cmt_req.m_owner_num  = 0;
                                cmt_req.m_sharer_vec = lkprsp_pktq[0].m_sharer_vec & ~(1 << m_iid_cacheid);
                                cmt_req.m_change_vec = (lkprsp_pktq[0].m_sharer_vec == ((1 << m_iid_cacheid) | lkprsp_pktq[0].m_sharer_vec)) ? (1 << m_iid_cacheid) : 0;
                            end
                CMD_CLN_INV,
                CMD_MK_INV,
                CMD_RD_NITC_CLN_INV,
                CMD_RD_NITC_MK_INV:
                                begin
                                    cmt_req.m_owner_val  = 0;
                                    cmt_req.m_owner_num  = 0;
                                    cmt_req.m_sharer_vec = 0;
                                    change_vec_old = lkprsp_pktq[0].m_sharer_vec;  
                                    change_vec_new = 0;
                                    cmt_req.m_change_vec = change_vec_old | change_vec_new;
                                end
                CMD_WR_UNQ_PTL,
                CMD_WR_UNQ_FULL:
                                begin
                                    //From ACE master with AWUNQ=0
                                    if ((m_initcmdupd_req_pkt.smi_mpf1_awunique == 0) && //AWUNIQUE == 0
                                        (m_initcmdupd_req_pkt.smi_tof == 2) && 
                                        (m_iid_cacheid != -1)) begin  //ACE master

                                        //ACE master and AWUNIQUE==0, and hits in UC, state transition UC->SC
                                        if ((lkprsp_pktq[0].m_owner_val == 1) && (lkprsp_pktq[0].m_owner_num == m_iid_cacheid)) begin
                                            cmt_req.m_owner_val  = 0;
                                            cmt_req.m_owner_num  = 0;
                                            cmt_req.m_sharer_vec = 1 << m_iid_cacheid;
                                            change_vec_old = lkprsp_pktq[0].m_sharer_vec;  
                                            change_vec_new = 0;
                                            cmt_req.m_change_vec = change_vec_old | change_vec_new;
                                        
                                        //ACE master and AWUNIQUE==0, and hits in SC, ideally skip sf_upd 
                                        //CMT_REQ == LKP_RSP. we get here since wr_required=1.
                                        end else if (requestor_dirlkp_state_is_SC(lkprsp_pktq[0])) begin 
                                            cmt_req.m_owner_val       = lkprsp_pktq[0].m_owner_val;
                                            cmt_req.m_owner_num       = lkprsp_pktq[0].m_owner_num;
                                            cmt_req.m_sharer_vec      = lkprsp_pktq[0].m_sharer_vec;
                                            cmt_req.m_change_vec      = lkprsp_pktq[0].m_sharer_vec;
                                        end 
                                    end else begin
                                        cmt_req.m_owner_val  = 0;
                                        cmt_req.m_owner_num  = 0;
                                        cmt_req.m_sharer_vec = 0;
                                        change_vec_old = lkprsp_pktq[0].m_sharer_vec;  
                                        change_vec_new = 0;
                                        cmt_req.m_change_vec = change_vec_old | change_vec_new;
                                    end
                                end
                CMD_WR_BK_PTL, 
                CMD_WR_BK_FULL,
                CMD_WR_EVICT,
                CMD_EVICT:      begin
                                    //cmt_req.m_owner_val  = (lkprsp_pktq[0].m_owner_val && (lkprsp_pktq[0].m_owner_num == m_iid_cacheid)) ? 'h0 : 'h1;
                                    cmt_req.m_owner_val  =  lkprsp_pktq[0].m_owner_val ? ((lkprsp_pktq[0].m_owner_num == m_iid_cacheid) ? 'h0 : 'h1) : 'h0;
                                    cmt_req.m_owner_num  = (cmt_req.m_owner_val == 1) ? lkprsp_pktq[0].m_owner_num : 'h0;
                                    cmt_req.m_sharer_vec = lkprsp_pktq[0].m_sharer_vec & ~(1 << m_iid_cacheid);
                                    
                                    //change_vec is only set to clear the requestor if valid.
                                    cmt_req.m_change_vec = ((lkprsp_pktq[0].m_sharer_vec | (1 << m_iid_cacheid)) == lkprsp_pktq[0].m_sharer_vec) ? (1 << m_iid_cacheid) : 0;
                    if(dm_lkprsp.m_sharer_vec != lkprsp_pktq[0].m_sharer_vec) begin
                                        cmt_req.m_change_vec = (((lkprsp_pktq[0].m_sharer_vec | (1 << m_iid_cacheid)) == lkprsp_pktq[0].m_sharer_vec) ? (1 << m_iid_cacheid) : 0) | (dm_lkprsp.m_sharer_vec ^ lkprsp_pktq[0].m_sharer_vec);
                    end
                                end
                CMD_WR_CLN_FULL: begin
                                    cmt_req.m_owner_val  = (lkprsp_pktq[0].m_owner_val && (lkprsp_pktq[0].m_owner_num == m_iid_cacheid) && !$onehot(lkprsp_pktq[0].m_sharer_vec)) ? 'h0 : lkprsp_pktq[0].m_owner_val;
                                    cmt_req.m_owner_num  = (cmt_req.m_owner_val == 1) ? lkprsp_pktq[0].m_owner_num : 0;
                                    cmt_req.m_sharer_vec =  lkprsp_pktq[0].m_sharer_vec;

                                    //sf update is only required if requestor hits as SD, and hence needs to downgrade to SC
                                    cmt_req.m_change_vec = (lkprsp_pktq[0].m_owner_val && (lkprsp_pktq[0].m_owner_num == m_iid_cacheid) && !$onehot(lkprsp_pktq[0].m_sharer_vec)) ? (1 << lkprsp_pktq[0].m_owner_num) : 0; 
                                 end 
                CMD_RD_UNQ,
                CMD_MK_UNQ:        begin
                                    cmt_req.m_owner_val  = 1;
                                    cmt_req.m_owner_num  = m_iid_cacheid;
                                    cmt_req.m_sharer_vec = 1 << m_iid_cacheid;
                                    change_vec_old = lkprsp_pktq[0].m_sharer_vec;  
                                    change_vec_new = 1 << m_iid_cacheid;
                                    cmt_req.m_change_vec = change_vec_old | change_vec_new;
                                 end
                CMD_CLN_UNQ:    begin
                                    if ((ex_store == 1) && (m_exmon_status == EXMON_FAIL)) begin
                                        cmt_req.m_owner_val       = lkprsp_pktq[0].m_owner_val;
                                        cmt_req.m_owner_num       = lkprsp_pktq[0].m_owner_num;
                                        cmt_req.m_sharer_vec      = lkprsp_pktq[0].m_sharer_vec;
                                        cmt_req.m_change_vec      = lkprsp_pktq[0].m_sharer_vec;
                                    end else begin
                                        cmt_req.m_owner_val  = 1;
                                        cmt_req.m_owner_num  = m_iid_cacheid;
                                        cmt_req.m_sharer_vec = 1 << m_iid_cacheid;
                                        change_vec_old = lkprsp_pktq[0].m_sharer_vec;  
                                        change_vec_new = 1 << m_iid_cacheid;
                                        cmt_req.m_change_vec = change_vec_old | change_vec_new;
                                    end
                                end
                CMD_RD_VLD,
                CMD_RD_CLN,
                CMD_RD_NOT_SHD:  begin
                                    cmt_req.m_owner_val  = (lkprsp_pktq[0].m_owner_val == 1) ? 1'b1 : ((requestor_dirlkp_state_is_SC(lkprsp_pktq[0]) && $onehot(lkprsp_pktq[0].m_sharer_vec)) ? 1'b1 : 1'b0);
                                    cmt_req.m_owner_num  = (cmt_req.m_owner_val == 1) ? m_iid_cacheid : 0;
                                    cmt_req.m_sharer_vec = lkprsp_pktq[0].m_sharer_vec | (1 << m_iid_cacheid);
                                    cmt_req.m_change_vec = 1 << m_iid_cacheid;
                                 end 

                CMD_LD_CCH_SH,
                CMD_LD_CCH_UNQ,
                CMD_WR_STSH_PTL,
                CMD_WR_STSH_FULL:  begin
                                    cmt_req.m_owner_val  = (lkprsp_pktq[0].m_owner_val && (lkprsp_pktq[0].m_owner_num == m_iid_cacheid)) ? 1'b0 : lkprsp_pktq[0].m_owner_val;
                                    cmt_req.m_owner_num  =  cmt_req.m_owner_val ? lkprsp_pktq[0].m_owner_num : 0;
                                    cmt_req.m_sharer_vec = lkprsp_pktq[0].m_sharer_vec & ~(1 << m_iid_cacheid); //clear requestor
                                    cmt_req.m_change_vec = requestor_dirlkp_state_is_valid(lkprsp_pktq[0]) ? (1 << m_iid_cacheid) : 0;
                                 end 

                //WrClnPtl is issued by CHI-A 
                //LKP_RSP should only indicate either requestor in UDP or IX.
                //No SF state change is needed. 
                default: begin //we should get here only if cmt_req was needed only due to wr required being set, and cmt_req == dir lkp_rsp.
                            cmt_req.m_owner_val   = lkprsp_pktq[0].m_owner_val;
                            cmt_req.m_owner_num   = lkprsp_pktq[0].m_owner_num;
                            cmt_req.m_sharer_vec  = lkprsp_pktq[0].m_sharer_vec;
                         end 
            endcase
            
            //always OR the calculated change_vec with lkprsp.sharer_vec to predict final change_vec. This is needed to assert write enables for all valid agents to complete TAG filter update as a result of VB swap. 
            if (lkprsp_pktq[0].m_wr_required == 1) begin // For dm_hit scenario m_wr_required reflects the VB_hit(old m_vhit)
                cmt_req.m_change_vec |= lkprsp_pktq[0].m_sharer_vec;
                //cmt_req.m_change_vec = lkprsp_pktq[0].m_sharer_vec | cmt_req.m_sharer_vec;
            end 

            //SysCo - start
            agent_idq = addrMgrConst::get_agent_ids_assoc2cacheid(cmt_req.m_owner_num);
            if(cmt_req.m_owner_val == 1 && snoop_enable_reg_txn[agent_idq[0]] == 0) begin
                cmt_req.m_owner_val = 0;
                cmt_req.m_owner_num = 0;
            end
            foreach(cmt_req.m_sharer_vec[x]) begin
                agent_idq = addrMgrConst::get_agent_ids_assoc2cacheid(x);
                if(cmt_req.m_sharer_vec[x] == 1 && snoop_enable_reg_txn[agent_idq[0]] == 0) begin
                    cmt_req.m_sharer_vec[x] = 0;
                end
            end
            //SysCo - end

            m_dm_pktq.push_back(cmt_req);
           `uvm_info(get_name(), $psprintf("[%-35s] (txnId: %5d) {%20s} (src: 0x%02h {%s}) (tgt: 0x%02h) (msgId: 0x%02h) (attid : 0x%02h) (rbid: 0x%02h) (addr: 0x%016h) (att: 0x%02h, %20s) (msgId: 0x%02h) (access: %20s) (updStat: %20s) (shareVec: 0x%04h) (owner: %1b/0x%02h)\n%s", "DceScbd-CmtPred-4", m_txn_id, m_initcmdupd_req_pkt.type2cmdname(), m_initcmdupd_req_pkt.smi_src_ncore_unit_id, addrMgrConst::get_cache_id_as_string(m_initcmdupd_req_pkt.smi_src_ncore_unit_id), m_initcmdupd_req_pkt.smi_targ_ncore_unit_id, m_initcmdupd_req_pkt.smi_msg_id, m_attid, m_rbid, cmt_req.m_addr, cmt_req.m_attid, cmt_req.m_attid_state.name(), cmt_req.m_msg_id, cmt_req.m_access_type.name(), cmt_req.m_status.name(), cmt_req.m_sharer_vec, cmt_req.m_owner_val, cmt_req.m_owner_num, cmt_req.convert2string()), UVM_MEDIUM);
        end //predict dir cmt_req
        
        if (cohreq_pktq[cohreq_pktq.size - 1].m_alloc && m_states["dirreq"].is_complete() && !dce_goldenref_model::is_stash_request(m_cmd_type)) begin
            `uvm_error("DCE SCB", "Commit_req not predicted for master_alloc txn");
        end
    end else if ( !lkprsp_pktq[0].is_dm_miss() 
                  //&& ((pktq[0].m_sharer_vec != ((1 << m_iid_cacheid) | pktq[0].m_sharer_vec)) || (pktq[0].m_owner_val && pktq[0].m_owner_num != m_iid_cacheid))
                  && (m_states["snpreq"].get_valid_count() >= 1) 
                  &&  m_states["snpreq"].is_complete() 
                  &&  m_states["snprsp"].is_complete()
                ) begin//dm_hit with agent_id not already valid, so write needed update sharer_vec and others if applicable
                     
        foreach (m_drvsnp_rsp_pktq[idx]) begin 
            snprsp_error |= m_drvsnp_rsp_pktq[idx].smi_cmstatus_err;
            if(!m_drvsnp_rsp_pktq[idx].smi_cmstatus_err) begin
                        aggregate_cmstatus |= m_drvsnp_rsp_pktq[idx].smi_cmstatus;
                        aggregate_dt_dmi   |= m_drvsnp_rsp_pktq[idx].smi_cmstatus_dt_dmi;
                        aggregate_dc       |= m_drvsnp_rsp_pktq[idx].smi_cmstatus_dc;
                        aggregate_rv       |= m_drvsnp_rsp_pktq[idx].smi_cmstatus_rv;
                        aggregate_rs       |= m_drvsnp_rsp_pktq[idx].smi_cmstatus_rs;
            end
        end
       
        if(!lkprsp_pktq[0].m_wr_required &&      // For dm_hit scenario m_wr_required reflects the VB_hit(old m_vhit)                        
            ((((m_cmd_type inside {CMD_CLN_VLD, CMD_CLN_SH_PER}) && (aggregate_rv && !aggregate_rs && !aggregate_dc))
                || ((m_cmd_type == CMD_RD_NITC) 
                    && ((lkprsp_pktq[0].m_owner_val ? (aggregate_rv && !aggregate_rs && !aggregate_dc) : (aggregate_rv && aggregate_rs))  //owner/sharer stays as owner/sharer
                        && ((m_iid_cacheid == -1) 
                            || !requestor_dirlkp_state_is_valid(lkprsp_pktq[0]) //requestor not valid
                            || (m_initcmdupd_req_pkt.smi_tof == 2)))) //requestor is ACE
                 || (aggregate_cmstatus[0] && lkprsp_pktq[0].m_owner_val && lkprsp_pktq[0].m_owner_num == m_sid_cacheid && m_initcmdupd_req_pkt.smi_mpf1_stash_valid && ((lkprsp_pktq[0].m_sharer_vec & ~(1 << lkprsp_pktq[0].m_owner_num)) == 0)) // if target was UD/UC then skip the CMT_REQ
                 || (ex_store && (m_exmon_status == EXMON_FAIL))))) begin
            //skip SF update/Dir Write
            if(lkprsp_pktq[0].m_sharer_vec != dm_lkprsp.m_sharer_vec) begin
                m_states["dirreq"].set_expect();
                cmt_req = new("cmt_req");
                cmt_req.m_access_type = DM_CMT_REQ;
                cmt_req.m_way_vec_or_mask = lkprsp_pktq[0].m_way_vec_or_mask;
                cmt_req.m_addr            = m_initcmdupd_req_pkt.smi_addr;
                cmt_req.m_ns              = m_initcmdupd_req_pkt.smi_ns;
                cmt_req.m_owner_val       = lkprsp_pktq[0].m_owner_val;
                cmt_req.m_owner_num       = lkprsp_pktq[0].m_owner_num;
                cmt_req.m_sharer_vec      = lkprsp_pktq[0].m_sharer_vec;
                cmt_req.m_change_vec      = dm_lkprsp.m_sharer_vec ^ lkprsp_pktq[0].m_sharer_vec;
                m_dm_pktq.push_back(cmt_req);
               `uvm_info(get_name(), $psprintf("[%-35s] (txnId: %5d) {%20s} (src: 0x%02h {%s}) (tgt: 0x%02h) (msgId: 0x%02h) (attid : 0x%02h) (rbid: 0x%02h) (addr: 0x%016h) (att: 0x%02h, %20s) (msgId: 0x%02h) (access: %20s) (updStat: %20s) (shareVec: 0x%04h) (owner: %1b/0x%02h)\n%s", "DceScbd-CmtPred-5", m_txn_id, m_initcmdupd_req_pkt.type2cmdname(), m_initcmdupd_req_pkt.smi_src_ncore_unit_id, addrMgrConst::get_cache_id_as_string(m_initcmdupd_req_pkt.smi_src_ncore_unit_id), m_initcmdupd_req_pkt.smi_targ_ncore_unit_id, m_initcmdupd_req_pkt.smi_msg_id, m_attid, m_rbid, cmt_req.m_addr, cmt_req.m_attid, cmt_req.m_attid_state.name(), cmt_req.m_msg_id, cmt_req.m_access_type.name(), cmt_req.m_status.name(), cmt_req.m_sharer_vec, cmt_req.m_owner_val, cmt_req.m_owner_num, cmt_req.convert2string()), UVM_MEDIUM);
            end
        end else begin
            //`uvm_info("DBG", $psprintf("cmt_req prediction rv: %0b rs:%0b dc: %0b", aggregate_rv, aggregate_rs, aggregate_dc), UVM_LOW)
            m_states["dirreq"].set_expect();
            cmt_req = new("cmt_req");
            cmt_req.m_access_type = DM_CMT_REQ;
            cmt_req.m_way_vec_or_mask = lkprsp_pktq[0].m_way_vec_or_mask;
            cmt_req.m_addr            = m_initcmdupd_req_pkt.smi_addr;
            cmt_req.m_ns              = m_initcmdupd_req_pkt.smi_ns;
            //owner_cacheid below is added to see which sharer is promoted to owner wrt sharer promotion
            case (m_cmd_type)
                CMD_RD_CLN : begin
                                cmt_req.m_owner_val  = (    
                                                            ((aggregate_cmstatus == 0) & $onehot(lkprsp_pktq[0].m_sharer_vec)) //SnpResp_I causes DCE to issue MrdRdUnqCln taking the line as CompData_UC  
                                                         |  ((aggregate_cmstatus == 0) & ($countones(lkprsp_pktq[0].m_sharer_vec) == 2) & requestor_dirlkp_state_is_SC(lkprsp_pktq[0])) //SnpResp_I causes DCE to issue MrdRdUnqCln taking the line as CompData_UC  
                                                         |  (aggregate_rv & !aggregate_rs & !aggregate_dc)                   //previous owner stays as owner  
                                                         |  aggregate_dc                                                     //ownership is transferred
                                                       ) ? 1'b1 : 1'b0;
                                cmt_req.m_owner_num  = cmt_req.m_owner_val ? ((aggregate_rv & !aggregate_rs & !aggregate_dc) ? (lkprsp_pktq[0].m_owner_val ? lkprsp_pktq[0].m_owner_num : owner_cacheid) : m_iid_cacheid) : 0;
                                cmt_req.m_sharer_vec = aggregate_rv ? ((1 << m_iid_cacheid) | lkprsp_pktq[0].m_sharer_vec) : lkprsp_pktq[0].m_owner_val ? (((1 << m_iid_cacheid) | lkprsp_pktq[0].m_sharer_vec) & ~(1 << lkprsp_pktq[0].m_owner_num)) : (((1 << m_iid_cacheid) | lkprsp_pktq[0].m_sharer_vec) & ~(1 << owner_cacheid));
                                change_vec_old = ((lkprsp_pktq[0].m_owner_val != cmt_req.m_owner_val) || (lkprsp_pktq[0].m_owner_num != cmt_req.m_owner_num)) ? (1 << lkprsp_pktq[0].m_owner_num) : 0;  
                                change_vec_new = 1 << m_iid_cacheid;
                                cmt_req.m_change_vec = change_vec_old | change_vec_new;
                             end 
                CMD_RD_VLD : begin
                                cmt_req.m_owner_val  = (    
                                                            ((aggregate_cmstatus == 0) & $onehot(lkprsp_pktq[0].m_sharer_vec))  //SnpResp_I and UP=1 causes DCE to issue MrdRdUnqCln taking the line as CompData_UC  
                                                         |  ((aggregate_cmstatus == 0) & ($countones(lkprsp_pktq[0].m_sharer_vec) == 2) & requestor_dirlkp_state_is_SC(lkprsp_pktq[0])) //SnpResp_I causes DCE to issue MrdRdUnqCln taking the line as CompData_UC  
                                                         |  (aggregate_rv & !aggregate_rs & !aggregate_dc)                    //previous owner stays as owner  
                                                         |  aggregate_dc                                                      //ownership is transferred
                                                       ) ? 1'b1 : 1'b0;
                                //cmt_req.m_owner_val  = (!aggregate_rv | !aggregate_rs | aggregate_dc) ? 1'b1 : 1'b0; //if the previous owner downgrades to sharer & dc=0, owner ceases to exists.
                                cmt_req.m_owner_num  = cmt_req.m_owner_val ? ((aggregate_rv & !aggregate_rs & !aggregate_dc) ? (lkprsp_pktq[0].m_owner_val ? lkprsp_pktq[0].m_owner_num : owner_cacheid) : m_iid_cacheid) : 0;
                                cmt_req.m_sharer_vec = aggregate_rv ? ((1 << m_iid_cacheid) | lkprsp_pktq[0].m_sharer_vec) : lkprsp_pktq[0].m_owner_val ? (((1 << m_iid_cacheid) | lkprsp_pktq[0].m_sharer_vec) & ~(1 << lkprsp_pktq[0].m_owner_num)) : (((1 << m_iid_cacheid) | lkprsp_pktq[0].m_sharer_vec) & ~(1 << owner_cacheid));
                                change_vec_old = ((lkprsp_pktq[0].m_owner_val != cmt_req.m_owner_val) || (lkprsp_pktq[0].m_owner_num != cmt_req.m_owner_num)) ? (1 << lkprsp_pktq[0].m_owner_num) : 0;  
                                change_vec_new = 1 << m_iid_cacheid;
                                cmt_req.m_change_vec = change_vec_old | change_vec_new;
                             end 
                CMD_RD_NOT_SHD : 
                             begin                          
                                cmt_req.m_owner_val  = (    
                                                            ((aggregate_cmstatus == 0) & $onehot(lkprsp_pktq[0].m_sharer_vec))  //SnpResp_I and UP=1 causes DCE to issue MrdRdUnqCln taking the line as CompData_UC  
                                                         |  ((aggregate_cmstatus == 0) & ($countones(lkprsp_pktq[0].m_sharer_vec) == 2) & requestor_dirlkp_state_is_SC(lkprsp_pktq[0])) //SnpResp_I causes DCE to issue MrdRdUnqCln taking the line as CompData_UC  
                                                         |  (aggregate_rv & !aggregate_rs & !aggregate_dc)  //previous owner stays as owner  
                                                         |  aggregate_dc                                    //ownership is transferred
                                                       ) ? 1'b1 : 1'b0;
                                cmt_req.m_owner_num  = cmt_req.m_owner_val ? ((aggregate_rv & !aggregate_rs & !aggregate_dc) ? (lkprsp_pktq[0].m_owner_val ? lkprsp_pktq[0].m_owner_num : owner_cacheid) : m_iid_cacheid) : 0;
                                cmt_req.m_sharer_vec = aggregate_rv ? ((1 << m_iid_cacheid) | lkprsp_pktq[0].m_sharer_vec) : lkprsp_pktq[0].m_owner_val ? (((1 << m_iid_cacheid) | lkprsp_pktq[0].m_sharer_vec) & ~(1 << lkprsp_pktq[0].m_owner_num)) : (((1 << m_iid_cacheid) | lkprsp_pktq[0].m_sharer_vec) & ~(1 << owner_cacheid));
                                change_vec_old = ((lkprsp_pktq[0].m_owner_val != cmt_req.m_owner_val) || (lkprsp_pktq[0].m_owner_num != cmt_req.m_owner_num)) ? (1 << lkprsp_pktq[0].m_owner_num) : 0;  
                                change_vec_new = 1 << m_iid_cacheid;
                                cmt_req.m_change_vec = change_vec_old | change_vec_new;
                             end 
                CMD_RD_UNQ,
                CMD_MK_UNQ: begin
                                cmt_req.m_owner_val  = 1;
                                cmt_req.m_owner_num  = m_iid_cacheid;
                                cmt_req.m_sharer_vec = 1 << m_iid_cacheid;
                                change_vec_old = lkprsp_pktq[0].m_sharer_vec;  
                                change_vec_new = 1 << m_iid_cacheid;
                                cmt_req.m_change_vec = change_vec_old | change_vec_new;
                             end

                CMD_CLN_UNQ: begin
                                if ((ex_store == 1) && (m_exmon_status == EXMON_FAIL)) begin
                                    cmt_req.m_owner_val       = lkprsp_pktq[0].m_owner_val;
                                    cmt_req.m_owner_num       = lkprsp_pktq[0].m_owner_num;
                                    cmt_req.m_sharer_vec      = lkprsp_pktq[0].m_sharer_vec;
                                    cmt_req.m_change_vec      = lkprsp_pktq[0].m_sharer_vec;
                                end else begin
                                    cmt_req.m_owner_val  = 1;
                                    cmt_req.m_owner_num  = m_iid_cacheid;
                                    cmt_req.m_sharer_vec = 1 << m_iid_cacheid;
                                    change_vec_old = lkprsp_pktq[0].m_sharer_vec;  
                                    change_vec_new = 1 << m_iid_cacheid;
                                    cmt_req.m_change_vec = change_vec_old | change_vec_new;
                                end
                             end
                CMD_RD_NITC: begin 
                                if (m_initcmdupd_req_pkt.smi_tof != 'h2) begin //not an ACE ordering model 
                                    cmt_req.m_owner_val = (aggregate_rv & !aggregate_rs & !aggregate_dc) ? 1'b1 : 1'b0;
                                    cmt_req.m_owner_num = cmt_req.m_owner_val ? (lkprsp_pktq[0].m_owner_val ? lkprsp_pktq[0].m_owner_num : owner_cacheid) : 'b0;
                                    cmt_req.m_sharer_vec = lkprsp_pktq[0].m_sharer_vec & ~(1 << m_iid_cacheid); //clear requestor
                                    cmt_req.m_sharer_vec = (aggregate_rv == 0) ? ((lkprsp_pktq[0].m_owner_val) ? cmt_req.m_sharer_vec & ~(1 << lkprsp_pktq[0].m_owner_num) :cmt_req.m_sharer_vec & ~(1 << owner_cacheid)) : cmt_req.m_sharer_vec;
                                    cmt_req.m_change_vec = (lkprsp_pktq[0].m_owner_val != cmt_req.m_owner_val) ? (1 << (lkprsp_pktq[0].m_owner_val ? lkprsp_pktq[0].m_owner_num : owner_cacheid)) : (aggregate_rv == 0) ? (1 << owner_cacheid) : 0;
                                    cmt_req.m_change_vec = (lkprsp_pktq[0].m_sharer_vec == ((1 << m_iid_cacheid) | lkprsp_pktq[0].m_sharer_vec)) ? ((1 << m_iid_cacheid) | cmt_req.m_change_vec) : cmt_req.m_change_vec;
                                end else begin //if requestor is ACE master . we get here implies requestor was in SC, it stays in SC if owner stays in SC or there are other sharers, else gets promoted to UC
                                    cmt_req.m_owner_val = (     (aggregate_rv & !aggregate_rs & !aggregate_dc)
                                                            ||  ((aggregate_cmstatus == 0) & ($countones(lkprsp_pktq[0].m_sharer_vec) == 2) & requestor_dirlkp_state_is_SC(lkprsp_pktq[0])) //Owner downgrades to IX and if no other sharers, requestor is promoted to UC 
                                                          ) ? 1 : 0;
                                    cmt_req.m_owner_num  = cmt_req.m_owner_val ? ((aggregate_rv & !aggregate_rs & !aggregate_dc) ? (lkprsp_pktq[0].m_owner_val ? lkprsp_pktq[0].m_owner_num : owner_cacheid) : m_iid_cacheid) : 0;
                                    cmt_req.m_sharer_vec = (aggregate_rv == 0) ? ((lkprsp_pktq[0].m_owner_val) ? lkprsp_pktq[0].m_sharer_vec & ~(1 << lkprsp_pktq[0].m_owner_num) : lkprsp_pktq[0].m_sharer_vec & ~(1 << owner_cacheid)) : lkprsp_pktq[0].m_sharer_vec;
                                    cmt_req.m_change_vec = ((lkprsp_pktq[0].m_owner_val != cmt_req.m_owner_val) || (lkprsp_pktq[0].m_owner_num != cmt_req.m_owner_num)) ? (1 << (lkprsp_pktq[0].m_owner_val ? lkprsp_pktq[0].m_owner_num : owner_cacheid)) : (!lkprsp_pktq[0].m_owner_val) ? (1 << owner_cacheid) : 0;  
                                    cmt_req.m_change_vec |= (cmt_req.m_owner_val == 1 && cmt_req.m_owner_num == m_iid_cacheid) ? (1 << m_iid_cacheid) : 0;
                                end

                                //if the cmt_req was just needed due to vhit, assign change_vec == sharer_vec
                                if (lkprsp_pktq[0].m_wr_required && (cmt_req.m_change_vec == 0)) begin // For dm_hit scenario m_wr_required reflects the VB_hit(old m_vhit)
                                    cmt_req.m_change_vec = lkprsp_pktq[0].m_sharer_vec;
                                end
                             end

                CMD_CLN_VLD,
                CMD_CLN_SH_PER: begin
                                    //we get here implies the owner is no longer a owner, either downgraded to sharer or invalidated
                                    //we could also get here if any SF change is not needed but is a VB hit
                                    cmt_req.m_owner_val  = (aggregate_rv && !aggregate_rs && !aggregate_dc) ? 1'b1 : 1'b0;
                                    cmt_req.m_owner_num  = cmt_req.m_owner_val ? lkprsp_pktq[0].m_owner_num : 'b0;
                                    cmt_req.m_sharer_vec = (aggregate_rv == 0) ? lkprsp_pktq[0].m_sharer_vec & ~(1 << lkprsp_pktq[0].m_owner_num) : lkprsp_pktq[0].m_sharer_vec;
                                    cmt_req.m_change_vec = 1 << lkprsp_pktq[0].m_owner_num; 
                                end
                CMD_RD_NITC_CLN_INV,
                CMD_RD_NITC_MK_INV,
                CMD_RD_ATM,
                CMD_WR_ATM,
                CMD_SW_ATM,
                CMD_CMP_ATM,
                CMD_CLN_INV,
                CMD_MK_INV: 
                                  begin
                                    cmt_req.m_owner_val  = 0;
                                    cmt_req.m_owner_num  = 0;
                                    cmt_req.m_sharer_vec = 0;
                                    change_vec_old = dm_lkprsp.m_sharer_vec;  
                                    change_vec_new = 0;
                                    cmt_req.m_change_vec = change_vec_old | change_vec_new;
                                  end
                CMD_WR_UNQ_PTL,
                CMD_WR_UNQ_FULL:  
                                  begin
                                    //ACE master and AWUNIQUE==0, and hits in SC, retain that state.
                                    if ((m_initcmdupd_req_pkt.smi_mpf1_awunique == 0) && //AWUNIQUE == 0
                                        (m_initcmdupd_req_pkt.smi_tof == 2) && 
                                        (m_iid_cacheid != -1) &&  //ACE master
                                         requestor_dirlkp_state_is_valid(lkprsp_pktq[0])) begin //SD->SC/SC->SC
                                         cmt_req.m_owner_val  = 0;
                                         cmt_req.m_owner_num  = 0;
                                         cmt_req.m_sharer_vec = 1 << m_iid_cacheid;
                                         if (lkprsp_pktq[0].m_owner_val && (lkprsp_pktq[0].m_owner_num == m_iid_cacheid)) begin //requestor=SD
                                            cmt_req.m_change_vec = lkprsp_pktq[0].m_sharer_vec;
                                         end else begin//requestor=SC
                                            cmt_req.m_change_vec = lkprsp_pktq[0].m_sharer_vec & ~(1 << m_iid_cacheid);
                                         end
                                    end else begin
                                        cmt_req.m_owner_val  = 0;
                                        cmt_req.m_owner_num  = 0;
                                        cmt_req.m_sharer_vec = 0;
                                        //change_vec_old = lkprsp_pktq[0].m_sharer_vec;  
                                        change_vec_old = dm_lkprsp.m_sharer_vec;  
                                        change_vec_new = 0;
                                        cmt_req.m_change_vec = change_vec_old | change_vec_new;
                                    end
                                  end
                CMD_WR_STSH_FULL: 
                                  begin 
                                      snarf = aggregate_cmstatus[0];
                                      if(snarf == 1) begin
                                          cmt_req.m_owner_val       = 1;
                                          cmt_req.m_owner_num       = m_sid_cacheid;
                                          cmt_req.m_sharer_vec      = (1 << m_sid_cacheid);
                                          change_vec_new            = (1 << m_sid_cacheid);
                                      end else begin
                                          cmt_req.m_owner_val       = 0;
                                          cmt_req.m_owner_num       = 0;
                                          cmt_req.m_sharer_vec      = 0;
                                          change_vec_new            = 0;
                                      end
                                      change_vec_old            = lkprsp_pktq[0].m_sharer_vec;  
                                      // Here Final state is going to be owner
                                      //Invalid/Sharer -> Owner Change
                                      //Owner          -> Owner no Change 
                                      cmt_req.m_change_vec      = (lkprsp_pktq[0].m_owner_val && (lkprsp_pktq[0].m_owner_num == m_sid_cacheid)) ? (change_vec_old ^ change_vec_new) : (change_vec_old | change_vec_new);
                                  end 
                CMD_WR_STSH_PTL: 
                                  begin 
                                      snarf = aggregate_cmstatus[0];
                                      if(snarf == 1) begin
                                          cmt_req.m_owner_val       = 1;
                                          cmt_req.m_owner_num       = m_sid_cacheid;
                                          cmt_req.m_sharer_vec      = (1 << m_sid_cacheid);
                                          change_vec_new            = (1 << m_sid_cacheid);
                                      end else begin
                                          cmt_req.m_owner_val       = 0;
                                          cmt_req.m_owner_num       = 0;
                                          cmt_req.m_sharer_vec      = 0;
                                          change_vec_new            = 0;
                                      end
                                      change_vec_old            = lkprsp_pktq[0].m_sharer_vec;  
                                      // Here Final state is going to be owner
                                      //Invalid/Sharer -> Owner Change
                                      //Owner          -> Owner no Change 
                                      cmt_req.m_change_vec      = (lkprsp_pktq[0].m_owner_val && (lkprsp_pktq[0].m_owner_num == m_sid_cacheid)) ? (change_vec_old ^ change_vec_new) : (change_vec_old | change_vec_new);
                                  end
                CMD_LD_CCH_UNQ: 
                                  begin 
                                      snarf = aggregate_cmstatus[0];
                                      if(snarf == 1) begin
                                          cmt_req.m_owner_val       = 1;
                                          cmt_req.m_owner_num       = m_sid_cacheid;
                                          cmt_req.m_sharer_vec      = (1 << m_sid_cacheid);
                                          change_vec_new            = (1 << m_sid_cacheid);
                                          change_vec_old            = lkprsp_pktq[0].m_sharer_vec;  
                                          // Here Final state is going to be owner
                                          //Invalid/Sharer -> Owner Change
                                          //Owner          -> Owner no Change 
                                          cmt_req.m_change_vec      = (lkprsp_pktq[0].m_owner_val && (lkprsp_pktq[0].m_owner_num == m_sid_cacheid)) ? (change_vec_old ^ change_vec_new) : (change_vec_old | change_vec_new);
                                      end else begin //snarf==0
                                          cmt_req.m_owner_val       = lkprsp_pktq[0].m_owner_val ? ((lkprsp_pktq[0].m_owner_num == m_iid_cacheid) ? 0 : 1) : 0;
                                          cmt_req.m_owner_num       = cmt_req.m_owner_val ? lkprsp_pktq[0].m_owner_num : 0;
                                          cmt_req.m_sharer_vec      = (m_iid_cacheid != -1) ? (lkprsp_pktq[0].m_sharer_vec & (~(1 << m_iid_cacheid))) : lkprsp_pktq[0].m_sharer_vec;
                                          cmt_req.m_change_vec      = (m_iid_cacheid != -1) ? ((lkprsp_pktq[0].m_sharer_vec == ((1 << m_iid_cacheid) | lkprsp_pktq[0].m_sharer_vec)) ? (1 << m_iid_cacheid) : 0) : 0;

                                          //SANJEEV: Fix Place 1/2: So called a spec change(now) in Ncore3.7 by RTL team (Unofficial, unreviwed, unlisted though). This is actually an RTL bug denied earlier(before 3.7), termed as TB bug and is being called as a spec update in 3.7 by RTL team. Stash target holding the line in Dirty state and is being removed from the directory upon snoop error leading to loss of latest data.
                                          //		Interested party may follow these Jira's and connected jiras for my arguments in Ncore 3.6.  Fix: CONC-15992. Revert CONC-14466, CONC-15458. Tag: CONC-15081, CONC-16087, CONC-15459
                                          //            Unfortunately DCE-DV does not have a jira to represent it as spec change to verify this change. DCE-DV owner's efforts are dubbed as a simple regression triage by DV team(CONC-15992)
                                          //SANJEEV: // CONC-13844
                                          //SANJEEV: // DV fix when stash tgt responds with error and it is also a owner/sharer
                                          //SANJEEV: snprsp_tgt_pktq           = m_drvsnp_rsp_pktq.find(item) with (item.smi_src_ncore_unit_id == lkprsp_pktq[0].m_sid >> WSMINCOREPORTID); //stash target response
                                          //SANJEEV: if(snprsp_tgt_pktq[0].smi_cmstatus_err != 0) begin
                                          //SANJEEV:   if((cmt_req.m_sharer_vec & (1 << m_sid_cacheid)) != 0) begin
                                          //SANJEEV:     cmt_req.m_sharer_vec = cmt_req.m_sharer_vec & (~(1 << m_sid_cacheid));
                                          //SANJEEV:     cmt_req.m_change_vec = (1 << m_sid_cacheid);

                                          //SANJEEV:     if(cmt_req.m_owner_num == m_sid_cacheid) begin
                                          //SANJEEV:       cmt_req.m_owner_val  = 0;
                                          //SANJEEV:       cmt_req.m_owner_num  = 0;
                                          //SANJEEV:     end
                                          //SANJEEV:   end
                                          //SANJEEV: end
                                      end 
                                  end 

                CMD_LD_CCH_SH: 
                //All Scenarios Snarf=1 Target Identified FOR "READ STASH SHARED"
                //
                //                                Target         Peers
                //                               IS -> FS        IS->FS
                //(UC/UD/SD->SNF=0) (UCE->SNF=1)  O    O         NO CHANGE, as for UCE peers will be I, No CMT_REQ
                //(SC->SNF=0)                     S    S         NO CHANGE, No CMT_REQ
                //(I->SNF=0/1)                    I    S         S(SC->I/SC)/O(UC->I/SC || UCE->I || UD->I_DT/SC_DT/SD || SD->I_DT/SC_DT/SD)
                //
                //====================================================================
                //                                RV/RS/DC/DT_AIU/DT_DMI + SNF       =
                //====================================================================
                //TGT(UCE)   : SnpResp_UC_Read     10000 + 1                         =
                //                         Aggr:   10000 + 1 -> TGT->O;No CMT_REQ    =
                //====================================================================
                //TGT(I)     : SnpResp_I_Read      00000 + 1                         =
                //OTH(SC)    : SnpResp_I           00000 + - ?? SnpReq to Owner only =
                //OTH(SC)    : SnpResp_SC          11000 + - ?? SnpReq to Owner only =
                //OTH(UC/UCE): SnpRespData_I       00000 + -                         =
                //OTH(UC)    : SnpRespData_SC      11000 + -                         =
                //OTH(UD/SD) : SnpRespData_I_PD    00001 + -                         =
                //OTH(UD)    : SnpRespDataPtl_I_PD 00001 + -                         =
                //OTH(UD/SD) : SnpRespData_SD      10001 + -                         =
                //OTH(UD/SD) : SnpRespData_SC_PD   11001 + -                         =
                //UC/SC -> I/SC                                                      =
                //                         Aggr:   00000 + 1 -> TGT->S; No O/S       =
                //                         Aggr:   11000 + 1 -> TGT->S; Only S       =
                //UD/SD -> I/SD/SC                               TGT     UD      SD  =
                //                         Aggr:   00001 + 1 -> TGT->S; No O/S | S   =
                //                         Aggr:   10001 + 1 -> TGT->S; O      | O S =
                //                         Aggr:   11001 + 1 -> TGT->S; only S | S   =
                //====================================================================
                                  begin 
                                      snarf = aggregate_cmstatus[0];
                                      if(snarf == 1) begin
                                          if(aggregate_rv && !aggregate_rs && !aggregate_dt_dmi && !lkprsp_pktq[0].m_wr_required) begin // No CMT_REQ should be there // For dm_hit scenario m_wr_required reflects the VB_hit(old m_vhit)
                                              `uvm_error("DCE SCB",$sformatf("For Read Stash, if owner present and no dt_dmi then no CMT_req predicted, rv=%0d rs=%0d ddmi=%0d",aggregate_rv,aggregate_rs,aggregate_dt_dmi) )
                                          end else begin
                                              //cmt_req.m_owner_val       = aggregate_dt_dmi ?(aggregate_rv & !aggregate_rs) : ((lkprsp_pktq[0].m_wr_required && (lkprsp_pktq[0].m_owner_num == m_sid_cacheid) ) ? lkprsp_pktq[0].m_owner_val : 0) ;
                                              //CONC-5866 Khaleel comment:The only possibility for target to become an owner in the case of StashOnceShared is if the target gave a snoop Response where it identified itself as an owner.
                                              snprsp_tgt_pktq   = m_drvsnp_rsp_pktq.find(item) with (item.smi_cmstatus_snarf == 1); //stash target response
                                              snprsp_owner_pktq = m_drvsnp_rsp_pktq.find(item) with (item.smi_cmstatus_snarf == 0); //owner snoop response
                                              
                                              // this is when the stash target and the owner are the same
                                              if((m_sid_cacheid == lkprsp_pktq[0].m_owner_num) && (lkprsp_pktq[0].m_owner_val == 1)) begin
                                                  snprsp_owner_pktq = snprsp_tgt_pktq;
                                              end

                                              `uvm_info(get_name(), $psprintf("[%-35s] (txnId: %5d) {%20s} (src: 0x%02h {%s}) (tgt: 0x%02h) (msgId: 0x%02h) (shareVec: 0x%04h) (sCacheId: 0x%02h) (iCacheId: 0x%02h)", "DceScbd-CmtPred-6(Dbg-01)", m_txn_id, m_initcmdupd_req_pkt.type2cmdname(), m_initcmdupd_req_pkt.smi_src_ncore_unit_id, addrMgrConst::get_cache_id_as_string(m_initcmdupd_req_pkt.smi_src_ncore_unit_id), m_initcmdupd_req_pkt.smi_targ_ncore_unit_id, m_initcmdupd_req_pkt.smi_msg_id, cmt_req.m_sharer_vec, m_sid_cacheid, m_iid_cacheid), UVM_MEDIUM);
                                              cmt_req.m_sharer_vec   = lkprsp_pktq[0].m_sharer_vec | (1 << m_sid_cacheid); //make the stash tgt vld
                                              `uvm_info(get_name(), $psprintf("[%-35s] (txnId: %5d) {%20s} (src: 0x%02h {%s}) (tgt: 0x%02h) (msgId: 0x%02h) (shareVec: 0x%04h) (sCacheId: 0x%02h) (iCacheId: 0x%02h)", "DceScbd-CmtPred-6(Dbg-02)", m_txn_id, m_initcmdupd_req_pkt.type2cmdname(), m_initcmdupd_req_pkt.smi_src_ncore_unit_id, addrMgrConst::get_cache_id_as_string(m_initcmdupd_req_pkt.smi_src_ncore_unit_id), m_initcmdupd_req_pkt.smi_targ_ncore_unit_id, m_initcmdupd_req_pkt.smi_msg_id, cmt_req.m_sharer_vec, m_sid_cacheid, m_iid_cacheid), UVM_MEDIUM);
                                              if (m_iid_cacheid != -1)
                                                  cmt_req.m_sharer_vec = cmt_req.m_sharer_vec & (~(1 << m_iid_cacheid)); //clear the requestor
                                              `uvm_info(get_name(), $psprintf("[%-35s] (txnId: %5d) {%20s} (src: 0x%02h {%s}) (tgt: 0x%02h) (msgId: 0x%02h) (shareVec: 0x%04h) (sCacheId: 0x%02h) (iCacheId: 0x%02h)", "DceScbd-CmtPred-6(Dbg-03)", m_txn_id, m_initcmdupd_req_pkt.type2cmdname(), m_initcmdupd_req_pkt.smi_src_ncore_unit_id, addrMgrConst::get_cache_id_as_string(m_initcmdupd_req_pkt.smi_src_ncore_unit_id), m_initcmdupd_req_pkt.smi_targ_ncore_unit_id, m_initcmdupd_req_pkt.smi_msg_id, cmt_req.m_sharer_vec, m_sid_cacheid, m_iid_cacheid), UVM_MEDIUM);

                                              // CONC-13564
                                              // When the owner snoop for read stash shared returns with error, uarch states that the owner state is preserved
                                              // ----------------------------------------------------------------------------------------------------------------
                                              // if there was an owner and it got demoted to IX, clear its bit in sharer vec
                                              if (snprsp_owner_pktq.size() != 0) begin
                                                  snooper_agentid    = addrMgrConst::agentid_assoc2funitid(snprsp_owner_pktq[0].smi_src_ncore_unit_id);
                                                  requestor_cache_id = addrMgrConst::get_cache_id(snprsp_owner_pktq[0].smi_src_ncore_unit_id, 1);
                                                  if(snprsp_owner_pktq[0].smi_cmstatus_err == 0) begin
                                                      cmt_req.m_owner_val   = lkprsp_pktq[0].m_owner_val ? (aggregate_rv & !aggregate_rs) : 'h0;
                                                      cmt_req.m_owner_num   = cmt_req.m_owner_val ? ((snprsp_tgt_pktq[0].smi_cmstatus_rv & !snprsp_tgt_pktq[0].smi_cmstatus_rs) ? m_sid_cacheid : lkprsp_pktq[0].m_owner_num) : 0;  
                                                      // The following override is valid only when the stash target is not the owner.
                                                      // If stash target is the owner and the stash is accepted, we dont clear it as it will have  a copy of the data eventually
                                                      if(m_sid_cacheid != lkprsp_pktq[0].m_owner_num) begin
                                                          cmt_req.m_sharer_vec  = cmt_req.m_sharer_vec & (~(snprsp_owner_pktq[0].smi_cmstatus_rv ? 0 : (1 << lkprsp_pktq[0].m_owner_num)));
                                                      end
                                                      `uvm_info(get_name(), $psprintf("[%-35s] (txnId: %5d) {%20s} (src: 0x%02h {%s}) (tgt: 0x%02h) (msgId: 0x%02h) (shareVec: 0x%04h) (owner: %1b/0x%02h) (sCacheId: 0x%02h) (iCacheId: 0x%02h)", "DceScbd-CmtPred-6(Dbg-04)", m_txn_id, m_initcmdupd_req_pkt.type2cmdname(), m_initcmdupd_req_pkt.smi_src_ncore_unit_id, addrMgrConst::get_cache_id_as_string(m_initcmdupd_req_pkt.smi_src_ncore_unit_id), m_initcmdupd_req_pkt.smi_targ_ncore_unit_id, m_initcmdupd_req_pkt.smi_msg_id, cmt_req.m_sharer_vec, cmt_req.m_owner_val, cmt_req.m_owner_num, m_sid_cacheid, m_iid_cacheid), UVM_MEDIUM);
                                                  end else begin //When SnpResp.Err
                                                      cmt_req.m_owner_val   = lkprsp_pktq[0].m_owner_val;
                                                      cmt_req.m_owner_num   = lkprsp_pktq[0].m_owner_num;
                                                      if (snprsp_owner_pktq[0].smi_cmstatus_err_payload == 'b100     //If (Address Error && CHI Snooper), DCE will invalidate the Snooper in SF. Refer CONC-16847,17100
                                                          && (addrMgrConst::get_native_interface(snooper_agentid) inside {addrMgrConst::CHI_A_AIU,addrMgrConst::CHI_B_AIU,addrMgrConst::CHI_E_AIU})) begin
                                                          cmt_req.m_sharer_vec = cmt_req.m_sharer_vec & (~(1 << requestor_cache_id)); //clear the requestor
                                                          cmt_req.m_owner_val   = 0;                                                  //Also we always clear the Owner as DCE will only snoop Owner for Read Stash Shared txn.
                                                          cmt_req.m_owner_num   = 0;                                                  //In case of no owner and sharer, DCE would have promoted one sharer with find first technique and will snoop it.
                                                      end
                                                      `uvm_info(get_name(), $psprintf("[%-35s] (txnId: %5d) {%20s} (src: 0x%02h {%s}) (tgt: 0x%02h) (msgId: 0x%02h) (shareVec: 0x%04h) (sCacheId: 0x%02h) (iCacheId: 0x%02h)", "DceScbd-CmtPred-6(Dbg-05)", m_txn_id, m_initcmdupd_req_pkt.type2cmdname(), m_initcmdupd_req_pkt.smi_src_ncore_unit_id, addrMgrConst::get_cache_id_as_string(m_initcmdupd_req_pkt.smi_src_ncore_unit_id), m_initcmdupd_req_pkt.smi_targ_ncore_unit_id, m_initcmdupd_req_pkt.smi_msg_id, cmt_req.m_sharer_vec, m_sid_cacheid, m_iid_cacheid), UVM_MEDIUM);
                                                  end
                                              end
                                              
                                              // old code --cmt_req.m_sharer_vec      = (1 << m_sid_cacheid) | (lkprsp_pktq[0].m_sharer_vec & ~( (aggregate_rv || !lkprsp_pktq[0].m_owner_val) ? 0 : 1<< lkprsp_pktq[0].m_owner_num ));
                                              change_vec_new            = (1 << m_sid_cacheid) | (lkprsp_pktq[0].m_sharer_vec & ~( (aggregate_rv || !lkprsp_pktq[0].m_owner_val) ? 0 : 1<< lkprsp_pktq[0].m_owner_num ));
                                              // Here Target's Final state is going to be Sharer
                                              //     Invalid -> Sharer Change (so XOR)
                                              // For Owner Peer Rv=1 and Rs=0 No change
                                              //     Owner -> Invalid change
                                              //     Owner -> Sharer change
                                              //     Owner -> Owner UD/SD->SD no change
                                              cmt_req.m_change_vec      =  (1 << m_sid_cacheid | (((aggregate_rv && !aggregate_rs) || !lkprsp_pktq[0].m_owner_val) ? 0 : 1<< lkprsp_pktq[0].m_owner_num )) ;
                                          end
                                      //sf update is not needed if snarf=0 unless requestor is valid in dir, wr is needed only if wr_Required is set    
                                      //a snoopee is permitted to not perform a cache lookup before responding in which case snoopee response is SnpResp_I
                                      end else if(aggregate_cmstatus == 0) begin
                                          cmt_req.m_owner_val       = (lkprsp_pktq[0].m_owner_val && (lkprsp_pktq[0].m_owner_num == m_iid_cacheid)) ? 0 : lkprsp_pktq[0].m_owner_val;
                                          cmt_req.m_owner_num       = cmt_req.m_owner_val ? lkprsp_pktq[0].m_owner_num : 0;
                                          cmt_req.m_sharer_vec      = lkprsp_pktq[0].m_sharer_vec & (~(1 << m_iid_cacheid)) ;
                                          cmt_req.m_change_vec      = (1 << m_iid_cacheid);
                                          `uvm_info(get_name(), $psprintf("[%-35s] (txnId: %5d) {%20s} (src: 0x%02h {%s}) (tgt: 0x%02h) (msgId: 0x%02h) (shareVec: 0x%04h) (sCacheId: 0x%02h) (iCacheId: 0x%02h)", "DceScbd-CmtPred-6(Dbg-06)", m_txn_id, m_initcmdupd_req_pkt.type2cmdname(), m_initcmdupd_req_pkt.smi_src_ncore_unit_id, addrMgrConst::get_cache_id_as_string(m_initcmdupd_req_pkt.smi_src_ncore_unit_id), m_initcmdupd_req_pkt.smi_targ_ncore_unit_id, m_initcmdupd_req_pkt.smi_msg_id, cmt_req.m_sharer_vec, m_sid_cacheid, m_iid_cacheid), UVM_MEDIUM);
                                      end else begin //snarf==0
                                          cmt_req.m_owner_val       = lkprsp_pktq[0].m_owner_val ? ((lkprsp_pktq[0].m_owner_num == m_iid_cacheid) ? 0 : 1) : 0;
                                          cmt_req.m_owner_num       = cmt_req.m_owner_val ? lkprsp_pktq[0].m_owner_num : 0;
                                          cmt_req.m_sharer_vec      = (m_iid_cacheid != -1) ? (lkprsp_pktq[0].m_sharer_vec & (~(1 << m_iid_cacheid))) : lkprsp_pktq[0].m_sharer_vec;
                                          cmt_req.m_change_vec      = (m_iid_cacheid != -1) ? ((lkprsp_pktq[0].m_sharer_vec == ((1 << m_iid_cacheid) | lkprsp_pktq[0].m_sharer_vec)) ? (1 << m_iid_cacheid) : 0) : 0;
                                          `uvm_info(get_name(), $psprintf("[%-35s] (txnId: %5d) {%20s} (src: 0x%02h {%s}) (tgt: 0x%02h) (msgId: 0x%02h) (shareVec: 0x%04h) (sCacheId: 0x%02h) (iCacheId: 0x%02h)", "DceScbd-CmtPred-6(Dbg-07)", m_txn_id, m_initcmdupd_req_pkt.type2cmdname(), m_initcmdupd_req_pkt.smi_src_ncore_unit_id, addrMgrConst::get_cache_id_as_string(m_initcmdupd_req_pkt.smi_src_ncore_unit_id), m_initcmdupd_req_pkt.smi_targ_ncore_unit_id, m_initcmdupd_req_pkt.smi_msg_id, cmt_req.m_sharer_vec, m_sid_cacheid, m_iid_cacheid), UVM_MEDIUM);
                                      end 
                                  end
            endcase

            //always OR the calculated change_vec with lkprsp.sharer_vec to predict final change_vec. This is needed to assert write enables for all valid agents to complete TAG filter update as a result of VB swap. 
            if (lkprsp_pktq[0].m_wr_required == 1) begin // For dm_hit scenario m_wr_required reflects the VB_hit(old m_vhit)
                cmt_req.m_change_vec |= lkprsp_pktq[0].m_sharer_vec;
            end 

            //SysCo - start
            agent_idq = addrMgrConst::get_agent_ids_assoc2cacheid(cmt_req.m_owner_num);
            if(cmt_req.m_owner_val == 1 && snoop_enable_reg_txn[agent_idq[0]] == 0) begin
                cmt_req.m_owner_val = 0;
                cmt_req.m_owner_num = 0;
            end

            foreach(cmt_req.m_sharer_vec[x]) begin
                agent_idq = addrMgrConst::get_agent_ids_assoc2cacheid(x);
                if(cmt_req.m_sharer_vec[x] == 1 && snoop_enable_reg_txn[agent_idq[0]] == 0) begin
                    cmt_req.m_sharer_vec[x] = 0;
                end
            end
            //SysCo - end

            m_dm_pktq.push_back(cmt_req);
           `uvm_info(get_name(), $psprintf("[%-35s] (txnId: %5d) {%20s} (src: 0x%02h {%s}) (tgt: 0x%02h) (msgId: 0x%02h) (attid : 0x%02h) (rbid: 0x%02h) (addr: 0x%016h) (att: 0x%02h, %20s) (msgId: 0x%02h) (access: %20s) (updStat: %20s) (shareVec: 0x%04h) (owner: %1b/0x%02h)\n%s", "DceScbd-CmtPred-6", m_txn_id, m_initcmdupd_req_pkt.type2cmdname(), m_initcmdupd_req_pkt.smi_src_ncore_unit_id, addrMgrConst::get_cache_id_as_string(m_initcmdupd_req_pkt.smi_src_ncore_unit_id), m_initcmdupd_req_pkt.smi_targ_ncore_unit_id, m_initcmdupd_req_pkt.smi_msg_id, m_attid, m_rbid, cmt_req.m_addr, cmt_req.m_attid, cmt_req.m_attid_state.name(), cmt_req.m_msg_id, cmt_req.m_access_type.name(), cmt_req.m_status.name(), cmt_req.m_sharer_vec, cmt_req.m_owner_val, cmt_req.m_owner_num, cmt_req.convert2string()), UVM_MEDIUM);
        end //all other cases in which Dir write is needed 
        if (cohreq_pktq[cohreq_pktq.size - 1].m_alloc && m_states["dirreq"].is_complete() && !dce_goldenref_model::is_stash_request(m_cmd_type)) begin
            `uvm_error("DCE SCB", "Commit_req not predicted for master_alloc txn");
        end
    end 

    if (lkprsp_pktq[0].is_dm_miss()
        && dce_goldenref_model::is_stash_request(m_cmd_type)
        && (m_states["snpreq"].get_valid_count() >= 1) 
        &&  m_states["snpreq"].is_complete() 
        &&  m_states["snprsp"].is_complete()) begin //stash request that misses with snooping complete

        snarf = m_drvsnp_rsp_pktq[0].smi_cmstatus_snarf;
        
        //stash accepted
        if (snarf == 1) begin 
                
            //wr stash full    
            m_states["dirreq"].set_expect();
            cmt_req = new("cmt_req");
            cmt_req.m_access_type     = DM_CMT_REQ;
            cmt_req.m_way_vec_or_mask = lkprsp_pktq[0].m_way_vec_or_mask;
            cmt_req.m_addr            = m_initcmdupd_req_pkt.smi_addr;
            cmt_req.m_ns              = m_initcmdupd_req_pkt.smi_ns;

            case (m_cmd_type)
                CMD_WR_STSH_FULL,CMD_WR_STSH_PTL: 
                                  begin 
                                    cmt_req.m_owner_val       = 1;
                                    cmt_req.m_owner_num       = m_sid_cacheid;
                                    cmt_req.m_sharer_vec      = 1 << m_sid_cacheid;
                                    change_vec_old            = lkprsp_pktq[0].m_sharer_vec;  
                                    change_vec_new            = 1 << m_sid_cacheid;
                                     cmt_req.m_change_vec     = change_vec_old | change_vec_new;
                                   end 

                CMD_LD_CCH_SH:
                                  begin 
                                      //dm_miss case
                                    cmt_req.m_owner_val       = 0;
                                    cmt_req.m_owner_num       = 0;
                                    cmt_req.m_sharer_vec      = 1 << m_sid_cacheid;
                                    cmt_req.m_change_vec      = 1 << m_sid_cacheid;
                                   end 
                CMD_LD_CCH_UNQ:
                                  begin 
                                      //dm_miss case
                                    cmt_req.m_owner_val       = 1;
                                    cmt_req.m_owner_num       = m_sid_cacheid;
                                    cmt_req.m_sharer_vec      = 1 << m_sid_cacheid;
                                    cmt_req.m_change_vec      = 1 << m_sid_cacheid;
                                   end
            endcase 

            //SysCo - start
            agent_idq = addrMgrConst::get_agent_ids_assoc2cacheid(cmt_req.m_owner_num);
            if(cmt_req.m_owner_val == 1 && snoop_enable_reg_txn[agent_idq[0]] == 0) begin
                cmt_req.m_owner_val = 0;
                cmt_req.m_owner_num = 0;
            end
            foreach(cmt_req.m_sharer_vec[x]) begin
                agent_idq = addrMgrConst::get_agent_ids_assoc2cacheid(x);
                if(cmt_req.m_sharer_vec[x] == 1 && snoop_enable_reg_txn[agent_idq[0]] == 0) begin
                    cmt_req.m_sharer_vec[x] = 0;
                end
            end
            //SysCo - end
            m_dm_pktq.push_back(cmt_req);
           `uvm_info(get_name(), $psprintf("[%-35s] (txnId: %5d) {%20s} (src: 0x%02h {%s}) (tgt: 0x%02h) (msgId: 0x%02h) (attid : 0x%02h) (rbid: 0x%02h) (addr: 0x%016h) (att: 0x%02h, %20s) (msgId: 0x%02h) (access: %20s) (updStat: %20s) (shareVec: 0x%04h) (owner: %1b/0x%02h)\n%s", "DceScbd-CmtPred-7", m_txn_id, m_initcmdupd_req_pkt.type2cmdname(), m_initcmdupd_req_pkt.smi_src_ncore_unit_id, addrMgrConst::get_cache_id_as_string(m_initcmdupd_req_pkt.smi_src_ncore_unit_id), m_initcmdupd_req_pkt.smi_targ_ncore_unit_id, m_initcmdupd_req_pkt.smi_msg_id, m_attid, m_rbid, cmt_req.m_addr, cmt_req.m_attid, cmt_req.m_attid_state.name(), cmt_req.m_msg_id, cmt_req.m_access_type.name(), cmt_req.m_status.name(), cmt_req.m_sharer_vec, cmt_req.m_owner_val, cmt_req.m_owner_num, cmt_req.convert2string()), UVM_MEDIUM);
    
        end else if (lkprsp_pktq[0].m_wr_required) begin
            m_states["dirreq"].set_expect();
            cmt_req = new("cmt_req");
            cmt_req.m_access_type     = DM_CMT_REQ;
            cmt_req.m_way_vec_or_mask = lkprsp_pktq[0].m_way_vec_or_mask;
            cmt_req.m_addr            = m_initcmdupd_req_pkt.smi_addr;
            cmt_req.m_ns              = m_initcmdupd_req_pkt.smi_ns;
            cmt_req.m_owner_val       = 0;
            cmt_req.m_owner_num       = 0;
            cmt_req.m_sharer_vec      = 0;
            cmt_req.m_change_vec      = ~(32'h0);
            m_dm_pktq.push_back(cmt_req);
           `uvm_info(get_name(), $psprintf("[%-35s] (txnId: %5d) {%20s} (src: 0x%02h {%s}) (tgt: 0x%02h) (msgId: 0x%02h) (attid : 0x%02h) (rbid: 0x%02h) (addr: 0x%016h) (att: 0x%02h, %20s) (msgId: 0x%02h) (access: %20s) (updStat: %20s) (shareVec: 0x%04h) (owner: %1b/0x%02h)\n%s", "DceScbd-CmtPred-8", m_txn_id, m_initcmdupd_req_pkt.type2cmdname(), m_initcmdupd_req_pkt.smi_src_ncore_unit_id, addrMgrConst::get_cache_id_as_string(m_initcmdupd_req_pkt.smi_src_ncore_unit_id), m_initcmdupd_req_pkt.smi_targ_ncore_unit_id, m_initcmdupd_req_pkt.smi_msg_id, m_attid, m_rbid, cmt_req.m_addr, cmt_req.m_attid, cmt_req.m_attid_state.name(), cmt_req.m_msg_id, cmt_req.m_access_type.name(), cmt_req.m_status.name(), cmt_req.m_sharer_vec, cmt_req.m_owner_val, cmt_req.m_owner_num, cmt_req.convert2string()), UVM_MEDIUM);
        end 
    end else if( dce_goldenref_model::is_stash_request(m_cmd_type)
                 && (m_states["snpreq"].get_valid_count() == 0) 
                 &&  m_states["snpreq"].is_complete() 
                 &&  m_states["snprsp"].is_complete() 
                 && lkprsp_pktq[0].m_sharer_vec != dm_lkprsp.m_sharer_vec
                 && m_states["dirreq"].is_complete()) begin
        m_states["dirreq"].set_expect();
        cmt_req = new("cmt_req");
        cmt_req.m_access_type = DM_CMT_REQ;
        cmt_req.m_way_vec_or_mask = lkprsp_pktq[0].m_way_vec_or_mask;
        cmt_req.m_addr            = m_initcmdupd_req_pkt.smi_addr;
        cmt_req.m_ns              = m_initcmdupd_req_pkt.smi_ns;
        cmt_req.m_owner_val       = lkprsp_pktq[0].m_owner_val;
        cmt_req.m_owner_num       = lkprsp_pktq[0].m_owner_num;
        cmt_req.m_sharer_vec      = lkprsp_pktq[0].m_sharer_vec;
        cmt_req.m_change_vec      = dm_lkprsp.m_sharer_vec ^ lkprsp_pktq[0].m_sharer_vec;
        m_dm_pktq.push_back(cmt_req);       
       `uvm_info(get_name(), $psprintf("[%-35s] (txnId: %5d) {%20s} (src: 0x%02h {%s}) (tgt: 0x%02h) (msgId: 0x%02h) (attid : 0x%02h) (rbid: 0x%02h) (addr: 0x%016h) (att: 0x%02h, %20s) (msgId: 0x%02h) (access: %20s) (updStat: %20s) (shareVec: 0x%04h) (owner: %1b/0x%02h)\n%s", "DceScbd-CmtPred-9", m_txn_id, m_initcmdupd_req_pkt.type2cmdname(), m_initcmdupd_req_pkt.smi_src_ncore_unit_id, addrMgrConst::get_cache_id_as_string(m_initcmdupd_req_pkt.smi_src_ncore_unit_id), m_initcmdupd_req_pkt.smi_targ_ncore_unit_id, m_initcmdupd_req_pkt.smi_msg_id, m_attid, m_rbid, cmt_req.m_addr, cmt_req.m_attid, cmt_req.m_attid_state.name(), cmt_req.m_msg_id, cmt_req.m_access_type.name(), cmt_req.m_status.name(), cmt_req.m_sharer_vec, cmt_req.m_owner_val, cmt_req.m_owner_num, cmt_req.convert2string()), UVM_MEDIUM);
    end

    if ((m_states["snpreq"].get_valid_count() >= 1) 
             &&  m_states["snpreq"].is_complete() 
             &&  m_states["snprsp"].is_complete()
           ) begin
        snarf = 0;
        dt_done = 0;
        aggregate_dt_aiu = 0;
        snprsp_error = 0;
        foreach(m_drvsnp_rsp_pktq[i]) begin
            snprsp_error |= m_drvsnp_rsp_pktq[i].smi_cmstatus_err;
            if(!m_drvsnp_rsp_pktq[i].smi_cmstatus_err) begin
                snarf |= m_drvsnp_rsp_pktq[i].smi_cmstatus_snarf;
                dt_done |= (m_drvsnp_rsp_pktq[i].smi_cmstatus_dt_dmi  | m_drvsnp_rsp_pktq[i].smi_cmstatus_dt_aiu);
                aggregate_dt_aiu |= m_drvsnp_rsp_pktq[i].smi_cmstatus_dt_aiu;
            end
        end
        if(snprsp_error == 1) begin
            requestor_cache_id = addrMgrConst::get_cache_id(m_initcmdupd_req_pkt.smi_src_ncore_unit_id);
            snooper_agentid = addrMgrConst::agentid_assoc2funitid(m_drvsnp_rsp_pktq[0].smi_src_ncore_unit_id);
            if(m_cmd_type inside {CMD_RD_NITC, CMD_CLN_VLD, CMD_CLN_SH_PER} && (lkprsp_pktq[0].m_wr_required == 0) 
               && !((addrMgrConst::get_native_interface(snooper_agentid) inside {addrMgrConst::CHI_A_AIU,addrMgrConst::CHI_B_AIU,addrMgrConst::CHI_E_AIU})
                    && (m_drvsnp_rsp_pktq[0].smi_cmstatus_err_payload == 'b100))) begin //If (Address Error && CHI Snooper), DCE will invalidate the Snooper in SF, so expect cmt_req. Refer CONC-16847
                m_dm_pktq.delete(m_dm_pktq.size()-1);
                m_states["dirreq"].clear_one_expect();
            end

            case (m_expsnp_req_pktq[0].smi_msg_type)
            SNP_CLN_DTR, SNP_VLD_DTR, SNP_NOSDINT, SNP_NITC:
            begin
                if(m_dm_pktq[m_dm_pktq.size()-1].m_access_type == DM_CMT_REQ) begin
                   if (m_drvsnp_rsp_pktq[0].smi_cmstatus_err_payload == 'b100     //If (Address Error && CHI Snooper), DCE will invalidate the Snooper in SF. Refer CONC-16847
                   && (addrMgrConst::get_native_interface(snooper_agentid) inside {addrMgrConst::CHI_A_AIU,addrMgrConst::CHI_B_AIU,addrMgrConst::CHI_E_AIU})) begin
                       m_dm_pktq[m_dm_pktq.size()-1].m_owner_val   =  0; 
                       m_dm_pktq[m_dm_pktq.size()-1].m_owner_num   =  0; 
                       m_dm_pktq[m_dm_pktq.size()-1].m_sharer_vec  =  0;
                   end else begin
                       m_dm_pktq[m_dm_pktq.size()-1].m_owner_val   =  (lkprsp_pktq[0].m_owner_num == requestor_cache_id) ? 0 : lkprsp_pktq[0].m_owner_val; 
                       m_dm_pktq[m_dm_pktq.size()-1].m_owner_num   =  (lkprsp_pktq[0].m_owner_num == requestor_cache_id) ? 0 : lkprsp_pktq[0].m_owner_num; 
                       m_dm_pktq[m_dm_pktq.size()-1].m_sharer_vec  =  lkprsp_pktq[0].m_sharer_vec & (~(1 << requestor_cache_id));
                   end
                   `uvm_info(get_name(), $psprintf("[%-35s] (txnId: %5d) {%20s} (src: 0x%02h {%s}) (tgt: 0x%02h) (msgId: 0x%02h) (attid : 0x%02h) (rbid: 0x%02h) (addr: 0x%016h) (att: 0x%02h, %20s) (msgId: 0x%02h) (access: %20s) (updStat: %20s) (shareVec: 0x%04h) (owner: %1b/0x%02h)\n%s", "DceScbd-CmtErrOvride-1", m_txn_id, m_initcmdupd_req_pkt.type2cmdname(), m_initcmdupd_req_pkt.smi_src_ncore_unit_id, addrMgrConst::get_cache_id_as_string(m_initcmdupd_req_pkt.smi_src_ncore_unit_id), m_initcmdupd_req_pkt.smi_targ_ncore_unit_id, m_initcmdupd_req_pkt.smi_msg_id, m_attid, m_rbid, cmt_req.m_addr, cmt_req.m_attid, cmt_req.m_attid_state.name(), cmt_req.m_msg_id, cmt_req.m_access_type.name(), cmt_req.m_status.name(), cmt_req.m_sharer_vec, cmt_req.m_owner_val, cmt_req.m_owner_num, cmt_req.convert2string()), UVM_MEDIUM);
                end
            end
            SNP_CLN_DTW:
            begin
                if(m_dm_pktq[m_dm_pktq.size()-1].m_access_type == DM_CMT_REQ) begin
                    if (m_drvsnp_rsp_pktq[0].smi_cmstatus_err_payload == 'b100     //If (Address Error && CHI Snooper), DCE will invalidate the Snooper in SF. Refer CONC-16847
                    && (addrMgrConst::get_native_interface(snooper_agentid) inside {addrMgrConst::CHI_A_AIU,addrMgrConst::CHI_B_AIU,addrMgrConst::CHI_E_AIU})) begin
                        m_dm_pktq[m_dm_pktq.size()-1].m_owner_val   =  0; 
                        m_dm_pktq[m_dm_pktq.size()-1].m_owner_num   =  0; 
                        m_dm_pktq[m_dm_pktq.size()-1].m_sharer_vec  =  0;
                    end else begin
                       m_dm_pktq[m_dm_pktq.size()-1].m_owner_val   =  (lkprsp_pktq[0].m_owner_num == requestor_cache_id) ? 0 : lkprsp_pktq[0].m_owner_val; 
                       m_dm_pktq[m_dm_pktq.size()-1].m_owner_num   =  (lkprsp_pktq[0].m_owner_num == requestor_cache_id) ? 0 : lkprsp_pktq[0].m_owner_num; 
                       m_dm_pktq[m_dm_pktq.size()-1].m_sharer_vec  =  lkprsp_pktq[0].m_sharer_vec & (~(1 << requestor_cache_id));
                    end
                    `uvm_info(get_name(), $psprintf("[%-35s] (txnId: %5d) {%20s} (src: 0x%02h {%s}) (tgt: 0x%02h) (msgId: 0x%02h) (attid : 0x%02h) (rbid: 0x%02h) (addr: 0x%016h) (att: 0x%02h, %20s) (msgId: 0x%02h) (access: %20s) (updStat: %20s) (shareVec: 0x%04h) (owner: %1b/0x%02h)\n%s", "DceScbd-CmtErrOvride-2", m_txn_id, m_initcmdupd_req_pkt.type2cmdname(), m_initcmdupd_req_pkt.smi_src_ncore_unit_id, addrMgrConst::get_cache_id_as_string(m_initcmdupd_req_pkt.smi_src_ncore_unit_id), m_initcmdupd_req_pkt.smi_targ_ncore_unit_id, m_initcmdupd_req_pkt.smi_msg_id, m_attid, m_rbid, cmt_req.m_addr, cmt_req.m_attid, cmt_req.m_attid_state.name(), cmt_req.m_msg_id, cmt_req.m_access_type.name(), cmt_req.m_status.name(), cmt_req.m_sharer_vec, cmt_req.m_owner_val, cmt_req.m_owner_num, cmt_req.convert2string()), UVM_MEDIUM);
                end
            end
            SNP_INV_DTR:
            begin
                if(m_dm_pktq[m_dm_pktq.size()-1].m_access_type == DM_CMT_REQ) begin
                   m_dm_pktq[m_dm_pktq.size()-1].m_owner_val   =  0;  
                   m_dm_pktq[m_dm_pktq.size()-1].m_owner_num   =  0;  
                   m_dm_pktq[m_dm_pktq.size()-1].m_sharer_vec  =  0;
                   `uvm_info(get_name(), $psprintf("[%-35s] (txnId: %5d) {%20s} (src: 0x%02h {%s}) (tgt: 0x%02h) (msgId: 0x%02h) (attid : 0x%02h) (rbid: 0x%02h) (addr: 0x%016h) (att: 0x%02h, %20s) (msgId: 0x%02h) (access: %20s) (updStat: %20s) (shareVec: 0x%04h) (owner: %1b/0x%02h)\n%s", "DceScbd-CmtErrOvride-3", m_txn_id, m_initcmdupd_req_pkt.type2cmdname(), m_initcmdupd_req_pkt.smi_src_ncore_unit_id, addrMgrConst::get_cache_id_as_string(m_initcmdupd_req_pkt.smi_src_ncore_unit_id), m_initcmdupd_req_pkt.smi_targ_ncore_unit_id, m_initcmdupd_req_pkt.smi_msg_id, m_attid, m_rbid, cmt_req.m_addr, cmt_req.m_attid, cmt_req.m_attid_state.name(), cmt_req.m_msg_id, cmt_req.m_access_type.name(), cmt_req.m_status.name(), cmt_req.m_sharer_vec, cmt_req.m_owner_val, cmt_req.m_owner_num, cmt_req.convert2string()), UVM_MEDIUM);
                end
            end
            SNP_INV_DTW, SNP_INV, SNP_NITCCI, SNP_NITCMI:
            begin
                if(m_dm_pktq[m_dm_pktq.size()-1].m_access_type == DM_CMT_REQ) begin
                   m_dm_pktq[m_dm_pktq.size()-1].m_owner_val   =  0;  
                   m_dm_pktq[m_dm_pktq.size()-1].m_owner_num   =  0;  
                   m_dm_pktq[m_dm_pktq.size()-1].m_sharer_vec  =  0;
                   m_dm_pktq[m_dm_pktq.size()-1].m_change_vec  =  lkprsp_pktq[0].m_sharer_vec; //CONC-16245 When SnpResp.Err for Invalidating Snoop DCE clears the corresponding snoopee entry in it's SF, thus sharer_vec must be cleared, hence change_vec reassigned from lkp_rsp.
                   `uvm_info(get_name(), $psprintf("[%-35s] (txnId: %5d) {%20s} (src: 0x%02h {%s}) (tgt: 0x%02h) (msgId: 0x%02h) (attid : 0x%02h) (rbid: 0x%02h) (addr: 0x%016h) (att: 0x%02h, %20s) (msgId: 0x%02h) (access: %20s) (updStat: %20s) (shareVec: 0x%04h) (owner: %1b/0x%02h) (changeVec: 0x%04h)\n%s", "DceScbd-CmtErrOvride-4", m_txn_id, m_initcmdupd_req_pkt.type2cmdname(), m_initcmdupd_req_pkt.smi_src_ncore_unit_id, addrMgrConst::get_cache_id_as_string(m_initcmdupd_req_pkt.smi_src_ncore_unit_id), m_initcmdupd_req_pkt.smi_targ_ncore_unit_id, m_initcmdupd_req_pkt.smi_msg_id, m_attid, m_rbid, cmt_req.m_addr, cmt_req.m_attid, cmt_req.m_attid_state.name(), cmt_req.m_msg_id, cmt_req.m_access_type.name(), cmt_req.m_status.name(), cmt_req.m_sharer_vec, cmt_req.m_owner_val, cmt_req.m_owner_num, cmt_req.m_change_vec, cmt_req.convert2string()), UVM_MEDIUM);
                end
            end
            SNP_INV_STSH, SNP_UNQ_STSH:
            begin
                if(snarf != 1) begin
                    if(m_dm_pktq[m_dm_pktq.size()-1].m_access_type == DM_CMT_REQ) begin
                       m_dm_pktq[m_dm_pktq.size()-1].m_owner_val   =  0;  
                       m_dm_pktq[m_dm_pktq.size()-1].m_owner_num   =  0;  
                       m_dm_pktq[m_dm_pktq.size()-1].m_sharer_vec  =  0;
                       `uvm_info(get_name(), $psprintf("[%-35s] (txnId: %5d) {%20s} (src: 0x%02h {%s}) (tgt: 0x%02h) (msgId: 0x%02h) (attid : 0x%02h) (rbid: 0x%02h) (addr: 0x%016h) (att: 0x%02h, %20s) (msgId: 0x%02h) (access: %20s) (updStat: %20s) (shareVec: 0x%04h) (owner: %1b/0x%02h)\n%s", "DceScbd-CmtErrOvride-5", m_txn_id, m_initcmdupd_req_pkt.type2cmdname(), m_initcmdupd_req_pkt.smi_src_ncore_unit_id, addrMgrConst::get_cache_id_as_string(m_initcmdupd_req_pkt.smi_src_ncore_unit_id), m_initcmdupd_req_pkt.smi_targ_ncore_unit_id, m_initcmdupd_req_pkt.smi_msg_id, m_attid, m_rbid, cmt_req.m_addr, cmt_req.m_attid, cmt_req.m_attid_state.name(), cmt_req.m_msg_id, cmt_req.m_access_type.name(), cmt_req.m_status.name(), cmt_req.m_sharer_vec, cmt_req.m_owner_val, cmt_req.m_owner_num, cmt_req.convert2string()), UVM_MEDIUM);
                    end
                end

            end
            SNP_STSH_UNQ:
            begin
                if(snarf != 1) begin
                    if(m_dm_pktq[m_dm_pktq.size()-1].m_access_type == DM_CMT_REQ) begin
                       if ((m_drvsnp_rsp_pktq[0].smi_cmstatus_err_payload == 'b100
                       && (m_drvsnp_rsp_pktq[0].smi_src_ncore_unit_id != m_initcmdupd_req_pkt.smi_mpf1_stash_nid) //Refer CONC-17393, do not invalidate cahcheline for Stash Unique & Stash Shared when (CHI snooping agent && SnpResp.Err && Snooper == stashing target)
                       && addrMgrConst::get_native_interface(snooper_agentid) inside {addrMgrConst::CHI_A_AIU,addrMgrConst::CHI_B_AIU,addrMgrConst::CHI_E_AIU})) begin
                           m_dm_pktq[m_dm_pktq.size()-1].m_owner_val   =  0; 
                           m_dm_pktq[m_dm_pktq.size()-1].m_owner_num   =  0; 
                           m_dm_pktq[m_dm_pktq.size()-1].m_sharer_vec  =  0;
                       end else begin
                           m_dm_pktq[m_dm_pktq.size()-1].m_owner_val   =  lkprsp_pktq[0].m_owner_val; 
                           m_dm_pktq[m_dm_pktq.size()-1].m_owner_num   =  lkprsp_pktq[0].m_owner_num; 
    
                           //SANJEEV: Fix Place 2/2: So called a spec change(now) in Ncore3.7 by RTL team (Unofficial, unreviwed, unlisted though). This is actually an RTL bug denied earlier(before 3.7), termed as  a DCE TB bug and is being called as a spec update in 3.7 by RTL team. Stash target holding the line in Dirty state and is being removed from the directory upon snoop error leading to loss of latest data.
                           //		Interested party may follow these Jira's and connected jiras for my arguments in Ncore 3.6.  Fix: CONC-15992. Revert CONC-14466, CONC-15458. Tag: CONC-15081, CONC-16087, CONC-15459
                           //            Unfortunately DCE-DV does not have a jira to represent it as spec change to verify this change. DCE-DV owner's efforts are dubbed as a simple regression triage by DV team(CONC-15992)
                           //SANJEEV: m_dm_pktq[m_dm_pktq.size()-1].m_sharer_vec  =  lkprsp_pktq[0].m_sharer_vec & (~(1 << addrMgrConst::get_cache_id(m_initcmdupd_req_pkt.smi_mpf1_stash_nid)));
                           m_dm_pktq[m_dm_pktq.size()-1].m_sharer_vec  =  lkprsp_pktq[0].m_sharer_vec;
                       end

                       `uvm_info(get_name(), $psprintf("[%-35s] (txnId: %5d) {%20s} (src: 0x%02h {%s}) (tgt: 0x%02h) (msgId: 0x%02h) (attid : 0x%02h) (rbid: 0x%02h) (addr: 0x%016h) (att: 0x%02h, %20s) (msgId: 0x%02h) (access: %20s) (updStat: %20s) (shareVec: 0x%04h) (owner: %1b/0x%02h)\n%s", "DceScbd-CmtErrOvride-6", m_txn_id, m_initcmdupd_req_pkt.type2cmdname(), m_initcmdupd_req_pkt.smi_src_ncore_unit_id, addrMgrConst::get_cache_id_as_string(m_initcmdupd_req_pkt.smi_src_ncore_unit_id), m_initcmdupd_req_pkt.smi_targ_ncore_unit_id, m_initcmdupd_req_pkt.smi_msg_id, m_attid, m_rbid, cmt_req.m_addr, cmt_req.m_attid, cmt_req.m_attid_state.name(), cmt_req.m_msg_id, m_dm_pktq[m_dm_pktq.size()-1].m_access_type.name(), cmt_req.m_status.name(), m_dm_pktq[m_dm_pktq.size()-1].m_sharer_vec,  m_dm_pktq[m_dm_pktq.size()-1].m_owner_val, m_dm_pktq[m_dm_pktq.size()-1].m_owner_num, cmt_req.convert2string()), UVM_MEDIUM);
                    end
                end
            end
            SNP_STSH_SH:
            begin
                if(snarf != 1) begin
                    if(m_dm_pktq[m_dm_pktq.size()-1].m_access_type == DM_CMT_REQ) begin
                       if ((m_drvsnp_rsp_pktq[0].smi_cmstatus_err_payload == 'b100
                       && (m_drvsnp_rsp_pktq[0].smi_src_ncore_unit_id != m_initcmdupd_req_pkt.smi_mpf1_stash_nid) //Refer CONC-17393, do not invalidate cahcheline for Stash Unique & Stash Shared when (CHI snooping agent && SnpResp.Err && Snooper == stashing target)
                       && addrMgrConst::get_native_interface(snooper_agentid) inside {addrMgrConst::CHI_A_AIU,addrMgrConst::CHI_B_AIU,addrMgrConst::CHI_E_AIU})) begin
                           m_dm_pktq[m_dm_pktq.size()-1].m_owner_val   =  0; 
                           m_dm_pktq[m_dm_pktq.size()-1].m_owner_num   =  0; 
                           m_dm_pktq[m_dm_pktq.size()-1].m_sharer_vec  =  0;
                       end else begin
                           m_dm_pktq[m_dm_pktq.size()-1].m_owner_val   =  lkprsp_pktq[0].m_owner_val; 
                           m_dm_pktq[m_dm_pktq.size()-1].m_owner_num   =  lkprsp_pktq[0].m_owner_num; 
                           m_dm_pktq[m_dm_pktq.size()-1].m_sharer_vec  =  lkprsp_pktq[0].m_sharer_vec;
                       end
                       `uvm_info(get_name(), $psprintf("[%-35s] (txnId: %5d) {%20s} (src: 0x%02h {%s}) (tgt: 0x%02h) (msgId: 0x%02h) (attid : 0x%02h) (rbid: 0x%02h) (addr: 0x%016h) (att: 0x%02h, %20s) (msgId: 0x%02h) (access: %20s) (updStat: %20s) (shareVec: 0x%04h) (owner: %1b/0x%02h)\n%s", "DceScbd-CmtErrOvride-7", m_txn_id, m_initcmdupd_req_pkt.type2cmdname(), m_initcmdupd_req_pkt.smi_src_ncore_unit_id, addrMgrConst::get_cache_id_as_string(m_initcmdupd_req_pkt.smi_src_ncore_unit_id), m_initcmdupd_req_pkt.smi_targ_ncore_unit_id, m_initcmdupd_req_pkt.smi_msg_id, m_attid, m_rbid, cmt_req.m_addr, cmt_req.m_attid, cmt_req.m_attid_state.name(), cmt_req.m_msg_id, cmt_req.m_access_type.name(), cmt_req.m_status.name(), cmt_req.m_sharer_vec, cmt_req.m_owner_val, cmt_req.m_owner_num, cmt_req.convert2string()), UVM_MEDIUM);
                    end
                end
            end
            endcase
        end
    end

    // Setting all bits of Change_Vec incase of wr_required
    if (lkprsp_pktq[0].m_wr_required) begin
        m_dm_pktq[m_dm_pktq.size()-1].m_change_vec = ~(32'h0);
    end
    else if(dm_lkprsp.m_sharer_vec != lkprsp_pktq[0].m_sharer_vec) begin
        m_dm_pktq[m_dm_pktq.size()-1].m_change_vec = m_dm_pktq[m_dm_pktq.size()-1].m_change_vec | (dm_lkprsp.m_sharer_vec ^ lkprsp_pktq[0].m_sharer_vec);
    end
    
endfunction: predict_dm_cmt_req

//**************************************************************************
function void dce_scb_txn::predict_mrd_req_stash_ops();
    dm_seq_item lkpq[$], cohreq_pktq[$];
    bit snarf = 0;
    bit predict_mrd = 0;
    eMsgMRD mrd_type;
    bit [WSMIMPF1-1:0] exp_mpf1_dtr_tgt_id; 
    bit [WSMIMPF2-1:0] exp_mpf2_dtr_msg_id; 
    smi_intfsize_t exp_intfsize; 

    if (dce_goldenref_model::cmdreq2mrdreq.exists(m_cmd_type) == 0) begin 
        m_states["mrdreq"].set_complete();
        m_states["mrdrsp"].set_complete();
        return;
    end

    lkpq = m_dm_pktq.find(item) with (item.m_access_type == DM_LKP_RSP);
    cohreq_pktq = m_dm_pktq.find(item) with (item.m_access_type == DM_CMD_REQ);
    
    if (lkpq.size != 1)
        `uvm_error("DCE_SCB_TXN", "Multiple DM LKP_RSP not possible");
    
    //assign defaults first.
    exp_mpf1_dtr_tgt_id = m_initcmdupd_req_pkt.smi_src_id >> WSMINCOREPORTID;
        exp_mpf2_dtr_msg_id = m_initcmdupd_req_pkt.smi_msg_id;
    exp_intfsize        = m_initcmdupd_req_pkt.smi_intfsize;
    
    //Note: MrdReq is not issued if there is a peer owner, else MrdPref is issued for target not identified case.
    if (   (m_states["snpreq"].get_valid_count() == 0) 
         && m_states["snpreq"].is_complete() 
         && m_states["snprsp"].is_complete()
         && (!lkpq[0].m_owner_val || (lkpq[0].m_owner_num == m_iid_cacheid))) begin   //snps not sent nor expected i.e target not identified case
        predict_mrd = 1;    
        mrd_type = dce_goldenref_model::cmdreq2mrdreq[m_cmd_type][DEF];
    
    end else if(    (m_states["snpreq"].get_valid_count() >= 1) 
                 && m_states["snpreq"].is_complete() 
                 && m_states["snprsp"].is_complete() ) begin //target identified and all snooping is complete
    
    if(m_drvsnp_rsp_pktq[0].smi_cmstatus_err == 0)
            snarf =  m_drvsnp_rsp_pktq[0].smi_cmstatus_snarf;
    else
        snarf = 0;

        if (snarf == 1) begin 
            predict_mrd = 1;
            exp_mpf1_dtr_tgt_id = m_initcmdupd_req_pkt.smi_mpf1_stash_nid;
                exp_mpf2_dtr_msg_id = m_drvsnp_rsp_pktq[0].smi_mpf1_dtr_msg_id;
            exp_intfsize        = m_drvsnp_rsp_pktq[0].smi_intfsize;
            if(m_cmd_type == CMD_LD_CCH_UNQ) begin
                mrd_type = dce_goldenref_model::cmdreq2mrdreq[m_cmd_type][UNQ];
            end else if (m_cmd_type == CMD_LD_CCH_SH) begin
                if (lkpq[0].is_dm_miss())
                    mrd_type = dce_goldenref_model::cmdreq2mrdreq[m_cmd_type][SHD];
                else begin // DM_HIT
                    if( m_drvsnp_rsp_pktq[0].smi_cmstatus_rv && !m_drvsnp_rsp_pktq[0].smi_cmstatus_rs && $onehot(lkpq[0].m_sharer_vec)) // target OWNER and all peers IX, so it might be in UCE and hence "MRD_RD_WITH_UNQ_CLN"
                        mrd_type = dce_goldenref_model::cmdreq2mrdreq[m_cmd_type][UNQ];
                    else  // Other Scenarios
                        mrd_type = dce_goldenref_model::cmdreq2mrdreq[m_cmd_type][SHD];
                end
            end
        end// snarf==1
    end//target identified and all snooping done.

    //CONC-5805 MRD_PREF RL='h1
    //For all other MRDs(stashing ops) = RL = 'h3
    if (predict_mrd) begin
        m_states["mrdreq"].set_expect();
        m_expmrd_req_pkt = new("mrd_req_pkt");
        m_expmrd_req_pkt.t_smi_ndp_valid = 0;
        //TODO: File a bug that CMDreq.mpf1 MSB bit(StashValid) should not be carried over to MRDreq.mpf1. 
        //RTL asserts MSB bit of mpf1_dtr_tgt_id if stash is accepted. For now match RTL so that ndp_protection is correctly predicted by DV
        m_expmrd_req_pkt.smi_ndp[MRD_REQ_MPF1_MSB:MRD_REQ_MPF1_LSB] = m_initcmdupd_req_pkt.smi_ndp[CMD_REQ_MPF1_MSB:CMD_REQ_MPF1_LSB] ;

        //#Check.DCE.MrdReq_Type
        m_expmrd_req_pkt.construct_mrdmsg(
            .smi_targ_ncore_unit_id (m_dmiid),
            .smi_src_ncore_unit_id  (addrMgrConst::get_dce_funitid(<%=obj.Id%>)),
            .smi_msg_tier           ('h0),
            .smi_steer              ('h0),
            .smi_msg_qos            ('h0),
            .smi_msg_pri            (m_initcmdupd_req_pkt.smi_msg_pri),
            .smi_msg_type           (mrd_type),
            .smi_msg_id             (m_attid),
            .smi_msg_err            ('h0),
            .smi_cmstatus           ('h0),
            .smi_addr               (m_initcmdupd_req_pkt.smi_addr),
            .smi_ns                 (m_initcmdupd_req_pkt.smi_ns),
            .smi_ac                 (m_initcmdupd_req_pkt.smi_ac),
            .smi_vz                 (m_initcmdupd_req_pkt.smi_vz),
            .smi_pr                 (m_initcmdupd_req_pkt.smi_pr),
            .smi_rl                 ((mrd_type == MRD_PREF) ? 'h1 : 'h3),
            .smi_tm                 (m_initcmdupd_req_pkt.smi_tm),
            .smi_mpf1_dtr_tgt_id    (exp_mpf1_dtr_tgt_id), //dont care but match RTL so DV can compute ndp_prot bits  //#Check.DCE.MrdReq_mpf1
            .smi_mpf2_dtr_msg_id    (exp_mpf2_dtr_msg_id), //dont care but match RTL so DV can compute ndp_prot bits  //#Check.DCE.MrdReq_mpf2
            .smi_size               (m_initcmdupd_req_pkt.smi_size),
            .smi_intfsize           (exp_intfsize), //CONC-11129
            .smi_qos                (m_initcmdupd_req_pkt.smi_qos),
            .smi_ndp_aux            (m_initcmdupd_req_pkt.smi_ndp_aux) // CONC-13177, CONC-13223
        );
    end else begin
        m_states["mrdreq"].set_complete();
        m_states["mrdrsp"].set_complete();
    end 

endfunction: predict_mrd_req_stash_ops

//**************************************************************************
function void dce_scb_txn::predict_mrd_req();
    int discard;
    bit aggregate_dt_aiu, issue_mrd;
    dm_seq_item lkpq[$], cmtq[$];
    eMsgMRD mrd_type;
    int fnd_err_idxq[$], fnd_dtaiu_idxq[$];
    int agent_idq[$];
    int max_credits;
    string credits_msg;
    
    if (dce_goldenref_model::cmdreq2mrdreq.exists(m_cmd_type) == 0) begin 
        m_states["mrdreq"].set_complete();
        m_states["mrdrsp"].set_complete();
        return;
    end

    lkpq = m_dm_pktq.find(item) with (item.m_access_type == DM_LKP_RSP);
    cmtq = m_dm_pktq.find(item) with (item.m_access_type == DM_CMT_REQ);
    
    if (lkpq.size != 1)
        `uvm_error("DCE_SCB_TXN", "Multiple DM LKP_RSP not possible");

    agent_idq = addrMgrConst::get_agent_ids_assoc2cacheid(lkpq[0].m_owner_num);
    if(lkpq[0].m_owner_val == 1 && snoop_enable_reg_txn[agent_idq[0]] == 0) begin
        lkpq[0].m_owner_val = 0;
        lkpq[0].m_owner_num = 0;
    end

    foreach(lkpq[0].m_sharer_vec[x]) begin
        agent_idq = addrMgrConst::get_agent_ids_assoc2cacheid(x);
        if(lkpq[0].m_sharer_vec[x] == 1 && snoop_enable_reg_txn[agent_idq[0]] == 0) begin
            lkpq[0].m_sharer_vec[x] = 0;
        end
    end

    if (   (m_states["snpreq"].get_valid_count() == 0) 
         && m_states["snpreq"].is_complete() 
         && m_states["snprsp"].is_complete() ) begin   //snps not required

        if ( lkpq[0].is_dm_miss() ||                                           //dm_miss
            (!lkpq[0].is_dm_miss && (lkpq[0].m_sharer_vec == (1 << m_iid_cacheid))) //dm_hit and there are no other sharers
           ) begin
            issue_mrd = 1;
            mrd_type = dce_goldenref_model::cmdreq2mrdreq[m_cmd_type].exists(UNQ) ? dce_goldenref_model::cmdreq2mrdreq[m_cmd_type][UNQ] : dce_goldenref_model::cmdreq2mrdreq[m_cmd_type][DEF];
           
            //CONC-6375 A Read from ACE master that hits directory in unique state ie its owner, MRD_RD_WITH_UNQ_CLN is sent out
            if (    (m_initcmdupd_req_pkt.smi_tof == 'h2) //ACE
                 && (m_cmd_type == CMD_RD_UNQ)
                 && ((m_iid_cacheid != -1) && lkpq[0].m_owner_val 
                 && (lkpq[0].m_owner_num == m_iid_cacheid))) begin
                mrd_type = eMsgMRD'(MRD_RD_WITH_UNQ_CLN);
            end
        
        end 
    
        //dm_hit and there are other sharers.
        else if (!lkpq[0].is_dm_miss() && (lkpq[0].m_sharer_vec != (1 << m_iid_cacheid))) begin 
            issue_mrd = 1;
            mrd_type = dce_goldenref_model::cmdreq2mrdreq[m_cmd_type].exists(SHD) ? dce_goldenref_model::cmdreq2mrdreq[m_cmd_type][SHD] : dce_goldenref_model::cmdreq2mrdreq[m_cmd_type][DEF];
        end 
        //CONC-6401 A RO from ACE master
        if ((m_initcmdupd_req_pkt.smi_tof == 'h2) && (m_iid_cacheid != -1) && (m_cmd_type == CMD_RD_NITC)) begin  //RO from ACE master
            if (requestor_dirlkp_state_is_valid(lkpq[0]) == 0) begin //requestor is not valid
                mrd_type = eMsgMRD'(MRD_RD_WITH_INV);
            end else begin  //requestor is valid
                if (lkpq[0].m_sharer_vec == (1 << m_iid_cacheid)) //requestor hits dir in unique state
                    mrd_type = eMsgMRD'(MRD_RD_WITH_UNQ_CLN);
                else //requestor hits dir in shared state
                    mrd_type = eMsgMRD'(MRD_RD_WITH_SHR_CLN);
            end
        end
    end //snps not required
    else if (  (m_states["snpreq"].get_valid_count() >= 1) 
             && m_states["snpreq"].is_complete() 
             && m_states["snprsp"].is_complete() ) begin   //snps required and are done

        fnd_err_idxq   = m_drvsnp_rsp_pktq.find_index(item) with (item.smi_cmstatus_err == 1);
        fnd_dtaiu_idxq = m_drvsnp_rsp_pktq.find_index(item) with ((item.smi_cmstatus_err == 0) && (item.smi_cmstatus_dt_aiu == 1)); 

        //CONC-6773 see Tso-Wei comment, do not expect Mrd if error on SNPrsp and no other snooper is doing a dt_aiu 
        if (fnd_err_idxq.size() != 0 && fnd_dtaiu_idxq.size() == 0) begin 
            m_states["mrdreq"].set_complete();
            m_states["mrdrsp"].set_complete();
            return;
        end

        if (fnd_dtaiu_idxq.size() == 0) begin
            issue_mrd = 1; 
            if (    (m_cmd_type inside {CMD_CLN_VLD, CMD_CLN_SH_PER}) 
                 || ((m_cmd_type == CMD_RD_NITC) && !((m_initcmdupd_req_pkt.smi_tof == 'h2) && (m_iid_cacheid != -1)))) begin //A RO not from ACE
                mrd_type = dce_goldenref_model::cmdreq2mrdreq[m_cmd_type][DEF];
            end else begin 
                //CONC-6401 A RO from ACE master
                if ((m_cmd_type == CMD_RD_NITC) && (m_initcmdupd_req_pkt.smi_tof == 'h2) && (m_iid_cacheid != -1)) begin //RO from ACE
                    if (requestor_dirlkp_state_is_valid(lkpq[0]) == 0) begin//requestor is invalid
                        mrd_type = eMsgMRD'(MRD_RD_WITH_INV);
                    end else begin 
                        //since owner downgraded to IX, and there are no other sharers the requestor is promoted to UC(from SC)
                        if ($countones(lkpq[0].m_sharer_vec) == 2 && m_drvsnp_rsp_pktq[0].smi_cmstatus_rv == 0)
                            mrd_type = eMsgMRD'(MRD_RD_WITH_UNQ_CLN);
                        else 
                            mrd_type = eMsgMRD'(MRD_RD_WITH_SHR_CLN);
                    end
                end else if ((m_cmd_type == CMD_RD_UNQ) && 
                             (m_initcmdupd_req_pkt.smi_tof == 'h2) && (m_iid_cacheid != -1) //ACE master
                              && lkpq[0].m_owner_val && (lkpq[0].m_owner_num == m_iid_cacheid)) begin //requestor is in SD(owner)
                              //CONC-6711 RdUnq from ACE(SD) should issue MrdRdWUnqCln, i.e ACE master in owner state should always issue MrdRdWUnqCln
                    
                        mrd_type = eMsgMRD'(MRD_RD_WITH_UNQ_CLN);
                end else begin // !(RO from ACE)
                    if (cmtq.size() != 1)
                        `uvm_error("DCE_SCB_TXN", $psprintf("There should be at least one CMT_REQ for cmd_type: %0p", m_cmd_type));
                    if ($onehot(cmtq[0].m_sharer_vec)) begin
                        mrd_type = dce_goldenref_model::cmdreq2mrdreq[m_cmd_type].exists(UNQ) ? dce_goldenref_model::cmdreq2mrdreq[m_cmd_type][UNQ] : dce_goldenref_model::cmdreq2mrdreq[m_cmd_type][DEF];
                    end else begin //sharer vec is not onehot
                        mrd_type = dce_goldenref_model::cmdreq2mrdreq[m_cmd_type].exists(SHD) ? dce_goldenref_model::cmdreq2mrdreq[m_cmd_type][SHD] : dce_goldenref_model::cmdreq2mrdreq[m_cmd_type][DEF];
                    end
                end //!(RO from ACE)
            end
        end //aggregate dt_aiu == 0 
    end  //snps required and done

    //See CONC-5206 for reference
    //For CMO MRDs i.e MrdFlush, MrdCln & MrdInv RL must be 2'b10 and 2'b01 in rest of the cases.

    if(issue_mrd) begin
    $sformat(credits_msg, "dce%0d_dmi%0d_nMrdInFlight", addrMgrConst::get_dce_funitid(<%=obj.Id%>), m_initcmdupd_req_pkt.smi_dest_id);
        m_credits.get_max_credit(credits_msg, max_credits);
    if(max_credits == 0) begin
        credit_zero_err = 1;
        predict_zero_mrd_credits();
        issue_mrd = 0;
    end
    end
     
    //#Check.DCE.MrdReq_Type
    if (issue_mrd) begin
        m_states["mrdreq"].set_expect();
        m_expmrd_req_pkt = new("mrd_req_pkt");
        m_expmrd_req_pkt.t_smi_ndp_valid = 0;
        m_expmrd_req_pkt.construct_mrdmsg(
            .smi_targ_ncore_unit_id (m_initcmdupd_req_pkt.smi_dest_id),
            .smi_src_ncore_unit_id  (addrMgrConst::get_dce_funitid(<%=obj.Id%>)),
            .smi_msg_tier           ('h0),
            .smi_steer              ('h0),
            .smi_msg_qos            ('h0),
            .smi_msg_pri            (m_initcmdupd_req_pkt.smi_msg_pri),
            .smi_msg_type           (mrd_type), //#Check.DCE.MrdReq_Type
            .smi_msg_id             (m_attid),
            .smi_msg_err            ('h0),
            .smi_cmstatus           ('h0),
            .smi_tm                 (m_initcmdupd_req_pkt.smi_tm),
            .smi_addr               (m_initcmdupd_req_pkt.smi_addr),
            .smi_ns                 (m_initcmdupd_req_pkt.smi_ns),
            .smi_ac                 (m_initcmdupd_req_pkt.smi_ac), //#Check.DCE.MrdReq_Attr_PassThru
            .smi_vz                 (m_initcmdupd_req_pkt.smi_vz),
            .smi_pr                 (m_initcmdupd_req_pkt.smi_pr),
            .smi_rl                 ((mrd_type inside {MRD_CLN, MRD_FLUSH, MRD_INV}) ? 'h2 : 'h1), //#Check.DCE.MrdReq_RL
            .smi_mpf1_dtr_tgt_id    (m_initcmdupd_req_pkt.smi_src_id >> WSMINCOREPORTID), //#Check.DCE.MrdReq_mpf1
            .smi_mpf2_dtr_msg_id    (m_initcmdupd_req_pkt.smi_msg_id),                    //#Check.DCE.MrdReq_mpf2
            .smi_size               (m_initcmdupd_req_pkt.smi_size),
            .smi_intfsize           (m_initcmdupd_req_pkt.smi_intfsize),
            .smi_qos                (m_initcmdupd_req_pkt.smi_qos),
            .smi_ndp_aux            (m_initcmdupd_req_pkt.smi_ndp_aux) // CONC-13177, CONC-13223
        );
    end else begin
        m_states["mrdreq"].set_complete();
        m_states["mrdrsp"].set_complete();
    end 

endfunction: predict_mrd_req

//**************************************************************************
function void dce_scb_txn::predict_rbr_snp_req_recall_ops(int recall_qos);
    bit [addrMgrConst::NUM_CACHES-1:0] sharer_vec;
    smi_seq_item snp_req_pkt;
    smi_seq_item rbr_req_pkt;
    int agent_idq[$];
    int i = 0;
    

    //See CONC-5168 
    //RL will be 'h2 for all snoops
    //For recalls, IntfSize = 'h1
    //For recalls, mpf1 and mpf2 are dont care

    foreach(m_dm_pktq[0].m_sharer_vec[x]) begin
        agent_idq = addrMgrConst::get_agent_ids_assoc2cacheid(x);
        if(m_dm_pktq[0].m_sharer_vec[x] == 1 && snoop_enable_reg_txn[agent_idq[0]] == 0) begin
            m_dm_pktq[0].m_sharer_vec[x] = 0;
        end
    end
    sharer_vec = m_dm_pktq[0].m_sharer_vec;


    while (sharer_vec != 0) begin
        if (sharer_vec & 'b1 != 0) begin
            agent_idq = addrMgrConst::get_agent_ids_assoc2cacheid(i);
            if (agent_idq.size() != 1)
                `uvm_error("DCE SCB", "Now clearly understand the fn:get_agent_ids_assoc2cacheid");

            if(snoop_enable_reg_txn[agent_idq[0]] == 1) begin
                m_states["snpreq"].set_expect();
                snp_req_pkt = new("snp_req_pkt");
                snp_req_pkt.construct_snpmsg(
                    .smi_targ_ncore_unit_id        (agent_idq[0]),
                    .smi_src_ncore_unit_id         (addrMgrConst::get_dce_funitid(<%=obj.Id%>)),
                    .smi_msg_tier                  ('h0),
                    .smi_steer                     ('h0),
                    .smi_msg_qos                   ('h0),
                    .smi_msg_pri                   ((addrMgrConst::get_highest_qos() != 0) ? addrMgrConst::qos_mapping(addrMgrConst::get_highest_qos()) : 'h0),
                    .smi_msg_type                  (SNP_INV_DTW),
                    .smi_msg_id                    (m_attid),
                    .smi_msg_err                   ('h0),
                    .smi_cmstatus                  ('h0),
                    .smi_addr                      (m_dm_pktq[0].m_addr),
                    .smi_vz                        ('h0),
                    .smi_ac                        ('h1),
                    .smi_ca                        ('h1),
                    .smi_ns                        (m_dm_pktq[0].m_ns),
                    .smi_pr                        ('h1),
                    .smi_rl                        ('h2),
                    .smi_tm                        ('h0),
                    .smi_up                        ($onehot(m_dm_pktq[0].m_sharer_vec) ? 'h1 : 'h0),
                    .smi_mpf1_stash_valid          ('h0),
                    .smi_mpf1_stash_nid            ('h0),
                    .smi_mpf1_dtr_tgt_id           ('h0),
                    .smi_mpf1_vmid_ext             ('h0),
                    .smi_mpf2_dtr_msg_id           ('h0),
                    .smi_mpf2_stash_valid          ('h0),
                    .smi_mpf2_stash_lpid           ('h0),
                    .smi_mpf2_dvmop_id             ('h0),
                    .smi_mpf3_intervention_unit_id ('h0),
                    .smi_mpf3_dvmop_portion        ('h0),
                    .smi_mpf3_range                ('h0),
                    .smi_mpf3_num                  ('h0),
                    .smi_intfsize                  ('h1),
                    .smi_dest_id                   (m_dmiid),
                    .smi_rbid                      ('h0),
                    .smi_tof                       ('h0),
                    .smi_qos                       (recall_qos), // CONC-13159
                    .smi_ndp_aux                   ('h0)
                );

                m_expsnp_req_pktq.push_back(snp_req_pkt);
            end
        end     
        i++;
        sharer_vec = sharer_vec >> 1;
    end

    if(m_dm_pktq[0].m_sharer_vec != 0) begin
        //always set expect for rbrreq for recalls 
        //#Check.DCE.RBReq_Rsv
        m_states["rbrreq"].set_expect();
        rbr_req_pkt = new("rbr_req");
        rbr_req_pkt.construct_rbmsg(
            .smi_targ_ncore_unit_id (m_dmiid),
            .smi_src_ncore_unit_id  (addrMgrConst::get_dce_funitid(<%=obj.Id%>)),
            .smi_msg_tier           ('h0),
            .smi_steer              ('h0),
            .smi_msg_qos            ('h0),
            .smi_msg_pri            ((addrMgrConst::get_highest_qos() != 0) ? addrMgrConst::qos_mapping(addrMgrConst::get_highest_qos()) : 'h0),
            .smi_msg_type           (RB_REQ),
            .smi_msg_id             (m_attid),
            .smi_msg_err            ('h0),
            .smi_cmstatus           ('h0),
            .smi_rbid               ('h0),
            .smi_tm                 ('h0),
            .smi_rtype              ('h1),
            .smi_addr               (m_dm_pktq[0].m_addr),
            .smi_size               (addrMgrConst::WCACHE_OFFSET),
            .smi_tof                ('h0),
            .smi_mpf1               ('h0),
            .smi_vz                 ('h0),
            .smi_ac                 ('h1),
            .smi_ca                 ('h1),
            .smi_ns                 (m_dm_pktq[0].m_ns),
            .smi_pr                 ('h1),
            .smi_mw                 ('h0),
            .smi_rl                 ('h2), //#Check.DCE.RBReq_Rsv_Attr_RL
            .smi_qos                (recall_qos), // CONC-13159
            .smi_ndp_aux            ('h0)
        );
        m_exprbr_req_pktq.push_back(rbr_req_pkt);
    end
    if(m_exprbr_req_pktq.size() == 0 && m_expsnp_req_pktq.size() == 0) begin // Adding this related to Sysco to check att deallocation
        m_states["snpreq"].set_complete();
        m_states["snprsp"].set_complete();
        m_states["rbrreq"].set_complete();
        // CLEANUP
        m_states["rbrrsp"].set_complete();
        m_states["rbureq"].set_complete();
        m_states["rbursp"].set_complete();
    end

endfunction: predict_rbr_snp_req_recall_ops

//**************************************************************************
function void dce_scb_txn::predict_rbr_snp_req(int idx=0);
    smi_seq_item snp_req_pkt;
    smi_seq_item rbr_req_pkt;
    dm_seq_item pktq[$];
    int agent_idq[$];
    bit predict_rbrreq = 0;
    int discard;
    int i = 0;
    int x = 0;
    bit [addrMgrConst::NUM_CACHES-1:0] sharer_vec;
    bit [WSMIUP-1:0] exp_smi_up;
    bit [WSMIMPF3-1:0] exp_smi_mpf3_intervention_unit_id = 'h0;
    bit [$clog2(addrMgrConst::NUM_CACHES)-1:0] promoted_sharer_cacheid = 'h0;
    
    pktq = m_dm_pktq.find(item) with (item.m_access_type == DM_LKP_RSP);

    `uvm_info("DCE_SCB_TXN_DBG",$psprintf("lkprsp sharer vector = %p",pktq[0].m_sharer_vec),UVM_LOW)

    if (pktq.size != 1)
        `uvm_error("DCE_SCB_TXN", "Multiple DM LKP_RSP not possible");

    agent_idq = addrMgrConst::get_agent_ids_assoc2cacheid(pktq[0].m_owner_num);
    if(pktq[0].m_owner_val == 1 && snoop_enable_reg_txn[agent_idq[0]] == 0) begin
        pktq[0].m_owner_val = 0;
        pktq[0].m_owner_num = 0;
    end

    foreach(pktq[0].m_sharer_vec[x]) begin
        agent_idq = addrMgrConst::get_agent_ids_assoc2cacheid(x);
        if(pktq[0].m_sharer_vec[x] == 1 && snoop_enable_reg_txn[agent_idq[0]] == 0) begin
            pktq[0].m_sharer_vec[x] = 0;
        end
    end
    
    if (pktq[0].is_dm_miss) begin
        m_states["snpreq"].set_complete();
        m_states["snprsp"].set_complete();
    
        if (dce_goldenref_model::is_nonstash_write(m_cmd_type)) begin
            predict_rbrreq = 1;
        end//is_write
    end else begin //dm_hit
        //See CONC-5168 
            //#Check.DCE.SnpReq.UP
        if ($onehot(pktq[0].m_sharer_vec)) begin 
            exp_smi_up = 'b01; //#Check.DCE.SnpReq.UP_01
        end 
        else begin 
            exp_smi_up = 'b11; //#Check.DCE.SnpReq.UP_11
        end

        //#Check.DCE.SnpReq.MPF3
        if (exp_smi_up == 2'b11) begin
            //#Check.DCE.SnpReq.MPF3_OwnerID
            if(pktq[0].m_owner_val) begin
                agent_idq = addrMgrConst::get_agent_ids_assoc2cacheid(pktq[0].m_owner_num);
                exp_smi_mpf3_intervention_unit_id = agent_idq[0];
                owner_cacheid = pktq[0].m_owner_num;
                `uvm_info("DCE_SCB_TXN",$psprintf("Predicting smi_up = %p and owner = %p",exp_smi_up,owner_cacheid),UVM_LOW)
            end
            else begin
                //#Check.DCE.SnpReq.MPF3_FindFirstSharer
                for(x = 0; x < addrMgrConst::NUM_CACHES; x++) begin
                    if(pktq[0].m_sharer_vec[x] == 1) begin
                        promoted_sharer_cacheid = x;
                        //#Check.DCE.SnpReq.MPF3_PromotedSharerID
                        owner_cacheid = promoted_sharer_cacheid;
                        agent_idq = addrMgrConst::get_agent_ids_assoc2cacheid(x);
                        exp_smi_mpf3_intervention_unit_id = agent_idq[0];
                        if(x != m_iid_cacheid) begin
                                `uvm_info("DCE_SCB_TXN",$psprintf("Predicting smi_up = %p and promoted sharer = %p",exp_smi_up,owner_cacheid),UVM_LOW)
                            break;
                        end
                    end
                end
            end 
        end
        
        if(exp_smi_up == 2'b01) begin
            if($countones(pktq[0].m_sharer_vec) != 1)
                    `uvm_error("DCE_SCB_TXN", "smi_up = 2'b01 when sharer vector is not onehot");
            
            if(pktq[0].m_owner_val) begin
                agent_idq = addrMgrConst::get_agent_ids_assoc2cacheid(pktq[0].m_owner_num);
                owner_cacheid = pktq[0].m_owner_num;
                    `uvm_info("DCE_SCB_TXN",$psprintf("Predicting smi_up = %p and owner = %p",exp_smi_up,owner_cacheid),UVM_LOW)
            end
            else begin
                for(x = 0; x < addrMgrConst::NUM_CACHES; x++) begin
                    if(pktq[0].m_sharer_vec[x] == 1) begin
                        promoted_sharer_cacheid = x;
                        owner_cacheid = promoted_sharer_cacheid;
                        agent_idq = addrMgrConst::get_agent_ids_assoc2cacheid(x);
                        if(x != m_iid_cacheid) begin
                                `uvm_info("DCE_SCB_TXN",$psprintf("Predicting smi_up = %p and promoted sharer = %p",exp_smi_up,owner_cacheid),UVM_LOW)
                            break;
                        end
                    end
                end

            end
        end
        
        if (dce_goldenref_model::cmdreq2owner_snp.exists(m_cmd_type) && 
            !(ex_store && (m_exmon_status == EXMON_FAIL)) &&
            ((pktq[0].m_owner_val || (dce_goldenref_model::cmdreq2owner_snp[m_cmd_type] inside {SNP_INV_DTR, SNP_CLN_DTR, SNP_VLD_DTR, SNP_NOSDINT, SNP_NITC, SNP_NITCCI, SNP_NITCMI})) &&
            ((owner_cacheid != m_iid_cacheid) || (dce_goldenref_model::is_atomic(m_cmd_type) && m_initcmdupd_req_pkt.smi_es)))) begin

            //#Check.DCE.SnpReq.NonInvSpns_Promoted_Sharer          
            if(snoop_enable_reg_txn[agent_idq[0]] == 1) begin
                m_states["snpreq"].set_expect();
                snp_req_pkt = new("snp_req_pkt");
                snp_req_pkt.t_smi_ndp_valid = 0;
    
                //#Check.DCE.SnpReq.Attributes
                snp_req_pkt.construct_snpmsg(
                    .smi_targ_ncore_unit_id        (agent_idq[0]), //#Check.DCE..SnpReq.TargId
                    .smi_src_ncore_unit_id         (addrMgrConst::get_dce_funitid(<%=obj.Id%>)), //#Check.DCE.SnpReq.SrcId
                    .smi_msg_tier                  ('h0),
                    .smi_steer                     ('h0),
                    .smi_msg_qos                   ('h0),
                    .smi_msg_pri                   (m_initcmdupd_req_pkt.smi_msg_pri),
                    .smi_msg_type                  (dce_goldenref_model::cmdreq2owner_snp[m_cmd_type]), //#Check.DCE.SnpReq.SnpType
                    .smi_msg_id                    (m_attid),
                    .smi_msg_err                   (m_initcmdupd_req_pkt.smi_msg_err),
                    .smi_cmstatus                  ('h0),
                    .smi_addr                      (m_initcmdupd_req_pkt.smi_addr),
                    .smi_vz                        (m_initcmdupd_req_pkt.smi_vz),
                    .smi_ac                        (m_initcmdupd_req_pkt.smi_ac),
                    .smi_ca                        (m_initcmdupd_req_pkt.smi_ca),
                    .smi_ns                        (m_initcmdupd_req_pkt.smi_ns),
                    .smi_pr                        (m_initcmdupd_req_pkt.smi_pr),
                    .smi_rl                        ('h2),
                    .smi_tm                        (m_initcmdupd_req_pkt.smi_tm),
                    .smi_up                        (exp_smi_up),
                    .smi_mpf1_stash_valid          (m_initcmdupd_req_pkt.smi_mpf1_stash_valid),
                    .smi_mpf1_stash_nid            ('h0),
                    .smi_mpf1_dtr_tgt_id           (m_initcmdupd_req_pkt.smi_src_id >> WSMINCOREPORTID),
                    .smi_mpf1_vmid_ext             ('h0),
                    .smi_mpf2_dtr_msg_id           (m_initcmdupd_req_pkt.smi_msg_id),
                    .smi_mpf2_stash_valid          (m_initcmdupd_req_pkt.smi_mpf2_stash_valid),
                    .smi_mpf2_stash_lpid           ('h0),
                    .smi_mpf2_dvmop_id             ('h0),
                    .smi_mpf3_intervention_unit_id (exp_smi_mpf3_intervention_unit_id),
                    .smi_mpf3_dvmop_portion        ('h0),
                    .smi_mpf3_range                ('h0),
                    .smi_mpf3_num                  ('h0),
                    .smi_intfsize                  (m_initcmdupd_req_pkt.smi_intfsize),
                    .smi_dest_id                   (m_initcmdupd_req_pkt.smi_dest_id),
                    .smi_rbid                      ('h0),
                    .smi_tof                       (m_initcmdupd_req_pkt.smi_tof),
                    .smi_qos                       (m_initcmdupd_req_pkt.smi_qos),
                    .smi_ndp_aux                   ('h0)
                ); 
                m_expsnp_req_pktq.push_back(snp_req_pkt);
            end
        end //snoop_owner

        //snoop sharers
        if (dce_goldenref_model::cmdreq2sharer_snp.exists(m_cmd_type) && !(ex_store && (m_exmon_status == EXMON_FAIL))) begin
            sharer_vec = pktq[0].m_sharer_vec;

            //clear requestor bit only if !(atomic && es)
            if ((dce_goldenref_model::is_atomic(m_cmd_type) && m_initcmdupd_req_pkt.smi_es) == 0) begin  
                sharer_vec = sharer_vec & ~(1 << m_iid_cacheid);
            end else begin
            end
            
            //clear the owner cacheid bit if applicable
            if (pktq[0].m_owner_val == 1) begin 
                sharer_vec = sharer_vec & ~(1 << pktq[0].m_owner_num);
            end
        else if (dce_goldenref_model::cmdreq2owner_snp[m_cmd_type] inside {SNP_INV_DTR, SNP_CLN_DTR, SNP_VLD_DTR, SNP_NOSDINT, SNP_NITC, SNP_NITCCI, SNP_NITCMI})
            sharer_vec = sharer_vec & ~(1 << promoted_sharer_cacheid);
            
            while (sharer_vec != 0) begin
                if (sharer_vec & 'b1 != 0) begin
                    agent_idq = addrMgrConst::get_agent_ids_assoc2cacheid(i);
                    if (agent_idq.size() != 1)
                        `uvm_error("DCE SCB", "Now clearly understand the fn:get_agent_ids_assoc2cacheid");
                    
                    if(snoop_enable_reg_txn[agent_idq[0]] == 1) begin
                        m_states["snpreq"].set_expect();
                        snp_req_pkt = new("snp_req_pkt");

                        //See CONC-5168 
                        //RL will be 'h2 for all snoops
                        
                        snp_req_pkt.construct_snpmsg(
                            .smi_targ_ncore_unit_id        (agent_idq[0]),
                            .smi_src_ncore_unit_id         (addrMgrConst::get_dce_funitid(<%=obj.Id%>)),
                            .smi_msg_tier                  ('h0),
                            .smi_steer                     ('h0),
                            .smi_msg_qos                   ('h0),
                            .smi_msg_pri                   (m_initcmdupd_req_pkt.smi_msg_pri),
                            .smi_msg_type                  (dce_goldenref_model::cmdreq2sharer_snp[m_cmd_type]),
                            .smi_msg_id                    (m_attid),
                            .smi_msg_err                   (m_initcmdupd_req_pkt.smi_msg_err),
                            .smi_cmstatus                  ('h0),
                            .smi_addr                      (m_initcmdupd_req_pkt.smi_addr),
                            .smi_vz                        (m_initcmdupd_req_pkt.smi_vz),
                            .smi_ac                        (m_initcmdupd_req_pkt.smi_ac),
                            .smi_ca                        (m_initcmdupd_req_pkt.smi_ca),
                            .smi_ns                        (m_initcmdupd_req_pkt.smi_ns),
                            .smi_pr                        (m_initcmdupd_req_pkt.smi_pr),
                            .smi_rl                        ('h2), //#Check.DCE..SnpReq.RL
                            .smi_tm                        (m_initcmdupd_req_pkt.smi_tm),
                            .smi_up                        (exp_smi_up),
                            .smi_mpf1_stash_valid          (m_initcmdupd_req_pkt.smi_mpf1_stash_valid), //#Check.DCE.SnpReq.MPF1
                            .smi_mpf1_stash_nid            ('h0),
                            .smi_mpf1_dtr_tgt_id           (m_initcmdupd_req_pkt.smi_src_id >> WSMINCOREPORTID),
                            .smi_mpf1_vmid_ext             ('h0),
                            .smi_mpf2_dtr_msg_id           (m_initcmdupd_req_pkt.smi_msg_id), //#Check.DCE.SnpReq.MPF2
                            .smi_mpf2_stash_valid          (m_initcmdupd_req_pkt.smi_mpf2_stash_valid),
                            .smi_mpf2_stash_lpid           ('h0),
                            .smi_mpf2_dvmop_id             ('h0),
                            .smi_mpf3_intervention_unit_id (exp_smi_mpf3_intervention_unit_id), //#Check.DCE.SnpReq.MPF3_SameInAllSnps
                            .smi_mpf3_dvmop_portion        ('h0),
                            .smi_mpf3_range                ('h0),
                            .smi_mpf3_num                  ('h0),
                            .smi_intfsize                  (m_initcmdupd_req_pkt.smi_intfsize),
                            .smi_dest_id                   (m_initcmdupd_req_pkt.smi_dest_id),
                            .smi_rbid                      ('h0),
                            .smi_tof                       (m_initcmdupd_req_pkt.smi_tof),
                            .smi_qos                       (m_initcmdupd_req_pkt.smi_qos),
                            .smi_ndp_aux                   ('h0)
                        );

                        m_expsnp_req_pktq.push_back(snp_req_pkt);
                    end
                end     
                i++;
                sharer_vec = sharer_vec >> 1;
            end
        end //snoop sharer

        if (dce_goldenref_model::is_nonstash_write(m_cmd_type)) begin
            predict_rbrreq = 1;
        end else if (m_states["snpreq"].is_expect() && (dce_goldenref_model::cmdreq2owner_snp[m_cmd_type] != SNP_INV)) begin
            predict_rbrreq = 1;
        end 

    end// dm_hit

    //#Check.DCE.RBReq_Rsv
    if (predict_rbrreq) begin
        m_states["rbrreq"].set_expect();
        rbr_req_pkt = new("rbr_req");
        rbr_req_pkt.construct_rbmsg(
            .smi_targ_ncore_unit_id (m_dmiid),
            .smi_src_ncore_unit_id  (addrMgrConst::get_dce_funitid(<%=obj.Id%>)),
            .smi_msg_tier           ('h0),
            .smi_steer              ('h0),
            .smi_msg_qos            ('h0),
            .smi_msg_pri            (m_initcmdupd_req_pkt.smi_msg_pri),
            .smi_msg_type           (RB_REQ),
            .smi_msg_id             (m_attid),
            .smi_msg_err            (m_initcmdupd_req_pkt.smi_msg_err),
            .smi_cmstatus           ('h0),
            .smi_rbid               ('h0),
            .smi_tm                 (m_initcmdupd_req_pkt.smi_tm),
            .smi_rtype              ('h1),
            .smi_addr               (m_initcmdupd_req_pkt.smi_addr),
            .smi_size               (m_initcmdupd_req_pkt.smi_size),
            .smi_tof                (m_initcmdupd_req_pkt.smi_tof),
            .smi_mpf1               (m_initcmdupd_req_pkt.smi_mpf2),
            .smi_vz                 (m_initcmdupd_req_pkt.smi_vz),
            .smi_ac                 (m_initcmdupd_req_pkt.smi_ac),
            .smi_ca                 (m_initcmdupd_req_pkt.smi_ca),
            .smi_ns                 (m_initcmdupd_req_pkt.smi_ns),
            .smi_pr                 (m_initcmdupd_req_pkt.smi_pr),
            .smi_mw                 ((m_cmd_type inside {CMD_WR_UNQ_PTL}) ? 'h1 : 'h0),
            .smi_rl                 ('b10),
            .smi_qos                (m_initcmdupd_req_pkt.smi_qos),
            .smi_ndp_aux            (m_initcmdupd_req_pkt.smi_ndp_aux) // CONC-13177, CONC-13223
        );
        m_exprbr_req_pktq.push_back(rbr_req_pkt);
    end 
   `uvm_info(get_name(), $psprintf("[%-35s] (txnId: %5d) {%20s} (src: 0x%02h {%s}) (tgt: 0x%02h) (msgId: 0x%02h) (attid : 0x%02h) (rbid: 0x%02h) (addr: 0x%016h) (owner: %1d, 0x%02h / sharer: 0x%04h / dmMiss: %1b / stshWr: %1b / rbrReqExpt: %1b) (%10t, %10t)", $psprintf("DceScbd-PredictRbreqNonStsh[%1d]", idx), m_txn_id, m_initcmdupd_req_pkt.type2cmdname(), m_initcmdupd_req_pkt.smi_src_ncore_unit_id, addrMgrConst::get_cache_id_as_string(m_initcmdupd_req_pkt.smi_src_ncore_unit_id), m_initcmdupd_req_pkt.smi_targ_ncore_unit_id, m_initcmdupd_req_pkt.smi_msg_id, m_attid, m_rbid, m_initcmdupd_req_pkt.smi_addr, pktq[0].m_owner_val, pktq[0].m_owner_num, pktq[0].m_sharer_vec, pktq[0].is_dm_miss, dce_goldenref_model::is_stash_write(m_cmd_type), predict_rbrreq, m_initcmdupd_req_pkt.t_smi_ndp_valid, t_conc_mux_cmdreq), UVM_LOW);

    if (m_states["snpreq"].is_expect() == 0) begin
        m_states["snpreq"].set_complete();
        m_states["snprsp"].set_complete();
    end

    if (m_states["rbrreq"].is_expect() == 0) begin
        m_states["rbrreq"].set_complete();
        // CLEANUP
        m_states["rbrrsp"].set_complete();
        m_states["rbureq"].set_complete();
        m_states["rbursp"].set_complete();
    end

endfunction: predict_rbr_snp_req 


//**************************************************************************
function void dce_scb_txn::predict_rbr_snp_req_stash_ops(int idx=0);
    dm_seq_item cohreq_pktq[$];
    dm_seq_item lkprsp_pktq[$];
    smi_seq_item snpreq_pkt;
    smi_seq_item rbrreq_pkt;
    int agent_idq[$];
    int i = 0;
    bit predict_rbrreq = 0;
    bit predict_snpreq = 0;
    bit [addrMgrConst::NUM_CACHES-1:0] sharer_vec;
    bit [WSMINCOREUNITID-1:0] snp_target_ncore_unit_id[$];

    cohreq_pktq = m_dm_pktq.find(item) with (item.m_access_type == DM_CMD_REQ);
    lkprsp_pktq = m_dm_pktq.find(item) with (item.m_access_type == DM_LKP_RSP);

    if (cohreq_pktq.size() == 0)
        `uvm_error("DCE_SCB_TXN", "No DM_CMD_REQ not possible");
    if (lkprsp_pktq.size() != 1)
        `uvm_error("DCE_SCB_TXN", "Multiple DM_LKP_RSP not possible");

    
    agent_idq = addrMgrConst::get_agent_ids_assoc2cacheid(lkprsp_pktq[0].m_owner_num);
    if(lkprsp_pktq[0].m_owner_val == 1 && snoop_enable_reg_txn[agent_idq[0]] == 0) begin
        lkprsp_pktq[0].m_owner_val = 0;
        lkprsp_pktq[0].m_owner_num = 0;
    end

    foreach(lkprsp_pktq[0].m_sharer_vec[x]) begin
        agent_idq = addrMgrConst::get_agent_ids_assoc2cacheid(x);
        if(lkprsp_pktq[0].m_sharer_vec[x] == 1 && snoop_enable_reg_txn[agent_idq[0]] == 0) begin
            lkprsp_pktq[0].m_sharer_vec[x] = 0;
        end
    end


    //*********************************
    // SNPreq prediction 
    //*********************************
    //only snps/rbr if valid target identified. always snoop stash target
    //stash snoop to stash target is already predicted when rd stash is seen on smi interface.
    //stash snoop to stash target is predicted at lkp_rsp for wr stash. can this be moved to when wr stash is seen on smi interface. not sure ??

    if (dce_goldenref_model::is_stash_write(m_cmd_type)) begin
        if (cohreq_pktq[cohreq_pktq.size() - 1].m_alloc == 1) begin //valid target identified 
            //1st snoop to stash target
            snp_target_ncore_unit_id.push_back(cohreq_pktq[cohreq_pktq.size() - 1].m_sid >> WSMINCOREPORTID);
        end
           
        //snoop all other owner and sharers too to invalidate them
        sharer_vec = lkprsp_pktq[0].m_sharer_vec;
        if (m_iid_cacheid != -1) //clear iid bit
            sharer_vec = sharer_vec & ~(1 << m_iid_cacheid);
            
        if (cohreq_pktq[cohreq_pktq.size() - 1].m_alloc == 1) begin //valid target identified 
            sharer_vec = sharer_vec & ~(1 << m_sid_cacheid); //clear stash tgt bit since the snoop to valid stash target was already sent
        end

        while (sharer_vec != 0) begin
            if (sharer_vec & 'b1 != 0) begin
                agent_idq = addrMgrConst::get_agent_ids_assoc2cacheid(i);
                snp_target_ncore_unit_id.push_back(agent_idq[0]);
            end     
            i++;
            sharer_vec = sharer_vec >> 1;
        end
    end else if (cohreq_pktq[cohreq_pktq.size() - 1].m_alloc == 1) begin//stash reads
        //1st snoop to stash target already predicted when rd stash is seen on smi interface 
        
        //2nd snoop - always snoop owner
        if (lkprsp_pktq[0].m_owner_val && !(lkprsp_pktq[0].m_owner_num inside {m_iid_cacheid, m_sid_cacheid})) begin
            agent_idq = addrMgrConst::get_agent_ids_assoc2cacheid(lkprsp_pktq[0].m_owner_num);
            snp_target_ncore_unit_id.push_back(agent_idq[0]);
        end

        //snoop other sharers only for CMD_LD_CCH_UNQ
        if (m_cmd_type == CMD_LD_CCH_UNQ) begin
            sharer_vec = lkprsp_pktq[0].m_sharer_vec;
            if (m_iid_cacheid != -1) begin
                sharer_vec = sharer_vec & ~(1 << m_iid_cacheid);
                //`uvm_info("DCE SCB", $psprintf("predict_snp: sharer_vec after clear requestor cacheid bit: 0x%0h", sharer_vec), UVM_LOW)
            end
        
            //clear the owner cacheid bit if applicable
            if (lkprsp_pktq[0].m_owner_val == 1) begin 
                sharer_vec = sharer_vec & ~(1 << lkprsp_pktq[0].m_owner_num);
                //`uvm_info("DCE SCB", $psprintf("predict_snp: sharer_vec after clear owner cacheid bit: 0x%0h", sharer_vec), UVM_LOW)
            end
        
            if (cohreq_pktq[cohreq_pktq.size() - 1].m_alloc == 1) begin //applies if onlu tgt is identified since this snoop was already predicted.
                sharer_vec = sharer_vec & ~(1 << m_sid_cacheid);
                //`uvm_info("DCE SCB", $psprintf("predict_snp: sharer_vec after clear identified target cacheid bit: 0x%0h", sharer_vec), UVM_LOW)
            end

            while (sharer_vec != 0) begin
                if (sharer_vec & 'b1 != 0) begin
                    agent_idq = addrMgrConst::get_agent_ids_assoc2cacheid(i);
                    snp_target_ncore_unit_id.push_back(agent_idq[0]);
                end     
                i++;
                sharer_vec = sharer_vec >> 1;
            end
        end
    end

    if (snp_target_ncore_unit_id.size() > 0) begin 
        foreach(snp_target_ncore_unit_id[i]) begin
            if(snoop_enable_reg_txn[snp_target_ncore_unit_id[i]] == 1) begin
                m_states["snpreq"].set_expect();
                snpreq_pkt = new("snpreq_pkt");
                
                snpreq_pkt.construct_snpmsg(
                    .smi_targ_ncore_unit_id        (snp_target_ncore_unit_id[i]),
                    .smi_src_ncore_unit_id         (addrMgrConst::get_dce_funitid(<%=obj.Id%>)),
                    .smi_msg_tier                  ('h0),
                    .smi_steer                     ('h0),
                    .smi_msg_qos                   ('h0),
                    .smi_msg_pri                   (m_initcmdupd_req_pkt.smi_msg_pri),
                    .smi_msg_type                  (dce_goldenref_model::cmdreq2stsh_snp[m_cmd_type]), //#Check.DCE.StashReq.SnoopType 
                    .smi_msg_id                    (m_attid),
                    .smi_msg_err                   (m_initcmdupd_req_pkt.smi_msg_err),
                    .smi_cmstatus                  ('h0),
                    .smi_addr                      (m_initcmdupd_req_pkt.smi_addr),
                    .smi_vz                        (m_initcmdupd_req_pkt.smi_vz),
                    .smi_ac                        (m_initcmdupd_req_pkt.smi_ac),
                    .smi_ca                        (m_initcmdupd_req_pkt.smi_ca),
                    .smi_ns                        (m_initcmdupd_req_pkt.smi_ns),
                    .smi_pr                        (m_initcmdupd_req_pkt.smi_pr),
                    .smi_rl                        ('h2),
                    .smi_tm                        (m_initcmdupd_req_pkt.smi_tm),
                    .smi_up                        ('h0),
                    .smi_mpf1_stash_valid          (m_initcmdupd_req_pkt.smi_mpf1_stash_valid),
                    .smi_mpf1_stash_nid            (m_initcmdupd_req_pkt.smi_mpf1_stash_nid),
                    .smi_mpf1_dtr_tgt_id           (m_initcmdupd_req_pkt.smi_src_id >> WSMINCOREPORTID),
                    .smi_mpf1_vmid_ext             ('h0),
                    .smi_mpf2_dtr_msg_id           (m_initcmdupd_req_pkt.smi_msg_id),
                    .smi_mpf2_stash_valid          (m_initcmdupd_req_pkt.smi_mpf2_stash_valid),
                    .smi_mpf2_stash_lpid           (m_initcmdupd_req_pkt.smi_mpf2_stash_lpid),
                    .smi_mpf2_dvmop_id             (m_initcmdupd_req_pkt.smi_mpf2_dvmop_id),
                    .smi_mpf3_intervention_unit_id ('h0),
                    .smi_mpf3_dvmop_portion        ('h0),
                    .smi_mpf3_range                ('h0),
                    .smi_mpf3_num                  ('h0),
                    .smi_intfsize                  (m_initcmdupd_req_pkt.smi_intfsize),
                    .smi_dest_id                   (m_initcmdupd_req_pkt.smi_dest_id),
                    .smi_rbid                      ('h0),
                    .smi_tof                       (m_initcmdupd_req_pkt.smi_tof),
                    .smi_qos                       (m_initcmdupd_req_pkt.smi_qos),
                    .smi_ndp_aux                   ('h0)
                );
                m_expsnp_req_pktq.push_back(snpreq_pkt);
            end
        end
    end 

    //*********************************
    // RBRreq prediction 
    //*********************************
    if (dce_goldenref_model::is_stash_write(m_cmd_type)) begin //for write stash
        predict_rbrreq = 1;
    end else if (cohreq_pktq[cohreq_pktq.size() - 1].m_alloc == 1) begin //for read stash with valid target identified
        if ((lkprsp_pktq[0].m_owner_val == 1) && !(lkprsp_pktq[0].m_owner_num inside {m_iid_cacheid, m_sid_cacheid}))
            predict_rbrreq = 1;

        sharer_vec = lkprsp_pktq[0].m_sharer_vec;
        if ((m_cmd_type == CMD_LD_CCH_UNQ) && (sharer_vec != 0)) begin 
            sharer_vec = sharer_vec & ~(1 << m_sid_cacheid);
            if (m_iid_cacheid != -1)
                sharer_vec = sharer_vec & ~(1 << m_iid_cacheid);
            if (lkprsp_pktq[0].m_owner_val == 1)
                sharer_vec = sharer_vec & ~(1 << lkprsp_pktq[0].m_owner_num);

            //if there are peer AIU, predict_rbr
            if (sharer_vec != 0)
                predict_rbrreq = 1;
        end
     end

   `uvm_info(get_name(), $psprintf("[%-35s] (txnId: %5d) {%20s} (src: 0x%02h {%s}) (tgt: 0x%02h) (msgId: 0x%02h) (attid : 0x%02h) (rbid: 0x%02h) (addr: 0x%016h) (owner: %1d, 0x%02h / sharer: 0x%04h / dmMiss: %1b / stshWr: %1b / rbrReqExpt: %1b) (%10t, %10t)", $psprintf("DceScbd-PredictRbreqStsh[%1d]", idx), m_txn_id, m_initcmdupd_req_pkt.type2cmdname(), m_initcmdupd_req_pkt.smi_src_ncore_unit_id, addrMgrConst::get_cache_id_as_string(m_initcmdupd_req_pkt.smi_src_ncore_unit_id), m_initcmdupd_req_pkt.smi_targ_ncore_unit_id, m_initcmdupd_req_pkt.smi_msg_id, m_attid, m_rbid, m_initcmdupd_req_pkt.smi_addr, lkprsp_pktq[0].m_owner_val, lkprsp_pktq[0].m_owner_num, lkprsp_pktq[0].m_sharer_vec, lkprsp_pktq[0].is_dm_miss, dce_goldenref_model::is_stash_write(m_cmd_type), predict_rbrreq, m_initcmdupd_req_pkt.t_smi_ndp_valid, t_conc_mux_cmdreq), UVM_LOW);

    //#Check.DCE.RBReq_Rsv
    if (predict_rbrreq) begin
        m_states["rbrreq"].set_expect();
        rbrreq_pkt = new("rbr_req");
        rbrreq_pkt.construct_rbmsg(
            .smi_targ_ncore_unit_id (m_dmiid),
            .smi_src_ncore_unit_id  (addrMgrConst::get_dce_funitid(<%=obj.Id%>)),
            .smi_msg_tier           ('h0),
            .smi_steer              ('h0),
            .smi_msg_qos            ('h0),
            .smi_msg_pri            (m_initcmdupd_req_pkt.smi_msg_pri),
            .smi_msg_type           (RB_REQ),
            .smi_msg_id             (m_attid),
            .smi_msg_err            (m_initcmdupd_req_pkt.smi_msg_err),
            .smi_cmstatus           ('h0),
            .smi_tm                 (m_initcmdupd_req_pkt.smi_tm),
            .smi_rbid               ('h0),
            .smi_rtype              ('h1),
            .smi_addr               (m_initcmdupd_req_pkt.smi_addr),
            .smi_size               (m_initcmdupd_req_pkt.smi_size),
            .smi_tof                (m_initcmdupd_req_pkt.smi_tof),
            .smi_mpf1               (m_initcmdupd_req_pkt.smi_mpf2),
            .smi_vz                 (m_initcmdupd_req_pkt.smi_vz),
            .smi_ac                 (m_initcmdupd_req_pkt.smi_ac),
            .smi_ca                 (m_initcmdupd_req_pkt.smi_ca),
            .smi_ns                 (m_initcmdupd_req_pkt.smi_ns),
            .smi_pr                 (m_initcmdupd_req_pkt.smi_pr),
            .smi_mw                 ((m_cmd_type==CMD_WR_STSH_PTL) ? 'h1 : 'h0),
            .smi_rl                 ('b10),
            .smi_qos                (m_initcmdupd_req_pkt.smi_qos),
            .smi_ndp_aux            (m_initcmdupd_req_pkt.smi_ndp_aux) // CONC-13177, CONC-13223
        );
        m_exprbr_req_pktq.push_back(rbrreq_pkt);
    end 

    if (m_states["snpreq"].is_expect() == 0) begin
        m_states["snpreq"].set_complete();
        m_states["snprsp"].set_complete();
    end
    if (m_states["rbrreq"].is_expect() == 0) begin
        m_states["rbrreq"].set_complete();
        // CLEANUP
        m_states["rbrrsp"].set_complete();
        m_states["rbureq"].set_complete();
        m_states["rbursp"].set_complete();
    end

endfunction: predict_rbr_snp_req_stash_ops


//*********************************************
// predict SNPreq for read stash requests -- predicted when stash request is seen on SMI interface
//********************************************
function void dce_scb_txn::predict_snp_req_rd_stash_ops();
    smi_seq_item snpreq_pkt;
    dm_seq_item cohreq_pktq[$];
    
    cohreq_pktq = m_dm_pktq.find(item) with (item.m_access_type == DM_CMD_REQ);

    //only snps if valid target identified.
    if (     m_initcmdupd_req_pkt.smi_mpf1_stash_valid 
         && (m_initcmdupd_req_pkt.smi_mpf1_stash_nid != m_initcmdupd_req_pkt.smi_src_ncore_unit_id)
         && (m_initcmdupd_req_pkt.smi_mpf1_stash_nid inside {addrMgrConst::stash_nids,addrMgrConst::stash_nids_ace_aius})
         && addrMgrConst::is_stash_enable(addrMgrConst::agentid_assoc2funitid(m_initcmdupd_req_pkt.smi_mpf1_stash_nid))
       ) begin
        //if(snoop_enable_reg_txn[m_initcmdupd_req_pkt.smi_mpf1_stash_nid] == 1) begin
        if(cohreq_pktq[0].stash_target_id_detached == 0) begin
            m_states["snpreq"].set_expect();
            snpreq_pkt = new("snpreq_pkt");

            snpreq_pkt.construct_snpmsg(
                .smi_steer                     ('h0),
                .smi_targ_ncore_unit_id        (m_initcmdupd_req_pkt.smi_mpf1_stash_nid),
                .smi_src_ncore_unit_id         (addrMgrConst::get_dce_funitid(<%=obj.Id%>)), //#Check.DCE.SnpReq.SrcId
                .smi_msg_tier                  ('h0),
                .smi_msg_qos                   ('h0),
                .smi_msg_pri                   (m_initcmdupd_req_pkt.smi_msg_pri),
                .smi_msg_type                  (dce_goldenref_model::cmdreq2stsh_snp[m_cmd_type]), //#Check.DCE.StashReq.SnoopType 
                .smi_msg_id                    (m_attid),
                .smi_msg_err                   (m_initcmdupd_req_pkt.smi_msg_err),
                .smi_cmstatus                  ('h0),
                .smi_addr                      (m_initcmdupd_req_pkt.smi_addr),
                .smi_vz                        (m_initcmdupd_req_pkt.smi_vz),
                .smi_ac                        (m_initcmdupd_req_pkt.smi_ac),
                .smi_ca                        (m_initcmdupd_req_pkt.smi_ca),
                .smi_ns                        (m_initcmdupd_req_pkt.smi_ns),
                .smi_pr                        (m_initcmdupd_req_pkt.smi_pr),
                .smi_rl                        ('h2), //'h2 for all snoops CONC-5168
                .smi_tm                        (m_initcmdupd_req_pkt.smi_tm),
                .smi_up                        ('h0),
                .smi_mpf1_stash_valid          (m_initcmdupd_req_pkt.smi_mpf1_stash_valid),
                .smi_mpf1_stash_nid            (m_initcmdupd_req_pkt.smi_mpf1_stash_nid),
                .smi_mpf1_dtr_tgt_id           (m_initcmdupd_req_pkt.smi_src_id >> WSMINCOREPORTID),
                .smi_mpf1_vmid_ext             (m_initcmdupd_req_pkt.smi_mpf1_vmid_ext),
                .smi_mpf2_dtr_msg_id           (m_initcmdupd_req_pkt.smi_msg_id),
                .smi_mpf2_stash_valid          (m_initcmdupd_req_pkt.smi_mpf2_stash_valid),
                .smi_mpf2_dvmop_id             (m_initcmdupd_req_pkt.smi_mpf2_dvmop_id),
                .smi_mpf2_stash_lpid           (m_initcmdupd_req_pkt.smi_mpf2_stash_lpid),
                .smi_mpf3_intervention_unit_id ('h0),
                .smi_mpf3_dvmop_portion        ('h0),
                .smi_mpf3_range                ('h0),
                .smi_mpf3_num                  ('h0),
                .smi_intfsize                  (m_initcmdupd_req_pkt.smi_intfsize),
                .smi_dest_id                   (m_initcmdupd_req_pkt.smi_dest_id),
                .smi_rbid                      ('h0),
                .smi_tof                       (m_initcmdupd_req_pkt.smi_tof),
                .smi_qos                       (m_initcmdupd_req_pkt.smi_qos),
                .smi_ndp_aux                   ('h0)
            );
            
            m_expsnp_req_pktq.push_back(snpreq_pkt);
        end
    
    end // only if valid target is identified

    if (m_states["snpreq"].is_expect() == 0) begin
        m_states["snpreq"].set_complete();
        m_states["snprsp"].set_complete();
    end
    
endfunction: predict_snp_req_rd_stash_ops

//**************************************************************************
function void dce_scb_txn::predict_str_req();
    dm_seq_item cohreq_pktq[$], lkprsp_pktq[$], cmtreq_pktq[$];
    dm_seq_item pkt;
    bit predict_strreq, ign;
    bit [2:0] exp_smi_cmstatus_state;
    bit [WSMICMSTATUS-1:0] exp_smi_cmstatus;
    bit [WSMICMSTATUSERR-1:0] exp_smi_cmstatus_err;
    bit [WSMICMSTATUSERRPAYLOAD-1:0] exp_smi_cmstatus_err_payload;

    cohreq_pktq = m_dm_pktq.find(item) with (item.m_access_type == DM_CMD_REQ);
    lkprsp_pktq = m_dm_pktq.find(item) with (item.m_access_type == DM_LKP_RSP);
    cmtreq_pktq = m_dm_pktq.find(item) with (item.m_access_type == DM_CMT_REQ);

    if (cohreq_pktq.size() == 0)
        `uvm_error("DCE_SCB_TXN", "No DM CMD_REQ not possible");
    if (lkprsp_pktq.size() != 1)
        `uvm_error("DCE_SCB_TXN", "Multiple  for sure for those snoops DM LKP_RSP not possible");

    //only set prediction for str req if snoops are not expected 
    if ((m_states["snpreq"].is_complete() &&
          m_states["snprsp"].is_complete()) ||
          (credit_zero_err == 1) ||
          lkprsp_pktq[0].m_error) begin
        predict_strreq = 1;
    end

    //#Check.DCE.StrReq
    if (predict_strreq == 1) begin 
        //create expect for STR req
        m_states["strreq"].set_expect();
        m_expstr_req_pkt = new("str_req_pkt");
        m_expstr_req_pkt.t_smi_ndp_valid = 0;

        //https://confluence.arteris.com/pages/viewpage.action?spaceKey=ENGR&title=Ncore+3.0+System+Specification#_Toc48944595
        //When DCE gets a snoop filter look up error
        //DCE issues STRReq with CMStatus = 8'b10000100 (Address Error).
        if ((lkprsp_pktq[0].m_error == 1) || (credit_zero_err == 1)) begin 
            exp_smi_cmstatus_err = 1;
            exp_smi_cmstatus_err_payload = 'b100; 
            exp_smi_cmstatus = {exp_smi_cmstatus_err, exp_smi_cmstatus_err_payload};
        end else begin//no error
            if (dce_goldenref_model::is_stash_request(m_cmd_type) == 0) begin 
                if (m_iid_cacheid != -1) begin 
                    if (cmtreq_pktq.size() > 0) begin 
                        pkt = cmtreq_pktq[0];
                    end else begin 
                        pkt = lkprsp_pktq[0];
                    end 

                    if ((pkt.m_sharer_vec | (1 << m_iid_cacheid)) != pkt.m_sharer_vec) begin //requestor not valid 
                        exp_smi_cmstatus_state = 3'b000;
                    end else if ((pkt.m_owner_val == 1) && (pkt.m_owner_num == m_iid_cacheid)) begin //requestor is owner
                        if ($onehot(pkt.m_sharer_vec) == 1) //requestor is only valid as a owner - unique (UC or UD state)
                            exp_smi_cmstatus_state = 3'b100;
                        else //requestor is owner and there are other sharers in the system (SD state)
                            exp_smi_cmstatus_state = 3'b010;
                    end else begin //requestor is valid as sharer (SC state) 
                        exp_smi_cmstatus_state = 3'b011;
                    end
                
                    if(m_cmd_type == CMD_CLN_UNQ) begin //Need to confirm refer Conc_7711
                            exp_smi_cmstatus_state = 3'b100;
                    end 
                end else begin 
                    exp_smi_cmstatus_state = 3'b000;
                end
            end else begin //for stash request
                exp_smi_cmstatus_state = 3'b000;
            end 
            //exp_smi_cmstatus = {exp_smi_cmstatus_err, exp_smi_cmstatus_err_payload};
        end

        //`uvm_info("DCE TXN SCB", $psprintf("predicted smi_cmstatus_err:0x%0h smi_cmstatus_err_payload:0x%0h smi_cmstatus:0x%0h", exp_smi_cmstatus_err, exp_smi_cmstatus_err_payload, exp_smi_cmstatus), UVM_LOW)
        //#Check.DCE.ExMon.ExLdStrExOkay
        //#Check.DCE.ExMon.ExStStrExOkay
        m_expstr_req_pkt.construct_strmsg(
            .smi_targ_ncore_unit_id (m_initcmdupd_req_pkt.smi_src_ncore_unit_id),
            .smi_src_ncore_unit_id  (m_initcmdupd_req_pkt.smi_targ_ncore_unit_id),
            .smi_msg_type           (STR_STATE),
            .smi_msg_id             (m_attid),//#Check.DCE.StrReq_MsgId 
            .smi_msg_tier           ('h0),
            .smi_steer              ('h0),
            .smi_msg_pri            (m_initcmdupd_req_pkt.smi_msg_pri),
            .smi_msg_qos            ('h0),
            .smi_msg_err            ('h0),
            .smi_rmsg_id            (m_initcmdupd_req_pkt.smi_msg_id),
            .smi_tm                 (m_initcmdupd_req_pkt.smi_tm),
            .smi_cmstatus           (exp_smi_cmstatus),
            .smi_cmstatus_so        ('h0),
            .smi_cmstatus_ss        ('h0),
            .smi_cmstatus_sd        ('h0),
            .smi_cmstatus_st        ('h0),
            .smi_cmstatus_state     (exp_smi_cmstatus_state),
            .smi_cmstatus_snarf     ('h0),
            .smi_cmstatus_exok      ((ex_store || ex_load) ? ((m_exmon_status == EXMON_PASS) ? 1'b1 : 1'b0) : 'h0),
            .smi_rbid               ('h0),
            .smi_mpf1               (m_initcmdupd_req_pkt.smi_mpf1_stash_nid), //dont care but need to match RTL to predict ndp_prot bits correctly
            .smi_mpf2               ('h0),
            .smi_intfsize           (m_initcmdupd_req_pkt.smi_intfsize)
        );
    end

endfunction: predict_str_req

//**************************************************************************
function void dce_scb_txn::save_dm_rsp_txn(const ref dm_seq_item item);
    dm_seq_item coh_req;
    dm_seq_item cohreq_pktq[$]; 
    bit ign, hf_allocreq;
    
    if (item.m_access_type == DM_LKP_RSP) begin
        if (item.m_error == 1) begin
            m_dm_pktq[m_dm_pktq.size() - 1].copy(item);
            foreach(m_states[idx]) begin
                if (!(m_states[idx].get_name() inside {"strreq", "strrsp", "cmdupdrsp", "dirreq"})) begin
                    if (m_states[idx].is_complete() == 0) begin 
                        m_states[idx].clear_expect();
                        m_states[idx].set_complete();
                    end
                end
            end
            predict_str_req();
            return;
        end

        if (m_dm_chks_en) 
            m_dm_pktq[m_dm_pktq.size() - 1].compare(item); //#Check.DCE.dm_cmdrsp

        owner_present = item.is_owner_present();
        m_dm_pktq[m_dm_pktq.size() - 1].copy(item);
        $cast(dm_lkprsp,item.clone());
        cohreq_pktq = m_dm_pktq.find(item) with (item.m_access_type == DM_CMD_REQ);
            
        if (cohreq_pktq.size() == 0)
            `uvm_error("DCE_SCB_TXN", "We receive LKP_RSP from directory, without a CMD_REQ to the directory");
    
        //Below check makes sure DM provides a alloc_way into TF on VB hit to allow for VB swap
        if (m_dm_chks_en) begin
           `uvm_info(get_name(), $psprintf("[%-35s] (txnId: %5d) {%20s} (src: 0x%02h {%s}) (tgt: 0x%02h) (msgId: 0x%02h) (attid : 0x%02h) (rbid: 0x%02h) (numDmReq: %2d) (dmAddr: 0x%016h) (dmAlloc: %1d)", "DceScbd-SaveLkupRsp", m_txn_id, m_initcmdupd_req_pkt.type2cmdname(), m_initcmdupd_req_pkt.smi_src_ncore_unit_id, addrMgrConst::get_cache_id_as_string(m_initcmdupd_req_pkt.smi_src_ncore_unit_id), m_initcmdupd_req_pkt.smi_targ_ncore_unit_id, m_initcmdupd_req_pkt.smi_msg_id, m_attid, m_rbid, cohreq_pktq.size(), cohreq_pktq[$].m_addr, cohreq_pktq[$].m_alloc), UVM_HIGH);
            m_dirm_mgr.check_dm_lkprsp_swap_way_on_vbhit(item.m_way_vec_or_mask, item.m_rtl_vbhit_sfvec); 

            //there is no check on way_vec after vb recovery is enabled. since vb recovery is not precise, we might miss on hit_way info, this needs to be fixed, in the model, or we will hit cmtreq mismatch since wr_way cacheline does not match
            for(int sfid = 0; sfid < addrMgrConst::NUM_SF; sfid++) begin
                if (    (m_dm_pktq[m_dm_pktq.size() - 1].m_tfhit_sfvec[sfid] == 1) 
                     && (m_dm_pktq[m_dm_pktq.size() - 1].m_hit_wayq[sfid] != m_dirm_mgr.get_waynum(sfid, item.m_way_vec_or_mask))
                   )begin
                    //this implies there was never a vb hit, so repair model 
                    //`uvm_info("DCE TXN SCB", $psprintf("Need to repair model for tagf mismatch sfid:%0d hitway_dv:%0d hitway_rtl:%0d", sfid, m_dm_pktq[m_dm_pktq.size() - 1].m_hit_wayq[sfid],m_dirm_mgr.get_waynum(sfid, item.m_way_vec_or_mask)), UVM_LOW)
                    m_dirm_mgr.repair_model_on_hitway_mismatch(sfid, {cohreq_pktq[cohreq_pktq.size() - 1].m_ns, cohreq_pktq[cohreq_pktq.size() - 1].m_addr}, item.m_way_vec_or_mask);
                end
            end 

            //applies only if vb recovery is enabled.
            for(int sfid = 0; sfid < addrMgrConst::NUM_SF; sfid++) begin
                if (m_dm_pktq[m_dm_pktq.size() - 1].m_vbhit_sfvec[sfid] && !item.m_rtl_vbhit_sfvec[sfid]) begin
                    //this implies there was never a vb hit, so repair model 
                    //`uvm_info("DCE TXN SCB", $psprintf("Need to repair model for vb recovery dv_vbhit_sf_vec:0x%0h rtl_vbhit_sfvec:0x%0h", m_dm_pktq[m_dm_pktq.size() - 1].m_vbhit_sfvec[sfid],item.m_rtl_vbhit_sfvec), UVM_LOW)
                    m_dirm_mgr.repair_model_on_vbhit_mismatch(sfid, {cohreq_pktq[cohreq_pktq.size() - 1].m_ns, cohreq_pktq[cohreq_pktq.size() - 1].m_addr}, item.m_way_vec_or_mask);
                end
            end 

            //always allocate sf segment in home filter for allocating request 
            if (cohreq_pktq[cohreq_pktq.size() - 1].m_alloc)
                m_dirm_mgr.update_model_for_allocating_request_or_vhit(cohreq_pktq[cohreq_pktq.size() - 1].m_filter_num, {cohreq_pktq[cohreq_pktq.size() - 1].m_ns, cohreq_pktq[cohreq_pktq.size() - 1].m_addr}, item.m_way_vec_or_mask, m_dm_pktq[m_dm_pktq.size() - 1].m_eviction_needed_sfvec[cohreq_pktq[cohreq_pktq.size() - 1].m_filter_num]);

            // YRAMASAMY
            // Updating the direcotyr model when there is a way that is active in the way vector.
            // This update is added to compensate for the change made in directory model where the busy way
            // was set as part of lookup request
            for(int sfid = 0; sfid < addrMgrConst::NUM_SF; sfid++) begin
                if(m_dirm_mgr.get_waynum(sfid, item.m_way_vec_or_mask) >= 0) begin
                    m_dirm_mgr.update_model_for_allocating_request_or_vhit(sfid, {cohreq_pktq[cohreq_pktq.size() - 1].m_ns, cohreq_pktq[cohreq_pktq.size() - 1].m_addr}, item.m_way_vec_or_mask, m_dm_pktq[m_dm_pktq.size() - 1].m_eviction_needed_sfvec[sfid]);
                end
            end

    
            //allocate sf_segment in all sfs where hit is in vb
            for(int sfid = 0; sfid < addrMgrConst::NUM_SF; sfid++) begin
                //if vb recovery is enabled cannot trust eviction_needed or vb_hit from model. just trust RTL's wr_required.
                //if (m_dm_pktq[m_dm_pktq.size() - 1].m_eviction_needed_sfvec[sfid] || m_dm_pktq[m_dm_pktq.size() - 1].m_vbhit_sfvec[sfid]) begin
                if (item.m_rtl_vbhit_sfvec[sfid]) begin
                    m_dirm_mgr.update_model_for_allocating_request_or_vhit(sfid, {cohreq_pktq[cohreq_pktq.size() - 1].m_ns, cohreq_pktq[cohreq_pktq.size() - 1].m_addr}, item.m_way_vec_or_mask, m_dm_pktq[m_dm_pktq.size() - 1].m_eviction_needed_sfvec[sfid]);
                end
            end 

            for(int sfid = 0; sfid < addrMgrConst::NUM_SF; sfid++) begin
                hf_allocreq = (cohreq_pktq[cohreq_pktq.size() - 1].m_alloc && (sfid == cohreq_pktq[cohreq_pktq.size() - 1].m_filter_num)) ? 1 : 0;
                m_dirm_mgr.update_model(sfid, hf_allocreq, {cohreq_pktq[cohreq_pktq.size() - 1].m_ns, cohreq_pktq[cohreq_pktq.size() - 1].m_addr}, item.m_way_vec_or_mask, item.m_wr_required);
            end

            //Additional sanity checks on lkprsp, based on per sf
            for(int sfid = 0; sfid < addrMgrConst::NUM_SF; sfid++) begin
                m_dirm_mgr.dm_lkprsp_checks((cohreq_pktq[cohreq_pktq.size() - 1].m_alloc ? cohreq_pktq[cohreq_pktq.size() - 1].m_filter_num : -1), item);
            end

        end//only if dm chks are enabled

        //sample DM coverage data.
        <% if(obj.COVER_ON) { %>
        //Only look at RTL signal for coverage collection
        m_dirm_mgr.dm_lkprsp_sf_coverage((cohreq_pktq[cohreq_pktq.size() - 1].m_alloc ? cohreq_pktq[cohreq_pktq.size() - 1].m_filter_num : -1), item);
        m_dirm_mgr.collect_dm_coverage();
        m_cov.collect_dirm_scenario(m_dirm_mgr);
        <% } %>

        // For Read Stash command predict the STR_req also
        if (dce_goldenref_model::is_stash_read(m_cmd_type)) begin
            predict_snp_req_rd_stash_ops();
        end

        if (dce_goldenref_model::is_stash_request(m_cmd_type)) begin
            predict_rbr_snp_req_stash_ops(1);
        end else begin
            predict_rbr_snp_req(1);
        end

        if (dce_goldenref_model::is_stash_read(m_cmd_type))
            predict_mrd_req_stash_ops();
        else
            predict_mrd_req();
        
        if (item.m_error == 0) begin
            predict_dm_cmt_req();
        end

        if (!(dce_goldenref_model::is_stash_read(m_cmd_type) && cohreq_pktq[cohreq_pktq.size() - 1].m_alloc)) begin
            //AT LKP_RSP: predict STRreq for all ops except ReadStash with 'valid target identified'. STRreq is predicted for ReadStash with 'valid target identified' at SNPrsp from stash target to grab the snarf bit.
            if (m_cmd_type inside {CMD_CLN_SH_PER, CMD_CLN_VLD, CMD_CLN_INV}) begin
            //predicting STR in MRDrsp save function for these cmd types because STRReq should be scheduled after MrdRsp
            //`uvm_info("DCE_SCB_DBG", $psprintf("Skipping predicting STR Req here"), UVM_LOW)
            end
            else
                predict_str_req();
        end
    end // access_type == LKP_RSP
    else if (item.m_access_type == DM_RTY_RSP) begin
        m_dm_pktq[m_dm_pktq.size() - 1].copy(item);
    
        //sample DM coverage data.
        <% if(obj.COVER_ON) { %>
        m_dirm_mgr.collect_dm_rtyrsp_coverage();
        m_cov.collect_dirm_scenario_on_rtyrsp(m_dirm_mgr);
        m_cov.collect_dirm_scenario(m_dirm_mgr);
        <% } %>

        //#Check.DCE.dm_rtyreq_dm_cmdreq_expected
        m_states["dirreq"].set_expect();
        coh_req = new("dm_coh_req");
        coh_req.m_access_type = DM_CMD_REQ;
        coh_req.m_iid         = m_initcmdupd_req_pkt.smi_src_id;
        coh_req.m_addr        = m_initcmdupd_req_pkt.smi_addr;
        coh_req.m_ns          = m_initcmdupd_req_pkt.smi_ns;
        $cast(coh_req.m_type, m_initcmdupd_req_pkt.smi_msg_type);
        
        if (dce_goldenref_model::is_master_allocating_req(coh_req.m_type)) begin
            coh_req.m_alloc = 1;
            coh_req.m_filter_num  = addrMgrConst::get_snoopfilter_id(m_initcmdupd_req_pkt.smi_src_ncore_unit_id);
        end else if (      dce_goldenref_model::is_stash_request(coh_req.m_type)
                        && m_initcmdupd_req_pkt.smi_mpf1_stash_valid
                        && (m_initcmdupd_req_pkt.smi_mpf1_stash_nid inside {addrMgrConst::stash_nids,addrMgrConst::stash_nids_ace_aius})
                        && addrMgrConst::is_stash_enable(addrMgrConst::agentid_assoc2funitid(m_initcmdupd_req_pkt.smi_mpf1_stash_nid))) begin

            coh_req.m_alloc = 1;
            coh_req.m_filter_num  =  addrMgrConst::get_snoopfilter_id(m_initcmdupd_req_pkt.smi_mpf1_stash_nid);
            coh_req.m_sid         =  m_initcmdupd_req_pkt.smi_mpf1_stash_nid << WSMINCOREPORTID;
        end else begin
            coh_req.m_alloc = 0;
            coh_req.m_filter_num = 0;
        end
        m_dm_pktq.push_back(coh_req);
    end

endfunction: save_dm_rsp_txn

//*************************************************************************
function void dce_scb_txn::check_snp_req(const ref smi_seq_item seq_item);
    int idxq[$];
    string s;
    smi_seq_item drvsnp_rsp_pkt;

    idxq = this.m_expsnp_req_pktq.find_index(item) with (item.smi_targ_ncore_unit_id == seq_item.smi_targ_ncore_unit_id);

    //#Check.DCE.SnpReq
    if(idxq.size() > 1) begin
        foreach(idxq[idx]) begin
            $sformat(s, "%s\n@ {EXP} SNPreq[%0d]: %s", s, idx,
                m_expsnp_req_pktq[idxq[idx]].convert2string());
        end
        $sformat(s, "%s\n@ {ACT} SNPreq: %s", s, seq_item.convert2string());
        `uvm_info("DCE SCB", s, UVM_LOW)
        `uvm_error("DCE SCB", "TbError: Multiple matches for given SNPreq")

    end else if(idxq.size() == 0) begin
        foreach(m_expsnp_req_pktq[idx]) begin
            $sformat(s, "%s\n@ {EXP} SNPreq[%0d]: %s", s, idx, m_expsnp_req_pktq[idx].convert2string());
        end
        $sformat(s, "%s\n@ {ACT} SNPreq: %s", s, seq_item.convert2string());
        `uvm_info("DCE SCB", s, UVM_LOW)
        `uvm_error("DCE SCB", "None of the {EXP} SNPreq's match with {ACT}")
    end else if (dce_goldenref_model::is_stash_read(m_cmd_type) && (m_states["snpreq"].get_valid_count() == 1) && idxq[0] != 0) begin //this checks makes sure 1st snoop is always sent to stash target
        `uvm_error("DCE SCB", "1st snoop to Read Stash request is not sent to Stash Target")
    end else begin
        `uvm_info("DCE SCB", "SNPreq match was successfull", UVM_LOW)
    end

    //#Check.DCE.SnpReq.RBID
    if( dce_goldenref_model::is_stash_read(m_cmd_type) && 
        m_initcmdupd_req_pkt.smi_mpf1_stash_valid &&
        (m_initcmdupd_req_pkt.smi_mpf1_stash_nid inside {addrMgrConst::stash_nids,addrMgrConst::stash_nids_ace_aius}) &&
        addrMgrConst::is_stash_enable(addrMgrConst::agentid_assoc2funitid(m_initcmdupd_req_pkt.smi_mpf1_stash_nid)) &&
        (m_initcmdupd_req_pkt.smi_mpf1_stash_nid == seq_item.smi_targ_ncore_unit_id)) begin
        //SnpReq.RBID to Stash Target is garbage, since there it is guaranteed that there will not be a DTW from Stash Target
    end else begin 
        if (m_rbid_status == RBID_UNRESERVED) begin
            m_rbid_status = RBID_RESERVED;
            m_rbid        = seq_item.smi_rbid;
        end else if (m_rbid != seq_item.smi_rbid) begin
            `uvm_error("RBID_ERROR", $psprintf("On SNP_REQ Expected RBID: %p, Actual RBID: %p", m_rbid, seq_item.smi_rbid))
        end
    end
    
    //We have RBID checks above, since it cannot be predicted when snpreq is predicted, we just assign the expected_pkt.RBID == actual_pkt.RBID
    m_expsnp_req_pktq[idxq[0]].smi_rbid = seq_item.smi_rbid;

    //Enable smi_up checks for only read_type request snoops.
    //smi_up checks can be ignored for read stash ops since there is never a DT_aiu from the snooper.
    if (dce_goldenref_model::is_read(m_cmd_type) == 0) begin // changed back to original from "Added smi_msg_type refer to CONC-7590"
        m_expsnp_req_pktq[idxq[0]].smi_up = seq_item.smi_up;
    end

    // See CONC-5168 for reference
    // mpf1 and mpf2 are dont care for snps initiated by recall requests
    if(m_req_type == REC_REQ) begin
        m_expsnp_req_pktq[idxq[0]].smi_mpf1_stash_valid  = seq_item.smi_mpf1_stash_valid;
        m_expsnp_req_pktq[idxq[0]].smi_mpf1_stash_nid    = seq_item.smi_mpf1_stash_nid;
        m_expsnp_req_pktq[idxq[0]].smi_mpf1_dtr_tgt_id   = seq_item.smi_mpf1_dtr_tgt_id;         
        m_expsnp_req_pktq[idxq[0]].smi_mpf2_dtr_msg_id   = seq_item.smi_mpf2_dtr_msg_id;       
        m_expsnp_req_pktq[idxq[0]].smi_mpf2_stash_valid  = seq_item.smi_mpf2_stash_valid;     
        m_expsnp_req_pktq[idxq[0]].smi_mpf2_stash_lpid   = seq_item.smi_mpf2_stash_lpid;     

        if (m_attid_status == ATTID_IS_INACTIVE) begin
            //This is the first SMI req sent out for a recall op, so it is hard to predict smi_msg_id
            m_attid_status = ATTID_IS_ACTIVE;
            m_attid        = seq_item.smi_msg_id;
        end  
        m_expsnp_req_pktq[idxq[0]].smi_msg_id = m_attid;
    end

    //in address region overlap test, there is either addr_map hit none, or multiple hit, the dmi_id will be invalid see CONC-6276
    if ($test$plusargs("k_csr_seq=dce_csr_address_region_overlap_seq") || $test$plusargs("k_csr_seq=dce_csr_no_address_hit_seq")) begin 
        m_expsnp_req_pktq[idxq[0]].smi_dest_id = seq_item.smi_dest_id;
    end 
    
    //mpf1 and mpf2 are dont care. so match RTL 
    if (!(seq_item.smi_msg_type inside {SNP_STSH_SH, SNP_STSH_UNQ, SNP_INV_STSH, SNP_UNQ_STSH,
                                        SNP_NOSDINT, SNP_CLN_DTR, SNP_VLD_DTR, SNP_INV_DTR, SNP_NITC, SNP_NITCCI, SNP_NITCMI})) begin
        m_expsnp_req_pktq[idxq[0]].smi_ndp[SNP_REQ_MPF1_MSB:SNP_REQ_MPF1_LSB] = seq_item.smi_ndp[SNP_REQ_MPF1_MSB:SNP_REQ_MPF1_LSB];
        m_expsnp_req_pktq[idxq[0]].smi_ndp[SNP_REQ_MPF2_MSB:SNP_REQ_MPF2_LSB] = seq_item.smi_ndp[SNP_REQ_MPF2_MSB:SNP_REQ_MPF2_LSB];
    end

    if(seq_item.smi_msg_type inside {SNP_INV_DTW, SNP_CLN_DTW, SNP_INV, SNP_STSH_UNQ, SNP_STSH_SH, SNP_UNQ_STSH, SNP_INV_STSH}) begin
        m_expsnp_req_pktq[idxq[0]].smi_ndp[SNP_REQ_MPF3_MSB:SNP_REQ_MPF3_LSB] = seq_item.smi_ndp[SNP_REQ_MPF3_MSB:SNP_REQ_MPF3_LSB];
    end
    
    m_expsnp_req_pktq[idxq[0]].compare(seq_item);
    m_expsnp_req_pktq[idxq[0]].copy(seq_item);
    //m_expsnp_req_pktq[idxq[0]].t_smi_ndp_valid = $time;

    //create expected snp_rsp_pkt 
    //#Check.DCE.SnpRsp
    m_states["snprsp"].set_expect();
    
    drvsnp_rsp_pkt = new("snp_rsp");
    drvsnp_rsp_pkt.t_smi_ndp_valid = 0;
    drvsnp_rsp_pkt.construct_snprsp(
        .smi_targ_ncore_unit_id (addrMgrConst::get_dce_funitid(<%=obj.Id%>)), //#Check.DCE.SnpRsp.TargId
        .smi_src_ncore_unit_id  (seq_item.smi_targ_ncore_unit_id), //#Check.DCE.SnpRsp.SrcId
        .smi_msg_type           ('h0),
        .smi_msg_id             ('h0),
        .smi_msg_tier           ('h0),
        .smi_steer              ('h0),
        .smi_msg_pri            (seq_item.smi_msg_pri),
        .smi_msg_qos            ('h0),
        .smi_rmsg_id            (seq_item.smi_msg_id), //#Check.DCE..SnpRsp.RMsgId 
        .smi_tm                 (seq_item.smi_tm), //#Check.DCE..SnpRsp.RMsgId 
        .smi_msg_err            ('h0),
        .smi_cmstatus           ('h0),
        .smi_cmstatus_rv        ('h0),
        .smi_cmstatus_rs        ('h0),
        .smi_cmstatus_dc        ('h0),
        .smi_cmstatus_dt_aiu    ('h0),
        .smi_cmstatus_dt_dmi    ('h0),
        .smi_cmstatus_snarf     ('h0),
        .smi_mpf1_dtr_msg_id    ('h0),
        .smi_intfsize           ('h0)
    );

    m_drvsnp_rsp_pktq.push_back(drvsnp_rsp_pkt);
    
endfunction: check_snp_req

//*************************************************************************
function void dce_scb_txn::check_str_req(const ref smi_seq_item seq_item);
    bit ex_op;
    string s;

    //Reserve/Check RBID on STR_REQ only for writes.
    //#Check.DCE.StrReq_RBID
    if (dce_goldenref_model::is_nonstash_write(m_cmd_type) || 
        dce_goldenref_model::is_stash_write(m_cmd_type) ) begin 
        if ((m_rbid_status == RBID_UNRESERVED)) begin
            m_rbid_status = RBID_RESERVED;
            m_rbid        = seq_item.smi_rbid;
        end else if (m_rbid != seq_item.smi_rbid) begin
            `uvm_error("RBID_ERROR", $psprintf("On STR_REQ Expected RBID: %p, Actual RBID: %p", m_rbid, seq_item.smi_rbid))
        end
    end

    //assign actual pkt values to fields that cannot be predicted.
    m_expstr_req_pkt.smi_rbid = seq_item.smi_rbid;
  
    m_expstr_req_pkt.smi_ndp_len = w_STR_REQ_NDP;

    //Disable smi_intfsize, mpf1, mpf2 check for STR for non-stash requests since it is a don't care (See ConcertoCProtocol Spec: CCMP STRreq message fields)
    if (dce_goldenref_model::is_stash_request(m_cmd_type) == 0) begin
        //Needed for full_sys
        m_expstr_req_pkt.smi_ndp[STR_REQ_MPF1_MSB:STR_REQ_MPF1_LSB] = seq_item.smi_ndp[STR_REQ_MPF1_MSB:STR_REQ_MPF1_LSB];
        m_expstr_req_pkt.smi_ndp[STR_REQ_MPF2_MSB:STR_REQ_MPF2_LSB] = seq_item.smi_ndp[STR_REQ_MPF2_MSB:STR_REQ_MPF2_LSB];
        m_expstr_req_pkt.smi_mpf1 = seq_item.smi_mpf1;
        m_expstr_req_pkt.smi_mpf2 = seq_item.smi_mpf2;
        
        m_expstr_req_pkt.smi_intfsize        = seq_item.smi_intfsize;
        m_expstr_req_pkt.smi_mpf1_dtr_tgt_id = seq_item.smi_mpf1_dtr_tgt_id;
        m_expstr_req_pkt.smi_mpf2_dtr_msg_id = seq_item.smi_mpf2_dtr_msg_id;
        m_expstr_req_pkt.smi_mpf1_stash_nid   = seq_item.smi_mpf1_stash_nid;
        m_expstr_req_pkt.smi_mpf1_stash_valid = seq_item.smi_mpf1_stash_valid;
        //m_expstr_req_pkt.smi_cmstatus_snarf   = seq_item.smi_cmstatus_snarf; // Maps to cmstatus[0] same as exok, not needed for exclusive ops 
    
        //for non-stash and non-exclusive request cmstatus.snarf/exokay is dont care
        if (ex_store == 0 && ex_load == 0) begin //Not exclusive ops 
            m_expstr_req_pkt.smi_cmstatus_exok  = seq_item.smi_cmstatus_exok; 
        end
    end else begin //For stashing requests
        m_expstr_req_pkt.smi_cmstatus_exok  = seq_item.smi_cmstatus_exok;// Maps to cmstatus[0] same as snarf, not needed for Stashing type 
        m_expstr_req_pkt.smi_cmstatus_st    = seq_item.smi_cmstatus_st;  // Maps to cmstatus[0] same as snarf, not needed for Stashing type
        if (      (m_states["snpreq"].get_valid_count() > 0)
              &&   m_states["snpreq"].is_complete()
              &&   m_states["snprsp"].is_complete()) begin
            m_expstr_req_pkt.smi_intfsize = seq_item.smi_intfsize; //don't care
            foreach(m_drvsnp_rsp_pktq[i]) begin
                if (m_drvsnp_rsp_pktq[i].smi_cmstatus_snarf == 1 && m_drvsnp_rsp_pktq[i].smi_cmstatus_err != 1) begin
                    m_expstr_req_pkt.smi_intfsize = m_drvsnp_rsp_pktq[i].smi_intfsize;
                    m_expstr_req_pkt.smi_cmstatus_snarf  = 1; 
                    break;
                end
            end
            if (m_expstr_req_pkt.smi_cmstatus_snarf == 0) begin
                m_expstr_req_pkt.smi_mpf1_dtr_tgt_id = seq_item.smi_mpf1_dtr_tgt_id; //don't care if snarf=0
                m_expstr_req_pkt.smi_mpf2_dtr_msg_id = seq_item.smi_mpf2_dtr_msg_id; //don't care if snarf=0
            end
        end else begin
            //Needed for full_sys
            m_expstr_req_pkt.smi_ndp[STR_REQ_MPF1_MSB:STR_REQ_MPF1_LSB] = seq_item.smi_ndp[STR_REQ_MPF1_MSB:STR_REQ_MPF1_LSB];
            m_expstr_req_pkt.smi_ndp[STR_REQ_MPF2_MSB:STR_REQ_MPF2_LSB] = seq_item.smi_ndp[STR_REQ_MPF2_MSB:STR_REQ_MPF2_LSB];
            
            m_expstr_req_pkt.smi_intfsize = seq_item.smi_intfsize; //don't care
            m_expstr_req_pkt.smi_mpf1_dtr_tgt_id = seq_item.smi_mpf1_dtr_tgt_id; //don't care if snarf=0
            m_expstr_req_pkt.smi_mpf2_dtr_msg_id = seq_item.smi_mpf2_dtr_msg_id; //don't care if snarf=0
        end
    end

    m_expstr_req_pkt.compare(seq_item);
    m_expstr_req_pkt.copy(seq_item);

    //create expected str_rsp_pkt 
    m_states["strrsp"].set_expect();
    
    m_drvstr_rsp_pkt = new("str_rsp");
    m_drvstr_rsp_pkt.t_smi_ndp_valid = 0;

    //#Check.DCE.StrRspCheck
    m_drvstr_rsp_pkt.construct_strrsp(
        .smi_targ_ncore_unit_id (addrMgrConst::get_dce_funitid(<%=obj.Id%>)), //#Check.DCE.StrRsp.TargetId
        .smi_src_ncore_unit_id  (seq_item.smi_targ_ncore_unit_id),            //#Check.DCE.StrRsp.InitiatorId 
        .smi_msg_tier           ('h0),
        .smi_steer              ('h0),
        .smi_msg_qos            ('h0),
        .smi_msg_pri            (seq_item.smi_msg_pri),
        .smi_msg_type           ('h0),
        .smi_tm                 (seq_item.smi_tm),
        .smi_msg_id             ('h0),
        .smi_msg_err            ('h0),
        .smi_cmstatus           ('h0),
        .smi_rmsg_id            (seq_item.smi_msg_id)                         //#Check.DCE.StrRsp.MsgId
              );
    
    s = "BEFORE";
    foreach(m_states[key]) begin
             $sformat(s, "%s %s:", s, key);
             $sformat(s, "%s %s\n", s, m_states[key].convert2string());
    end
    //`uvm_info("DCE SCB", s, UVM_LOW)

    //Clear all remaining expects except strrsp if strreq is issued with an error
    if (seq_item.smi_cmstatus_err == 1) begin
        if (dce_goldenref_model::is_stash_read(m_cmd_type)) begin 
            foreach(m_states[idx]) begin
                if (m_states[idx].get_name() inside {"mrdreq", "mrdrsp"}) begin
                    if (m_states[idx].is_complete() == 0) begin 
                        m_states[idx].clear_expect();
                        m_states[idx].set_complete();
                    end
                end
            end
        end
//      if (dce_goldenref_model::is_stash_write(m_cmd_type)) begin 
//          foreach(m_states[idx]) begin
//              if (m_states[idx].get_name() inside {"rbureq", "rbursp"}) begin
//                  if (m_states[idx].is_complete() == 0) begin 
//                      m_states[idx].clear_expect();
//                      m_states[idx].set_complete();
//                  end
//              end
//          end
//      end
    end

    s = "AFTER";

    foreach(m_states[key]) begin
             $sformat(s, "%s %s:", s, key);
             $sformat(s, "%s %s\n", s, m_states[key].convert2string());
    end
    //`uvm_info("DCE SCB", s, UVM_LOW)
endfunction: check_str_req

//*************************************************************************
function void dce_scb_txn::check_mrd_req(const ref smi_seq_item seq_item);
    dm_seq_item cohreq_pktq[$];
    m_expmrd_req_pkt.smi_ndp_len = w_MRD_REQ_NDP;

    cohreq_pktq = m_dm_pktq.find(item) with (item.m_access_type == DM_CMD_REQ);
    
    //dont care but match RTL so DV can compute ndp_prot bits
    if (seq_item.smi_msg_type == MRD_PREF) begin
        m_expmrd_req_pkt.smi_mpf1_dtr_tgt_id = seq_item.smi_mpf1_dtr_tgt_id;
        m_expmrd_req_pkt.smi_mpf2_dtr_msg_id = seq_item.smi_mpf2_dtr_msg_id;
        m_expmrd_req_pkt.smi_mpf1 = seq_item.smi_mpf1;
        m_expmrd_req_pkt.smi_mpf2 = seq_item.smi_mpf2;
    end 

    m_expmrd_req_pkt.compare(seq_item);
    m_expmrd_req_pkt.copy(seq_item);

    //create expected mrd_rsp_pkt 
    m_states["mrdrsp"].set_expect();
    m_drvmrd_rsp_pkt = new("mrd_rsp");
    m_drvmrd_rsp_pkt.t_smi_ndp_valid = 0;
    
   //#Check.DCE.Concerto.v3.0.MrdRsp 
    m_drvmrd_rsp_pkt.construct_mrdrsp(
        .smi_targ_ncore_unit_id (addrMgrConst::get_dce_funitid(<%=obj.Id%>)), //#Check.DCE.Concerto.v3.0.MrdRsp.InitiatorId
        .smi_src_ncore_unit_id  (seq_item.smi_targ_ncore_unit_id), //#Check.DCE.Concerto.v3.0.MrdRsp.TargetId
        .smi_msg_tier           ('h0),
        .smi_steer              ('h0),
        .smi_msg_qos            ('h0),
        .smi_msg_pri            (seq_item.smi_msg_pri),
        .smi_msg_type           ('h0),
        .smi_msg_id             ('h0),
        .smi_msg_err            ('h0),
        .smi_cmstatus           ('h0),
        .smi_tm                 (seq_item.smi_tm),
        .smi_rmsg_id            (seq_item.smi_msg_id) //#Check.DCE.Concerto.v3.0.MrdRsp.RMsgId
    );

endfunction: check_mrd_req

//*************************************************************************
function void dce_scb_txn::check_rbr_req(const ref smi_seq_item seq_item);
    smi_seq_item exprbr_req_pkt;
    smi_seq_item drvrbr_rsp_pkt;

    //#Check.DCE.RbrReq.RBID
    if (m_rbid_status == RBID_UNRESERVED) begin
        m_rbid_status = RBID_RESERVED;
        m_rbid        = seq_item.smi_rbid;
    end else if (m_rbid != seq_item.smi_rbid) begin
        `uvm_error("RBID_ERROR", $psprintf("On RBR_REQ Expected RBID: %p, Actual RBID: %p", m_rbid, seq_item.smi_rbid))
    end
    
    if (m_exprbr_req_pktq.size() == 0)
        `uvm_error("DCE SCB", "EXP RBR REQ pkt q should not be empty")

    if (seq_item.smi_rtype == 1) begin
        exprbr_req_pkt = m_exprbr_req_pktq.pop_front();
    end else begin
        exprbr_req_pkt = m_exprbr_req_pktq.pop_back();
    end
    
    //We have RBID checks above, since it cannot be predicted when rbrreq is predicted, we just assign the expected_pkt.RBID == actual_pkt.RBID
    exprbr_req_pkt.smi_rbid = seq_item.smi_rbid;
    
    if (m_req_type == REC_REQ) begin
        if (m_attid_status == ATTID_IS_INACTIVE) begin
            //This is the first SMI req sent out for a recall op, so it is hard to predict smi_msg_id
            m_attid_status = ATTID_IS_ACTIVE;
            m_attid        = seq_item.smi_msg_id;
        end  
        exprbr_req_pkt.smi_msg_id = m_attid;
    end

    //RTL's dmiid computation is garbage due to no_address hit. Hence set DV expectation to RTL value. i.e disable targetid check. CONC-6276
    if (    $test$plusargs("k_csr_seq=dce_csr_no_address_hit_seq") || 
            $test$plusargs("k_csr_seq=dce_csr_address_region_overlap_seq") ) begin

         exprbr_req_pkt.smi_targ_ncore_unit_id = seq_item.smi_targ_ncore_unit_id;
    end
    
    //CONC-7204 RBReq.MPF1 check is disabled, RTL drives 0 and DMI does not look at this field.
    exprbr_req_pkt.smi_mpf1 = seq_item.smi_mpf1;
    exprbr_req_pkt.smi_ndp[RB_REQ_MPF1_MSB:RB_REQ_MPF1_LSB] = seq_item.smi_ndp[RB_REQ_MPF1_MSB:RB_REQ_MPF1_LSB];

    exprbr_req_pkt.smi_ndp_len = w_RB_REQ_NDP;
    exprbr_req_pkt.compare(seq_item);

    exprbr_req_pkt.copy(seq_item);

    if (seq_item.smi_rtype == 1) begin
        m_exprbr_req_pktq.push_front(exprbr_req_pkt);
    end else begin
        m_exprbr_req_pktq.push_back(exprbr_req_pkt);
    end
    predict_rb_rsp();
endfunction: check_rbr_req

//**************************************************************************
function bit dce_scb_txn::smi_snprsp_maps_to_req(const ref smi_seq_item seq_item);
    int snpreq_idxq[$];

    snpreq_idxq = m_expsnp_req_pktq.find_index(item) with (item.smi_targ_ncore_unit_id == seq_item.smi_src_ncore_unit_id);

    if (snpreq_idxq.size() == 1) begin
       return 1;
    end
    
    return 0;
endfunction: smi_snprsp_maps_to_req

//***************************************************************************
function void dce_scb_txn::save_snprsp(const ref smi_seq_item seq_item);
    dm_seq_item cohreq_pktq[$], lkprsp_pktq[$], cmtreq_pktq[$], pkt;
    smi_seq_item tmp, rbr_req_pkt;
    smi_intfsize_t exp_intfsize;
    string msg;
    bit dt_dmi = 0;
    bit snarf = 0;
    smi_cmstatus_t cmstatus = 0;
    int discard;
    bit predict_rbrreq = 0;
    bit predict_strreq = 0;
    int idxq[$];
    int snpreq_idxq[$];
    bit ign;
    bit [WSMIMPF1-1:0] exp_mpf1_dtr_tgt_id; 
    bit [WSMIMPF2-1:0] exp_mpf2_dtr_msg_id; 
    bit [2:0] exp_smi_cmstatus_state; 
    int agentid, snooper_agentid;
    bit [WSMICMSTATUS-1:0] exp_smi_cmstatus;
    bit [WSMICMSTATUSERR-1:0] exp_smi_cmstatus_err;
    bit [WSMICMSTATUSERRPAYLOAD-1:0] exp_smi_cmstatus_err_payload;
    int snprsp_cmstatus_errq[$], snprsp_cmstatus_dtaiuq[$];
    bit stash_target;
    bit snprsp_err = 0;

    
    $cast(tmp, seq_item.clone());
    cohreq_pktq = m_dm_pktq.find(item) with (item.m_access_type == DM_CMD_REQ);

    if ((tmp.smi_cmstatus_err == 1)
         && ((tmp.smi_cmstatus_err_payload == 'b100) //address error 
            || (tmp.smi_cmstatus_err_payload == 'b011) //data error 
            )) begin 
        SNPrsp_data_or_address_error_in_cmstatus = 1;
        snprsp_err = 1;
    end 

    //#Check.DCE.SnpRsp_SnpInvDtr
    if(m_expsnp_req_pktq[0].smi_msg_type == SNP_INV_DTR && m_expsnp_req_pktq[0].smi_up == 2'b11) begin
        // CONC-13847
        // The following condition violates the concerto spec and hence commenting out
        // if(tmp.smi_cmstatus[1] == 0 && tmp.smi_cmstatus[2] == 1 && tmp.smi_cmstatus_err == 0)
        //         `uvm_error("DCE_SCB", "SnpRsp.DT_AIU is 1 when SnpRsp.DT_DMI is 0 for eSnpInvDtr")
    end

    // Find corresponding SnpReq to get its Snp_type
    snpreq_idxq = m_expsnp_req_pktq.find_index(item) with (item.smi_targ_ncore_unit_id == tmp.smi_src_ncore_unit_id);
    if(snpreq_idxq.size() > 1)
        `uvm_error("DCE SCB", $sformatf("SnpRsp.smi_src_ncore_unit_id matched multiple(Total = %0d) SnpReq.smi_targ_ncore_unit_id",snpreq_idxq.size()))
    if(snpreq_idxq.size() == 0)
        `uvm_error("DCE SCB", "SnpRsp.smi_src_ncore_unit_id didn't matched any SnpReq.smi_targ_ncore_unit_id")

    snooper_agentid = addrMgrConst::agentid_assoc2funitid(tmp.smi_src_ncore_unit_id);
    if (dce_goldenref_model::is_stash_request(m_cmd_type)) begin 
        if (cohreq_pktq[cohreq_pktq.size() - 1].m_alloc && ((cohreq_pktq[cohreq_pktq.size() - 1].m_sid >> WSMINCOREPORTID) == tmp.smi_src_ncore_unit_id)) 
            idxq = dce_goldenref_model::snptyp2legl_cmsts_stshtgt[m_expsnp_req_pktq[snpreq_idxq[0]].smi_msg_type].find_index(item) with (item == tmp.smi_cmstatus);
        else 
            idxq = dce_goldenref_model::snptyp2legl_cmsts_peer[addrMgrConst::get_native_interface(snooper_agentid)][m_expsnp_req_pktq[snpreq_idxq[0]].smi_msg_type].find_index(item) with (item == tmp.smi_cmstatus);
    end else begin 
        idxq = dce_goldenref_model::snptyp2legl_cmsts[addrMgrConst::get_native_interface(snooper_agentid)][m_expsnp_req_pktq[snpreq_idxq[0]].smi_msg_type].find_index(item) with (item == tmp.smi_cmstatus);
    end
    
    //#Check.DCE.SnpRsp.CMStatus
    if (idxq.size() != 1 && snprsp_err != 1) begin
        `uvm_error("DCE SCB", $psprintf("SnpRsp.smi_cmstatus unexpected SnooperType:%0p SnpType:%0p CMStatus --> actual:%0b expected:check possible legal values in dce_goldenref_model", addrMgrConst::get_native_interface(snooper_agentid), eMsgSNP'(m_expsnp_req_pktq[snpreq_idxq[0]].smi_msg_type), tmp.smi_cmstatus))
    end

    idxq = m_drvsnp_rsp_pktq.find_index(item) with (item.smi_src_ncore_unit_id == tmp.smi_src_ncore_unit_id);
    if (idxq.size() != 1)
        `uvm_error("DCE SCB", "snprsp.smi_src_ncore_unit_id does not match any expected snprsp pkts")

    m_drvsnp_rsp_pktq[idxq[0]] = tmp;

    //check if all snp_rsps are received and predict rbr_req.
    if (dce_goldenref_model::is_read(m_cmd_type) || dce_goldenref_model::is_clean(m_cmd_type) || dce_goldenref_model::is_atomic(m_cmd_type) || (m_req_type == REC_REQ)) begin
        if (      (m_states["snpreq"].get_valid_count() == m_states["snprsp"].get_valid_count()) 
              &&   m_states["snpreq"].is_complete()
              &&   m_states["snprsp"].is_complete()) begin
            foreach(m_drvsnp_rsp_pktq[i]) begin
                if (m_drvsnp_rsp_pktq[i].smi_cmstatus_err == 0)
                    dt_dmi |= m_drvsnp_rsp_pktq[i].smi_cmstatus_dt_dmi;
            end
            if (dt_dmi == 0) begin //predict rbr release request
                predict_rbrreq = 1;
            end
        end
    end

    //LKP_RSP data is only needed for code below hence guard it with m_req_type == CMD_REQ or we hit fail on m_req_type == REC_REQ
    if (m_req_type == CMD_REQ) begin
        lkprsp_pktq = m_dm_pktq.find(item) with (item.m_access_type == DM_LKP_RSP);

        if(dce_goldenref_model::is_stash_read(m_cmd_type) && !m_states["snpreq"].is_complete()) begin // Snarf=0 then remove the expected SnpReq on Non-target owner
            foreach(m_drvsnp_rsp_pktq[i]) begin 
        if(m_drvsnp_rsp_pktq[i].smi_cmstatus_err == 0)
            snarf |= m_drvsnp_rsp_pktq[i].smi_cmstatus_snarf;
        end
            if(snarf==0) begin
                 m_states["snpreq"].clear_expect();
                 m_states["snprsp"].clear_expect();
                 m_states["snpreq"].set_expect();
                 m_states["snprsp"].set_expect();
                 m_states["snpreq"].set_complete();
                 m_states["snprsp"].set_complete();
            end
        end

        if (lkprsp_pktq.size == 0 ) begin
            `uvm_info("DCE_SCB_TXN",$sformatf("SnpReq/Rsp came before DM LKP_RSP "),UVM_LOW)
        end else if(lkprsp_pktq.size != 1) begin
            `uvm_error("DCE_SCB_TXN", "Multiple DM LKP_RSP not possible6");
        end else begin
            if (      (m_states["snpreq"].get_valid_count() >= 1) 
                  &&   m_states["snpreq"].is_complete()
                  &&   m_states["snprsp"].is_complete()) begin
                foreach(m_drvsnp_rsp_pktq[i]) begin
                    //for stash write if snarf is set by stash target, issue rbr_release
                    if (m_drvsnp_rsp_pktq[i].smi_cmstatus_err == 0)
                        snarf |= m_drvsnp_rsp_pktq[i].smi_cmstatus_snarf;
                    
                    //for stash read if all snp_rsps set dt_dmi=0 then issue rbr_release
                    if (dce_goldenref_model::is_stash_read(m_cmd_type) && lkprsp_pktq[0].m_owner_val && !m_drvsnp_rsp_pktq[i].smi_cmstatus_err) 
                        dt_dmi |= m_drvsnp_rsp_pktq[i].smi_cmstatus_dt_dmi;
                end
                if ( snarf == 1 && // Snarf has to be 1 (For StashOnce if snarf=0 no RBR request,So no DTW nor Release) (WrStash if snarf=1,hence no DTW to DMI from RN, Hence predict release)
                      (dce_goldenref_model::is_stash_write(m_cmd_type) ||
                      (dt_dmi == 0 && dce_goldenref_model::is_stash_read(m_cmd_type) && m_states["rbrreq"].is_expect())
                       // ( m_cmd_type!=CMD_LD_CCH_SH  || (lkprsp_pktq[0].m_sharer_vec && lkprsp_pktq[0].m_owner_val && (lkprsp_pktq[0].m_sharer_vec != (1<<m_sid_cacheid)))     ) &&
                       // ( m_cmd_type!=CMD_LD_CCH_UNQ || (lkprsp_pktq[0].m_sharer_vec && (!lkprsp_pktq[0].m_owner_val || !(lkprsp_pktq[0].m_sharer_vec inside (1<<m_sid_cacheid))) ) )// target not owner or requestor
                      )
                   ) begin //predict rbr release request
                    predict_rbrreq = 1;
                end
            end
            //HS 03-15-2021 Do not remove the allocated segment for stash commands since there will always be a write to that segment since lkprsp.wr_required==1
            //Below was probably stale code. Remove 
            //if (m_dm_chks_en) begin 
            //  // In Case of SnpRsp from Target came after the LkpRsp , we have to de-allocate SF based on Snarf=0
            //  if ((dce_goldenref_model::is_stash_read(m_cmd_type) || (dce_goldenref_model::is_stash_write(m_cmd_type) && m_dm_pktq[m_dm_pktq.size() - 1].m_wr_required==0 && lkprsp_pktq[0].is_dm_miss())) && (snarf == 0) && (m_states["snprsp"].get_valid_count() == 1) ) begin 
            //      if (cohreq_pktq[cohreq_pktq.size() - 1].m_alloc || m_dm_pktq[m_dm_pktq.size() - 1].m_wr_required)  // Only if allocation happend we need to de-allocate
            //          m_dirm_mgr.update_model_for_deallocating_request(cohreq_pktq[cohreq_pktq.size() - 1].m_filter_num, {cohreq_pktq[cohreq_pktq.size() - 1].m_ns, cohreq_pktq[cohreq_pktq.size() - 1].m_addr}, lkprsp_pktq[0].m_way_vec_or_mask, m_dm_pktq[m_dm_pktq.size() - 1].m_predicted_eviction);
            //      
            //  end
            //end
        end
    end

    // For WR_STASH_PARTIAL DTW will always be there. Hence no need to release RBID.
    if(m_cmd_type == CMD_WR_STSH_PTL) predict_rbrreq = 0;

    //#Check.DCE.RBReq_Rls
    if (predict_rbrreq) begin
    //CONC-11806 Ncore3.6 No RB Release
    end 
    else begin
    foreach(m_drvsnp_rsp_pktq[i]) begin//for stash read if snarf is 0 clear the speculated rbr_req
        if(m_drvsnp_rsp_pktq[i].smi_cmstatus_err == 0)
                    snarf |= m_drvsnp_rsp_pktq[i].smi_cmstatus_snarf;
    end
        if(snarf==0 && dce_goldenref_model::is_stash_read(m_cmd_type)) begin// if snarf was not calculated re-calculate it for read stash
            if(snarf == 0) begin
                m_states["rbrreq"].clear_expect();
                m_states["rbrrsp"].clear_expect();
                m_states["rbureq"].clear_expect();
                m_states["rbursp"].clear_expect();
                m_states["rbrreq"].set_complete();
                // CLEANUP
                m_states["rbrrsp"].set_complete();
                m_states["rbureq"].set_complete();
                m_states["rbursp"].set_complete();
            end
        end
    end

    // CMT_REQ, MRD_REQ and STR_REQ predictions that follow only apply to CMD_REQ, hence return early if others.
    if (m_req_type != CMD_REQ) begin
        return;
    end

    foreach(m_drvsnp_rsp_pktq[i]) begin
    if(m_drvsnp_rsp_pktq[i].smi_cmstatus_err == 0) begin
            snarf |= m_drvsnp_rsp_pktq[i].smi_cmstatus_snarf;
            cmstatus |= m_drvsnp_rsp_pktq[i].smi_cmstatus;
    end
    end
    
    lkprsp_pktq = m_dm_pktq.find(item) with (item.m_access_type == DM_LKP_RSP);

    //#Check.DCE.StashReq.DMWrite
    // In case of ReadStash if (the target was owner and it gave SnpRsp IX) or (Target gave Snarf==1) , Commit Request needs to be predicted
    if((dce_goldenref_model::is_stash_read(m_cmd_type) == 0) || (lkprsp_pktq.size()>=1)) begin
        if(!dce_goldenref_model::is_stash_read(m_cmd_type) || snarf == 1 || (cmstatus==0 && (lkprsp_pktq[0].m_sharer_vec & (1<<m_sid_cacheid))) || (lkprsp_pktq[0].m_wr_required))
        predict_dm_cmt_req();
    end 

    if (dce_goldenref_model::is_stash_request(m_cmd_type)) begin
        if(lkprsp_pktq.size()>=1)
            //#Check.DCE.StashReq.MrdReq 
            predict_mrd_req_stash_ops();
    end else 
        predict_mrd_req();

    //**********************************
    //  STRreq prediction
    //**********************************
    //assign defaults first
    if (!dce_goldenref_model::is_read(m_cmd_type)) begin 
        exp_mpf1_dtr_tgt_id = 'h0;
        exp_mpf2_dtr_msg_id = 'h0;
    end else begin
        exp_mpf1_dtr_tgt_id = m_initcmdupd_req_pkt.smi_src_id >> WSMINCOREPORTID;
        exp_mpf2_dtr_msg_id = m_initcmdupd_req_pkt.smi_msg_id;
    end


    //Immediately predict STRreq for Read Stash requests once SNPrsp from Stash target is received (makes sense for 'valid target identified' scenarios)
    if (dce_goldenref_model::is_stash_read(m_cmd_type) == 1) begin 
          if (m_states["snprsp"].get_valid_count() == 1) begin
            predict_strreq = 1;
            snprsp_cmstatus_errq = m_drvsnp_rsp_pktq.find_index(item) with (item.smi_cmstatus_err == 1);
            snprsp_cmstatus_dtaiuq = m_drvsnp_rsp_pktq.find_index(item) with (item.smi_cmstatus_err == 0 && item.smi_cmstatus_dt_aiu == 1);
            snarf = m_drvsnp_rsp_pktq[0].smi_cmstatus_snarf & !m_drvsnp_rsp_pktq[0].smi_cmstatus_err;
          end 
    end else begin //for all ops other than read stash, predict STRreq after all SNPrsps are received.
          if (     (m_states["snpreq"].get_valid_count() == m_states["snprsp"].get_valid_count()) 
                &&  m_states["snpreq"].is_complete()
                &&  m_states["snprsp"].is_complete()) begin 
            predict_strreq = 1;
            snprsp_cmstatus_errq = m_drvsnp_rsp_pktq.find_index(item) with (item.smi_cmstatus_err == 1);
            snprsp_cmstatus_dtaiuq = m_drvsnp_rsp_pktq.find_index(item) with (item.smi_cmstatus_err == 0 && item.smi_cmstatus_dt_aiu == 1);
          end 
    end 

    if (dce_goldenref_model::is_stash_request(m_cmd_type)) begin
        exp_mpf1_dtr_tgt_id = m_initcmdupd_req_pkt.smi_mpf1_stash_nid;
        foreach(m_drvsnp_rsp_pktq[i]) begin
            if (m_drvsnp_rsp_pktq[i].smi_src_ncore_unit_id == m_initcmdupd_req_pkt.smi_mpf1_stash_nid && m_drvsnp_rsp_pktq[i].smi_cmstatus_snarf == 1 && !m_drvsnp_rsp_pktq[i].smi_cmstatus_err)
                exp_mpf2_dtr_msg_id = m_drvsnp_rsp_pktq[i].smi_mpf1_dtr_msg_id;
        end
    end 

    if (dce_goldenref_model::is_read(m_cmd_type)) begin
        foreach(m_drvsnp_rsp_pktq[i]) begin
            if (m_drvsnp_rsp_pktq[i].smi_cmstatus_dt_aiu == 1) begin
                exp_mpf2_dtr_msg_id = m_drvsnp_rsp_pktq[i].smi_mpf1_dtr_msg_id;
                break;
            end 
        end
    end

    cmtreq_pktq = m_dm_pktq.find(item) with (item.m_access_type == DM_CMT_REQ);

    //strreq is predicted at dm_lkp_rsp for lkprsp.m_error
    if ((predict_strreq == 1) && 
        (lkprsp_pktq[0].m_error != 1)) begin 
            m_states["strreq"].set_expect();
            m_expstr_req_pkt = new("strreq_pkt");
            m_expstr_req_pkt.t_smi_ndp_valid = 0;
    
            if (snprsp_cmstatus_errq.size() == 0 || snprsp_cmstatus_dtaiuq.size() > 0) begin 
                if (dce_goldenref_model::is_stash_request(m_cmd_type) == 0) begin 
                    if (m_iid_cacheid != -1) begin 
                        if (cmtreq_pktq.size() > 0) begin 
                            pkt = cmtreq_pktq[0];
                        end else begin 
                            pkt = lkprsp_pktq[0];
                        end 

                        if ((pkt.m_sharer_vec | (1 << m_iid_cacheid)) != pkt.m_sharer_vec) begin //requestor not valid 
                            exp_smi_cmstatus_state = 3'b000;
                        end else if ((pkt.m_owner_val == 1) && (pkt.m_owner_num == m_iid_cacheid)) begin //requestor is owner
                            if ($onehot(pkt.m_sharer_vec) == 1) //requestor is only valid as a owner - unique (UC or UD state)
                                exp_smi_cmstatus_state = 3'b100;
                            else //requestor is owner and there are other sharers in the system (SD state)
                                exp_smi_cmstatus_state = 3'b010;
                        end else begin //requestor is valid as sharer (SC state) 
                            exp_smi_cmstatus_state = 3'b011;
                        end 
                    end else begin 
                        exp_smi_cmstatus_state = 3'b000;
                    end
                end else begin //for stash request
                    foreach(m_drvsnp_rsp_pktq[i]) begin
                        if (m_drvsnp_rsp_pktq[i].smi_cmstatus_snarf == 1 && m_drvsnp_rsp_pktq[i].smi_cmstatus_err == 0)
                            exp_intfsize = m_drvsnp_rsp_pktq[i].smi_intfsize;
                    end
                    exp_smi_cmstatus_state = 3'b000;
                end 
            end else begin//only if snprsp.cmstatus has error
                exp_smi_cmstatus_err_payload = m_drvsnp_rsp_pktq[snprsp_cmstatus_errq[0]].smi_cmstatus_err_payload;
                foreach(m_drvsnp_rsp_pktq[i]) begin
                    if(m_drvsnp_rsp_pktq[i].smi_cmstatus_err == 0) begin
                        snarf |= m_drvsnp_rsp_pktq[i].smi_cmstatus_snarf;
                        dt_dmi |= m_drvsnp_rsp_pktq[i].smi_cmstatus_dt_dmi;
                    end
                    else begin
                        if(exp_smi_cmstatus_err_payload != 'b100) begin
                            if(m_drvsnp_rsp_pktq[i].smi_cmstatus_err_payload)
                                exp_smi_cmstatus_err_payload = m_drvsnp_rsp_pktq[i].smi_cmstatus_err_payload;
                        end
                    end
                end
                if(dt_dmi == 1) begin //Don't propagate error on STRReq because there is already one DTW/DTR Refer to CONC_8920
                    if(!(dce_goldenref_model::is_stash_write(m_cmd_type) || dce_goldenref_model::is_nonstash_write(m_cmd_type))) begin
                        exp_smi_cmstatus_err = 1;
                        exp_smi_cmstatus_err_payload = m_drvsnp_rsp_pktq[snprsp_cmstatus_errq[0]].smi_cmstatus_err_payload; 
                        exp_smi_cmstatus = {exp_smi_cmstatus_err, exp_smi_cmstatus_err_payload}; // Special case for rdunq
                    end
                end
                else if(dce_goldenref_model::is_stash_write(m_cmd_type) || dce_goldenref_model::is_nonstash_write(m_cmd_type)) begin
                /*  exp_smi_cmstatus_err = 1;
                    exp_smi_cmstatus_err_payload = m_drvsnp_rsp_pktq[snprsp_cmstatus_errq[0]].smi_cmstatus_err_payload;; 
                    exp_smi_cmstatus = {exp_smi_cmstatus_err, exp_smi_cmstatus_err_payload};*/ // Commenting this based on New error flow
                end
                else if(dce_goldenref_model::is_stash_read(m_cmd_type)) begin
                    foreach(m_drvsnp_rsp_pktq[i]) begin
                        if(m_drvsnp_rsp_pktq[i].smi_cmstatus_err == 0)
                            snarf |= m_drvsnp_rsp_pktq[i].smi_cmstatus_snarf;
                    end
                    if(snarf == 0) begin
                        exp_smi_cmstatus_err = 1;
                        exp_smi_cmstatus_err_payload = m_drvsnp_rsp_pktq[snprsp_cmstatus_errq[0]].smi_cmstatus_err_payload;; 
                        exp_smi_cmstatus = {exp_smi_cmstatus_err, exp_smi_cmstatus_err_payload};
                    end
                    else if(snarf == 1) begin
                        exp_smi_cmstatus_err = 1;
                        exp_smi_cmstatus_err_payload = m_drvsnp_rsp_pktq[snprsp_cmstatus_errq[0]].smi_cmstatus_err_payload;; 
                        exp_smi_cmstatus = {exp_smi_cmstatus_err, exp_smi_cmstatus_err_payload};
                    end
                end
                else begin
                    exp_smi_cmstatus_err = 1;
                    exp_smi_cmstatus_err_payload = m_drvsnp_rsp_pktq[snprsp_cmstatus_errq[0]].smi_cmstatus_err_payload;; 
                    exp_smi_cmstatus = {exp_smi_cmstatus_err, exp_smi_cmstatus_err_payload};
                end
            end 


            m_expstr_req_pkt.construct_strmsg(
                .smi_targ_ncore_unit_id (m_initcmdupd_req_pkt.smi_src_ncore_unit_id),
                .smi_src_ncore_unit_id  (m_initcmdupd_req_pkt.smi_targ_ncore_unit_id),
                .smi_msg_tier           ('h0),
                .smi_steer              ('h0),
                .smi_msg_qos            ('h0),
                .smi_msg_pri            (m_initcmdupd_req_pkt.smi_msg_pri),
                .smi_msg_type           (STR_STATE),
                .smi_msg_id             (m_attid),
                .smi_msg_err            ('h0),
                .smi_cmstatus           (exp_smi_cmstatus),
                .smi_cmstatus_so        ('h0),
                .smi_cmstatus_ss        ('h0),
                .smi_cmstatus_sd        ('h0),
                .smi_cmstatus_st        ('h0),
                .smi_cmstatus_state     (dce_goldenref_model::is_stash_request(m_cmd_type) ? 0 : exp_smi_cmstatus_state),
                .smi_cmstatus_snarf     (dce_goldenref_model::is_stash_request(m_cmd_type) ? snarf : 0),
                .smi_cmstatus_exok      ((ex_store || ex_load) ? ((m_exmon_status == EXMON_PASS) ? 1'b1 : 1'b0) : 'h0),
                .smi_rbid               ('h0),
                .smi_tm                 (m_initcmdupd_req_pkt.smi_tm),
                .smi_rmsg_id            (m_initcmdupd_req_pkt.smi_msg_id),
                .smi_mpf1               (exp_mpf1_dtr_tgt_id),//#Check.DCE.StrReq_MPF1
                .smi_mpf2               (exp_mpf2_dtr_msg_id),//#Check.DCE.StrReq_MPF2
                .smi_intfsize           ((dce_goldenref_model::is_stash_request(m_cmd_type) && (snarf == 1)) ? exp_intfsize : 0) //#Check.DCE.StrReq_IntfSize 
            );
    end 
    
    //sample DM coverage data.
    <% if(obj.COVER_ON) { %>
    //stash
    if (dce_goldenref_model::is_stash_request(m_cmd_type)) begin
        if(m_initcmdupd_req_pkt.smi_mpf1_stash_valid &&
           (m_initcmdupd_req_pkt.smi_mpf1_stash_nid inside {addrMgrConst::stash_nids,addrMgrConst::stash_nids_ace_aius}) &&
           (addrMgrConst::is_stash_enable(addrMgrConst::agentid_assoc2funitid(m_initcmdupd_req_pkt.smi_mpf1_stash_nid))) &&
           (seq_item.smi_src_ncore_unit_id == m_initcmdupd_req_pkt.smi_mpf1_stash_nid))
           stash_target = 1;
        else
           stash_target = 0;
         
        m_cov.collect_snprsp(m_cmd_type, addrMgrConst::get_native_interface(snooper_agentid), stash_target, 0, seq_item.smi_cmstatus);
    end

    //non-stash
    if (dce_goldenref_model::cmdreq2owner_snp.exists(m_cmd_type) 
        && lkprsp_pktq[0].m_owner_val 
        && (lkprsp_pktq[0].m_owner_num == addrMgrConst::get_cache_id(seq_item.smi_src_ncore_unit_id)))
        m_cov.collect_snprsp(m_cmd_type, addrMgrConst::get_native_interface(snooper_agentid), 0, 1, seq_item.smi_cmstatus);

    if (dce_goldenref_model::cmdreq2sharer_snp.exists(m_cmd_type) 
        && (!lkprsp_pktq[0].m_owner_val || (lkprsp_pktq[0].m_owner_num != addrMgrConst::get_cache_id(seq_item.smi_src_ncore_unit_id))))
        m_cov.collect_snprsp(m_cmd_type, addrMgrConst::get_native_interface(snooper_agentid), 0, 0, seq_item.smi_cmstatus);
    <% } %>
endfunction: save_snprsp

//***************************************************************************
function void dce_scb_txn::save_strrsp(const ref smi_seq_item seq_item);
    m_drvstr_rsp_pkt.copy(seq_item);
    m_drvstr_rsp_pkt.t_smi_ndp_valid = $time;
endfunction: save_strrsp

//***************************************************************************
function void dce_scb_txn::save_mrdrsp(const ref smi_seq_item seq_item);
    smi_seq_item temp;
    bit [2:0] exp_smi_cmstatus_state;
    bit [WSMICMSTATUS-1:0] exp_smi_cmstatus;
    bit [WSMICMSTATUSERR-1:0] exp_smi_cmstatus_err;
    bit [WSMICMSTATUSERRPAYLOAD-1:0] exp_smi_cmstatus_err_payload;
    $cast(temp, seq_item.clone());
    if(m_cmd_type inside {CMD_CLN_SH_PER, CMD_CLN_VLD, CMD_CLN_INV}) begin
        if ((temp.smi_cmstatus_err == 1)
        && ((temp.smi_cmstatus_err_payload == 'b100) //address error 
        || (temp.smi_cmstatus_err_payload == 'b011)) //data error 
        ) begin

        if(m_states["strreq"].is_expect) begin
            m_states["strreq"].clear_one_expect();
            m_expstr_req_pkt = null;
        end
        //`uvm_info("DCE_SCB_DBG", $psprintf("In MRDrsp save dce_scb_txn function predicting STR Req"), UVM_LOW)
        m_states["strreq"].set_expect();
        m_expstr_req_pkt = new("strreq_pkt");
        m_expstr_req_pkt.t_smi_ndp_valid = 0;
        exp_smi_cmstatus_err = 1;
        exp_smi_cmstatus_err_payload = temp.smi_cmstatus_err_payload; 
        exp_smi_cmstatus = {exp_smi_cmstatus_err, exp_smi_cmstatus_err_payload};
        exp_smi_cmstatus_state = 3'b000;
        m_expstr_req_pkt.construct_strmsg(
            .smi_targ_ncore_unit_id (m_initcmdupd_req_pkt.smi_src_ncore_unit_id),
            .smi_src_ncore_unit_id  (m_initcmdupd_req_pkt.smi_targ_ncore_unit_id),
            .smi_msg_type           (STR_STATE),
            .smi_msg_id             (m_attid),//#Check.DCE.StrReq_MsgId 
            .smi_msg_tier           ('h0),
            .smi_steer              ('h0),
            .smi_msg_pri            (m_initcmdupd_req_pkt.smi_msg_pri),
            .smi_msg_qos            ('h0),
            .smi_msg_err            ('h0),
            .smi_tm                 (m_initcmdupd_req_pkt.smi_tm),
            .smi_rmsg_id            (m_initcmdupd_req_pkt.smi_msg_id),
            .smi_cmstatus           (exp_smi_cmstatus),
            .smi_cmstatus_so        ('h0),
            .smi_cmstatus_ss        ('h0),
            .smi_cmstatus_sd        ('h0),
            .smi_cmstatus_st        ('h0),
            .smi_cmstatus_state     (exp_smi_cmstatus_state),
            .smi_cmstatus_snarf     ('h0),
            .smi_cmstatus_exok      ((ex_store || ex_load) ? ((m_exmon_status == EXMON_PASS) ? 1'b1 : 1'b0) : 'h0),
            .smi_rbid               ('h0),
            .smi_mpf1               (m_initcmdupd_req_pkt.smi_mpf1_stash_nid), //dont care but need to match RTL to predict ndp_prot bits correctly
            .smi_mpf2               ('h0),
            .smi_intfsize           (m_initcmdupd_req_pkt.smi_intfsize)
        );
        
             
        end
        else if(!m_states["strreq"].is_expect) begin
            predict_str_req();
        end
    end
    m_drvmrd_rsp_pkt.copy(seq_item);
    m_drvmrd_rsp_pkt.t_smi_ndp_valid = $time;
endfunction: save_mrdrsp

//***************************************************************************
function void dce_scb_txn::save_rbrrsp(const ref smi_seq_item seq_item);
    smi_seq_item drvrbr_rsp_pkt;

    m_drvrbr_rsp_pktq.delete(); 
   
    drvrbr_rsp_pkt = new("rbr_rsp");
    drvrbr_rsp_pkt.copy(seq_item);
    drvrbr_rsp_pkt.t_smi_ndp_valid = $time;

    m_drvrbr_rsp_pktq.push_back(drvrbr_rsp_pkt);
endfunction: save_rbrrsp

//***************************************************************************
function void dce_scb_txn::save_rbureq(const ref smi_seq_item seq_item);

    if (m_drvrbu_req_pkt == null) begin
        `uvm_error("DCE SCB", "RBUREQ pkt should not be null")
    end
    
    m_drvrbu_req_pkt.smi_msg_id = seq_item.smi_msg_id;
    
    m_drvrbu_req_pkt.compare(seq_item);
    m_drvrbu_req_pkt.copy(seq_item);
    m_drvrbu_req_pkt.t_smi_ndp_valid = $time;
    
    //create expected rbu_rsp_pkt 
    //#Check.DCE.RBURsp
    m_states["rbursp"].set_expect();
    m_exprbu_rsp_pkt = new("rbu_rsp");
    m_exprbu_rsp_pkt.t_smi_ndp_valid = 0;

    m_exprbu_rsp_pkt.construct_rbusersp(
        .smi_targ_ncore_unit_id (seq_item.smi_src_ncore_unit_id),
        .smi_src_ncore_unit_id  (addrMgrConst::get_dce_funitid(<%=obj.Id%>)),
        .smi_msg_type           (RB_USE_RSP),
        .smi_msg_tier           ('h0),
        .smi_steer              ('h0),
        .smi_msg_qos            ('h0),
        .smi_msg_pri            (seq_item.smi_msg_pri),
        .smi_msg_id             ('h0),
        .smi_msg_err            ('h0),
        .smi_cmstatus           ('h0),
        .smi_tm                 (seq_item.smi_tm),
        .smi_rmsg_id            (seq_item.smi_msg_id)
    );
endfunction: save_rbureq

//***************************************************************************
function void dce_scb_txn::check_rbu_rsp(const ref smi_seq_item seq_item);
    
    m_exprbu_rsp_pkt.compare(seq_item);
    m_exprbu_rsp_pkt.copy(seq_item);
    m_exprbu_rsp_pkt.t_smi_ndp_valid = $time;
endfunction: check_rbu_rsp

//***************************************************************************
function bit dce_scb_txn::requestor_dirlkp_state_is_SC(const ref dm_seq_item lkprsp);
                                
    if (    ((lkprsp.m_sharer_vec | (1 << m_iid_cacheid)) == lkprsp.m_sharer_vec) 
         && (!lkprsp.m_owner_val || (lkprsp.m_owner_num != m_iid_cacheid))
         && (m_iid_cacheid != -1)) 
        return 1;
    else 
        return 0;

endfunction: requestor_dirlkp_state_is_SC

//***************************************************************************
function bit dce_scb_txn::requestor_dirlkp_state_is_valid(const ref dm_seq_item lkprsp);
                                
    if (m_iid_cacheid == -1) begin
        return 0;
    end else if ((lkprsp.m_sharer_vec | (1 << m_iid_cacheid)) == lkprsp.m_sharer_vec) 
        return 1;
    else 
        return 0;

endfunction: requestor_dirlkp_state_is_valid

//***************************************************************************
function bit dce_scb_txn::is_exclusive_operation(output bit ex_load, output bit ex_store);
    // evaluating excl load
    ex_load  = m_initcmdupd_req_pkt.smi_es == 1 &&
               m_cmd_type inside {CMD_RD_VLD, 
                                  CMD_RD_CLN, 
                                  CMD_RD_NOT_SHD};

    // evaluating excl store
    ex_store = m_initcmdupd_req_pkt.smi_es == 1 &&
               m_cmd_type == CMD_CLN_UNQ;

    // CONC-12328 - Exmon update for non-exclusive transaction that can generate
    // snoop invalidate command, in which case, matching tagged monitor and basic monitor
    // has to be cleared
    // CONC-12556
    // Undoing the earlier update as Arch team has suggested a cleaner fix for the issue that caused this problem
    return(ex_load | ex_store);
endfunction: is_exclusive_operation

//***************************************************************************
function void dce_scb_txn::save_attid_for_rd_stash_ops(const ref dm_seq_item item);
    int idxq[$];
    if (item.m_access_type == DM_CMD_REQ) begin
        // Add attid as smi_msg_id for expected Snoop request to Target in case of LdCchUnq(StashOnceUnique)
        if(dce_goldenref_model::is_stash_read(m_cmd_type)) begin
            // Search for the Expected SnpReq, created at the time of save_cmdupd_req

            idxq = this.m_expsnp_req_pktq.find_index(snp_req_item) with ((snp_req_item.smi_addr == item.m_addr) && (snp_req_item.smi_ns == item.m_ns));
            if(idxq.size()==1) begin
                m_expsnp_req_pktq[idxq[0]].smi_msg_id = item.m_attid;
            end
        end
    end 
endfunction: save_attid_for_rd_stash_ops

//***************************************************************************
function bit dce_scb_txn::get_aggregated_snprsp_cmstatus();
    if ((m_states["snpreq"].get_valid_count() == m_states["snprsp"].get_valid_count()) 
              &&   m_states["snpreq"].is_complete()
              &&   m_states["snprsp"].is_complete()) begin
        foreach(m_drvsnp_rsp_pktq[i]) begin
            agg_snprsp_cmstatus |= m_drvsnp_rsp_pktq[i].smi_cmstatus;
        end
        return 1;
    end
    else
        return 0;

endfunction: get_aggregated_snprsp_cmstatus
//***************************************************************************
function void dce_scb_txn::predict_sys_evt_req();
    smi_seq_item sys_evt_req;

    sys_evt_req = new("sys_evt_req");
    m_states["sysreq"].set_expect();
    //#Check.DCE.v36.SysEvent
    sys_evt_req.construct_sysmsg(
            .smi_targ_ncore_unit_id (addrMgrConst::get_dve_funitid(0)), //#Check.DCE.v36.SysEventTgtId
            .smi_src_ncore_unit_id  (addrMgrConst::get_dce_funitid(<%=obj.Id%>)),
            .smi_msg_type           (SYS_REQ),
            .smi_msg_id             (0),
            .smi_msg_tier           (0),
            .smi_steer              (0),
            .smi_msg_pri            (0),
            .smi_msg_qos            (0),
            .smi_rmsg_id            (0),
            .smi_msg_err            (0),
            .smi_cmstatus           (0),
            .smi_sysreq_op          (3),
            .smi_ndp_aux            (0)
        );
    m_expsys_event_req_pktq_<%=obj.BlockId%>.push_back(sys_evt_req);
endfunction:predict_sys_evt_req

//***************************************************************************
function void dce_scb_txn::repredict_sys_evt_req();

    smi_seq_item sys_evt_req;
    m_states["sysreq"].clear_expect();
    sys_evt_req = new("sys_evt_req");
    m_states["sysreq"].set_expect();
    sys_evt_req.construct_sysmsg(
            .smi_targ_ncore_unit_id (addrMgrConst::get_dve_funitid(0)),
            .smi_src_ncore_unit_id  (addrMgrConst::get_dce_funitid(<%=obj.Id%>)),
            .smi_msg_type           (SYS_REQ),
            .smi_msg_id             (0),
            .smi_msg_tier           (0),
            .smi_steer              (0),
            .smi_msg_pri            (0),
            .smi_msg_qos            (0),
            .smi_rmsg_id            (0),
            .smi_msg_err            (0),
            .smi_cmstatus           (0),
            .smi_sysreq_op          (3),
            .smi_ndp_aux            (0)
            );
    m_expsys_event_req_pktq_<%=obj.BlockId%>.push_back(sys_evt_req);
endfunction:repredict_sys_evt_req
//***************************************************************************
function void dce_scb_txn::check_sys_event_req(const ref smi_seq_item seq_item);
    int idxq[$];

    idxq = m_expsys_event_req_pktq_<%=obj.BlockId%>.find_index(item) with (item.smi_targ_ncore_unit_id == seq_item.smi_targ_ncore_unit_id && !m_states["sysreq"].is_complete());
    if(idxq.size() == 0) begin
        predict_sys_evt_req();   
        idxq = m_expsys_event_req_pktq_<%=obj.BlockId%>.find_index(item) with (item.smi_targ_ncore_unit_id == seq_item.smi_targ_ncore_unit_id && !m_states["sysreq"].is_complete());
        m_expsys_event_req_pktq_<%=obj.BlockId%>[idxq[0]].compare(seq_item);
    end
    else if(idxq.size() == 1) begin
            m_expsys_event_req_pktq_<%=obj.BlockId%>[idxq[0]].compare(seq_item);
    end
    else
        `uvm_error("DCE_SCB",$psprintf("wrong with prediction"))
        m_states["sysreq"].set_valid($time);
        m_states["sysrsp"].set_expect();
endfunction: check_sys_event_req

//***************************************************************************
function void dce_scb_txn::process_sys_event_rsp(const ref smi_seq_item seq_item);
    int idxq[$];
    
    if($test$plusargs("en_dce_ev_protocol_timeout")) begin
        if(m_expsys_event_req_pktq_<%=obj.BlockId%>.size() == 0)
            return;
    end 

    idxq = m_expsys_event_req_pktq_<%=obj.BlockId%>.find_index(item) with (item.smi_targ_ncore_unit_id == seq_item.smi_src_ncore_unit_id && !m_states["sysrsp"].is_complete());
    if(idxq.size() == 0) begin
        `uvm_error("DCE_SCB",$psprintf("sys_req was not generated for the sys_rsp"))
    end
    else if(idxq.size() == 1) begin
        m_expsys_event_req_pktq_<%=obj.BlockId%>.delete(idxq[0]);
    end
    else
        `uvm_error("DCE_SCB",$psprintf("wrong with prediction"))
        m_states["sysrsp"].set_valid($time);
endfunction: process_sys_event_rsp
    
//***************************************************************************
function void dce_scb_txn::save_sys_co_req(const ref smi_seq_item seq_item);
    m_initcmdupd_req_pkt = new("dummy");
    m_req_type     = SYSCO_REQ; 
    m_attid_status = ATTID_IS_INACTIVE;
    m_rbid_status  = RBID_UNRESERVED;
    m_attid        = -1;
    void'($cast(m_initsys_co_req_pkt, seq_item.clone()));

    m_states["cmdupdrsp"].set_complete();
    m_states["sb_cmdrsp"].set_complete();
    
    m_states["dirreq"].set_complete();
    m_states["dirrsp"].set_complete();
    
    m_states["strreq"].set_complete();
    m_states["strrsp"].set_complete();
    
    m_states["mrdreq"].set_complete();
    m_states["mrdrsp"].set_complete();
    
    m_states["snpreq"].set_complete();
    m_states["snprsp"].set_complete();
    
    m_states["rbrreq"].set_complete();
    // CLEANUP
    m_states["rbrrsp"].set_complete();
    m_states["rbureq"].set_complete();
    m_states["rbursp"].set_complete();
    m_states["dirreq"].set_complete();
    m_states["dirrsp"].set_complete();

    check_sys_co_req(m_initsys_co_req_pkt);
    m_initsys_co_req_pkt.t_smi_ndp_valid = $time;
    m_states["sysreq"].set_valid($time);
    m_states["sysrsp"].set_expect();
    m_states["sb_sysrsp"].set_expect();
    m_expsys_co_rsp_pkt = new("sysrsp");
    m_expsys_co_rsp_pkt.t_smi_ndp_valid = 0;
    m_expsys_co_rsp_pkt.construct_sysrsp(
        .smi_targ_ncore_unit_id (m_initsys_co_req_pkt.smi_src_ncore_unit_id),
        .smi_src_ncore_unit_id  (m_initsys_co_req_pkt.smi_targ_ncore_unit_id),
        .smi_msg_type           (SYS_RSP),
        .smi_msg_id             (0),
        .smi_msg_tier           (0),
        .smi_steer              (0),
        .smi_msg_pri            (0),
        .smi_msg_qos            (0),
        .smi_tm                 (0),
        .smi_rmsg_id            (m_initsys_co_req_pkt.smi_msg_id),
        .smi_msg_err            (0),
        .smi_cmstatus           (0),
        .smi_ndp_aux            (0)
    );

endfunction: save_sys_co_req
//***************************************************************************
function void dce_scb_txn::check_sys_co_req(const ref smi_seq_item seq_item);
    int idxq[$];

endfunction: check_sys_co_req
//***************************************************************************
function void dce_scb_txn::check_sys_co_rsp(const ref smi_seq_item seq_item);

    //`uvm_info("DBG", $psprintf("src_id:%0d unit_id:%0d port_id:%0d", m_expcmdupd_rsp_pkt.smi_src_id, m_expcmdupd_rsp_pkt.smi_src_ncore_unit_id, m_expcmdupd_rsp_pkt.smi_src_ncore_port_id), UVM_NONE)
    m_expsys_co_rsp_pkt.smi_cmstatus = seq_item.smi_cmstatus;

    m_expsys_co_rsp_pkt.compare(seq_item);
    m_expsys_co_rsp_pkt.copy(seq_item);
    m_expsys_co_rsp_pkt.t_smi_ndp_valid = $time;

endfunction: check_sys_co_rsp
//***************************************************************************
function void dce_scb_txn::predict_rb_rsp();
    smi_seq_item drvrbr_rsp_pkt;

    m_states["rbrrsp"].set_expect();    
    drvrbr_rsp_pkt = new("rbr_rsp");
    drvrbr_rsp_pkt.t_smi_ndp_valid = 0;
    
    drvrbr_rsp_pkt.construct_rbrsp(
        .smi_targ_ncore_unit_id (addrMgrConst::get_dce_funitid(<%=obj.Id%>)),
        .smi_src_ncore_unit_id  (m_exprbr_req_pktq[0].smi_targ_ncore_unit_id),
        .smi_msg_tier           ('h0),
        .smi_steer              ('h0),
        .smi_msg_qos            ('h0),
        .smi_msg_pri            (m_exprbr_req_pktq[0].smi_msg_pri),
        .smi_msg_type           ('h0),
        .smi_msg_id             ('h0),
        .smi_cmstatus           ('h0),
        .smi_tm                 (m_exprbr_req_pktq[0].smi_tm),
        .smi_rbid               (m_exprbr_req_pktq[0].smi_rmsg_id)
    );
    m_drvrbr_rsp_pktq.push_back(drvrbr_rsp_pkt);
endfunction: predict_rb_rsp
//***************************************************************************
function void dce_scb_txn::predict_rb_rsv_rls_req();

//This function predicts RB Reserve and RB release as this function is called when no snoops are predicted 

    smi_seq_item rbr_req_pkt;

    m_states["rbrreq"].set_expect();
        rbr_req_pkt = new("rbr_req");
        rbr_req_pkt.construct_rbmsg(
            .smi_targ_ncore_unit_id (m_dmiid),
            .smi_src_ncore_unit_id  (addrMgrConst::get_dce_funitid(<%=obj.Id%>)),
            .smi_msg_tier           ('h0),
            .smi_steer              ('h0),
            .smi_msg_qos            ('h0),
            .smi_msg_pri            (m_initcmdupd_req_pkt.smi_msg_pri),
            .smi_msg_type           (RB_REQ),
            .smi_msg_id             (m_attid),
            .smi_msg_err            (m_initcmdupd_req_pkt.smi_msg_err),
            .smi_cmstatus           ('h0),
            .smi_rbid               ('h0),
            .smi_tm                 (m_initcmdupd_req_pkt.smi_tm),
            .smi_rtype              ('h1),
            .smi_addr               (m_initcmdupd_req_pkt.smi_addr),
            .smi_size               (m_initcmdupd_req_pkt.smi_size),
            .smi_tof                (m_initcmdupd_req_pkt.smi_tof),
            .smi_mpf1               (m_initcmdupd_req_pkt.smi_mpf2),
            .smi_vz                 (m_initcmdupd_req_pkt.smi_vz),
            .smi_ac                 (m_initcmdupd_req_pkt.smi_ac),
            .smi_ca                 (m_initcmdupd_req_pkt.smi_ca),
            .smi_ns                 (m_initcmdupd_req_pkt.smi_ns),
            .smi_pr                 (m_initcmdupd_req_pkt.smi_pr),
            .smi_mw                 ((m_cmd_type inside {CMD_WR_UNQ_PTL}) ? 'h1 : 'h0),
            .smi_rl                 ('b10),
            .smi_qos                (m_initcmdupd_req_pkt.smi_qos),
            .smi_ndp_aux            (m_initcmdupd_req_pkt.smi_ndp_aux) // CONC-13177, CONC-13223
        );
        m_exprbr_req_pktq.push_back(rbr_req_pkt);

endfunction: predict_rb_rsv_rls_req
    
//***************************************************************************
function void dce_scb_txn::repredict_snp_mrd_reqs(); //Adding this function for Sysco repredicting when Snoopenables change
    //Snps - repredicting snoops and RBs first

        //`uvm_info("DCE_FSYS_DBG",$psprintf("Snoop enable in repredict = %x",snoop_enable_reg_txn),UVM_LOW)
        //`uvm_info("DCE_FSYS_DBG",$psprintf("snp complete = %d and valid count = %d and is_valid = %d, get_expect = %d and expect_count = %d and snoop_exp size() = %d",m_states["snpreq"].is_complete(),m_states["snpreq"].get_valid_count(),m_states["snpreq"].is_valid(),m_states["snpreq"].is_expect,m_states["snpreq"].get_expect_count(),m_expsnp_req_pktq.size()),UVM_LOW)
        if(m_expsnp_req_pktq.size() == 0) begin
            if (dce_goldenref_model::is_stash_read(m_cmd_type)) begin
                predict_snp_req_rd_stash_ops();
            end

            if (dce_goldenref_model::is_stash_request(m_cmd_type))
                predict_rbr_snp_req_stash_ops();
            else 
                predict_rbr_snp_req();
        end
        else begin
            foreach(m_expsnp_req_pktq[x]) begin
                if($isunknown(m_expsnp_req_pktq[x].t_smi_ndp_valid) || m_expsnp_req_pktq[x].t_smi_ndp_valid == 0) begin
                    if(snoop_enable_reg_txn[m_expsnp_req_pktq[x].smi_targ_ncore_unit_id] == 0) begin
                        m_expsnp_req_pktq.delete(x);
                        m_states["snpreq"].clear_one_expect();
                    end
                end     
            end
        end
        //`uvm_info("DCE_FSYS_DBG",$psprintf("snp complete = %d and valid count = %d and is_valid = %d, get_expect = %d and expect_count = %d",m_states["snpreq"].is_complete(),m_states["snpreq"].get_valid_count(),m_states["snpreq"].is_valid(),m_states["snpreq"].is_expect,m_states["snpreq"].get_expect_count()),UVM_LOW)
        
    //Done repredicting snoops
    //Mrds - repredicting Mrds
        if (dce_goldenref_model::is_stash_read(m_cmd_type))
                    predict_mrd_req_stash_ops();
            else
                    predict_mrd_req();
    //Done repredicting mrds
    //DM_CMT - Repredicting dm cmt reqs
        foreach(m_dm_pktq[x]) begin
            if(m_dm_pktq[x].m_access_type == DM_CMT_REQ) begin
                m_dm_pktq.delete(x);
                m_states["dirreq"].clear_one_expect();
            end
        end
        predict_dm_cmt_req();

    //Done dm_cmt repredicting
        
endfunction: repredict_snp_mrd_reqs
//**************************************************************************

function void dce_scb_txn::predict_zero_mrd_credits();

    if(m_dm_pktq[m_dm_pktq.size()-1].m_access_type == DM_CMT_REQ) begin
        m_dm_pktq.delete(m_dm_pktq.size()-1);
        m_states["dirreq"].clear_one_expect();
    end

endfunction: predict_zero_mrd_credits

    
