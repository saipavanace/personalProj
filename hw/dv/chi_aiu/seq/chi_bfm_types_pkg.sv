
package <%=obj.BlockId%>_chi_bfm_types_pkg;
  import ncore_config_pkg::*;

import addr_trans_mgr_pkg::*;

typedef enum bit [2:0] {
  CHI_IX, CHI_UC, CHI_UCE, CHI_UD, CHI_UDP, CHI_SD, CHI_SC
} chi_bfm_cache_state_t;

typedef bit [ncoreConfigInfo::W_SEC_ADDR - 1 : 0] addr_width_t;
typedef bit [7:0] byte_64_t[64];
typedef bit bit_64_t[64];

typedef struct {
  byte_64_t m_data;
  bit_64_t  m_be;
} chi_data_be_t;

typedef enum int {
  TX_REQ_CHNL, TX_RSP_CHNL, TX_DAT_CHNL, 
  RX_SNP_CHNL, RX_RSP_CHNL, RX_DAT_CHNL
} chi_bfm_chnl_t;

typedef enum int {
  RD_NONCOH_CMD, 
  RD_RDONCE_CMD,
  RD_LDRSTR_CMD,
  DT_LS_UPD_CMD,
  DT_LS_CMO_CMD,
  DT_LS_STH_CMD,
  WR_NONCOH_CMD,
  WR_COHUNQ_CMD,
  WR_STHUNQ_CMD,
  WR_CPYBCK_CMD,
  ATOMIC_ST_CMD,
  ATOMIC_LD_CMD,
  ATOMIC_SW_CMD,
  ATOMIC_CM_CMD,
  DVM_OPERT_CMD,
  PRE_FETCH_CMD,
  RQ_LCRDRT_CMD,
  SNP_STASH_CMD,
  RD_PRFR_UNQ_CMD,
  WR_NOSNP_FULL_CMO_CMD,
  WR_BACK_FULL_CMO_CMD,
  WR_CLN_FULL_CMO_CMD,
  WR_EVICT_OR_EVICT_CMD,
  UNSUP_TXN_CMD
} chi_bfm_opcode_type_t;

typedef enum int {
  COH_ADDR, NON_COH_ADDR
} chi_bfm_addr_format_t;

typedef enum int {
  NORMAL, DEVICE
} chi_bfm_memory_target_t;

typedef enum bit {
  NO_ALLOC, ALLOC
} chi_bfm_allocate_attr_t;

typedef enum bit {
  NON_CACHEABLE, CACHEABLE
} chi_bfm_cacheable_attr_t;

typedef enum int {
  BFM_RN, BFM_RNI, BFM_RND
} chi_bfm_node_t;

typedef enum int {
  CMD_BASED, STATE_BASED, ADDR_BASED
} chi_bfm_rand_txn_t;

typedef enum bit [1:0] {
  NO_ORDER, REQUEST_ACCEPTED, REQUEST_ORDER, ENDPOINT_ORDER
} chi_bfm_order_t;

typedef enum int {
    BFM_REQLCRDRETURN        = 'h00,
    BFM_READSHARED           = 'h01,
    BFM_READCLEAN            = 'h02,
    BFM_READONCE             = 'h03,
    BFM_READNOSNP            = 'h04,
    BFM_PCRDRETURN           = 'h05,
    BFM_READUNIQUE           = 'h07,
    BFM_CLEANSHARED          = 'h08,
    BFM_CLEANINVALID         = 'h09,
    BFM_MAKEINVALID          = 'h0A,
    BFM_CLEANUNIQUE          = 'h0B,
    BFM_MAKEUNIQUE           = 'h0C,
    BFM_EVICT                = 'h0D,
    BFM_EOBARRIER            = 'h0E,  //Valid only for CHI-A
    BFM_ECBARRIER            = 'h0F,  //Valid only for CHI-A
    BFM_DVMOP                = 'h14, 
    BFM_WRITEEVICTFULL       = 'h15,
    BFM_WRITECLEANPTL        = 'h16,  //Valid only for CHI-A
    BFM_WRITECLEANFULL       = 'h17,
    BFM_WRITEUNIQUEPTL       = 'h18,
    BFM_WRITEUNIQUEFULL      = 'h19,
    BFM_WRITEBACKPTL         = 'h1A,
    BFM_WRITEBACKFULL        = 'h1B,
    BFM_WRITENOSNPPTL        = 'h1C,
    BFM_WRITENOSNPFULL       = 'h1D,
    BFM_WRITEUNIQUEFULLSTASH = 'h20,
    BFM_WRITEUNIQUEPTLSTASH  = 'h21,
    BFM_STASHONCESHARED      = 'h22,
    BFM_STASHONCEUNIQUE      = 'h23,
    BFM_READONCECLEANINVALID = 'h24,
    BFM_READONCEMAKEINVALID  = 'h25,
    BFM_READNOTSHAREDDIRTY   = 'h26,
    BFM_CLEANSHAREDPERSIST   = 'h27,
    BFM_ATOMICSTORE_STADD    = 'h28,
    BFM_ATOMICSTORE_STCLR    = 'h29,
    BFM_ATOMICSTORE_STEOR    = 'h2A,
    BFM_ATOMICSTORE_STSET    = 'h2B,
    BFM_ATOMICSTORE_STSMAX   = 'h2C,
    BFM_ATOMICSTORE_STMIN    = 'h2D,
    BFM_ATOMICSTORE_STUSMAX  = 'h2E,
    BFM_ATOMICSTORE_STUMIN   = 'h2F,
    BFM_ATOMICLOAD_LDADD     = 'h30,
    BFM_ATOMICLOAD_LDCLR     = 'h31,
    BFM_ATOMICLOAD_LDEOR     = 'h32,
    BFM_ATOMICLOAD_LDSET     = 'h33,
    BFM_ATOMICLOAD_LDSMAX    = 'h34,
    BFM_ATOMICLOAD_LDMIN     = 'h35,
    BFM_ATOMICLOAD_LDUSMAX   = 'h36,
    BFM_ATOMICLOAD_LDUMIN    = 'h37,
    BFM_ATOMICSWAP           = 'h38,
    BFM_ATOMICCOMPARE        = 'h39,
    BFM_PREFETCHTARGET       = 'h3A,

<% if(obj.AiuInfo[obj.Id].fnNativeInterface != 'CHI-A') { %>
    BFM_UNSUP_OPCODE_0       = 'h06,
    BFM_UNSUP_OPCODE_1       = 'h10,
    BFM_UNSUP_OPCODE_2       = 'h11,
    BFM_UNSUP_OPCODE_3       = 'h12,
    <% if(obj.AiuInfo[obj.Id].fnNativeInterface != 'CHI-E') { %>
        BFM_UNSUP_OPCODE_4       = 'h13,
    <%}%>
    BFM_UNSUP_OPCODE_5       = 'h1E,
    BFM_UNSUP_OPCODE_6       = 'h1F,
    BFM_UNSUP_OPCODE_7       = 'h3B,
    BFM_UNSUP_OPCODE_8       = 'h3C,
    BFM_UNSUP_OPCODE_9       = 'h3D,
    BFM_UNSUP_OPCODE_10      = 'h3E,
    BFM_UNSUP_OPCODE_11      = 'h3F
<% } else { %>
    BFM_UNSUP_OPCODE_0       = 'h06,
    BFM_UNSUP_OPCODE_1       = 'h10,
    BFM_UNSUP_OPCODE_2       = 'h11,
    BFM_UNSUP_OPCODE_3       = 'h12,
    BFM_UNSUP_OPCODE_4       = 'h13,
    BFM_UNSUP_OPCODE_5       = 'h1E,
    BFM_UNSUP_OPCODE_6       = 'h1F
<% } %>
} chi_bfm_opcode_t;

typedef enum int {
 BFM_RESPLCRDRETURN = 'h0,
 BFM_SNPRESP        = 'h1,
 BFM_COMPACK        = 'h2,
 BFM_RETRYACK       = 'h3,
 BFM_COMP           = 'h4,
 BFM_COMPDBIDRESP   = 'h5,
 BFM_DBIDRESP       = 'h6,
 BFM_PCRDGRANT      = 'h7, 
 BFM_READRECEIPT    = 'h8,
 BFM_SNPRESPFWD     = 'h9
} chi_bfm_rsp_opcode_t;

typedef enum int {
 BFM_DATALCRDRETURN    = 'h0,
 BFM_SNPRESPDATA       = 'h1,
 BFM_COPYBACKWRDATA    = 'h2,
 BFM_NONCOPYBACKWRDATA = 'h3,
 BFM_COMPDATA          = 'h4,
 BFM_SNPRESPDATAPTL    = 'h5,
 BFM_SNPRESPDATAFWDED  = 'h6,
 BFM_WRITEDATACANCEL   = 'h7
} chi_bfm_dat_opcode_t;

typedef enum int {
    BFM_SNPLCRDRETURN         = 'h0,
    BFM_SNPSHARED             = 'h1,
    BFM_SNPCLEAN              = 'h2,
    BFM_SNPONCE               = 'h3,
    BFM_SNPNOTSHAREDDIRTY     = 'h4,
    BFM_SNPUNIQUESTASH        = 'h5,
    BFM_SNPMAKEINVALIDSTASH   = 'h6,
    BFM_SNPUNIQUE             = 'h7,
    BFM_SNPCLEANSHARED        = 'h8,
    BFM_SNPCLEANINVALID       = 'h9,
    BFM_SNPMAKEINVALID        = 'hA,
    BFM_SNPSTASHUNIQUE        = 'hB,
    BFM_SNPSTASHSHARED        = 'hC,
    BFM_SNPDVMOP              = 'hD,
    BFM_SNPSHAREDFWD          = 'h11,
    BFM_SNPCLEANFWD           = 'h12,
    BFM_SNPONCEFWD            = 'h13,
    BFM_SNPNOTSHAREDDIRTYFWD  = 'h14,
    BFM_SNPUNIQUEFWD          = 'h17
} chi_bfm_snp_opcode_t;

typedef enum int {
  BFM_COMPDATA_IX = 'h0,
  BFM_COMPDATA_UC = 'h2,
  BFM_COMPDATA_SC = 'h1,
  BFM_COMPDATA_UD_PD = 'h6,
  BFM_COMPDATA_SD_PD = 'h7
} chi_bfm_compdata_rsp_t;

typedef enum int {
  BFM_COMP_IX   = 'h0,
  BFM_COMP_UC   = 'h2,
  BFM_COMP_SC   = 'h1
} chi_bfm_comp_rsp_t;

typedef enum int {
  BFM_NONCPYBCK_CPYBCK_IX  = 'h0,
  BFM_COPYBACKWRDATA_UC    = 'h2,
  BFM_COPYBACKWRDATA_SC    = 'h1,
  BFM_COPYBACKWRDATA_UD_PD = 'h6,
  BFM_COPYBACKWRDATA_SD_PD = 'h7
} chi_bfm_copyback_rsp_t;

typedef enum int {
  BFM_SNPRSP, 
  BFM_SNPRSP_FWD,
  BFM_SNPRSP_DATA,
  BFM_SNPRSP_DATA_FWD
} chi_bfm_snprsp_type_t;

typedef enum int {
  BFM_SNPRSP_IX       = 'h0,
  BFM_SNPRSP_SC       = 'h1,
  BFM_SNPRSP_UC_OR_UD = 'h2,
  BFM_SNPRSP_SD       = 'h3
} chi_bfm_snprsp_rsp_t;

//These values are combination of RESP and FWDSTATE
//CHI Spec table 4-8 Pg 151
typedef enum int {
  BFM_SNPRSP_IX_FWD_IX    = 'h0,
  BFM_SNPRSP_IX_FWD_SC    = 'h1,
  BFM_SNPRSP_IX_FWD_UC    = 'h2,
  BFM_SNPRSP_IX_FWD_UD_PD = 'h6,
  BFM_SNPRSP_IX_FWD_SD_PD = 'h7,
  BFM_SNPRSP_SC_FWD_IX    = 'h8,
  BFM_SNPRSP_SC_FWD_SC    = 'h9,
  BFM_SNPRSP_SC_FWD_SD_PD = 'hF,
  BFM_SNPRSP_UC_FWD_IX    = 'h10,
  BFM_SNPRSP_SD_FWD_IX    = 'h18,
  BFM_SNPRSP_SD_FWD_SC    = 'h19
} chi_bfm_snprsp_fwd_t;

//These values are combination of DAT-OPCODE and RESP
//CHI Spec table 4-9 Pg 152
typedef enum int {
  BFM_SNPRSP_DATA_IX        = 'h8,
  BFM_SNPRSP_DATA_UC_OR_UD  = 'hA,
  BFM_SNPRSP_DATA_SC        = 'h9,
  BFM_SNPRSP_DATA_SD        = 'hB,
  BFM_SNPRSP_DATA_IX_PD     = 'hC,
  BFM_SNPRSP_DATA_UC_PD     = 'hE,
  BFM_SNPRSP_DATA_SC_PD     = 'hD,
  BFM_SNPRSP_DATAPTL_IX_PD  = 'h2C,
  BFM_SNPRSP_DATAPTL_UD     = 'h2A
} chi_bfm_snprsp_data_t;

//These values are combination of DAT-OPCODE, RESP & FwdState
//CHI Spec table 4-10 Pg 153
typedef enum int {
  BFM_SNPRSP_DATA_IX_FWD_SC    = 'h181,
  BFM_SNPRSP_DATA_IX_FWD_SD_PD = 'h187,
  BFM_SNPRSP_DATA_SC_FWD_SC    = 'h189,
  BFM_SNPRSP_DATA_SC_FWD_SD_PD = 'h18F,
  BFM_SNPRSP_DATA_SD_FWD_SC    = 'h199,
  BFM_SNPRSP_DATA_IX_PD_FWD_IX = 'h1A0,
  BFM_SNPRSP_DATA_IX_PD_FWD_SC = 'h1A1,
  BFM_SNPRSP_DATA_SC_PD_FWD_IX = 'h1A8,
  BFM_SNPRSP_DATA_SC_PD_FWD_SC = 'h1A9
} chi_bfm_snprsp_data_fwd_t; 

typedef enum int {
  BFM_RESP_OK, BFM_RESP_EXOK, BFM_RESP_DERR, BFM_RESP_NDERR
} chi_bfm_rsp_err_t;

endpackage: <%=obj.BlockId%>_chi_bfm_types_pkg
