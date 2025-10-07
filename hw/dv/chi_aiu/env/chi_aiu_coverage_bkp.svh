typedef struct{
	bit[1:0] sysreq_event_opcode;
	bit event_receiver_enable;
	bit sysreq_event;
	bit [7:0] cm_status;
	bit timeout_err_det_en;
	bit timeout_err_int_en;
	bit [3:0] uesr_err_type;
	bit err_valid;
	bit irq_uc;
	int timeout_threshold;
}sysreq_pkt_t;   // This is temporary - Can be deleted after sysreq events feature delivery

class chi_aiu_coverage;
    // REQ flit fields
    bit                      lcrdv;
    chi_addr_t               addr;
    chi_req_size_t           size;
    chi_req_expcompack_t     expcompack;
    chi_req_snoopme_t        snoopme;
    chi_req_excl_t           excl;
    chi_req_order_t          order;
    chi_tracetag_t           tracetag;
    // SNP flit fields
    chi_ns_t                 ns;
    chi_snp_donotgotosd_t    donotgotosd;
    chi_snp_donotdatapull_t  donotdatapull;
    int                      num_stashing_snps;
    int                      num_donotdatapull_asserted;
    bit [3:0]                stsh_snoops_with_donotdatapull;
	sysreq_pkt_t 		     sysreq_pkt;
    chi_aiu_scb_txn          scb_txn_item;
    chi_req_opcode_enum_t    req_opcode;
    chi_req_opcode_enum_t    req_type;
    chi_dat_opcode_enum_t    rdata_opcode;
    chi_dat_opcode_enum_t    wdata_opcode;
    chi_rsp_opcode_enum_t    srsp_opcode;
    chi_rsp_opcode_enum_t    crsp_opcode;
    chi_snp_opcode_enum_t    snp_opcode;
    chi_sysco_state_t        smi_sysco_state, chi_sysco_state;
    chi_sysco_state_t        smi_dvm_part2_sysco_state, chi_dvm_part2_sysco_state;
    bit                      isSnoop,isDVMSnoop, is_sysco_snp_returned;
    bit [WRESP-1:0]          compdata_resp;
    bit [WRESP-1:0]          snp_resp;
    bit [WRESP-1:0]          comp_resp;
    smi_msg_type_bit_t       snp_req_type;
    smi_cmstatus_rv_t        snp_rsp_rv;
    smi_cmstatus_rs_t        snp_rsp_rs;
    smi_cmstatus_dc_t        snp_rsp_dc;
    smi_cmstatus_dt_aiu_t    snp_rsp_dt_aiu;
    smi_cmstatus_dt_dmi_t    snp_rsp_dt_dmi ;
    bit [6:0]                creditv_dly;
    bit [5:0]                snp_req_rsp_dly;
    bit [11:0]               chi_cmd_req_latency;
    bit [9:0]                chi_snp_req_latency;
    bit [4:0]                chi_cmd_req_dly;
    bit [8:0]                chi_snp_req_dly;
    bit                      snp_addr_match_chi_req;
    time                     t_chi_snp_rcvd;
    time                     t_chi_req_flitv[$];
    enum {cmdReq_cmdRsp_strReq_strRsp_dtrReq_dtrRsp, // read txn
          cmdReq_cmdRsp_strReq_dtrReq_dtrRsp_strRsp,
          cmdReq_cmdRsp_strReq_dtrReq_strRsp_dtrRsp,
          cmdReq_strReq_cmdRsp_strRsp_dtrReq_dtrRsp,
          cmdReq_strReq_cmdRsp_dtrReq_strRsp_dtrRsp,
          cmdReq_strReq_cmdRsp_dtrReq_dtrRsp_strRsp,
          cmdReq_strReq_dtrReq_cmdRsp_strRsp_dtrRsp,
          cmdReq_strReq_dtrReq_cmdRsp_dtrRsp_strRsp,
          cmdReq_strReq_dtrReq_strRsp_cmdRsp_dtrRsp,
          cmdReq_strReq_dtrReq_strRsp_dtrRsp_cmdRsp,
          cmdReq_strReq_dtrReq_dtrRsp_cmdRsp_strRsp,
          cmdReq_strReq_dtrReq_dtrRsp_strRsp_cmdRsp,
          cmdReq_cmdRsp_dtrReq_dtrRsp_strReq_strRsp,
          cmdReq_cmdRsp_dtrReq_strReq_dtrRsp_strRsp,
          cmdReq_cmdRsp_dtrReq_strReq_strRsp_dtrRsp,
          cmdReq_dtrReq_cmdRsp_dtrRsp_strReq_strRsp,
          cmdReq_dtrReq_cmdRsp_strReq_strRsp_dtrRsp,
          cmdReq_dtrReq_cmdRsp_strReq_dtrRsp_strRsp,
          cmdReq_dtrReq_strReq_cmdRsp_strRsp_dtrRsp,
          cmdReq_dtrReq_strReq_cmdRsp_dtrRsp_strRsp,
          cmdReq_dtrReq_strReq_strRsp_cmdRsp_dtrRsp,
          cmdReq_dtrReq_strReq_dtrRsp_cmdRsp_strRsp,
          cmdReq_dtrReq_strReq_strRsp_dtrRsp_cmdRsp,
          cmdReq_dtrReq_strReq_dtrRsp_strRsp_cmdRsp,
          cmdReq_cmdRsp_strReq_strRsp_dtwReq_dtwRsp,
          cmdReq_cmdRsp_strReq_dtwReq_dtwRsp_strRsp, // write txn
          cmdReq_cmdRsp_strReq_dtwReq_strRsp_dtwRsp,
          cmdReq_strReq_cmdRsp_strRsp_dtwReq_dtwRsp,
          cmdReq_strReq_cmdRsp_dtwReq_strRsp_dtwRsp,
          cmdReq_strReq_cmdRsp_dtwReq_dtwRsp_strRsp,
          cmdReq_strReq_dtwReq_cmdRsp_strRsp_dtwRsp,
          cmdReq_strReq_dtwReq_cmdRsp_dtwRsp_strRsp,
          cmdReq_strReq_dtwReq_strRsp_cmdRsp_dtwRsp,
          cmdReq_strReq_dtwReq_strRsp_dtwRsp_cmdRsp,
          cmdReq_strReq_dtwReq_dtwRsp_cmdRsp_strRsp,
          cmdReq_strReq_dtwReq_dtwRsp_strRsp_cmdRsp,
          snpReq_dtwReq_dtrReq_dtwrsp_dtrrsp_snprsp, // snoop txn
          snpReq_dtwReq_dtrReq_dtwrsp_snprsp_dtrrsp,
          snpReq_dtwReq_dtrReq_dtrrsp_dtwrsp_snprsp,
          snpReq_dtwReq_dtrReq_dtrrsp_snprsp_dtwrsp,
          snpReq_dtwReq_dtrReq_snprsp_dtrrsp_dtwrsp,
          snpReq_dtwReq_dtrReq_snprsp_dtwrsp_dtrrsp,
          snpReq_dtrReq_dtwReq_dtwrsp_dtrrsp_snprsp,
          snpReq_dtrReq_dtwReq_dtwrsp_snprsp_dtrrsp,
          snpReq_dtrReq_dtwReq_dtrrsp_dtwrsp_snprsp,
          snpReq_dtrReq_dtwReq_dtrrsp_snprsp_dtwrsp,
          snpReq_dtrReq_dtwReq_snprsp_dtrrsp_dtwrsp,
          snpReq_dtrReq_dtwReq_snprsp_dtwrsp_dtrrsp,
          snpReq_dtwReq_dtwrsp_snprsp,
          snpReq_dtwReq_snprsp_dtwrsp,
          snpReq_dtrReq_dtrrsp_snprsp,
          snpReq_dtrReq_snprsp_dtrrsp} smi_msg_seq;

///////////////////////////////////////////////////////////////////////////////////
// COVERPOINTS ON SMI INTERFACE
///////////////////////////////////////////////////////////////////////////////////
    covergroup concerto_messages;
        seq_of_transitions: coverpoint smi_msg_seq {
            bins cp_cmdReq_cmdRsp_strReq_strRsp_dtrReq_dtrRsp = {0};
            bins cp_cmdReq_cmdRsp_strReq_dtrReq_dtrRsp_strRsp = {1};
            bins cp_cmdReq_cmdRsp_strReq_dtrReq_strRsp_dtrRsp = {2};
            bins cp_cmdReq_strReq_cmdRsp_strRsp_dtrReq_dtrRsp = {3};
            bins cp_cmdReq_strReq_cmdRsp_dtrReq_strRsp_dtrRsp = {4};
            bins cp_cmdReq_strReq_cmdRsp_dtrReq_dtrRsp_strRsp = {5};
            bins cp_cmdReq_strReq_dtrReq_cmdRsp_strRsp_dtrRsp = {6};
            bins cp_cmdReq_strReq_dtrReq_cmdRsp_dtrRsp_strRsp = {7};
            bins cp_cmdReq_strReq_dtrReq_strRsp_cmdRsp_dtrRsp = {8};
            bins cp_cmdReq_strReq_dtrReq_strRsp_dtrRsp_cmdRsp = {9};
            bins cp_cmdReq_strReq_dtrReq_dtrRsp_cmdRsp_strRsp = {10};
            bins cp_cmdReq_strReq_dtrReq_dtrRsp_strRsp_cmdRsp = {11};
            bins cp_cmdReq_cmdRsp_dtrReq_dtrRsp_strReq_strRsp = {12};
            bins cp_cmdReq_cmdRsp_dtrReq_strReq_dtrRsp_strRsp = {13};
            bins cp_cmdReq_cmdRsp_dtrReq_strReq_strRsp_dtrRsp = {14};
            bins cp_cmdReq_dtrReq_cmdRsp_dtrRsp_strReq_strRsp = {15};
            bins cp_cmdReq_dtrReq_cmdRsp_strReq_strRsp_dtrRsp = {16};
            bins cp_cmdReq_dtrReq_cmdRsp_strReq_dtrRsp_strRsp = {17};
            bins cp_cmdReq_dtrReq_strReq_cmdRsp_strRsp_dtrRsp = {18};
            bins cp_cmdReq_dtrReq_strReq_cmdRsp_dtrRsp_strRsp = {19};
            bins cp_cmdReq_dtrReq_strReq_strRsp_cmdRsp_dtrRsp = {20};
            bins cp_cmdReq_dtrReq_strReq_dtrRsp_cmdRsp_strRsp = {21};
            bins cp_cmdReq_dtrReq_strReq_strRsp_dtrRsp_cmdRsp = {22};
            bins cp_cmdReq_dtrReq_strReq_dtrRsp_strRsp_cmdRsp = {23};
            bins cp_cmdReq_cmdRsp_strReq_strRsp_dtwReq_dtwRsp = {24};
            bins cp_cmdReq_cmdRsp_strReq_dtwReq_dtwRsp_strRsp = {25};
            bins cp_cmdReq_cmdRsp_strReq_dtwReq_strRsp_dtwRsp = {26};
            bins cp_cmdReq_strReq_cmdRsp_strRsp_dtwReq_dtwRsp = {27};
            bins cp_cmdReq_strReq_cmdRsp_dtwReq_strRsp_dtwRsp = {28};
            bins cp_cmdReq_strReq_cmdRsp_dtwReq_dtwRsp_strRsp = {29};
            bins cp_cmdReq_strReq_dtwReq_cmdRsp_strRsp_dtwRsp = {30};
            bins cp_cmdReq_strReq_dtwReq_cmdRsp_dtwRsp_strRsp = {31};
            bins cp_cmdReq_strReq_dtwReq_strRsp_cmdRsp_dtwRsp = {32};
            bins cp_cmdReq_strReq_dtwReq_strRsp_dtwRsp_cmdRsp = {33};
            bins cp_cmdReq_strReq_dtwReq_dtwRsp_cmdRsp_strRsp = {34};
            bins cp_cmdReq_strReq_dtwReq_dtwRsp_strRsp_cmdRsp = {35};
            bins cp_snpReq_dtwReq_dtrReq_dtwrsp_dtrrsp_snprsp = {36};
            bins cp_snpReq_dtwReq_dtrReq_dtwrsp_snprsp_dtrrsp = {37};
            bins cp_snpReq_dtwReq_dtrReq_dtrrsp_dtwrsp_snprsp = {38};
            bins cp_snpReq_dtwReq_dtrReq_dtrrsp_snprsp_dtwrsp = {39};
            bins cp_snpReq_dtwReq_dtrReq_snprsp_dtrrsp_dtwrsp = {40};
            bins cp_snpReq_dtwReq_dtrReq_snprsp_dtwrsp_dtrrsp = {41};
            bins cp_snpReq_dtrReq_dtwReq_dtwrsp_dtrrsp_snprsp = {42};
            bins cp_snpReq_dtrReq_dtwReq_dtwrsp_snprsp_dtrrsp = {43};
            bins cp_snpReq_dtrReq_dtwReq_dtrrsp_dtwrsp_snprsp = {44};
            bins cp_snpReq_dtrReq_dtwReq_dtrrsp_snprsp_dtwrsp = {45};
            bins cp_snpReq_dtrReq_dtwReq_snprsp_dtrrsp_dtwrsp = {46};
            bins cp_snpReq_dtrReq_dtwReq_snprsp_dtwrsp_dtrrsp = {47};
            bins cp_snpReq_dtwReq_dtwrsp_snprsp = {48};
            bins cp_snpReq_dtwReq_snprsp_dtwrsp = {49}; 
            bins cp_snpReq_dtrReq_dtrrsp_snprsp = {50}; 
            bins cp_snpReq_dtrReq_snprsp_dtrrsp = {51}; 
        }
    endgroup
    covergroup smi_snp_resp;
        snp_req: coverpoint snp_req_type {
          bins snp_cln_dtr       = {SNP_CLN_DTR};
          bins snp_nitc          = {SNP_NITC};
          bins snp_vld_dtr       = {SNP_VLD_DTR};
          bins snp_inv_dtr       = {SNP_INV_DTR};
          bins snp_inv_dtw       = {SNP_INV_DTW};
          bins snp_inv           = {SNP_INV};
          bins snp_cln_dtw       = {SNP_CLN_DTW};
          bins snp_recall        = {SNP_RECALL};
          bins snp_nosdint       = {SNP_NOSDINT};
          <% if(obj.AiuInfo[obj.Id].fnNativeInterface != 'CHI-A') { %>
          bins snp_inv_stsh      = {SNP_INV_STSH};
          bins snp_unq_stsh      = {SNP_UNQ_STSH};
          bins snp_stsh_sh       = {SNP_STSH_SH};
          bins snp_stsh_unq      = {SNP_STSH_UNQ};
          <% } %>
          bins snp_dvm_msg       = {SNP_DVM_MSG};
          bins snp_nitcci        = {SNP_NITCCI};
          bins snp_nitcmi        = {SNP_NITCMI};
        }
        snprsp_rv :coverpoint snp_rsp_rv;
        snprsp_rs :coverpoint snp_rsp_rs;
        snprsp_dc :coverpoint snp_rsp_dc;
        snprsp_dt_aiu :coverpoint snp_rsp_dt_aiu;
        snprsp_dt_dmi :coverpoint snp_rsp_dt_dmi;
        cross snp_req, snprsp_rv;
        cross snp_req, snprsp_rs;
        cross snp_req, snprsp_dc;
        cross snp_req, snprsp_dt_aiu;
        cross snp_req, snprsp_dt_dmi;
    endgroup

///////////////////////////////////////////////////////////////////////////////////
// COVERPOINTS ON CHI INTERFACE
///////////////////////////////////////////////////////////////////////////////////
    covergroup chi_req_port;
        chi_req_opcode: coverpoint req_opcode {
            bins REQLCRDRETURN        = {'h00};
            bins READSHARED           = {'h01};
            bins READCLEAN            = {'h02};
            bins READONCE             = {'h03};
            bins READNOSNP            = {'h04};
            <% if(obj.AiuInfo[obj.Id].fnNativeInterface == 'CHI-E') { %>
            bins PCRDRETURN           = {'h05};
            <% } %>
            ignore_bins RSVD_6        = {'h06}; // TODO: make it illegal later(unsupported_txn)
            bins READUNIQUE           = {'h07};
            bins CLEANSHARED          = {'h08};
            bins CLEANINVALID         = {'h09};
            bins MAKEINVALID          = {'h0A};
            bins CLEANUNIQUE          = {'h0B};
            bins MAKEUNIQUE           = {'h0C};
            bins EVICT                = {'h0D};
            <% if(obj.AiuInfo[obj.Id].fnNativeInterface == 'CHI-A') { %>
            ignore_bins EOBARRIER     = {'h0E};
            ignore_bins ECBARRIER     = {'h0F};
            <% } %>
            ignore_bins RSVD_10_13    = {['h10 : 'h13]}; // TODO: make it illegal later(unsupported_txn)
            bins DVMOP                = {'h14};
            bins WRITEEVICTFULL       = {'h15};
            <% if(obj.AiuInfo[obj.Id].fnNativeInterface == 'CHI-A') { %>
            bins WRITECLEANPTL        = {'h16};
            <% } %>
            bins WRITECLEANFULL       = {'h17};
            bins WRITEUNIQUEPTL       = {'h18};
            bins WRITEUNIQUEFULL      = {'h19};
            bins WRITEBACKPTL         = {'h1A};
            bins WRITEBACKFULL        = {'h1B};
            bins WRITENOSNPPTL        = {'h1C};
            bins WRITENOSNPFULL       = {'h1D};
            ignore_bins RSVD_1E_1F    = {['h1E : 'h1F]}; // TODO: make it illegal later(unsupported_txn)
            <% if(obj.AiuInfo[obj.Id].fnNativeInterface != 'CHI-A') { %>
            bins WRITEUNIQUEFULLSTASH = {'h20};
            bins WRITEUNIQUEPTLSTASH  = {'h21};
            bins STASHONCESHARED      = {'h22};
            bins STASHONCEUNIQUE      = {'h23};
            bins READONCECLEANINVALID = {'h24};
            bins READONCEMAKEINVALID  = {'h25};
            bins READNOTSHAREDDIRTY   = {'h26};
            bins CLEANSHAREDPERSIST   = {'h27};
            bins ATOMICSTORE_STADD    = {'h28};
            bins ATOMICSTORE_STCLR    = {'h29};
            bins ATOMICSTORE_STEOR    = {'h2A};
            bins ATOMICSTORE_STSET    = {'h2B};
            bins ATOMICSTORE_STSMAX   = {'h2C};
            bins ATOMICSTORE_STMIN    = {'h2D};
            bins ATOMICSTORE_STUSMAX  = {'h2E};
            bins ATOMICSTORE_STUMIN   = {'h2F};
            bins ATOMICLOAD_LDADD     = {'h30};
            bins ATOMICLOAD_LDCLR     = {'h31};
            bins ATOMICLOAD_LDEOR     = {'h32};
            bins ATOMICLOAD_LDSET     = {'h33};
            bins ATOMICLOAD_LDSMAX    = {'h34};
            bins ATOMICLOAD_LDMIN     = {'h35};
            bins ATOMICLOAD_LDUSMAX   = {'h36};
            bins ATOMICLOAD_LDUMIN    = {'h37};
            bins ATOMICSWAP           = {'h38};
            bins ATOMICCOMPARE        = {'h39};
            bins PREFETCHTARGET       = {'h3A};
            ignore_bins RSVD_3B_3F    = {['h3B : 'h3F]}; // TODO: make it illegal later(unsupported_txn)
          <% } %>
        }
        chi_req_to_crd_delay: coverpoint creditv_dly iff (lcrdv);
        chi_cmd_req_delay: coverpoint chi_cmd_req_dly;
        chi_req_addr: coverpoint addr;
        chi_req_size: coverpoint size {
          illegal_bins RSVD_7 = {'h7};
        }
        chi_req_expcompack: coverpoint expcompack;
        chi_req_excl: coverpoint excl;
        chi_req_order: coverpoint order {
          //Applicable in Read request from HN-F to SN-F only.  Reserved in all other cases.
          illegal_bins RSVD_1 = {'h1};
        }
        <% if(obj.AiuInfo[obj.Id].fnNativeInterface != 'CHI-A') { %>
        chi_req_snoopme: coverpoint snoopme;
        chi_req_tracetag: coverpoint tracetag;
        snoopeme_cross_ATOMICSTORE_STADD  : coverpoint snoopme iff (req_opcode == {'h28});
        snoopeme_cross_ATOMICSTORE_STCLR  : coverpoint snoopme iff (req_opcode == {'h29});
        snoopeme_cross_ATOMICSTORE_STEOR  : coverpoint snoopme iff (req_opcode == {'h2A});
        snoopeme_cross_ATOMICSTORE_STSET  : coverpoint snoopme iff (req_opcode == {'h2B});
        snoopeme_cross_ATOMICSTORE_STSMAX : coverpoint snoopme iff (req_opcode == {'h2C});
        snoopeme_cross_ATOMICSTORE_STMIN  : coverpoint snoopme iff (req_opcode == {'h2D});
        snoopeme_cross_ATOMICSTORE_STUSMAX: coverpoint snoopme iff (req_opcode == {'h2E});
        snoopeme_cross_ATOMICSTORE_STUMIN : coverpoint snoopme iff (req_opcode == {'h2F});
        snoopeme_cross_ATOMICLOAD_LDADD   : coverpoint snoopme iff (req_opcode == {'h30});
        snoopeme_cross_ATOMICLOAD_LDCLR   : coverpoint snoopme iff (req_opcode == {'h31});
        snoopeme_cross_ATOMICLOAD_LDEOR   : coverpoint snoopme iff (req_opcode == {'h32});
        snoopeme_cross_ATOMICLOAD_LDSET   : coverpoint snoopme iff (req_opcode == {'h33});
        snoopeme_cross_ATOMICLOAD_LDSMAX  : coverpoint snoopme iff (req_opcode == {'h34});
        snoopeme_cross_ATOMICLOAD_LDMIN   : coverpoint snoopme iff (req_opcode == {'h35});
        snoopeme_cross_ATOMICLOAD_LDUSMAX : coverpoint snoopme iff (req_opcode == {'h36});
        snoopeme_cross_ATOMICLOAD_LDUMIN  : coverpoint snoopme iff (req_opcode == {'h37});
        snoopeme_cross_ATOMICSWAP         : coverpoint snoopme iff (req_opcode == {'h38});
        snoopeme_cross_ATOMICCOMPARE      : coverpoint snoopme iff (req_opcode == {'h39});
        <% } %>
        chi_req_opcode_cross_size: cross chi_req_opcode, chi_req_size {
            ignore_bins ignore_atomic_cmp = binsof(chi_req_opcode) intersect {'h39} &&
                                            binsof(chi_req_size) intersect {0,6};
            ignore_bins ignore_atomic_load_store_swap = binsof(chi_req_opcode) intersect {['h28:'h38]} &&
                                                        binsof(chi_req_size) intersect {4,5,6};
        }
        chi_req_opcode_cross_expcompack: cross chi_req_opcode, chi_req_expcompack;
        chi_req_opcode_cross_excl: cross chi_req_opcode, chi_req_excl;
    endgroup

    covergroup chi_wdata_port;
        chi_wdata_opcode: coverpoint wdata_opcode {
            bins DATALCRDRETURN            = {'h0};
            bins SNPRESPDATA               = {'h1};
            bins COPYBACKWRDATA            = {'h2};
            bins NONCOPYBACKWRDATA         = {'h3};
            illegal_bins COMPDATA          = {'h4};
            bins SNPRESPDATAPTL            = {'h5};
            <% if(obj.AiuInfo[obj.Id].fnNativeInterface != 'CHI-A') { %>
            ignore_bins SNPRESPDATAFWDED          = {'h6};
            bins WRDATACANCEL              = {'h7};
            <% } %>
        }
        <% if(obj.AiuInfo[obj.Id].fnNativeInterface != 'CHI-A') { %>
        req_type_for_wrdatacancel: coverpoint req_opcode {
            bins WRITEUNIQUEPTL       = {'h18} iff (wdata_opcode == {'h7});
            bins WRITENOSNPPTL        = {'h1C} iff (wdata_opcode == {'h7});
            bins WRITEUNIQUEPTLSTASH  = {'h21} iff (wdata_opcode == {'h7});
        }
        <% } %>
    endgroup

    covergroup chi_rdata_port;
        opcode: coverpoint rdata_opcode {
            bins DATALCRDRETURN            = {'h0};
            illegal_bins SNPRESPDATA       = {'h1};
            illegal_bins COPYBACKWRDATA    = {'h2};
            illegal_bins NONCOPYBACKWRDATA = {'h3};
            bins COMPDATA                  = {'h4};
            illegal_bins SNPRESPDATAPTL    = {'h5};
            <% if(obj.AiuInfo[obj.Id].fnNativeInterface != 'CHI-A') { %>
            illegal_bins SNPRESPDATAFWDED  = {'h6};
            illegal_bins WRDATACANCEL      = {'h7};
            <% } %>
        }
    endgroup

    covergroup chi_srsp_port;
        chi_srsp_opcode: coverpoint srsp_opcode {
            bins RESPLCRDRETURN         = {'h0};
            bins SNPRESP                = {'h1};
            bins COMPACK                = {'h2};
            <% if(obj.AiuInfo[obj.Id].fnNativeInterface == 'CHI-E') { %>
            illegal_bins RETRYACK       = {'h3};
            <% } %>
            illegal_bins COMP           = {'h4};
            illegal_bins COMPDBIDRESP   = {'h5};
            illegal_bins DBIDRESP       = {'h6};
            <% if(obj.AiuInfo[obj.Id].fnNativeInterface == 'CHI-E') { %>
            illegal_bins PCRDGRANT      = {'h7};
            <% } %>
            illegal_bins READRECEIPT    = {'h8};

        }
    endgroup

    covergroup chi_crsp_port;
        chi_crsp_opcode: coverpoint crsp_opcode {
            bins RESPLCRDRETURN         = {'h0};
            illegal_bins SNPRESP        = {'h1};
            illegal_bins COMPACK        = {'h2};
            <% if(obj.AiuInfo[obj.Id].fnNativeInterface == 'CHI-E') { %>
            bins RETRYACK               = {'h3};
            <% } %>
            bins COMP                   = {'h4};
            bins COMPDBIDRESP           = {'h5};
            bins DBIDRESP               = {'h6};
            <% if(obj.AiuInfo[obj.Id].fnNativeInterface == 'CHI-E') { %>
            bins PCRDGRANT              = {'h7};
            <% } %>
            bins READRECEIPT            = {'h8};
        }
    endgroup

    covergroup chi_snp_port;
        chi_snp_opcode: coverpoint snp_opcode {
            bins SNPLCRDRETURN   = {'h0};
            bins SNPSHARED       = {'h1};
            bins SNPCLEAN        = {'h2};
            bins SNPONCE         = {'h3};
            <% if(obj.AiuInfo[obj.Id].fnNativeInterface != 'CHI-A') { %>
            bins SNPNSHDTY       = {'h4};
            bins SNPUNQSTASH     = {'h5};
            bins SNPMKINVSTASH   = {'h6};
            <% } %>
            bins SNPUNIQUE       = {'h7};
            bins SNPCLEANSHARED  = {'h8};
            bins SNPCLEANINVALID = {'h9};
            bins SNPMAKEINVALID  = {'hA};
            <% if(obj.AiuInfo[obj.Id].fnNativeInterface != 'CHI-A') { %>
            bins SNPSTASHUNQ     = {'hB};
            bins SNPSTASHSHRD    = {'hC};
            <% } %>
            bins SNPDVMOP        = {'hD};
            <% if(obj.AiuInfo[obj.Id].fnNativeInterface != 'CHI-A') { %>
            ignore_bins SNPSHRFWD       = {'h11};
            ignore_bins SNPCLNFWD       = {'h12};
            ignore_bins SNPONCEFWD      = {'h13};
            ignore_bins SNPNOTSDFWD     = {'h14};
            ignore_bins SNPUNQFWD       = {'h17};
            <% } %>
        }
        snp_req_delay: coverpoint chi_snp_req_dly; 
        snp_addr_match_pending_chi_req: coverpoint snp_addr_match_chi_req;
        opcode_cross_ns: cross ns, chi_snp_opcode;
        <% if(obj.AiuInfo[obj.Id].fnNativeInterface != 'CHI-A') { %>
        opcode_cross_donotgotosd: cross donotgotosd, chi_snp_opcode;
        opcode_cross_donotdatapull: cross donotdatapull, chi_snp_opcode;
        <% } %>
    endgroup

    <% if(obj.AiuInfo[obj.Id].fnNativeInterface != 'CHI-A') { %>
    covergroup stashing_snoops;
        donotdatapull_asserted:coverpoint stsh_snoops_with_donotdatapull;
    endgroup
    <% } %>
    covergroup req_cross_resp;
        cp_snp_resp: coverpoint snp_resp {
          <% if(obj.AiuInfo[obj.Id].fnNativeInterface == 'CHI-A') { %>
          ignore_bins UNUSED_7 = {'h07};
          <% } %>
        }

        cp_snp_opcode: coverpoint snp_opcode {
          <% if(obj.AiuInfo[obj.Id].fnNativeInterface == 'CHI-A') { %>
          ignore_bins SNPNSHDTY       = {'h4};
          ignore_bins SNPUNQSTASH     = {'h5};
          ignore_bins SNPMKINVSTASH   = {'h6};
          ignore_bins SNPSTASHUNQ     = {'hB};
          ignore_bins SNPSTASHSHRD    = {'hC};
          <% } %>
          ignore_bins SNPSHRFWD       = {'h11};
          ignore_bins SNPCLNFWD       = {'h12};
          ignore_bins SNPONCEFWD      = {'h13};
          ignore_bins SNPNOTSDFWD     = {'h14};
          ignore_bins SNPUNQFWD       = {'h17};
        }

        cp_comp_resp: coverpoint comp_resp {
          bins COMP_I              = {'h00};
          bins COMP_SC             = {'h01};
          bins COMP_UC             = {'h02};
          ignore_bins UNUSED_3_ALL = {['h03 : $]};
        }

        cp_compdata_resp: coverpoint compdata_resp {
          bins COMPDATA_I          = {'h00};
          bins COMPDATA_SC         = {'h01};
          bins COMPDATA_UC         = {'h02};
          bins COMPDATA_UD_PD      = {'h06};
          bins COMPDATA_SD_PD      = {'h07};
          ignore_bins UNUSED_3_5   = {['h03 : 'h5]};
          ignore_bins UNUSED_7_ALL = {['h07 : $]};
        }
        chi_snp_rsp_delay: coverpoint snp_req_rsp_dly;
        chi_cmd_req_processed: coverpoint chi_cmd_req_latency;
        chi_snp_req_processed: coverpoint chi_snp_req_latency;
        req_type_cross_compdata_resp: cross req_opcode, cp_compdata_resp;
        req_type_cross_comp_resp: cross req_opcode, cp_comp_resp;
        snp_req_cross_rsp_snpResp: cross cp_snp_opcode, cp_snp_resp iff (srsp_opcode == SNPRESP);
        snp_req_cross_rsp_snpRespData: cross cp_snp_opcode, cp_snp_resp iff (rdata_opcode == SNPRESPDATA);
        snp_req_cross_rsp_snpRespDataPtl: cross cp_snp_opcode, cp_snp_resp iff (rdata_opcode == SNPRESPDATAPTL);
    endgroup

    <% if(obj.AiuInfo[obj.Id].fnNativeInterface != 'CHI-A') { %>
    covergroup chi_smi_sysco_states;
        option.name         = "SYSCO coverage at CHI-block level";
        option.comment      = "This coverage samples the sysco_state for incoming snoops from the TB perspective when the Txn sampled
                               at SMI/CHI interface from respective monitor. RTL may had consume Txn during different sysco_state";
        option.per_instance = 1;
        option.goal         = 100;

        cp_smi_sysco_state: coverpoint smi_sysco_state{
          bins DISABLED   = {DISABLED  };
          bins CONNECT    = {CONNECT   };
          bins ENABLED    = {ENABLED   };
          bins DISCONNECT = {DISCONNECT};
        }
        cp_smi_dvm_part2_sysco_state: coverpoint smi_dvm_part2_sysco_state iff (isDVMSnoop){
          bins DISABLED   = {DISABLED  };
          bins CONNECT    = {CONNECT   };
          bins ENABLED    = {ENABLED   };
          bins DISCONNECT = {DISCONNECT};
        }
        cp_chi_sysco_state: coverpoint chi_sysco_state iff (!is_sysco_snp_returned){
          illegal_bins DISABLED   = {DISABLED  };
          bins         CONNECT    = {CONNECT   }; // RTL will/won't? ignore_bins?
          bins         ENABLED    = {ENABLED   };
          bins         DISCONNECT = {DISCONNECT};
        }
        cp_chi_dvm_part2_sysco_state: coverpoint chi_dvm_part2_sysco_state iff (!is_sysco_snp_returned && isDVMSnoop){
          illegal_bins DISABLED   = {DISABLED  };
          bins         CONNECT    = {CONNECT   }; // RTL will/won't? ignore_bins?
          bins         ENABLED    = {ENABLED   };
          bins         DISCONNECT = {DISCONNECT};
        }
        cp_is_sysco_snp_returned: coverpoint is_sysco_snp_returned{
          bins RETURNED   = {1};
          bins PASSED_ON  = {0};
        }
        // normal smi_snoop
        Xcp_smi_snp1_vs_return: cross cp_smi_sysco_state, cp_is_sysco_snp_returned iff (!isDVMSnoop){
          // Spec says No
          illegal_bins ENABLED_x_RETURNED     = binsof (cp_smi_sysco_state) intersect {ENABLED}    && binsof (cp_is_sysco_snp_returned) intersect {1};
          illegal_bins DISABLED_x_PASSED_ON   = binsof (cp_smi_sysco_state) intersect {DISABLED}   && binsof (cp_is_sysco_snp_returned) intersect {0};
        }
        // normal chi_snoop
        Xcp_chi_snp1_vs_return: cross cp_chi_sysco_state, cp_is_sysco_snp_returned iff (!isDVMSnoop){
          // Spec says No
          illegal_bins ENABLED_x_RETURNED     = binsof (cp_chi_sysco_state) intersect {ENABLED}    && binsof (cp_is_sysco_snp_returned) intersect {1};
          illegal_bins DISABLED_x_PASSED_ON   = binsof (cp_chi_sysco_state) intersect {DISABLED}   && binsof (cp_is_sysco_snp_returned) intersect {0};
        }
        // normal smi_chi_snoop
        Xcp_smi_snp1_vs_chi_snp1: cross cp_smi_sysco_state, cp_chi_sysco_state iff (!isDVMSnoop && !is_sysco_snp_returned){
          illegal_bins ENABLED_x_DISABLED     = binsof (cp_smi_sysco_state) intersect {ENABLED, CONNECT, DISCONNECT}    && binsof (cp_chi_sysco_state) intersect {DISABLED};
        }
        Xcp_smi_dvm_part2_vs_return: cross cp_smi_dvm_part2_sysco_state, cp_is_sysco_snp_returned iff (isDVMSnoop){
          // Spec says No, but 2nd part can depends on the behaviour from the 1st part so not making them illegal from SMI side
          // illegal/ignore bins?
          illegal_bins ENABLED_x_RETURNED      = binsof (cp_smi_dvm_part2_sysco_state) intersect {ENABLED}    && binsof (cp_is_sysco_snp_returned) intersect {1};
          illegal_bins DISABLED_x_PASSED_ON    = binsof (cp_smi_dvm_part2_sysco_state) intersect {DISABLED}   && binsof (cp_is_sysco_snp_returned) intersect {0};
        }
        Xcp_smi_snp1_vs_snp2_sysco_state: cross cp_smi_sysco_state, cp_smi_dvm_part2_sysco_state iff (isDVMSnoop){
          bins ENABLED_x_ENABLED              = binsof (cp_smi_sysco_state) intersect {ENABLED}    && binsof (cp_smi_dvm_part2_sysco_state) intersect {ENABLED};
          bins ENABLED_x_DISCONNECT           = binsof (cp_smi_sysco_state) intersect {ENABLED}    && binsof (cp_smi_dvm_part2_sysco_state) intersect {DISCONNECT};
          bins DISABLED_x_DISABLED            = binsof (cp_smi_sysco_state) intersect {DISABLED}   && binsof (cp_smi_dvm_part2_sysco_state) intersect {DISABLED};
          bins DISABLED_x_CONNECT             = binsof (cp_smi_sysco_state) intersect {DISABLED}   && binsof (cp_smi_dvm_part2_sysco_state) intersect {CONNECT};
          bins CONNECT_x_CONNECT              = binsof (cp_smi_sysco_state) intersect {CONNECT}    && binsof (cp_smi_dvm_part2_sysco_state) intersect {CONNECT};
          bins CONNECT_x_ENABLED              = binsof (cp_smi_sysco_state) intersect {CONNECT}    && binsof (cp_smi_dvm_part2_sysco_state) intersect {ENABLED};
          bins DISCONNECT_x_DISCONNECT        = binsof (cp_smi_sysco_state) intersect {DISCONNECT} && binsof (cp_smi_dvm_part2_sysco_state) intersect {DISCONNECT};
          bins DISCONNECT_x_DISABLED          = binsof (cp_smi_sysco_state) intersect {DISCONNECT} && binsof (cp_smi_dvm_part2_sysco_state) intersect {DISABLED};

          // Not likely to follow by RTL , ignore or illegal?
          ignore_bins IGNR_ENABLED            = binsof (cp_smi_sysco_state) intersect {ENABLED}    && binsof (cp_smi_dvm_part2_sysco_state) intersect {DISABLED, CONNECT};
          ignore_bins IGNR_DISABLED           = binsof (cp_smi_sysco_state) intersect {DISABLED}   && binsof (cp_smi_dvm_part2_sysco_state) intersect {ENABLED, DISCONNECT};
          ignore_bins IGNR_CONNECT            = binsof (cp_smi_sysco_state) intersect {CONNECT}    && binsof (cp_smi_dvm_part2_sysco_state) intersect {DISABLED, DISCONNECT};
          ignore_bins IGNR_DISCONNECT         = binsof (cp_smi_sysco_state) intersect {DISCONNECT} && binsof (cp_smi_dvm_part2_sysco_state) intersect {CONNECT, ENABLED};
        }
        Xcp_chi_snp1_vs_snp2_sysco_state: cross cp_chi_sysco_state, cp_chi_dvm_part2_sysco_state iff (isDVMSnoop){
          bins ENABLED_x_ENABLED              = binsof (cp_chi_sysco_state) intersect {ENABLED}    && binsof (cp_chi_dvm_part2_sysco_state) intersect {ENABLED};
          bins ENABLED_x_DISCONNECT           = binsof (cp_chi_sysco_state) intersect {ENABLED}    && binsof (cp_chi_dvm_part2_sysco_state) intersect {DISABLED};
          bins DISCONNECT_x_DISCONNECT        = binsof (cp_chi_sysco_state) intersect {DISCONNECT} && binsof (cp_chi_dvm_part2_sysco_state) intersect {DISCONNECT};
          bins CONNECT_x_CONNECT              = binsof (cp_chi_sysco_state) intersect {CONNECT}    && binsof (cp_chi_dvm_part2_sysco_state) intersect {CONNECT};
          bins CONNECT_x_ENABLED              = binsof (cp_chi_sysco_state) intersect {CONNECT}    && binsof (cp_chi_dvm_part2_sysco_state) intersect {ENABLED};
          bins DISABLED_x_DISABLED            = binsof (cp_chi_sysco_state) intersect {DISABLED}   && binsof (cp_chi_dvm_part2_sysco_state) intersect {DISABLED};

          // Spec says No
          illegal_bins IGNR_CONNECT           = binsof (cp_chi_sysco_state) intersect {CONNECT}    && binsof (cp_chi_dvm_part2_sysco_state) intersect {DISCONNECT, DISABLED};
          illegal_bins IGNR_ENABLED           = binsof (cp_chi_sysco_state) intersect {ENABLED}    && binsof (cp_chi_dvm_part2_sysco_state) intersect {CONNECT, DISABLED};
          illegal_bins IGNR_DISCONNECT        = binsof (cp_chi_sysco_state) intersect {DISCONNECT} && binsof (cp_chi_dvm_part2_sysco_state) intersect {CONNECT, ENABLED, DISABLED};
        }
    endgroup
    <% } %>

    covergroup sys_req_events_cg;
        option.per_instance 		= 1;
        cp_sysreq_event_opcode 		: coverpoint sysreq_pkt.sysreq_event_opcode{
            bins event_opcode  		= {3};
        }
        cp_timeout_threshold   		: coverpoint sysreq_pkt.timeout_threshold{
            bins valid_bins[]  		= {[1:3]};
            //Disabled following bin as value 0 -> no timeout and that results in test to fail with UVM_TEMOUT
            //bins disable_value 		= {0};
        }
        cp_event_receiver_enable	: coverpoint sysreq_pkt.event_receiver_enable{
            bins enable				= {1};
            bins dis				= {0};
        }
        cp_sysreq_event				: coverpoint sysreq_pkt.sysreq_event{
            bins sysreq_received	= {1};
        }
        cp_sysrsp_event_cmstatus	: coverpoint sysreq_pkt.cm_status{
            bins good_operation		= {3};
            bins unit_busy			= {1};
            bins receiving_disable	= {0};
        }
        cp_timeout_err_det_en		: coverpoint sysreq_pkt.timeout_err_det_en{
            bins timeout_enable		= {1};
            bins timeout_disable	= {0};
        }	
        cp_timeout_err_int_en		: coverpoint sysreq_pkt.timeout_err_int_en{
            bins timeout_int_en		= {1};
            bins timeout_int_dis	= {0};
        }
        cp_uesr_err_type			: coverpoint sysreq_pkt.uesr_err_type{
            bins uesr_err_type		= {'hA};
        }
        cp_err_valid				: coverpoint sysreq_pkt.err_valid{
            bins valid				= {1};
            bins invalid			= {0};
        }
        cp_uc_int_occurred			: coverpoint sysreq_pkt.irq_uc{
            bins irq_occurred		= {1};
            bins no_irq				= {0};
        }
    endgroup : sys_req_events_cg


    extern function void collect_chi_req_flit(chi_req_seq_item txn);
    extern function void collect_chi_wdata_flit(chi_aiu_scb_txn scb_txn_item);
    extern function void collect_chi_rdata_flit(chi_dat_seq_item txn);
    extern function void collect_chi_srsp_flit(chi_rsp_seq_item txn);
    extern function void collect_chi_crsp_flit(chi_rsp_seq_item txn);
    extern function void collect_chi_snp_flit(chi_snp_seq_item txn);
    extern function void collect_ott_entry(chi_aiu_scb_txn scb_txn_item);
    extern function void collect_sys_req_events(sysreq_pkt_t txn);
    extern function void collect_stasting_snoops();
    
    extern function new();
endclass // chi_aiu_coverage

function void chi_aiu_coverage::collect_chi_req_flit(chi_req_seq_item txn);
    req_opcode = txn.opcode;
    addr       = txn.addr;
    size       = txn.size;
    expcompack = txn.expcompack;
    snoopme    = txn.snoopme;
    excl       = txn.excl;
    order      = txn.order;
    tracetag   = txn.tracetag;
    lcrdv      = txn.lcrdv;
    if (txn.lcrdv) begin
        // cycles required by AIU to release credit
        creditv_dly = ($time - t_chi_req_flitv[0])/10ns;
        chi_cmd_req_dly = ($time - t_chi_req_flitv[$])/10ns;
        t_chi_req_flitv = {}; // delete all items
    end
    // delay btw 2 back to back chi cmd reqs
    chi_cmd_req_dly = ($time - t_chi_req_flitv[$])/10ns;
    t_chi_req_flitv.push_back($time);
    chi_req_port.sample();
endfunction // collect_chi_req_seq_item

function void chi_aiu_coverage::collect_chi_wdata_flit(chi_aiu_scb_txn scb_txn_item);
    if (scb_txn_item.chi_rcvd[`CHI_REQ])
        req_opcode = scb_txn_item.m_chi_req_pkt.opcode;
    if (scb_txn_item.chi_rcvd[`WRITE_DATA_IN]) begin
        foreach(scb_txn_item.m_chi_write_data_pkt[i]) begin
            wdata_opcode = scb_txn_item.m_chi_write_data_pkt[i].opcode;
            chi_wdata_port.sample();
        end
    end else if(scb_txn_item.chi_rcvd[`CHI_SNP_REQ]) begin
        foreach(scb_txn_item.m_chi_snp_data_pkt[i]) begin
            wdata_opcode = scb_txn_item.m_chi_snp_data_pkt[i].opcode;
            chi_wdata_port.sample();
        end
    end
endfunction // collect_chi_wdata_flit

function void chi_aiu_coverage::collect_chi_rdata_flit(chi_dat_seq_item txn);
    rdata_opcode = txn.opcode;
    chi_rdata_port.sample();
endfunction // collect_chi_rdata_seq_item

function void chi_aiu_coverage::collect_chi_srsp_flit(chi_rsp_seq_item txn);
    srsp_opcode = txn.opcode;
    chi_srsp_port.sample();
endfunction // collect_chi_srsp_seq_item

function void chi_aiu_coverage::collect_chi_crsp_flit(chi_rsp_seq_item txn);
    crsp_opcode = txn.opcode;
    chi_crsp_port.sample();
endfunction // collect_chi_crsp_seq_item

function void chi_aiu_coverage::collect_chi_snp_flit(chi_snp_seq_item txn);
    snp_opcode = txn.opcode;
    ns = txn.ns;
    donotgotosd = txn.donotgotosd;
    donotdatapull = txn.donotdatapull;
    if (snp_opcode == SNPSTASHUNQ || snp_opcode == SNPSTASHSHRD ||
        snp_opcode == SNPUNQSTASH || snp_opcode == SNPMKINVSTASH) begin
        num_stashing_snps++;
        if (donotdatapull)
            num_donotdatapull_asserted++;
    end
    // delay btw 2 back to back chi snp reqs
    chi_snp_req_dly = ($time - t_chi_snp_rcvd)/10ns;
    t_chi_snp_rcvd = $time;
    chi_snp_port.sample();
endfunction // collect_chi_snp_flit

function void chi_aiu_coverage::collect_stasting_snoops();
    stsh_snoops_with_donotdatapull = (num_donotdatapull_asserted*100)/num_stashing_snps;
    <% if(obj.AiuInfo[obj.Id].fnNativeInterface != 'CHI-A') { %>
    stashing_snoops.sample();
    <% } %>
endfunction // collect_stasting_snoops

function void chi_aiu_coverage::collect_sys_req_events(sysreq_pkt_t txn);
    sysreq_pkt = txn;
    sys_req_events_cg.sample();
endfunction : collect_sys_req_events

function void chi_aiu_coverage::collect_ott_entry(chi_aiu_scb_txn scb_txn_item);
    time t_cmdReq, t_dtrReq, t_strReq, t_dtwReq, t_snpReq;
    time t_cmdRsp, t_dtrRsp, t_strRsp, t_dtwRsp, t_snpRsp;
    time t_SnpdtrReq, t_SnpdtrRsp, t_SnpdtwReq, t_SnpdtwRsp;
    bit chiaiu_txn_rd, chiaiu_txn_wr, chiaiu_txn_snp;
    // Cycles required for CHI request to compelete
    chi_cmd_req_latency = ($time - scb_txn_item.t_chi_req_rcvd)/10ns;
    chi_snp_req_latency = ($time - scb_txn_item.t_chi_snp_req)/10ns;
    // CHI snp req to rsp delay
    if (scb_txn_item.m_chi_read_data_pkt.size() > 0)
        snp_req_rsp_dly = (scb_txn_item.t_chi_snp_rsp - scb_txn_item.t_chi_snp_req)/10ns;
    // SMI snp_rsp for reqs
    if (scb_txn_item.smi_rcvd[`SNP_REQ_IN]) begin
        snp_req_type = scb_txn_item.m_snp_req_pkt.smi_msg_type;
    end
    if (scb_txn_item.smi_rcvd[`SNP_RSP_OUT]) begin
        snp_rsp_rv     = scb_txn_item.m_snp_rsp_pkt.smi_cmstatus_rv;
        snp_rsp_rs     = scb_txn_item.m_snp_rsp_pkt.smi_cmstatus_rs;
        snp_rsp_dc     = scb_txn_item.m_snp_rsp_pkt.smi_cmstatus_dc;
        snp_rsp_dt_aiu = scb_txn_item.m_snp_rsp_pkt.smi_cmstatus_dt_aiu;
        snp_rsp_dt_dmi = scb_txn_item.m_snp_rsp_pkt.smi_cmstatus_dt_dmi;
    end
    smi_snp_resp.sample();
    // collect timing of smi req and rsp
    if (scb_txn_item.smi_rcvd[`CMD_REQ_OUT]) begin
        t_cmdReq = scb_txn_item.t_smi_cmd_req;
    end
    if (scb_txn_item.smi_rcvd[`CMD_RSP_IN]) begin
        t_cmdRsp = scb_txn_item.t_smi_cmd_rsp;
    end
    if (scb_txn_item.smi_rcvd[`STR_REQ_IN]) begin
        t_strReq = scb_txn_item.t_smi_str_req;
    end
    if (scb_txn_item.smi_rcvd[`STR_RSP_OUT]) begin
        t_strRsp = scb_txn_item.t_smi_str_rsp;
    end
    if (scb_txn_item.smi_rcvd[`DTR_REQ_IN]) begin
        t_dtrReq = scb_txn_item.t_smi_dtr_req;
    end
    if (scb_txn_item.smi_rcvd[`DTR_RSP_OUT]) begin
        t_dtrRsp = scb_txn_item.t_smi_dtr_rsp;
        chiaiu_txn_rd = 1;
    end
    if (scb_txn_item.smi_rcvd[`DTW_REQ_OUT]) begin
        t_dtwReq = scb_txn_item.t_smi_dtw_req;
    end
    if (scb_txn_item.smi_rcvd[`DTW_RSP_IN]) begin
        t_dtwRsp = scb_txn_item.t_smi_dtw_rsp;
        chiaiu_txn_wr = 1;
    end
    if (scb_txn_item.smi_rcvd[`SNP_REQ_IN]) begin
        t_snpReq = scb_txn_item.t_smi_snp_req;
        chiaiu_txn_snp = 1;
    end
    if (scb_txn_item.smi_rcvd[`SNP_RSP_OUT]) begin
        t_snpRsp = scb_txn_item.t_smi_snp_rsp;
    end
    if (scb_txn_item.smi_rcvd[`SNP_DTR_REQ]) begin
        t_SnpdtrReq = scb_txn_item.t_smi_snp_dtr_req;
    end
    if (scb_txn_item.smi_rcvd[`SNP_DTR_RSP]) begin
        t_SnpdtrRsp = scb_txn_item.t_smi_snp_dtr_rsp;
    end
    if (scb_txn_item.smi_rcvd[`SNP_DTW_REQ_OUT]) begin
        t_SnpdtwReq = scb_txn_item.t_smi_snp_dtw_req;
    end
    if (scb_txn_item.smi_rcvd[`SNP_DTW_RSP_IN]) begin
        t_SnpdtwRsp = scb_txn_item.t_smi_snp_dtw_rsp;
    end
    // valid seq in txn state machine
    // read txns
    if (chiaiu_txn_rd) begin
        if (t_cmdRsp < t_strReq && t_strRsp < t_dtrReq)                                                  $cast(smi_msg_seq , {cmdReq_cmdRsp_strReq_strRsp_dtrReq_dtrRsp});
        if (t_cmdRsp < t_strReq && t_strReq < t_dtrReq && t_dtrReq < t_dtrRsp && t_dtrRsp < t_strRsp)    $cast(smi_msg_seq , {cmdReq_cmdRsp_strReq_dtrReq_dtrRsp_strRsp});
        if (t_cmdRsp < t_strReq && t_strReq < t_dtrReq && t_dtrReq < t_strRsp && t_strRsp < t_dtrRsp)    $cast(smi_msg_seq , {cmdReq_cmdRsp_strReq_dtrReq_strRsp_dtrRsp});
        if (t_strReq < t_cmdRsp && t_cmdRsp < t_strRsp && t_strRsp < t_dtrReq)                           $cast(smi_msg_seq , {cmdReq_strReq_cmdRsp_strRsp_dtrReq_dtrRsp});
        if (t_strReq < t_cmdRsp && t_cmdRsp < t_dtrReq && t_dtrReq < t_strRsp && t_strRsp < t_dtrRsp)    $cast(smi_msg_seq , {cmdReq_strReq_cmdRsp_dtrReq_strRsp_dtrRsp});
        if (t_strReq < t_cmdRsp && t_cmdRsp < t_dtrReq && t_dtrReq < t_dtrRsp && t_dtrRsp < t_strRsp)    $cast(smi_msg_seq , {cmdReq_strReq_cmdRsp_dtrReq_dtrRsp_strRsp});
        if (t_strReq < t_dtrReq && t_dtrReq < t_cmdRsp && t_cmdRsp < t_strRsp && t_strRsp < t_dtrRsp)    $cast(smi_msg_seq , {cmdReq_strReq_dtrReq_cmdRsp_strRsp_dtrRsp});
        if (t_strReq < t_dtrReq && t_dtrReq < t_cmdRsp && t_cmdRsp < t_dtrRsp && t_dtrRsp < t_strRsp)    $cast(smi_msg_seq , {cmdReq_strReq_dtrReq_cmdRsp_dtrRsp_strRsp});
        if (t_strReq < t_dtrReq && t_dtrReq < t_strRsp && t_strRsp < t_cmdRsp && t_cmdRsp < t_dtrRsp)    $cast(smi_msg_seq , {cmdReq_strReq_dtrReq_strRsp_cmdRsp_dtrRsp});
        if (t_strReq < t_dtrReq && t_dtrReq < t_strRsp && t_strRsp < t_dtrRsp && t_dtrRsp < t_cmdRsp)    $cast(smi_msg_seq , {cmdReq_strReq_dtrReq_strRsp_dtrRsp_cmdRsp});
        if (t_strReq < t_dtrReq && t_dtrReq < t_dtrRsp && t_dtrRsp < t_cmdRsp && t_cmdRsp < t_strRsp)    $cast(smi_msg_seq , {cmdReq_strReq_dtrReq_dtrRsp_cmdRsp_strRsp});
        if (t_strReq < t_dtrReq && t_dtrReq < t_dtrRsp && t_dtrRsp < t_strRsp && t_strRsp < t_cmdRsp)    $cast(smi_msg_seq , {cmdReq_strReq_dtrReq_dtrRsp_strRsp_cmdRsp});
        if (t_cmdRsp < t_dtrReq && t_dtrRsp < t_strReq)                                                  $cast(smi_msg_seq , {cmdReq_cmdRsp_dtrReq_dtrRsp_strReq_strRsp});
        if (t_cmdRsp < t_dtrReq && t_dtrReq < t_strReq && t_strReq < t_strRsp && t_strRsp < t_dtrRsp)    $cast(smi_msg_seq , {cmdReq_cmdRsp_dtrReq_strReq_strRsp_dtrRsp});
        if (t_cmdRsp < t_dtrReq && t_dtrReq < t_strReq && t_strReq < t_dtrRsp && t_dtrRsp < t_strRsp)    $cast(smi_msg_seq , {cmdReq_cmdRsp_dtrReq_strReq_dtrRsp_strRsp});
        if (t_dtrReq < t_cmdRsp && t_cmdRsp < t_dtrRsp && t_dtrRsp < t_strReq)                           $cast(smi_msg_seq , {cmdReq_dtrReq_cmdRsp_dtrRsp_strReq_strRsp});
        if (t_dtrReq < t_cmdRsp && t_cmdRsp < t_strReq && t_strReq < t_dtrRsp && t_dtrRsp < t_strRsp)    $cast(smi_msg_seq , {cmdReq_dtrReq_cmdRsp_strReq_dtrRsp_strRsp});
        if (t_dtrReq < t_cmdRsp && t_cmdRsp < t_strReq && t_strReq < t_strRsp && t_strRsp < t_dtrRsp)    $cast(smi_msg_seq , {cmdReq_dtrReq_cmdRsp_strReq_strRsp_dtrRsp});
        if (t_dtrReq < t_strReq && t_strReq < t_cmdRsp && t_cmdRsp < t_dtrRsp && t_dtrRsp < t_strRsp)    $cast(smi_msg_seq , {cmdReq_dtrReq_strReq_cmdRsp_dtrRsp_strRsp});
        if (t_dtrReq < t_strReq && t_strReq < t_cmdRsp && t_cmdRsp < t_strRsp && t_strRsp < t_dtrRsp)    $cast(smi_msg_seq , {cmdReq_dtrReq_strReq_cmdRsp_strRsp_dtrRsp});
        if (t_dtrReq < t_strReq && t_strReq < t_dtrRsp && t_dtrRsp < t_cmdRsp && t_cmdRsp < t_strRsp)    $cast(smi_msg_seq , {cmdReq_dtrReq_strReq_dtrRsp_cmdRsp_strRsp});
        if (t_dtrReq < t_strReq && t_strReq < t_dtrRsp && t_dtrRsp < t_strRsp && t_strRsp < t_cmdRsp)    $cast(smi_msg_seq , {cmdReq_dtrReq_strReq_dtrRsp_strRsp_cmdRsp});
        if (t_dtrReq < t_strReq && t_strReq < t_strRsp && t_strRsp < t_cmdRsp && t_cmdRsp < t_dtrRsp)    $cast(smi_msg_seq , {cmdReq_dtrReq_strReq_strRsp_cmdRsp_dtrRsp});
        if (t_dtrReq < t_strReq && t_strReq < t_strRsp && t_strRsp < t_dtrRsp && t_dtrRsp < t_cmdRsp)    $cast(smi_msg_seq , {cmdReq_dtrReq_strReq_strRsp_dtrRsp_cmdRsp});
    end
    // write txns
    if (chiaiu_txn_wr) begin
        if (t_cmdRsp < t_strReq && t_strRsp < t_dtwReq)                                                  $cast(smi_msg_seq , {cmdReq_cmdRsp_strReq_strRsp_dtwReq_dtwRsp});
        if (t_cmdRsp < t_strReq && t_strReq < t_dtwReq && t_dtwReq < t_dtwRsp && t_dtwRsp < t_strRsp)    $cast(smi_msg_seq , {cmdReq_cmdRsp_strReq_dtwReq_dtwRsp_strRsp});
        if (t_cmdRsp < t_strReq && t_strReq < t_dtwReq && t_dtwReq < t_strRsp && t_strRsp < t_dtwRsp)    $cast(smi_msg_seq , {cmdReq_cmdRsp_strReq_dtwReq_strRsp_dtwRsp});
        if (t_strReq < t_cmdRsp && t_cmdRsp < t_strRsp && t_strRsp < t_dtwReq)                           $cast(smi_msg_seq , {cmdReq_strReq_cmdRsp_strRsp_dtwReq_dtwRsp});
        if (t_strReq < t_cmdRsp && t_cmdRsp < t_dtwReq && t_dtwReq < t_strRsp && t_strRsp < t_dtwRsp)    $cast(smi_msg_seq , {cmdReq_strReq_cmdRsp_dtwReq_strRsp_dtwRsp});
        if (t_strReq < t_cmdRsp && t_cmdRsp < t_dtwReq && t_dtwReq < t_dtwRsp && t_dtwRsp < t_strRsp)    $cast(smi_msg_seq , {cmdReq_strReq_cmdRsp_dtwReq_dtwRsp_strRsp});
        if (t_strReq < t_dtwReq && t_dtwReq < t_cmdRsp && t_cmdRsp < t_strRsp && t_strRsp < t_dtwRsp)    $cast(smi_msg_seq , {cmdReq_strReq_dtwReq_cmdRsp_strRsp_dtwRsp});
        if (t_strReq < t_dtwReq && t_dtwReq < t_cmdRsp && t_cmdRsp < t_dtwRsp && t_dtwRsp < t_strRsp)    $cast(smi_msg_seq , {cmdReq_strReq_dtwReq_cmdRsp_dtwRsp_strRsp});
        if (t_strReq < t_dtwReq && t_dtwReq < t_strRsp && t_strRsp < t_cmdRsp && t_cmdRsp < t_dtwRsp)    $cast(smi_msg_seq , {cmdReq_strReq_dtwReq_strRsp_cmdRsp_dtwRsp});
        if (t_strReq < t_dtwReq && t_dtwReq < t_strRsp && t_strRsp < t_dtwRsp && t_dtwRsp < t_cmdRsp)    $cast(smi_msg_seq , {cmdReq_strReq_dtwReq_strRsp_dtwRsp_cmdRsp});
        if (t_strReq < t_dtwReq && t_dtwReq < t_dtwRsp && t_dtwRsp < t_cmdRsp && t_cmdRsp < t_strRsp)    $cast(smi_msg_seq , {cmdReq_strReq_dtwReq_dtwRsp_cmdRsp_strRsp});
        if (t_strReq < t_dtwReq && t_dtwReq < t_dtwRsp && t_dtwRsp < t_strRsp && t_strRsp < t_cmdRsp)    $cast(smi_msg_seq , {cmdReq_strReq_dtwReq_dtwRsp_strRsp_cmdRsp});
    end
    // Snoop txns
    if (chiaiu_txn_snp) begin
       if (t_SnpdtwReq < t_SnpdtrReq && t_SnpdtwRsp < t_SnpdtrRsp && t_SnpdtrRsp < t_snpRsp   ) $cast(smi_msg_seq , {snpReq_dtwReq_dtrReq_dtwrsp_dtrrsp_snprsp}); 
       if (t_SnpdtwReq < t_SnpdtrReq && t_SnpdtwRsp < t_snpRsp    && t_snpRsp    < t_SnpdtrRsp) $cast(smi_msg_seq , {snpReq_dtwReq_dtrReq_dtwrsp_snprsp_dtrrsp});
       if (t_SnpdtwReq < t_SnpdtrReq && t_SnpdtrRsp < t_SnpdtwRsp && t_SnpdtwRsp < t_snpRsp   ) $cast(smi_msg_seq , {snpReq_dtwReq_dtrReq_dtrrsp_dtwrsp_snprsp});
       if (t_SnpdtwReq < t_SnpdtrReq && t_SnpdtrRsp < t_snpRsp    && t_snpRsp    < t_SnpdtwRsp) $cast(smi_msg_seq , {snpReq_dtwReq_dtrReq_dtrrsp_snprsp_dtwrsp});
       if (t_SnpdtwReq < t_SnpdtrReq && t_snpRsp    < t_SnpdtrRsp && t_SnpdtrRsp < t_SnpdtwRsp) $cast(smi_msg_seq , {snpReq_dtwReq_dtrReq_snprsp_dtrrsp_dtwrsp});
       if (t_SnpdtwReq < t_SnpdtrReq && t_snpRsp    < t_SnpdtwRsp && t_SnpdtwRsp < t_SnpdtrRsp) $cast(smi_msg_seq , {snpReq_dtwReq_dtrReq_snprsp_dtwrsp_dtrrsp});
       if (t_SnpdtrReq < t_SnpdtwReq && t_SnpdtwRsp < t_SnpdtrRsp && t_SnpdtrRsp < t_snpRsp   ) $cast(smi_msg_seq , {snpReq_dtrReq_dtwReq_dtwrsp_dtrrsp_snprsp});
       if (t_SnpdtrReq < t_SnpdtwReq && t_SnpdtwRsp < t_snpRsp    && t_snpRsp    < t_SnpdtrRsp) $cast(smi_msg_seq , {snpReq_dtrReq_dtwReq_dtwrsp_snprsp_dtrrsp});
       if (t_SnpdtrReq < t_SnpdtwReq && t_SnpdtrRsp < t_SnpdtwRsp && t_SnpdtwRsp < t_snpRsp   ) $cast(smi_msg_seq , {snpReq_dtrReq_dtwReq_dtrrsp_dtwrsp_snprsp});
       if (t_SnpdtrReq < t_SnpdtwReq && t_SnpdtrRsp < t_snpRsp    && t_snpRsp    < t_SnpdtwRsp) $cast(smi_msg_seq , {snpReq_dtrReq_dtwReq_dtrrsp_snprsp_dtwrsp});
       if (t_SnpdtrReq < t_SnpdtwReq && t_snpRsp    < t_SnpdtrRsp && t_SnpdtrRsp < t_SnpdtwRsp) $cast(smi_msg_seq , {snpReq_dtrReq_dtwReq_snprsp_dtrrsp_dtwrsp});
       if (t_SnpdtrReq < t_SnpdtwReq && t_snpRsp    < t_SnpdtwRsp && t_SnpdtwRsp < t_SnpdtrRsp) $cast(smi_msg_seq , {snpReq_dtrReq_dtwReq_snprsp_dtwrsp_dtrrsp});
       if (t_SnpdtwReq < t_SnpdtwRsp && t_SnpdtwRsp < t_snpRsp   )    $cast(smi_msg_seq , {snpReq_dtwReq_dtwrsp_snprsp});
       if (t_SnpdtwReq < t_snpRsp    && t_snpRsp    < t_SnpdtwRsp)    $cast(smi_msg_seq , {snpReq_dtwReq_snprsp_dtwrsp});
       if (t_SnpdtrReq < t_SnpdtrRsp && t_SnpdtrRsp < t_snpRsp   )    $cast(smi_msg_seq , {snpReq_dtrReq_dtrrsp_snprsp});
       if (t_SnpdtrReq < t_snpRsp    && t_snpRsp    < t_SnpdtrRsp)    $cast(smi_msg_seq , {snpReq_dtrReq_snprsp_dtrrsp});
    end
    concerto_messages.sample();

    // Cross between Req type and COMPDATA resp
    if (scb_txn_item.chi_rcvd[`CHI_REQ])
        req_opcode = scb_txn_item.m_chi_req_pkt.opcode;
    if (scb_txn_item.chi_rcvd[`WRITE_DATA_IN]) begin
        compdata_resp = scb_txn_item.m_chi_write_data_pkt[$].resp;
        foreach(scb_txn_item.m_chi_write_data_pkt[i]) begin
            if (scb_txn_item.m_chi_write_data_pkt[i].opcode == COMPDATA)
                req_cross_resp.sample();
        end
    end
    if (scb_txn_item.chi_rcvd[`READ_DATA_IN]) begin
        compdata_resp = scb_txn_item.m_chi_read_data_pkt[$].resp;
        foreach(scb_txn_item.m_chi_read_data_pkt[i]) begin
            if (scb_txn_item.m_chi_read_data_pkt[i].opcode == COMPDATA)
                req_cross_resp.sample();
        end
    end
    // Cross between Req type and COMP resp
    if (scb_txn_item.m_chi_crsp_pkt !== null) begin
        if (scb_txn_item.m_chi_crsp_pkt.opcode == COMP)
            comp_resp = scb_txn_item.m_chi_crsp_pkt.resp;
    end
    if (scb_txn_item.m_chi_srsp_pkt !== null) begin
        if (scb_txn_item.m_chi_srsp_pkt.opcode == COMP)
            comp_resp = scb_txn_item.m_chi_srsp_pkt.resp;
    end
    // Cross between SNPRESP/SNPRESPDATA resp (srsp & rdata) and snp req and snp resp opcode
    if (scb_txn_item.chi_rcvd[`CHI_SNP_REQ])
        snp_opcode = scb_txn_item.m_chi_snp_addr_pkt.opcode;
    if (scb_txn_item.m_chi_srsp_pkt !== null) begin
        srsp_opcode = scb_txn_item.m_chi_srsp_pkt.opcode;
        if (scb_txn_item.m_chi_srsp_pkt.opcode == SNPRESP)
            snp_resp = scb_txn_item.m_chi_srsp_pkt.resp;
    end
    else if (scb_txn_item.m_chi_read_data_pkt.size() !== 0) begin
        foreach(scb_txn_item.m_chi_read_data_pkt[i]) begin
            rdata_opcode = scb_txn_item.m_chi_read_data_pkt[i].opcode;
            if (scb_txn_item.m_chi_read_data_pkt[i].opcode == SNPRESPDATA ||
                scb_txn_item.m_chi_read_data_pkt[i].opcode == SNPRESPDATAPTL)
                snp_resp = scb_txn_item.m_chi_read_data_pkt[i].resp;
            req_cross_resp.sample();
        end
    end
    req_cross_resp.sample();

    <% if(obj.AiuInfo[obj.Id].fnNativeInterface != 'CHI-A') { %>
    // sysco coverage variables
    smi_sysco_state = scb_txn_item.smi_sysco_state;
    chi_sysco_state = scb_txn_item.chi_sysco_state;
    smi_dvm_part2_sysco_state = scb_txn_item.smi_dvm_part2_sysco_state;
    chi_dvm_part2_sysco_state = scb_txn_item.chi_dvm_part2_sysco_state;
    isSnoop = scb_txn_item.isSnoop;
    isDVMSnoop = scb_txn_item.isDVMSnoop;
    is_sysco_snp_returned = scb_txn_item.is_sysco_snp_returned;

    if(isSnoop)
      chi_smi_sysco_states.sample();
    <% } %>
endfunction // collect_ott_entry

function chi_aiu_coverage::new();
    chi_wdata_port = new();
    chi_rdata_port = new();
    chi_req_port = new();
    chi_crsp_port = new();
    chi_srsp_port = new();
    chi_snp_port = new();
    req_cross_resp = new();
    concerto_messages = new();
    smi_snp_resp = new();
    sys_req_events_cg = new();

    <% if(obj.AiuInfo[obj.Id].fnNativeInterface != 'CHI-A') { %>
    stashing_snoops = new();
    chi_smi_sysco_states = new();
    <% } %>
endfunction // new
