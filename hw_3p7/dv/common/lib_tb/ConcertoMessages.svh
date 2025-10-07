////////////////////////////////////////////////////////////////////////////////
// Type Definitions
////////////////////////////////////////////////////////////////////////////////

//typedef bit [<%=obj.wSfiSlvId%>              - 1: 0] SFISlvID_t;
//typedef bit [SMI_MSG_TYPE_WIDTH                - 1: 0] MsgType_t;
//typedef bit [SFI_PRIV_MSG_ATTR_WIDTH         - 1: 0] MsgAttr_t;
//typedef bit [SFI_PRIV_REQ_AIU_PROCID_WIDTH   - 1: 0] AceProcID_t;
//typedef bit [SFI_PRIV_REQ_ACE_USER_WIDTH     - 1: 0] AceUser_t;

//typedef bit                                    AceLock_t;
//typedef                          axi_axprot_t  AceProt_t;
//typedef                         axi_axcache_t  AceCache_t;
//typedef                           axi_axqos_t  AceQos_t;
//typedef                        axi_axregion_t  AceRegion_t;
////typedef                           axi_wuser_t  AceUser_t;
//typedef                        axi_axdomain_t  AceDomain_t;
//typedef bit                                    AceUnique_t; //Boon: to change its type from "bit" to "axi_axunique_t"
//typedef bit                                    AceExOkay_t;

//localparam SecureCacheAddrMsb = WSEC + SYS_wSysAddress - 1;
//localparam SecureCacheAddrLsb = SYS_wSysAddress;

//typedef bit [WSEC+SYS_wSysAddress       -1:0]  cacheAddress_t;
//typedef bit [WTRANSID                   -1:0]  SFITransID_t;
typedef bit [wNumCachingAius            -1:0]  coherResult_ST_t;

//typedef bit [                            1:0]  errResult_t;

//typedef struct packed {
//  bit [(<%=obj.BlockId + '_con'%>::SYS_nSysCohAIUs * SYS_nSysAIUMaxProcs)-1:0] valid; // one bit for each processor in the system, at most one bit can be set.
//} basic_monitor_t;
	
//typedef struct {
//  basic_monitor_t bas_mon;
//  cacheAddress_t  addr;
//} tagged_monitor_t;

////////////////////////////////////////////////////////////////////////////////
//
// DCE decodes these protocol message encodings:
//
////////////////////////////////////////////////////////////////////////////////


////////////////////////////////////////////////////////////////////////////////
//
// Message bit field data structures
//
////////////////////////////////////////////////////////////////////////////////

typedef struct packed {

  bit RV;
  bit RS;
  bit DC;
  bit DT;

} snoopResult_t;

typedef struct packed {

  bit SO;
  bit SS;
  bit SD;
  coherResult_ST_t ST;

} coherResult_t;

typedef struct packed {

  bit DO;
  bit DS;

} transResult_t;

typedef struct packed {

    bit TS;
    bit AC;
    bit VZ;

} msgAttr_t;

//Maintainence OpCode format
typedef enum bit [3:0] {
    MEM_INIT = 4'h0, RECALL_ALL = 4'h4, RECALL_INDEX_WAY =4'h5, RECALL_ADDRESS = 4'h6,
    RECALL_VICTIM_BUFFER = 4'h8, DBG_RD_ENTRY = 4'hC, DBG_WR_ENTRY = 4'hE} maint_req_opcode_t;


