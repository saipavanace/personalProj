<%  
var ace_present = 0;
var chi_a_present = 0;
var chi_b_present = 0;
var axi_present = 0;
var acelite_present = 0;
var acelite_e_present = 0;
var iocache_present = 0;
var caching_agents = 0;
var filter_secded = 0;
var filter_parity = 0;

obj.AiuInfo.forEach(function(bundle, idx, array) {
    if (bundle.fnNativeInterface === "ACE") {
        ace_present++;
    }
    if (bundle.fnNativeInterface === "CHI-A") {
        chi_a_present++;
    }   
    if (bundle.fnNativeInterface === "CHI-B") {
        chi_b_present++;
    }
    if ((bundle.fnNativeInterface === "AXI4") && (bundle.useCache == 1)) {
        iocache_present++;
    }
    if ((bundle.fnNativeInterface === "AXI4") && (bundle.useCache == 0)) {
        axi_present++;
    }
    if (bundle.fnNativeInterface === "ACE-LITE") {
        acelite_present++;
    }
    if (bundle.fnNativeInterface === "ACELITE-E") {
        acelite_e_present++;
    }
})
caching_agents = ace_present + chi_a_present + chi_b_present + iocache_present;

obj.SnoopFilterInfo.forEach(function sfways(item,index){
    if(item.TagFilterErrorInfo.fnErrDetectCorrect === "SECDED") {
        filter_secded = 1;
    }
});
obj.SnoopFilterInfo.forEach(function sfways(item,index){
    if(item.TagFilterErrorInfo.fnErrDetectCorrect === "PARITY") {
        filter_parity = 1;
    }
});
%>

class dce_coverage;

    eMsgCMD       exld_cmd_type;
    smi_seq_item  cmdreq;
    smi_seq_item  mrdreq;
    smi_seq_item  snpreq;
    exmon_state_e exmon_state;
    bit           set_flag;
    int           attid;
    bit[1:0]      flag;
    bit[1:0]      non_alloc_flag;

    <% if (obj.DceInfo[obj.Id].CMDOverflowBufInSRAM == true) { %>
    //skidbuf coverage
    bit [3:0] sram_enabled; 
    bit skidbuf_int_bit;
    bit skidbuf_err_det_bit;
    bit type_of_error;
    <% } %>

    // Events Coverage related variables
    enum {
           dm_miss,
           dm_hit_as_owner_and_other_sharers_absent,
           dm_hit_as_owner_and_other_sharers_present,
           dm_hit_as_sharer_and_owner_absent_other_sharers_absent,
           dm_hit_as_sharer_and_owner_absent_other_sharers_present,
           dm_hit_as_sharer_and_owner_present_other_sharers_absent,
           dm_hit_as_sharer_and_owner_present_other_sharers_present,
           dm_hit_as_neither_and_owner_absent_other_sharers_present,
           dm_hit_as_neither_and_owner_present_other_sharers_absent,
           dm_hit_as_neither_and_owner_present_other_sharers_present
         } dm_state_on_lkp_e;

    enum {
           dm_miss_stash=1,
           dm_hit_trgt_as_neither_and_owner_present_other_sharers_absent,
           dm_hit_trgt_as_neither_and_owner_absent_other_sharers_present,
           dm_hit_trgt_as_neither_and_owner_present_other_sharers_present,
           dm_hit_trgt_as_owner_and_other_sharers_absent,
           dm_hit_trgt_as_sharer_and_owner_absent_other_sharers_absent,
           dm_hit_trgt_as_sharer_and_owner_absent_other_sharers_present,
           dm_hit_trgt_as_sharer_and_owner_present_other_sharers_absent,
           dm_hit_trgt_as_sharer_and_owner_present_other_sharers_present,
           dm_hit_trgt_as_owner_and_other_sharers_present
         } dm_state_on_lkp_stash;


    enum {
        owner_attached,
        owner_detached,
        sharer_attached,
        sharer_detached
    } owner_sharer_attach_detached;
    
    typedef struct {
        bit [1:0] op;
        int agent_id;
        time smi_sys_time;  
    } sysco_req_t;

    typedef struct {
        bit [$clog2(addrMgrConst::NUM_SF)-1:0]  sf_num;
        bit [WSMIADDR-1:0]  cmd_addr;
        bit [WSFSETIDX-1:0] set_index;
        bit                 vb_hit;
        bit                 tag_hit;
        bit                 miss;
        longint             cmd_time;
    } alloc_collect_struct_t;
    
    typedef struct {
        bit [WSMIADDR-1:0]  address;
        bit [2:0]       type_msg; //100 : cmd, 010 : upd, 001 : dm_write
        longint         rcvd_time;
    } cmd_upd_cmt_collect_struct_t;

    enum {
        back_back_allocating_requests_same_SF_same_setaddr_different_tagaddr,
        back_back_allocating_requests_same_SF_same_setaddr_all_tag_hits,
        back_back_allocating_requests_same_SF_same_setaddr_all_vb_hits,
        back_back_allocating_requests_same_SF_same_setaddr_all_misses
    } back_back_alloc_state;

    enum {
        back_back_non_allocating_requests_same_SF_same_setaddr_different_tagaddr,
        back_back_non_allocating_requests_same_SF_same_setaddr_all_tag_hits,
        back_back_non_allocating_requests_same_SF_same_setaddr_all_vb_hits,
        back_back_non_allocating_requests_same_SF_same_setaddr_all_misses
    } back_back_non_alloc_state;

    enum {
        snpreq_snprsp_rbrsv,
        snpreq_rbrsv_snprsp,
        rbrsv_snpreq_snprsp
    } timing_order;
    
    enum {
        cmd_upd_same_cycle,
        cmd_upd_one_cycle,
        cmd_upd_two_cycle,
        cmd_upd_three_cycle,
        cmd_upd_four_cycle
    } cmd_upd_order;
    enum {
        upd_cmt_same_cycle,
        upd_before_cmt_one_cycle,
        upd_after_cmt_one_cycle
    } upd_cmt_order;

    alloc_collect_struct_t btb_allocs[3];
    alloc_collect_struct_t btb_nonallocs[3];
    alloc_collect_struct_t empty_struct;

    cmd_upd_cmt_collect_struct_t back_collect_reqs[2];
    sysco_req_t sysco_reqq[$];

    covergroup cg_dm_lkprsp with function sample(bit alloc, addrMgrConst::interface_t inf);
        
        //#Cover.DCE.DM.CmdReqType
        cp_cmd_type: coverpoint cmdreq.smi_msg_type {
            bins CMD_RD_CLN          = {8'b00000001};  //0x01
            bins CMD_RD_NOT_SHD      = {8'b00000010};  //0x02
            bins CMD_RD_VLD          = {8'b00000011};  //0x03
            bins CMD_RD_UNQ          = {8'b00000100};  //0x04
            bins CMD_CLN_UNQ         = {8'b00000101};  //0x05
            bins CMD_MK_UNQ          = {8'b00000110};  //0x06
            bins CMD_RD_NITC         = {8'b00000111};  //0x07
            bins CMD_CLN_VLD         = {8'b00001000};  //0x08
            bins CMD_CLN_INV         = {8'b00001001};  //0x09
            bins CMD_MK_INV          = {8'b00001010};  //0x0A
            bins CMD_WR_UNQ_PTL      = {8'b00010000};  //0x10
            bins CMD_WR_UNQ_FULL     = {8'b00010001};  //0x11
            bins CMD_WR_ATM          = {8'b00010010};  //0x12
            bins CMD_RD_ATM          = {8'b00010011};  //0x13
            bins CMD_WR_BK_FULL      = {8'b00010100};  //0x14
            <% if (chi_b_present !=0) { %>
            bins CMD_WR_CLN_FULL     = {8'b00010101};  //0x15
            <%} %>
            bins CMD_WR_EVICT        = {8'b00010110};  //0x16
            bins CMD_EVICT           = {8'b00010111};  //0x17
            bins CMD_WR_BK_PTL       = {8'b00011000};  //0x18
            <% if (chi_a_present !=0) { %>
            bins CMD_WR_CLN_PTL      = {8'b00011001};  //0x19
            <%}
            if (acelite_e_present!=0) { %>
            bins CMD_WR_STSH_FULL    = {8'b00100010};  //0x22
            bins CMD_WR_STSH_PTL     = {8'b00100011};  //0x23
            <%}
            if (chi_b_present !=0 || acelite_e_present !=0) { %>
            bins CMD_LD_CCH_SH       = {8'b00100100};  //0x24
            bins CMD_LD_CCH_UNQ      = {8'b00100101};  //0x25
            <%}%>
            bins CMD_RD_NITC_CLN_INV = {8'b00100110};  //0x26
            bins CMD_RD_NITC_MK_INV  = {8'b00100111};  //0x27
            bins CMD_CLN_SH_PER      = {8'b00101000};  //0x28
            bins CMD_SW_ATM          = {8'b00101001};  //0x29
            bins CMD_CMP_ATM         = {8'b00101010};  //0x2A
        }
        
        cp_iid_type: coverpoint inf {
            <%  if(ace_present != 0) { %>
            bins ACE_AIU = {addrMgrConst::ACE_AIU};
            <%  }
            if(chi_a_present != 0) { %>
            bins CHI_A_AIU = {addrMgrConst::CHI_A_AIU};
            <%  } 
            if(chi_b_present != 0) { %>
            bins CHI_B_AIU = {addrMgrConst::CHI_B_AIU};
            <%  } 
            if(iocache_present != 0) { %>
            bins IO_CACHE_AIU = {addrMgrConst::IO_CACHE_AIU};
            <%  }
            if(axi_present != 0) { %>
            bins AXI_AIU = {addrMgrConst::AXI_AIU};
            <%  } 
            if(acelite_present != 0) { %>
            bins ACE_LITE_AIU = {addrMgrConst::ACE_LITE_AIU};
            <%  } 
            if(acelite_e_present != 0) { %>
            bins ACE_LITE_E_AIU = {addrMgrConst::ACE_LITE_E_AIU};
            <%  } %>
        }

        cp_lkprsp_non_stash: coverpoint dm_state_on_lkp_e {
            bins dm_miss                                                    = {0};
            bins dm_hit_as_owner_and_other_sharers_absent                   = {1};
            bins dm_hit_as_owner_and_other_sharers_present                  = {2};
            bins dm_hit_as_sharer_and_owner_absent_other_sharers_absent     = {3};
            bins dm_hit_as_sharer_and_owner_absent_other_sharers_present    = {4};
            bins dm_hit_as_sharer_and_owner_present_other_sharers_absent    = {5};
            <%if (caching_agents > 2) { %>
            bins dm_hit_as_sharer_and_owner_present_other_sharers_present   = {6};
            <%}%>
            bins dm_hit_as_neither_and_owner_absent_other_sharers_present   = {7};
            bins dm_hit_as_neither_and_owner_present_other_sharers_absent   = {8};
            <% if (caching_agents > 2) { %>
            bins dm_hit_as_neither_and_owner_present_other_sharers_present  = {9};
            <%}
            if (caching_agents <= 1) { %>
            ignore_bins ignore_dm_hit_as_owner_and_other_sharers_present            = {2};  
            ignore_bins ignore_dm_hit_as_sharer_and_owner_absent_other_sharers_present  = {4};
            ignore_bins ignore_dm_hit_as_sharer_and_owner_present_other_sharers_absent      = {5};
            <%}%>
        }

        <% if (chi_b_present !=0) { %>
        cp_lkprsp_stash: coverpoint dm_state_on_lkp_stash {
            bins dm_miss_stash                                                 = {1};
            bins dm_hit_trgt_as_neither_and_owner_present_other_sharers_absent = {2};
            bins dm_hit_trgt_as_neither_and_owner_absent_other_sharers_present = {3};
            bins dm_hit_trgt_as_neither_and_owner_present_other_sharers_present= {4};
            bins dm_hit_trgt_as_owner_and_other_sharers_absent                 = {5};
            bins dm_hit_trgt_as_sharer_and_owner_absent_other_sharers_absent   = {6};
            bins dm_hit_trgt_as_sharer_and_owner_absent_other_sharers_present  = {7};
            bins dm_hit_trgt_as_sharer_and_owner_present_other_sharers_absent  = {8};
            <%if (caching_agents > 2) { %>
            bins dm_hit_trgt_as_sharer_and_owner_present_other_sharers_present = {9};
            <%}%>
            bins dm_hit_trgt_as_owner_and_other_sharers_present                = {10};
            <%if (caching_agents <= 1) { %>
            ignore_bins ignore_dm_hit_trgt_as_neither_and_owner_present_other_sharers_present= {4};
            ignore_bins ignore_dm_hit_trgt_as_sharer_and_owner_absent_other_sharers_present  = {7};
            ignore_bins ignore_dm_hit_trgt_as_sharer_and_owner_present_other_sharers_absent  = {8};
            ignore_bins ignore_dm_hit_trgt_as_owner_and_other_sharers_present                = {10};
            <%}%>
        }
        <%}%>

        cp_alloc: coverpoint alloc {
            <% if (chi_b_present !=0) { %>
            bins stsh_tgt_identified     = {1};
            <%}%>
            bins stsh_tgt_not_identified = {0};
        }

        //#Check.DCE.DM.CmdReqAttAllocate
        cp_attid: coverpoint attid {
            <%for(var i=0; i < (DceInfo[0].nAttCtrlEntries-(obj.DceInfo[obj.Id].useSramInputFlop?3:2));i++) {%>
                bins attid_<%=i%> = {<%=i%>};
            <%}%>
        }

        cp_awunique: coverpoint cmdreq.smi_mpf1_awunique {
            bins _0_ = {0};
            bins _1_ = {1};
        }

        //#Cover.DCE.dm_lkprsp_wrunqs_ace_awunq
        <%if (ace_present != 0) {%>
        cx_lkprsp_wrunqs_awunique: cross cp_cmd_type, cp_lkprsp_non_stash, cp_iid_type, cp_awunique iff ((inf == addrMgrConst::ACE_AIU) && (cmdreq.smi_msg_type inside {'b00010000, 'b00010001})) { //CMD_WR_UNQ_PTL and CMD_WR_UNQ_FULL
            ignore_bins non_ace = !binsof(cp_iid_type) intersect {addrMgrConst::ACE_AIU};
            ignore_bins all_cmds_except_wrunqs = !binsof(cp_cmd_type) intersect {CMD_WR_UNQ_PTL, CMD_WR_UNQ_FULL};
        }
        <%}%>

        //#Cover.DCE.DM.CmdReqType_iidType
        cx_non_stash_cmdtype_iid_type: cross cp_cmd_type, cp_iid_type iff (!(cmdreq.smi_msg_type inside {8'b00100010, 8'b00100011,8'b00100100,8'b00100101})){ //sample the cross if cmdreq is not a stash
            ignore_bins  stash_cmds = binsof(cp_cmd_type) with (dce_goldenref_model::is_stash_request(cp_cmd_type));
            ignore_bins illegal_cmds_from_nc_agents = binsof(cp_iid_type) intersect {addrMgrConst::AXI_AIU, addrMgrConst::ACE_LITE_AIU, addrMgrConst::ACE_LITE_E_AIU} &&
                                                      binsof(cp_cmd_type) intersect {CMD_RD_CLN, CMD_RD_VLD, CMD_RD_NOT_SHD, CMD_RD_UNQ, CMD_CLN_UNQ, CMD_MK_UNQ, CMD_WR_CLN_PTL, CMD_WR_CLN_FULL, CMD_WR_BK_PTL, CMD_WR_BK_FULL, CMD_WR_EVICT, CMD_EVICT};
            ignore_bins illegal_cmds_from_proxycache = binsof(cp_iid_type) intersect {addrMgrConst::IO_CACHE_AIU} &&
                                                       !binsof(cp_cmd_type) intersect {CMD_RD_NITC, CMD_RD_VLD, CMD_RD_UNQ, CMD_MK_UNQ, CMD_WR_UNQ_PTL, CMD_WR_UNQ_FULL};
            ignore_bins  illegal_read_stash_cmds_ace_lite_e = binsof(cp_iid_type) intersect {addrMgrConst::ACE_LITE_E_AIU} &&
                                                              binsof(cp_cmd_type) intersect {CMD_LD_CCH_SH, CMD_LD_CCH_UNQ};
            ignore_bins  illegal_cmds_from_ace  = binsof(cp_iid_type) intersect {addrMgrConst::ACE_AIU} && binsof(cp_cmd_type) intersect {CMD_RD_NITC_CLN_INV, CMD_RD_NITC_MK_INV, CMD_WR_CLN_PTL};
        }
            
        //#Cover.DCE.dm_nonstash_cmdtype_lkprsp
        cx_non_stash_cmdtype_lkprsp: cross cp_cmd_type, cp_lkprsp_non_stash iff (!(cmdreq.smi_msg_type inside {8'b00100010, 8'b00100011,8'b00100100,8'b00100101})) { //sample the cross if cmdreq is not a stash
            ignore_bins  stash_cmds = binsof(cp_cmd_type) with (dce_goldenref_model::is_stash_request(cp_cmd_type));
            ignore_bins  CLN_VLD_SH_PER_from_SD = binsof(cp_cmd_type) intersect {CMD_CLN_SH_PER, CMD_CLN_VLD} && binsof(cp_lkprsp_non_stash.dm_hit_as_owner_and_other_sharers_present);
            <%if(chi_b_present == 0 && chi_a_present == 0){%>
            ignore_bins INV_NITCs_ace_proxy = binsof(cp_cmd_type) intersect {CMD_RD_NITC_CLN_INV, CMD_RD_NITC_MK_INV} && !binsof(cp_lkprsp_non_stash) intersect {dm_miss, dm_hit_as_neither_and_owner_absent_other_sharers_present, dm_hit_as_neither_and_owner_present_other_sharers_absent, dm_hit_as_neither_and_owner_present_other_sharers_present};
            <%}
            if(ace_present == 0){%>
            ignore_bins  RD_CLN_From_SD_Not_possible_from_CHI   =  binsof(cp_cmd_type.CMD_RD_CLN) && binsof(cp_lkprsp_non_stash.dm_hit_as_owner_and_other_sharers_present);
            <%}
            if(caching_agents <= 1){%>
            ignore_bins  Coherent_cmds_from_neither_o_s_present =  binsof(cp_cmd_type) intersect {CMD_RD_CLN, CMD_RD_VLD, CMD_RD_NOT_SHD, CMD_RD_UNQ, CMD_CLN_UNQ, CMD_MK_UNQ, CMD_WR_CLN_PTL, CMD_WR_CLN_FULL, CMD_WR_BK_PTL, CMD_WR_BK_FULL, CMD_WR_EVICT, CMD_EVICT} && binsof(cp_lkprsp_non_stash) intersect {dm_hit_as_neither_and_owner_present_other_sharers_absent, dm_hit_as_neither_and_owner_absent_other_sharers_present};
            <%}%>
        }

        //#Cover.DCE.dm_stash_cmdtype_lkprsp_tgt_identified
        <% if (chi_b_present !=0 || acelite_e_present !=0) { %>
        <% if (chi_b_present !=0) { %>
        cx_stash_lkprsp_stashtgt_identified: cross cp_cmd_type, cp_lkprsp_stash, cp_alloc iff ((cmdreq.smi_msg_type inside {8'b00100010, 8'b00100011,8'b00100100,8'b00100101}) && alloc == 1) { //sample the cross if cmdreq is a stash
            ignore_bins  stashtgt_not_identified = binsof(cp_alloc.stsh_tgt_not_identified);
            ignore_bins  non_stash_cmds          = binsof(cp_cmd_type) with (dce_goldenref_model::is_stash_request(cp_cmd_type) == 0);
            <%if(caching_agents <= 1){%>
            ignore_bins  stash_cmds_trgt_as_neither_o_s_present =  binsof(cp_cmd_type) intersect {CMD_WR_STSH_FULL, CMD_WR_STSH_PTL,CMD_LD_CCH_SH,CMD_LD_CCH_UNQ} && binsof(cp_lkprsp_stash) intersect {dm_hit_trgt_as_neither_and_owner_present_other_sharers_absent, dm_hit_trgt_as_neither_and_owner_absent_other_sharers_present};
            <%}%>
        }

        //#Cover.DCE.dm_stash_cmdtype_lkprsp_tgt_not_identified
        cx_stash_lkprsp_stashtgt_not_identified: cross cp_cmd_type, cp_lkprsp_non_stash, cp_alloc iff ((cmdreq.smi_msg_type inside {8'b00100010, 8'b00100011,8'b00100100,8'b00100101}) && alloc == 0) { //sample the cross if cmdreq is a stash
            ignore_bins  stashtgt_identified     =   !binsof(cp_alloc.stsh_tgt_not_identified);
            ignore_bins  non_stash_cmds          =   binsof(cp_cmd_type) with (dce_goldenref_model::is_stash_request(cp_cmd_type) == 0);
        ignore_bins  illegal_write_stash         =   binsof(cp_cmd_type) intersect {CMD_WR_STSH_FULL, CMD_WR_STSH_PTL} && !binsof(cp_lkprsp_non_stash) intersect {dm_miss,dm_hit_as_neither_and_owner_absent_other_sharers_present,dm_hit_as_neither_and_owner_present_other_sharers_present,dm_hit_as_neither_and_owner_present_other_sharers_absent} ;
        } 
        <%}

        //#Cover.DCE.dm_stash_cmdtype_lkprsp_tgt_not_identified
        if (chi_b_present == 0){%>
        cx_stash_lkprsp_stashtgt_not_identified: cross cp_cmd_type, cp_lkprsp_non_stash, cp_alloc iff (cmdreq.smi_msg_type inside {8'b00100010, 8'b00100011,8'b00100100,8'b00100101}) { //sample the cross if cmdreq is a stash
            ignore_bins  stashtgt_identified     = !binsof(cp_alloc.stsh_tgt_not_identified);
            ignore_bins  non_stash_cmds          = binsof(cp_cmd_type) with (dce_goldenref_model::is_stash_request(cp_cmd_type) == 0);
            ignore_bins  ace_lite_e_valid_state  = !binsof(cp_lkprsp_non_stash) intersect {dm_miss,dm_hit_as_neither_and_owner_absent_other_sharers_present,dm_hit_as_neither_and_owner_present_other_sharers_present,dm_hit_as_neither_and_owner_present_other_sharers_absent} ;
            ignore_bins  illegal_write_stash     = binsof(cp_cmd_type) intersect {CMD_WR_STSH_FULL, CMD_WR_STSH_PTL} && !binsof(cp_lkprsp_non_stash) intersect {dm_miss,dm_hit_as_neither_and_owner_absent_other_sharers_present,dm_hit_as_neither_and_owner_present_other_sharers_present,dm_hit_as_neither_and_owner_present_other_sharers_absent} ;
        } 
        <%}
        }%>
    endgroup

    //owner bit only applies to non-stash snoops. 
    covergroup cg_snprsp with function sample(eMsgCMD cmd_type, addrMgrConst::interface_t inf, bit stash_target, bit owner, bit [WSMICMSTATUS-1:0] cmstatus);
        
        //#Cover.DCE.SnpReq
        cp_cmd_type: coverpoint cmd_type {
            <% if (chi_b_present !=0) { %>
            //stash
            bins LdCchUnq_SnpStshUnq   = {eMsgCMD'(CMD_LD_CCH_UNQ)};
            bins LdCchShd_SnpStshShd   = {eMsgCMD'(CMD_LD_CCH_SH)};
        <%}
       if (acelite_e_present!=0) { %>
            bins WrStshFull_SnpInvStsh = {eMsgCMD'(CMD_WR_STSH_FULL)};
            bins WrStshPtl_SnpUnqStsh  = {eMsgCMD'(CMD_WR_STSH_PTL)};
        <%}%>
            //reads
       <%if (caching_agents > 1) { %>
            bins RdCln_SnpClnDtr        = {eMsgCMD'(CMD_RD_CLN)};
            bins RdVld_SnpVldDtr        = {eMsgCMD'(CMD_RD_VLD)};
            bins RdNotShdDty_SnpNoSDInt = {eMsgCMD'(CMD_RD_NOT_SHD)};
            bins RdUnq_SnpInvDtr        = {eMsgCMD'(CMD_RD_UNQ)};
        <%}%>
            bins RdNITC_SnpNITC     = {eMsgCMD'(CMD_RD_NITC)};

            //atomics
            bins RdAtm_SnpInvDtw       = {eMsgCMD'(CMD_RD_ATM)};
            bins WrAtm_SnpInvDtw       = {eMsgCMD'(CMD_WR_ATM)};
            bins SwAtm_SnpInvDtw       = {eMsgCMD'(CMD_SW_ATM)};
            bins CmpAtm_SnpInvDtw      = {eMsgCMD'(CMD_CMP_ATM)};

            //cleans
       <%if (caching_agents > 1) { %>
            bins ClnUnq_SnpInvDtw      = {eMsgCMD'(CMD_CLN_UNQ)};
        <%}%>
            bins ClnInv_SnpInvDtw      = {eMsgCMD'(CMD_CLN_INV)};
            bins ClnVld_SnpClnDtw      = {eMsgCMD'(CMD_CLN_VLD)};
            bins ClnShPer_SnpClnDtw    = {eMsgCMD'(CMD_CLN_SH_PER)};
            
            //makes
       <%if (caching_agents > 1) { %>
            bins MkUnq_SnpInv          = {eMsgCMD'(CMD_MK_UNQ)};
        <%}%>
            bins MkInv_SnpInv          = {eMsgCMD'(CMD_MK_INV)};

            //writes
            bins WrUnqPtl_SnpInvDtw    = {eMsgCMD'(CMD_WR_UNQ_PTL)};
            bins WrUnqFull_SnpInv      = {eMsgCMD'(CMD_WR_UNQ_FULL)};

            //nitc
            bins RdNITCMkInv_SnpNITCMkInv   = {eMsgCMD'(CMD_RD_NITC_MK_INV)};
            bins RdNITCClnInv_SnpNITCClnInv = {eMsgCMD'(CMD_RD_NITC_CLN_INV)};
        }

        cp_snooper_type: coverpoint inf {
            <%  if(ace_present != 0) { %>
                    bins ACE_AIU = {addrMgrConst::ACE_AIU};
            <%  }
                if(chi_a_present != 0) { %>
                    bins CHI_A_AIU = {addrMgrConst::CHI_A_AIU};
            <%  } 
                if(chi_b_present != 0) { %>
                    bins CHI_B_AIU = {addrMgrConst::CHI_B_AIU};
            <%  } 
                if(iocache_present != 0) { %>
                    bins IO_CACHE_AIU = {addrMgrConst::IO_CACHE_AIU};
            <%  } %>
        }

        cp_snooper_state: coverpoint owner {
            bins owner   = {1};
            bins sharer  = {0};
        }

        cp_stash_tgt: coverpoint stash_target {
    <% if (chi_b_present !=0) { %>
            bins stash_tgt = {1};
    <%}%>
            bins peer_aiu  = {0};
        }
        /*cp_cmstatus: coverpoint cmstatus {
            ignore_bins illegal_combo_rv_0_rs_1 = {[0:63]} with ((item >> 5 == 0) && (item >> 4 == 1));
            ignore_bins illegal_val_above_63    = {[0:2**WSMICMSTATUS-1]} with (item > 63);
            ignore_bins illegal_combo_DT1_0_DC_1 = {[0:63]} with ((item >> 2 == 0 ) && (item >> 3 == 1));
        }*/

        cp_cmstatus: coverpoint cmstatus{

            bins valid_cmstatus[] = {[0:4],6,12,14,[32:34],36,38,[48:50],52,54,60};
            <%if(chi_a_present == 0 && chi_b_present == 0) {%>
            ignore_bins chi_cmstatus = {1,3,33,38,49};
            <%}
            if(acelite_e_present == 0) {%>
            ignore_bins no_acelite_cmstatus = {3};
            <%}
            if(chi_b_present == 0) {%>
            ignore_bins stash_cmstatus = {1,3,33,49};
            <%}
            if (caching_agents == 1) { %>
            ignore_bins reads_cmstatus = {12,14,60}; //These are applicable to Snps for cachable reads 
            <%}%>
            
            
        }


       <%if (caching_agents > 1) { %>
        //-------------------------------------------------
        // RdCln-SnpClnDtr
        //#Cover.DCE.RdCln.SnpRsp_CMstatus
        //-------------------------------------------------
        cx_rdcln_snprsps: cross cp_cmd_type, cp_snooper_type, cp_cmstatus iff (cmd_type == CMD_RD_CLN){
            ignore_bins not_rdcln = !binsof(cp_cmd_type.RdCln_SnpClnDtr);
            <%  if(ace_present != 0) { %>
                    ignore_bins illegal_cmstatus_ACE_AIU       = binsof(cp_snooper_type.ACE_AIU) && !binsof(cp_cmstatus) intersect {6'b000000, 6'b110000, 6'b001100, 6'b000100, 6'b100100, 6'b000110, 6'b001110, 6'b110110};
            <%  }
                if(chi_a_present != 0) { %>
                    ignore_bins illegal_cmstatus_CHI_A_AIU       = binsof(cp_snooper_type.CHI_A_AIU) && !binsof(cp_cmstatus) intersect {6'b000000, 6'b110000, 6'b001100, 6'b110100, 6'b100100, 6'b000110, 6'b001110, 6'b110110};
            <%  } 
                if(chi_b_present != 0) { %>
                    ignore_bins illegal_cmstatus_CHI_B_AIU       = binsof(cp_snooper_type.CHI_B_AIU) && !binsof(cp_cmstatus) intersect {6'b000000, 6'b110000, 6'b001100, 6'b110100, 6'b100100, 6'b000110, 6'b001110, 6'b110110};
            <%  } 
                if(iocache_present != 0) { %>
                    ignore_bins illegal_cmstatus_IO_CACHE_AIU = binsof(cp_snooper_type.IO_CACHE_AIU) && !binsof(cp_cmstatus) intersect {6'b000000, 6'b100100, 6'b110100}; //Removing 'b110000 case because DCE will not snoop sharer if not UP match but its still in the ARCH spec
            <%  } %>
        }
        
        //-------------------------------------------------
        // RdVld-SnpVldDtr
        //#Cover.DCE.RdVld.SnpRsp_CMStatus
        //-------------------------------------------------
        cx_rdvld_snprsps: cross cp_cmd_type, cp_snooper_type, cp_cmstatus iff(cmd_type == CMD_RD_VLD) {
            ignore_bins not_rdvld = !binsof(cp_cmd_type.RdVld_SnpVldDtr);
            <%  if(ace_present != 0) { %>
                    ignore_bins illegal_cmstatus_ACE_AIU       = binsof(cp_snooper_type.ACE_AIU) && !binsof(cp_cmstatus) intersect {6'b000000, 6'b110000, 6'b001100, 6'b000100, 6'b100100, 6'b111100};
            <%  }
                if(chi_a_present != 0) { %>
                    ignore_bins illegal_cmstatus_CHI_A_AIU       = binsof(cp_snooper_type.CHI_A_AIU) && !binsof(cp_cmstatus) intersect {6'b000000, 6'b110000, 6'b001100, 6'b110100, 6'b100100, 6'b111100, 6'b001110};
            <%  } 
                if(chi_b_present != 0) { %>
                    ignore_bins illegal_cmstatus_CHI_B_AIU       = binsof(cp_snooper_type.CHI_B_AIU) && !binsof(cp_cmstatus) intersect {6'b000000, 6'b110000, 6'b001100, 6'b110100, 6'b100100, 6'b111100, 6'b001110};
            <%  } 
                if(iocache_present != 0) { %>
                    ignore_bins illegal_cmstatus_IO_CACHE_AIU = binsof(cp_snooper_type.IO_CACHE_AIU) && !binsof(cp_cmstatus) intersect {6'b000000, 6'b110100, 6'b111100}; //Removing 'b110000 case because DCE will not snoop sharer if not UP match but its still in the ARCH spec
            <%  } %>
        }
        
        //-------------------------------------------------
        // RdNotShdDirty-SnpNoSDInt
        //#Cover.DCE.RdNotShdDirty.SnpRsp_CMStatus
        //-------------------------------------------------
        cx_rdnotshddirty_snprsps: cross cp_cmd_type, cp_snooper_type, cp_cmstatus iff (cmd_type == CMD_RD_NOT_SHD) {
            ignore_bins not_rdnotshddirty = !binsof(cp_cmd_type.RdNotShdDty_SnpNoSDInt);
            <%  if(ace_present != 0) { %>
                    ignore_bins illegal_cmstatus_ACE_AIU       = binsof(cp_snooper_type.ACE_AIU) && !binsof(cp_cmstatus) intersect {6'b000000, 6'b000100, 6'b001100, 6'b000110, 6'b110000, 6'b110110, 6'b100100};
            <%  }
            if(chi_a_present != 0) { %>
                    ignore_bins illegal_cmstatus_CHI_A_AIU       = binsof(cp_snooper_type.CHI_A_AIU) && !binsof(cp_cmstatus) intersect {6'b000000, 6'b000110, 6'b001100, 6'b001110, 6'b110000, 6'b110100, 6'b110110, 6'b100100};
            <%  } 
            if(chi_b_present != 0) { %>
                    ignore_bins illegal_cmstatus_CHI_B_AIU       = binsof(cp_snooper_type.CHI_B_AIU) && !binsof(cp_cmstatus) intersect {6'b000000, 6'b000110, 6'b001100, 6'b001110, 6'b110000, 6'b110100, 6'b110110, 6'b100100};
            <%  } 
            if(iocache_present != 0) { %>
                    ignore_bins illegal_cmstatus_IO_CACHE_AIU = binsof(cp_snooper_type.IO_CACHE_AIU) && !binsof(cp_cmstatus) intersect {6'b000000, 6'b100100, 6'b110100}; //Removing 'b110000 case because DCE will not snoop sharer if not UP match but its still in the ARCH spec
            <%  } %>
        }
        cx_rdunq_snprsps: cross cp_cmd_type, cp_snooper_type, cp_cmstatus iff (cmd_type == CMD_RD_UNQ) {
            ignore_bins not_rdunq_snprps = !binsof(cp_cmd_type.RdUnq_SnpInvDtr);
            <%  if(ace_present != 0) { %>
                    ignore_bins illegal_cmstatus_ACE_AIU       = binsof(cp_snooper_type.ACE_AIU) && !binsof(cp_cmstatus) intersect {6'b000000, 6'b000010, 6'b001100};
            <%  }
            if(chi_a_present != 0) { %>
                    ignore_bins illegal_cmstatus_CHI_A_AIU       = binsof(cp_snooper_type.CHI_A_AIU) && !binsof(cp_cmstatus) intersect {6'b000000, 6'b001100, 6'b000010, 6'b001110};
            <%  } 
            if(chi_b_present != 0) { %>
                    ignore_bins illegal_cmstatus_CHI_B_AIU       = binsof(cp_snooper_type.CHI_B_AIU) && !binsof(cp_cmstatus) intersect {6'b000000, 6'b001100, 6'b000010, 6'b001110};
            <%  } 
            if(iocache_present != 0) { %>
                    ignore_bins illegal_cmstatus_IO_CACHE_AIU = binsof(cp_snooper_type.IO_CACHE_AIU) && !binsof(cp_cmstatus) intersect {6'b000000, 6'b000010, 6'b001100};
            <%  } %>
        }
        <%}%>

        //-------------------------------------------------
        // RdNITC-SnpNITC
        //#Cover.DCE.RdNITC.SnpRsp_CMStatus
        //-------------------------------------------------
        cx_rdnitc_snprsps: cross cp_cmd_type, cp_snooper_type, cp_cmstatus iff (cmd_type == CMD_RD_NITC) {
            ignore_bins not_rdnitc        = !binsof(cp_cmd_type.RdNITC_SnpNITC);
            <% if(chi_a_present != 0) { %>
                    ignore_bins illegal_cmstatus_CHI_A_AIU       = binsof(cp_snooper_type.CHI_A_AIU) && !binsof(cp_cmstatus) intersect {6'b000000, 6'b000100, 6'b110000, 6'b110100, 6'b110110, 6'b100000, 6'b100100, 6'b100110,6'b000110};
            <%  } 
               if(chi_b_present != 0) { %>
                    ignore_bins illegal_cmstatus_CHI_B_AIU       = binsof(cp_snooper_type.CHI_B_AIU) && !binsof(cp_cmstatus) intersect {6'b000000, 6'b000100, 6'b110000, 6'b110100, 6'b110110, 6'b100000, 6'b100100, 6'b100110,6'b000110};
            <%  } 
                if(ace_present != 0) { %>
                    ignore_bins illegal_cmstatus_ACE_AIU       = binsof(cp_snooper_type.ACE_AIU) && !binsof(cp_cmstatus) intersect {6'b000000, 6'b000100, 6'b000110, 6'b110000, 6'b110110, 6'b100000, 6'b100100};
            <%  }
                if(iocache_present != 0) { %>
                    ignore_bins illegal_cmstatus_IO_CACHE_AIU = binsof(cp_snooper_type.IO_CACHE_AIU) && !binsof(cp_cmstatus) intersect {6'b000000, 6'b110100, 6'b100100};
            <%  } %>
        }

        
        //-------------------------------------------------
        // RdNITCClnInv-SnpNITCClnInv
        //#Cover.DCE.RdNITCClnInv.SnpRsp_CMStatus
        //-------------------------------------------------
        cx_rdnitcclninv_snprsps: cross cp_cmd_type, cp_snooper_type, cp_cmstatus iff (cmd_type == CMD_RD_NITC_CLN_INV) {
            ignore_bins not_rdnitcclninv  = !binsof(cp_cmd_type.RdNITCClnInv_SnpNITCClnInv);
            <% if(chi_a_present != 0) { %>
                    ignore_bins illegal_cmstatus_CHI_A_AIU       = binsof(cp_snooper_type.CHI_A_AIU) && !binsof(cp_cmstatus) intersect {6'b000000, 6'b000100, 6'b000110};
            <%  } 
               if(chi_b_present != 0) { %>
                    ignore_bins illegal_cmstatus_CHI_B_AIU       = binsof(cp_snooper_type.CHI_B_AIU) && !binsof(cp_cmstatus) intersect {6'b000000, 6'b000100, 6'b000110};
            <%  } 
                if(ace_present != 0) { %>
                    ignore_bins illegal_cmstatus_ACE_AIU       = binsof(cp_snooper_type.ACE_AIU) && !binsof(cp_cmstatus) intersect {6'b000000, 6'b000110};
            <%  }
                if(iocache_present != 0) { %>
                    ignore_bins illegal_cmstatus_IO_CACHE_AIU = binsof(cp_snooper_type.IO_CACHE_AIU) && !binsof(cp_cmstatus) intersect {6'b000000, 6'b000100, 6'b000110};
            <%  } %>
        }

        //-------------------------------------------------
        // RdNITCMkInv-SnpNITCMkInv
        //#Cover.DCE.RdNITCMkInv.SnpRsp_CMStatus
        //-------------------------------------------------
        cx_rdnitcmkinv_snprsps: cross cp_cmd_type, cp_snooper_type, cp_cmstatus iff(cmd_type == CMD_RD_NITC_MK_INV){
            ignore_bins not_rdnitcmkinv  = !binsof(cp_cmd_type.RdNITCMkInv_SnpNITCMkInv);
            <% if(chi_a_present != 0) { %>
                    ignore_bins illegal_cmstatus_CHI_A_AIU       = binsof(cp_snooper_type.CHI_A_AIU) && !binsof(cp_cmstatus) intersect {6'b000000, 6'b000100, 6'b000110};
            <%  } 
               if(chi_b_present != 0) { %>
                    ignore_bins illegal_cmstatus_CHI_B_AIU       = binsof(cp_snooper_type.CHI_B_AIU) && !binsof(cp_cmstatus) intersect {6'b000000, 6'b000100, 6'b000110};
            <%  } 
                if(ace_present != 0) { %>
                    ignore_bins illegal_cmstatus_ACE_AIU       = binsof(cp_snooper_type.ACE_AIU) && !binsof(cp_cmstatus) intersect {6'b000000, 6'b000110};
            <%  }
                if(iocache_present != 0) { %>
                    ignore_bins illegal_cmstatus_IO_CACHE_AIU = binsof(cp_snooper_type.IO_CACHE_AIU) && !binsof(cp_cmstatus) intersect {6'b000000, 6'b000100};
            <%  } %>
        }

        //-------------------------------------------------
        // MkInv-SnpInv
        //#Cover.DCE.MkInv.SnpRsp_CMStatus
        //-------------------------------------------------
        cx_mkinv_snprsps_owner: cross cp_cmd_type, cp_snooper_type, cp_cmstatus iff(cmd_type == CMD_MK_INV && owner == 1) {
            ignore_bins not_mkinv          = !binsof(cp_cmd_type.MkInv_SnpInv);
            <% if(chi_a_present != 0) { %>
                    ignore_bins illegal_cmstatus_CHI_A_AIU       = binsof(cp_snooper_type.CHI_A_AIU) && !binsof(cp_cmstatus) intersect {6'b000000};
            <%  } 
               if(chi_b_present != 0) { %>
                    ignore_bins illegal_cmstatus_CHI_B_AIU       = binsof(cp_snooper_type.CHI_B_AIU) && !binsof(cp_cmstatus) intersect {6'b000000};
            <%  } 
                if(ace_present != 0) { %>
                    ignore_bins illegal_cmstatus_ACE_AIU       = binsof(cp_snooper_type.ACE_AIU) && !binsof(cp_cmstatus) intersect {6'b000000};
            <%  }
                if(iocache_present != 0) { %>
                    ignore_bins illegal_cmstatus_IO_CACHE_AIU = binsof(cp_snooper_type.IO_CACHE_AIU) && !binsof(cp_cmstatus) intersect {6'b000000};
            <%  } %>
        }
       <%if (caching_agents > 1) { %>
        cx_mkinv_snprsps_sharer: cross cp_cmd_type, cp_snooper_type, cp_cmstatus iff(cmd_type == CMD_MK_INV && owner == 0) {
            ignore_bins not_mkinv          = !binsof(cp_cmd_type.MkInv_SnpInv);
            <% if(chi_a_present != 0) { %>
                    ignore_bins illegal_cmstatus_CHI_A_AIU       = binsof(cp_snooper_type.CHI_A_AIU) && !binsof(cp_cmstatus) intersect {6'b000000};
            <%  } 
               if(chi_b_present != 0) { %>
                    ignore_bins illegal_cmstatus_CHI_B_AIU       = binsof(cp_snooper_type.CHI_B_AIU) && !binsof(cp_cmstatus) intersect {6'b000000};
            <%  } 
                if(ace_present != 0) { %>
                    ignore_bins illegal_cmstatus_ACE_AIU       = binsof(cp_snooper_type.ACE_AIU) && !binsof(cp_cmstatus) intersect {6'b000000};
            <%  }
                if(iocache_present != 0) { %>
                    ignore_bins illegal_cmstatus_IO_CACHE_AIU = binsof(cp_snooper_type.IO_CACHE_AIU) && !binsof(cp_cmstatus) intersect {6'b000000};
            <%  } %>
        }
        <%}

       if (caching_agents > 1) { %>
        //-------------------------------------------------
        // MkUnq-SnpInv
        //#Cover.DCE.MkUnq.SnpRsp_CMStatus
        //-------------------------------------------------
        cx_mkunq_snprsps_owner: cross cp_cmd_type, cp_snooper_type, cp_cmstatus iff (cmd_type == CMD_MK_UNQ && owner == 1) {
            ignore_bins not_mkunq          = !binsof(cp_cmd_type.MkUnq_SnpInv);
            <% if(chi_a_present != 0) { %>
                    ignore_bins illegal_cmstatus_CHI_A_AIU       = binsof(cp_snooper_type.CHI_A_AIU) && !binsof(cp_cmstatus) intersect {6'b000000};
            <%  } 
               if(chi_b_present != 0) { %>
                    ignore_bins illegal_cmstatus_CHI_B_AIU       = binsof(cp_snooper_type.CHI_B_AIU) && !binsof(cp_cmstatus) intersect {6'b000000};
            <%  } 
                if(ace_present != 0) { %>
                    ignore_bins illegal_cmstatus_ACE_AIU       = binsof(cp_snooper_type.ACE_AIU) && !binsof(cp_cmstatus) intersect {6'b000000};
            <%  }
                if(iocache_present != 0) { %>
                    ignore_bins illegal_cmstatus_IO_CACHE_AIU = binsof(cp_snooper_type.IO_CACHE_AIU) && !binsof(cp_cmstatus) intersect {6'b000000};
            <%  } %>
        }
        <%}
       if (caching_agents > 2) { %>
        cx_mkunq_snprsps_sharer: cross cp_cmd_type, cp_snooper_type, cp_cmstatus iff (cmd_type == CMD_MK_UNQ && owner == 0) {
            ignore_bins not_mkunq          = !binsof(cp_cmd_type.MkUnq_SnpInv);
            <% if(chi_a_present != 0) { %>
                    ignore_bins illegal_cmstatus_CHI_A_AIU       = binsof(cp_snooper_type.CHI_A_AIU) && !binsof(cp_cmstatus) intersect {6'b000000};
            <%  } 
               if(chi_b_present != 0) { %>
                    ignore_bins illegal_cmstatus_CHI_B_AIU       = binsof(cp_snooper_type.CHI_B_AIU) && !binsof(cp_cmstatus) intersect {6'b000000};
            <%  } 
                if(ace_present != 0) { %>
                    ignore_bins illegal_cmstatus_ACE_AIU       = binsof(cp_snooper_type.ACE_AIU) && !binsof(cp_cmstatus) intersect {6'b000000};
            <%  }
                if(iocache_present != 0) { %>
                    ignore_bins illegal_cmstatus_IO_CACHE_AIU = binsof(cp_snooper_type.IO_CACHE_AIU) && !binsof(cp_cmstatus) intersect {6'b000000};
            <%  } %>
        }
        <%}%>

        //-------------------------------------------------
        // WrUnqFull-SnpInv
        //#Cover.DCE.WrUnqFull.SnpRsp_CMStatus
        //-------------------------------------------------
        cx_wrunqfull_snprsps_owner: cross cp_cmd_type, cp_snooper_type, cp_cmstatus iff (cmd_type == CMD_WR_UNQ_FULL && owner == 1){
            ignore_bins not_wrunqfull      = !binsof(cp_cmd_type.WrUnqFull_SnpInv);
            <% if(chi_a_present != 0) { %>
                    ignore_bins illegal_cmstatus_CHI_A_AIU       = binsof(cp_snooper_type.CHI_A_AIU) && !binsof(cp_cmstatus) intersect {6'b000000};
            <%  } 
               if(chi_b_present != 0) { %>
                    ignore_bins illegal_cmstatus_CHI_B_AIU       = binsof(cp_snooper_type.CHI_B_AIU) && !binsof(cp_cmstatus) intersect {6'b000000};
            <%  } 
                if(ace_present != 0) { %>
                    ignore_bins illegal_cmstatus_ACE_AIU       = binsof(cp_snooper_type.ACE_AIU) && !binsof(cp_cmstatus) intersect {6'b000000};
            <%  }
                if(iocache_present != 0) { %>
                    ignore_bins illegal_cmstatus_IO_CACHE_AIU = binsof(cp_snooper_type.IO_CACHE_AIU) && !binsof(cp_cmstatus) intersect {6'b000000};
            <%  } %>
        }
        cx_wrunqfull_snprsps_sharer: cross cp_cmd_type, cp_snooper_type, cp_cmstatus iff (cmd_type == CMD_WR_UNQ_FULL && owner == 0){
            ignore_bins not_wrunqfull      = !binsof(cp_cmd_type.WrUnqFull_SnpInv);
            <% if(chi_a_present != 0) { %>
                    ignore_bins illegal_cmstatus_CHI_A_AIU       = binsof(cp_snooper_type.CHI_A_AIU) && !binsof(cp_cmstatus) intersect {6'b000000};
            <%  } 
               if(chi_b_present != 0) { %>
                    ignore_bins illegal_cmstatus_CHI_B_AIU       = binsof(cp_snooper_type.CHI_B_AIU) && !binsof(cp_cmstatus) intersect {6'b000000};
            <%  } 
                if(ace_present != 0) { %>
                    ignore_bins illegal_cmstatus_ACE_AIU       = binsof(cp_snooper_type.ACE_AIU) && !binsof(cp_cmstatus) intersect {6'b000000};
            <%  }
                if(iocache_present != 0) { %>
                    ignore_bins illegal_cmstatus_IO_CACHE_AIU = binsof(cp_snooper_type.IO_CACHE_AIU) && !binsof(cp_cmstatus) intersect {6'b000000};
            <%  } %>
        }

        //-------------------------------------------------
        // WrUnqPtl-SnpInvDtw
        //#Cover.DCE.WrUnqPtl.SnpRsp_CMStatus
        //-------------------------------------------------
        cx_wrunqptl_snprsps_owner: cross cp_cmd_type, cp_snooper_type, cp_cmstatus iff (cmd_type == CMD_WR_UNQ_PTL && owner == 1) {
            ignore_bins not_wrunqptl       = !binsof(cp_cmd_type.WrUnqPtl_SnpInvDtw);
            <% if(chi_a_present != 0) { %>
                    ignore_bins illegal_cmstatus_CHI_A_AIU       = binsof(cp_snooper_type.CHI_A_AIU) && !binsof(cp_cmstatus) intersect {6'b000000, 6'b000010};
            <%  } 
               if(chi_b_present != 0) { %>
                    ignore_bins illegal_cmstatus_CHI_B_AIU       = binsof(cp_snooper_type.CHI_B_AIU) && !binsof(cp_cmstatus) intersect {6'b000000, 6'b000010};
            <%  } 
                if(ace_present != 0) { %>
                    ignore_bins illegal_cmstatus_ACE_AIU       = binsof(cp_snooper_type.ACE_AIU) && !binsof(cp_cmstatus) intersect {6'b000000, 6'b000010};
            <%  }
                if(iocache_present != 0) { %>
                    ignore_bins illegal_cmstatus_IO_CACHE_AIU = binsof(cp_snooper_type.IO_CACHE_AIU) && !binsof(cp_cmstatus) intersect {6'b000000, 6'b000010};
            <%  } %>
        }
        cx_wrunqptl_snprsps_sharer: cross cp_cmd_type, cp_snooper_type, cp_cmstatus iff (cmd_type == CMD_WR_UNQ_PTL && owner == 0) {
            ignore_bins not_wrunqptl       = !binsof(cp_cmd_type.WrUnqPtl_SnpInvDtw);
            <% if(chi_a_present != 0) { %>
                    ignore_bins illegal_cmstatus_CHI_A_AIU       = binsof(cp_snooper_type.CHI_A_AIU) && !binsof(cp_cmstatus) intersect {6'b000000};
            <%  } 
               if(chi_b_present != 0) { %>
                    ignore_bins illegal_cmstatus_CHI_B_AIU       = binsof(cp_snooper_type.CHI_B_AIU) && !binsof(cp_cmstatus) intersect {6'b000000};
            <%  } 
                if(ace_present != 0) { %>
                    ignore_bins illegal_cmstatus_ACE_AIU       = binsof(cp_snooper_type.ACE_AIU) && !binsof(cp_cmstatus) intersect {6'b000000};
            <%  }
                if(iocache_present != 0) { %>
                    ignore_bins illegal_cmstatus_IO_CACHE_AIU = binsof(cp_snooper_type.IO_CACHE_AIU) && !binsof(cp_cmstatus) intersect {6'b000000};
            <%  } %>
        }

        //-------------------------------------------------
        // ClnInv-SnpInvDtw
        //#Cover.DCE.ClnInv.SnpRsp_CMStatus
        //-------------------------------------------------
        cx_clninv_snprsps_owner: cross cp_cmd_type, cp_snooper_type, cp_cmstatus iff (cmd_type == CMD_CLN_INV && owner == 1){
            ignore_bins not_clninv         = !binsof(cp_cmd_type.ClnInv_SnpInvDtw);
            <% if(chi_a_present != 0) { %>
                    ignore_bins illegal_cmstatus_CHI_A_AIU       = binsof(cp_snooper_type.CHI_A_AIU) && !binsof(cp_cmstatus) intersect {6'b000000, 6'b000010};
            <%  } 
               if(chi_b_present != 0) { %>
                    ignore_bins illegal_cmstatus_CHI_B_AIU       = binsof(cp_snooper_type.CHI_B_AIU) && !binsof(cp_cmstatus) intersect {6'b000000, 6'b000010};
            <%  } 
                if(ace_present != 0) { %>
                    ignore_bins illegal_cmstatus_ACE_AIU       = binsof(cp_snooper_type.ACE_AIU) && !binsof(cp_cmstatus) intersect {6'b000000, 6'b000010};
            <%  }
                if(iocache_present != 0) { %>
                    ignore_bins illegal_cmstatus_IO_CACHE_AIU = binsof(cp_snooper_type.IO_CACHE_AIU) && !binsof(cp_cmstatus) intersect {6'b000000, 6'b000010};
            <%  } %>
        }
        cx_clninv_snprsps_sharer: cross cp_cmd_type, cp_snooper_type, cp_cmstatus iff (cmd_type == CMD_CLN_INV && owner == 0){
            ignore_bins not_clninv         = !binsof(cp_cmd_type.ClnInv_SnpInvDtw);
            <% if(chi_a_present != 0) { %>
                    ignore_bins illegal_cmstatus_CHI_A_AIU       = binsof(cp_snooper_type.CHI_A_AIU) && !binsof(cp_cmstatus) intersect {6'b000000};
            <%  } 
               if(chi_b_present != 0) { %>
                    ignore_bins illegal_cmstatus_CHI_B_AIU       = binsof(cp_snooper_type.CHI_B_AIU) && !binsof(cp_cmstatus) intersect {6'b000000};
            <%  } 
                if(ace_present != 0) { %>
                    ignore_bins illegal_cmstatus_ACE_AIU       = binsof(cp_snooper_type.ACE_AIU) && !binsof(cp_cmstatus) intersect {6'b000000};
            <%  }
                if(iocache_present != 0) { %>
                    ignore_bins illegal_cmstatus_IO_CACHE_AIU = binsof(cp_snooper_type.IO_CACHE_AIU) && !binsof(cp_cmstatus) intersect {6'b000000};
            <%  } %>
        }

       <%if (caching_agents > 1) { %>
        //-------------------------------------------------
        // ClnUnq-SnpInvDtw
        //#Cover.DCE.ClnUnq.SnpRsp_CMStatus
        //-------------------------------------------------
        cx_clnunq_snprsps_owner: cross cp_cmd_type, cp_snooper_type, cp_cmstatus iff (cmd_type == CMD_CLN_UNQ && owner == 1){
            ignore_bins not_clnunq         = !binsof(cp_cmd_type.ClnUnq_SnpInvDtw);
            <% if(chi_a_present != 0) { %>
                    ignore_bins illegal_cmstatus_CHI_A_AIU       = binsof(cp_snooper_type.CHI_A_AIU) && !binsof(cp_cmstatus) intersect {6'b000000, 6'b000010};
            <%  } 
               if(chi_b_present != 0) { %>
                    ignore_bins illegal_cmstatus_CHI_B_AIU       = binsof(cp_snooper_type.CHI_B_AIU) && !binsof(cp_cmstatus) intersect {6'b000000, 6'b000010};
            <%  } 
                if(ace_present != 0) { %>
                    ignore_bins illegal_cmstatus_ACE_AIU       = binsof(cp_snooper_type.ACE_AIU) && !binsof(cp_cmstatus) intersect {6'b000000, 6'b000010};
            <%  }
                if(iocache_present != 0) { %>
                    ignore_bins illegal_cmstatus_IO_CACHE_AIU = binsof(cp_snooper_type.IO_CACHE_AIU) && !binsof(cp_cmstatus) intersect {6'b000000, 6'b000010};
            <%  } %>
        }
        cx_clnunq_snprsps_sharer: cross cp_cmd_type, cp_snooper_type, cp_cmstatus iff (cmd_type == CMD_CLN_UNQ && owner == 0){
            ignore_bins not_clnunq         = !binsof(cp_cmd_type.ClnUnq_SnpInvDtw);
            <% if(chi_a_present != 0) { %>
                    ignore_bins illegal_cmstatus_CHI_A_AIU       = binsof(cp_snooper_type.CHI_A_AIU) && !binsof(cp_cmstatus) intersect {6'b000000};
            <%  } 
               if(chi_b_present != 0) { %>
                    ignore_bins illegal_cmstatus_CHI_B_AIU       = binsof(cp_snooper_type.CHI_B_AIU) && !binsof(cp_cmstatus) intersect {6'b000000};
            <%  } 
                if(ace_present != 0) { %>
                    ignore_bins illegal_cmstatus_ACE_AIU       = binsof(cp_snooper_type.ACE_AIU) && !binsof(cp_cmstatus) intersect {6'b000000};
            <%  }
                if(iocache_present != 0) { %>
                    ignore_bins illegal_cmstatus_IO_CACHE_AIU = binsof(cp_snooper_type.IO_CACHE_AIU) && !binsof(cp_cmstatus) intersect {6'b000000};
            <%  } %>
        }
        <%}%>

        //-------------------------------------------------
        // RdAtm-SnpInvDtw
        //#Cover.DCE.RdAtm.SnpRsp_CMStatus
        //-------------------------------------------------
        cx_rdatm_snprsps_owner: cross cp_cmd_type, cp_snooper_type, cp_cmstatus iff (cmd_type == CMD_RD_ATM && owner == 1) {
            ignore_bins not_rdatm          = !binsof(cp_cmd_type.RdAtm_SnpInvDtw);
            <% if(chi_a_present != 0) { %>
                    ignore_bins illegal_cmstatus_CHI_A_AIU       = binsof(cp_snooper_type.CHI_A_AIU) && !binsof(cp_cmstatus) intersect {6'b000000, 6'b000010};
            <%  } 
               if(chi_b_present != 0) { %>
                    ignore_bins illegal_cmstatus_CHI_B_AIU       = binsof(cp_snooper_type.CHI_B_AIU) && !binsof(cp_cmstatus) intersect {6'b000000, 6'b000010};
            <%  } 
                if(ace_present != 0) { %>
                    ignore_bins illegal_cmstatus_ACE_AIU       = binsof(cp_snooper_type.ACE_AIU) && !binsof(cp_cmstatus) intersect {6'b000000, 6'b000010};
            <%  }
                if(iocache_present != 0) { %>
                    ignore_bins illegal_cmstatus_IO_CACHE_AIU = binsof(cp_snooper_type.IO_CACHE_AIU) && !binsof(cp_cmstatus) intersect {6'b000000, 6'b000010};
            <%  } %>
        }
        cx_rdatm_snprsps_sharer: cross cp_cmd_type, cp_snooper_type, cp_cmstatus iff (cmd_type == CMD_RD_ATM && owner == 0) {
            ignore_bins not_rdatm          = !binsof(cp_cmd_type.RdAtm_SnpInvDtw);
            <% if(chi_a_present != 0) { %>
                    ignore_bins illegal_cmstatus_CHI_A_AIU       = binsof(cp_snooper_type.CHI_A_AIU) && !binsof(cp_cmstatus) intersect {6'b000000};
            <%  } 
               if(chi_b_present != 0) { %>
                    ignore_bins illegal_cmstatus_CHI_B_AIU       = binsof(cp_snooper_type.CHI_B_AIU) && !binsof(cp_cmstatus) intersect {6'b000000};
            <%  } 
                if(ace_present != 0) { %>
                    ignore_bins illegal_cmstatus_ACE_AIU       = binsof(cp_snooper_type.ACE_AIU) && !binsof(cp_cmstatus) intersect {6'b000000};
            <%  }
                if(iocache_present != 0) { %>
                    ignore_bins illegal_cmstatus_IO_CACHE_AIU = binsof(cp_snooper_type.IO_CACHE_AIU) && !binsof(cp_cmstatus) intersect {6'b000000};
            <%  } %>
        }

        //-------------------------------------------------
        // WrAtm-SnpInvDtw
        //-------------------------------------------------
        //#Cover.DCE.WrAtm.SnpRsp_CMStatus
        cx_wratm_snprsps_owner: cross cp_cmd_type, cp_snooper_type, cp_cmstatus iff (cmd_type == CMD_WR_ATM && owner == 1){
            ignore_bins not_wratm          = !binsof(cp_cmd_type.WrAtm_SnpInvDtw);
            <% if(chi_a_present != 0) { %>
                    ignore_bins illegal_cmstatus_CHI_A_AIU       = binsof(cp_snooper_type.CHI_A_AIU) && !binsof(cp_cmstatus) intersect {6'b000000, 6'b000010};
            <%  } 
               if(chi_b_present != 0) { %>
                    ignore_bins illegal_cmstatus_CHI_B_AIU       = binsof(cp_snooper_type.CHI_B_AIU) && !binsof(cp_cmstatus) intersect {6'b000000, 6'b000010};
            <%  } 
                if(ace_present != 0) { %>
                    ignore_bins illegal_cmstatus_ACE_AIU       = binsof(cp_snooper_type.ACE_AIU) && !binsof(cp_cmstatus) intersect {6'b000000, 6'b000010};
            <%  }
                if(iocache_present != 0) { %>
                    ignore_bins illegal_cmstatus_IO_CACHE_AIU = binsof(cp_snooper_type.IO_CACHE_AIU) && !binsof(cp_cmstatus) intersect {6'b000000, 6'b000010};
            <%  } %>
        }
        cx_wratm_snprsps_sharer: cross cp_cmd_type, cp_snooper_type, cp_cmstatus iff (cmd_type == CMD_WR_ATM && owner == 0){
            ignore_bins not_wratm          = !binsof(cp_cmd_type.WrAtm_SnpInvDtw);
            <% if(chi_a_present != 0) { %>
                    ignore_bins illegal_cmstatus_CHI_A_AIU       = binsof(cp_snooper_type.CHI_A_AIU) && !binsof(cp_cmstatus) intersect {6'b000000};
            <%  } 
               if(chi_b_present != 0) { %>
                    ignore_bins illegal_cmstatus_CHI_B_AIU       = binsof(cp_snooper_type.CHI_B_AIU) && !binsof(cp_cmstatus) intersect {6'b000000};
            <%  } 
                if(ace_present != 0) { %>
                    ignore_bins illegal_cmstatus_ACE_AIU       = binsof(cp_snooper_type.ACE_AIU) && !binsof(cp_cmstatus) intersect {6'b000000};
            <%  }
                if(iocache_present != 0) { %>
                    ignore_bins illegal_cmstatus_IO_CACHE_AIU = binsof(cp_snooper_type.IO_CACHE_AIU) && !binsof(cp_cmstatus) intersect {6'b000000};
            <%  } %>
        }
        
        //-------------------------------------------------
        // SwAtm-SnpInvDtw
        //-------------------------------------------------
        //#Cover.DCE.SwpAtm.SnpRsp_CMStatus
        cx_swatm_snprsps_owner: cross cp_cmd_type, cp_snooper_type, cp_cmstatus iff (cmd_type == CMD_SW_ATM && owner == 1) {
            ignore_bins not_swatm          = !binsof(cp_cmd_type.SwAtm_SnpInvDtw);
            <% if(chi_a_present != 0) { %>
                    ignore_bins illegal_cmstatus_CHI_A_AIU       = binsof(cp_snooper_type.CHI_A_AIU) && !binsof(cp_cmstatus) intersect {6'b000000, 6'b000010};
            <%  } 
               if(chi_b_present != 0) { %>
                    ignore_bins illegal_cmstatus_CHI_B_AIU       = binsof(cp_snooper_type.CHI_B_AIU) && !binsof(cp_cmstatus) intersect {6'b000000, 6'b000010};
            <%  } 
                if(ace_present != 0) { %>
                    ignore_bins illegal_cmstatus_ACE_AIU       = binsof(cp_snooper_type.ACE_AIU) && !binsof(cp_cmstatus) intersect {6'b000000, 6'b000010};
            <%  }
                if(iocache_present != 0) { %>
                    ignore_bins illegal_cmstatus_IO_CACHE_AIU = binsof(cp_snooper_type.IO_CACHE_AIU) && !binsof(cp_cmstatus) intersect {6'b000000, 6'b000010};
            <%  } %>
        }
        cx_swatm_snprsps_sharer: cross cp_cmd_type, cp_snooper_type, cp_cmstatus iff (cmd_type == CMD_SW_ATM && owner == 0) {
            ignore_bins not_swatm          = !binsof(cp_cmd_type.SwAtm_SnpInvDtw);
            <% if(chi_a_present != 0) { %>
                    ignore_bins illegal_cmstatus_CHI_A_AIU       = binsof(cp_snooper_type.CHI_A_AIU) && !binsof(cp_cmstatus) intersect {6'b000000};
            <%  } 
               if(chi_b_present != 0) { %>
                    ignore_bins illegal_cmstatus_CHI_B_AIU       = binsof(cp_snooper_type.CHI_B_AIU) && !binsof(cp_cmstatus) intersect {6'b000000};
            <%  } 
                if(ace_present != 0) { %>
                    ignore_bins illegal_cmstatus_ACE_AIU       = binsof(cp_snooper_type.ACE_AIU) && !binsof(cp_cmstatus) intersect {6'b000000};
            <%  }
                if(iocache_present != 0) { %>
                    ignore_bins illegal_cmstatus_IO_CACHE_AIU = binsof(cp_snooper_type.IO_CACHE_AIU) && !binsof(cp_cmstatus) intersect {6'b000000};
            <%  } %>
        }

        //-------------------------------------------------
        // CmpAtm-SnpInvDtw
        //-------------------------------------------------
        //#Cover.DCE.CmpAtm.SnpRsp_CMStatus
        cx_cmpatm_snprsps_owner: cross cp_cmd_type, cp_snooper_type, cp_cmstatus iff (cmd_type ==  CMD_CMP_ATM && owner == 1) {
            ignore_bins not_cmpatm         = !binsof(cp_cmd_type.CmpAtm_SnpInvDtw);
            <% if(chi_a_present != 0) { %>
                    ignore_bins illegal_cmstatus_CHI_A_AIU       = binsof(cp_snooper_type.CHI_A_AIU) && !binsof(cp_cmstatus) intersect {6'b000000, 6'b000010};
            <%  } 
               if(chi_b_present != 0) { %>
                    ignore_bins illegal_cmstatus_CHI_B_AIU       = binsof(cp_snooper_type.CHI_B_AIU) && !binsof(cp_cmstatus) intersect {6'b000000, 6'b000010};
            <%  } 
                if(ace_present != 0) { %>
                    ignore_bins illegal_cmstatus_ACE_AIU       = binsof(cp_snooper_type.ACE_AIU) && !binsof(cp_cmstatus) intersect {6'b000000, 6'b000010};
            <%  }
                if(iocache_present != 0) { %>
                    ignore_bins illegal_cmstatus_IO_CACHE_AIU = binsof(cp_snooper_type.IO_CACHE_AIU) && !binsof(cp_cmstatus) intersect {6'b000000, 6'b000010};
            <%  } %>
        }
        cx_cmpatm_snprsps_sharer: cross cp_cmd_type, cp_snooper_type, cp_cmstatus iff (cmd_type ==  CMD_CMP_ATM && owner == 0) {
            ignore_bins not_cmpatm         = !binsof(cp_cmd_type.CmpAtm_SnpInvDtw);
            <% if(chi_a_present != 0) { %>
                    ignore_bins illegal_cmstatus_CHI_A_AIU       = binsof(cp_snooper_type.CHI_A_AIU) && !binsof(cp_cmstatus) intersect {6'b000000};
            <%  } 
               if(chi_b_present != 0) { %>
                    ignore_bins illegal_cmstatus_CHI_B_AIU       = binsof(cp_snooper_type.CHI_B_AIU) && !binsof(cp_cmstatus) intersect {6'b000000};
            <%  } 
                if(ace_present != 0) { %>
                    ignore_bins illegal_cmstatus_ACE_AIU       = binsof(cp_snooper_type.ACE_AIU) && !binsof(cp_cmstatus) intersect {6'b000000};
            <%  }
                if(iocache_present != 0) { %>
                    ignore_bins illegal_cmstatus_IO_CACHE_AIU = binsof(cp_snooper_type.IO_CACHE_AIU) && !binsof(cp_cmstatus) intersect {6'b000000};
            <%  } %>
        }
        
        //-------------------------------------------------
        // ClnVld-SnpClnDtw
        //#Cover.DCE.ClnVld.SnpRsp_CMStatus
        //-------------------------------------------------
        cx_clnvld_snprsps: cross cp_cmd_type, cp_snooper_type, cp_cmstatus iff(cmd_type == CMD_CLN_VLD) {
            ignore_bins not_clnvld         = !binsof(cp_cmd_type.ClnVld_SnpClnDtw);
            <% if(chi_a_present != 0) { %>
                    ignore_bins illegal_cmstatus_CHI_A_AIU       = binsof(cp_snooper_type.CHI_A_AIU) && (!binsof(cp_cmstatus) intersect {6'b000000, 6'b000010, 6'b100000, 6'b100010, 6'b110000, 6'b110010});
            <%  } 
               if(chi_b_present != 0) { %>
                    ignore_bins illegal_cmstatus_CHI_B_AIU       = binsof(cp_snooper_type.CHI_B_AIU) && (!binsof(cp_cmstatus) intersect {6'b000000, 6'b000010, 6'b100000, 6'b100010, 6'b110000, 6'b110010});
            <%  } 
                if(ace_present != 0) { %>
                    ignore_bins illegal_cmstatus_ACE_AIU       = binsof(cp_snooper_type.ACE_AIU) && (!binsof(cp_cmstatus) intersect {6'b000000, 6'b000010, 6'b100000, 6'b110000, 6'b110010});
            <%  }
                if(iocache_present != 0) { %>
                    ignore_bins illegal_cmstatus_IO_CACHE_AIU = binsof(cp_snooper_type.IO_CACHE_AIU) && (!binsof(cp_cmstatus) intersect {6'b000000, 6'b100000, 6'b100010, 6'b110000, 6'b110010});
            <%  } %>
        }

        //-------------------------------------------------
        // ClnShPer-SnpClnDtw
        //#Cover.DCE.ClnShPer.SnpRsp_CMStatus
        //-------------------------------------------------
        cx_clnshper_snprsps: cross cp_cmd_type, cp_snooper_type, cp_cmstatus iff (cmd_type == CMD_CLN_SH_PER) {
            ignore_bins not_clnshper       = !binsof(cp_cmd_type.ClnShPer_SnpClnDtw);
            <% if(chi_a_present != 0) { %>
                    ignore_bins illegal_cmstatus_CHI_A_AIU       = binsof(cp_snooper_type.CHI_A_AIU) && !binsof(cp_cmstatus) intersect {6'b000000, 6'b000010, 6'b100000, 6'b100010, 6'b110000, 6'b110010};
            <%  } 
               if(chi_b_present != 0) { %>
                    ignore_bins illegal_cmstatus_CHI_B_AIU       = binsof(cp_snooper_type.CHI_B_AIU) && !binsof(cp_cmstatus) intersect {6'b000000, 6'b000010, 6'b100000, 6'b100010, 6'b110000, 6'b110010};
            <%  } 
                if(ace_present != 0) { %>
                    ignore_bins illegal_cmstatus_ACE_AIU       = binsof(cp_snooper_type.ACE_AIU) && !binsof(cp_cmstatus) intersect {6'b000000, 6'b000010, 6'b100000, 6'b110000, 6'b110010};
            <%  }
                if(iocache_present != 0) { %>
                    ignore_bins illegal_cmstatus_IO_CACHE_AIU = binsof(cp_snooper_type.IO_CACHE_AIU) && !binsof(cp_cmstatus) intersect {6'b000000, 6'b100000, 6'b100010, 6'b110000, 6'b110010};
            <%  } %>
        }
    <% if (acelite_e_present != 0) {
               if(chi_b_present != 0) { %>

        //-------------------------------------------------
        // WrStshFull-SnpInvStsh snprsps from stash target
        //#Cover.DCE.WrStshFull.StshTgt.SnpRsp_CMStatus
        //-------------------------------------------------
        cx_wrstshfull_snprsp_stshtgt: cross cp_cmd_type, cp_stash_tgt, cp_cmstatus iff (cmd_type == CMD_WR_STSH_FULL && stash_target == 1 ) {
            ignore_bins  peer_aiu       =  binsof(cp_stash_tgt.peer_aiu);
        ignore_bins not_wrstshfull = !binsof(cp_cmd_type.WrStshFull_SnpInvStsh);
            ignore_bins illegal_cmstatus = !binsof(cp_cmstatus) intersect {6'b000000, 6'b000001}; 
        }
    <%}%>
        //-------------------------------------------------
        // WrStshFull-SnpInvStsh snprsps from peer
        //#Cover.DCE.WrStshFull.Peer.SnpRsp_CMStatus
        //-------------------------------------------------
        cx_wrstshfull_snprsp_peer: cross cp_cmd_type, cp_snooper_type, cp_stash_tgt, cp_cmstatus iff (cmd_type == CMD_WR_STSH_FULL && stash_target == 0) {
            ignore_bins  peer_aiu       =  !binsof(cp_stash_tgt.peer_aiu);
        ignore_bins not_wrstshfull = !binsof(cp_cmd_type.WrStshFull_SnpInvStsh);
            <% if(chi_a_present != 0) { %>
                    ignore_bins illegal_cmstatus_CHI_A_AIU       = binsof(cp_snooper_type.CHI_A_AIU) && !binsof(cp_cmstatus) intersect {6'b000000};
            <%  } 
               if(chi_b_present != 0) { %>
                    ignore_bins illegal_cmstatus_CHI_B_AIU       = binsof(cp_snooper_type.CHI_B_AIU) && !binsof(cp_cmstatus) intersect {6'b000000};
            <%  } 
                if(ace_present != 0) { %>
                    ignore_bins illegal_cmstatus_ACE_AIU       = binsof(cp_snooper_type.ACE_AIU) && !binsof(cp_cmstatus) intersect {6'b000000};
            <%  }
                if(iocache_present != 0) { %>
                    ignore_bins illegal_cmstatus_IO_CACHE_AIU = binsof(cp_snooper_type.IO_CACHE_AIU) && !binsof(cp_cmstatus) intersect {6'b000000};
            <%  } %>
        }

              <% if(chi_b_present != 0) { %>
        //-------------------------------------------------
        // WrStshPtl-SnpUnqStsh snprsps from stash target
        //#Cover.DCE.WrStshPtl.StshTgt.SnpRsp_CMStatus
        //-------------------------------------------------
        cx_wrstshptl_snprsp_stshtgt: cross cp_cmd_type, cp_stash_tgt, cp_cmstatus iff (cmd_type == CMD_WR_STSH_PTL && stash_target == 1) {
            ignore_bins  peer_aiu       =  binsof(cp_stash_tgt.peer_aiu);
        ignore_bins not_wrstshptl = !binsof(cp_cmd_type.WrStshPtl_SnpUnqStsh);
            ignore_bins illegal_cmstatus = !binsof(cp_cmstatus) intersect {6'b000000, 6'b000001, 6'b000010, 6'b000011}; 
        }
        <%}%>
        //-------------------------------------------------
        // WrStshPtl-SnpUnqStsh snprsps from peer
        //#Cover.DCE.WrStshPtl.Peer.SnpRsp_CMStatus
        //-------------------------------------------------
        cx_wrstshptl_snprsp_peer: cross cp_cmd_type, cp_snooper_type,  cp_stash_tgt, cp_cmstatus iff (cmd_type == CMD_WR_STSH_PTL && stash_target == 0)  {
            ignore_bins  peer_aiu       =  !binsof(cp_stash_tgt.peer_aiu);
        ignore_bins not_wrstshptl = !binsof(cp_cmd_type.WrStshPtl_SnpUnqStsh);
            <% if(chi_a_present != 0) { %>
                    ignore_bins illegal_cmstatus_CHI_A_AIU       = binsof(cp_snooper_type.CHI_A_AIU) && !binsof(cp_cmstatus) intersect {6'b000000, 6'b000010};
            <%  } 
               if(chi_b_present != 0) { %>
                    ignore_bins illegal_cmstatus_CHI_B_AIU       = binsof(cp_snooper_type.CHI_B_AIU) && !binsof(cp_cmstatus) intersect {6'b000000, 6'b000010};
            <%  } 
                if(ace_present != 0) { %>
                    ignore_bins illegal_cmstatus_ACE_AIU       = binsof(cp_snooper_type.ACE_AIU) && !binsof(cp_cmstatus) intersect {6'b000000, 6'b000010};
            <%  }
                if(iocache_present != 0) { %>
                    ignore_bins illegal_cmstatus_IO_CACHE_AIU = binsof(cp_snooper_type.IO_CACHE_AIU) && !binsof(cp_cmstatus) intersect {6'b000000, 6'b000010};
            <%  }  %> 
        }

    <%} if (chi_b_present !=0) { %>
        //-------------------------------------------------
        // LdCchUnq-SnpStshUnq snprsps from stash target
        //-------------------------------------------------
        //#Cover.DCE.LdCchUnq.StshTgt.SnpRsps_CMStatus
        cx_ldcchunq_snprsp_stshtgt: cross cp_cmd_type, cp_stash_tgt, cp_cmstatus iff (cmd_type == CMD_LD_CCH_UNQ && stash_target == 1)  {
            ignore_bins  peer_aiu     =  binsof(cp_stash_tgt.peer_aiu);
            ignore_bins  not_ldcchunq =  !binsof(cp_cmd_type.LdCchUnq_SnpStshUnq);
            ignore_bins illegal_cmstatus = !binsof(cp_cmstatus) intersect {6'b000000, 6'b000001, 6'b100000, 6'b100001, 6'b110000, 6'b110001}; 
        }

        //-------------------------------------------------
        // LdCchUnq-SnpStshUnq snprsps from peer
        //-------------------------------------------------
        //#Cover.DCE.LdCchUnq.Peer.SnpRsps_CMStatus
        cx_ldcchunq_snprsp_peer: cross cp_cmd_type, cp_snooper_type,  cp_stash_tgt, cp_cmstatus iff (cmd_type == CMD_LD_CCH_UNQ && stash_target == 0)  {
            ignore_bins  stshtgt      =  binsof(cp_stash_tgt.stash_tgt);
            ignore_bins  not_ldcchunq =  !binsof(cp_cmd_type.LdCchUnq_SnpStshUnq);
            <% if(chi_b_present > 2) { %>
                    ignore_bins illegal_cmstatus_CHI_B_AIU       = binsof(cp_snooper_type.CHI_B_AIU) && !binsof(cp_cmstatus) intersect {6'b000000, 6'b000010};
            <%  } 
                else if (chi_b_present !=0) {%>
                    ignore_bins illegal_CHI_B_AIU       = binsof(cp_snooper_type.CHI_B_AIU);
            <%  } 
               if(chi_a_present != 0) { %>
                    ignore_bins illegal_cmstatus_CHI_A_AIU       = binsof(cp_snooper_type.CHI_A_AIU) && !binsof(cp_cmstatus) intersect {6'b000000, 6'b000010};
            <%  } 
                if(ace_present != 0) { %>
                    ignore_bins illegal_cmstatus_ACE_AIU       = binsof(cp_snooper_type.ACE_AIU) && !binsof(cp_cmstatus) intersect {6'b000000, 6'b000010};
            <%  }
                if(iocache_present != 0) { %>
                    ignore_bins illegal_cmstatus_IO_CACHE_AIU = binsof(cp_snooper_type.IO_CACHE_AIU) && !binsof(cp_cmstatus) intersect {6'b000000, 6'b000010};
            <%  } %>
        }
    
        //-------------------------------------------------
        // LdCchShd-SnpStshShd snprsps from stash target
        //-------------------------------------------------
        //#Cover.DCE.LdCchShd.StshTgt.SnpRsps_CMStatus
        cx_ldcchshd_snprsp_stshtgt: cross cp_cmd_type, cp_stash_tgt, cp_cmstatus iff (cmd_type == CMD_LD_CCH_SH && stash_target == 1)  {
            ignore_bins peer_aiu     =  binsof(cp_stash_tgt.peer_aiu);
            ignore_bins not_ldcchshd =  !binsof(cp_cmd_type.LdCchShd_SnpStshShd);
            ignore_bins illegal_cmstatus = !binsof(cp_cmstatus) intersect {6'b000000, 6'b000001, 6'b110000, 6'b100000, 6'b100001}; 
        }
        
        //-------------------------------------------------
        // LdCchShd-SnpStshShd snprsps from peer
        //-------------------------------------------------
        //#Cover.DCE.LdCchShd.Peer.SnpRsps_CMStatus
        cx_ldcchshd_snprsp_peer: cross cp_cmd_type, cp_snooper_type, cp_stash_tgt, cp_cmstatus iff (cmd_type == CMD_LD_CCH_SH && stash_target == 0)  {
            ignore_bins  stshtgt      =  binsof(cp_stash_tgt.stash_tgt);
            ignore_bins  not_ldcchshd =  !binsof(cp_cmd_type.LdCchShd_SnpStshShd);
            <% if(chi_b_present > 2) { %>
                    ignore_bins illegal_cmstatus_CHI_B_AIU       = binsof(cp_snooper_type.CHI_B_AIU) && !binsof(cp_cmstatus) intersect {6'b000000, 6'b000010, 6'b110000, 6'b110010, 6'b100010};
            <%  }
                else if (chi_b_present != 0){%>
                    ignore_bins illegal_CHI_B_AIU            = binsof(cp_snooper_type.CHI_B_AIU);
            <%  } 
               if(chi_a_present != 0) { %>
                    ignore_bins illegal_cmstatus_CHI_A_AIU       = binsof(cp_snooper_type.CHI_A_AIU) && !binsof(cp_cmstatus) intersect {6'b000000, 6'b000010, 6'b110000, 6'b110010, 6'b100010};
            <%  }
                if(ace_present != 0) { %>
                    ignore_bins illegal_cmstatus_ACE_AIU       = binsof(cp_snooper_type.ACE_AIU) && !binsof(cp_cmstatus) intersect {6'b000000, 6'b000010};
            <%  }
                if(iocache_present != 0) { %>
                    ignore_bins illegal_cmstatus_IO_CACHE_AIU = binsof(cp_snooper_type.IO_CACHE_AIU) && !binsof(cp_cmstatus) intersect {6'b000000, 6'b110000, 6'b100010};
            <%  } %>
        }
    <%}%>
    endgroup: cg_snprsp

    covergroup cg_credits with function sample(bit snp_n_mrd, int available_credits);

        //#Cover.DCE.SnpReq.CreditCounterEqualsZero
        cp_snp_credits: coverpoint available_credits iff (snp_n_mrd == 1) {
<%          var i; var j = 0;
            if(obj.DceInfo[0].nAttCtrlEntries <= obj.DceInfo[0].nSnpsPerAiu){
                j = obj.DceInfo[0].nSnpsPerAiu-obj.DceInfo[0].nAttCtrlEntries + 2
            }
            for (i = j; i <= obj.DceInfo[0].nSnpsPerAiu; i++) { %>
                bins cntr_<%=i%> = {<%=i%>}; <%}%>  
        }

        //#Cover.DCE.MrdReq.CreditCounterEqualsZero
        cp_mrd_credits: coverpoint available_credits iff (snp_n_mrd == 0) {
<%          var i;
            var j = 0;
            if(obj.DceInfo[0].nAttCtrlEntries < 32) {
                j = obj.DceInfo[0].nAttCtrlEntries;
            }
            else {
                j = 0;
            }
            for (i = j; i <= 30; i++) { %>
                bins cntr_<%=i%> = {<%=i%>}; <%}%>  
        }
        
    endgroup: cg_credits

    covergroup cg_scm_state with function sample(int dmiid, int counter_state);
    
    //#Cover.DCE.SCM.dmi_ids
    cp_dmi_id: coverpoint dmiid {
    <% for(var i = 0; i < obj.DceInfo[obj.Id].nDmis; i++) { %>
        bins dmi_<%=obj.DmiInfo[i].FUnitId%>    = {<%=obj.DmiInfo[i].FUnitId%>};
    <%}%>
    }

    //#Cover.DCE.SCM.CCRCounterState
    cp_counter_state: coverpoint counter_state {
        bins Normal_operation   = {3'b000};
        bins Empty      = {3'b001};
        bins Full       = {3'b100};
        bins Negative       = {3'b010};
        bins No_Connection  = {3'b111};
        <%if(obj.DceInfo[obj.Id].hexDceConnectedDmiFunitId.length == obj.DceInfo[obj.Id].nDmis){%>
        ignore_bins all_dmis_connected = {3'b111};
        <%}%>
    }

    //#Cover.DCE.SCM.IdsxStates
    cx_dmi_counter_state: cross cp_dmi_id, cp_counter_state {
        <%for(var i = 0; i < obj.DceInfo[obj.Id].nDmis; i++) {
        if(obj.DmiInfo[i].FUnitId == obj.DceInfo[obj.Id].hexDceConnectedDmiFunitId[i]){%>
        ignore_bins connected_dmi_<%=i%>    = binsof(cp_dmi_id.dmi_<%=obj.DceInfo[obj.Id].hexDceConnectedDmiFunitId[i]%>) && binsof(cp_counter_state.No_Connection);
        <%}
        else {%>
        ignore_bins unconnected_dmi_<%=i%>_ops  = binsof(cp_dmi_id.dmi_<%=obj.DmiInfo[i].FUnitId%>) && binsof(cp_counter_state.Normal_operation);
        ignore_bins unconnected_dmi_<%=i%>_emty = binsof(cp_dmi_id.dmi_<%=obj.DmiInfo[i].FUnitId%>) && binsof(cp_counter_state.Empty);
        ignore_bins unconnected_dmi_<%=i%>_full = binsof(cp_dmi_id.dmi_<%=obj.DmiInfo[i].FUnitId%>) && binsof(cp_counter_state.Full);
        ignore_bins unconnected_dmi_<%=i%>_neg  = binsof(cp_dmi_id.dmi_<%=obj.DmiInfo[i].FUnitId%>) && binsof(cp_counter_state.Negative);
        <%}
        }%>
    }
    endgroup: cg_scm_state

    //#Cover.DCE.v36.AddrHash
    covergroup cg_sf_access_v36 with function sample(int sf_id, int set_idx);
        <% var x = 0; %>
        <% obj.SnoopFilterInfo.forEach(function(bundle, indx, array) { %>
        cp_sf<%=x%>_setidx: coverpoint set_idx iff(sf_id == <%=x%>) {
            bins sf<%=x%>_idx[16] = {0, [1:<%=bundle.nSets%>-2], <%=bundle.nSets-1%>};
        }
        <% x = x+1; %>
        <% }) %>
    endgroup

    covergroup cg_rbid_updates_v36 with function sample(int rbid, int gid, int req0_rsp1, int internal_release);
        //#Cover.DCE.v36RBReq.NoRbRsp
        cp_rbid: coverpoint rbid {
            bins rbid_bins[<%=obj.DceInfo[0].nRbsPerDmi%>] = {[0:<%=obj.DceInfo[0].nRbsPerDmi%>-1]};
        }

        //#Cover.DCE.v36.RBReq.GID
        cp_gid: coverpoint gid {
            bins gid_bins[2] = {0,1};
        }

        cp_reqrsp: coverpoint req0_rsp1 {
            bins req = {0};
            bins rsp = {1};
        }

        //#Cover.DCE.v36.RBReq.InternalRelease
        cp_int_rls: coverpoint internal_release {
            bins int_rls[2] = {0,1};
        }

        cross_rbid_gid: cross cp_rbid, cp_gid;

        cross_gid_int_rls: cross cp_gid, cp_int_rls;

        cross_rbid_req_rsp: cross cp_rbid, cp_reqrsp;
    endgroup
    
    covergroup cg_rb_credits with function sample(req_type_e rb, int available_credits);
        cp_rb_credits: coverpoint available_credits {
        <% var i;
            var j = 0;
            if(obj.DceInfo[0].nAttCtrlEntries <= obj.DceInfo[0].nRbsPerDmi){
                j = obj.DceInfo[0].nRbsPerDmi-obj.DceInfo[0].nAttCtrlEntries + 2
            }
            for (i = j; i <= obj.DceInfo[0].nRbsPerDmi; i++) { %>
                bins cntr_<%=i%> = {<%=i%>}; <%}
            if(obj.DceInfo[0].nAttCtrlEntries <= obj.DceInfo[0].nRbsPerDmi){    
            for (i = 0; i < j; i++) { %>
                ignore_bins ignore_cntr_<%=i%> = {<%=i%>}; <%}
            }%> 
        }

        cp_rb_req_type: coverpoint rb {
            bins RB_RSV = {RB_RSV};
          // RBU deprecated for Ncore-3.6
          //bins RB_RLS = {RB_RLS};
          //bins RB_USE = {RB_USE};
        }
        
        //#Cover.DCE.RBReq.RBIDNotAvailable
        cx_rb_available_credits: cross cp_rb_req_type, cp_rb_credits {
            //After RB_RSV, available_credits != max_credits
            ignore_bins RB_RSV_max_credits  = binsof(cp_rb_req_type.RB_RSV) && binsof(cp_rb_credits.cntr_<%=obj.DceInfo[0].nRbsPerDmi%>); 
            <%if(obj.DceInfo[0].nAttCtrlEntries > obj.DceInfo[0].nRbsPerDmi){%>
          // RBU deprecated for Ncore-3.6
          //ignore_bins RB_RLS_zero_credits = binsof(cp_rb_req_type.RB_RLS) && binsof(cp_rb_credits.cntr_0); 
          //ignore_bins RB_USE_zero_credits = binsof(cp_rb_req_type.RB_USE) && binsof(cp_rb_credits.cntr_0); 
            <%}%>
        }
        
    endgroup: cg_rb_credits

    covergroup cg_exmon with function sample(int aiuid, int procid);
        cp_agentid: coverpoint aiuid {
        <%  obj.AiuInfo.forEach(function(bundle, idx, array) {
            if ((bundle.fnNativeInterface === "ACE") || (bundle.fnNativeInterface === "CHI-A") || (bundle.fnNativeInterface === "CHI-B")) {%>

                    bins aiuid_<%=idx%> = {<%=idx%>};
            <%  } 
            }) %>
        }

        cp_procid: coverpoint procid {
        <%  var j;
            j= 0;
            obj.AiuInfo.forEach(function(bundle, idx, array) {
            if ((bundle.fnNativeInterface === "ACE") || (bundle.fnNativeInterface === "CHI-A") || (bundle.fnNativeInterface === "CHI-B")) {
                var i;
                for(i=j; i<bundle.nProcs; i++) { %>
                    bins procid_<%=i%> = {<%=i%>};
            <%      } 
                } 
            j= i ;
            })
                 %>
        }
        
        //#Cover.DCE.ExMon.AiuidProcidPair
        cx_agentid_procid: cross cp_agentid, cp_procid{
        
        <% var i= 0;
           var j = 0;
            obj.AiuInfo.forEach(function(bundle, idx, array) {
            if ((bundle.fnNativeInterface === "ACE") || (bundle.fnNativeInterface === "CHI-A") || (bundle.fnNativeInterface === "CHI-B")) {
                for(i=j;i<bundle.nProcs;i++){
                
                } j = i; }})
            
            obj.AiuInfo.forEach(function(bundle, idx, array) {
                if ((bundle.fnNativeInterface === "ACE") || (bundle.fnNativeInterface === "CHI-A") || (bundle.fnNativeInterface === "CHI-B")) {
                    if(bundle.nProcs < j){%>
                        ignore_bins aiuid_<%=idx%>_proc = binsof(cp_agentid.aiuid_<%=idx%>) intersect{
                            <% var k; for(k = bundle.nProcs;k<(j-1);k++){%>
                                <%=k%>,<%}%> 
                                <%=(j-1)%>}; 
                        <%}
                }
            })%>
        }
        
        cp_exld_cmdtype: coverpoint exld_cmd_type {
            bins CMD_RD_CLN          = {eCmdRdCln}; 
            bins CMD_RD_NOT_SHD      = {eCmdRdNShD}; 
            bins CMD_RD_VLD          = {eCmdRdVld};  
        }

        cp_exmon_state_exld: coverpoint exmon_state {
            <%if(obj.DceInfo[0].nTaggedMonitors < caching_agents) {%>
            bins EXLD_NOMATCH_TMADDR_OTHER_TM_NOT_AVAILABLE          = {EXLD_NOMATCH_TMADDR_OTHER_TM_NOT_AVAILABLE};
            <%}
            if(obj.DceInfo[0].nTaggedMonitors!=0) {%>
            bins EXLD_NOMATCH_TMADDR_OTHER_TM_AVAILABLE              = {EXLD_NOMATCH_TMADDR_OTHER_TM_AVAILABLE};
            bins EXLD_MATCH_TMADDR                                   = {EXLD_MATCH_TMADDR};
            <%}%>
        }

        //#Cover.DCE.ExMon.ExStScenario
        cp_exmon_state_exst: coverpoint exmon_state {
            <%if(obj.DceInfo[0].nTaggedMonitors < caching_agents) {%>
            bins EXST_NOMATCH_TMADDR_NO_BMVLD_OTHER_TM_NOT_AVAILABLE = {EXST_NOMATCH_TMADDR_NO_BMVLD_OTHER_TM_NOT_AVAILABLE};
            <%}%>
            bins EXST_NOMATCH_TMADDR_BMVLD                           = {EXST_NOMATCH_TMADDR_BMVLD};
            <%if(obj.DceInfo[0].nTaggedMonitors!=0) {%>
            bins EXST_NOMATCH_TMADDR_NO_BMVLD_OTHER_TM_AVAILABLE     = {EXST_NOMATCH_TMADDR_NO_BMVLD_OTHER_TM_AVAILABLE};
            bins EXST_MATCH_TMADDR_NO_TMVLD                          = {EXST_MATCH_TMADDR_NO_TMVLD};
            bins EXST_MATCH_TMADDR_TMVLD                             = {EXST_MATCH_TMADDR_TMVLD};
            <%}%>
        }

        //#Cover.DCE.ExMon.ExLdScenario
        cx_exld_cmdtype_exmon_state: cross cp_exld_cmdtype, cp_exmon_state_exld;
    endgroup

    covergroup cg_dm with function sample(directory_mgr dirm);
    
    <%var victim_count = 0;
      var victim_present = 0;
      var victim_array = [];
        var index = 0;
        var sf_count = 0;
    obj.SnoopFilterInfo.forEach(function(bundle,indx, array) {
        index = index + indx; 
    });
    obj.SnoopFilterInfo.forEach(function(bundle,indx, array) {
        victim_array[indx] = bundle.nVictimEntries;
        victim_count = victim_count + bundle.nVictimEntries;
        sf_count++;
        }); 
    for(var i ; i < index;i++){
        if(victim_array[i] > 0)
            victim_present = victim_present + 1;
    }
    
        %>
    
        //#Cover.DCE.dm_lkprsp.mutiple_tag_hit
        cp_cmdreq_hit_mutiple_tagf : coverpoint dirm.obsrvd_tagf_hit_in_multiple_sf {
            bins hit = {1};
            <%if(sf_count < 2){%>
            ignore_bins bin_hit = {1};
            <%}%>
        }
        //#Cover.DCE.dm_lkprsp.mutiple_vb_hit
        cp_cmdreq_hit_mutiple_VB : coverpoint dirm.obsrvd_vctb_hit_in_multiple_sf {
            bins hit = {1};
            <%if(victim_present < 2){%>
            ignore_bins bin_hit = {1};
            <%}%>
        }
        //#Cover.DCE.dm_lkprsp.vb_hit_tag_hit
        cp_cmdreq_hit_tagf_VB : coverpoint dirm.obsrvd_vctb_hit_tagf_hit {
            bins hit = {1};
            <%if(victim_count == 0 || sf_count < 2){%>
            ignore_bins bin_hit = {1};
            <%}%>
        }
        //#Cover.DCE.dm_lkprsp.alloc_miss_vb_hit
        cp_cmdreq_alloc_miss_vb_hit : coverpoint dirm.obsrvd_alloc_miss_vb_hit {
            bins hit = {1};
            <%if(victim_count == 0 || sf_count < 2){%>
            ignore_bins bin_hit = {1};
            <%}%>
        }

    endgroup

<%  obj.SnoopFilterInfo.forEach(function(bundle, idx, array) {%>
    covergroup cg_sf_<%=idx%> with function sample (bit sf[string], int hit_swap_way, int alloc_evct_way);
        //#Cover.DCE.DM.UPDreq_COMP_RequestorOwner
        cp_updreq_hit_owner: coverpoint sf["updreq_hit_owner_updcomp"] {
            bins found = {1};
        }
        
        //#Cover.DCE.DM.UPDreq_COMP_RequestorSharer
        cp_updreq_hit_sharer: coverpoint sf["updreq_hit_sharer_updcomp"] {
            bins found = {1};
        }
         
        //#Check.DCE.DM.UPDreq_FAIL_SFMiss  
        cp_updreq_miss_updfail: coverpoint sf["updreq_miss_updfail"] {
            bins found = {1};
        }
    
        //#Check.DCE.DM.UPDreq_FAIL_SFHit
        cp_updreq_hit_updfail: coverpoint sf["updreq_hit_updfail"] {
            bins found = {1};
        }
    
        cp_home_filter: coverpoint sf["home_filter"] {
            bins hf     = {1};
            bins not_hf = {0};
        }
        
        cp_all_ways_busy: coverpoint sf["all_ways_busy"] {
            bins busy     = {1};
            bins not_busy = {0};
            <%if(obj.DceInfo[0].nAttCtrlEntries < bundle.nWays){%>
            ignore_bins ignore_busy = {1};
            <%}%>
        }

        cp_tagf_hit: coverpoint sf["tagf_hit"] {
            bins found = {1};   
        }
    
<%  if (bundle.nVictimEntries > 0) {  %>
        
        //#Cover.DCE.dm_vbhit
        cp_vctb_hit: coverpoint sf["vctb_hit"] {
            bins found = {1};   
        }
        
        //#Cover.DCE.dm_vbhit_hf_all_ways_busy
        //#Cover.DCE.dm_vbhit_nonhf_all_ways_busy
        cx_vctb_hit_homefilter_all_ways_busy: cross cp_vctb_hit, cp_home_filter, cp_all_ways_busy;
<% } %> 

        cp_alloc_miss: coverpoint sf["alloc_miss"] {
            bins found = {1};
        }
        
        //#Cover.DCE.dm_alloc_miss_all_ways_busy
        cx_alloc_miss_all_ways_busy: cross cp_alloc_miss, cp_all_ways_busy;

        //#Cover.DCE.dm_alloc_way
        cp_alloc_miss_way_num: coverpoint alloc_evct_way iff (sf["alloc_miss"] == 1) { 
<%          var i;
            for (i = 0; i < bundle.nWays; i++) { %>
                bins way_<%=i%> = {<%=i%>}; <%}%>   
        }
        
        cp_tagf_hit_way_num: coverpoint hit_swap_way iff (sf["tagf_hit"] == 1) { 
<%          var i;
            for (i = 0; i < bundle.nWays; i++) { %>
                bins way_<%=i%> = {<%=i%>}; <%}%>   
        }
        
<%  if (bundle.nVictimEntries > 0) {  %>
        //#Cover.DCE.dm_vbhit_swap_way
        cp_vctb_swap_way_num: coverpoint hit_swap_way iff (sf["vctb_hit"] == 1) { 
<%          var i;
            for (i = 0; i < bundle.nWays; i++) { %>
                bins way_<%=i%> = {<%=i%>}; <%}%>   
        }
<% } %> 

        //#Cover.DCE.dm_recall_req_from_each_sf
        cp_recreq: coverpoint sf["recreq"] {
            bins found = {1};
        }

    endgroup: cg_sf_<%=idx%>
<%      })%>

<%  obj.SnoopFilterInfo.forEach(function(bundle, idx, array) {%>
  <%if(obj.DceInfo[0].nAttCtrlEntries > bundle.nWays){%> //CONC-16596::Disable::If the nAttEntries in a config are less than nWays of that SF, the condition of all ways busy can never be achieved thus never generating retry reeqs/rsps
    covergroup cg_rtyrsp_sf_<%=idx%> with function sample (bit sf[string], int hit_swap_way, int alloc_evct_way);
        cp_home_filter: coverpoint sf["home_filter"] {
            bins hf     = {1};
            bins not_hf = {0};
        }
        
        cp_all_ways_busy: coverpoint sf["all_ways_busy"] {
            bins busy     = {1};
            bins not_busy = {0};
            <%if(obj.DceInfo[0].nAttCtrlEntries < bundle.nWays){%>
            ignore_bins ignore_busy = {1};
            <%}%>
        }
        /*
        cp_tagf_hit: coverpoint sf["tagf_hit"] {
            bins found = {1};   
        } */
    
    <%  if (bundle.nVictimEntries > 0) {  %>
        cp_vctb_hit: coverpoint sf["vctb_hit"] {
            bins found = {1};   
        }
        
        //#Cover.DCE.dm_vbhit_hf_all_ways_busy
        //#Cover.DCE.dm_vbhit_nonhf_all_ways_busy
        cx_vctb_hit_homefilter_all_ways_busy: cross cp_vctb_hit, cp_home_filter, cp_all_ways_busy{
        <%if(obj.SnoopFilterInfo.length == 1){%>
            ignore_bins notbusy = binsof(cp_all_ways_busy.not_busy);
        <%}%>

        }
    <% } %>

        cp_alloc_miss: coverpoint sf["alloc_miss"] {
            bins found = {1};
        }
        
        //#Cover.DCE.dm_alloc_miss_all_ways_busy
        cx_alloc_miss_all_ways_busy: cross cp_alloc_miss, cp_all_ways_busy;

    endgroup: cg_rtyrsp_sf_<%=idx%>
  <%}%>
<%})%>

<%if (obj.DceInfo[0].fnEnableQos == 1) {%>
    covergroup cg_qoscr_et with function sample(int qoscr_et);
    
    //#Cover.DCE.QOS.qoscr_event_threshold
    
    cp_qoscr_et: coverpoint qoscr_et{
            <% var i;
                for(i =0; i<=16; i++){%>
                bins qoscr_et_<%=i%> = {<%=i%>}; <%}%>

        } 
     
    endgroup: cg_qoscr_et<%}%>

    covergroup cg_mrd_req with function sample(bit alloc, addrMgrConst::interface_t inf);

         cp_lkprsp_non_stash: coverpoint dm_state_on_lkp_e iff (cmdreq.smi_msg_type != CMD_LD_CCH_SH || cmdreq.smi_msg_type != CMD_LD_CCH_UNQ) {
            bins dm_miss                                                    = {0};
            bins dm_hit_as_owner_and_other_sharers_absent                   = {1};
    <% if (caching_agents > 1) { %>
            bins dm_hit_as_owner_and_other_sharers_present                  = {2};
    <%}%>
            bins dm_hit_as_sharer_and_owner_absent_other_sharers_absent     = {3};
    <% if (caching_agents > 1) { %>
            bins dm_hit_as_sharer_and_owner_absent_other_sharers_present    = {4};
            bins dm_hit_as_sharer_and_owner_present_other_sharers_absent    = {5};
    <%}
       if (caching_agents > 2) { %>
            bins dm_hit_as_sharer_and_owner_present_other_sharers_present   = {6};
    <%}%>
            bins dm_hit_as_neither_and_owner_absent_other_sharers_present   = {7};
            bins dm_hit_as_neither_and_owner_present_other_sharers_absent   = {8};
    <% if (caching_agents > 2) { %>
            bins dm_hit_as_neither_and_owner_present_other_sharers_present  = {9};
    <%}%>
        }
    
    <% if (chi_b_present !=0) { %>
    cp_lkprsp_stash: coverpoint dm_state_on_lkp_stash iff (cmdreq.smi_msg_type == CMD_LD_CCH_SH || cmdreq.smi_msg_type == CMD_LD_CCH_UNQ) {
            bins dm_miss_stash                                                 = {1};
            bins dm_hit_trgt_as_neither_and_owner_present_other_sharers_absent = {2};
            bins dm_hit_trgt_as_neither_and_owner_absent_other_sharers_present = {3};
    <% if (caching_agents > 1) { %>
            bins dm_hit_trgt_as_neither_and_owner_present_other_sharers_present= {4};
    <%}%>
            bins dm_hit_trgt_as_owner_and_other_sharers_absent                 = {5};
            bins dm_hit_trgt_as_sharer_and_owner_absent_other_sharers_absent   = {6};
    <% if (caching_agents > 1) { %>
            bins dm_hit_trgt_as_sharer_and_owner_absent_other_sharers_present  = {7};
            bins dm_hit_trgt_as_sharer_and_owner_present_other_sharers_absent  = {8};
    <%}
       if (caching_agents > 2) { %>
            bins dm_hit_trgt_as_sharer_and_owner_present_other_sharers_present = {9};
    <%}
       if (caching_agents > 1) { %>
            bins dm_hit_trgt_as_owner_and_other_sharers_present                = {10};
    <%}%>

        }
    <%} %>

    cp_iid_type: coverpoint inf iff (cmdreq.smi_msg_type != CMD_LD_CCH_SH || cmdreq.smi_msg_type != CMD_LD_CCH_UNQ) {
            <%  if(ace_present != 0) { %>
                    bins ACE_AIU = {addrMgrConst::ACE_AIU};
            <%  }
                if(chi_a_present != 0) { %>
                    bins CHI_A_AIU = {addrMgrConst::CHI_A_AIU};
            <%  } 
                if(chi_b_present != 0) { %>
                    bins CHI_B_AIU = {addrMgrConst::CHI_B_AIU};
            <%  } 
                if(iocache_present != 0) { %>
                    bins IO_CACHE_AIU = {addrMgrConst::IO_CACHE_AIU};
            <%  }
                if(axi_present != 0) { %>
                    bins AXI_AIU = {addrMgrConst::AXI_AIU};
            <%  } 
                if(acelite_present != 0) { %>
                    bins ACE_LITE_AIU = {addrMgrConst::ACE_LITE_AIU};
            <%  } 
                if(acelite_e_present != 0) { %>
                    bins ACE_LITE_E_AIU = {addrMgrConst::ACE_LITE_E_AIU};
            <%  } %>
    }
    <% if (chi_b_present !=0 || acelite_e_present !=0) { %>
    cp_stash_iid_type: coverpoint inf iff (cmdreq.smi_msg_type == CMD_LD_CCH_SH || cmdreq.smi_msg_type == CMD_LD_CCH_UNQ) {
    <%  if(chi_b_present != 0) { %>
                    bins CHI_B_AIU = {addrMgrConst::CHI_B_AIU};
            <%  } 
        if(acelite_e_present != 0) { %>
                    bins ACE_LITE_E_AIU = {addrMgrConst::ACE_LITE_E_AIU};
            <%  } %>
    }
    <%} %>

        cp_cmd_type: coverpoint cmdreq.smi_msg_type iff (cmdreq.smi_msg_type != CMD_LD_CCH_SH || cmdreq.smi_msg_type != CMD_LD_CCH_UNQ) {
            bins CMD_RD_CLN          = {8'b00000001};  //0x01
            bins CMD_RD_NOT_SHD      = {8'b00000010};  //0x02
            bins CMD_RD_VLD          = {8'b00000011};  //0x03
            bins CMD_RD_UNQ          = {8'b00000100};  //0x04
            bins CMD_RD_NITC         = {8'b00000111};  //0x07
    }
    
    
    <% if (chi_b_present !=0 || acelite_e_present !=0) { %>
    cp_stash_type: coverpoint cmdreq.smi_msg_type iff (cmdreq.smi_msg_type == CMD_LD_CCH_SH || cmdreq.smi_msg_type == CMD_LD_CCH_UNQ) {
        
        bins CMD_LD_CCH_SH       = {8'b00100100};  //0x24
                bins CMD_LD_CCH_UNQ      = {8'b00100101};  //0x25
    }
    <%} %>
    
    cp_mrd_type: coverpoint mrdreq.smi_msg_type iff (cmdreq.smi_msg_type != CMD_LD_CCH_SH || cmdreq.smi_msg_type != CMD_LD_CCH_UNQ) {
        bins MrdRdClnWU     = {eMsgMRD'(MRD_RD_WITH_UNQ_CLN)};
        bins MrdRdWU        = {eMsgMRD'(MRD_RD_WITH_UNQ)};
        bins MrdRdWINV      = {eMsgMRD'(MRD_RD_WITH_INV)};
        bins MrdRdClnWS     = {eMsgMRD'(MRD_RD_WITH_SHR_CLN)};
    }
    
    <% if (chi_b_present !=0 || acelite_e_present !=0) { %>
    cp_mrd_stash_type: coverpoint mrdreq.smi_msg_type iff (cmdreq.smi_msg_type == CMD_LD_CCH_SH || cmdreq.smi_msg_type == CMD_LD_CCH_UNQ){
        
    <% if (chi_b_present !=0 ) { %>
        bins MrdRdClnWU     = {eMsgMRD'(MRD_RD_WITH_UNQ_CLN)};
        bins MrdRdClnWS     = {eMsgMRD'(MRD_RD_WITH_SHR_CLN)};
        <%}%>
        bins MrdPrefetch    = {eMsgMRD'(MRD_PREF)}; 
    }
    <%} %>
    //#Cover.DCE.MrdReq.dm_miss
    
    cx_dm_miss: cross cp_cmd_type, cp_iid_type, cp_mrd_type iff ((dm_state_on_lkp_e == 0) && (cmdreq.smi_msg_type != CMD_LD_CCH_SH || cmdreq.smi_msg_type != CMD_LD_CCH_UNQ)) {

        ignore_bins illegal_bins_vld_cln_notshddirty    = binsof(cp_cmd_type) intersect {CMD_RD_VLD,CMD_RD_CLN,CMD_RD_NOT_SHD} && !binsof(cp_mrd_type.MrdRdClnWU);
        ignore_bins illegal_bins_rdunq          = binsof(cp_cmd_type.CMD_RD_UNQ) && !binsof(cp_mrd_type.MrdRdWU);
        ignore_bins illegal_bins_rdnitc         = binsof(cp_cmd_type.CMD_RD_NITC) && !binsof(cp_mrd_type.MrdRdWINV);
        ignore_bins illegal_cmds_from_nc_agents     = binsof(cp_iid_type) intersect {addrMgrConst::AXI_AIU, addrMgrConst::ACE_LITE_AIU, addrMgrConst::ACE_LITE_E_AIU} &&
                                        binsof(cp_cmd_type) intersect {CMD_RD_CLN, CMD_RD_VLD, CMD_RD_NOT_SHD, CMD_RD_UNQ};
        ignore_bins illegal_cmds_from_proxycache    = binsof(cp_iid_type) intersect {addrMgrConst::IO_CACHE_AIU} &&
                                        !binsof(cp_cmd_type) intersect {CMD_RD_NITC, CMD_RD_VLD, CMD_RD_UNQ};
    }

    //#Cover.DCE.MrdReq.dm_hit_iid_inv_owner_absent_other_sharers_present

    cx_dm_hit_iid_inv_owner_absent_other_sharers_present: cross cp_cmd_type, cp_iid_type, cp_mrd_type iff ((dm_state_on_lkp_e == 7) && (cmdreq.smi_msg_type != CMD_LD_CCH_SH || cmdreq.smi_msg_type != CMD_LD_CCH_UNQ)) {

        ignore_bins illegal_bins_vld_cln_notshddirty    = binsof(cp_cmd_type) intersect {CMD_RD_VLD,CMD_RD_CLN,CMD_RD_NOT_SHD} && !binsof(cp_mrd_type) intersect {eMsgMRD'(MRD_RD_WITH_SHR_CLN), eMsgMRD'(MRD_RD_WITH_UNQ_CLN)};
        ignore_bins illegal_bins_rdunq          = binsof(cp_cmd_type.CMD_RD_UNQ) && !binsof(cp_mrd_type.MrdRdWU);
        ignore_bins illegal_bins_rdnitc         = binsof(cp_cmd_type.CMD_RD_NITC) && !binsof(cp_mrd_type.MrdRdWINV);
        
        ignore_bins illegal_cmds_from_nc_agents     = binsof(cp_iid_type) intersect {addrMgrConst::AXI_AIU, addrMgrConst::ACE_LITE_AIU, addrMgrConst::ACE_LITE_E_AIU} &&
                                        binsof(cp_cmd_type) intersect {CMD_RD_CLN, CMD_RD_VLD, CMD_RD_NOT_SHD, CMD_RD_UNQ};
        ignore_bins illegal_cmds_from_proxycache    = binsof(cp_iid_type) intersect {addrMgrConst::IO_CACHE_AIU} &&
                                        !binsof(cp_cmd_type) intersect {CMD_RD_NITC, CMD_RD_VLD, CMD_RD_UNQ};
    <% if (caching_agents <= 1) { %>
        ignore_bins illegal_bins_non_rdnitc     = !binsof(cp_cmd_type) intersect {CMD_RD_NITC};
        ignore_bins illegal_bins_rdnitc_coherent_aiu    = binsof(cp_cmd_type) intersect {CMD_RD_NITC} && !binsof(cp_iid_type) intersect {addrMgrConst::AXI_AIU, addrMgrConst::ACE_LITE_AIU, addrMgrConst::ACE_LITE_E_AIU};
        <%}%>
    }

    //#Cover.DCE.MrdReq.dm_hit_iid_inv_owner_present_other_sharers_absent

    cx_dm_hit_iid_inv_owner_present_other_sharers_absent: cross cp_cmd_type, cp_iid_type, cp_mrd_type iff ((dm_state_on_lkp_e == 8) && (cmdreq.smi_msg_type != CMD_LD_CCH_SH || cmdreq.smi_msg_type != CMD_LD_CCH_UNQ)) {

        ignore_bins illegal_bins_vld_cln_notshddirty    = binsof(cp_cmd_type) intersect {CMD_RD_VLD,CMD_RD_CLN,CMD_RD_NOT_SHD} && 
                                    !binsof(cp_mrd_type) intersect {eMsgMRD'(MRD_RD_WITH_UNQ_CLN),eMsgMRD'(MRD_RD_WITH_SHR_CLN)};
        ignore_bins illegal_bins_rdunq          = binsof(cp_cmd_type.CMD_RD_UNQ) && !binsof(cp_mrd_type.MrdRdWU);
        ignore_bins illegal_bins_rdnitc         = binsof(cp_cmd_type.CMD_RD_NITC) && !binsof(cp_mrd_type.MrdRdWINV);
        
        ignore_bins illegal_cmds_from_nc_agents     = binsof(cp_iid_type) intersect {addrMgrConst::AXI_AIU, addrMgrConst::ACE_LITE_AIU, addrMgrConst::ACE_LITE_E_AIU} &&
                                        binsof(cp_cmd_type) intersect {CMD_RD_CLN, CMD_RD_VLD, CMD_RD_NOT_SHD, CMD_RD_UNQ};
        ignore_bins illegal_cmds_from_proxycache    = binsof(cp_iid_type) intersect {addrMgrConst::IO_CACHE_AIU} &&
                                        !binsof(cp_cmd_type) intersect {CMD_RD_NITC, CMD_RD_VLD, CMD_RD_UNQ};
    <% if (caching_agents <=1) { %>
        ignore_bins illegal_bins_non_rdnitc     = !binsof(cp_cmd_type) intersect {CMD_RD_NITC};
        ignore_bins illegal_bins_rdnitc_coherent_aiu    = binsof(cp_cmd_type) intersect {CMD_RD_NITC} && !binsof(cp_iid_type) intersect {addrMgrConst::AXI_AIU, addrMgrConst::ACE_LITE_AIU, addrMgrConst::ACE_LITE_E_AIU};
        <%}%>
    }
    
    <% if (caching_agents > 2) { %>
    //#Cover.DCE.MrdReq.dm_hit_iid_inv_owner_present_other_sharers_present

    cx_dm_hit_iid_inv_owner_present_other_sharers_present: cross cp_cmd_type, cp_iid_type, cp_mrd_type iff ((dm_state_on_lkp_e == 9) && (cmdreq.smi_msg_type != CMD_LD_CCH_SH || cmdreq.smi_msg_type != CMD_LD_CCH_UNQ)) {

        ignore_bins illegal_bins_vld_cln_notshddirty    = binsof(cp_cmd_type) intersect {CMD_RD_VLD,CMD_RD_CLN,CMD_RD_NOT_SHD} && !binsof(cp_mrd_type.MrdRdClnWS);
        ignore_bins illegal_bins_rdunq          = binsof(cp_cmd_type.CMD_RD_UNQ) && !binsof(cp_mrd_type.MrdRdWU);
        ignore_bins illegal_bins_rdnitc         = binsof(cp_cmd_type.CMD_RD_NITC) && !binsof(cp_mrd_type.MrdRdWINV);
        
        ignore_bins illegal_cmds_from_nc_agents     = binsof(cp_iid_type) intersect {addrMgrConst::AXI_AIU, addrMgrConst::ACE_LITE_AIU, addrMgrConst::ACE_LITE_E_AIU} &&
                                        binsof(cp_cmd_type) intersect {CMD_RD_CLN, CMD_RD_VLD, CMD_RD_NOT_SHD, CMD_RD_UNQ};
        ignore_bins illegal_cmds_from_proxycache    = binsof(cp_iid_type) intersect {addrMgrConst::IO_CACHE_AIU} &&
                                        !binsof(cp_cmd_type) intersect {CMD_RD_NITC, CMD_RD_VLD, CMD_RD_UNQ};
        ignore_bins illegal_bins_non_rdunq      = !binsof(cp_cmd_type) intersect {CMD_RD_UNQ};
    }
    <%}%>   
    //#Cover.DCE.MrdReq.dm_hit_iid_sharer_owner_absent_sharers_absent

    cx_dm_hit_iid_sharer_owner_absent_sharers_absent: cross cp_cmd_type, cp_iid_type, cp_mrd_type iff ((dm_state_on_lkp_e == 3) && (cmdreq.smi_msg_type != CMD_LD_CCH_SH || cmdreq.smi_msg_type != CMD_LD_CCH_UNQ )) {

        ignore_bins illegal_bins_vld_cln_notshddirty    = binsof(cp_cmd_type) intersect {CMD_RD_VLD,CMD_RD_CLN,CMD_RD_NOT_SHD} && !binsof(cp_mrd_type) intersect {eMsgMRD'(MRD_RD_WITH_SHR_CLN), eMsgMRD'(MRD_RD_WITH_UNQ_CLN)};
        ignore_bins illegal_bins_rdunq          = binsof(cp_cmd_type.CMD_RD_UNQ) && !binsof(cp_mrd_type.MrdRdWU);
        ignore_bins illegal_bins_rdnitc         = binsof(cp_cmd_type.CMD_RD_NITC) && !binsof(cp_mrd_type.MrdRdClnWU) && 
                                    binsof(cp_iid_type) intersect {addrMgrConst::ACE_AIU};
        ignore_bins illegal_bins_rdnitc_aiu     = binsof(cp_cmd_type.CMD_RD_NITC) && !binsof(cp_mrd_type.MrdRdWINV) && 
                                    !binsof(cp_iid_type) intersect {addrMgrConst::ACE_AIU};
        
        ignore_bins illegal_cmds_from_nc_agents     = binsof(cp_iid_type) intersect {addrMgrConst::AXI_AIU, addrMgrConst::ACE_LITE_AIU, addrMgrConst::ACE_LITE_E_AIU} &&
                                        binsof(cp_cmd_type) intersect {CMD_RD_CLN, CMD_RD_VLD, CMD_RD_NOT_SHD, CMD_RD_UNQ};
        ignore_bins illegal_cmds_from_proxycache    = binsof(cp_iid_type) intersect {addrMgrConst::IO_CACHE_AIU} &&
                                        !binsof(cp_cmd_type) intersect {CMD_RD_NITC, CMD_RD_VLD, CMD_RD_UNQ};
        ignore_bins illegal_state_from_nc_agents    = binsof(cp_iid_type) intersect {addrMgrConst::AXI_AIU, addrMgrConst::ACE_LITE_AIU, addrMgrConst::ACE_LITE_E_AIU};
        ignore_bins illegal_proxycache_RD_NITC_from_owner_state = binsof(cp_cmd_type.CMD_RD_NITC) && binsof(cp_iid_type) intersect {addrMgrConst::IO_CACHE_AIU};
    }
    
    <% if (caching_agents > 1) { %>
    //#Cover.DCE.MrdReq.dm_hit_iid_sharer_owner_absent_sharers_present

    cx_dm_hit_iid_sharer_owner_absent_sharers_present: cross cp_cmd_type, cp_iid_type, cp_mrd_type iff ((dm_state_on_lkp_e == 4) && (cmdreq.smi_msg_type != CMD_LD_CCH_SH || cmdreq.smi_msg_type != CMD_LD_CCH_UNQ)) {

        ignore_bins illegal_bins_vld_cln_notshddirty    = binsof(cp_cmd_type) intersect {CMD_RD_VLD,CMD_RD_CLN,CMD_RD_NOT_SHD} && !binsof(cp_mrd_type.MrdRdClnWS);
        ignore_bins illegal_bins_rdunq          = binsof(cp_cmd_type.CMD_RD_UNQ) && !binsof(cp_mrd_type.MrdRdWU);
        ignore_bins illegal_bins_rdnitc         = binsof(cp_cmd_type.CMD_RD_NITC) && !binsof(cp_mrd_type.MrdRdClnWS) && 
                                    binsof(cp_iid_type) intersect {addrMgrConst::ACE_AIU};
        ignore_bins illegal_bins_rdnitc_aiu     = binsof(cp_cmd_type.CMD_RD_NITC) && !binsof(cp_mrd_type.MrdRdWINV) && 
                                    !binsof(cp_iid_type) intersect {addrMgrConst::ACE_AIU};
        
        ignore_bins illegal_cmds_from_nc_agents     = binsof(cp_iid_type) intersect {addrMgrConst::AXI_AIU, addrMgrConst::ACE_LITE_AIU, addrMgrConst::ACE_LITE_E_AIU} &&
                                        binsof(cp_cmd_type) intersect {CMD_RD_CLN, CMD_RD_VLD, CMD_RD_NOT_SHD, CMD_RD_UNQ};
        ignore_bins illegal_cmds_from_proxycache    = binsof(cp_iid_type) intersect {addrMgrConst::IO_CACHE_AIU} &&
                                        !binsof(cp_cmd_type) intersect {CMD_RD_NITC, CMD_RD_VLD, CMD_RD_UNQ};
        ignore_bins illegal_state_from_nc_agents    = binsof(cp_iid_type) intersect {addrMgrConst::AXI_AIU, addrMgrConst::ACE_LITE_AIU, addrMgrConst::ACE_LITE_E_AIU};
    }

    //#Cover.DCE.MrdReq.dm_hit_iid_sharer_owner_present_sharers_absent

    cx_dm_hit_iid_sharer_owner_present_sharers_absent: cross cp_cmd_type, cp_iid_type, cp_mrd_type iff ((dm_state_on_lkp_e == 5) && (cmdreq.smi_msg_type != CMD_LD_CCH_SH || cmdreq.smi_msg_type != CMD_LD_CCH_UNQ)) {

        ignore_bins illegal_bins_vld_cln_notshddirty    = binsof(cp_cmd_type) intersect {CMD_RD_VLD,CMD_RD_CLN,CMD_RD_NOT_SHD} && 
                                    !binsof(cp_mrd_type) intersect {eMsgMRD'(MRD_RD_WITH_UNQ_CLN), eMsgMRD'(MRD_RD_WITH_SHR_CLN)};
        ignore_bins illegal_bins_rdunq          = binsof(cp_cmd_type.CMD_RD_UNQ) && !binsof(cp_mrd_type.MrdRdWU);
        ignore_bins illegal_bins_rdnitc         = binsof(cp_cmd_type.CMD_RD_NITC) && 
                                    !binsof(cp_mrd_type) intersect {eMsgMRD'(MRD_RD_WITH_UNQ_CLN), eMsgMRD'(MRD_RD_WITH_SHR_CLN)} && 
                                    binsof(cp_iid_type) intersect {addrMgrConst::ACE_AIU};
        ignore_bins illegal_bins_rdnitc_aiu     = binsof(cp_cmd_type.CMD_RD_NITC) && !binsof(cp_mrd_type.MrdRdWINV) && 
                                    !binsof(cp_iid_type) intersect {addrMgrConst::ACE_AIU};
        
        ignore_bins illegal_cmds_from_nc_agents     = binsof(cp_iid_type) intersect {addrMgrConst::AXI_AIU, addrMgrConst::ACE_LITE_AIU, addrMgrConst::ACE_LITE_E_AIU} &&
                                        binsof(cp_cmd_type) intersect {CMD_RD_CLN, CMD_RD_VLD, CMD_RD_NOT_SHD, CMD_RD_UNQ};
        ignore_bins illegal_cmds_from_proxycache    = binsof(cp_iid_type) intersect {addrMgrConst::IO_CACHE_AIU} &&
                                        !binsof(cp_cmd_type) intersect {CMD_RD_NITC, CMD_RD_VLD, CMD_RD_UNQ};
        ignore_bins illegal_state_from_nc_agents    = binsof(cp_iid_type) intersect {addrMgrConst::AXI_AIU, addrMgrConst::ACE_LITE_AIU, addrMgrConst::ACE_LITE_E_AIU};
        ignore_bins illegal_cmd_type            = binsof(cp_cmd_type);
        ignore_bins illegal_iid_type            = binsof(cp_iid_type);
        ignore_bins illegal_mrd_type            = binsof(cp_mrd_type);
    }

    
    <%}%>
    //#Cover.DCE.MrdReq.dm_hit_iid_sharer_owner_present_sharers_present
    <% if (caching_agents > 2) { %>

    cx_dm_hit_iid_sharer_owner_present_sharers_present: cross cp_cmd_type, cp_iid_type, cp_mrd_type iff ((dm_state_on_lkp_e == 6) && (cmdreq.smi_msg_type != CMD_LD_CCH_SH || cmdreq.smi_msg_type != CMD_LD_CCH_UNQ)) {

        ignore_bins illegal_bins_vld_cln_notshddirty    = binsof(cp_cmd_type) intersect {CMD_RD_VLD,CMD_RD_CLN,CMD_RD_NOT_SHD} && !binsof(cp_mrd_type.MrdRdClnWS);
        ignore_bins illegal_bins_rdunq          = binsof(cp_cmd_type.CMD_RD_UNQ) && !binsof(cp_mrd_type.MrdRdWU);
        ignore_bins illegal_bins_rdnitc         = binsof(cp_cmd_type.CMD_RD_NITC) && !binsof(cp_mrd_type.MrdRdClnWS) && 
                                    binsof(cp_iid_type) intersect {addrMgrConst::ACE_AIU};
        ignore_bins illegal_bins_rdnitc_aiu     = binsof(cp_cmd_type.CMD_RD_NITC) && !binsof(cp_mrd_type.MrdRdWINV) && 
                                    !binsof(cp_iid_type) intersect {addrMgrConst::ACE_AIU};
        
        ignore_bins illegal_cmds_from_nc_agents     = binsof(cp_iid_type) intersect {addrMgrConst::AXI_AIU, addrMgrConst::ACE_LITE_AIU, addrMgrConst::ACE_LITE_E_AIU} &&
                                        binsof(cp_cmd_type) intersect {CMD_RD_CLN, CMD_RD_VLD, CMD_RD_NOT_SHD, CMD_RD_UNQ};
        ignore_bins illegal_cmds_from_proxycache    = binsof(cp_iid_type) intersect {addrMgrConst::IO_CACHE_AIU} &&
                                        !binsof(cp_cmd_type) intersect {CMD_RD_NITC, CMD_RD_VLD, CMD_RD_UNQ};
        ignore_bins illegal_state_from_nc_agents    = binsof(cp_iid_type) intersect {addrMgrConst::AXI_AIU, addrMgrConst::ACE_LITE_AIU, addrMgrConst::ACE_LITE_E_AIU};
        ignore_bins illegal_cmd_type            = binsof(cp_cmd_type);
        ignore_bins illegal_iid_type            = binsof(cp_iid_type);
        ignore_bins illegal_mrd_type            = binsof(cp_mrd_type);
    }
    <%}%>
    //#Cover.DCE.MrdReq.dm_hit_iid_owner_other_sharers_absent

    cx_dm_hit_iid_owner_sharers_absent: cross cp_cmd_type, cp_iid_type, cp_mrd_type iff ((dm_state_on_lkp_e == 1) && (cmdreq.smi_msg_type != CMD_LD_CCH_SH || cmdreq.smi_msg_type != CMD_LD_CCH_UNQ)) {

        ignore_bins illegal_bins_vld_cln_notshddirty    = binsof(cp_cmd_type) intersect {CMD_RD_VLD,CMD_RD_CLN,CMD_RD_NOT_SHD} && !binsof(cp_mrd_type.MrdRdClnWU);
        ignore_bins illegal_bins_rdunq          = binsof(cp_cmd_type.CMD_RD_UNQ) && !binsof(cp_mrd_type.MrdRdClnWU) && 
                                    binsof(cp_iid_type) intersect {addrMgrConst::ACE_AIU};
        ignore_bins illegal_bins_rdunq_aiu      = binsof(cp_cmd_type.CMD_RD_UNQ) && !binsof(cp_mrd_type.MrdRdWU) && 
                                    !binsof(cp_iid_type) intersect {addrMgrConst::ACE_AIU};
        
        ignore_bins illegal_bins_rdnitc         = binsof(cp_cmd_type.CMD_RD_NITC) && !binsof(cp_mrd_type.MrdRdClnWU) && 
                                    binsof(cp_iid_type) intersect {addrMgrConst::ACE_AIU};
        ignore_bins illegal_bins_rdnitc_aiu     = binsof(cp_cmd_type.CMD_RD_NITC) && !binsof(cp_mrd_type.MrdRdWINV) && 
                                    !binsof(cp_iid_type) intersect {addrMgrConst::ACE_AIU};
        
        ignore_bins illegal_cmds_from_nc_agents     = binsof(cp_iid_type) intersect {addrMgrConst::AXI_AIU, addrMgrConst::ACE_LITE_AIU, addrMgrConst::ACE_LITE_E_AIU} &&
                                        binsof(cp_cmd_type) intersect {CMD_RD_CLN, CMD_RD_VLD, CMD_RD_NOT_SHD, CMD_RD_UNQ};
        ignore_bins illegal_cmds_from_proxycache    = binsof(cp_iid_type) intersect {addrMgrConst::IO_CACHE_AIU} &&
                                        !binsof(cp_cmd_type) intersect {CMD_RD_NITC, CMD_RD_VLD, CMD_RD_UNQ};
        ignore_bins illegal_state_from_nc_agents    = binsof(cp_iid_type) intersect {addrMgrConst::AXI_AIU, addrMgrConst::ACE_LITE_AIU, addrMgrConst::ACE_LITE_E_AIU};
        ignore_bins illegal_proxycache_RD_NITC_from_owner_state = binsof(cp_cmd_type.CMD_RD_NITC) && binsof(cp_iid_type) intersect {addrMgrConst::IO_CACHE_AIU};
    }

    <% if (caching_agents > 1) { %>
    //#Cover.DCE.MrdReq.dm_hit_iid_owner_other_sharers_present

    cx_dm_hit_iid_owner_sharers_present: cross cp_cmd_type, cp_iid_type, cp_mrd_type iff ((dm_state_on_lkp_e == 2) && (cmdreq.smi_msg_type != CMD_LD_CCH_SH || cmdreq.smi_msg_type != CMD_LD_CCH_UNQ)){

        ignore_bins illegal_bins_vld_cln_notshddirty    = binsof(cp_cmd_type) intersect {CMD_RD_VLD,CMD_RD_CLN,CMD_RD_NOT_SHD} && !binsof(cp_mrd_type.MrdRdClnWS);
        ignore_bins illegal_bins_rdunq          = binsof(cp_cmd_type.CMD_RD_UNQ) && !binsof(cp_mrd_type.MrdRdClnWU) && 
                                    binsof(cp_iid_type) intersect {addrMgrConst::ACE_AIU};
        ignore_bins illegal_bins_rdunq_aiu      = binsof(cp_cmd_type.CMD_RD_UNQ) && !binsof(cp_mrd_type.MrdRdWU) && 
                                    !binsof(cp_iid_type) intersect {addrMgrConst::ACE_AIU};
        
        ignore_bins illegal_bins_rdnitc         = binsof(cp_cmd_type.CMD_RD_NITC) && !binsof(cp_mrd_type.MrdRdClnWS) && 
                                    binsof(cp_iid_type) intersect {addrMgrConst::ACE_AIU};
        ignore_bins illegal_bins_rdnitc_aiu     = binsof(cp_cmd_type.CMD_RD_NITC) && !binsof(cp_mrd_type.MrdRdWINV) && 
                                    !binsof(cp_iid_type) intersect {addrMgrConst::ACE_AIU};
        
        ignore_bins illegal_cmds_from_nc_agents     = binsof(cp_iid_type) intersect {addrMgrConst::AXI_AIU, addrMgrConst::ACE_LITE_AIU, addrMgrConst::ACE_LITE_E_AIU} &&
                                        binsof(cp_cmd_type) intersect {CMD_RD_CLN, CMD_RD_VLD, CMD_RD_NOT_SHD, CMD_RD_UNQ};
        ignore_bins illegal_cmds_from_proxycache    = binsof(cp_iid_type) intersect {addrMgrConst::IO_CACHE_AIU} &&
                                        !binsof(cp_cmd_type) intersect {CMD_RD_NITC, CMD_RD_VLD, CMD_RD_UNQ};
        ignore_bins illegal_state_from_nc_agents    = binsof(cp_iid_type) intersect {addrMgrConst::AXI_AIU, addrMgrConst::ACE_LITE_AIU, addrMgrConst::ACE_LITE_E_AIU};
        ignore_bins Rdcln_from_SD_not_possible_chi  = binsof(cp_iid_type) intersect {addrMgrConst::CHI_A_AIU, addrMgrConst::CHI_B_AIU} && binsof(cp_cmd_type.CMD_RD_CLN);
        ignore_bins illegal_proxycache_RD_NITC_from_owner_state = binsof(cp_cmd_type.CMD_RD_NITC) && binsof(cp_iid_type) intersect {addrMgrConst::IO_CACHE_AIU};
    }
    <%}%>

    //#Cover.DCE.MrdReq.stash.iid
    <% if (chi_b_present !=0 || acelite_e_present !=0) { %>
    cx_stash_sub: cross cp_stash_type, cp_mrd_stash_type iff ((mrdreq.smi_msg_type == eMsgMRD'(MRD_RD_WITH_UNQ_CLN) || mrdreq.smi_msg_type == eMsgMRD'(MRD_RD_WITH_SHR_CLN) || mrdreq.smi_msg_type == eMsgMRD'(MRD_PREF)) && (cmdreq.smi_msg_type == CMD_LD_CCH_SH || cmdreq.smi_msg_type == CMD_LD_CCH_UNQ)) {
        
        bins prefetch_unq   = binsof(cp_stash_type.CMD_LD_CCH_UNQ) && binsof(cp_mrd_stash_type.MrdPrefetch);
        bins prefetch_shd   = binsof(cp_stash_type.CMD_LD_CCH_SH) && binsof(cp_mrd_stash_type.MrdPrefetch);
    <% if (chi_b_present !=0) { %>
        bins clnwu_unq      = binsof(cp_stash_type.CMD_LD_CCH_UNQ) && binsof(cp_mrd_stash_type.MrdRdClnWU);
        bins clnwu_shd      = binsof(cp_stash_type.CMD_LD_CCH_SH) && binsof(cp_mrd_stash_type.MrdRdClnWU);
        bins clnws_shd      = binsof(cp_stash_type.CMD_LD_CCH_SH) && binsof(cp_mrd_stash_type.MrdRdClnWS);
        ignore_bins illegal_unq = binsof(cp_stash_type.CMD_LD_CCH_UNQ) && binsof(cp_mrd_stash_type.MrdRdClnWS);
        <%}%>
    }
    
    <% if (chi_b_present >=  2) { %>
    cx_stash_reads: cross cx_stash_sub, cp_stash_iid_type, cp_lkprsp_stash  iff ((mrdreq.smi_msg_type == eMsgMRD'(MRD_RD_WITH_UNQ_CLN) || mrdreq.smi_msg_type == eMsgMRD'(MRD_RD_WITH_SHR_CLN) || mrdreq.smi_msg_type == eMsgMRD'(MRD_PREF)) && (cmdreq.smi_msg_type == CMD_LD_CCH_SH || cmdreq.smi_msg_type == CMD_LD_CCH_UNQ)) {
    
    ignore_bins trgt_owner_shr_abs  = binsof(cp_lkprsp_stash.dm_hit_trgt_as_owner_and_other_sharers_absent) && binsof(cx_stash_sub.clnws_shd);
    ignore_bins clnwu_shd_trgt_owner_other_sharers_absent_only = binsof(cx_stash_sub.clnwu_shd) && !binsof(cp_lkprsp_stash.dm_hit_trgt_as_owner_and_other_sharers_absent);
    ignore_bins prefetch_unq_req_owner  = binsof(cp_lkprsp_stash) intersect {dm_hit_trgt_as_neither_and_owner_present_other_sharers_absent, dm_hit_trgt_as_neither_and_owner_present_other_sharers_present, dm_hit_trgt_as_sharer_and_owner_present_other_sharers_absent, dm_hit_trgt_as_sharer_and_owner_present_other_sharers_present, dm_hit_trgt_as_owner_and_other_sharers_present, dm_hit_trgt_as_owner_and_other_sharers_absent} && binsof(cx_stash_sub.prefetch_unq) && binsof(cp_stash_iid_type) intersect {addrMgrConst::ACE_LITE_E_AIU};
    ignore_bins prefetch_shd_req_owner  = binsof(cp_lkprsp_stash) intersect {dm_hit_trgt_as_neither_and_owner_present_other_sharers_absent, dm_hit_trgt_as_neither_and_owner_present_other_sharers_present, dm_hit_trgt_as_sharer_and_owner_present_other_sharers_absent, dm_hit_trgt_as_sharer_and_owner_present_other_sharers_present, dm_hit_trgt_as_owner_and_other_sharers_present, dm_hit_trgt_as_owner_and_other_sharers_absent} && binsof(cx_stash_sub.prefetch_shd) && binsof(cp_stash_iid_type) intersect {addrMgrConst::ACE_LITE_E_AIU};
    }   
        <%}
    if (chi_b_present == 1){%>
    cx_stash_reads: cross cx_stash_sub, cp_stash_iid_type, cp_lkprsp_stash  iff ((mrdreq.smi_msg_type == eMsgMRD'(MRD_RD_WITH_UNQ_CLN) || mrdreq.smi_msg_type == eMsgMRD'(MRD_RD_WITH_SHR_CLN) || mrdreq.smi_msg_type == eMsgMRD'(MRD_PREF)) && (cmdreq.smi_msg_type == CMD_LD_CCH_SH || cmdreq.smi_msg_type == CMD_LD_CCH_UNQ)) {
    
    //ignore_bins owner_absent_lkp  = binsof(cp_lkprsp_stash) intersect {dm_miss_stash,dm_hit_trgt_as_neither_and_owner_absent_other_sharers_present,dm_hit_trgt_as_sharer_and_owner_absent_other_sharers_absent, dm_hit_trgt_as_sharer_and_owner_absent_other_sharers_present, dm_hit_trgt_as_owner_and_other_sharers_present} && binsof(cx_stash_sub.clnwu_shd);
    ignore_bins trgt_owner_shr_abs  = binsof(cp_lkprsp_stash.dm_hit_trgt_as_owner_and_other_sharers_absent) && binsof(cx_stash_sub.clnws_shd);
    //ignore_bins owner_present_lkp = binsof(cp_lkprsp_stash) intersect {dm_hit_trgt_as_neither_and_owner_present_other_sharers_absent, dm_hit_trgt_as_neither_and_owner_present_other_sharers_present, dm_hit_trgt_as_sharer_and_owner_present_other_sharers_absent, dm_hit_trgt_as_sharer_and_owner_present_other_sharers_present} && binsof(cx_stash_sub.prefetch_unq);
    //ignore_bins owner_present_lkp_1   = binsof(cp_lkprsp_stash) intersect {dm_hit_trgt_as_neither_and_owner_present_other_sharers_absent, dm_hit_trgt_as_neither_and_owner_present_other_sharers_present, dm_hit_trgt_as_sharer_and_owner_present_other_sharers_absent, dm_hit_trgt_as_sharer_and_owner_present_other_sharers_present} && binsof(cx_stash_sub.prefetch_shd);
    //ignore_bins owner_present_lkp_2   = binsof(cp_lkprsp_stash) intersect {dm_hit_trgt_as_neither_and_owner_present_other_sharers_absent, dm_hit_trgt_as_neither_and_owner_present_other_sharers_present, dm_hit_trgt_as_sharer_and_owner_present_other_sharers_absent, dm_hit_trgt_as_sharer_and_owner_present_other_sharers_present} && binsof(cx_stash_sub.clnwu_shd);
    ignore_bins prefetch_unq_req_owner  = binsof(cp_lkprsp_stash) intersect {dm_hit_trgt_as_neither_and_owner_present_other_sharers_absent, dm_hit_trgt_as_neither_and_owner_present_other_sharers_present, dm_hit_trgt_as_sharer_and_owner_present_other_sharers_absent, dm_hit_trgt_as_sharer_and_owner_present_other_sharers_present, dm_hit_trgt_as_owner_and_other_sharers_present, dm_hit_trgt_as_owner_and_other_sharers_absent} && binsof(cx_stash_sub.prefetch_unq) && binsof(cp_stash_iid_type) intersect {addrMgrConst::ACE_LITE_E_AIU};
    ignore_bins prefetch_shd_req_owner  = binsof(cp_lkprsp_stash) intersect {dm_hit_trgt_as_neither_and_owner_present_other_sharers_absent, dm_hit_trgt_as_neither_and_owner_present_other_sharers_present, dm_hit_trgt_as_sharer_and_owner_present_other_sharers_absent, dm_hit_trgt_as_sharer_and_owner_present_other_sharers_present, dm_hit_trgt_as_owner_and_other_sharers_present, dm_hit_trgt_as_owner_and_other_sharers_absent} && binsof(cx_stash_sub.prefetch_shd) && binsof(cp_stash_iid_type) intersect {addrMgrConst::ACE_LITE_E_AIU};
    ignore_bins no_trgt_chi_stash_0 = binsof(cp_stash_iid_type) intersect {addrMgrConst::CHI_B_AIU} && binsof(cx_stash_sub.clnwu_shd);
    ignore_bins no_trgt_chi_stash_1 = binsof(cp_stash_iid_type) intersect {addrMgrConst::CHI_B_AIU} && binsof(cx_stash_sub.clnwu_unq);
    ignore_bins no_trgt_chi_stash_2 = binsof(cp_stash_iid_type) intersect {addrMgrConst::CHI_B_AIU} && binsof(cx_stash_sub.clnws_shd);
    ignore_bins clnwu_shd_trgt_owner_other_sharers_absent_only = binsof(cx_stash_sub.clnwu_shd) && !binsof(cp_lkprsp_stash.dm_hit_trgt_as_owner_and_other_sharers_absent);
    <%if (caching_agents == 1) { %>
    ignore_bins trgt_inv_ower_shar_present  = binsof(cp_lkprsp_stash) intersect {dm_hit_trgt_as_neither_and_owner_present_other_sharers_absent,dm_hit_trgt_as_neither_and_owner_absent_other_sharers_present};
    <%}%>
    
    }   

    <%}
    if (chi_b_present == 0){%>
    cx_stash_reads: cross cx_stash_sub, cp_stash_iid_type, cp_lkprsp_non_stash  iff ((mrdreq.smi_msg_type == eMsgMRD'(MRD_PREF)) && (cmdreq.smi_msg_type == CMD_LD_CCH_SH || cmdreq.smi_msg_type == CMD_LD_CCH_UNQ)) {

            ignore_bins ace_lite_e_valid_state  = !binsof(cp_lkprsp_non_stash) intersect {dm_miss,dm_hit_as_neither_and_owner_absent_other_sharers_present,dm_hit_as_neither_and_owner_present_other_sharers_present,dm_hit_as_neither_and_owner_present_other_sharers_absent} ;
            ignore_bins no_mrd_issued_unq       = binsof(cp_lkprsp_non_stash) intersect {dm_hit_as_neither_and_owner_present_other_sharers_present,dm_hit_as_neither_and_owner_present_other_sharers_absent} && binsof(cx_stash_sub.prefetch_unq);
            ignore_bins no_mrd_issued_shd       = binsof(cp_lkprsp_non_stash) intersect {dm_hit_as_neither_and_owner_present_other_sharers_present,dm_hit_as_neither_and_owner_present_other_sharers_absent} && binsof(cx_stash_sub.prefetch_shd);

            }

        
        <%}
    }%>
    endgroup: cg_mrd_req

    covergroup cg_snp_req with function sample (eMsgCMD cmd_type, int up, int mpf3);

    cp_snp_type: coverpoint cmd_type {
    <% if (chi_b_present !=0) { %>
            //stash
            bins LdCchUnq_SnpStshUnq    = {eMsgCMD'(CMD_LD_CCH_UNQ)};
            bins LdCchShd_SnpStshShd    = {eMsgCMD'(CMD_LD_CCH_SH)};
        <%}
       if (acelite_e_present!=0) { %>
            bins WrStshFull_SnpInvStsh  = {eMsgCMD'(CMD_WR_STSH_FULL)};
            bins WrStshPtl_SnpUnqStsh   = {eMsgCMD'(CMD_WR_STSH_PTL)};
        <%}%>
            //reads
       <%if (caching_agents > 1) { %>
            bins RdCln_SnpClnDtr            = {eMsgCMD'(CMD_RD_CLN)};
            bins RdVld_SnpVldDtr            = {eMsgCMD'(CMD_RD_VLD)};
            bins RdNotShdDty_SnpNoSDInt     = {eMsgCMD'(CMD_RD_NOT_SHD)};
            bins RdUnq_SnpInvDtr            = {eMsgCMD'(CMD_RD_UNQ)};
        <%}%>
            bins RdNITC_SnpNITC         = {eMsgCMD'(CMD_RD_NITC)};

            //atomics
            bins RdAtm_SnpInvDtw        = {eMsgCMD'(CMD_RD_ATM)};
            bins WrAtm_SnpInvDtw        = {eMsgCMD'(CMD_WR_ATM)};
            bins SwAtm_SnpInvDtw        = {eMsgCMD'(CMD_SW_ATM)};
            bins CmpAtm_SnpInvDtw       = {eMsgCMD'(CMD_CMP_ATM)};

            //cleans
       <%if (caching_agents > 1) { %>
            bins ClnUnq_SnpInvDtw       = {eMsgCMD'(CMD_CLN_UNQ)};
        <%}%>
            bins ClnInv_SnpInvDtw       = {eMsgCMD'(CMD_CLN_INV)};
            bins ClnVld_SnpClnDtw       = {eMsgCMD'(CMD_CLN_VLD)};
            bins ClnShPer_SnpClnDtw     = {eMsgCMD'(CMD_CLN_SH_PER)};
            
            //makes
       <%if (caching_agents > 1) { %>
            bins MkUnq_SnpInv       = {eMsgCMD'(CMD_MK_UNQ)};
        <%}%>
            bins MkInv_SnpInv       = {eMsgCMD'(CMD_MK_INV)};

            //writes
            bins WrUnqPtl_SnpInvDtw     = {eMsgCMD'(CMD_WR_UNQ_PTL)};
            bins WrUnqFull_SnpInv       = {eMsgCMD'(CMD_WR_UNQ_FULL)};

            //nitc
            bins RdNITCMkInv_SnpNITCMkInv   = {eMsgCMD'(CMD_RD_NITC_MK_INV)};
            bins RdNITCClnInv_SnpNITCClnInv = {eMsgCMD'(CMD_RD_NITC_CLN_INV)};
        }

        cp_snp_up: coverpoint up {
            bins UP_01  = {1};
            bins UP_11  = {3};
        <%if (caching_agents == 1) { %>
            ignore_bins No_sharer   = {3};
        <%}%>
        }

        //#Cover.DCE.SnpReq.MPF3
        cp_snp_mpf3: coverpoint mpf3 {
        <%obj.AiuInfo.forEach(function(bundle, idx, array) {
            if ((bundle.fnNativeInterface === "ACE") || (bundle.fnNativeInterface === "CHI-A") || (bundle.fnNativeInterface === "CHI-B") || (bundle.useCache == 1)) {%>
            bins caching_agent_<%=bundle.FUnitId%> = {<%=bundle.FUnitId%>};
            <%}
        })%>
        }
        
        //#Cover.DCE.SnpReq.SnpReq_UP_MPF3
        cx_snp_up_mpf3: cross cp_snp_type, cp_snp_up;

    endgroup: cg_snp_req

    covergroup cg_snprsp_err with function sample (eMsgCMD cmd_type, smi_cmstatus_t snprsp_cmstatus , bit dt_aiu, smi_cmstatus_t strreq_cmstatus);
        //#Cover.DCE.SnpRspErr.SnpReq
        cp_snp_type: coverpoint cmd_type {
        <% if (chi_b_present !=0) { %>
            //stash
            bins LdCchUnq_SnpStshUnq    = {eMsgCMD'(CMD_LD_CCH_UNQ)};
            bins LdCchShd_SnpStshShd    = {eMsgCMD'(CMD_LD_CCH_SH)};
        <%}
        if (acelite_e_present!=0) { %>
            bins WrStshFull_SnpInvStsh  = {eMsgCMD'(CMD_WR_STSH_FULL)};
            bins WrStshPtl_SnpUnqStsh   = {eMsgCMD'(CMD_WR_STSH_PTL)};
        <%}%>
            //reads
        <%if (caching_agents > 1) { %>
            bins RdCln_SnpClnDtr            = {eMsgCMD'(CMD_RD_CLN)};
            bins RdVld_SnpVldDtr            = {eMsgCMD'(CMD_RD_VLD)};
            bins RdNotShdDty_SnpNoSDInt     = {eMsgCMD'(CMD_RD_NOT_SHD)};
            bins RdUnq_SnpInvDtr        = {eMsgCMD'(CMD_RD_UNQ)};
        <%}%>
            bins RdNITC_SnpNITC         = {eMsgCMD'(CMD_RD_NITC)};

            //atomics
            bins RdAtm_SnpInvDtw        = {eMsgCMD'(CMD_RD_ATM)};
            bins WrAtm_SnpInvDtw        = {eMsgCMD'(CMD_WR_ATM)};
            bins SwAtm_SnpInvDtw        = {eMsgCMD'(CMD_SW_ATM)};
            bins CmpAtm_SnpInvDtw       = {eMsgCMD'(CMD_CMP_ATM)};

            //cleans
        <%if (caching_agents > 1) { %>
            bins ClnUnq_SnpInvDtw       = {eMsgCMD'(CMD_CLN_UNQ)};
        <%}%>
            bins ClnInv_SnpInvDtw       = {eMsgCMD'(CMD_CLN_INV)};
            bins ClnVld_SnpClnDtw       = {eMsgCMD'(CMD_CLN_VLD)};
            bins ClnShPer_SnpClnDtw     = {eMsgCMD'(CMD_CLN_SH_PER)};
            
            //makes
        <%if (caching_agents > 1) { %>
            bins MkUnq_SnpInv       = {eMsgCMD'(CMD_MK_UNQ)};
        <%}%>
            bins MkInv_SnpInv       = {eMsgCMD'(CMD_MK_INV)};

            //writes
            bins WrUnqPtl_SnpInvDtw     = {eMsgCMD'(CMD_WR_UNQ_PTL)};
            bins WrUnqFull_SnpInv       = {eMsgCMD'(CMD_WR_UNQ_FULL)};

            //nitc
            bins RdNITCMkInv_SnpNITCMkInv   = {eMsgCMD'(CMD_RD_NITC_MK_INV)};
            bins RdNITCClnInv_SnpNITCClnInv = {eMsgCMD'(CMD_RD_NITC_CLN_INV)};
        }
        //#Cover.DCE.SnpRspErr.Type
        cp_snp_err_cmstatus: coverpoint snprsp_cmstatus {
            bins address_error  = {'b1000_0100};
            bins data_error     = {'b1000_0011};
        }
        //#Cover.DCE.SnpRspErr.DT_done
        cp_aiu_dt: coverpoint dt_aiu {
            bins Dtr_Done   = {'b1};
            bins no_Dtr = {'b0};
        }
        //#Cover.DCE.SnpRspErr.StrReq_Err
        cp_str_err_cmstatus: coverpoint strreq_cmstatus {
            bins address_error  = {'b1000_0100};
            bins data_error     = {'b1000_0011};
            bins no_error       = {'b0000_0000}; //All cmstatus with no err
        }
        //#Cover.DCE.SnpRspErr
        cx_snpreq_rsperr: cross cp_snp_type, cp_snp_err_cmstatus; 
    

    endgroup: cg_snprsp_err
    
    covergroup cg_mrdrsp_err with function sample (eMsgCMD cmd_type, smi_cmstatus_t mrdrsp_cmstatus);

    cp_cmd_type: coverpoint cmd_type {
            bins CMD_CLN_VLD         = {8'b00001000};  //0x08
            bins CMD_CLN_INV         = {8'b00001001};  //0x09
            bins CMD_CLN_SH_PER      = {8'b00101000};  //0x28
        }

    cp_mrd_err_cmstatus: coverpoint mrdrsp_cmstatus {
        bins address_error  = {'b1000_0100};
        bins data_error     = {'b1000_0011};
    }
    
    cx_mrdreq_rsperr: cross cp_cmd_type, cp_mrd_err_cmstatus;
        
    endgroup: cg_mrdrsp_err

    covergroup cg_rbreq with function sample(int rbrreq_count);
        
        cp_cmd_type: coverpoint cmdreq.smi_msg_type {
            bins CMD_RD_CLN          = {8'b00000001};  //0x01
            bins CMD_RD_NOT_SHD      = {8'b00000010};  //0x02
            bins CMD_RD_VLD          = {8'b00000011};  //0x03
            bins CMD_RD_UNQ          = {8'b00000100};  //0x04
            bins CMD_CLN_UNQ         = {8'b00000101};  //0x05
            bins CMD_MK_UNQ          = {8'b00000110};  //0x06
            bins CMD_RD_NITC         = {8'b00000111};  //0x07
            bins CMD_CLN_VLD         = {8'b00001000};  //0x08
            bins CMD_CLN_INV         = {8'b00001001};  //0x09
            bins CMD_MK_INV          = {8'b00001010};  //0x0A
            bins CMD_WR_UNQ_PTL      = {8'b00010000};  //0x10
            bins CMD_WR_UNQ_FULL     = {8'b00010001};  //0x11
            bins CMD_WR_ATM          = {8'b00010010};  //0x12
            bins CMD_RD_ATM          = {8'b00010011};  //0x13
            bins CMD_WR_BK_FULL      = {8'b00010100};  //0x14
    <% if (chi_b_present !=0) { %>
            bins CMD_WR_CLN_FULL     = {8'b00010101};  //0x15
        <%}%>
            bins CMD_WR_EVICT        = {8'b00010110};  //0x16
            bins CMD_EVICT           = {8'b00010111};  //0x17
            bins CMD_WR_BK_PTL       = {8'b00011000};  //0x18
    <% if (chi_a_present !=0) { %>
            bins CMD_WR_CLN_PTL      = {8'b00011001};  //0x19
        <%}
       if (acelite_e_present!=0) { %>
            bins CMD_WR_STSH_FULL    = {8'b00100010};  //0x22
            bins CMD_WR_STSH_PTL     = {8'b00100011};  //0x23
        <%}
       if (chi_b_present !=0 || acelite_e_present !=0) { %>
            bins CMD_LD_CCH_SH       = {8'b00100100};  //0x24
            bins CMD_LD_CCH_UNQ      = {8'b00100101};  //0x25
        <%}%>
            bins CMD_RD_NITC_CLN_INV = {8'b00100110};  //0x26
            bins CMD_RD_NITC_MK_INV  = {8'b00100111};  //0x27
            bins CMD_CLN_SH_PER      = {8'b00101000};  //0x28
            bins CMD_SW_ATM          = {8'b00101001};  //0x29
            bins CMD_CMP_ATM         = {8'b00101010};  //0x2A
        }

        cp_rbrreq_count: coverpoint rbrreq_count {
            bins no_rbrreq    = {0};
            bins rbrrsv_rbusd = {1};
          //bins rbrrsv_rbrls = {2}; // Deprecated in Ncore-3.6
        }

        //#Cover.DCE.RBRsv_RBUsed
        //#Cover.DCE.RBRsv_RBRelease
        cx_cmdtype_rbrreq: cross cp_cmd_type, cp_rbrreq_count {
            ignore_bins writes_always_get_rbusd_req = binsof(cp_cmd_type) intersect {CMD_WR_UNQ_PTL, CMD_WR_UNQ_FULL, CMD_WR_BK_FULL, CMD_WR_BK_PTL, CMD_WR_CLN_FULL, CMD_WR_CLN_PTL, CMD_WR_EVICT, CMD_WR_STSH_PTL} && binsof(cp_rbrreq_count) intersect {0, 2};
            ignore_bins make_UNQ_IX_and_Evict_norbs = binsof(cp_cmd_type) intersect {CMD_EVICT, CMD_MK_INV, CMD_MK_UNQ} && binsof(cp_rbrreq_count) intersect {1,2};
            ignore_bins write_stash_cannot_have_no_rbrreq = binsof(cp_cmd_type) intersect {CMD_WR_STSH_FULL, CMD_WR_STSH_PTL} && binsof(cp_rbrreq_count) intersect {0};
        <% if (chi_b_present == 0){%>
            ignore_bins No_stash_target_cannot_have_rbs = binsof(cp_cmd_type) intersect {CMD_LD_CCH_SH, CMD_LD_CCH_UNQ} && binsof(cp_rbrreq_count) intersect {1,2};     
            <%}
           if (caching_agents <=1) { %>
                ignore_bins  Coherent_cmds_from_neither_o_s_present =  binsof(cp_cmd_type) intersect {CMD_RD_CLN, CMD_RD_VLD, CMD_RD_NOT_SHD, CMD_RD_UNQ, CMD_CLN_UNQ, CMD_LD_CCH_SH, CMD_LD_CCH_UNQ} && binsof(cp_rbrreq_count) intersect {1,2};
            <%}%>
            
        }

    endgroup: cg_rbreq


    covergroup cg_back_to_back_allocs with function sample();

    
    cp_back_to_back_allocs: coverpoint back_back_alloc_state {
    //#Cover.DCE.dm_lkprsp.back_back_3_allocs_diff_tag_addr 
        bins back_back_allocating_requests_same_SF_same_setaddr_different_tagaddr   = {0};
    //#Cover.DCE.dm_lkprsp.back_back_3_allocs_tags_hit  
        bins back_back_allocating_requests_same_SF_same_setaddr_all_tag_hits        = {1};
    //#Cover.DCE.dm_lkprsp.back_back_3_allocs_vb_hit    
        bins back_back_allocating_requests_same_SF_same_setaddr_all_vb_hits     = {2};
    //#Cover.DCE.dm_lkprsp.back_back_3_allocs_misses    
        bins back_back_allocating_requests_same_SF_same_setaddr_all_misses      = {3};
    
    <%if(obj.DceInfo[0].nAttCtrlEntries <= 4){%>
        ignore_bins tag_bins    = {0};
        ignore_bins tag_hits    = {1};
        ignore_bins tag_vbs = {2};
        ignore_bins tag_miss    = {3};
            

    <%}
    else{%>
        ignore_bins tag_vbs_1   = {2};
    <%}%>
    }
    endgroup: cg_back_to_back_allocs
    
    covergroup cg_back_to_back_non_allocs with function sample();

    cp_back_to_back_non_allocs: coverpoint back_back_non_alloc_state {
    //#Cover.DCE.dm_lkprsp.back_back_3_non_allocs_diff_tag_addr 
        bins back_back_non_allocating_requests_same_SF_same_setaddr_different_tagaddr   = {0};
    //#Cover.DCE.dm_lkprsp.back_back_3_non_allocs_tags_hit  
        bins back_back_non_allocating_requests_same_SF_same_setaddr_all_tag_hits    = {1};
    //#Cover.DCE.dm_lkprsp.back_back_3_non_allocs_vb_hit    
        bins back_back_non_allocating_requests_same_SF_same_setaddr_all_vb_hits     = {2};
    //#Cover.DCE.dm_lkprsp.back_back_3_non_allocs_misses    
        bins back_back_non_allocating_requests_same_SF_same_setaddr_all_misses      = {3};
    
    <%if(obj.DceInfo[0].nAttCtrlEntries <= 4){%>
        ignore_bins tag_bins    = {0};
        ignore_bins tag_hits    = {1};
        ignore_bins tag_vbs = {2};
        ignore_bins tag_miss    = {3};
            

    <%}
    else{%>
        ignore_bins tag_vbs_1   = {2};
    <%}%>
    }
    endgroup: cg_back_to_back_non_allocs

    covergroup cg_message_timing with function sample(bit flag_time, bit[1:0] str_time);
        //#Cover.DCE.SMIMsgsTiming  
        cp_smi_message_order: coverpoint timing_order iff (flag_time == 1) {
            bins snpreq_snprsp_rbrsv  = {0};
            bins snpreq_rbrsv_snprsp  = {1};
            bins rbrsv_snpreq_snprsp  = {2};
        }
        
        //#Cover.DCE.STRreqDMwriteTiming
        cp_strreq_wrt_dm_write: coverpoint str_time iff (str_time !=0) {
            bins dm_write_strreq = {1};
            bins strreq_dm_write = {2};
        }

    endgroup: cg_message_timing
    
    covergroup cg_back_reqs with function sample(bit[1:0] sample_flag);
    cp_cmd_upd_order: coverpoint cmd_upd_order iff (sample_flag == 2'b10) {
        ignore_bins cmd_upd_same_cycle      = {0}; // DM_UPD Req will block DM for 3 cycles so DM_CMD Req can not be accepted. DM_UPD has more priority than DM_CMD
    //#Cover.DCE.dm_cmd_upd_one_cycle
        bins cmd_upd_one_cycle      = {1};
    //#Cover.DCE.dm_cmd_upd_two_cycles
        bins cmd_upd_two_cycle      = {2};
    //#Cover.DCE.dm_cmd_upd_three_cycles
        bins cmd_upd_three_cycle    = {3};
    //#Cover.DCE.dm_cmd_upd_four_cycles
        bins cmd_upd_four_cycle     = {4};
    }
    cp_upd_cmt_order: coverpoint upd_cmt_order iff (sample_flag == 2'b01) {
        ignore_bins upd_cmt_same_cycle      = {0}; //Update Req will block DM for 3 cycles so DM_CMT Req can not be accepted on the same cycle. CMT have more priority than DM_UPD.
        ignore_bins upd_before_cmt_one_cycle    = {1}; //Update Req will block DM for 3 cycles so DM_CMT Req can not be accepted next cycle of DM_UPD Req.
    //#Cover.DCE.dm_upd_after_write
        bins upd_after_cmt_one_cycle    = {2};
    }
    endgroup: cg_back_reqs

    // Covergroup for system event messages
    covergroup cg_sys_event with function sample(dce_scb_txn sys_event_msg);

        option.per_instance         = 1;

        cp_sysreq_event_opcode      : coverpoint sys_event_msg.sys_event_cov_txn.sysreq_event_opcode{
            bins event_opcode   = {3};
        }
        cp_timeout_threshold        : coverpoint sys_event_msg.sys_event_cov_txn.timeout_threshold{
            bins valid_bins     = {[1:4]};
            bins disable_value  = {0};
        }
        cp_sysreq_event         : coverpoint sys_event_msg.sys_event_cov_txn.sysreq_event{
            bins sysreq_event_sent  = {1};
        }
        cp_sysrsp_event         : coverpoint sys_event_msg.sys_event_cov_txn.sysrsp_event{
            bins sysrsp_event_rcvd  = {1};
        }
        cp_sysrsp_event_cmstatus    : coverpoint sys_event_msg.sys_event_cov_txn.cm_status{
            bins good_operation = {3};
        }
        cp_timeout_err_det_en       : coverpoint sys_event_msg.sys_event_cov_txn.timeout_err_det_en{
            bins timeout_enable = {1};
            bins timeout_disable    = {0};
        }   
        cp_timeout_err_int_en       : coverpoint sys_event_msg.sys_event_cov_txn.timeout_err_int_en{
            bins timeout_int_en = {1};
            bins timeout_int_dis    = {0};
        }
        cp_uesr_err_type        : coverpoint sys_event_msg.sys_event_cov_txn.uesr_err_type{
            bins uesr_err_type  = {'hA};
        }
        cp_err_valid            : coverpoint sys_event_msg.sys_event_cov_txn.err_valid{
            bins valid      = {1};
            bins invalid        = {0};
        }
        cp_uc_int_occurred      : coverpoint sys_event_msg.sys_event_cov_txn.irq_uc{
            bins irq_occurred   = {1};
            bins no_irq     = {0};
            }
    endgroup: cg_sys_event

    // CONC-13159
    covergroup cg_recall_qos with function sample(bit use_eviction_qos, int eviction_qos);
        cp_default_eviction_qos: coverpoint eviction_qos iff(use_eviction_qos == 0) {
            bins default_eviction_qos_bins[1] = {15};
        }

        <%if(obj.DceInfo[0].fnEnableQos == 1) {%>
        cp_use_eviction_qos: coverpoint eviction_qos iff(use_eviction_qos == 1) {
            bins use_eviction_qos_bins[16] = {[0:15]};
        }
        <%}%>
    endgroup: cg_recall_qos
    
    covergroup cg_strreq with function sample(bit[2:0] final_state, addrMgrConst::interface_t inf);
        option.per_instance = 1;
        cp_iid_type: coverpoint inf {
                <%  if(ace_present != 0) { %>
                        bins ACE_AIU = {addrMgrConst::ACE_AIU};
                <%  }
                    if(chi_a_present != 0) { %>
                        bins CHI_A_AIU = {addrMgrConst::CHI_A_AIU};
                <%  } 
                    if(chi_b_present != 0) { %>
                        bins CHI_B_AIU = {addrMgrConst::CHI_B_AIU};
                <%  } 
                    if(iocache_present != 0) { %>
                        bins IO_CACHE_AIU = {addrMgrConst::IO_CACHE_AIU};
                <%  } %>
            }
        
        //#Cover.DCE.StrReq_finalstate
        cp_cmstatus_state: coverpoint final_state {
            bins state_IX       = {3'b000};
            bins state_UC_UD    = {3'b100}; 
            bins state_SD       = {3'b010}; 
            bins state_SC       = {3'b011}; 
        <% if (caching_agents <=1) { %>
            ignore_bins illegal_bins_SD     = {3'b010};
            <%}%>
        }
        
        cx_iid_state: cross cp_iid_type, cp_cmstatus_state;
    endgroup: cg_strreq

    covergroup cg_sysco_req with function sample(bit[2:0] sysco_op, int agent_id);
    
    cp_agentid: coverpoint agent_id {
        <%  obj.AiuInfo.forEach(function(bundle, idx, array) {
            if ((bundle.fnNativeInterface === "ACE") || (bundle.fnNativeInterface === "CHI-A") || (bundle.fnNativeInterface === "CHI-B") || (bundle.useCache == 1)) {%>

                    bins aiuid_<%=idx%> = {<%=idx%>};
            <%  } 
            }) %>
        }

    cp_sysco_op: coverpoint sysco_op {
        bins ATTACH = {1};  
        bins DETACH = {2};  
    }
    
    cx_agent_sysco_op: cross cp_agentid, cp_sysco_op;

    endgroup: cg_sysco_req

   covergroup cg_attach_detach with function sample();
    cp_att_det: coverpoint owner_sharer_attach_detached {
        bins owner_attached = {0};
        bins owner_detached = {1};
        bins sharer_attached    = {2};
        bins sharer_detached    = {3};
    }
   endgroup

    <% if (obj.DceInfo[obj.Id].CMDOverflowBufInSRAM == true) {%> 
    covergroup skidbuf_error_testing; 

    // Coverpoint for interrupt enable status
    interrupt_enabled : coverpoint skidbuf_int_bit {
        bins int_is_enabled = {1};
        bins int_is_disabled = {0};
    }

    // Coverpoint for error detection enable status
    error_det_enabled : coverpoint skidbuf_err_det_bit {
        bins errdet_is_enabled = {1};
      <%if(filter_secded) { %>
        bins errdet_is_disabled = {0};
      <% } %>
      <%if(filter_parity) { %>
        ignore_bins errdet_is_disabled = {0};
      <% } %>
    }

    // Coverpoint for type of error
    type_of_error : coverpoint type_of_error {
      <%if(filter_secded) { %>
        bins corr_err = {1};   // Correctable error
      <% } %>
      <%if(filter_parity) { %>
        ignore_bins corr_err = {1};   // Correctable error
      <% } %>
        bins uncorr_err = {0}; // Uncorrectable error
    }

    // Coverpoint for SRAM status
    sram_enabled : coverpoint sram_enabled {
        bins sram_on = {5, 6}; // SRAM enabled states
    }

    // Cross coverage for corr_err when SRAM is on and different enable combinations
    corr_err_cross : cross type_of_error, sram_enabled, error_det_enabled, interrupt_enabled {
        // Ignore illegal combination where only interrupt is enabled
        ignore_bins uncorr_corr_memdet_disabled = binsof(type_of_error) intersect {0,1} && 
                              binsof(sram_enabled) intersect {5, 6} &&
                              binsof(error_det_enabled) intersect {0} && 
                              binsof(interrupt_enabled) intersect {1};

        ignore_bins uncorr_both_disabled = binsof(type_of_error) intersect {0} && 
                               binsof(sram_enabled) intersect {5, 6} &&
                               binsof(error_det_enabled) intersect {0} && 
                               binsof(interrupt_enabled) intersect {0};

    <%if(filter_secded) { %> //#Cover.DCE.Concerto.v3.7.CorrectableSECDED


        bins corr_sram_int_errdet_enabled = binsof(type_of_error) intersect {1} && 
                                            binsof(sram_enabled) intersect {5, 6} &&
                                            binsof(error_det_enabled) intersect {1} && 
                                            binsof(interrupt_enabled) intersect {1};

        bins corr_sram_errdet_only = binsof(type_of_error) intersect {1} && 
                                     binsof(sram_enabled) intersect {5, 6} &&
                                     binsof(error_det_enabled) intersect {1} && 
                                     binsof(interrupt_enabled) intersect {0};

        bins corr_sram_both_disabled = binsof(type_of_error) intersect {1} && 
                                       binsof(sram_enabled) intersect {5, 6} &&
                                       binsof(error_det_enabled) intersect {0} && 
                                       binsof(interrupt_enabled) intersect {0};
    <% } %>

    <%if(filter_parity) { %>


        ignore_bins corr_sram_int_errdet_enabled = binsof(type_of_error) intersect {1} && 
                                            binsof(sram_enabled) intersect {5, 6} &&
                                            binsof(error_det_enabled) intersect {1} && 
                                            binsof(interrupt_enabled) intersect {1};

        ignore_bins corr_sram_errdet_only = binsof(type_of_error) intersect {1} && 
                                     binsof(sram_enabled) intersect {5, 6} &&
                                     binsof(error_det_enabled) intersect {1} && 
                                     binsof(interrupt_enabled) intersect {0};

        ignore_bins corr_sram_both_disabled = binsof(type_of_error) intersect {1} && 
                                       binsof(sram_enabled) intersect {5, 6} &&
                                       binsof(error_det_enabled) intersect {0} && 
                                       binsof(interrupt_enabled) intersect {0};
    <% } %>

        bins uncorr_sram_int_errdet_enabled = binsof(type_of_error) intersect {0} && //#Cover.DCE.Concerto.v3.7.UncorrectableSECDED
                                            binsof(sram_enabled) intersect {5, 6} && //#Cover.DCE.Concerto.v3.7.UncorrectablePARITY
                                            binsof(error_det_enabled) intersect {1} && 
                                            binsof(interrupt_enabled) intersect {1};

        bins uncorr_sram_errdet_only = binsof(type_of_error) intersect {0} && 
                                     binsof(sram_enabled) intersect {5, 6} &&
                                     binsof(error_det_enabled) intersect {1} && 
                                     binsof(interrupt_enabled) intersect {0};

    }

    endgroup
    <% } %>
    

    extern function new                                  ();
    extern function void collect_dce_scb_txn             (dce_scb_txn txn);  
    extern function void collect_snp_mrd_credits_info    (bit snp_n_mrd, int available_credits);  
    extern function void collect_rbid_credits_info       (req_type_e rb, int available_credits);  
    extern function void collect_scm_state               (int dmiid, int state);
    extern function void collect_exmon_scenario          (int agentid, int procid, eMsgCMD cmd_type, exmon_state_e exmon_state);  
    extern function void collect_recall_qos              (bit use_eviction_qos, int eviction_qos);
    extern function void collect_dirm_scenario           (directory_mgr dirm);  
    extern function void collect_dirm_scenario_on_rtyrsp (directory_mgr dirm);
    extern function void collect_snprsp                  (eMsgCMD cmd_type, addrMgrConst::interface_t inf, bit stash_target, bit owner, bit [WSMICMSTATUS-1:0] cmstatus);
    extern function void collect_back_to_back_allocs     (dm_seq_item lkprsp, int iid);
    extern function void collect_back_to_back_non_allocs (dm_seq_item lkprsp, int iid);
    extern function void collect_back_back_cmd_upd_reqs  (dm_seq_item packet);
    extern function void collect_message_timing          (dce_scb_txn txn);
    extern function void collect_sys_event_cov           (dce_scb_txn sys_ev_msg);
    <%if (obj.DceInfo[0].fnEnableQos == 1) {%>
    extern function void collect_qoscr_event_threshold   (int qoscr_event_threshold_value);
    <%}%>
    <% if (obj.DceInfo[obj.Id].CMDOverflowBufInSRAM == true){ %> 
    extern function void collect_skidbuff_err_csr (bit type_of_error_csr, bit skidbuf_err_det_bit_csr, bit skidbuf_int_bit_csr, bit [3:0] skidbuf_uesr_err_type_csr);
    <%}%>


endclass: dce_coverage;

//**************************************
function dce_coverage::new();
    cg_dm_lkprsp               = new();
    cg_exmon                   = new();
    cg_dm                      = new();
    cg_snprsp                  = new();
    cg_credits                 = new();
    cg_scm_state               = new();
    cg_rb_credits              = new();
    cg_sf_access_v36           = new();
    cg_rbid_updates_v36        = new();
    cg_mrd_req                 = new();
    cg_snp_req                 = new();
    cg_snprsp_err              = new();
    cg_mrdrsp_err              = new();
    cg_rbreq                   = new();
    cg_back_to_back_allocs     = new();
    cg_back_to_back_non_allocs = new();
    cg_message_timing          = new();
    cg_back_reqs               = new();
    cg_sys_event               = new();
    cg_recall_qos              = new();
    cg_strreq                  = new();
    cg_sysco_req               = new();
    cg_attach_detach           = new();

    <%obj.SnoopFilterInfo.forEach(function(bundle, idx, array) {%>
      <%if(obj.DceInfo[0].nAttCtrlEntries > bundle.nWays){%>
    cg_rtyrsp_sf_<%=idx%> = new();
      <%}%>
      cg_sf_<%=idx%> = new(); 
    <%})%>
    <%if (obj.DceInfo[0].fnEnableQos == 1) {%>
    cg_qoscr_et = new();
    <%}%>
    <% if (obj.DceInfo[obj.Id].CMDOverflowBufInSRAM == true){ %> 
    skidbuf_error_testing = new();
    <%}%>

endfunction: new

//*****************************************************
function void dce_coverage::collect_snp_mrd_credits_info(bit snp_n_mrd, int available_credits);  


    `uvm_info("DCE_COV", $psprintf("snp_n_mrd:%0d available_credits:%0d", snp_n_mrd, available_credits), UVM_LOW)
    cg_credits.sample(snp_n_mrd, available_credits);


endfunction: collect_snp_mrd_credits_info

//*****************************************************
function void dce_coverage::collect_rbid_credits_info(req_type_e rb, int available_credits);  


    `uvm_info("DCE_COV", $psprintf("rb:%0p available_credits:%0d", rb, available_credits), UVM_LOW)
    cg_rb_credits.sample(rb, available_credits);
        //  if(available_credits < 10)
    //  `uvm_info("DCE_COV_error", $psprintf("rb:%0p available_credits:%0d", rb, available_credits), UVM_LOW)


endfunction: collect_rbid_credits_info

//*****************************************************
function void dce_coverage::collect_scm_state(int dmiid, int state);  

    cg_scm_state.sample(dmiid, state);

endfunction: collect_scm_state

//*****************************
function void dce_coverage::collect_snprsp(eMsgCMD cmd_type, addrMgrConst::interface_t inf, bit stash_target, bit owner, bit [WSMICMSTATUS-1:0] cmstatus);



    `uvm_info("DCE_COV", $psprintf("Got cmd_type:%0p inf:%0p, stash_tgt:%0d owner:%0d cmstatus:%0p for coverage", cmd_type, inf, stash_target, owner, cmstatus), UVM_LOW)
    cg_snprsp.sample(cmd_type, inf, stash_target, owner, cmstatus);

endfunction: collect_snprsp

function void dce_coverage::collect_dce_scb_txn(dce_scb_txn txn);
    dm_seq_item pktq[$], dm_cmdreq_pktq[$];
    dm_seq_item lkprsp, dm_cmdreq;
    int cache_id, agentid;
    int stsh_nid; 
    int agent_idq[$];
    int mrd_sample, snp_sample;
    eMsgCMD cmd_type;
    eMsgMRD mrd_type;
    eMsgSNP snp_type;
    smi_seq_item sysreq;
    smi_seq_item strreq;
    sysco_req_t sysco_req;
    smi_cmstatus_t err_snprsp;
    bit dt_aiu;

    if(txn.m_req_type == SYSCO_REQ && txn.m_initsys_co_req_pkt != null) begin
            $cast(sysreq, txn.m_initsys_co_req_pkt.clone());
        if (sysreq.smi_sysreq_op == 1) begin
            sysco_req.op = 1;
            sysco_req.agent_id = sysreq.smi_src_ncore_unit_id;
            sysco_req.smi_sys_time = sysreq.t_smi_ndp_valid;    
        end
        else if (sysreq.smi_sysreq_op == 2) begin
            sysco_req.op = 2;
            sysco_req.agent_id = sysreq.smi_src_ncore_unit_id;
            sysco_req.smi_sys_time = sysreq.t_smi_ndp_valid;    
        end
        sysco_reqq.push_back(sysco_req);
        //#Cover.DCE.Sysco
        cg_sysco_req.sample(sysco_req.op,sysco_req.agent_id);
        return;
    end
    
    //TODO: Update for Recall ops, Update ops 
    if (txn.m_req_type != CMD_REQ)
        return;
    
    $cast(cmdreq, txn.m_initcmdupd_req_pkt.clone());
    $cast(cmd_type, cmdreq.smi_msg_type); 
    
    mrd_sample = 0;
    snp_sample = 0;
    
    if(txn.m_expmrd_req_pkt != null) begin
         $cast(mrdreq, txn.m_expmrd_req_pkt.clone()); 
             $cast(mrd_type, mrdreq.smi_msg_type);
        mrd_sample =1;
    end

    if(txn.m_expsnp_req_pktq.size() != 0) begin
        $cast(snpreq, txn.m_expsnp_req_pktq[0].clone()); 
            $cast(snp_type, snpreq.smi_msg_type);
        snp_sample =1;
    end

    
    cache_id = txn.m_iid_cacheid;

    pktq = txn.m_dm_pktq.find(item) with (item.m_access_type == DM_LKP_RSP);
    $cast(lkprsp, pktq[pktq.size() - 1].clone());
    lkprsp.m_set_index = pktq[pktq.size()-1].m_set_index;
    dm_cmdreq_pktq = txn.m_dm_pktq.find(item) with (item.m_access_type == DM_CMD_REQ);
    $cast(dm_cmdreq, dm_cmdreq_pktq[dm_cmdreq_pktq.size() - 1].clone());
    attid = lkprsp.m_attid;
    if (lkprsp.is_dm_miss()) begin
        dm_state_on_lkp_e = dm_miss;
    end 
    else if (cache_id != -1) begin //dm_hit
        if (     lkprsp.m_owner_val
         && (cache_id!=-1)
             && (lkprsp.m_owner_num == cache_id)
             && (lkprsp.m_sharer_vec == (1 << cache_id)))
            dm_state_on_lkp_e = dm_hit_as_owner_and_other_sharers_absent;
        if (     lkprsp.m_owner_val
         && (cache_id!=-1)
             && (lkprsp.m_owner_num == cache_id)
             && (lkprsp.m_sharer_vec != (1 << cache_id)))
            dm_state_on_lkp_e = dm_hit_as_owner_and_other_sharers_present;
        if (    !lkprsp.m_owner_val 
         && (cache_id!=-1)
             && (lkprsp.m_sharer_vec == (1 << cache_id)))
            dm_state_on_lkp_e = dm_hit_as_sharer_and_owner_absent_other_sharers_absent;
        if (      !lkprsp.m_owner_val 
         && (cache_id!=-1)
             && (lkprsp.m_sharer_vec == ((1 << cache_id) | lkprsp.m_sharer_vec))
             && !$onehot(lkprsp.m_sharer_vec))
            dm_state_on_lkp_e = dm_hit_as_sharer_and_owner_absent_other_sharers_present;
        if (       lkprsp.m_owner_val 
         && (cache_id!=-1)
             && (lkprsp.m_owner_num != cache_id)
             && (lkprsp.m_sharer_vec == ((1 << cache_id) | (1 << lkprsp.m_owner_num))))
            dm_state_on_lkp_e = dm_hit_as_sharer_and_owner_present_other_sharers_absent;
        if (       lkprsp.m_owner_val 
         && (cache_id!=-1)
             && (lkprsp.m_owner_num != cache_id)
             && (lkprsp.m_sharer_vec == ((1 << cache_id) | lkprsp.m_sharer_vec)) //hit as sharer
             && (lkprsp.m_sharer_vec != ((1 << cache_id) | (1 << lkprsp.m_owner_num)))
             && ($countones(lkprsp.m_sharer_vec) > 2)) //other sharers present
            dm_state_on_lkp_e = dm_hit_as_sharer_and_owner_present_other_sharers_present;
        if (      !lkprsp.m_owner_val 
             && (lkprsp.m_sharer_vec != ((1 << cache_id) | lkprsp.m_sharer_vec)) //hit as neither
             && ($countones(lkprsp.m_sharer_vec) >= 1)) //other sharers present
            dm_state_on_lkp_e = dm_hit_as_neither_and_owner_absent_other_sharers_present;
        if (       lkprsp.m_owner_val 
             && (lkprsp.m_owner_num  != cache_id)
             && (lkprsp.m_sharer_vec != ((1 << cache_id) | lkprsp.m_sharer_vec)) //hit as neither
             && ($countones(lkprsp.m_sharer_vec) == 1)) //only owner present
            dm_state_on_lkp_e = dm_hit_as_neither_and_owner_present_other_sharers_absent;
        if (       lkprsp.m_owner_val 
             && (lkprsp.m_owner_num  != cache_id)
             && (lkprsp.m_sharer_vec != ((1 << cache_id) | lkprsp.m_sharer_vec)) //hit as neither
             && ($countones(lkprsp.m_sharer_vec) >= 2)) // other sharers and owner present
            dm_state_on_lkp_e = dm_hit_as_neither_and_owner_present_other_sharers_present;
    end
    else begin // hit as neither because cache_id = -1 represents NC
        if (      (lkprsp.m_owner_val == 0) 
             && ($countones(lkprsp.m_sharer_vec) >= 1)) //other sharers present
            dm_state_on_lkp_e = dm_hit_as_neither_and_owner_absent_other_sharers_present;
        if (       lkprsp.m_owner_val 
             && (lkprsp.m_owner_num  != cache_id)
             && ($countones(lkprsp.m_sharer_vec) == 1)) //only owner present
            dm_state_on_lkp_e = dm_hit_as_neither_and_owner_present_other_sharers_absent;
        if (       lkprsp.m_owner_val 
             && (lkprsp.m_owner_num  != cache_id)
             && ($countones(lkprsp.m_sharer_vec) >= 2)) // other sharers and owner present
            dm_state_on_lkp_e = dm_hit_as_neither_and_owner_present_other_sharers_present;
    end

    if(    dce_goldenref_model::is_stash_request(cmd_type) )      // For Stash Request
    begin
        stsh_nid = addrMgrConst::get_cache_id(cmdreq.smi_mpf1_stash_nid);
        if (lkprsp.is_dm_miss()) begin
            dm_state_on_lkp_stash = dm_miss_stash;
        end else if (stsh_nid != -1) begin //dm_hit Coherent agent
            if (     lkprsp.m_owner_val
                 && (lkprsp.m_owner_num == stsh_nid)
                 && (lkprsp.m_sharer_vec == (1 << stsh_nid)))
                dm_state_on_lkp_stash = dm_hit_trgt_as_owner_and_other_sharers_absent;
            if (     lkprsp.m_owner_val
                 && (lkprsp.m_owner_num == stsh_nid)
                 && (lkprsp.m_sharer_vec != (1 << stsh_nid)))
                dm_state_on_lkp_stash = dm_hit_trgt_as_owner_and_other_sharers_present;
            if (    !lkprsp.m_owner_val 
                 && (lkprsp.m_sharer_vec == (1 << stsh_nid)))
                dm_state_on_lkp_stash = dm_hit_trgt_as_sharer_and_owner_absent_other_sharers_absent;
            if (      !lkprsp.m_owner_val 
                 && (lkprsp.m_sharer_vec == ((1 << stsh_nid) | lkprsp.m_sharer_vec))
                 && !$onehot(lkprsp.m_sharer_vec))
                dm_state_on_lkp_stash = dm_hit_trgt_as_sharer_and_owner_absent_other_sharers_present;
            if (       lkprsp.m_owner_val 
                 && (lkprsp.m_owner_num != stsh_nid)
                 && (lkprsp.m_sharer_vec == ((1 << stsh_nid) | (1 << lkprsp.m_owner_num))))
                dm_state_on_lkp_stash = dm_hit_trgt_as_sharer_and_owner_present_other_sharers_absent;
            if (       lkprsp.m_owner_val 
                 && (lkprsp.m_owner_num != stsh_nid)
                 && (lkprsp.m_sharer_vec == ((1 << stsh_nid) | lkprsp.m_sharer_vec)) //hit as sharer
                 && (lkprsp.m_sharer_vec != ((1 << stsh_nid) | (1 << lkprsp.m_owner_num)))
                 && ($countones(lkprsp.m_sharer_vec) > 2)) //other sharers present
                dm_state_on_lkp_stash = dm_hit_trgt_as_sharer_and_owner_present_other_sharers_present;
            if (      !lkprsp.m_owner_val 
                 && (lkprsp.m_sharer_vec != ((1 << stsh_nid) | lkprsp.m_sharer_vec)) //hit as neither
                 && ($countones(lkprsp.m_sharer_vec) >= 1)) //other sharers present
                dm_state_on_lkp_stash = dm_hit_trgt_as_neither_and_owner_absent_other_sharers_present;
            if (       lkprsp.m_owner_val 
                 && (lkprsp.m_owner_num  != stsh_nid)
                 && (lkprsp.m_sharer_vec != ((1 << stsh_nid) | lkprsp.m_sharer_vec)) //hit as neither
                 && ($countones(lkprsp.m_sharer_vec) == 1)) //only owner present
                dm_state_on_lkp_stash = dm_hit_trgt_as_neither_and_owner_present_other_sharers_absent;
            if (       lkprsp.m_owner_val 
                 && (lkprsp.m_owner_num  != stsh_nid)
                 && (lkprsp.m_sharer_vec != ((1 << stsh_nid) | lkprsp.m_sharer_vec)) //hit as neither
                 && ($countones(lkprsp.m_sharer_vec) >= 2)) // other sharers and owner present
                dm_state_on_lkp_stash = dm_hit_trgt_as_neither_and_owner_present_other_sharers_present;
        end
    else if(stsh_nid == -1) begin
        if (      !lkprsp.m_owner_val
                 && ($countones(lkprsp.m_sharer_vec) >= 1)) //other sharers present
                dm_state_on_lkp_stash = dm_hit_trgt_as_neither_and_owner_absent_other_sharers_present;
            if (       lkprsp.m_owner_val 
                 && (lkprsp.m_owner_num  != stsh_nid)
                 && ($countones(lkprsp.m_sharer_vec) == 1)) //only owner present
                dm_state_on_lkp_stash = dm_hit_trgt_as_neither_and_owner_present_other_sharers_absent;
            if (       lkprsp.m_owner_val 
                 && (lkprsp.m_owner_num  != stsh_nid)
                 && ($countones(lkprsp.m_sharer_vec) >= 2)) // other sharers and owner present
                dm_state_on_lkp_stash = dm_hit_trgt_as_neither_and_owner_present_other_sharers_present;
    end
        
    end
    
    // CONC-7661 commenting the checkers
    /*  if(dm_state_on_lkp_e == dm_hit_as_sharer_and_owner_present_other_sharers_present && mrd_sample == 1 && dce_goldenref_model::is_read(cmd_type) && !$test$plusargs("en_silent_cache_st_transition"))
                `uvm_error("DCE_COV", $psprintf("dm_lkprsp = %p and %s", dm_state_on_lkp_e,txn.print_txn))
        if(dm_state_on_lkp_e == dm_hit_as_sharer_and_owner_present_other_sharers_absent && mrd_sample == 1 && dce_goldenref_model::is_read(cmd_type) && !$test$plusargs("en_silent_cache_st_transition"))
                `uvm_error("DCE_COV", $psprintf("dm_lkprsp = %p and %s", dm_state_on_lkp_e,txn.print_txn))
        if(dm_state_on_lkp_stash == dm_hit_trgt_as_owner_and_other_sharers_absent && mrd_sample == 1 && mrdreq.smi_msg_type == eMsgMRD'(MRD_RD_WITH_SHR_CLN) && dce_goldenref_model::is_stash_read(cmd_type) && !$test$plusargs("en_silent_cache_st_transition"))
                `uvm_error("DCE_COV_DBG", $psprintf("dm_state_on_lkp_stash = %p, MRD = %p and %s", dm_state_on_lkp_stash, mrdreq.smi_msg_type, txn.print_txn))
        if(mrd_sample == 1) begin
            if(dm_state_on_lkp_stash inside {dm_hit_trgt_as_neither_and_owner_present_other_sharers_absent, dm_hit_trgt_as_neither_and_owner_present_other_sharers_present, dm_hit_trgt_as_sharer_and_owner_present_other_sharers_absent, dm_hit_trgt_as_sharer_and_owner_present_other_sharers_present} && mrdreq.smi_msg_type == eMsgMRD'(MRD_PREF) && dce_goldenref_model::is_stash_read(cmd_type) && mrd_sample == 1 && (lkprsp.m_owner_num != cache_id))
                `uvm_error("DCE_COV_DBG", $psprintf("dm_state_on_lkp_stash = %p, MRD = %p, cmd = %p , stash_target = %p(%p), requester cache_id = %p, owner_number = %p and %s", dm_state_on_lkp_stash, mrdreq.smi_msg_type, cmd_type, cmdreq.smi_mpf1_stash_nid, addrMgrConst::get_native_interface(cmdreq.smi_mpf1_stash_nid), cache_id, lkprsp.m_owner_num,txn.print_txn))
        end */

    agentid = addrMgrConst::agentid_assoc2funitid(dm_cmdreq.m_iid >> WSMINCOREPORTID);
    
        cg_dm_lkprsp.sample(dm_cmdreq.m_alloc, addrMgrConst::get_native_interface(agentid));
    if(mrd_sample == 1 && (dce_goldenref_model::is_stash_read(cmd_type) || dce_goldenref_model::is_read(cmd_type))) begin
        cg_mrd_req.sample(dm_cmdreq.m_alloc, addrMgrConst::get_native_interface(agentid));
    end
    
    collect_message_timing(txn);
    
    if(snp_sample == 1) begin
        cg_snp_req.sample(cmd_type, snpreq.smi_up, snpreq.smi_mpf3_intervention_unit_id);
    end
    
    if(txn.m_expstr_req_pkt != null) begin
        $cast(strreq, txn.m_expstr_req_pkt.clone());
        cg_strreq.sample(strreq.smi_cmstatus_state,addrMgrConst::get_native_interface(agentid));
    end
    if(lkprsp.m_error != 1) begin
        if(txn.dm_lkprsp.m_sharer_vec != 0) begin
            if(txn.dm_lkprsp.m_owner_val) begin
                agent_idq = addrMgrConst::get_agent_ids_assoc2cacheid(txn.dm_lkprsp.m_owner_num);
                if(txn.snoop_enable_reg_txn[agent_idq[0]] == 0)
                    owner_sharer_attach_detached = owner_detached;
                else
                    owner_sharer_attach_detached = owner_attached;
                cg_attach_detach.sample();
            end
            foreach(txn.dm_lkprsp.m_sharer_vec[x]) begin
                if(txn.dm_lkprsp.m_sharer_vec[x] != lkprsp.m_sharer_vec[x]) begin
                    owner_sharer_attach_detached = sharer_detached;
                    cg_attach_detach.sample();
                end
                else begin
                    owner_sharer_attach_detached = sharer_attached;
                    cg_attach_detach.sample();
                end
            end
        end
    end
    
    if(txn.m_expsnp_req_pktq.size() != 0) begin //Adding code to capture SnpRsp.Err and Corresponding StrReq.Err
        foreach(txn.m_drvsnp_rsp_pktq[i]) begin
            if(txn.m_drvsnp_rsp_pktq[i].smi_cmstatus_err == 1) begin
                err_snprsp = txn.m_drvsnp_rsp_pktq[i].smi_cmstatus;
            end
            else begin
                dt_aiu |= txn.m_drvsnp_rsp_pktq[i].smi_cmstatus_dt_aiu;
            end
        end
        if(strreq.smi_cmstatus inside {'b1000_0100, 'b1000_0011})
            cg_snprsp_err.sample(cmd_type,err_snprsp, dt_aiu, strreq.smi_cmstatus);
        else
            cg_snprsp_err.sample(cmd_type,err_snprsp, dt_aiu, 'b0); //STR no error status
        //`uvm_info("DCE_COV", $psprintf("Got err cmstatus = %0x",err_snprsp), UVM_LOW)
    end
    if(txn.m_expmrd_req_pkt != null) begin
        if(txn.m_drvmrd_rsp_pkt.smi_cmstatus_err == 1) begin
            cg_mrdrsp_err.sample(cmd_type,txn.m_drvmrd_rsp_pkt.smi_cmstatus);
        end
    end

    cg_rbreq.sample(txn.m_states["rbrreq"].get_valid_count());
endfunction: collect_dce_scb_txn

function void dce_coverage::collect_exmon_scenario(int agentid, int procid, eMsgCMD cmd_type, exmon_state_e exmon_state);  
    this.exld_cmd_type     = cmd_type;
    this.exmon_state       = exmon_state; 
    cg_exmon.sample(agentid, procid);
endfunction: collect_exmon_scenario

function void dce_coverage::collect_sys_event_cov(dce_scb_txn sys_ev_msg);

    cg_sys_event.sample(sys_ev_msg);

endfunction: collect_sys_event_cov  

//This function is called on lkprsp, updreq, recreq
function void dce_coverage::collect_recall_qos(bit use_eviction_qos, int eviction_qos);
    cg_recall_qos.sample(use_eviction_qos, eviction_qos);
endfunction: collect_recall_qos

//This function is called on lkprsp, updreq, recreq
function void dce_coverage::collect_dirm_scenario(directory_mgr dirm);  

<%  obj.SnoopFilterInfo.forEach(function(bundle, idx, array) {%>
    cg_sf_<%=idx%>.sample(dirm.m_sampleq[<%=idx%>], dirm.m_hit_swap_wayq[<%=idx%>], dirm.m_alloc_evct_wayq[<%=idx%>]);
<%      })%>

    cg_dm.sample(dirm);
endfunction: collect_dirm_scenario

//This function is called only on rtyrsp
function void dce_coverage::collect_dirm_scenario_on_rtyrsp(directory_mgr dirm);  
    //dirm.print_cov_data();
    //`uvm_error("DCE_COV", $psprintf("End early"))
    //cg_dm.sample(dirm);

<%obj.SnoopFilterInfo.forEach(function(bundle, idx, array) {%>
  <%if(obj.DceInfo[0].nAttCtrlEntries > bundle.nWays){%>
    cg_rtyrsp_sf_<%=idx%>.sample(dirm.m_sampleq[<%=idx%>], dirm.m_hit_swap_wayq[<%=idx%>], dirm.m_alloc_evct_wayq[<%=idx%>]);
  <%}%>
<%})%>

endfunction: collect_dirm_scenario_on_rtyrsp

<%if (obj.DceInfo[0].fnEnableQos == 1) {%>
function void dce_coverage::collect_qoscr_event_threshold(int qoscr_event_threshold_value);

    cg_qoscr_et.sample(qoscr_event_threshold_value);

endfunction: collect_qoscr_event_threshold

<%}%>

    
function void dce_coverage::collect_back_to_back_allocs(dm_seq_item lkprsp, int iid);
    bit alloc_req;
    eMsgCMD cmd_type_lkprsp;
    int cache_id;

    
    cache_id = addrMgrConst::get_cache_id(iid);
 

    $cast(cmd_type_lkprsp, lkprsp.m_type);  
    alloc_req = dce_goldenref_model::is_master_allocating_req(cmd_type_lkprsp);
    //`uvm_info("DCE_COV_debug", $psprintf("cmd_type from lkprsp: %p",cmd_type_lkprsp), UVM_LOW)

        //`uvm_info("DCE_COV_debug", $psprintf("cache_id from txn: %p",cache_id), UVM_LOW)

    case(flag)
        2'b00 : flag = alloc_req ? 2'b01 : 2'b00;
        2'b01 : flag = alloc_req ? 2'b10 : 2'b00;
        2'b10 : flag = alloc_req ? 2'b11 : 2'b00;
        2'b11 : flag = alloc_req ? 2'b01 : 2'b00;
    endcase

    if(flag!=0) begin
    
        btb_allocs[flag-1].sf_num = lkprsp.m_filter_num;
        btb_allocs[flag-1].cmd_addr = lkprsp.m_addr;
        btb_allocs[flag-1].set_index = lkprsp.m_set_index;
        btb_allocs[flag-1].cmd_time = lkprsp.m_cycle_count;
            //`uvm_info("DCE_COV_debug", $psprintf("0: %p",lkprsp.m_filter_num), UVM_LOW)
        
        if (lkprsp.m_rtl_vbhit_sfvec[lkprsp.m_filter_num] == 1) begin
            btb_allocs[flag-1].vb_hit = 1;
            btb_allocs[flag-1].tag_hit = 0;
            btb_allocs[flag-1].miss = 0;
        end
        else if (lkprsp.m_sharer_vec != 0 && lkprsp.m_rtl_vbhit_sfvec[lkprsp.m_filter_num] != 1) begin
            btb_allocs[flag-1].tag_hit = 1;
            btb_allocs[flag-1].vb_hit = 0;
            btb_allocs[flag-1].miss = 0;
        end
        else begin
            btb_allocs[flag-1].tag_hit = 0;
            btb_allocs[flag-1].vb_hit = 0;
            btb_allocs[flag-1].miss = 1;
        end
    end
    if(flag == 2) begin
        if((btb_allocs[0].cmd_time + 1) != btb_allocs[1].cmd_time) begin
            btb_allocs[0] = btb_allocs[1];
            flag = 1;
            btb_allocs[1] = empty_struct;
        end
    end
    if(flag == 3) begin
        if((btb_allocs[0].cmd_time + 2) != btb_allocs[2].cmd_time) begin
            btb_allocs[0] = btb_allocs[2];
            btb_allocs[1] = empty_struct;
            btb_allocs[2] = empty_struct;
            flag = 1;
        end
        else if((btb_allocs[1].cmd_time + 1) != btb_allocs[2].cmd_time) begin
            btb_allocs[1] = btb_allocs[2];
            flag = 2;
            btb_allocs[2] = empty_struct;
        end
    end
        //`uvm_info("DCE_COV_debug", $psprintf("btb: %p and flag = %d",btb_allocs, flag), UVM_LOW)
             
if (flag == 3) begin
    if((btb_allocs[0].cmd_addr == btb_allocs[1].cmd_addr) || (btb_allocs[0].cmd_addr == btb_allocs[2].cmd_addr) || (btb_allocs[1].cmd_addr == btb_allocs[2].cmd_addr)) begin
    
                btb_allocs[0] = btb_allocs[1];
                btb_allocs[1] = btb_allocs[2];
                btb_allocs[2] = empty_struct;
                flag = 2;
    end
    else begin
        if((btb_allocs[0].sf_num == btb_allocs[1].sf_num) && (btb_allocs[0].sf_num == btb_allocs[2].sf_num) && (btb_allocs[1].sf_num == btb_allocs[2].sf_num)) begin
            if((btb_allocs[0].set_index == btb_allocs[1].set_index) && (btb_allocs[0].set_index == btb_allocs[2].set_index) && (btb_allocs[1].set_index == btb_allocs[2].set_index)) begin
                if({btb_allocs[0].vb_hit,btb_allocs[1].vb_hit,btb_allocs[2].vb_hit} == 3'b111) begin
                    back_back_alloc_state = back_back_allocating_requests_same_SF_same_setaddr_all_vb_hits; 
                    cg_back_to_back_allocs.sample();
                end
                else if({btb_allocs[0].tag_hit,btb_allocs[1].tag_hit,btb_allocs[2].tag_hit} == 3'b111) begin
                    back_back_alloc_state = back_back_allocating_requests_same_SF_same_setaddr_all_tag_hits; 
                    cg_back_to_back_allocs.sample();
                end
                else if({btb_allocs[0].miss,btb_allocs[1].miss,btb_allocs[2].miss} == 3'b111) begin
                    back_back_alloc_state = back_back_allocating_requests_same_SF_same_setaddr_all_misses;
                    cg_back_to_back_allocs.sample();
                end
 
                back_back_alloc_state = back_back_allocating_requests_same_SF_same_setaddr_different_tagaddr; 
                cg_back_to_back_allocs.sample();

                btb_allocs[0] = btb_allocs[1];
                btb_allocs[1] = btb_allocs[2];
                btb_allocs[2] = empty_struct;
                flag = 2;
            end
            else begin
                btb_allocs[0] = btb_allocs[1];
                btb_allocs[1] = btb_allocs[2];
                btb_allocs[2] = empty_struct;
                flag = 2;
            end 
        end
        else begin
            btb_allocs[0] = btb_allocs[1];
            btb_allocs[1] = btb_allocs[2];
            btb_allocs[2] = empty_struct;
            flag = 2;
        end 
    end
end
endfunction : collect_back_to_back_allocs

function void dce_coverage::collect_back_to_back_non_allocs(dm_seq_item lkprsp, int iid);
    bit non_alloc_req;
    eMsgCMD cmd_type_lkprsp;
    int cache_id;

    
    cache_id = addrMgrConst::get_cache_id(iid);
 

    $cast(cmd_type_lkprsp, lkprsp.m_type);  
    non_alloc_req = !dce_goldenref_model::is_master_allocating_req(cmd_type_lkprsp);

    case(non_alloc_flag)
        2'b00 : non_alloc_flag = non_alloc_req ? 2'b01 : 2'b00;
        2'b01 : non_alloc_flag = non_alloc_req ? 2'b10 : 2'b00;
        2'b10 : non_alloc_flag = non_alloc_req ? 2'b11 : 2'b00;
        2'b11 : non_alloc_flag = non_alloc_req ? 2'b01 : 2'b00;
    endcase

    if(non_alloc_flag!=0) begin
    
        btb_nonallocs[non_alloc_flag-1].sf_num = lkprsp.m_filter_num;
        btb_nonallocs[non_alloc_flag-1].cmd_addr = lkprsp.m_addr;
        btb_nonallocs[non_alloc_flag-1].set_index = lkprsp.m_set_index;
        btb_nonallocs[non_alloc_flag-1].cmd_time = lkprsp.m_cycle_count;
        
        if (lkprsp.m_rtl_vbhit_sfvec[lkprsp.m_filter_num] == 1) begin
            btb_nonallocs[non_alloc_flag-1].vb_hit = 1;
            btb_nonallocs[non_alloc_flag-1].tag_hit = 0;
            btb_nonallocs[non_alloc_flag-1].miss = 0;
        end
        else if (lkprsp.m_sharer_vec != 0 && lkprsp.m_rtl_vbhit_sfvec[lkprsp.m_filter_num] != 1) begin
            btb_nonallocs[non_alloc_flag-1].tag_hit = 1;
            btb_nonallocs[non_alloc_flag-1].vb_hit = 0;
            btb_nonallocs[non_alloc_flag-1].miss = 0;
        end
        else begin
            btb_nonallocs[non_alloc_flag-1].tag_hit = 0;
            btb_nonallocs[non_alloc_flag-1].vb_hit = 0;
            btb_nonallocs[non_alloc_flag-1].miss = 1;
        end
    end
    if(non_alloc_flag == 2) begin
        if((btb_nonallocs[0].cmd_time + 1) != btb_nonallocs[1].cmd_time) begin
            btb_nonallocs[0] = btb_nonallocs[1];
            non_alloc_flag = 1;
            btb_nonallocs[1] = empty_struct;
        end
    end
    if(non_alloc_flag == 3) begin
        if((btb_nonallocs[0].cmd_time + 2) != btb_nonallocs[2].cmd_time) begin
            btb_nonallocs[0] = btb_nonallocs[2];
            btb_nonallocs[1] = empty_struct;
            btb_nonallocs[2] = empty_struct;
            non_alloc_flag = 1;
        end
        else if((btb_nonallocs[1].cmd_time + 1) != btb_nonallocs[2].cmd_time) begin
            btb_nonallocs[1] = btb_nonallocs[2];
            non_alloc_flag = 2;
            btb_nonallocs[2] = empty_struct;
        end
    end
             
if (non_alloc_flag == 3) begin
    if((btb_nonallocs[0].cmd_addr == btb_nonallocs[1].cmd_addr) || (btb_nonallocs[0].cmd_addr == btb_nonallocs[2].cmd_addr) || (btb_nonallocs[1].cmd_addr == btb_nonallocs[2].cmd_addr)) begin
    
                btb_nonallocs[0] = btb_nonallocs[1];
                btb_nonallocs[1] = btb_nonallocs[2];
                btb_nonallocs[2] = empty_struct;
                non_alloc_flag = 2;
    end
    else begin
        if((btb_nonallocs[0].sf_num == btb_nonallocs[1].sf_num) && (btb_nonallocs[0].sf_num == btb_nonallocs[2].sf_num) && (btb_nonallocs[1].sf_num == btb_nonallocs[2].sf_num)) begin
            if((btb_nonallocs[0].set_index == btb_nonallocs[1].set_index) && (btb_nonallocs[0].set_index == btb_nonallocs[2].set_index) && (btb_nonallocs[1].set_index == btb_nonallocs[2].set_index)) begin
                if({btb_nonallocs[0].vb_hit,btb_nonallocs[1].vb_hit,btb_nonallocs[2].vb_hit} == 3'b111) begin
                    back_back_non_alloc_state = back_back_non_allocating_requests_same_SF_same_setaddr_all_vb_hits;
                    cg_back_to_back_non_allocs.sample();
                end
                else if({btb_nonallocs[0].tag_hit,btb_nonallocs[1].tag_hit,btb_nonallocs[2].tag_hit} == 3'b111) begin
                    back_back_non_alloc_state = back_back_non_allocating_requests_same_SF_same_setaddr_all_tag_hits;
                    cg_back_to_back_non_allocs.sample();
                end
                else if({btb_nonallocs[0].miss,btb_nonallocs[1].miss,btb_nonallocs[2].miss} == 3'b111) begin
                    back_back_non_alloc_state = back_back_non_allocating_requests_same_SF_same_setaddr_all_misses;
                    cg_back_to_back_non_allocs.sample();
                end
 
                back_back_non_alloc_state = back_back_non_allocating_requests_same_SF_same_setaddr_different_tagaddr; 
                cg_back_to_back_non_allocs.sample();

                btb_nonallocs[0] = btb_nonallocs[1];
                btb_nonallocs[1] = btb_nonallocs[2];
                btb_nonallocs[2] = empty_struct;
                non_alloc_flag = 2;
            end
            else begin
                btb_nonallocs[0] = btb_nonallocs[1];
                btb_nonallocs[1] = btb_nonallocs[2];
                btb_nonallocs[2] = empty_struct;
                non_alloc_flag = 2;
            end 
        end
        else begin
            btb_nonallocs[0] = btb_nonallocs[1];
            btb_nonallocs[1] = btb_nonallocs[2];
            btb_nonallocs[2] = empty_struct;
            non_alloc_flag = 2;
        end 
    end
end
endfunction : collect_back_to_back_non_allocs

function void dce_coverage::collect_message_timing(dce_scb_txn txn);

    bit flag_time;
    bit[1:0] str_time;

    if (txn.time_struct.dm_write !== 'hx) begin
        if(txn.time_struct.dm_write < txn.time_struct.str_req)
            str_time = 1;
        if(txn.time_struct.dm_write > txn.time_struct.str_req)
            str_time = 2;
    end

    if(txn.time_struct.snp_req === 'hx)
        return;

    if(txn.time_struct.rbrsv_req !== 'hx) begin
        if(txn.time_struct.snp_rsp < txn.time_struct.rbrsv_req)
            timing_order = snpreq_snprsp_rbrsv;
        else if((txn.time_struct.snp_req < txn.time_struct.rbrsv_req) && (txn.time_struct.rbrsv_req < txn.time_struct.snp_rsp))
            timing_order = snpreq_rbrsv_snprsp;
        else if(txn.time_struct.rbrsv_req < txn.time_struct.snp_req)
            timing_order = rbrsv_snpreq_snprsp;
        flag_time = 1;
    end

    if(flag_time == 1)
        cg_message_timing.sample(flag_time,0);
    if(str_time inside {1,2})
        cg_message_timing.sample(0,str_time);



endfunction : collect_message_timing


function void dce_coverage::collect_back_back_cmd_upd_reqs(dm_seq_item packet);
dm_seq_item pckt;
bit [2:0] cov_msg_type;
    
    $cast(pckt, packet.clone());
    if(pckt.m_access_type == DM_CMD_REQ)
        cov_msg_type = 3'b100;
    else if(pckt.m_access_type == DM_UPD_REQ)
        cov_msg_type = 3'b010;
    else if(pckt.m_access_type == DM_CMT_REQ)
        cov_msg_type = 3'b001;
    
    if(back_collect_reqs[0].type_msg inside {'b100,'b001} && ((back_collect_reqs[0].address >> addrMgrConst::WCACHE_OFFSET) == (pckt.m_addr >> addrMgrConst::WCACHE_OFFSET))) begin
        if(cov_msg_type == 'b010)
            set_flag = 1;
        else
            set_flag = 0;
    end
    else if (back_collect_reqs[0].type_msg == 'b010 && ((back_collect_reqs[0].address >> addrMgrConst::WCACHE_OFFSET) == (pckt.m_addr >> addrMgrConst::WCACHE_OFFSET))) begin
        if(cov_msg_type inside {'b100,'b001})
            set_flag = 1;
        else
            set_flag = 0;
    end
    else
        set_flag = 0;
    
    back_collect_reqs[set_flag].rcvd_time = pckt.m_cycle_count;
    back_collect_reqs[set_flag].address = pckt.m_addr;
    back_collect_reqs[set_flag].type_msg = cov_msg_type;
    
    if(set_flag == 1) begin
        if((back_collect_reqs[0].type_msg == 'b100) && (back_collect_reqs[1].type_msg == 'b010)) begin
            case (back_collect_reqs[1].rcvd_time - back_collect_reqs[0].rcvd_time)
            0       :   begin
                            cmd_upd_order = cmd_upd_same_cycle;     
                            cg_back_reqs.sample(2'b10);
                        end
            1       :   begin
                            cmd_upd_order = cmd_upd_one_cycle;
                            cg_back_reqs.sample(2'b10);
                        end
            2       :   begin
                            cmd_upd_order = cmd_upd_two_cycle; 
                            cg_back_reqs.sample(2'b10);
                        end
            3       :   begin
                            cmd_upd_order = cmd_upd_three_cycle; 
                            cg_back_reqs.sample(2'b10);
                        end
            4       :   begin
                            cmd_upd_order = cmd_upd_four_cycle; 
                            cg_back_reqs.sample(2'b10);
                        end
            endcase
        end
        if((back_collect_reqs[0].type_msg inside {'b010,'b001}) && (back_collect_reqs[1].type_msg inside {'b010,'b001})) begin
            if(back_collect_reqs[1].rcvd_time - back_collect_reqs[0].rcvd_time == 0) begin
                upd_cmt_order = upd_cmt_same_cycle; 
                cg_back_reqs.sample(2'b01); 
            end
            else if(back_collect_reqs[1].rcvd_time - back_collect_reqs[0].rcvd_time == 1) begin
                if(back_collect_reqs[0].type_msg == 'b010) begin
                    upd_cmt_order = upd_before_cmt_one_cycle;
                    cg_back_reqs.sample(2'b01);
                end
                else if(back_collect_reqs[1].type_msg == 'b010) begin
                    upd_cmt_order = upd_after_cmt_one_cycle;    
                    cg_back_reqs.sample(2'b01);
                end
            end

        end
        
        back_collect_reqs[0] = back_collect_reqs[1];
        set_flag = 0;
    end
endfunction : collect_back_back_cmd_upd_reqs

<% if(obj.DceInfo[obj.Id].CMDOverflowBufInSRAM == true) { %>
function void dce_coverage::collect_skidbuff_err_csr (bit type_of_error_csr, bit skidbuf_err_det_bit_csr, bit skidbuf_int_bit_csr, bit [3:0] skidbuf_uesr_err_type_csr);
    $display("Skidbuf error coverage values before sampling 1 type_of_error_csr = %0b, skidbuf_err_det_bit_csr = %0b , skidbuf_int_bit_csr = %0b , skidbuf_uesr_err_type_csr = %0h", type_of_error_csr, skidbuf_err_det_bit_csr, skidbuf_int_bit_csr, skidbuf_uesr_err_type_csr);
    type_of_error = type_of_error_csr;
    skidbuf_err_det_bit = skidbuf_err_det_bit_csr;
    skidbuf_int_bit = skidbuf_int_bit_csr;
    sram_enabled = skidbuf_uesr_err_type_csr;
     $display("Skidbuf error coverage values before sampling 2 type_of_error = %0b, skidbuf_err_det_bit = %0b , skidbuf_int_bit = %0b , sram_enabled = %0h", type_of_error, skidbuf_err_det_bit, skidbuf_int_bit, sram_enabled);
    skidbuf_error_testing.sample();
endfunction
<% } %>
