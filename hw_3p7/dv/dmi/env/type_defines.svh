
localparam int WDATA         = <%=obj.DmiInfo[obj.Id].wData%>;
localparam int NUM_AIUS      = <%=obj.DmiInfo[obj.Id].nAius%>;
localparam int NUM_DCES      = <%=obj.DceInfo.length%>;
localparam int SMI_MSG_WIDTH = <%=obj.DmiInfo[obj.Id].concParams.hdrParams.wMsgId%>;
localparam int AIU_TABLE_MAX = ((2**SMI_MSG_WIDTH)*NUM_AIUS);
localparam int DCE_TABLE_MAX = ((2**SMI_MSG_WIDTH)*NUM_DCES);
localparam int CMD_SKID_BUF_SIZE = <%=obj.DmiInfo[obj.Id].nCMDSkidBufSize%>;
localparam int MRD_SKID_BUF_SIZE = <%=obj.DmiInfo[obj.Id].nMrdSkidBufSize%>;
localparam int N_SYS_CACHELINE = 64;
localparam int W_DATA          = <%=obj.DmiInfo[obj.Id].wData%>;
localparam int BEAT_INDEX_LOW  = <%= Math.log2(obj.DmiInfo[obj.Id].wData/8)%>;
localparam int BEAT_INDEX_HIGH = <%=(Math.log2(Math.pow(2,obj.wCacheLineOffset)))-1%>;
localparam int COH_RBID_SIZE   = <%=obj.DmiInfo[obj.Id].cmpInfo.nDceRbEntries%>;
localparam int NONCOH_RBID_SIZE= <%=obj.DmiInfo[obj.Id].cmpInfo.nDmiRbEntries%>;
localparam int RTT_SIZE        = <%=obj.DmiInfo[obj.Id].cmpInfo.nRttCtrlEntries%>;
localparam int WTT_SIZE        = <%=obj.DmiInfo[obj.Id].cmpInfo.nWttCtrlEntries%>;
localparam int ADDR_WIDTH      = <%=obj.wSysAddr%>;
localparam int CCP_CL_OFFSET   = <%=obj.wCacheLineOffset%>;
<% if(obj.useCmc) { %>
localparam int CCP_SETS   = <%=obj.DmiInfo[obj.Id].ccpParams.nSets%>;
localparam int CCP_WAYS   = <%=obj.DmiInfo[obj.Id].ccpParams.nWays%>;
localparam int DATA_BANKS = <%=obj.DmiInfo[obj.Id].ccpParams.nDataBanks%>;
localparam int SET_X_WAY  = <%=obj.DmiInfo[obj.Id].ccpParams.nWays*obj.DmiInfo[obj.Id].ccpParams.nSets%>;
<% if( (obj.DmiInfo[obj.Id].ccpParams.nBeatsPerBank == 2 && obj.DmiInfo[obj.Id].ccpParams.wData == 256) ||
       (obj.DmiInfo[obj.Id].ccpParams.nBeatsPerBank == 2 && obj.DmiInfo[obj.Id].ccpParams.wData == 128) ||
       (obj.DmiInfo[obj.Id].ccpParams.nBeatsPerBank == 1 && obj.DmiInfo[obj.Id].ccpParams.wData == 256) ) {%>
localparam int CCP_BEATN       = 2;
<%} else if( obj.DmiInfo[obj.Id].ccpParams.nBeatsPerBank == 1 && obj.DmiInfo[obj.Id].ccpParams.wData == 128) {%>
localparam int CCP_BEATN       = 4;
<%} else {%>
localparam int CCP_BEATN       = 1;
<% } } %>

`define uvm_guarded_info(EN,ID,PRINT,VERBOSITY) \
  if(EN) begin \
    `uvm_info(ID,PRINT,VERBOSITY) \
  end 


typedef bit bit_q[$];

typedef int int_q[$];

typedef smi_rbid_t smi_rbid_q[$];

typedef bit [WSMINCOREUNITID- 1: 0] AIUID_t;
typedef bit [WSMIMSGID      - 1: 0] AIUmsgID_t;

typedef enum int {
  COH_WR_TT,
  COH_RD_TT,
  NON_COH_RD_TT,
  NON_COH_WR_TT,
  ATM_LD_TT
} dmi_table_type_t;

typedef enum int{
  QOS_NORMAL,
  QOS_UPDATE
} dmi_qos_seq_type_t;

typedef enum int {
  COH_RD,
  NON_COH_RD,
  COH_WR,
  NON_COH_WR
} dmi_backpressure_type_t;

typedef enum int{
  CMD_CT,
  MRD_CT
} dmi_credit_table_type_t;

typedef struct {
  dmi_table_type_t src_type;
  smi_ns_t ns;
  smi_addr_t addr;
} smi_full_addr_t;



typedef smi_full_addr_t smi_addr_q[$];

typedef struct packed{
  bit is_used;
  smi_msg_id_bit_t msg_id;
  smi_ncore_unit_id_bit_t dce_id;
  int rbid;
} dce_table_t;

typedef struct packed {
  bit            is_used;
  AIUID_t        aiu_id;
  AIUmsgID_t     msg_id;
} aiu_table_t;

typedef struct packed {
  bit is_used;
  bit is_int_release;
  smi_rbid_t rbid;
} rbid_table_t;

typedef struct packed {
  smi_ncore_unit_id_bit_t  aiu_id;
  smi_msg_id_bit_t         msg_id;
} aiu_id_t;

typedef struct packed{
  smi_ncore_unit_id_bit_t dce_id;
  smi_msg_id_bit_t        msg_id;
  smi_rbid_t              rbid;
} dce_id_t;

typedef aiu_id_t AIUIDQ_t[$];

typedef struct packed {
  AIUID_t        req_aiu_id;
  AIUmsgID_t     req_aiu_msg_id;
} aiu_id_queue_t;

typedef struct {
  aiu_id_queue_t entry;
  bit            inUse;
} AIUmsgIDTableEntry_t;


typedef struct {
  smi_ncore_unit_id_bit_t src_id;   
  smi_msg_id_bit_t        smi_msg_id;
  smi_rbid_t              smi_rbid;
  bit         valRb;
  bit         inUse;
} SMImsgIDTableEntry_t;

typedef enum int {
  FLOW_CONTROL,
  BELOW_LIMIT,
  ARBITRARY_SLOW,
  NO_LONG_DELAY
} long_delay_mode_e;

typedef enum int {MIN,MAX} min_max_t;

typedef enum int {
  MERGING_WRITE,
  NONCOH_CMD_DTW_RSP,
  NONCOH_ATM_DTW_RSP
} rsrc_semaphore_t;

typedef enum bit[1:0] {
  NULL_ERROR=0,
  ADDRESS_ERROR=1,
  SINGLE_BIT_DATA_ERROR=2,
  DOUBLE_BIT_DATA_ERROR=3
} error_type_t;

typedef struct{
  bit flag; //0:OFF 1:ON
  rsrc_semaphore_t _type;
  smi_rbid_t mw_rbid; //To send merging write DTW
}resource_semaphore_t;

typedef enum int {
  DMI_RAW_p,
  DMI_WAW_p,
  DMI_CMP_ATM_MATCH_p,
  DMI_USER_p,
  DMI_EXCLUSIVE_p,
  DMI_CMO_on_WR_p,
  DMI_LATE_MRD_p,
  DMI_CACHE_WARMUP_p,
  DMI_SP_WARMUP_p,
  DMI_ATM_MRG_p,
  DMI_RAND_p 
} dmi_pattern_type_t;

typedef enum int {
  DEADLOCK_ATM_MRG_p,
  SUPER_NULL_p
} dmi_super_pattern_type_t;

`ifdef VCS
typedef uvm_enum_wrapper#(dmi_pattern_type_t) dmi_pattern_type_t_wrapper;
typedef uvm_enum_wrapper#(dmi_super_pattern_type_t) dmi_super_pattern_type_t_wrapper;
typedef uvm_enum_wrapper#(long_delay_mode_e) long_delay_mode_e_wrapper;
`endif

typedef enum int {
  COH,
  NONCOH
} dmi_addr_format_t;

typedef struct packed {
  smi_type_t smi_type;
  dmi_pattern_type_t pattern_type;
  dmi_addr_format_t addr_type;
  int payload_size;
} traffic_type_pair_t;

typedef enum int {
  REUSE,
  CACHE_EVICT,
  INCREMENTAL,
  RANDOM,
  CACHE_WARMUP,
  SCRATCHPAD,
  REGULAR
} dmi_addr_q_format_t;

typedef enum int {
  PRIMARY,
  SECONDARY
} dmi_addr_q_type_t;

typedef enum int{
  AIU_TABLE_TIMEOUT,
  DCE_TABLE_TIMEOUT,
  ADDRESS_TIMEOUT,
  CREDIT_TIMEOUT,
  RBID_TIMEOUT,
  RBID_RELEASE_TIMEOUT
} dmi_timeout_state_t;

typedef enum int{
  FILL,
  BURST
} dmi_delay_t;

//Classes


class MRDInfo_t extends uvm_object;
  MsgType_t        cmd_msg_type;
  AIUID_t          aiu_id;       // to match dtr
  AIUmsgID_t       aiu_msg_id; // to match dtr
  smi_ncore_unit_id_bit_t dce_id;   
  smi_msg_id_t     smi_msg_id; // for number of MRDs in flight
  smi_addr_t       cache_addr;   // can't have two MRDs with same addr
  smi_security_t   security; // can't have two MRDs with same addr
  bit              cmd_rsp_recd = 0;
  bit              dtr_recd = 0;

  function new(string name = "MRDInfo_t");
  endfunction : new
endclass // MRDInfo_t
class NcRDInfo_t extends uvm_object;
  MsgType_t        cmd_msg_type;
  AIUID_t          aiu_id;       // to match dtr
  smi_msg_id_t     smi_msg_id; // for number of NcRds in flight
  smi_addr_t       cache_addr;   // can't have two NcRds with same addr
  smi_security_t   security; // can't have two NcRds with same addr
  bit              cmd_rsp_recd = 0;
  bit              dtr_recd = 0;
  bit              str_recd = 0;
  bit              str_rsp_sent = 0;
  axi_arid_t       axi_axid_q;
  bit              arlock;

  function new(string name = "NcRDInfo_t");
  endfunction : new
endclass // NcRDInfo_t
class AtmLoadInfo_t extends uvm_object;
  MsgType_t        cmd_msg_type;
  AIUID_t          aiu_id;       // to match dtr
  smi_msg_id_t     smi_msg_id; 
  smi_addr_t       cache_addr;  
  smi_security_t   security; 
  bit              cmd_rsp_recd = 0;
  bit              dtr_recd = 0;
  bit              str_recd = 0;
  bit              str_rsp_sent = 0;
  bit              dtw_sent = 0;
  bit              dtw_rsp_recd = 0;

  function new(string name = "AtmLoadInfo_t");
  endfunction : new
endclass // AtmLoadInfo_t
class NcWRInfo_t extends uvm_object;
  MsgType_t          cmd_msg_type;
  smi_addr_t         cache_addr; 
  smi_security_t     security; 
  smi_rbid_t         smi_rbid; 
  AIUID_t            aiu_id; 
  smi_msg_id_t       smi_msg_id; 
  bit                cmd_rsp_recd = 0;
  bit                str_recd = 0;
  bit                str_rsp_sent = 0;
  bit                dtw_sent = 0;
  bit                dtw_rsp_recd = 0;
  axi_awid_t         axi_axid_q;
  bit                awlock;

  function new(string name = "NcWRInfo_t");
  endfunction : new
endclass // NcWRInfo_t

class DTWInfo_t extends uvm_object;
  smi_addr_t         cache_addr;   
  smi_security_t     security; 
  smi_rbid_t         smi_rbid; 
  AIUID_t            aiu_id; 
  AIUID_t            dtr_aiu_id; 
  AIUID_t            aiu_id_2nd; 
  smi_ncore_unit_id_bit_t dce_id;   
  smi_msg_id_t       smi_msg_id; 
  smi_msg_id_t       smi_msg_id_2nd; 
  smi_msg_id_t       dtr_rmsg_id; 
  smi_msg_id_t       RBRs_rmsg_id; 
  smi_msg_id_t       RBRl_rmsg_id; 
  bit                rb_rsp_recd = 0;
  bit                rb_rl_rsp_expd = 0;
  bit                rb_rl_rsp_recd = 0;
  bit                dtw_sent = 0;
  bit                dtw_rsp_recd = 0;
  bit                dtw_rsp_recd_2nd = 0;
  bit                dtr_recd = 0;
  bit                isMrgMrd;
  bit                isMW;
  int                dtws_expd;
  bit                rb_released;

  function new(string name = "DTWInfo_t");
  endfunction : new
endclass // DTWInfo_t

class AddrQ_t extends uvm_object;
  smi_addr_t         cache_addr;   // can't have two MRDs with same addr
  smi_security_t     security;   // can't have two MRDs with same addr
  bit                cacheable;
  MsgType_t          cmd_msg_type;
  AIUID_t            aiu_id; // to match req aiu
  AIUID_t            dtr_aiu_id; // to match dtr target id
  AIUmsgID_t         aiu_msg_id; // to match dtr
  smi_msg_id_t       smi_msg_id; // 
  bit    isMrd;
  bit    isMrgMrd;
  bit    isDtw;
  bit    isNcRd;
  bit    isNcWr;
  bit    isAtmLd;
  bit    isAtmSt;

  function new(string name = "AddrQ_t");
  endfunction : new
endclass // AddrQ_t

class Addr_t extends uvm_object;
  smi_addr_t     addr; 
  smi_security_t     security; 
  function new(string name = "Addr_t");
  endfunction : new
endclass // Addr_t

class dmi_exclusive_c extends uvm_object;
  smi_addr_t                addr;
  smi_msg_type_bit_t        msg_type;
  smi_ncore_unit_id_bit_t   src_id;
  smi_mpf2_flowid_t         flowid;
  smi_ns_t                  ns;
  //------------------------------------------------------------------------------
  // constructor
  //------------------------------------------------------------------------------
  function new(string name="");
     super.new(name);
  endfunction : new
endclass : dmi_exclusive_c
/*
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
             RB_USED_e			= 8'b01111101  //0x7D*/
