////////////////////////////////////////
// naming convention used is channel
// name followed by the signal name
////////////////////////////////////////

//======================================
// FLAG Parameters
// Due to configurability support need 
// to indicate if paramaters are valid
//======================================
parameter bit WDATACHECK_VALID           = 1'b1;
parameter bit WPOSION_VALID              = 1'b1;
parameter bit WREQRSVDC_VALID            = 1'b1;
parameter bit WDATRSVDC_VALID            = 1'b1;

//======================================
//      CHI Common Types
//======================================

typedef bit [ WQOS-1          : 0 ] chi_qos_t;
typedef bit [ WTGID-1         : 0 ] chi_tgtid_t;
typedef bit [ WSRCID-1        : 0 ] chi_srcid_t;
typedef bit [ WTXNID-1        : 0 ] chi_txnid_t;
typedef bit                         chi_tracetag_t;
typedef bit [ WLPID-1         : 0 ] chi_lpid_t;
typedef bit                         chi_lpidvalid_t;
typedef bit                         chi_ns_t;
typedef bit [ WADDR-1         : 0 ] chi_addr_t;

//======================================
//      CHI Request Types
//======================================

typedef bit [ WREQOPCODE-1    : 0 ]    chi_req_opcode_t;
typedef bit [ WSIZE-1         : 0 ]    chi_req_size_t;
typedef bit                            chi_req_likelyshared_t;
typedef bit                            chi_req_allowretry_t;
typedef bit [ WORDER-1        : 0 ]    chi_req_order_t;
typedef bit [ WPCRDTYPE-1     : 0 ]    chi_req_pcrdtype_t;
typedef bit [ WMEMATTR-1      : 0 ]    chi_req_memattr_t;
typedef bit [ WSNPATTR-1      : 0 ]    chi_req_snpattr_t;
typedef bit                            chi_req_excl_t;
typedef bit                            chi_req_expcompack_t;
typedef bit [TAGOP-1          :0 ]     chi_req_tagop_t;
typedef bit [ WREQRSVDC-1   : 0 ]      chi_req_rsvdc_t;
typedef bit [ WRETURNNID -1   : 0 ]    chi_req_returnnid_t;     
typedef bit [ WRETURNTXNIND - 1  : 0 ] chi_req_returntxnid_t;
typedef bit [ WSTASHNID - 1      : 0 ] chi_req_stashnid_t;      
typedef bit                            chi_req_stashnidvalid_t;
typedef bit                            chi_req_endian_t;
typedef bit                            chi_req_snoopme_t;
typedef bit [ WSLCREPHINT - 1 : 0 ]    chi_req_slcrephint_t;
typedef bit                            chi_req_deep_t;
typedef bit                            chi_req_dodwt_t;
typedef bit [ WPGROUPID - 1 : 0 ]      chi_req_pgroupid_t;
typedef bit [ WSTASHGROUPID - 1 : 0 ]  chi_req_stashgroupid_t;
typedef bit [ WTAGGROUPID - 1 : 0 ]    chi_req_taggroupid_t;
typedef bit [ WMPAM - 1 : 0 ]          chi_req_mpam_t;


//======================================
//      CHI Snoop Request Types
//======================================

typedef bit [ WSNPOPCODE-1        : 0 ] chi_snp_opcode_t;
typedef bit [ WFWDNID - 1         : 0 ] chi_snp_fwdnid_t;     
typedef bit [ WFWDTXNID - 1       : 0 ] chi_snp_fwdtxnid_t;      
typedef bit [ WVMIDEXT -1         : 0 ] chi_snp_vmidext_t;
typedef bit                             chi_snp_donotgotosd_t;
typedef bit                             chi_snp_donotdatapull_t;
typedef bit                             chi_snp_rettosrc_t;
typedef bit [ WSNPADDR-1         : 0 ]     chi_snpaddr_t;

//======================================
//      CHI Data Request Types
//======================================

typedef bit [ WHOMENID -1     : 0]  chi_dat_homenid_t;
typedef bit [ WDATAOPCODE-1   : 0 ] chi_dat_opcode_t;
typedef bit [ WRESPERR-1      : 0 ] chi_dat_resperr_t;
typedef bit [ WRESP-1         : 0 ] chi_dat_resp_t;
typedef bit [ WFWDSTATE - 1   : 0 ] chi_dat_fwdstate_t;
typedef bit [ WCBUSY-1        : 0 ] chi_dat_cbusy_t;
typedef bit [ WDATAPULL - 1   : 0 ] chi_dat_datapull_t;
typedef bit [ WDATASOURCE - 1 : 0 ] chi_dat_datasource_t;
typedef bit [ WDBID-1         : 0 ] chi_dat_dbid_t;
typedef bit [ WCCID-1         : 0 ] chi_dat_ccid_t;
typedef bit [ WDATAID-1       : 0 ] chi_dat_dataid_t;
typedef bit [ WDATATAGOP-1    : 0 ] chi_dat_tagop_t;
typedef bit [ WTAG-1          : 0 ] chi_dat_tag_t;
typedef bit [ WTU-1           : 0 ] chi_dat_tu_t;
typedef bit [ WBE-1           : 0 ] chi_dat_be_t;
typedef bit [ WDATA-1         : 0 ] chi_dat_data_t;
typedef bit [ WDATACHECK - 1  : 0 ] chi_dat_datacheck_t;
typedef bit [ WPOSION - 1     : 0 ] chi_dat_poison_t;
typedef bit [ WDATRSVDC - 1 : 0 ]   chi_dat_rsvdc_t;


//======================================
//      CHI Response Types
//======================================

typedef bit [ WRSPOPCODE-1 : 0 ] chi_rsp_opcode_t;
typedef bit [ WRESPERR-1   : 0 ] chi_rsp_resperr_t;
typedef bit [ WRESP-1      : 0 ] chi_rsp_resp_t;
typedef bit [ WCBUSY-1     : 0 ] chi_rsp_cbusy_t;
typedef bit [ WDBID-1      : 0 ] chi_rsp_dbid_t;
typedef bit [ WPCRDTYPE-1  : 0 ] chi_rsp_pcrdtype_t;


//======================================
//      CHI Enum Types
//======================================

typedef enum chi_req_opcode_t {
    REQLCRDRETURN        = 'h00,
    READSHARED           = 'h01,
    READCLEAN            = 'h02,
    READONCE             = 'h03,
    READNOSNP            = 'h04,
    PCRDRETURN           = 'h05,
    READUNIQUE           = 'h07,
    CLEANSHARED          = 'h08,
    CLEANINVALID         = 'h09,
    MAKEINVALID          = 'h0A,
    CLEANUNIQUE          = 'h0B,
    MAKEUNIQUE           = 'h0C,
    EVICT                = 'h0D,
    EOBARRIER            = 'h0E,  //Valid only for CHI-A
    ECBARRIER            = 'h0F,  //Valid only for CHI-A
    DVMOP                = 'h14, 
    WRITEEVICTFULL       = 'h15,
    WRITECLEANPTL        = 'h16,  //Valid only for CHI-A
    WRITECLEANFULL       = 'h17,
    WRITEUNIQUEPTL       = 'h18,
    WRITEUNIQUEFULL      = 'h19,
    WRITEBACKPTL         = 'h1A,
    WRITEBACKFULL        = 'h1B,
    WRITENOSNPPTL        = 'h1C,
    WRITENOSNPFULL       = 'h1D,
<% if(obj.AiuInfo[obj.Id].fnNativeInterface != 'CHI-A') { %>
    WRITEUNIQUEFULLSTASH = 'h20,
    WRITEUNIQUEPTLSTASH  = 'h21,
    STASHONCESHARED      = 'h22,
    STASHONCEUNIQUE      = 'h23,
    READONCECLEANINVALID = 'h24,
    READONCEMAKEINVALID  = 'h25,
    READNOTSHAREDDIRTY   = 'h26,
    CLEANSHAREDPERSIST   = 'h27,
    ATOMICSTORE_STADD    = 'h28,
    ATOMICSTORE_STCLR    = 'h29,
    ATOMICSTORE_STEOR    = 'h2A,
    ATOMICSTORE_STSET    = 'h2B,
    ATOMICSTORE_STSMAX   = 'h2C,
    ATOMICSTORE_STMIN    = 'h2D,
    ATOMICSTORE_STUSMAX  = 'h2E,
    ATOMICSTORE_STUMIN   = 'h2F,
    ATOMICLOAD_LDADD     = 'h30,
    ATOMICLOAD_LDCLR     = 'h31,
    ATOMICLOAD_LDEOR     = 'h32,
    ATOMICLOAD_LDSET     = 'h33,
    ATOMICLOAD_LDSMAX    = 'h34,
    ATOMICLOAD_LDMIN     = 'h35,
    ATOMICLOAD_LDUSMAX   = 'h36,
    ATOMICLOAD_LDUMIN    = 'h37,
    ATOMICSWAP           = 'h38,
    ATOMICCOMPARE        = 'h39,
    PREFETCHTARGET       = 'h3A,
    <% if(obj.AiuInfo[obj.Id].fnNativeInterface == 'CHI-E') { %>
        CLEANSHAREDPERSISTSEP                   = 'h13,
        MAKEREADUNIQUE                         = 'h41,
        WRITEUNIQUEZERO                         = 'h43,
        WRITENOSNPZERO                          = 'h44,
        READPREFERUNIQUE                        = 'h4C,
        WRITENOSNPFULL_CLEANSHARED              = 'h50, 
        WRITENOSNPFULL_CLEANINVALID             = 'h51, 
        WRITENOSNPFULL_CLEANSHAREDPERSISTSEP    = 'h52,
        WRITEBACKFULL_CLEANSHARED               = 'h58,
        WRITEBACKFULL_CLEANINVALID              = 'h59,
        WRITEBACKFULL_CLEANSHAREDPERSISTSEP     = 'h5A,
        WRITECLEANFULL_CLEANSHARED              = 'h5C,
        WRITECLEANFULL_CLEANSHAREDPERSISTSEP    = 'h5E,
        WRITEUNIQUEFULL_CLEANSHARED             = 'h54,
        WRITEUNIQUEPTL_CLEANSHARED              = 'h64,
        WRITENOSNPPTL_CLEANSHARED               = 'h60,
        WRITENOSNPPTL_CLEANINV                  = 'h61,
        WRITEUNQFULL_CLEANSHAREDPERSISTSEP      = 'h56,
        WRITEUNQPTL_CLEANSHAREDPERSISTSEP       = 'h66,
        WRITENOSNPPTL_CLEANSHAREDPERSISTSEP     = 'h62,
        STASHONCESEPUNIQUE                      = 'h48,
        STASHONCESEPSHARED                      = 'h47,
    <%}%>
    UNSUP_OPCODE_0       = 'h06,
    UNSUP_OPCODE_1       = 'h10,
    UNSUP_OPCODE_2       = 'h11,
    UNSUP_OPCODE_3       = 'h12,
    <% if(obj.AiuInfo[obj.Id].fnNativeInterface != 'CHI-E') { %>
        UNSUP_OPCODE_4       = 'h13,
    <%}%>
    <% if(obj.AiuInfo[obj.Id].fnNativeInterface == 'CHI-E') { %>
        WRITEEVICTOREVICT       = 'h42,
    <%}%>
    UNSUP_OPCODE_6       = 'h1E,
    UNSUP_OPCODE_7       = 'h1F,
    UNSUP_OPCODE_8       = 'h3B,
    UNSUP_OPCODE_9       = 'h3C,
    UNSUP_OPCODE_10      = 'h3D,
    UNSUP_OPCODE_11      = 'h3E,
    UNSUP_OPCODE_12      = 'h3F
<% } else { %>
    UNSUP_OPCODE_0       = 'h06,
    UNSUP_OPCODE_1       = 'h10,
    UNSUP_OPCODE_2       = 'h11,
    UNSUP_OPCODE_3       = 'h12,
    UNSUP_OPCODE_4       = 'h13,
    UNSUP_OPCODE_5       = 'h1E,
    UNSUP_OPCODE_6       = 'h1F
<% } %>

} chi_req_opcode_enum_t;

<% if (obj.testBench != "emu_t" ) { %>
const chi_req_opcode_enum_t write_ops[] = {WRITEEVICTFULL,WRITECLEANPTL,WRITECLEANFULL,WRITEUNIQUEPTL,WRITEUNIQUEFULL,WRITEBACKPTL,WRITEBACKFULL,WRITENOSNPPTL,WRITENOSNPFULL
 <%if(obj.AiuInfo[obj.Id].fnNativeInterface == 'CHI-E') {%>
        , WRITENOSNPFULL_CLEANSHARED 
        , WRITENOSNPFULL_CLEANINVALID 
        , WRITENOSNPFULL_CLEANSHAREDPERSISTSEP
        , WRITENOSNPZERO
        , WRITEUNIQUEZERO
        , WRITEBACKFULL_CLEANSHARED           
        , WRITEBACKFULL_CLEANINVALID          
        , WRITEBACKFULL_CLEANSHAREDPERSISTSEP 
        , WRITECLEANFULL_CLEANSHARED          
        , WRITECLEANFULL_CLEANSHAREDPERSISTSEP
        , WRITEEVICTOREVICT
    <%}%>
};
<% if(obj.AiuInfo[obj.Id].fnNativeInterface != 'CHI-A') { %>
const chi_req_opcode_enum_t unsupported_ops[] = {UNSUP_OPCODE_0,UNSUP_OPCODE_1,UNSUP_OPCODE_2,UNSUP_OPCODE_3,
<%if(obj.AiuInfo[obj.Id].fnNativeInterface != "CHI-E"){%>
UNSUP_OPCODE_4,
<%}%>
UNSUP_OPCODE_6,UNSUP_OPCODE_7,UNSUP_OPCODE_8,UNSUP_OPCODE_9,UNSUP_OPCODE_10,UNSUP_OPCODE_11,UNSUP_OPCODE_12,EOBARRIER,ECBARRIER};
const chi_req_opcode_enum_t read_ops[] = {
    READSHARED,
    READCLEAN,
    READONCE,
    READNOSNP,
    READUNIQUE,
    READONCECLEANINVALID,
    READONCEMAKEINVALID,
    READNOTSHAREDDIRTY
    <%if(obj.AiuInfo[obj.Id].fnNativeInterface == 'CHI-E') {%>
        ,MAKEREADUNIQUE
        ,READPREFERUNIQUE
    <%}%>
    };
const chi_req_opcode_enum_t dataless_ops[] = { CLEANUNIQUE, MAKEUNIQUE, EVICT, CLEANSHARED, CLEANSHAREDPERSIST,
        <%if(obj.AiuInfo[obj.Id].fnNativeInterface == 'CHI-E') {%>
        WRITEEVICTOREVICT,
        CLEANSHAREDPERSISTSEP,
        <%}%>
        CLEANINVALID, MAKEINVALID
    };

const chi_req_opcode_enum_t cmo_only_ops[] = { CLEANSHARED, CLEANSHAREDPERSIST,
        <%if(obj.AiuInfo[obj.Id].fnNativeInterface == 'CHI-E') {%>
        CLEANSHAREDPERSISTSEP,
        <%}%>
        CLEANINVALID, MAKEINVALID
    };

const chi_req_opcode_enum_t write_bk[] =        {WRITEEVICTFULL,WRITECLEANPTL,WRITECLEANFULL,WRITEBACKPTL,WRITEBACKFULL};
const chi_req_opcode_enum_t atomic_dtls_ops[] = {ATOMICSTORE_STADD, ATOMICSTORE_STCLR, ATOMICSTORE_STEOR, ATOMICSTORE_STSET, ATOMICSTORE_STSMAX, ATOMICSTORE_STMIN, ATOMICSTORE_STUSMAX, ATOMICSTORE_STUMIN};
const chi_req_opcode_enum_t atomic_dat_ops[] = { ATOMICLOAD_LDADD, ATOMICLOAD_LDCLR, ATOMICLOAD_LDEOR, ATOMICLOAD_LDSET, ATOMICLOAD_LDSMAX, ATOMICLOAD_LDMIN, ATOMICLOAD_LDUSMAX, ATOMICLOAD_LDUMIN, ATOMICSWAP, ATOMICCOMPARE};
const chi_req_opcode_enum_t stash_ops[] = {WRITEUNIQUEPTLSTASH, WRITEUNIQUEFULLSTASH, STASHONCESHARED, STASHONCEUNIQUE};
const chi_req_opcode_enum_t datalessStash_ops[] = {STASHONCESHARED, STASHONCEUNIQUE <% if(obj.AiuInfo[obj.Id].fnNativeInterface == 'CHI-E') { %>,STASHONCESEPSHARED,STASHONCESEPUNIQUE<%}%>};
const chi_req_opcode_enum_t prefetch_op[] = {PREFETCHTARGET};
<%if(obj.AiuInfo[obj.Id].fnNativeInterface == 'CHI-E') {%>
const chi_req_opcode_enum_t combined_wr_nc_ops[] = { WRITENOSNPFULL_CLEANSHARED, WRITENOSNPFULL_CLEANINVALID, WRITENOSNPFULL_CLEANSHAREDPERSISTSEP };
const chi_req_opcode_enum_t combined_wr_c_ops[] = { WRITEBACKFULL_CLEANSHARED, WRITEBACKFULL_CLEANINVALID, WRITEBACKFULL_CLEANSHAREDPERSISTSEP, WRITECLEANFULL_CLEANSHARED, WRITECLEANFULL_CLEANSHAREDPERSISTSEP };
const chi_req_opcode_enum_t combined_wr_unsupp_ops[] = { WRITEUNIQUEFULL_CLEANSHARED, WRITEUNIQUEPTL_CLEANSHARED, WRITENOSNPPTL_CLEANSHARED, WRITENOSNPPTL_CLEANINV, WRITEUNQFULL_CLEANSHAREDPERSISTSEP, WRITEUNQPTL_CLEANSHAREDPERSISTSEP, WRITENOSNPPTL_CLEANSHAREDPERSISTSEP };
const chi_req_opcode_enum_t wr_zero_ops[] = { WRITEUNIQUEZERO, WRITENOSNPZERO };
<% } else { //CHI-E %>
const chi_req_opcode_enum_t combined_wr_nc_ops[] = { };
const chi_req_opcode_enum_t combined_wr_c_ops[] = { };
const chi_req_opcode_enum_t combined_wr_unsupp_ops[] = { };
const chi_req_opcode_enum_t wr_zero_ops[] = { };
<% } %>
<% } else { %>
const chi_req_opcode_enum_t unsupported_ops[] = {UNSUP_OPCODE_0,UNSUP_OPCODE_1,UNSUP_OPCODE_2,UNSUP_OPCODE_3,UNSUP_OPCODE_4,UNSUP_OPCODE_5,UNSUP_OPCODE_6};
const chi_req_opcode_enum_t read_ops[] = {READSHARED,READCLEAN,READONCE,READNOSNP,READUNIQUE};
const chi_req_opcode_enum_t dataless_ops[] = { CLEANUNIQUE, MAKEUNIQUE, EVICT, CLEANSHARED, CLEANINVALID, MAKEINVALID };
const chi_req_opcode_enum_t atomic_dtls_ops[] = { };
const chi_req_opcode_enum_t atomic_dat_ops[] = { };
const chi_req_opcode_enum_t stash_ops[] = { };
const chi_req_opcode_enum_t prefetch_op[] = { };
const chi_req_opcode_enum_t combined_wr_nc_ops[] = { };
const chi_req_opcode_enum_t combined_wr_c_ops[] = { };
const chi_req_opcode_enum_t combined_wr_unsupp_ops[] = { };
const chi_req_opcode_enum_t wr_zero_ops[] = { };
<% } %>
<% } %> 

typedef enum chi_dat_opcode_t {
    DATALCRDRETURN    = 'h0,
    SNPRESPDATA       = 'h1,
    COPYBACKWRDATA    = 'h2,
    NONCOPYBACKWRDATA = 'h3,
    COMPDATA          = 'h4,
    SNPRESPDATAPTL    = 'h5,
    SNPRESPDATAFWDED  = 'h6,
    WRDATACANCEL      = 'h7
    <% if(obj.AiuInfo[obj.Id].fnNativeInterface == 'CHI-E') { %>
        ,DATASEPRESP = 'hB
        ,NCBWRDATACOMPACK = 'hC
    <%}%>
} chi_dat_opcode_enum_t;


typedef enum chi_rsp_opcode_t {
    RESPLCRDRETURN = 'h0,
    SNPRESP        = 'h1,
    COMPACK        = 'h2,
    RETRYACK       = 'h3,
    COMP           = 'h4,
    COMPDBIDRESP   = 'h5,
    DBIDRESP       = 'h6,
    PCRDGRANT      = 'h7,
    READRECEIPT    = 'h8,
    COMPPERSIST    = 'hD
    <% if(obj.AiuInfo[obj.Id].fnNativeInterface == 'CHI-E') { %>
    , COMPCMO      = 'h14
    <%}%>
} chi_rsp_opcode_enum_t;


typedef enum chi_snp_opcode_t {
    SNPLCRDRETURN   = 'h0,
    SNPSHARED       = 'h1,
    SNPCLEAN        = 'h2,
    SNPONCE         = 'h3,
    SNPNSHDTY       = 'h4,
    SNPUNQSTASH     = 'h5,
    SNPMKINVSTASH   = 'h6,
    SNPUNIQUE       = 'h7,
    SNPCLEANSHARED  = 'h8,
    SNPCLEANINVALID = 'h9,
    SNPMAKEINVALID  = 'hA,
    SNPSTASHUNQ     = 'hB,
    SNPSTASHSHRD    = 'hC,
<% if(obj.AiuInfo[obj.Id].fnNativeInterface != 'CHI-A') { %>
    SNPDVMOP        = 'hD,
    SNPSHRFWD       = 'h11,
    SNPCLNFWD       = 'h12,
    SNPONCEFWD      = 'h13,
    SNPNOTSDFWD     = 'h14,
    SNPUNQFWD       = 'h17
<% } else { %>
    SNPDVMOP        = 'hD
<% } %>
} chi_snp_opcode_enum_t;
<% if (obj.testBench != "emu_t" ) { %>    
const chi_snp_opcode_enum_t stash_snps[] = {SNPUNQSTASH, SNPMKINVSTASH, SNPSTASHUNQ, SNPSTASHSHRD};  <% } %>

typedef enum int {
    CHI_A, CHI_B
} chi_revision_t;

typedef enum int {
  NONE, RN_F, RN_D, RN_I, HN_F, HN_I, MN, SN_F, SN_I
} chi_node_t;

typedef enum bit[1:0] {
    CHI_REQ, CHI_RSP, CHI_DAT, CHI_SNP
} chi_channel_t;

typedef enum bit {
    CHI_ACTIVE, CHI_REACTIVE
} chi_channel_func_t;

typedef enum int {
  AGENT_PASSIVE,  AGENT_ACTIVE
} chi_uvm_agent_cfg_t;

typedef enum int {
  FLTPENDV_HIGH, FLTPENDV_RAND, FLTPENDV_ILGL
} flit_pend_mode_t;

typedef enum int {
  BURST_MODE, NORM_MODE, STRV_MODE
} rxcrd_drv_mode_t;

typedef struct {
  int dlyc;
  logic [MAX_FW-1:0] data;
} chi_flit_t;

typedef enum int {
  STOP, ACTIVE, RUN, INACTIVE
} chi_link_state_t;

<% if (obj.testBench != "emu_t" ) { %>
//Data types used at multiple places
typedef bit[MAX_FW-1:0] packed_flit_t[$]; <% } %>

typedef enum int {
  POWUP_TX_LN, WAIT4RX_LN2POWUP, POWDN_TX_LN
} chi_txactv_st_t;

typedef enum int {
  DISABLED, CONNECT, ENABLED, DISCONNECT
} chi_sysco_state_t;

typedef bit chi_sysco_t;

`define CHI_REQ_QOS_LSB     0
`define CHI_REQ_QOS_MSB     WQOS-1
`define CHI_REQ_TGTID_LSB   `CHI_REQ_QOS_MSB+1
`define CHI_REQ_TGTID_MSB   `CHI_REQ_TGTID_LSB+WTGID-1
`define CHI_REQ_SRCID_LSB   `CHI_REQ_TGTID_MSB+1
`define CHI_REQ_SRCID_MSB   `CHI_REQ_SRCID_LSB+WSRCID-1
`define CHI_REQ_TXNID_LSB   `CHI_REQ_SRCID_MSB+1
`define CHI_REQ_TXNID_MSB   `CHI_REQ_TXNID_LSB+WTXNID-1
<% if(obj.AiuInfo[obj.Id].fnNativeInterface != 'CHI-A') { %>
`define CHI_REQ_RTRN_NID_LSB    `CHI_REQ_TXNID_MSB+1
`define CHI_REQ_RTRN_NID_MSB    `CHI_REQ_RTRN_NID_LSB+WRETURNNID-1
`define CHI_REQ_ENDIAN_LSB      `CHI_REQ_RTRN_NID_MSB+1
`define CHI_REQ_ENDIAN_MSB      `CHI_REQ_ENDIAN_LSB
`define CHI_REQ_RTRN_TXNID_LSB  `CHI_REQ_ENDIAN_MSB+1
`define CHI_REQ_RTRN_TXNID_MSB  `CHI_REQ_RTRN_TXNID_LSB+WRETURNTXNIND-1
`define CHI_REQ_STSH_LPID_LSB  `CHI_REQ_RTRN_NID_MSB+1
`define CHI_REQ_STSH_LPID_MSB  `CHI_REQ_STSH_LPID_LSB+WLPID-1
`define CHI_REQ_STSH_LPIDV_LSB  `CHI_REQ_STSH_LPID_MSB+1
`define CHI_REQ_STSH_LPIDV_MSB  `CHI_REQ_STSH_LPIDV_LSB
`define CHI_REQ_OPCODE_LSB      `CHI_REQ_RTRN_TXNID_MSB+1
<% } else { %>
`define CHI_REQ_OPCODE_LSB      `CHI_REQ_TXNID_MSB+1
<% } %>
`define CHI_REQ_OPCODE_MSB      `CHI_REQ_OPCODE_LSB+WREQOPCODE-1
`define CHI_REQ_SIZE_LSB        `CHI_REQ_OPCODE_MSB+1
`define CHI_REQ_SIZE_MSB        `CHI_REQ_SIZE_LSB+WSIZE-1
`define CHI_REQ_ADDR_LSB        `CHI_REQ_SIZE_MSB+1
`define CHI_REQ_ADDR_MSB        `CHI_REQ_ADDR_LSB+WADDR-1
`define CHI_REQ_NS_LSB          `CHI_REQ_ADDR_MSB+1
`define CHI_REQ_NS_MSB          `CHI_REQ_NS_LSB
`define CHI_REQ_LIKELYSHARED_LSB    `CHI_REQ_NS_MSB+1
`define CHI_REQ_LIKELYSHARED_MSB    `CHI_REQ_LIKELYSHARED_LSB
`define CHI_REQ_ALLOWRETRY_LSB      `CHI_REQ_LIKELYSHARED_MSB+1
`define CHI_REQ_ALLOWRETRY_MSB      `CHI_REQ_ALLOWRETRY_LSB
`define CHI_REQ_ORDER_LSB           `CHI_REQ_ALLOWRETRY_MSB+1
`define CHI_REQ_ORDER_MSB           `CHI_REQ_ORDER_LSB+WORDER-1
`define CHI_REQ_PCRDTYPE_LSB        `CHI_REQ_ORDER_MSB+1
`define CHI_REQ_PCRDTYPE_MSB        `CHI_REQ_PCRDTYPE_LSB+WPCRDTYPE-1
`define CHI_REQ_MEMATTR_LSB         `CHI_REQ_PCRDTYPE_MSB+1
`define CHI_REQ_MEMATTR_MSB         `CHI_REQ_MEMATTR_LSB+WMEMATTR-1
`define CHI_REQ_SNPATTR_LSB         `CHI_REQ_MEMATTR_MSB+1
`define CHI_REQ_SNPATTR_MSB         `CHI_REQ_SNPATTR_LSB+WSNPATTR-1
`define CHI_REQ_LPID_LSB            `CHI_REQ_SNPATTR_MSB+1
`define CHI_REQ_LPID_MSB            `CHI_REQ_LPID_LSB+WLPID-1
`define CHI_REQ_EXCL_LSB            `CHI_REQ_LPID_MSB+1
`define CHI_REQ_EXCL_MSB            `CHI_REQ_EXCL_LSB
`define CHI_REQ_EXPCOMPACK_LSB      `CHI_REQ_EXCL_MSB+1
`define CHI_REQ_EXPCOMPACK_MSB      `CHI_REQ_EXPCOMPACK_LSB
<% if(obj.AiuInfo[obj.Id].fnNativeInterface != 'CHI-A') { %>
<% if(obj.AiuInfo[obj.Id].fnNativeInterface == 'CHI-E') { %>
`define CHI_REQ_TAGOP_LSB           `CHI_REQ_EXPCOMPACK_MSB+1
`define CHI_REQ_TAGOP_MSB           `CHI_REQ_TAGOP_LSB+TAGOP-1
`define CHI_REQ_TRACETAG_LSB        `CHI_REQ_TAGOP_MSB+1
<% } else { %>
`define CHI_REQ_TRACETAG_LSB        `CHI_REQ_EXPCOMPACK_MSB+1
<% } %>
`define CHI_REQ_TRACETAG_MSB        `CHI_REQ_TRACETAG_LSB
`define CHI_REQ_RSVDC_LSB           `CHI_REQ_TRACETAG_MSB+1
<% } else { %>
`define CHI_REQ_RSVDC_LSB           `CHI_REQ_EXPCOMPACK_MSB+1
<% } %>
`define CHI_REQ_RSVDC_MSB           `CHI_REQ_RSVDC_LSB+WREQRSVDC-1

<% if(obj.AiuInfo[obj.Id].fnNativeInterface != 'CHI-A') { %>
`define CHI_DAT_HOMENID_LSB         `CHI_REQ_TXNID_MSB+1
`define CHI_DAT_HOMENID_MSB         `CHI_DAT_HOMENID_LSB+WHOMENID-1
`define CHI_DAT_OPCODE_LSB          `CHI_DAT_HOMENID_MSB+1
<% } else { %>
`define CHI_DAT_OPCODE_LSB          `CHI_REQ_TXNID_MSB+1
<% } %>
`define CHI_DAT_OPCODE_MSB          `CHI_DAT_OPCODE_LSB+WDATAOPCODE-1
`define CHI_DAT_RESPERR_LSB         `CHI_DAT_OPCODE_MSB+1
`define CHI_DAT_RESPERR_MSB         `CHI_DAT_RESPERR_LSB+WRESPERR-1
`define CHI_DAT_RESP_LSB            `CHI_DAT_RESPERR_MSB+1
`define CHI_DAT_RESP_MSB            `CHI_DAT_RESP_LSB+WRESP-1
<% if(obj.AiuInfo[obj.Id].fnNativeInterface != 'CHI-A') { %>
<% if(obj.AiuInfo[obj.Id].fnNativeInterface == 'CHI-E') { %>
`define CHI_DAT_DATASOURCE_LSB      `CHI_DAT_RESP_MSB+1
`define CHI_DAT_DATASOURCE_MSB      `CHI_DAT_DATASOURCE_LSB+WDATASOURCE-1
`define CHI_DAT_CBUSY_LSB           `CHI_DAT_DATASOURCE_MSB+1
`define CHI_DAT_CBUSY_MSB           `CHI_DAT_CBUSY_LSB+WCBUSY-1
`define CHI_DAT_DBID_LSB            `CHI_DAT_CBUSY_MSB+1
<% } else { %>
`define CHI_DAT_FWDSTATE_LSB        `CHI_DAT_RESP_MSB+1
`define CHI_DAT_FWDSTATE_MSB        `CHI_DAT_FWDSTATE_LSB+WFWDSTATE-1
`define CHI_DAT_DBID_LSB            `CHI_DAT_FWDSTATE_MSB+1
<% } %>
<% } else { %>
`define CHI_DAT_DBID_LSB            `CHI_DAT_RESP_MSB+1
<% } %>
`define CHI_DAT_DBID_MSB            `CHI_DAT_DBID_LSB+WDBID-1
`define CHI_DAT_CCID_LSB            `CHI_DAT_DBID_MSB+1
`define CHI_DAT_CCID_MSB            `CHI_DAT_CCID_LSB+WCCID-1
`define CHI_DAT_DATAID_LSB          `CHI_DAT_CCID_MSB+1
`define CHI_DAT_DATAID_MSB          `CHI_DAT_DATAID_LSB+WDATAID-1
<% if(obj.AiuInfo[obj.Id].fnNativeInterface != 'CHI-A') { %>
<% if(obj.AiuInfo[obj.Id].fnNativeInterface == 'CHI-E') { %>
`define CHI_DAT_TAGOP_LSB           `CHI_DAT_DATAID_MSB+1
`define CHI_DAT_TAGOP_MSB           `CHI_DAT_TAGOP_LSB+WDATATAGOP-1
`define CHI_DAT_TAG_LSB             `CHI_DAT_TAGOP_MSB+1
`define CHI_DAT_TAG_MSB             `CHI_DAT_TAG_LSB+WTAG-1
`define CHI_DAT_TU_LSB              `CHI_DAT_TAG_MSB+1
`define CHI_DAT_TU_MSB              `CHI_DAT_TU_LSB+WTU-1
`define CHI_DAT_TRACETAG_LSB        `CHI_DAT_TU_MSB+1 //(4 = tag =4, tagup = 1) 
<% } else { %>
`define CHI_DAT_TRACETAG_LSB        `CHI_DAT_DATAID_MSB+1
<% } %>
`define CHI_DAT_TRACETAG_MSB        `CHI_DAT_TRACETAG_LSB
`define CHI_DAT_RSVDC_LSB           `CHI_DAT_TRACETAG_MSB+1
<% } else { %>
`define CHI_DAT_RSVDC_LSB           `CHI_DAT_DATAID_MSB+1
<% } %>
`define CHI_DAT_RSVDC_MSB           `CHI_DAT_RSVDC_LSB+WDATRSVDC-1
`define CHI_DAT_BE_LSB              `CHI_DAT_RSVDC_MSB+1
`define CHI_DAT_BE_MSB              `CHI_DAT_BE_LSB+WBE-1
`define CHI_DAT_DATA_LSB            `CHI_DAT_BE_MSB+1
`define CHI_DAT_DATA_MSB            `CHI_DAT_DATA_LSB+WDATA-1
<% if(obj.AiuInfo[obj.Id].fnNativeInterface != 'CHI-A') { %>
//`define CHI_DAT_DATACHECK_LSB       `CHI_DAT_DATA_MSB+1
//`define CHI_DAT_DATACHECK_MSB       `CHI_DAT_DATACHECK_LSB+WDATACHECK-1
<% if(obj.AiuInfo[obj.Id].interfaces.chiInt.params.enPoison) { %>
`define CHI_DAT_POISON_LSB          `CHI_DAT_DATA_MSB+1
`define CHI_DAT_POISON_MSB          `CHI_DAT_POISON_LSB+WPOSION-1
<% } %>
<% } %>

`define CHI_RSP_OPCODE_LSB          `CHI_REQ_TXNID_MSB+1
`define CHI_RSP_OPCODE_MSB          `CHI_RSP_OPCODE_LSB+WRSPOPCODE-1
`define CHI_RSP_RESPERR_LSB         `CHI_RSP_OPCODE_MSB+1
`define CHI_RSP_RESPERR_MSB         `CHI_RSP_RESPERR_LSB+WRESPERR-1
`define CHI_RSP_RESP_LSB            `CHI_RSP_RESPERR_MSB+1
`define CHI_RSP_RESP_MSB            `CHI_RSP_RESP_LSB+WRESP-1
<% if(obj.AiuInfo[obj.Id].fnNativeInterface != 'CHI-A') { %>
<% if(obj.AiuInfo[obj.Id].fnNativeInterface == 'CHI-E') { %>
`define CHI_RSP_FWDSTATE_LSB        `CHI_RSP_RESP_MSB+1
`define CHI_RSP_FWDSTATE_MSB        `CHI_RSP_FWDSTATE_LSB+WFWDSTATE-1
`define CHI_RSP_CBUSY_LSB           `CHI_RSP_FWDSTATE_MSB+1
`define CHI_RSP_CBUSY_MSB           `CHI_RSP_CBUSY_LSB+WCBUSY-1
`define CHI_RSP_DBID_LSB            `CHI_RSP_CBUSY_MSB+1
<% } else { %>
`define CHI_RSP_FWDSTATE_LSB        `CHI_RSP_RESP_MSB+1
`define CHI_RSP_FWDSTATE_MSB        `CHI_RSP_FWDSTATE_LSB+WFWDSTATE-1
`define CHI_RSP_DBID_LSB            `CHI_RSP_FWDSTATE_MSB+1
<% } %>
<% } else { %>
`define CHI_RSP_DBID_LSB            `CHI_RSP_RESP_MSB+1
<% } %>
`define CHI_RSP_DBID_MSB            `CHI_RSP_DBID_LSB+WDBID-1
`define CHI_RSP_PCRDTYPE_LSB        `CHI_RSP_DBID_MSB+1
`define CHI_RSP_PCRDTYPE_MSB        `CHI_RSP_PCRDTYPE_LSB+WPCRDTYPE-1
<% if(obj.AiuInfo[obj.Id].fnNativeInterface != 'CHI-A') { %>
<% if(obj.AiuInfo[obj.Id].fnNativeInterface == 'CHI-E') { %>
`define CHI_RSP_TAGOP_LSB           `CHI_RSP_PCRDTYPE_MSB+1
`define CHI_RSP_TAGOP_MSB           `CHI_RSP_TAGOP_LSB+WDATATAGOP-1
`define CHI_RSP_TRACETAG_LSB        `CHI_RSP_TAGOP_MSB+1
`define CHI_RSP_TRACETAG_MSB        `CHI_RSP_TRACETAG_LSB
<% } else { %>
`define CHI_RSP_TRACETAG_LSB        `CHI_RSP_PCRDTYPE_MSB+1
`define CHI_RSP_TRACETAG_MSB        `CHI_RSP_TRACETAG_LSB
<% } %>
<% } %>

`define CHI_SNP_QOS_LSB     0
`define CHI_SNP_QOS_MSB     WQOS-1
`define CHI_SNP_SRCID_LSB   `CHI_SNP_QOS_MSB+1
`define CHI_SNP_SRCID_MSB   `CHI_SNP_SRCID_LSB+WSRCID-1
`define CHI_SNP_TXNID_LSB   `CHI_SNP_SRCID_MSB+1
`define CHI_SNP_TXNID_MSB   `CHI_SNP_TXNID_LSB+WTXNID-1
<% if((obj.AiuInfo[obj.Id].fnNativeInterface == 'CHI-B') || (obj.AiuInfo[obj.Id].fnNativeInterface == 'CHI-E')) { %>
`define CHI_SNP_FWDNID_LSB  `CHI_SNP_TXNID_MSB+1
`define CHI_SNP_FWDNID_MSB  `CHI_SNP_FWDNID_LSB+WFWDNID-1
`define CHI_SNP_FWDTXNID_LSB `CHI_SNP_FWDNID_MSB+1
`define CHI_SNP_FWDTXNID_MSB `CHI_SNP_FWDTXNID_LSB+WFWDTXNID-1
`define CHI_SNP_OPCODE_LSB   `CHI_SNP_FWDTXNID_MSB+1
<% } else { %>
`define CHI_SNP_OPCODE_LSB   `CHI_SNP_TXNID_MSB+1
<% } %>
`define CHI_SNP_OPCODE_MSB   `CHI_SNP_OPCODE_LSB+WSNPOPCODE-1
`define CHI_SNP_ADDR_LSB     `CHI_SNP_OPCODE_MSB+1
`define CHI_SNP_ADDR_MSB     `CHI_SNP_ADDR_LSB+WSNPADDR-1
`define CHI_SNP_NS_LSB      `CHI_SNP_ADDR_MSB+1
`define CHI_SNP_NS_MSB      `CHI_SNP_NS_LSB
<% if(obj.AiuInfo[obj.Id].fnNativeInterface != 'CHI-A') { %>
`define CHI_SNP_DNGSD_LSB   `CHI_SNP_NS_MSB+1
`define CHI_SNP_DNGSD_MSB   `CHI_SNP_DNGSD_LSB
`define CHI_SNP_RETSRC_LSB  `CHI_SNP_DNGSD_MSB+1
`define CHI_SNP_RETSRC_MSB  `CHI_SNP_RETSRC_LSB
`define CHI_SNP_TRACETAG_LSB `CHI_SNP_RETSRC_MSB+1
`define CHI_SNP_TRACETAG_MSB `CHI_SNP_TRACETAG_LSB
<% } %>

