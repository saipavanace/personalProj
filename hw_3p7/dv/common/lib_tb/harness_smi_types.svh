
//
// SMI Types 
//

<% if(obj.testBench=="emu"){ %>
<% if (1 == 0) { %>
<% } %>

 
<% if ( obj.interfaces.smiRxInt[obj.interfaces.smiRxInt.length-1].params.wSmiDPdata > 0 ) { %>
localparam int <%=obj.BlockId%>_harness_wSmiDPdata = <%=obj.interfaces.smiRxInt[obj.interfaces.smiRxInt.length-1].params.wSmiDPdata%>;
<% } else { %>
localparam int <%=obj.BlockId%>_harness_wSmiDPdata     =  <%=obj.Widths.Concerto.Dp.Data.wDpData%>;
<% } %>
localparam int <%=obj.BlockId%>_harness_wSmiDPbe       = ((<%=obj.BlockId%>_harness_wSmiDPdata/64)*<%=obj.BlockId%>_harness_WSMIDPBEPERDW);
localparam int <%=obj.BlockId%>_harness_wSmiDPprot     = ((<%=obj.BlockId%>_harness_wSmiDPdata/64)*<%=obj.BlockId%>_harness_WSMIDPPROTPERDW);
localparam int <%=obj.BlockId%>_harness_wSmiDPdwid     = ((<%=obj.BlockId%>_harness_wSmiDPdata/64)*<%=obj.BlockId%>_harness_WSMIDPDWIDPERDW);
localparam int <%=obj.BlockId%>_harness_wSmiDPconcuser = ((<%=obj.BlockId%>_harness_wSmiDPdata/64)*<%=obj.BlockId%>_harness_WSMIDPCONCUSERPERDW);
localparam int <%=obj.BlockId%>_harness_wSmiDPuser     = ((<%=obj.BlockId%>_harness_wSmiDPdata/64)*<%=obj.BlockId%>_harness_WSMIDPUSERPERDW);
localparam int <%=obj.BlockId%>_harness_wSmiDPdbad     = ((<%=obj.BlockId%>_harness_wSmiDPdata/64)*<%=obj.BlockId%>_harness_WSMIDPDBADPERDW);

//ndp max ECC protection width
<% if (obj.Widths.Physical.wNdpBody <= 110) { %>
localparam int <%=obj.BlockId%>_harness_wSmiNdpProt    = 8;
<% } else if (obj.Widths.Physical.wNdpBody <= 237) { %>
localparam int <%=obj.BlockId%>_harness_wSmiNdpProt    = 9;
<% } else { %>
localparam int <%=obj.BlockId%>_harness_wSmiNdpProt    = 10;
<% } %>
// need to add protection field width
localparam int <%=obj.BlockId%>_harness_w_CMD_REQ_NDP        = (<%=obj.BlockId%>_harness_W_CMD_REQ_NDP + <%=obj.AiuInfo[0].concParams.cmdReqParams.wMProt%>);
localparam int <%=obj.BlockId%>_harness_w_C_CMD_RSP_NDP      = (<%=obj.BlockId%>_harness_W_C_CMD_RSP_NDP + <%=obj.AiuInfo[0].concParams.cmdRspParams.wMProt%>);
localparam int <%=obj.BlockId%>_harness_w_NC_CMD_RSP_NDP     = (<%=obj.BlockId%>_harness_W_NC_CMD_RSP_NDP + <%=obj.AiuInfo[0].concParams.ncCmdRspParams.wMProt%>);
localparam int <%=obj.BlockId%>_harness_w_SNP_REQ_NDP        = (<%=obj.BlockId%>_harness_W_SNP_REQ_NDP + <%=obj.AiuInfo[0].concParams.snpReqParams.wMProt%>);
localparam int <%=obj.BlockId%>_harness_w_SNP_RSP_NDP        = (<%=obj.BlockId%>_harness_W_SNP_RSP_NDP + <%=obj.AiuInfo[0].concParams.snpRspParams.wMProt%>);
localparam int <%=obj.BlockId%>_harness_w_MRD_REQ_NDP        = (<%=obj.BlockId%>_harness_W_MRD_REQ_NDP + <%=obj.AiuInfo[0].concParams.mrdReqParams.wMProt%>);
localparam int <%=obj.BlockId%>_harness_w_MRD_RSP_NDP        = (<%=obj.BlockId%>_harness_W_MRD_RSP_NDP + <%=obj.AiuInfo[0].concParams.mrdRspParams.wMProt%>);
localparam int <%=obj.BlockId%>_harness_w_STR_REQ_NDP        = (<%=obj.BlockId%>_harness_W_STR_REQ_NDP + <%=obj.AiuInfo[0].concParams.strReqParams.wMProt%>);
localparam int <%=obj.BlockId%>_harness_w_STR_RSP_NDP        = (<%=obj.BlockId%>_harness_W_STR_RSP_NDP + <%=obj.AiuInfo[0].concParams.strRspParams.wMProt%>);
localparam int <%=obj.BlockId%>_harness_w_DTR_REQ_NDP        = (<%=obj.BlockId%>_harness_W_DTR_REQ_NDP + <%=obj.AiuInfo[0].concParams.dtrReqParams.wMProt%>);
localparam int <%=obj.BlockId%>_harness_w_DTR_RSP_NDP        = (<%=obj.BlockId%>_harness_W_DTR_RSP_NDP + <%=obj.AiuInfo[0].concParams.dtrRspParams.wMProt%>);
localparam int <%=obj.BlockId%>_harness_w_DTW_REQ_NDP        = (<%=obj.BlockId%>_harness_W_DTW_REQ_NDP + <%=obj.AiuInfo[0].concParams.dtwReqParams.wMProt%>);
localparam int <%=obj.BlockId%>_harness_w_DTW_RSP_NDP        = (<%=obj.BlockId%>_harness_W_DTW_RSP_NDP + <%=obj.AiuInfo[0].concParams.dtwRspParams.wMProt%>);
localparam int <%=obj.BlockId%>_harness_w_UPD_REQ_NDP        = (<%=obj.BlockId%>_harness_W_UPD_REQ_NDP + <%=obj.AiuInfo[0].concParams.updReqParams.wMProt%>);
localparam int <%=obj.BlockId%>_harness_w_UPD_RSP_NDP        = (<%=obj.BlockId%>_harness_W_UPD_RSP_NDP + <%=obj.AiuInfo[0].concParams.updRspParams.wMProt%>);
localparam int <%=obj.BlockId%>_harness_w_RB_REQ_NDP         = (<%=obj.BlockId%>_harness_W_RB_REQ_NDP  + <%=obj.AiuInfo[0].concParams.rbrReqParams.wMProt%>);
localparam int <%=obj.BlockId%>_harness_w_RB_RSP_NDP         = (<%=obj.BlockId%>_harness_W_RB_RSP_NDP  + <%=obj.AiuInfo[0].concParams.rbrRspParams.wMProt%>);
localparam int <%=obj.BlockId%>_harness_w_RBUSE_REQ_NDP      = (<%=obj.BlockId%>_harness_W_RBUSE_REQ_NDP + <%=obj.AiuInfo[0].concParams.rbuReqParams.wMProt%>);
localparam int <%=obj.BlockId%>_harness_w_RBUSE_RSP_NDP      = (<%=obj.BlockId%>_harness_W_RBUSE_RSP_NDP + <%=obj.AiuInfo[0].concParams.rbuRspParams.wMProt%>);
localparam int <%=obj.BlockId%>_harness_w_CMP_RSP_NDP        = (<%=obj.BlockId%>_harness_W_CMP_RSP_NDP + <%=obj.AiuInfo[0].concParams.cmpRspParams.wMProt%>);

typedef logic                                                       <%=obj.BlockId%>_harness_smi_msg_valid_logic_t;
typedef logic                                                       <%=obj.BlockId%>_harness_smi_msg_ready_logic_t;
typedef logic                                                       <%=obj.BlockId%>_harness_smi_dp_valid_logic_t;
typedef logic                                                       <%=obj.BlockId%>_harness_smi_dp_ready_logic_t;
typedef logic                                                       <%=obj.BlockId%>_harness_smi_dp_last_logic_t;
typedef logic [ <%=obj.BlockId%>_harness_WSMISTEER-1:0]             <%=obj.BlockId%>_harness_smi_steer_logic_t;
typedef logic [ <%=obj.BlockId%>_harness_WSMITGTID-1:0]             <%=obj.BlockId%>_harness_smi_targ_id_logic_t;
typedef logic [ <%=obj.BlockId%>_harness_WSMISRCID-1:0]             <%=obj.BlockId%>_harness_smi_src_id_logic_t;
typedef logic [ <%=obj.BlockId%>_harness_WSMIMSGTIER-1:0]           <%=obj.BlockId%>_harness_smi_msg_tier_logic_t;
typedef logic [ <%=obj.BlockId%>_harness_WSMIMSGQOS-1:0]            <%=obj.BlockId%>_harness_smi_msg_qos_logic_t;
typedef logic [ <%=obj.BlockId%>_harness_WSMIMSGPRI-1:0]            <%=obj.BlockId%>_harness_smi_msg_pri_logic_t;
typedef logic [ <%=obj.BlockId%>_harness_WSMIMSGTYPE-1:0]           <%=obj.BlockId%>_harness_smi_msg_type_logic_t;
typedef logic [ <%=obj.BlockId%>_harness_WSMINDPLEN-1:0]            <%=obj.BlockId%>_harness_smi_ndp_len_logic_t;
typedef logic [ <%=obj.BlockId%>_harness_WSMINDP-1:0]               <%=obj.BlockId%>_harness_smi_ndp_logic_t;
typedef logic [ <%=obj.BlockId%>_harness_WSMIDPPRESENT-1:0]         <%=obj.BlockId%>_harness_smi_dp_present_logic_t;
typedef logic [ <%=obj.BlockId%>_harness_WSMIMSGID-1:0]             <%=obj.BlockId%>_harness_smi_msg_id_logic_t;
typedef logic [ <%=obj.BlockId%>_harness_WSMIMSGUSER-1:0]           <%=obj.BlockId%>_harness_smi_msg_user_logic_t;
<% if (obj.Widths.Concerto.Ndp.Header.wHProt > 0) { %>
typedef logic [<%=obj.Widths.Concerto.Ndp.Header.wHProt%>-1:0 ]      <%=obj.BlockId%>_harness_smi_msg_hprot_logic_t;
<% } %>
typedef logic [<%=obj.BlockId%>_harness_WSMIMSGERR-1:0]              <%=obj.BlockId%>_harness_smi_msg_err_logic_t;
typedef logic [<%=obj.BlockId%>_harness_wSmiDPdata-1:0]              <%=obj.BlockId%>_harness_smi_dp_data_logic_t;
typedef logic [<%=obj.BlockId%>_harness_wSmiDPbe-1:0]                <%=obj.BlockId%>_harness_smi_dp_be_logic_t;
typedef logic [<%=obj.BlockId%>_harness_wSmiDPuser-1:0]              <%=obj.BlockId%>_harness_smi_dp_user_logic_t;
typedef bit                                                          <%=obj.BlockId%>_harness_smi_msg_valid_bit_t;
typedef bit                                                          <%=obj.BlockId%>_harness_smi_msg_ready_bit_t;
typedef bit                                                          <%=obj.BlockId%>_harness_smi_dp_valid_bit_t;
typedef bit                                                          <%=obj.BlockId%>_harness_smi_dp_ready_bit_t;
typedef bit                                                          <%=obj.BlockId%>_harness_smi_dp_last_bit_t;
typedef bit [<%=obj.BlockId%>_harness_WSMITGTID-1:0]                 <%=obj.BlockId%>_harness_smi_targ_id_bit_t;
typedef bit [<%=obj.BlockId%>_harness_WSMISRCID-1:0]                 <%=obj.BlockId%>_harness_smi_src_id_bit_t;
typedef bit [<%=obj.BlockId%>_harness_WSMINCOREUNITID-1:0]           <%=obj.BlockId%>_harness_smi_ncore_unit_id_bit_t;
typedef bit [<%=obj.BlockId%>_harness_WSMINCOREPORTID-1:0]           <%=obj.BlockId%>_harness_smi_ncore_port_id_bit_t;
typedef bit [<%=obj.BlockId%>_harness_WSMIUNQIDENTIFIER-1:0]         <%=obj.BlockId%>_harness_smi_unq_identifier_bit_t;
<% if (obj.Widths.Concerto.Ndp.Header.wSteering > 0) { %>
typedef bit [<%=obj.BlockId%>_harness_WSMISTEER-1:0]                  <%=obj.BlockId%>_harness_smi_steer_bit_t;
<% } else { %>
typedef bit                                                           <%=obj.BlockId%>_harness_smi_steer_bit_t;
<% } %>
<% if (obj.Widths.Concerto.Ndp.Header.wTTier > 0) { %>
typedef bit [<%=obj.BlockId%>_harness_WSMIMSGTIER-1:0]       <%=obj.BlockId%>_harness_smi_msg_tier_bit_t;
<% } else { %>
typedef bit                         <%=obj.BlockId%>_harness_smi_msg_tier_bit_t;
<% } %>
<% if (obj.Widths.Concerto.Ndp.Header.wQl> 0) { %>
typedef bit [<%=obj.BlockId%>_harness_WSMIMSGQOS-1:0]        <%=obj.BlockId%>_harness_smi_msg_qos_bit_t;
<% } else { %>
typedef bit                         <%=obj.BlockId%>_harness_smi_msg_qos_bit_t;
<% } %>
typedef bit [<%=obj.BlockId%>_harness_WSMIMSGPRI-1:0]        <%=obj.BlockId%>_harness_smi_msg_pri_bit_t;
typedef bit [<%=obj.BlockId%>_harness_WSMIMSGTYPE-1:0]       <%=obj.BlockId%>_harness_smi_msg_type_bit_t;
typedef bit [<%=obj.BlockId%>_harness_WSMINDPLEN-1:0]        <%=obj.BlockId%>_harness_smi_ndp_len_bit_t;
typedef bit [<%=obj.BlockId%>_harness_WSMINDP-1:0]           <%=obj.BlockId%>_harness_smi_ndp_bit_t;
typedef bit [<%=obj.BlockId%>_harness_WSMIDPPRESENT-1:0]     <%=obj.BlockId%>_harness_smi_dp_present_bit_t;
typedef bit [<%=obj.BlockId%>_harness_WSMIMSGID-1:0]         <%=obj.BlockId%>_harness_smi_msg_id_bit_t;
typedef bit [<%=obj.BlockId%>_harness_WSMIMSGUSER-1:0]       <%=obj.BlockId%>_harness_smi_msg_user_bit_t;
<% if (obj.Widths.Concerto.Ndp.Body.wNdpAux > 0) { %>
typedef bit [<%=obj.Widths.Concerto.Ndp.Body.wNdpAux%>-1:0]          <%=obj.BlockId%>_harness_smi_ndp_aux_bit_t;
<% } else { %>
typedef bit                                                          <%=obj.BlockId%>_harness_smi_ndp_aux_bit_t;
<% } %>
<% if (obj.Widths.Concerto.Ndp.Header.wHProt > 0) { %>
typedef bit [<%=obj.BlockId%>_harness_WSMIHPROT-1:0]         <%=obj.BlockId%>_harness_smi_msg_hprot_bit_t;
<% } else { %>
typedef bit                         <%=obj.BlockId%>_harness_smi_msg_hprot_bit_t;   // variable will not be used
<% } %>
typedef bit [<%=obj.BlockId%>_harness_WSMIMSGERR-1:0]       <%=obj.BlockId%>_harness_smi_msg_err_bit_t;
typedef bit [<%=obj.BlockId%>_harness_wSmiDPdata-1:0]       <%=obj.BlockId%>_harness_smi_dp_data_bit_t;
typedef bit [<%=obj.BlockId%>_harness_wSmiDPbe-1:0]         <%=obj.BlockId%>_harness_smi_dp_be_bit_t;
typedef bit [<%=obj.BlockId%>_harness_wSmiDPuser-1:0]       <%=obj.BlockId%>_harness_smi_dp_user_bit_t;

// Ncore NDP and DP break-down defines 
typedef bit [<%=obj.BlockId%>_harness_WSMIADDR-1:0]                             <%=obj.BlockId%>_harness_smi_addr_t;
typedef bit [<%=obj.BlockId%>_harness_WSMIADDR-1+<%=obj.wSecurityAttribute%>:0] <%=obj.BlockId%>_harness_smi_addr_security_t;
typedef bit [<%=obj.BlockId%>_harness_WSEC-1:0]                                 <%=obj.BlockId%>_harness_smi_security_t;
typedef bit [<%=obj.BlockId%>_harness_WSMIVZ-1:0]                               <%=obj.BlockId%>_harness_smi_vz_t;
typedef bit [<%=obj.BlockId%>_harness_WSMIAC-1:0]                               <%=obj.BlockId%>_harness_smi_ac_t;
typedef bit [<%=obj.BlockId%>_harness_WSMICA-1:0]                               <%=obj.BlockId%>_harness_smi_ca_t;
typedef bit [<%=obj.BlockId%>_harness_WSMICH-1:0]                               <%=obj.BlockId%>_harness_smi_ch_t;
typedef bit [<%=obj.BlockId%>_harness_WSMIST-1:0]                               <%=obj.BlockId%>_harness_smi_st_t;
typedef bit [<%=obj.BlockId%>_harness_WSMIEN-1:0]                               <%=obj.BlockId%>_harness_smi_en_t;
typedef bit [<%=obj.BlockId%>_harness_WSMIES-1:0]                               <%=obj.BlockId%>_harness_smi_es_t;
typedef bit [<%=obj.BlockId%>_harness_WSMINS-1:0]                               <%=obj.BlockId%>_harness_smi_ns_t;
typedef bit [<%=obj.BlockId%>_harness_WSMIPR-1:0]                               <%=obj.BlockId%>_harness_smi_pr_t;
typedef bit [<%=obj.BlockId%>_harness_WSMIORDER-1:0]                            <%=obj.BlockId%>_harness_smi_order_t;
typedef bit [<%=obj.BlockId%>_harness_WSMILK-1:0]                               <%=obj.BlockId%>_harness_smi_lk_t;
typedef bit [<%=obj.BlockId%>_harness_WSMIRL-1:0]                               <%=obj.BlockId%>_harness_smi_rl_t;
typedef bit [<%=obj.BlockId%>_harness_WSMITM-1:0]                               <%=obj.BlockId%>_harness_smi_tm_t;
typedef bit [<%=obj.BlockId%>_harness_WSMIPRIMARY-1:0]                          <%=obj.BlockId%>_harness_smi_prim_t;
typedef bit [<%=obj.BlockId%>_harness_WSMIMW-1:0]                               <%=obj.BlockId%>_harness_smi_mw_t;
typedef bit [<%=obj.BlockId%>_harness_WSMIMBR-1:0]                              <%=obj.BlockId%>_harness_smi_mbr_t;
<% if (obj.Widths.Concerto.Ndp.Body.wEO > 0) { %>
typedef bit [obj.Widths.Concerto.Ndp.Body.wEO-1:0]      <%=obj.BlockId%>_harness_smi_eo_t;
<% } else { %>
typedef bit                                             <%=obj.BlockId%>_harness_smi_eo_t;
<% } %>
typedef bit [<%=obj.BlockId%>_harness_WSMIUP-1:0]                               <%=obj.BlockId%>_harness_smi_up_t;
typedef bit [<%=obj.BlockId%>_harness_WSMISTASHVALID-1:0]                       <%=obj.BlockId%>_harness_smi_mpf1_stash_valid_t;
typedef bit [<%=obj.BlockId%>_harness_WSMISTASHNID-1:0]                         <%=obj.BlockId%>_harness_smi_mpf1_stash_nid_t;
typedef bit [<%=obj.BlockId%>_harness_WSMIARGV-1:0]                             <%=obj.BlockId%>_harness_smi_mpf1_argv_t;
typedef bit [<%=obj.BlockId%>_harness_WSMINCOREUNITID-1:0]                      <%=obj.BlockId%>_harness_smi_mpf1_dtr_tgt_id_t;
typedef bit [<%=obj.BlockId%>_harness_WSMIASIZE-1:0]                            <%=obj.BlockId%>_harness_smi_mpf1_asize_t;
typedef bit [<%=obj.BlockId%>_harness_WSMIALENGTH-1:0]                          <%=obj.BlockId%>_harness_smi_mpf1_alength_t;
typedef bit [<%=obj.BlockId%>_harness_WSMIBURSTTYPE-1:0]                        <%=obj.BlockId%>_harness_smi_mpf1_burst_type_t;
typedef bit [<%=obj.BlockId%>_harness_WSMIMPF1-1:0]                             <%=obj.BlockId%>_harness_smi_mpf1_dtr_long_dtw_t;
typedef bit [<%=obj.BlockId%>_harness_WSMIMPF1-1:0]                             <%=obj.BlockId%>_harness_smi_mpf1_vmid_ext_t;
typedef bit [<%=obj.BlockId%>_harness_WSMIMSGID-1:0]                            <%=obj.BlockId%>_harness_smi_mpf1_dtr_msg_id_t;
typedef bit                                            <%=obj.BlockId%>_harness_smi_mpf1_awunique_t;
typedef bit [<%=obj.BlockId%>_harness_WSMIMPF1-1:0]                             <%=obj.BlockId%>_harness_smi_mpf1_t;
typedef bit [<%=obj.BlockId%>_harness_WSMISTASHLPIDVALID-1:0]                   <%=obj.BlockId%>_harness_smi_mpf2_stash_valid_t;
typedef bit [<%=obj.BlockId%>_harness_WSMISTASHLPID-1:0]                        <%=obj.BlockId%>_harness_smi_mpf2_stash_lpid_t;
typedef bit [<%=obj.BlockId%>_harness_WSMISTASHLPIDVALID-1:0]                   <%=obj.BlockId%>_harness_smi_mpf2_flowid_valid_t;
typedef bit [<%=obj.BlockId%>_harness_WSMIFLOWID-1:0]                           <%=obj.BlockId%>_harness_smi_mpf2_flowid_t;
typedef bit [<%=obj.BlockId%>_harness_WSMIMSGID-1:0]                            <%=obj.BlockId%>_harness_smi_mpf2_dtr_msg_id_t;
typedef bit [<%=obj.BlockId%>_harness_WSMIMPF2-1:0]                             <%=obj.BlockId%>_harness_smi_mpf2_dvmop_id_t;
typedef bit [<%=obj.BlockId%>_harness_WSMIMPF2-1:0]                             <%=obj.BlockId%>_harness_smi_mpf2_snp_mpf2_t;
typedef bit [<%=obj.BlockId%>_harness_WSMIMPF2-1:0]                             <%=obj.BlockId%>_harness_smi_mpf2_str_mpf2_t;
typedef bit [<%=obj.BlockId%>_harness_WSMIMPF2-1:0]                             <%=obj.BlockId%>_harness_smi_mpf2_t;
typedef bit [<%=obj.BlockId%>_harness_WSMINCOREUNITID-1:0]                      <%=obj.BlockId%>_harness_smi_mpf3_intervention_unit_id_t;
typedef bit [<%=obj.BlockId%>_harness_WSMIMPF3-1:0]                             <%=obj.BlockId%>_harness_smi_mpf3_dvmop_portion_t;
typedef bit [<%=obj.BlockId%>_harness_WSMIMPF3-1:0]                             <%=obj.BlockId%>_harness_smi_mpf3_range_t;
typedef bit [<%=obj.BlockId%>_harness_WSMIMPF3-1:0]                             <%=obj.BlockId%>_harness_smi_mpf3_flowid_t;
typedef bit [<%=obj.BlockId%>_harness_WSMIINTFSIZE-1:0]                         <%=obj.BlockId%>_harness_smi_intfsize_t;
typedef bit [<%=obj.BlockId%>_harness_WSMIDESTID-1:0]                           <%=obj.BlockId%>_harness_smi_dest_id_t;
typedef bit [<%=obj.BlockId%>_harness_WSMISIZE-1:0]                             <%=obj.BlockId%>_harness_smi_size_t;
typedef bit [<%=obj.BlockId%>_harness_WSMITOF-1:0]                              <%=obj.BlockId%>_harness_smi_tof_t;
typedef bit [<%=obj.BlockId%>_harness_WSMIQOS-1:0]                              <%=obj.BlockId%>_harness_smi_qos_t;
typedef bit [<%=obj.BlockId%>_harness_WSMINDPAUX-1:0]                           <%=obj.BlockId%>_harness_smi_ndp_aux_t;
typedef bit [<%=obj.BlockId%>_harness_wSmiNdpProt-1:0]                          <%=obj.BlockId%>_harness_smi_ndp_protection_t;
typedef bit [<%=obj.BlockId%>_harness_WSMIRBID-1:0]                             <%=obj.BlockId%>_harness_smi_rbid_t;
typedef bit [<%=obj.BlockId%>_harness_WSMIRTYPE-1:0]                            <%=obj.BlockId%>_harness_smi_rtype_t;
typedef bit [<%=obj.BlockId%>_harness_WSMIMSGTYPE-1:0]                          <%=obj.BlockId%>_harness_smi_type_t;
typedef bit [<%=obj.BlockId%>_harness_WSMIMSGID-1:0]                            <%=obj.BlockId%>_harness_smi_msg_id_t;
typedef bit [<%=obj.BlockId%>_harness_wSmiDPbe-1:0]                             <%=obj.BlockId%>_harness_smi_dp_be_t;
typedef bit [<%=obj.BlockId%>_harness_wSmiDPprot-1:0]                           <%=obj.BlockId%>_harness_smi_dp_protection_t;
typedef bit [<%=obj.BlockId%>_harness_wSmiDPdwid-1:0]                           <%=obj.BlockId%>_harness_smi_dp_dwid_t;
typedef bit [<%=obj.BlockId%>_harness_wSmiDPdbad-1:0]                           <%=obj.BlockId%>_harness_smi_dp_dbad_t;
typedef bit [<%=obj.BlockId%>_harness_wSmiDPconcuser-1:0]                       <%=obj.BlockId%>_harness_smi_dp_concuser_t;
typedef bit [<%=obj.BlockId%>_harness_WSMICMSTATUS-1:0]                         <%=obj.BlockId%>_harness_smi_cmstatus_t;
typedef bit [<%=obj.BlockId%>_harness_WSMICMSTATUSERR-1:0]                      <%=obj.BlockId%>_harness_smi_cmstatus_err_t;
typedef bit [<%=obj.BlockId%>_harness_WSMICMSTATUSERRPAYLOAD-1:0]               <%=obj.BlockId%>_harness_smi_cmstatus_err_payload_t;
typedef bit [<%=obj.BlockId%>_harness_WSMICMSTATUSSO-1:0]                       <%=obj.BlockId%>_harness_smi_cmstatus_so_t;
typedef bit [<%=obj.BlockId%>_harness_WSMICMSTATUSSS-1:0]                       <%=obj.BlockId%>_harness_smi_cmstatus_ss_t;
typedef bit [<%=obj.BlockId%>_harness_WSMICMSTATUSSD-1:0]                       <%=obj.BlockId%>_harness_smi_cmstatus_sd_t;
typedef bit [<%=obj.BlockId%>_harness_WSMICMSTATUSST-1:0]                       <%=obj.BlockId%>_harness_smi_cmstatus_st_t;
typedef bit [2:0]                        				        <%=obj.BlockId%>_harness_smi_cmstatus_state_t;
typedef bit [<%=obj.BlockId%>_harness_WSMICMSTATUSSNARF-1:0]                    <%=obj.BlockId%>_harness_smi_cmstatus_snarf_t;
typedef bit [<%=obj.BlockId%>_harness_WSMICMSTATUSEXOK-1:0]                     <%=obj.BlockId%>_harness_smi_cmstatus_exok_t;
typedef bit [<%=obj.BlockId%>_harness_WSMICMSTATUSRV-1:0]                       <%=obj.BlockId%>_harness_smi_cmstatus_rv_t;
typedef bit [<%=obj.BlockId%>_harness_WSMICMSTATUSRS-1:0]                       <%=obj.BlockId%>_harness_smi_cmstatus_rs_t;
typedef bit [<%=obj.BlockId%>_harness_WSMICMSTATUSDC-1:0]                       <%=obj.BlockId%>_harness_smi_cmstatus_dc_t;
typedef bit [<%=obj.BlockId%>_harness_WSMICMSTATUSDTAIU-1:0]                    <%=obj.BlockId%>_harness_smi_cmstatus_dt_aiu_t;
typedef bit [<%=obj.BlockId%>_harness_WSMICMSTATUSDTDMI-1:0]                    <%=obj.BlockId%>_harness_smi_cmstatus_dt_dmi_t;

////////////////////////////////////////////////////////////////////////////////
//Msg type

typedef bit [<%=obj.BlockId%>_harness_WSMIMSGTYPE-1:0] <%=obj.BlockId%>_harness_MsgType_t;
typedef bit [<%=obj.BlockId%>_harness_WSMICONCMSGCLASS-1:0] <%=obj.BlockId%>_harness_ConcMsgClass_t;

localparam <%=obj.BlockId%>_harness_MsgType_t <%=obj.BlockId%>_harness_CMD_RD_CLN          = 8'b00000001;  //0x01
localparam <%=obj.BlockId%>_harness_MsgType_t <%=obj.BlockId%>_harness_CMD_RD_NOT_SHD      = 8'b00000010;  //0x02
localparam <%=obj.BlockId%>_harness_MsgType_t <%=obj.BlockId%>_harness_CMD_RD_VLD          = 8'b00000011;  //0x03
localparam <%=obj.BlockId%>_harness_MsgType_t <%=obj.BlockId%>_harness_CMD_RD_UNQ          = 8'b00000100;  //0x04
localparam <%=obj.BlockId%>_harness_MsgType_t <%=obj.BlockId%>_harness_CMD_CLN_UNQ         = 8'b00000101;  //0x05
localparam <%=obj.BlockId%>_harness_MsgType_t <%=obj.BlockId%>_harness_CMD_MK_UNQ          = 8'b00000110;  //0x06
localparam <%=obj.BlockId%>_harness_MsgType_t <%=obj.BlockId%>_harness_CMD_RD_NITC         = 8'b00000111;  //0x07
localparam <%=obj.BlockId%>_harness_MsgType_t <%=obj.BlockId%>_harness_CMD_CLN_VLD         = 8'b00001000;  //0x08
localparam <%=obj.BlockId%>_harness_MsgType_t <%=obj.BlockId%>_harness_CMD_CLN_INV         = 8'b00001001;  //0x09
localparam <%=obj.BlockId%>_harness_MsgType_t <%=obj.BlockId%>_harness_CMD_MK_INV          = 8'b00001010;  //0x0A
localparam <%=obj.BlockId%>_harness_MsgType_t <%=obj.BlockId%>_harness_CMD_RD_NC           = 8'b00001011;  //0x0B
localparam <%=obj.BlockId%>_harness_MsgType_t <%=obj.BlockId%>_harness_CMD_DVM_MSG         = 8'b00001111;  //0x0F
localparam <%=obj.BlockId%>_harness_MsgType_t <%=obj.BlockId%>_harness_CMD_WR_UNQ_PTL      = 8'b00010000;  //0x10
localparam <%=obj.BlockId%>_harness_MsgType_t <%=obj.BlockId%>_harness_CMD_WR_UNQ_FULL     = 8'b00010001;  //0x11
localparam <%=obj.BlockId%>_harness_MsgType_t <%=obj.BlockId%>_harness_CMD_WR_ATM          = 8'b00010010;  //0x12
localparam <%=obj.BlockId%>_harness_MsgType_t <%=obj.BlockId%>_harness_CMD_RD_ATM          = 8'b00010011;  //0x13
localparam <%=obj.BlockId%>_harness_MsgType_t <%=obj.BlockId%>_harness_CMD_WR_BK_FULL      = 8'b00010100;  //0x14
localparam <%=obj.BlockId%>_harness_MsgType_t <%=obj.BlockId%>_harness_CMD_WR_CLN_FULL     = 8'b00010101;  //0x15
localparam <%=obj.BlockId%>_harness_MsgType_t <%=obj.BlockId%>_harness_CMD_WR_EVICT        = 8'b00010110;  //0x16
localparam <%=obj.BlockId%>_harness_MsgType_t <%=obj.BlockId%>_harness_CMD_EVICT           = 8'b00010111;  //0x17
localparam <%=obj.BlockId%>_harness_MsgType_t <%=obj.BlockId%>_harness_CMD_WR_BK_PTL       = 8'b00011000;  //0x18
localparam <%=obj.BlockId%>_harness_MsgType_t <%=obj.BlockId%>_harness_CMD_WR_CLN_PTL      = 8'b00011001;  //0x19
localparam <%=obj.BlockId%>_harness_MsgType_t <%=obj.BlockId%>_harness_CMD_WR_NC_PTL       = 8'b00100000;  //0x20
localparam <%=obj.BlockId%>_harness_MsgType_t <%=obj.BlockId%>_harness_CMD_WR_NC_FULL      = 8'b00100001;  //0x21
localparam <%=obj.BlockId%>_harness_MsgType_t <%=obj.BlockId%>_harness_CMD_WR_STSH_FULL    = 8'b00100010;  //0x22
localparam <%=obj.BlockId%>_harness_MsgType_t <%=obj.BlockId%>_harness_CMD_WR_STSH_PTL     = 8'b00100011;  //0x23
localparam <%=obj.BlockId%>_harness_MsgType_t <%=obj.BlockId%>_harness_CMD_LD_CCH_SH       = 8'b00100100;  //0x24
localparam <%=obj.BlockId%>_harness_MsgType_t <%=obj.BlockId%>_harness_CMD_LD_CCH_UNQ      = 8'b00100101;  //0x25
localparam <%=obj.BlockId%>_harness_MsgType_t <%=obj.BlockId%>_harness_CMD_RD_NITC_CLN_INV = 8'b00100110;  //0x26
localparam <%=obj.BlockId%>_harness_MsgType_t <%=obj.BlockId%>_harness_CMD_RD_NITC_MK_INV  = 8'b00100111;  //0x27
localparam <%=obj.BlockId%>_harness_MsgType_t <%=obj.BlockId%>_harness_CMD_CLN_SH_PER      = 8'b00101000;  //0x28
localparam <%=obj.BlockId%>_harness_MsgType_t <%=obj.BlockId%>_harness_CMD_SW_ATM          = 8'b00101001;  //0x29
localparam <%=obj.BlockId%>_harness_MsgType_t <%=obj.BlockId%>_harness_CMD_CMP_ATM         = 8'b00101010;  //0x2A
localparam <%=obj.BlockId%>_harness_MsgType_t <%=obj.BlockId%>_harness_CMD_PREF            = 8'b00101011;  //0x2B
localparam <%=obj.BlockId%>_harness_MsgType_t <%=obj.BlockId%>_harness_UPD_INV         = 8'b01110000;  //0x70
//localparam MsgType_t UPD_INV         = 8'b01111111;  //0x7f
localparam <%=obj.BlockId%>_harness_MsgType_t <%=obj.BlockId%>_harness_UPD_SCLN        = 8'b01110001;  //0x71

////////////////////////////////////////////////////////////////////////////////
//
// AIU decodes these protocol message encodings:
//
////////////////////////////////////////////////////////////////////////////////
localparam <%=obj.BlockId%>_harness_MsgType_t <%=obj.BlockId%>_harness_SNP_CLN_DTR     = 8'b01000001; //0x41
localparam <%=obj.BlockId%>_harness_MsgType_t <%=obj.BlockId%>_harness_SNP_NITC        = 8'b01000010; //0x42
localparam <%=obj.BlockId%>_harness_MsgType_t <%=obj.BlockId%>_harness_SNP_VLD_DTR     = 8'b01000011; //0x43
localparam <%=obj.BlockId%>_harness_MsgType_t <%=obj.BlockId%>_harness_SNP_INV_DTR     = 8'b01000100; //0x44
localparam <%=obj.BlockId%>_harness_MsgType_t <%=obj.BlockId%>_harness_SNP_INV_DTW     = 8'b01000101; //0x45
localparam <%=obj.BlockId%>_harness_MsgType_t <%=obj.BlockId%>_harness_SNP_INV         = 8'b01000110; //0x46
localparam <%=obj.BlockId%>_harness_MsgType_t <%=obj.BlockId%>_harness_SNP_CLN_DTW     = 8'b01001000; //0x48
localparam <%=obj.BlockId%>_harness_MsgType_t <%=obj.BlockId%>_harness_SNP_RECALL      = 8'b01001001; //0x49
localparam <%=obj.BlockId%>_harness_MsgType_t <%=obj.BlockId%>_harness_SNP_NOSDINT     = 8'b01001010; //0x4A
localparam <%=obj.BlockId%>_harness_MsgType_t <%=obj.BlockId%>_harness_SNP_INV_STSH    = 8'b01001011; //0x4B
localparam <%=obj.BlockId%>_harness_MsgType_t <%=obj.BlockId%>_harness_SNP_UNQ_STSH    = 8'b01001100; //0x4C
localparam <%=obj.BlockId%>_harness_MsgType_t <%=obj.BlockId%>_harness_SNP_STSH_SH     = 8'b01001101; //0x4D
localparam <%=obj.BlockId%>_harness_MsgType_t <%=obj.BlockId%>_harness_SNP_STSH_UNQ    = 8'b01001110; //0x4E
localparam <%=obj.BlockId%>_harness_MsgType_t <%=obj.BlockId%>_harness_SNP_DVM_MSG     = 8'b01001111; //0x4F
localparam <%=obj.BlockId%>_harness_MsgType_t <%=obj.BlockId%>_harness_SNP_NITCCI      = 8'b01010000; //0x50
localparam <%=obj.BlockId%>_harness_MsgType_t <%=obj.BlockId%>_harness_SNP_NITCMI      = 8'b01010001; //0x51
////////////////////////////////////////////////////////////////////////////////
//
// DMI decodes these protocol message encodings:
//
////////////////////////////////////////////////////////////////////////////////
localparam <%=obj.BlockId%>_harness_MsgType_t <%=obj.BlockId%>_harness_MRD_RD_CLN           = 8'b01100000;  //0x60
localparam <%=obj.BlockId%>_harness_MsgType_t <%=obj.BlockId%>_harness_MRD_RD_WITH_SHR_CLN  = 8'b01100001;  //0x61
localparam <%=obj.BlockId%>_harness_MsgType_t <%=obj.BlockId%>_harness_MRD_RD_WITH_UNQ_CLN  = 8'b01100010;  //0x62
localparam <%=obj.BlockId%>_harness_MsgType_t <%=obj.BlockId%>_harness_MRD_RD_WITH_UNQ      = 8'b01100011;  //0x63
localparam <%=obj.BlockId%>_harness_MsgType_t <%=obj.BlockId%>_harness_MRD_RD_WITH_INV      = 8'b01100100;  //0x64
localparam <%=obj.BlockId%>_harness_MsgType_t <%=obj.BlockId%>_harness_MRD_PREF             = 8'b01100101;  //0x65
localparam <%=obj.BlockId%>_harness_MsgType_t <%=obj.BlockId%>_harness_MRD_CLN              = 8'b01100110;  //0x66
localparam <%=obj.BlockId%>_harness_MsgType_t <%=obj.BlockId%>_harness_MRD_INV              = 8'b01100111;  //0x67
localparam <%=obj.BlockId%>_harness_MsgType_t <%=obj.BlockId%>_harness_MRD_FLUSH            = 8'b01101000;  //0x68
localparam <%=obj.BlockId%>_harness_MsgType_t   <%=obj.BlockId%>_harness_HNT_READ           = 8'b01111000;  //0x78
////////////////////////////////////////////////////////////////////////////////
//
// AIU decodes these protocol message encodings:
//
////////////////////////////////////////////////////////////////////////////////
localparam <%=obj.BlockId%>_harness_MsgType_t <%=obj.BlockId%>_harness_STR_STATE           = 8'b01111010; // 0x7A
localparam <%=obj.BlockId%>_harness_MsgType_t <%=obj.BlockId%>_harness_DTR_DATA_INV        = 8'b10000000;  // 0x80
localparam <%=obj.BlockId%>_harness_MsgType_t <%=obj.BlockId%>_harness_DTR_DATA_SHR_CLN    = 8'b10000001;  // 0x81
localparam <%=obj.BlockId%>_harness_MsgType_t <%=obj.BlockId%>_harness_DTR_DATA_SHR_DTY    = 8'b10000010;  // 0x82 
localparam <%=obj.BlockId%>_harness_MsgType_t <%=obj.BlockId%>_harness_DTR_DATA_UNQ_CLN    = 8'b10000011;  // 0x83
localparam <%=obj.BlockId%>_harness_MsgType_t <%=obj.BlockId%>_harness_DTR_DATA_UNQ_DTY    = 8'b10000100;  // 0x84
////////////////////////////////////////////////////////////////////////////////
//
// DMI decodes these protocol message encodings:
//
////////////////////////////////////////////////////////////////////////////////
localparam <%=obj.BlockId%>_harness_MsgType_t <%=obj.BlockId%>_harness_DTW_NO_DATA     = 8'b10010000;  //0x90
localparam <%=obj.BlockId%>_harness_MsgType_t <%=obj.BlockId%>_harness_DTW_DATA_CLN    = 8'b10010001;  //0x91
localparam <%=obj.BlockId%>_harness_MsgType_t <%=obj.BlockId%>_harness_DTW_DATA_PTL    = 8'b10010010;  //0x92
localparam <%=obj.BlockId%>_harness_MsgType_t <%=obj.BlockId%>_harness_DTW_DATA_DTY    = 8'b10010011;  //0x93
localparam <%=obj.BlockId%>_harness_MsgType_t <%=obj.BlockId%>_harness_DTW_MRG_MRD_INV  = 8'b10011000;  //0x98
localparam <%=obj.BlockId%>_harness_MsgType_t <%=obj.BlockId%>_harness_DTW_MRG_MRD_SCLN = 8'b10011001;  //0x99
localparam <%=obj.BlockId%>_harness_MsgType_t <%=obj.BlockId%>_harness_DTW_MRG_MRD_SDTY = 8'b10011010;  //0x9A
localparam <%=obj.BlockId%>_harness_MsgType_t <%=obj.BlockId%>_harness_DTW_MRG_MRD_UCLN = 8'b10011011;  //0x9B
localparam <%=obj.BlockId%>_harness_MsgType_t <%=obj.BlockId%>_harness_DTW_MRG_MRD_UDTY = 8'b10011100;  //0x9C
////////////////////////////////////////////////////////////////////////////////
//
// All response types
//
////////////////////////////////////////////////////////////////////////////////
localparam <%=obj.BlockId%>_harness_MsgType_t <%=obj.BlockId%>_harness_C_CMD_RSP  = 8'b11110000;  //0xF0
localparam <%=obj.BlockId%>_harness_MsgType_t <%=obj.BlockId%>_harness_NC_CMD_RSP = 8'b11110001;  //0xF1
localparam <%=obj.BlockId%>_harness_MsgType_t <%=obj.BlockId%>_harness_SNP_RSP    = 8'b11110010;  //0xF2
localparam <%=obj.BlockId%>_harness_MsgType_t <%=obj.BlockId%>_harness_DTW_RSP    = 8'b11110011;  //0xF3
localparam <%=obj.BlockId%>_harness_MsgType_t <%=obj.BlockId%>_harness_DTR_RSP    = 8'b11110100;  //0xF4
localparam <%=obj.BlockId%>_harness_MsgType_t <%=obj.BlockId%>_harness_HNT_RSP    = 8'b11110101;  //0xF5
localparam <%=obj.BlockId%>_harness_MsgType_t <%=obj.BlockId%>_harness_MRD_RSP    = 8'b11110110;  //0xF6
localparam <%=obj.BlockId%>_harness_MsgType_t <%=obj.BlockId%>_harness_STR_RSP    = 8'b11110111;  //0xF7
localparam <%=obj.BlockId%>_harness_MsgType_t <%=obj.BlockId%>_harness_UPD_RSP    = 8'b11111000;  //0xF8
localparam <%=obj.BlockId%>_harness_MsgType_t <%=obj.BlockId%>_harness_RB_RSP     = 8'b11111001;  //0xF9
localparam <%=obj.BlockId%>_harness_MsgType_t <%=obj.BlockId%>_harness_RB_USE_RSP = 8'b11111010;  //0xFA
localparam <%=obj.BlockId%>_harness_MsgType_t <%=obj.BlockId%>_harness_CMP_RSP    = 8'b11111100;  //0xFC
localparam <%=obj.BlockId%>_harness_MsgType_t <%=obj.BlockId%>_harness_CME_RSP    = 8'b11111101;  //0xFD
localparam <%=obj.BlockId%>_harness_MsgType_t <%=obj.BlockId%>_harness_TRE_RSP    = 8'b11111110;  //0xFE
////////////////////////////////////////////////////////////////////////////////
//
// DMI decodes these protocol message encodings:
//
////////////////////////////////////////////////////////////////////////////////

localparam <%=obj.BlockId%>_harness_MsgType_t <%=obj.BlockId%>_harness_RB_REQ         = 8'b01111100;  //0x7C 
localparam <%=obj.BlockId%>_harness_MsgType_t <%=obj.BlockId%>_harness_RB_USED        = 8'b01111101;  //0x7D

 <% } %>
