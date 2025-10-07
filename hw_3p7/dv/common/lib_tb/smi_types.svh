//
// SMI Types 
//
 
<% if ( obj.interfaces.smiRxInt[obj.interfaces.smiRxInt.length-1].params.wSmiDPdata > 0 ) { %>
localparam int wSmiDPdata = <%=obj.interfaces.smiRxInt[obj.interfaces.smiRxInt.length-1].params.wSmiDPdata%>;
<% } else { %>
localparam int wSmiDPdata     =  <%=obj.Widths.Concerto.Dp.Data.wDpData%>;
<% } %>
localparam int wSmiDPbe       = ((wSmiDPdata/64)*WSMIDPBEPERDW);
localparam int wSmiDPprot     = ((wSmiDPdata/64)*WSMIDPPROTPERDW);
localparam int wSmiDPdwid     = ((wSmiDPdata/64)*WSMIDPDWIDPERDW);
localparam int wSmiDPconcuser = ((wSmiDPdata/64)*WSMIDPCONCUSERPERDW);
localparam int wSmiDPuser     = ((wSmiDPdata/64)*WSMIDPUSERPERDW);
localparam int wSmiDPdbad     = ((wSmiDPdata/64)*WSMIDPDBADPERDW);

// SMI DPdata+DPdbad+DPdwid+DPconcuser+DPbe. Also has space for DP protection
localparam int wSmiDPbundleNoProt = (64+WSMIDPBEPERDW+WSMIDPCONCUSERPERDW+WSMIDPDWIDPERDW+WSMIDPDBADPERDW);
localparam int wSmiDPbundle       = (wSmiDPbundleNoProt + WSMIDPPROTPERDW);
// Field offset within DPuser
localparam int SmiDPUserBeL     = 0;
localparam int SmiDPUserBeM     = (SmiDPUserBeL   + WSMIDPBEPERDW - 1);
localparam int SmiDPUserConcL   = (SmiDPUserBeM + 1 );
localparam int SmiDPUserConcM   = (SmiDPUserConcL + WSMIDPCONCUSERPERDW - ((WSMIDPCONCUSERPERDW > 0) ? 1 : 0));
localparam int SmiDPUserProtL   = (SmiDPUserConcM + ((WSMIDPCONCUSERPERDW > 0)?1:0));
localparam int SmiDPUserProtM   = (SmiDPUserProtL + WSMIDPPROTPERDW - ((WSMIDPPROTPERDW > 0) ? 1 : 0));
localparam int SmiDPUserDwidL   = (SmiDPUserProtM + ((WSMIDPPROTPERDW > 0)?1:0));
localparam int SmiDPUserDwidM   = (SmiDPUserDwidL + WSMIDPDWIDPERDW - 1);
localparam int SmiDPUserDbadL   = (SmiDPUserDwidM + 1);
localparam int SmiDPUserDbadM   = (SmiDPUserDbadL + WSMIDPDBADPERDW - 1);
// Field offset when DPPROT is moved out of DPUSER (for ECC generation and checking)
localparam int SmiDPUserDwidNpL = (SmiDPUserConcM + ((WSMIDPCONCUSERPERDW > 0)?1:0));
localparam int SmiDPUserDwidNpM = (SmiDPUserDwidNpL + WSMIDPDWIDPERDW - 1);
localparam int SmiDPUserDbadNpL = (SmiDPUserDwidNpM + 1);
localparam int SmiDPUserDbadNpM = (SmiDPUserDbadNpL + WSMIDPDBADPERDW - 1);
localparam int SmiDPUserProtNpL = (SmiDPUserDbadNpM + 1);
localparam int SmiDPUserProtNpM = (SmiDPUserProtNpL + WSMIDPPROTPERDW - ((WSMIDPPROTPERDW>0)?1:0));

//ndp max ECC protection width
<% if (obj.Widths.Physical.wNdpBody <= 110) { %>
localparam int wSmiNdpProt    = 8;
<% } else if (obj.Widths.Physical.wNdpBody <= 237) { %>
localparam int wSmiNdpProt    = 9;
<% } else { %>
localparam int wSmiNdpProt    = 10;
<% } %>
// need to add protection field width
localparam int w_CMD_REQ_NDP        = (W_CMD_REQ_NDP + <%=obj.AiuInfo[0].concParams.cmdReqParams.wMProt%>);
localparam int w_C_CMD_RSP_NDP      = (W_C_CMD_RSP_NDP + <%=obj.AiuInfo[0].concParams.cmdRspParams.wMProt%>);
localparam int w_NC_CMD_RSP_NDP     = (W_NC_CMD_RSP_NDP + <%=obj.AiuInfo[0].concParams.ncCmdRspParams.wMProt%>);
localparam int w_SNP_REQ_NDP        = (W_SNP_REQ_NDP + <%=obj.AiuInfo[0].concParams.snpReqParams.wMProt%>);
localparam int w_SNP_RSP_NDP        = (W_SNP_RSP_NDP + <%=obj.AiuInfo[0].concParams.snpRspParams.wMProt%>);
//localparam int w_HNT_REQ_NDP        = (W_SNP_REQ_NDP + <%=obj.AiuInfo[0].concParams.cmdReqParams.wMProt%>);
//localparam int w_HNT_RSP_NDP        = (W_SNP_RSP_NDP + <%=obj.AiuInfo[0].concParams.cmdRspParams.wMProt%>);
localparam int w_MRD_REQ_NDP        = (W_MRD_REQ_NDP + <%=obj.AiuInfo[0].concParams.mrdReqParams.wMProt%>);
localparam int w_MRD_RSP_NDP        = (W_MRD_RSP_NDP + <%=obj.AiuInfo[0].concParams.mrdRspParams.wMProt%>);
localparam int w_STR_REQ_NDP        = (W_STR_REQ_NDP + <%=obj.AiuInfo[0].concParams.strReqParams.wMProt%>);
localparam int w_STR_RSP_NDP        = (W_STR_RSP_NDP + <%=obj.AiuInfo[0].concParams.strRspParams.wMProt%>);
localparam int w_DTR_REQ_NDP        = (W_DTR_REQ_NDP + <%=obj.AiuInfo[0].concParams.dtrReqParams.wMProt%>);
localparam int w_DTR_RSP_NDP        = (W_DTR_RSP_NDP + <%=obj.AiuInfo[0].concParams.dtrRspParams.wMProt%>);
localparam int w_DTW_REQ_NDP        = (W_DTW_REQ_NDP + <%=obj.AiuInfo[0].concParams.dtwReqParams.wMProt%>);
localparam int w_DTW_RSP_NDP        = (W_DTW_RSP_NDP + <%=obj.AiuInfo[0].concParams.dtwRspParams.wMProt%>);
localparam int w_DTW_DBG_REQ_NDP    = (W_DTW_REQ_NDP + <%=obj.AiuInfo[0].concParams.dtwReqParams.wMProt%>);
localparam int w_DTW_DBG_RSP_NDP    = (W_DTW_RSP_NDP + <%=obj.AiuInfo[0].concParams.dtwRspParams.wMProt%>);
localparam int w_UPD_REQ_NDP        = (W_UPD_REQ_NDP + <%=obj.AiuInfo[0].concParams.updReqParams.wMProt%>);
localparam int w_UPD_RSP_NDP        = (W_UPD_RSP_NDP + <%=obj.AiuInfo[0].concParams.updRspParams.wMProt%>);
localparam int w_RB_REQ_NDP         = (W_RB_REQ_NDP  + <%=obj.AiuInfo[0].concParams.rbrReqParams.wMProt%>);
localparam int w_RB_RSP_NDP         = (W_RB_RSP_NDP  + <%=obj.AiuInfo[0].concParams.rbrRspParams.wMProt%>);
localparam int w_SYS_REQ_NDP        = (W_SYS_REQ_NDP  + <%=obj.AiuInfo[0].concParams.sysReqParams.wMProt%>);
localparam int w_SYS_RSP_NDP        = (W_SYS_RSP_NDP  + <%=obj.AiuInfo[0].concParams.sysRspParams.wMProt%>);
localparam int w_RBUSE_REQ_NDP      = (W_RBUSE_REQ_NDP + <%=obj.AiuInfo[0].concParams.rbuReqParams.wMProt%>);
localparam int w_RBUSE_RSP_NDP      = (W_RBUSE_RSP_NDP + <%=obj.AiuInfo[0].concParams.rbuRspParams.wMProt%>);
localparam int w_CMP_RSP_NDP        = (W_CMP_RSP_NDP + <%=obj.AiuInfo[0].concParams.cmpRspParams.wMProt%>);
//localparam int w_CME_RSP_NDP        = (W_CME_RSP_NDP + <%=obj.AiuInfo[0].concParams.cmpRspParams.wMProt%>);
//localparam int w_TRE_RSP_NDP        = (W_TRE_RSP_NDP + <%=obj.AiuInfo[0].concParams.cmpRspParams.wMProt%>);

typedef logic                       smi_msg_valid_logic_t;
typedef logic                       smi_msg_ready_logic_t;
typedef logic                       smi_dp_valid_logic_t;
typedef logic                       smi_dp_ready_logic_t;
typedef logic                       smi_dp_last_logic_t;
typedef logic [WSMISTEER-1:0]       smi_steer_logic_t;
typedef logic [WSMITGTID-1:0]       smi_targ_id_logic_t;
typedef logic [WSMISRCID-1:0]       smi_src_id_logic_t;
typedef logic [WSMIMSGTIER-1:0]     smi_msg_tier_logic_t;
typedef logic [WSMIMSGQOS-1:0]      smi_msg_qos_logic_t;
typedef logic [WSMIMSGPRI-1:0]      smi_msg_pri_logic_t;
typedef logic [WSMIMSGTYPE-1:0]     smi_msg_type_logic_t;
typedef logic [WSMINDPLEN-1:0]      smi_ndp_len_logic_t;
typedef logic [WSMINDP-1:0]         smi_ndp_logic_t;
typedef logic [WSMIDPPRESENT-1:0]   smi_dp_present_logic_t;
typedef logic [WSMIMSGID-1:0]       smi_msg_id_logic_t;
typedef logic [WSMIMSGUSER-1:0]     smi_msg_user_logic_t;
<% if (obj.Widths.Concerto.Ndp.Header.wHProt > 0) { %>
typedef logic [<%=obj.Widths.Concerto.Ndp.Header.wHProt%>-1:0 ]     smi_msg_hprot_logic_t;
<% } %>
typedef logic [WSMIMSGERR-1:0]      smi_msg_err_logic_t;
typedef logic [wSmiDPdata-1:0]      smi_dp_data_logic_t;
typedef logic [wSmiDPbe-1:0]        smi_dp_be_logic_t;
typedef logic [wSmiDPuser-1:0]      smi_dp_user_logic_t;
typedef bit                         smi_msg_valid_bit_t;
typedef bit                         smi_msg_ready_bit_t;
typedef bit                         smi_dp_valid_bit_t;
typedef bit                         smi_dp_ready_bit_t;
typedef bit                         smi_dp_last_bit_t;
typedef bit [WSMITGTID-1:0]         smi_targ_id_bit_t;
typedef bit [WSMISRCID-1:0]         smi_src_id_bit_t;
typedef bit [WSMINCOREUNITID-1:0]   smi_ncore_unit_id_bit_t;
typedef bit [WSMINCOREPORTID-1:0]   smi_ncore_port_id_bit_t;
typedef bit [WSMIUNQIDENTIFIER-1:0] smi_unq_identifier_bit_t;
<% if (obj.Widths.Concerto.Ndp.Header.wSteering > 0) { %>
typedef bit [WSMISTEER-1:0]         smi_steer_bit_t;
<% } else { %>
typedef bit                         smi_steer_bit_t;
<% } %>
<% if (obj.Widths.Concerto.Ndp.Header.wTTier > 0) { %>
typedef bit [WSMIMSGTIER-1:0]       smi_msg_tier_bit_t;
<% } else { %>
typedef bit                         smi_msg_tier_bit_t;
<% } %>
<% if (obj.Widths.Concerto.Ndp.Header.wQl> 0) { %>
typedef bit [WSMIMSGQOS-1:0]        smi_msg_qos_bit_t;
<% } else { %>
typedef bit                         smi_msg_qos_bit_t;
<% } %>
typedef bit [WSMIMSGPRI-1:0]        smi_msg_pri_bit_t;
typedef bit [WSMIMSGTYPE-1:0]       smi_msg_type_bit_t;
typedef bit [WSMINDPLEN-1:0]        smi_ndp_len_bit_t;
typedef bit [WSMINDP-1:0]           smi_ndp_bit_t;
typedef bit [WSMIDPPRESENT-1:0]     smi_dp_present_bit_t;
typedef bit [WSMIMSGID-1:0]         smi_msg_id_bit_t;
typedef bit [WSMIMSGUSER-1:0]       smi_msg_user_bit_t;
<% if (obj.Widths.Concerto.Ndp.Body.wNdpAux > 0) { %>
typedef bit [<%=obj.Widths.Concerto.Ndp.Body.wNdpAux%>-1:0]          smi_ndp_aux_bit_t;
<% } else { %>
typedef bit                                                          smi_ndp_aux_bit_t;
<% } %>
<% if (obj.Widths.Concerto.Ndp.Header.wHProt > 0) { %>
typedef bit [WSMIHPROT-1:0]         smi_msg_hprot_bit_t;
<% } else { %>
typedef bit                         smi_msg_hprot_bit_t;   // variable will not be used
<% } %>
typedef bit [WSMIMSGERR-1:0]        smi_msg_err_bit_t;
typedef bit [wSmiDPdata-1:0]        smi_dp_data_bit_t;
typedef bit [wSmiDPbe-1:0]          smi_dp_be_bit_t;
typedef bit [wSmiDPuser-1:0]        smi_dp_user_bit_t;

// Ncore NDP and DP break-down defines 
typedef bit [WSMIADDR-1:0]                              smi_addr_t;
typedef bit [WSMIADDR-1+<%=obj.wSecurityAttribute%>:0]  smi_addr_security_t;
typedef bit [WSEC-1:0]                                  smi_security_t;
typedef bit [WSMIVZ-1:0]                                smi_vz_t;
typedef bit [WSMIAC-1:0]                                smi_ac_t;
typedef bit [WSMICA-1:0]                                smi_ca_t;
typedef bit [WSMICH-1:0]                                smi_ch_t;
typedef bit [WSMIST-1:0]                                smi_st_t;
typedef bit [WSMIEN-1:0]                                smi_en_t;
typedef bit [WSMIES-1:0]                                smi_es_t;
typedef bit [WSMINS-1:0]                                smi_ns_t;
typedef bit [WSMIPR-1:0]                                smi_pr_t;
typedef bit [WSMIORDER-1:0]                             smi_order_t;
typedef bit [WSMILK-1:0]                                smi_lk_t;
typedef bit [WSMIRL-1:0]                                smi_rl_t;
typedef bit [WSMITM-1:0]                                smi_tm_t;
typedef bit [WSMIPRIMARY-1:0]                           smi_prim_t;
typedef bit [WSMIMW-1:0]                                smi_mw_t;
typedef bit [WSMIMBR-1:0]                               smi_mbr_t;
<% if (obj.Widths.Concerto.Ndp.Body.wEO > 0) { %>
typedef bit [obj.Widths.Concerto.Ndp.Body.wEO-1:0]      smi_eo_t;
<% } else { %>
typedef bit                                             smi_eo_t;
<% } %>
typedef bit [WSMIUP-1:0]                                smi_up_t;
typedef bit [WSMISTASHVALID-1:0]                        smi_mpf1_stash_valid_t;
typedef bit [WSMISTASHNID-1:0]                          smi_mpf1_stash_nid_t;
typedef bit [WSMIARGV-1:0]                              smi_mpf1_argv_t;
typedef bit [WSMINCOREUNITID-1:0]                       smi_mpf1_dtr_tgt_id_t;
typedef bit [WSMIASIZE-1:0]                             smi_mpf1_asize_t;
typedef bit [WSMIALENGTH-1:0]                           smi_mpf1_alength_t;
typedef bit [WSMIBURSTTYPE-1:0]                         smi_mpf1_burst_type_t;
typedef bit [WSMIMPF1-1:0]                              smi_mpf1_dtr_long_dtw_t;
typedef bit [WSMIMPF1-1:0]                              smi_mpf1_vmid_ext_t;
typedef bit [WSMIMSGID-1:0]                             smi_mpf1_dtr_msg_id_t;
typedef bit                                             smi_mpf1_awunique_t;
typedef bit [WSMIMPF1-1:0]                              smi_mpf1_t;
typedef bit [WSMISTASHLPIDVALID-1:0]                    smi_mpf2_stash_valid_t;
typedef bit [WSMISTASHLPID-1:0]                         smi_mpf2_stash_lpid_t;
typedef bit [WSMISTASHLPIDVALID-1:0]                    smi_mpf2_flowid_valid_t;
typedef bit [WSMIFLOWID-1:0]                            smi_mpf2_flowid_t;
typedef bit [WSMIMSGID-1:0]                             smi_mpf2_dtr_msg_id_t;
typedef bit [WSMIMPF2-1:0]                              smi_mpf2_dvmop_id_t;
typedef bit [WSMIMPF2-1:0]                              smi_mpf2_snp_mpf2_t;
typedef bit [WSMIMPF2-1:0]                              smi_mpf2_str_mpf2_t;
typedef bit [WSMIMPF2-1:0]                              smi_mpf2_t;
typedef bit [WSMINCOREUNITID-1:0]                       smi_mpf3_intervention_unit_id_t;
typedef bit [WSMIMPF3-1:0]                              smi_mpf3_dvmop_portion_t;
typedef bit [WSMIMPF3-1:0]                              smi_mpf3_range_t;
typedef bit [WSMIMPF3-1:0]                              smi_mpf3_flowid_t;
typedef bit [WSMIMPF3-1:0]                              smi_mpf3_num_t;
typedef bit [WSMIINTFSIZE-1:0]                          smi_intfsize_t;
typedef bit [WSMIDESTID-1:0]                            smi_dest_id_t;
typedef bit [WSMISIZE-1:0]                              smi_size_t;
typedef bit [WSMITOF-1:0]                               smi_tof_t;
typedef bit [WSMIQOS-1:0]                               smi_qos_t;
typedef bit [WSMINDPAUX-1:0]                            smi_ndp_aux_t;
typedef bit [wSmiNdpProt-1:0]                           smi_ndp_protection_t;
typedef bit [WSMIRBID-1:0]                              smi_rbid_t;
typedef bit [WSMIRBGEN-1:0 ]                            smi_rbgen_t;
typedef bit [WSMIRTYPE-1:0]                             smi_rtype_t;
typedef bit [WSMIMSGTYPE-1:0]                           smi_type_t;
typedef bit [WSMIMSGID-1:0]                             smi_msg_id_t;
typedef bit [wSmiDPbe-1:0]                              smi_dp_be_t;
typedef bit [wSmiDPprot-1:0]                            smi_dp_protection_t;
typedef bit [wSmiDPdwid-1:0]                            smi_dp_dwid_t;
typedef bit [wSmiDPdbad-1:0]                            smi_dp_dbad_t;
typedef bit [wSmiDPconcuser-1:0]                        smi_dp_concuser_t;
typedef bit [WSMICMSTATUS-1:0]                          smi_cmstatus_t;
typedef bit [WSMICMSTATUSERR-1:0]                       smi_cmstatus_err_t;
typedef bit [WSMICMSTATUSERRPAYLOAD-1:0]                smi_cmstatus_err_payload_t;
typedef bit [WSMICMSTATUSSO-1:0]                        smi_cmstatus_so_t;
typedef bit [WSMICMSTATUSSS-1:0]                        smi_cmstatus_ss_t;
typedef bit [WSMICMSTATUSSD-1:0]                        smi_cmstatus_sd_t;
typedef bit [WSMICMSTATUSST-1:0]                        smi_cmstatus_st_t;
typedef bit [2:0]                        				smi_cmstatus_state_t;
typedef bit [WSMICMSTATUSSNARF-1:0]                     smi_cmstatus_snarf_t;
typedef bit [WSMICMSTATUSEXOK-1:0]                      smi_cmstatus_exok_t;
typedef bit [WSMICMSTATUSRV-1:0]                        smi_cmstatus_rv_t;
typedef bit [WSMICMSTATUSRS-1:0]                        smi_cmstatus_rs_t;
typedef bit [WSMICMSTATUSDC-1:0]                        smi_cmstatus_dc_t;
typedef bit [WSMICMSTATUSDTAIU-1:0]                     smi_cmstatus_dt_aiu_t;
typedef bit [WSMICMSTATUSDTDMI-1:0]                     smi_cmstatus_dt_dmi_t;
typedef bit [WSMISYSREQOP-1:0]                          smi_sysreq_op_t;

//enums

typedef enum  {SMI_TRANSMITTER, SMI_RECEIVER} smi_agent_type_enum_t;
typedef enum smi_mpf1_burst_type_t {    //TODO changing legacy enum names would affect all TBs
    //FIXED=0,  //defeature ncore 3.0
    INCR=1,
    WRAP=2 
} smi_burst_enum_t;
typedef enum smi_order_t {
    SMI_ORDER_NONE = 2'h0,
    SMI_ORDER_WRITE = 2'h1,
    SMI_ORDER_REQUEST_WR_OBS = 2'h2,
    SMI_ORDER_ENDPOINT = 2'h3
} smi_order_enum_t;
typedef enum smi_lk_t {
    SMI_LK_NOP,
    SMI_LK_LOCK,
    SMI_LK_UNLOCK
} smi_lk_enum_t;
typedef enum smi_vz_t {
    SMI_VZ_COHERENCY_DOMAIN,
    SMI_VZ_SYSTEM_DOMAIN
} smi_vz_enum_t;
typedef enum smi_ac_t {
    SMI_AC_NOALLOC_IN_SYSTEM_CACHE,
    SMI_AC_ALLOC_IN_SYSTEM_CACHE
} smi_ac_enum_t;
typedef enum smi_rl_t {
    SMI_RL_NONE,
    SMI_RL_TRANSPORT,
    SMI_RL_COHERENCY,
    SMI_RL_TRANSITIVE
} smi_rl_enum_t;
typedef enum smi_up_t {
    SMI_UP_NONE,
    SMI_UP_PRESENCE,
    SMI_UP_PROVIDER,
    SMI_UP_PERMISSION
} smi_up_enum_t;  
typedef enum smi_tof_t {
    SMI_TOF_CONC_C,
    SMI_TOF_CHI,
    SMI_TOF_ACE,
    SMI_TOF_AXI,
    SMI_TOF_PCIE
} smi_tof_enum_t;
typedef enum smi_sysreq_op_t {
    SMI_SYSREQ_NOP     = 0,
    SMI_SYSREQ_ATTACH  = 1,
    SMI_SYSREQ_DETACH  = 2,
    SMI_SYSREQ_EVENT   = 3,
    RSVD_SYSREQ_OP04   = 4,
    RSVD_SYSREQ_OP05   = 5,
    RSVD_SYSREQ_OP06   = 6,
    RSVD_SYSREQ_OP07   = 7,
    RSVD_SYSREQ_OP08   = 8,
    RSVD_SYSREQ_OP09   = 9,
    RSVD_SYSREQ_OP10   = 10,
    RSVD_SYSREQ_OP11   = 11,
    RSVD_SYSREQ_OP12   = 12,
    RSVD_SYSREQ_OP13   = 13,
    RSVD_SYSREQ_OP14   = 14,
    RSVD_SYSREQ_OP15   = 15
} smi_sysreq_op_enum_t;

//optional fields.  must guard all code pertaining in same way, else compile or ndp error.

//optional fields.  must guard all code pertaining in same way, else compile or ndp error.
//could converge protection types?

typedef enum {
   SMI_NDP_PROTECTION_NONE = 0, 
   SMI_NDP_PROTECTION_PARITY, 
   SMI_NDP_PROTECTION_ECC 
} smi_ndp_protection_enum_t;

typedef enum {
   SMI_DP_PROTECTION_NONE = 0, 
   SMI_DP_PROTECTION_PARITY, 
   SMI_DP_PROTECTION_ECC 
} smi_dp_protection_enum_t;

typedef enum {
    INJ_NO_ERROR = 0,
    INJ_HDR_ERR     ,
    INJ_NDP_ERR     ,
    INJ_DATA_ERR
}  smi_error_inj_t;
    
typedef enum {
    FN_NOERROR   = 0,
    PARITY_ERR      ,
    CORR_ECC_ERR    ,
    UNCORR_ECC_ERR
} smi_err_class_t;


////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////
//Msg type

typedef bit [WSMIMSGTYPE-1:0] MsgType_t;
typedef bit [WSMICONCMSGCLASS-1:0] ConcMsgClass_t;

localparam MsgType_t CMD_RD_CLN          = 8'b00000001;  //0x01
localparam MsgType_t CMD_RD_NOT_SHD      = 8'b00000010;  //0x02
localparam MsgType_t CMD_RD_VLD          = 8'b00000011;  //0x03
localparam MsgType_t CMD_RD_UNQ          = 8'b00000100;  //0x04
localparam MsgType_t CMD_CLN_UNQ         = 8'b00000101;  //0x05
localparam MsgType_t CMD_MK_UNQ          = 8'b00000110;  //0x06
localparam MsgType_t CMD_RD_NITC         = 8'b00000111;  //0x07
localparam MsgType_t CMD_CLN_VLD         = 8'b00001000;  //0x08
localparam MsgType_t CMD_CLN_INV         = 8'b00001001;  //0x09
localparam MsgType_t CMD_MK_INV          = 8'b00001010;  //0x0A
localparam MsgType_t CMD_RD_NC           = 8'b00001011;  //0x0B
localparam MsgType_t CMD_DVM_MSG         = 8'b00001111;  //0x0F
localparam MsgType_t CMD_WR_UNQ_PTL      = 8'b00010000;  //0x10
localparam MsgType_t CMD_WR_UNQ_FULL     = 8'b00010001;  //0x11
localparam MsgType_t CMD_WR_ATM          = 8'b00010010;  //0x12
localparam MsgType_t CMD_RD_ATM          = 8'b00010011;  //0x13
localparam MsgType_t CMD_WR_BK_FULL      = 8'b00010100;  //0x14
localparam MsgType_t CMD_WR_CLN_FULL     = 8'b00010101;  //0x15
localparam MsgType_t CMD_WR_EVICT        = 8'b00010110;  //0x16
localparam MsgType_t CMD_EVICT           = 8'b00010111;  //0x17
localparam MsgType_t CMD_WR_BK_PTL       = 8'b00011000;  //0x18
localparam MsgType_t CMD_WR_CLN_PTL      = 8'b00011001;  //0x19
localparam MsgType_t CMD_WR_NC_PTL       = 8'b00100000;  //0x20
localparam MsgType_t CMD_WR_NC_FULL      = 8'b00100001;  //0x21
localparam MsgType_t CMD_WR_STSH_FULL    = 8'b00100010;  //0x22
localparam MsgType_t CMD_WR_STSH_PTL     = 8'b00100011;  //0x23
localparam MsgType_t CMD_LD_CCH_SH       = 8'b00100100;  //0x24
localparam MsgType_t CMD_LD_CCH_UNQ      = 8'b00100101;  //0x25
localparam MsgType_t CMD_RD_NITC_CLN_INV = 8'b00100110;  //0x26
localparam MsgType_t CMD_RD_NITC_MK_INV  = 8'b00100111;  //0x27
localparam MsgType_t CMD_CLN_SH_PER      = 8'b00101000;  //0x28
localparam MsgType_t CMD_SW_ATM          = 8'b00101001;  //0x29
localparam MsgType_t CMD_CMP_ATM         = 8'b00101010;  //0x2A
localparam MsgType_t CMD_PREF            = 8'b00101011;  //0x2B

localparam MsgType_t SYS_REQ             = 8'b01111011;  //0x7B

localparam MsgType_t UPD_INV         = 8'b01110000;  //0x70
//localparam MsgType_t UPD_INV         = 8'b01111111;  //0x7f
localparam MsgType_t UPD_SCLN        = 8'b01110001;  //0x71

typedef enum MsgType_t {
               eCmdRdCln        = CMD_RD_CLN,
               eCmdRdNShD       = CMD_RD_NOT_SHD,
               eCmdRdVld        = CMD_RD_VLD,
               eCmdRdUnq        = CMD_RD_UNQ,
               eCmdClnUnq       = CMD_CLN_UNQ,
               eCmdMkUnq        = CMD_MK_UNQ,
               eCmdRdNITC       = CMD_RD_NITC,
               eCmdClnVld       = CMD_CLN_VLD,
               eCmdClnInv       = CMD_CLN_INV,
               eCmdMkInv        = CMD_MK_INV,
               eCmdRdNC         = CMD_RD_NC,
               eCmdDvmMsg       = CMD_DVM_MSG,
               eCmdWrUnqPtl     = CMD_WR_UNQ_PTL,
               eCmdWrUnqFull    = CMD_WR_UNQ_FULL,
               eCmdWrAtm        = CMD_WR_ATM,
               eCmdRdAtm        = CMD_RD_ATM,
               eCmdWrBkFull     = CMD_WR_BK_FULL,
               eCmdWrClnFull    = CMD_WR_CLN_FULL,
               eCmdWrEvict      = CMD_WR_EVICT,
               eCmdEvict        = CMD_EVICT,
               eCmdWrBkPtl      = CMD_WR_BK_PTL,
               eCmdWrClnPtl     = CMD_WR_CLN_PTL,
               eCmdWrNCPtl      = CMD_WR_NC_PTL,
               eCmdWrNCFull     = CMD_WR_NC_FULL,
               eCmdWrStshPtl    = CMD_WR_STSH_PTL,
               eCmdWrStshFull   = CMD_WR_STSH_FULL,
               eCmdLdCchShd     = CMD_LD_CCH_SH,
               eCmdLdCchUnq     = CMD_LD_CCH_UNQ,
               eCmdRdNITCClnInv = CMD_RD_NITC_CLN_INV,
               eCmdRdNITCMkInv  = CMD_RD_NITC_MK_INV,
               eCmdClnShdPer    = CMD_CLN_SH_PER,
               eCmdSwAtm        = CMD_SW_ATM,
               eCmdCompAtm      = CMD_CMP_ATM,
               eCmdPref         = CMD_PREF
             } eMsgCMD;

typedef enum MsgType_t {
               eUpdInv       = UPD_INV,
               eUpdSCln      = UPD_SCLN
             } eMsgUPD;

typedef enum MsgType_t {
               eSysReq          = SYS_REQ
             } eMsgSysReq;


////////////////////////////////////////////////////////////////////////////////
//
// AIU decodes these protocol message encodings:
//
////////////////////////////////////////////////////////////////////////////////
localparam MsgType_t SNP_CLN_DTR     = 8'b01000001; //0x41
localparam MsgType_t SNP_NITC        = 8'b01000010; //0x42
localparam MsgType_t SNP_VLD_DTR     = 8'b01000011; //0x43
localparam MsgType_t SNP_INV_DTR     = 8'b01000100; //0x44
localparam MsgType_t SNP_INV_DTW     = 8'b01000101; //0x45
localparam MsgType_t SNP_INV         = 8'b01000110; //0x46
localparam MsgType_t SNP_CLN_DTW     = 8'b01001000; //0x48
localparam MsgType_t SNP_RECALL      = 8'b01001001; //0x49
localparam MsgType_t SNP_NOSDINT     = 8'b01001010; //0x4A
localparam MsgType_t SNP_INV_STSH    = 8'b01001011; //0x4B
localparam MsgType_t SNP_UNQ_STSH    = 8'b01001100; //0x4C
localparam MsgType_t SNP_STSH_SH     = 8'b01001101; //0x4D
localparam MsgType_t SNP_STSH_UNQ    = 8'b01001110; //0x4E
localparam MsgType_t SNP_DVM_MSG     = 8'b01001111; //0x4F
localparam MsgType_t SNP_NITCCI      = 8'b01010000; //0x50
localparam MsgType_t SNP_NITCMI      = 8'b01010001; //0x51

typedef enum MsgType_t {
               eSnpClnDtr    = SNP_CLN_DTR,
               eSnpNITC      = SNP_NITC,
               eSnpVldDtr    = SNP_VLD_DTR,
               eSnpInvDtr    = SNP_INV_DTR,
               eSnpInvDtw    = SNP_INV_DTW,
               eSnpInv       = SNP_INV,
               eSnpClnDtw    = SNP_CLN_DTW,
               eSnpRecall    = SNP_RECALL,
               eSnpNoSDInt   = SNP_NOSDINT,
               eSnpInvStsh   = SNP_INV_STSH,
               eSnpUnqStsh   = SNP_UNQ_STSH,
               eSnpStshShd   = SNP_STSH_SH,
               eSnpStshUnq   = SNP_STSH_UNQ,
               eSnpDvmMsg    = SNP_DVM_MSG,
               eSnpNITCCI    = SNP_NITCCI,
               eSnpNITCMI    = SNP_NITCMI
             } eMsgSNP;

////////////////////////////////////////////////////////////////////////////////
//
// DMI decodes these protocol message encodings:
//
////////////////////////////////////////////////////////////////////////////////
localparam MsgType_t MRD_RD_CLN           = 8'b01100000;  //0x60
localparam MsgType_t MRD_RD_WITH_SHR_CLN  = 8'b01100001;  //0x61
localparam MsgType_t MRD_RD_WITH_UNQ_CLN  = 8'b01100010;  //0x62
localparam MsgType_t MRD_RD_WITH_UNQ      = 8'b01100011;  //0x63
localparam MsgType_t MRD_RD_WITH_INV      = 8'b01100100;  //0x64
localparam MsgType_t MRD_PREF             = 8'b01100101;  //0x65
localparam MsgType_t MRD_CLN              = 8'b01100110;  //0x66
localparam MsgType_t MRD_INV              = 8'b01100111;  //0x67
localparam MsgType_t MRD_FLUSH            = 8'b01101000;  //0x68

localparam MsgType_t HNT_READ             = 8'b01111000;  //0x78

typedef enum MsgType_t {
               eMrdRdCln        = MRD_RD_CLN,
               eMrdRdWithShrCln = MRD_RD_WITH_SHR_CLN,
               eMrdRdWithUnqCln = MRD_RD_WITH_UNQ_CLN,
               eMrdRdWithUnq    = MRD_RD_WITH_UNQ,
               eMrdRdWithInv    = MRD_RD_WITH_INV,
               eMrdPref         = MRD_PREF,
               eMrdCln          = MRD_CLN,
               eMrdInv          = MRD_INV,
               eMrdFlush        = MRD_FLUSH
             } eMsgMRD;

typedef enum MsgType_t {
               eHntRead      = HNT_READ
             } eMsgHNT;


////////////////////////////////////////////////////////////////////////////////
//
// AIU decodes these protocol message encodings:
//
////////////////////////////////////////////////////////////////////////////////
localparam MsgType_t STR_STATE       = 8'b01111010; // 0x7A

typedef enum MsgType_t {
               eStrState      = STR_STATE
             } eMsgSTR;

////////////////////////////////////////////////////////////////////////////////
//
// AIU decodes these protocol message encodings:
//
////////////////////////////////////////////////////////////////////////////////
localparam MsgType_t DTR_DATA_INV        = 8'b10000000;  // 0x80
localparam MsgType_t DTR_DATA_SHR_CLN    = 8'b10000001;  // 0x81
localparam MsgType_t DTR_DATA_SHR_DTY    = 8'b10000010;  // 0x82 
localparam MsgType_t DTR_DATA_UNQ_CLN    = 8'b10000011;  // 0x83
localparam MsgType_t DTR_DATA_UNQ_DTY    = 8'b10000100;  // 0x84

typedef enum MsgType_t {
               eDtrDataInv      = DTR_DATA_INV,
               eDtrDataShrCln   = DTR_DATA_SHR_CLN,
               eDtrDataShrDty   = DTR_DATA_SHR_DTY,
               eDtrDataUnqCln   = DTR_DATA_UNQ_CLN,
               eDtrDataUnqDty   = DTR_DATA_UNQ_DTY
             } eMsgDTR;

////////////////////////////////////////////////////////////////////////////////
//
// DMI decodes these protocol message encodings:
//
////////////////////////////////////////////////////////////////////////////////
localparam MsgType_t DTW_NO_DATA     = 8'b10010000;  //0x90
localparam MsgType_t DTW_DATA_CLN    = 8'b10010001;  //0x91
localparam MsgType_t DTW_DATA_PTL    = 8'b10010010;  //0x92
localparam MsgType_t DTW_DATA_DTY    = 8'b10010011;  //0x93


localparam MsgType_t DTW_MRG_MRD_INV  = 8'b10011000;  //0x98
localparam MsgType_t DTW_MRG_MRD_SCLN = 8'b10011001;  //0x99
localparam MsgType_t DTW_MRG_MRD_SDTY = 8'b10011010;  //0x9A
localparam MsgType_t DTW_MRG_MRD_UCLN = 8'b10011011;  //0x9B
localparam MsgType_t DTW_MRG_MRD_UDTY = 8'b10011100;  //0x9C

typedef enum MsgType_t {
               eDtwNoData     = DTW_NO_DATA,
               eDtwDataCln    = DTW_DATA_CLN,
               eDtwDataPtl    = DTW_DATA_PTL,
               eDtwDataDty    = DTW_DATA_DTY
             } eMsgDTW;

typedef enum MsgType_t {
               eDtwMrgMRDInv  = DTW_MRG_MRD_INV,
               eDtwMrgMRDSCln = DTW_MRG_MRD_SCLN,
               eDtwMrgMRDSDty = DTW_MRG_MRD_SDTY,
               eDtwMrgMRDUCln = DTW_MRG_MRD_UCLN,
               eDtwMrgMRDUDty = DTW_MRG_MRD_UDTY
             } eMsgDTWMrgMRD;

               
localparam MsgType_t DTW_DBG_REQ = 8'b10100000;  //0xA0

////////////////////////////////////////////////////////////////////////////////
//
// All response types
//
////////////////////////////////////////////////////////////////////////////////
localparam MsgType_t C_CMD_RSP  = 8'b11110000;  //0xF0
localparam MsgType_t NC_CMD_RSP = 8'b11110001;  //0xF1
localparam MsgType_t SNP_RSP    = 8'b11110010;  //0xF2
localparam MsgType_t DTW_RSP    = 8'b11110011;  //0xF3
localparam MsgType_t DTR_RSP    = 8'b11110100;  //0xF4
localparam MsgType_t HNT_RSP    = 8'b11110101;  //0xF5
localparam MsgType_t MRD_RSP    = 8'b11110110;  //0xF6
localparam MsgType_t STR_RSP    = 8'b11110111;  //0xF7
localparam MsgType_t UPD_RSP    = 8'b11111000;  //0xF8
localparam MsgType_t RB_RSP     = 8'b11111001;  //0xF9
localparam MsgType_t RB_USE_RSP = 8'b11111010;  //0xFA
localparam MsgType_t SYS_RSP    = 8'b11111011;  //0xFB
localparam MsgType_t CMP_RSP    = 8'b11111100;  //0xFC
localparam MsgType_t CME_RSP    = 8'b11111101;  //0xFD
localparam MsgType_t TRE_RSP    = 8'b11111110;  //0xFE
localparam MsgType_t DTW_DBG_RSP= 8'b11111111;  //0xFF

typedef enum MsgType_t {
                          eCCmdRsp	= C_CMD_RSP
			} eMsgCCmdRsp;

typedef enum MsgType_t {
			  eNCCmdRsp	= NC_CMD_RSP
			} eMsgNCCmdRsp;

typedef enum MsgType_t {
			  eSnpRsp		= SNP_RSP
			} eMsgSnpRsp;

typedef enum MsgType_t {
			  eDtwRsp		= DTW_RSP
			} eMsgDtwRsp;

typedef enum MsgType_t {
                          eDtwDbgReq            = DTW_DBG_REQ
                        } eMsgDtwDbgReq;

typedef enum MsgType_t {
			  eDtwDbgRsp		= DTW_DBG_RSP
			} eMsgDtwDbgRsp;

typedef enum MsgType_t {
			  eDtrRsp		= DTR_RSP
			} eMsgDtrRsp;

typedef enum MsgType_t {
			  eHntRsp		= HNT_RSP
			} eMsgHntRsp;

typedef enum MsgType_t {
			  eMrdRsp		= MRD_RSP
			} eMsgMrdRsp;

typedef enum MsgType_t {
			  eStrRsp		= STR_RSP
			} eMsgStrRsp;

typedef enum MsgType_t {
			  eUpdRsp		= UPD_RSP
			} eMsgUpdRsp;

typedef enum MsgType_t {
			  eRBRsp		= RB_RSP
			} eMsgRBRsp;

typedef enum MsgType_t {
			  eRBUseRsp             = RB_USE_RSP
			} eMsgRBUseRsp;

typedef enum MsgType_t {
			  eCmpRsp               = CMP_RSP
			} eMsgCmpRsp;

typedef enum MsgType_t {
			  eCmeRsp		= CME_RSP
			} eMsgCmeRsp;

typedef enum MsgType_t {
			  eTreRsp		= TRE_RSP
			} eMsgTreRsp;

typedef enum MsgType_t {
			  eSysRsp		= SYS_RSP
			} eMsgSysRsp;


////////////////////////////////////////////////////////////////////////////////
//
// DMI decodes these protocol message encodings:
//
////////////////////////////////////////////////////////////////////////////////

localparam MsgType_t RB_REQ         = 8'b01111100;  //0x7C 

typedef enum MsgType_t {
                eRBReq      = RB_REQ
            } eMsgRBReq;

////////////////////////////////////////////////////////////////////////////////
//
// DCE decodes these protocol message encodings:
//
////////////////////////////////////////////////////////////////////////////////

localparam MsgType_t RB_USED        = 8'b01111101;  //0x7D

typedef enum MsgType_t {
                eRBUsed     = RB_USED
            } eMsgRBUsed;
//////////////////////////////////////////////////////////////////////////////////////
//
// Master enum type to avoid elaborate casting to type based enumsfor verbose printing
//
//////////////////////////////////////////////////////////////////////////////////////

typedef enum MsgType_t {  
             CMD_RD_CLN_e			= 8'b00000001,  //0x01
             CMD_RD_NOT_SHD_e	= 8'b00000010,  //0x02
             CMD_RD_VLD_e			= 8'b00000011,  //0x03
             CMD_RD_UNQ_e			= 8'b00000100,  //0x04
             CMD_CLN_UNQ_e	  = 8'b00000101,  //0x05
             CMD_MK_UNQ_e			= 8'b00000110,  //0x06
             CMD_RD_NITC_e		= 8'b00000111,  //0x07
             CMD_CLN_VLD_e		= 8'b00001000,  //0x08
             CMD_CLN_INV_e		= 8'b00001001,  //0x09
             CMD_MK_INV_e			= 8'b00001010,  //0x0A
             CMD_RD_NC_e			= 8'b00001011,  //0x0B
             CMD_DVM_MSG_e		= 8'b00001111,  //0x0F
             CMD_WR_UNQ_PTL_e	= 8'b00010000,  //0x10
             CMD_WR_UNQ_FULL_e= 8'b00010001,  //0x11
             CMD_WR_ATM_e			= 8'b00010010,  //0x12
             CMD_RD_ATM_e			= 8'b00010011,  //0x13
             CMD_WR_BK_FULL_e	= 8'b00010100,  //0x14
             CMD_WR_CLN_FULL_e= 8'b00010101,  //0x15
             CMD_WR_EVICT_e		= 8'b00010110,  //0x16
             CMD_EVICT_e			= 8'b00010111,  //0x17
             CMD_WR_BK_PTL_e	= 8'b00011000,  //0x18
             CMD_WR_CLN_PTL_e	= 8'b00011001,  //0x19
             CMD_WR_NC_PTL_e	= 8'b00100000,  //0x20
             CMD_WR_NC_FULL_e	= 8'b00100001,  //0x21
             CMD_WR_STSH_FULL_e			= 8'b00100010,  //0x22
             CMD_WR_STSH_PTL_e			= 8'b00100011,  //0x23
             CMD_LD_CCH_SH_e	  		= 8'b00100100,  //0x24
             CMD_LD_CCH_UNQ_e		  	= 8'b00100101,  //0x25
             CMD_RD_NITC_CLN_INV_e	= 8'b00100110,  //0x26
             CMD_RD_NITC_MK_INV_e		= 8'b00100111,  //0x27
             CMD_CLN_SH_PER_e			  = 8'b00101000,  //0x28
             CMD_SW_ATM_e			      = 8'b00101001,  //0x29
             CMD_CMP_ATM_e			    = 8'b00101010,  //0x2A
             CMD_PREF_e			= 8'b00101011,  //0x2B
             SYS_REQ_e			= 8'b01111011,  //0x7B
             UPD_INV_e			= 8'b01110000,  //0x70
             UPD_SCLN_e			= 8'b01110001,  //0x71
             SNP_CLN_DTR_e	= 8'b01000001, //0x41
             SNP_NITC_e	  	= 8'b01000010, //0x42
             SNP_VLD_DTR_e	= 8'b01000011, //0x43
             SNP_INV_DTR_e	= 8'b01000100, //0x44
             SNP_INV_DTW_e	= 8'b01000101, //0x45
             SNP_INV_e			= 8'b01000110, //0x46
             SNP_CLN_DTW_e	= 8'b01001000, //0x48
             SNP_RECALL_e		= 8'b01001001, //0x49
             SNP_NOSDINT_e	= 8'b01001010, //0x4A
             SNP_INV_STSH_e	= 8'b01001011, //0x4B
             SNP_UNQ_STSH_e	= 8'b01001100, //0x4C
             SNP_STSH_SH_e	= 8'b01001101, //0x4D
             SNP_STSH_UNQ_e	= 8'b01001110, //0x4E
             SNP_DVM_MSG_e	= 8'b01001111, //0x4F
             SNP_NITCCI_e		= 8'b01010000, //0x50
             SNP_NITCMI_e		= 8'b01010001, //0x51
             MRD_RD_CLN_e		= 8'b01100000,  //0x60
             MRD_RD_WITH_SHR_CLN_e	= 8'b01100001,  //0x61
             MRD_RD_WITH_UNQ_CLN_e	= 8'b01100010,  //0x62
             MRD_RD_WITH_UNQ_e			= 8'b01100011,  //0x63
             MRD_RD_WITH_INV_e			= 8'b01100100,  //0x64
             MRD_PREF_e		    = 8'b01100101,  //0x65
             MRD_CLN_e		    = 8'b01100110,  //0x66
             MRD_INV_e		    = 8'b01100111,  //0x67
             MRD_FLUSH_e			= 8'b01101000,  //0x68
             HNT_READ_e			  = 8'b01111000,  //0x78
             STR_STATE_e			= 8'b01111010, // 0x7A
             DTR_DATA_INV_e		= 8'b10000000,  // 0x80
             DTR_DATA_SHR_CLN_e			= 8'b10000001,  // 0x81
             DTR_DATA_SHR_DTY_e			= 8'b10000010,  // 0x82 
             DTR_DATA_UNQ_CLN_e			= 8'b10000011,  // 0x83
             DTR_DATA_UNQ_DTY_e			= 8'b10000100,  // 0x84
             DTW_NO_DATA_e			= 8'b10010000,  //0x90
             DTW_DATA_CLN_e			= 8'b10010001,  //0x91
             DTW_DATA_PTL_e			= 8'b10010010,  //0x92
             DTW_DATA_DTY_e			= 8'b10010011,  //0x93
             DTW_MRG_MRD_INV_e  		= 8'b10011000,  //0x98
             DTW_MRG_MRD_SCLN_e			= 8'b10011001,  //0x99
             DTW_MRG_MRD_SDTY_e			= 8'b10011010,  //0x9A
             DTW_MRG_MRD_UCLN_e			= 8'b10011011,  //0x9B
             DTW_MRG_MRD_UDTY_e			= 8'b10011100,  //0x9C
             DTW_DBG_REQ_e	= 8'b10100000,  //0xA0
             C_CMD_RSP_e	  = 8'b11110000,  //0xF0
             NC_CMD_RSP_e		= 8'b11110001,  //0xF1
             SNP_RSP_e			= 8'b11110010,  //0xF2
             DTW_RSP_e			= 8'b11110011,  //0xF3
             DTR_RSP_e			= 8'b11110100,  //0xF4
             HNT_RSP_e			= 8'b11110101,  //0xF5
             MRD_RSP_e			= 8'b11110110,  //0xF6
             STR_RSP_e			= 8'b11110111,  //0xF7
             UPD_RSP_e			= 8'b11111000,  //0xF8
             RB_RSP_e			  = 8'b11111001,  //0xF9
             RB_USE_RSP_e 	= 8'b11111010,  //0xFA
             SYS_RSP_e			= 8'b11111011,  //0xFB
             CMP_RSP_e			= 8'b11111100,  //0xFC
             CME_RSP_e			= 8'b11111101,  //0xFD
             TRE_RSP_e			= 8'b11111110,  //0xFE
             DTW_DBG_RSP_e	= 8'b11111111,  //0xFF
             RB_REQ_e			  = 8'b01111100,  //0x7C 
             RB_USED_e			= 8'b01111101  //0x7D
            }smi_msg_type_e;
////////////////////////////////////////////////////////////////////////////////
//
// Msg class used in unique identifier within DV 
//
////////////////////////////////////////////////////////////////////////////////

typedef enum ConcMsgClass_t {
    eConcMsgBAD,     //denotes invalid msg class... also the default of the enum
    eConcMsgCmdReq,
    eConcMsgCCmdRsp,
    eConcMsgNcCmdRsp,
    eConcMsgSnpReq,
    eConcMsgSnpRsp,
    eConcMsgSysReq,
    eConcMsgSysRsp,
    eConcMsgHntReq,
    eConcMsgHntRsp,
    eConcMsgMrdReq,
    eConcMsgMrdRsp,
    eConcMsgStrReq,
    eConcMsgStrRsp,
    eConcMsgDtrReq,
    eConcMsgDtrRsp,
    eConcMsgDtwReq,
    eConcMsgDtwRsp,
    eConcMsgDtwDbgReq,
    eConcMsgDtwDbgRsp,
    eConcMsgUpdReq,
    eConcMsgUpdRsp,
    eConcMsgRbReq,
    eConcMsgRbRsp,
    eConcMsgRbUseReq,
    eConcMsgRbUseRsp,
    eConcMsgCmpRsp,
    eConcMsgCmeRsp,
    eConcMsgTreRsp
} eConcMsgClass;


//each msg class is rsp to at most 1 uniquely determined msg class
<% if(obj.testBench == 'dii') { %>
`ifndef CDNS
eConcMsgClass rsp2req[eConcMsgClass] = {
`else // `ifndef CDNS
eConcMsgClass rsp2req[eConcMsgClass] = '{
`endif // `ifndef CDNS
<% } else {%>
eConcMsgClass rsp2req[eConcMsgClass] = {
<% } %>
    eConcMsgBAD       : eConcMsgBAD    , 
    eConcMsgCmdReq    : eConcMsgBAD    ,
    eConcMsgCCmdRsp   : eConcMsgCmdReq ,
    eConcMsgNcCmdRsp  : eConcMsgCmdReq ,
    eConcMsgSnpReq    : eConcMsgCmdReq ,
    eConcMsgSnpRsp    : eConcMsgSnpReq ,
    eConcMsgSysReq    : eConcMsgBAD    ,
    eConcMsgSysRsp    : eConcMsgSysReq ,
    eConcMsgHntReq    : eConcMsgCmdReq ,
    eConcMsgHntRsp    : eConcMsgHntReq ,
    eConcMsgMrdReq    : eConcMsgCmdReq ,
    eConcMsgMrdRsp    : eConcMsgMrdReq ,
    eConcMsgStrReq    : eConcMsgCmdReq ,
    eConcMsgStrRsp    : eConcMsgStrReq ,
    eConcMsgDtrReq    : eConcMsgCmdReq ,
    eConcMsgDtrRsp    : eConcMsgDtrReq ,
    eConcMsgDtwReq    : eConcMsgCmdReq ,
    eConcMsgDtwRsp    : eConcMsgDtwReq ,
    eConcMsgDtwDbgReq : eConcMsgBAD    ,
    eConcMsgDtwDbgRsp : eConcMsgDtwDbgReq ,
    eConcMsgUpdReq    : eConcMsgBAD    ,
    eConcMsgUpdRsp    : eConcMsgUpdReq ,
    eConcMsgRbReq     : eConcMsgCmdReq ,        
    eConcMsgRbRsp     : eConcMsgRbReq  ,
    eConcMsgRbUseReq  : eConcMsgRbReq  ,        
    eConcMsgRbUseRsp  : eConcMsgRbUseReq ,
    eConcMsgCmpRsp    : eConcMsgCmdReq ,    //TODO which units use this? dve
    eConcMsgCmeRsp    : eConcMsgBAD    ,    //must associate on the fly with correct msg class
    eConcMsgTreRsp    : eConcMsgBAD         //must associate on the fly with correct msg class
};


//msg class determines ndp content
//TODO msg class var names do not match others in system
<% if(obj.testBench == 'dii') { %>
`ifndef CDNS
smi_ndp_len_logic_t class2ndp_len[eConcMsgClass] = {
`else // `ifndef CDNS
smi_ndp_len_logic_t class2ndp_len[eConcMsgClass] = '{
`endif // `ifndef CDNS
<% } else {%>
smi_ndp_len_logic_t class2ndp_len[eConcMsgClass] = {
<% } %>
    eConcMsgCmdReq	: w_CMD_REQ_NDP ,
    eConcMsgCCmdRsp	: w_C_CMD_RSP_NDP ,
    eConcMsgNcCmdRsp	: w_NC_CMD_RSP_NDP ,
    eConcMsgSnpReq	: w_SNP_REQ_NDP ,
    eConcMsgSnpRsp	: w_SNP_RSP_NDP ,
    eConcMsgSysReq      : w_SYS_REQ_NDP ,
    eConcMsgSysRsp      : w_SYS_RSP_NDP ,
    eConcMsgHntReq	: W_HNT_REQ_NDP ,
    eConcMsgHntRsp	: W_HNT_RSP_NDP ,
    eConcMsgMrdReq	: w_MRD_REQ_NDP ,
    eConcMsgMrdRsp	: w_MRD_RSP_NDP ,
    eConcMsgStrReq	: w_STR_REQ_NDP ,
    eConcMsgStrRsp	: w_STR_RSP_NDP ,
    eConcMsgDtrReq	: w_DTR_REQ_NDP ,
    eConcMsgDtrRsp	: w_DTR_RSP_NDP  ,
    eConcMsgDtwReq	: w_DTW_REQ_NDP ,
    eConcMsgDtwRsp	: w_DTW_RSP_NDP ,
    eConcMsgDtwDbgReq   : w_DTW_DBG_REQ_NDP ,
    eConcMsgDtwDbgRsp   : w_DTW_DBG_RSP_NDP ,
    eConcMsgUpdReq	: w_UPD_REQ_NDP ,
    eConcMsgDtwRsp	: w_DTW_RSP_NDP ,
    eConcMsgUpdRsp	: w_UPD_RSP_NDP ,
    eConcMsgRbReq	: w_RB_REQ_NDP  ,
    eConcMsgRbRsp	: w_RB_RSP_NDP ,
    eConcMsgRbUseReq	: w_RBUSE_REQ_NDP  ,
    eConcMsgRbUseRsp	: w_RBUSE_RSP_NDP ,
    eConcMsgCmpRsp	: w_CMP_RSP_NDP ,
    eConcMsgCmeRsp	: W_CME_RSP_NDP ,
    eConcMsgTreRsp      : W_TRE_RSP_NDP
};


//format conversion shims
<% if(obj.testBench == 'dii') { %>
`ifndef CDNS
eConcMsgClass string2class[string] = {
`else // `ifndef CDNS
eConcMsgClass string2class[string] = '{
`endif // `ifndef CDNS
<% } else {%>
eConcMsgClass string2class[string] = {
<% } %>
     "CMDREQ"    : eConcMsgCmdReq ,
     "CMDRSP"    : eConcMsgCCmdRsp ,
     "NCCMDRSP"  : eConcMsgNcCmdRsp ,
     "SNPREQ"    : eConcMsgSnpReq ,
     "SNPRSP"    : eConcMsgSnpRsp ,
     "SYSREQ"    : eConcMsgSysReq  ,
     "SYSRSP"    : eConcMsgSysRsp  ,
     "HNTREQ"    : eConcMsgHntReq ,
     "HNTRSP"    : eConcMsgHntRsp ,
     "MRDREQ"    : eConcMsgMrdReq ,
     "MRDRSP"    : eConcMsgMrdRsp ,
     "STRREQ"    : eConcMsgStrReq ,
     "STRRSP"    : eConcMsgStrRsp ,
     "DTRREQ"    : eConcMsgDtrReq ,
     "DTRRSP"    : eConcMsgDtrRsp ,
     "DTWREQ"    : eConcMsgDtwReq ,
     "DTWRSP"    : eConcMsgDtwRsp ,
     "DTWDBGREQ" : eConcMsgDtwDbgReq ,
     "DTWDBGRSP" : eConcMsgDtwDbgRsp ,
     "UPDREQ"    : eConcMsgUpdReq ,
     "UPDRSP"    : eConcMsgUpdRsp ,
     "RBRREQ"    : eConcMsgRbReq ,
     "RBRRSP"    : eConcMsgRbRsp ,
     "RBUREQ"    : eConcMsgRbUseReq ,
     "RBURSP"    : eConcMsgRbUseRsp ,
     "CMPRSP"    : eConcMsgCmpRsp ,
     "CMERSP"    : eConcMsgCmeRsp ,
     "TRERSP"    : eConcMsgTreRsp 
};

<% if(obj.testBench == 'dii') { %>
`ifndef CDNS
string class2string[eConcMsgClass] = {
`else // `ifndef CDNS
string class2string[eConcMsgClass] = '{
`endif // `ifndef CDNS
<% } else {%>
string class2string[eConcMsgClass] = {
<% } %>
    eConcMsgCmdReq    : "CMDREQ",
    eConcMsgCCmdRsp   : "CMDRSP",
    eConcMsgNcCmdRsp  : "NCCMDRSP",
    eConcMsgSnpReq    : "SNPREQ",
    eConcMsgSnpRsp    : "SNPRSP",
    eConcMsgSysReq    : "SYSREQ",
    eConcMsgSysRsp    : "SYSRSP",
    eConcMsgHntReq    : "HNTREQ",
    eConcMsgHntRsp    : "HNTRSP",
    eConcMsgMrdReq    : "MRDREQ",
    eConcMsgMrdRsp    : "MRDRSP",
    eConcMsgStrReq    : "STRREQ",
    eConcMsgStrRsp    : "STRRSP",
    eConcMsgDtrReq    : "DTRREQ",
    eConcMsgDtrRsp    : "DTRRSP",
    eConcMsgDtwReq    : "DTWREQ",
    eConcMsgDtwRsp    : "DTWRSP",
    eConcMsgDtwDbgReq : "DTWDBGREQ",
    eConcMsgDtwDbgRsp : "DTWDBGRSP",
    eConcMsgUpdReq    : "UPDREQ",
    eConcMsgUpdRsp    : "UPDRSP",
    eConcMsgRbReq     : "RBRREQ",
    eConcMsgRbRsp     : "RBRRSP",
    eConcMsgRbUseReq  : "RBUREQ",
    eConcMsgRbUseRsp  : "RBURSP",
    eConcMsgCmpRsp    : "CMPRSP",
    eConcMsgCmeRsp    : "CMERSP",
    eConcMsgTreRsp    : "TRERSP"
};

<% if(obj.testBench == 'dii') { %>
`ifndef CDNS
string class2rtlcmd[eConcMsgClass] = {
`else // `ifndef CDNS
string class2rtlcmd[eConcMsgClass] = '{
`endif // `ifndef CDNS
<% } else {%>
string class2rtlcmd[eConcMsgClass] = {
<% } %>
    eConcMsgCmdReq    : "cmd_req_",
    eConcMsgCCmdRsp   : "cmd_rsp_",
    eConcMsgNcCmdRsp  : "nc_cmd_rsp_",
    eConcMsgSnpReq    : "snp_req_",
    eConcMsgSnpRsp    : "snp_rsp_",
    eConcMsgHntReq    : "hnt_req_",
    eConcMsgHntRsp    : "hnt_rsp_",
    eConcMsgMrdReq    : "mrd_req_",
    eConcMsgMrdRsp    : "mrd_rsp_",
    eConcMsgStrReq    : "str_req_",
    eConcMsgStrRsp    : "str_rsp_",
    eConcMsgDtrReq    : "dtr_req_",
    eConcMsgDtrRsp    : "dtr_rsp_",
    eConcMsgDtwReq    : "dtw_req_",
    eConcMsgDtwRsp    : "dtw_rsp_",
    eConcMsgDtwDbgReq : "dtw_dbg_req_",
    eConcMsgDtwDbgRsp : "dtw_dbg_rsp_", 
    eConcMsgUpdReq    : "upd_req_",
    eConcMsgUpdRsp    : "upd_rsp_",
    eConcMsgRbReq     : "rbr_req_",
    eConcMsgRbRsp     : "rbr_rsp_",
    eConcMsgRbUseReq  : "rbu_req_",
    eConcMsgRbUseRsp  : "rbu_rsp_",
    eConcMsgSysReq    : "sys_req_",
    eConcMsgSysRsp    : "sys_rsp_",
    eConcMsgCmpRsp    : "cmp_rsp_",
    eConcMsgCmeRsp    : "cme_rsp_",
    eConcMsgTreRsp    : "tre_rsp_"
};

<% if(obj.testBench == 'dii') { %>
`ifndef CDNS
string dvcmd2rtlcmd[string] = {
`else // `ifndef CDNS
string dvcmd2rtlcmd[string] = '{
`endif // `ifndef CDNS
<% } else {%>
string dvcmd2rtlcmd[string] = {
<% } %>
  "CMDREQ"    : "cmd_req_",
  "CMDRSP"    : "cmd_rsp_",
  "NCCMDRSP"  : "nc_cmd_rsp_", //temp fix per Khaleel 10/8
  "SNPREQ"    : "snp_req_",
  "SNPRSP"    : "snp_rsp_",
  "HNTREQ"    : "hnt_req_",
  "HNTRSP"    : "hnt_rsp_",
  "MRDREQ"    : "mrd_req_",
  "MRDRSP"    : "mrd_rsp_",
  "STRREQ"    : "str_req_",
  "STRRSP"    : "str_rsp_",
  "DTRREQ"    : "dtr_req_",
  "DTRRSP"    : "dtr_rsp_",
  "DTWREQ"    : "dtw_req_",
  "DTWRSP"    : "dtw_rsp_",
  "DTWDBGREQ" : "dtw_dbg_req_",
  "DTWDBGRSP" : "dtw_dbg_rsp_",
  "UPDREQ"    : "upd_req_",
  "UPDRSP"    : "upd_rsp_",
  "RBRREQ"    : "rbr_req_",
  "RBRRSP"    : "rbr_rsp_",
  "RBUREQ"    : "rbu_req_",
  "RBURSP"    : "rbu_rsp_",
  "SYSREQ"    : "sys_req_rx_",
  "SYSRSP"    : "sys_rsp_tx_",
  "CMPRSP"    : "cmp_rsp_",
  "CMERSP"    : "cme_rsp_",
  "TRERSP"    : "tre_rsp_"
};

<% if(obj.testBench == 'dii') { %>
`ifndef CDNS
string rtlcmd2dvcmd[string] = {
`else // `ifndef CDNS
string rtlcmd2dvcmd[string] = '{
`endif // `ifndef CDNS
<% } else {%>
string rtlcmd2dvcmd[string] = {
<% } %>
 "cmd_req_"     :   "CMDREQ"    , 
 "cmd_rsp_"     :   "CMDRSP"    , 
 "nc_cmd_rsp"   :   "NCCMDRSP"  ,
 "snp_req_"     :   "SNPREQ"    , 
 "snp_rsp_"     :   "SNPRSP"    , 
 "hnt_req_"     :   "HNTREQ"    , 
 "hnt_rsp_"     :   "HNTRSP"    , 
 "mrd_req_"     :   "MRDREQ"    , 
 "mrd_rsp_"     :   "MRDRSP"    , 
 "str_req_"     :   "STRREQ"    , 
 "str_rsp_"     :   "STRRSP"    , 
 "dtr_req_"     :   "DTRREQ"    , 
 "dtr_rsp_"     :   "DTRRSP"    , 
 "dtw_req_"     :   "DTWREQ"    , 
 "dtw_rsp_"     :   "DTWRSP"    , 
 "dtw_dbg_req_" :   "DTWDBGREQ" , 
 "dtw_dbg_rsp_" :   "DTWDBGRSP" ,
 "upd_req_"    :   "UPDREQ"     , 
 "upd_rsp_"    :   "UPDRSP"     , 
 "rbr_req_"    :   "RBRREQ"     , 
 "rbr_rsp_"    :   "RBRRSP"     , 
 "rbu_req_"    :   "RBUREQ"     , 
 "rbu_rsp_"    :   "RBURSP"     , 
 "sys_req_rx_" :   "SYSREQ"     ,
 "sys_rsp_tx_" :   "SYSRSP"     ,
 "cmp_rsp_"    :   "CMPRSP"     , 
 "cme_rsp_"    :   "CMERSP"     , 
 "tre_rsp_"    :   "TRERSP" 
};

////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////
//construct funitid format for dut instantiation and seq stim
//  (magic numbers come from json)
<% 
function capitalize(str) { return (str.charAt(0).toUpperCase() + str.slice(1)) ; } //set the first letter uppercase

var unittypes = ["aiu", "dce", "dve", "dmi", "dii"];
var Funittypes = unittypes.slice(); //copy

var Caching_aiuInfo = [];
obj.SnoopFilterInfo.forEach(function(sfObj, idx) {
	Caching_aiuInfo =
	Caching_aiuInfo.concat(sfObj.SnoopFilterAssignment.reverse());
});

/*obj.Caching_aiuInfo = obj.AiuInfo.filter(
	function (unitInfo) { return Caching_aiuInfo.includes(unitInfo.FUnitId); }
);*/

var obj_Caching_aiuInfo = [];
Caching_aiuInfo.forEach(function(a) {
	obj.AiuInfo.forEach(function(aiu) {
		if(aiu.FUnitId == a) {
			obj_Caching_aiuInfo.push(aiu);
		}
	});
});

if(obj_Caching_aiuInfo.length > 0) {
	obj.Caching_aiuInfo = obj_Caching_aiuInfo;
	//obj_Caching_aiuInfo.filter(function(x){ return true; });
	Funittypes.push("caching_aiu");
}

//obj.Caching_aiuInfo = ["1","2","3"].filter(function (x) { return true; } );
//obj.SnoopFilterInfo.forEach(function(SfObj, indx) {
//	 obj.Caching_aiuInfo = obj.Caching_aiuInfo.concat(SfObj.SnoopFilterAssignment);
//});

//dve requires vector of which aius are dvm capable, ordered by NUnitId
// Ncore3.0: nunitid taken to be the index of this aiu within json AiuInfo 
obj.Dvm_aiuInfo = [] ;
obj.Dvm_NUnitIds = [] ;
unsorted_dvm_aiuInfo = [];
unsorted_dvm_nunitIds = [];
for (elem of obj.AiuInfo) {
    if(elem.cmpInfo.nDvmSnpInFlight >0) {
        unsorted_dvm_aiuInfo.push(elem);
        unsorted_dvm_nunitIds.push(elem.nUnitId);   //dve requires corresponding vector of NUnitIds of which aius are dvm capable, ordered by NUnitId
    }
}
obj.Dvm_aiuInfo = unsorted_dvm_aiuInfo.sort((a,b) => a.nUnitId - b.nUnitId);
obj.Dvm_NUnitIds = unsorted_dvm_nunitIds.sort((a,b) => a - b);   //dve requires corresponding vector of NUnitIds of which aius are dvm capable, ordered by NUnitId
if(obj.Dvm_aiuInfo.length > 0) {    //presence of DVMEnable
    Funittypes.push("dvm_aiu");
}
%>

bit [<%=obj.DceInfo[0].nDmis%>-1:0] DMI_CONNECTIVITY = ($urandom_range(1, {{(<%=obj.DceInfo[0].nDmis%>-1){1'b1}},1'b0}));
bit [<%=obj.AiuInfo[0].nDCEs%>-1:0] DCE_CONNECTIVITY = ($urandom_range(1, {<%=obj.AiuInfo[0].nDCEs%>{1'b1}}));
bit [<%=obj.AiuInfo[0].nDiis%>-1:0] DII_CONNECTIVITY = ($urandom_range(1, {<%=obj.AiuInfo[0].nDiis%>{1'b1}}));
<%if(obj.testBench =='dce') {%>
localparam [<%=obj.DceInfo[obj.Id].nDceConnectedCas%>-1:0][<%=obj.DceInfo[obj.Id].wFUnitId%>-1:0] CONNECTED_CACHING_FUNIT_IDS = '{
	<% for(var ca_index = 0; ca_index < obj.DceInfo[obj.Id].hexDceConnectedCaFunitId.length; ca_index++){%>
		<%=obj.DceInfo[obj.Id].hexDceConnectedCaFunitId[ca_index]%><% if(ca_index == (obj.DceInfo[obj.Id].hexDceConnectedCaFunitId.length-1)){ } else {%> ,<%};
		}%>
};
<%}%>

//FUnitIds vectors
<%
for (elem of Funittypes) {
    var unitInfos = obj[capitalize(elem) + "Info"];
    var unit_array = [];
%>
localparam [<%=unitInfos.length%>-1:0][<%=smiObj.WSMINCOREUNITID%>-1:0] <%=elem.toUpperCase()%>_FUNIT_IDS = '{

<% if(elem!=="caching_aiu") { %>
    <% for( j=0; j<(unitInfos.length) ; j++ ) {     
                console.log(capitalize(elem) + ": Nid " + unitInfos[j].nUnitId + ": Fid " + unitInfos[j].FUnitId);
		unit_array[unitInfos[j].nUnitId] = unitInfos[j].FUnitId;
	}%>

    <% for( j=(unitInfos.length - 1) ; j >= 0 ; j-- ) {     //0th entry is rightmost in array decl %>

        <%=smiObj.WSMINCOREUNITID%>'d<%=unitInfos[j].FUnitId%> <% if (j != 0) { %>,<% } %>
    <% } %>
<% }else{ %>

     <% for( j=(unitInfos.length - 1) ; j >= 0 ; j-- ) {     //0th entry is rightmost in array decl %>
        <%=smiObj.WSMINCOREUNITID%>'d<%=unitInfos[j].FUnitId%> <% if (j != 0) { %>,<% } %>
     <% } %>

<%}%>
};
<% } %>

<% if(obj.Dvm_NUnitIds.length > 0) { %>
//dve requires corresponding vector of NUnitIds of which aius are dvm capable, ordered by NUnitId
localparam [<%=obj.Dvm_NUnitIds.length%>-1:0][<%=smiObj.WNUNITID%>-1:0] DVM_AIU_NUNIT_IDS = '{
    <% for( j=(obj.Dvm_NUnitIds.length - 1) ; j >= 0 ; j-- ) {     //0th entry is rightmost in array decl %>
        <%=smiObj.WNUNITID%>'d<%=obj.Dvm_NUnitIds[j]%> <% if (j != 0) { %>,<% } %>
    <% } %>
};
<% } %>

<% if ((obj.testBench =='io_aiu' || obj.testBench =='chi_aiu')) { %>
localparam bit [<%=obj.AiuInfo[obj.Id].nAiuConnectedDces%>-1:0] [<%=smiObj.WSMINCOREUNITID%>-1:0] CONNECTED_DCE_FUNIT_IDS = '{
  <% for( j=(obj.AiuInfo[obj.Id].nAiuConnectedDces - 1) ; j >= 0 ; j-- ) {  //0th entry is rightmost in array decl %>
    <%=smiObj.WSMINCOREUNITID%>'d<%=obj.AiuInfo[obj.Id].hexAiuConnectedDceFunitId[j]%> <% if (j != 0) { %>,<% } %>
 <% } %>
};
<% } %>

<% if ((obj.testBench == "fsys" || obj.testBench == "emu")  && 
    (!obj.strRtlNamePrefix.includes('dmi') && !obj.strRtlNamePrefix.includes('dii') &&
    !obj.strRtlNamePrefix.includes('dce') && !obj.strRtlNamePrefix.includes('dve'))) { %>
localparam bit [<%=obj.AiuInfo[obj.Id].nAiuConnectedDces%>-1:0] [<%=smiObj.WSMINCOREUNITID%>-1:0] CONNECTED_DCE_FUNIT_IDS = '{
  <% for( j=(obj.AiuInfo[obj.Id].nAiuConnectedDces - 1) ; j >= 0 ; j-- ) {  //0th entry is rightmost in array decl %>
    <%=smiObj.WSMINCOREUNITID%>'d<%=obj.AiuInfo[obj.Id].hexAiuConnectedDceFunitId[j]%> <% if (j != 0) { %>,<% } %>
 <% } %>
};
<% } %>
