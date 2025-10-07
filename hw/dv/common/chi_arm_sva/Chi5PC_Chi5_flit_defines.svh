//------------------------------------------------------------------------------
// The confidential and proprietary information contained in this file may 
// only be used by a person authorised under and to the extent permitted 
// by a subsisting licensing agreement from ARM Limited.
//
//            (C) COPYRIGHT 2012-2014 ARM Limited.
//                ALL RIGHTS RESERVED
//
// This entire notice must be reproduced on all copies of this file 
// and copies of this file may only be made by a person if such person is 
// permitted to do so under the terms of a subsisting license agreement 
// from ARM Limited.
//
//----------------------------------------------------------------------------
//  Version and Release Control Information:
//
//  File Revision       : 172039
//
//  Date                :  2014-04-25 11:32:43 +0100 (Fri, 25 Apr 2014)
//
//  Release Information : BP066-BU-01000-r0p0-00lac0
//
//------------------------------------------------------------------------------

// Set this `define in case inclusion would be guarded
`define CHI5PC_FLIT_DEFINES_SVH
`include "Chi5PC_Chi5_defines.v"

  // Enum: eChi5PCReqOp
  // Defines all possible values for Chi5 request opcode
  typedef enum bit[4:0] {
    CHI5PC_REQ_LINKFLIT = `CHI5PC_REQLINKFLIT,
    CHI5PC_RD_SHD = `CHI5PC_READSHARED,
    CHI5PC_RD_CLN = `CHI5PC_READCLEAN,
    CHI5PC_RD_ONCE = `CHI5PC_READONCE,
    CHI5PC_RD_NO_SNP = `CHI5PC_READNOSNP,
    CHI5PC_RD_UNIQ = `CHI5PC_READUNIQUE,
    CHI5PC_CLN_SHD = `CHI5PC_CLEANSHARED,
    CHI5PC_CLN_INV = `CHI5PC_CLEANINVALID,
    CHI5PC_MAKE_INV = `CHI5PC_MAKEINVALID,
    CHI5PC_CLN_UNIQ = `CHI5PC_CLEANUNIQUE,
    CHI5PC_MAKE_UNIQ = `CHI5PC_MAKEUNIQUE,
    CHI5PC_DVM_OP = `CHI5PC_DVMOP,
    CHI5PC_EO_BARRIER = `CHI5PC_EOBARRIER,
    CHI5PC_EC_BARRIER = `CHI5PC_ECBARRIER,
    CHI5PC_CRD_RETURN = `CHI5PC_PCRDRETURN,
    CHI5PC_EVICT = `CHI5PC_EVICT,
    CHI5PC_WR_CLN_PTL = `CHI5PC_WRITECLEANPTL,
    CHI5PC_WR_BACK_PTL = `CHI5PC_WRITEBACKPTL,
    CHI5PC_WR_UNIQ_PTL = `CHI5PC_WRITEUNIQUEPTL,
    CHI5PC_WR_UNIQ_FULL = `CHI5PC_WRITEUNIQUEFULL,
    CHI5PC_WR_CLN_FULL = `CHI5PC_WRITECLEANFULL,
    CHI5PC_WR_BACK_FULL = `CHI5PC_WRITEBACKFULL,
    CHI5PC_WR_NO_SNP_PTL = `CHI5PC_WRITENOSNPPTL,
    CHI5PC_WR_NO_SNP_FULL = `CHI5PC_WRITENOSNPFULL,
    CHI5PC_WR_EVICT_FULL = `CHI5PC_WRITEEVICTFULL
  } eChi5PCReqOp;

  // Enum: eChi5PCRspOp
  // Defines all possible values for Chi5 response opcode
  typedef enum bit [3:0] {
    CHI5PC_RSP_LINKFLIT = `CHI5PC_RSPLINKFLIT,
    CHI5PC_SNP_RSP = `CHI5PC_SNPRESP,
    CHI5PC_COMP_ACK = `CHI5PC_COMPACK,
    CHI5PC_RETRY_ACK = `CHI5PC_RETRYACK,
    CHI5PC_COMP = `CHI5PC_COMP,
    CHI5PC_COMP_DBID_RSP = `CHI5PC_COMPDBIDRESP,
    CHI5PC_DBID_RSP = `CHI5PC_DBIDRESP,
    CHI5PC_CRD_GRANT = `CHI5PC_PCRDGRANT,
    CHI5PC_READ_RECEIPT = `CHI5PC_READRECEIPT
  } eChi5PCRspOp;

  // Enum: eChi5PCSnpOp
  // Defines all possible values for Chi5 snoop opcode
  typedef enum bit[3:0] {
    CHI5PC_SNP_LINKFLIT = `CHI5PC_SNPLINKFLIT,
    CHI5PC_SNP_SHD = `CHI5PC_SNPSHARED,
    CHI5PC_SNP_CLN = `CHI5PC_SNPCLEAN,
    CHI5PC_SNP_ONCE = `CHI5PC_SNPONCE,
    CHI5PC_SNP_UNIQ = `CHI5PC_SNPUNIQUE,
    CHI5PC_SNP_CLN_SHD = `CHI5PC_SNPCLEANSHARED,
    CHI5PC_SNP_CLN_INV = `CHI5PC_SNPCLEANINVALID,
    CHI5PC_SNP_MAKE_INV = `CHI5PC_SNPMAKEINVALID,
    CHI5PC_SNP_DVM_OP = `CHI5PC_SNPDVMOP
  } eChi5PCSnpOp;

  // Enum: eChi5PCDatOp
  // Defines all possible values for Chi5 data opcode
  typedef enum bit [2:0] {
    CHI5PC_DAT_LINKFLIT = `CHI5PC_DATLINKFLIT,
    CHI5PC_SNP_RSP_DATA = `CHI5PC_SNPRESPDATA,
    CHI5PC_COPYBACK_WR_DATA = `CHI5PC_COPYBACKWRDATA,
    CHI5PC_NON_COPYBACK_WR_DATA = `CHI5PC_NONCOPYBACKWRDATA,
    CHI5PC_COMP_DATA = `CHI5PC_COMPDATA,
    CHI5PC_SNP_RSP_DATA_PTL = `CHI5PC_SNPRESPDATAPTL
  } eChi5PCDatOp;

  // Enum: eChi5PCDvmType
  // Defines all possible values for Chi5 DVM request's guest/hypervisor field
  typedef enum bit [2:0] {
    CHI5PC_DVM_TLB_INV   = 3'b000,
    CHI5PC_DVM_BTB_INV   = 3'b001,
    CHI5PC_DVM_IC_PA_INV = 3'b010,
    CHI5PC_DVM_IC_VA_INV = 3'b011,
    CHI5PC_DVM_SYNC      = 3'b100
  } eChi5PCDvmType;

  // Enum: eChi5PCDvmNs
  // Defines all possible values for Chi5 DVM request's S/NS field
  typedef enum bit [1:0] {
    CHI5PC_DVM_NS_BOTH      = 2'b00,
    CHI5PC_DVM_NS_SECURE    = 2'b10,
    CHI5PC_DVM_NS_NONSECURE = 2'b11
  } eChi5PCDvmNs;

  // Enum: eChi5PCDvmHyp
  // Defines all possible values for Chi5 DVM request's guest/hypervisor field
  typedef enum bit [1:0] {
    CHI5PC_DVM_HYP_BOTH       = 2'b00,
    CHI5PC_DVM_HYP_GUESTOS    = 2'b10,
    CHI5PC_DVM_HYP_HYPERVISOR = 2'b11
  } eChi5PCDvmHyp;

  // Enum: eChi5PCDatWidth
  // Defines the possible widths of the data bytes on a Chi5 data virtual channel:
  //
  //   DAT_128B - 128-bits of data
  //   DAT_256B - 256-bits of data
  //   DAT_512B - 512-bits of data
  //
  // Defining the values this way allows them to be passed as parameters to various classes
  typedef enum {
    CHI5PC_DAT_128B = 128,
    CHI5PC_DAT_256B = 256,
    CHI5PC_DAT_512B = 512
  } eChi5PCDatWidth;

  // Enum: eChi5PCOrder
  // Defines the possible ordering types for a request
  //
  //   ORDER_NONE         - No ordering request
  //   ORDER_REQ          - Read receipt to enforce request ordering
  //   ORDER_REQ_ENDPOINT - Read receipt to enforce request ordering, plus endpoint ordering
  typedef enum bit [1:0] {
    CHI5PC_ORDER_NONE         = 2'b00,
    CHI5PC_ORDER_REQ          = 2'b10,
    CHI5PC_ORDER_REQ_ENDPOINT = 2'b11                      
  } eChi5PCOrder;

  // Enum: eChi5PCResp
  // Defines the possible encodings for a Chi5 response. These encodings are common for snoop and
  // completion responses on both the RSP and SNP VCs and are used to indicate the final state in
  // the responder.
  //
  //   RESP_I     - State is invalid  
  //   RESP_SC    - State is shared clean
  //   RESP_UC_UD - State is either unique clean or unique dirty
  //   RESP_SD    - State is shared dirty
  typedef enum bit [1:0] {
    CHI5PC_RESP_I     = 2'b00, 
    CHI5PC_RESP_SC    = 2'b01, 
    CHI5PC_RESP_UC_UD = 2'b10, 
    CHI5PC_RESP_SD    = 2'b11
  } eChi5PCResp;

  // Enum: eChi5PCRespErr
  // Defines the possible encodings for a Chi5 error response. These encodings are common for snoop and
  // completion responses on both the RSP and SNP VCs.
  //
  //   RESP_OK_EXCL_FAIL - Normal OK or exclusive fail for exclusive access
  //   EXCL_OK           - Exclusive OK
  //   DATA_ERR          - Data error
  //   NON_DATA_ERR      - Non Data error
  typedef enum bit [1:0] {
    CHI5PC_RESP_OK_EXCL_FAIL = 2'b00,
    CHI5PC_EXCL_OK           = 2'b01,
    CHI5PC_DATA_ERR          = 2'b10,
    CHI5PC_NON_DATA_ERR      = 2'b11
  } eChi5PCRespErr;


  // Enum: eChi5PCSize
  // Defines the possible encodings for a Chi5 request size.
  //
  //   SIZE_1B  - Request is 1 bytes
  //   SIZE_2B  - Request is 2 bytes
  //   SIZE_4B  - Request is 4 bytes
  //   SIZE_8B  - Request is 8 bytes
  //   SIZE_16B - Request is 16 bytes
  //   SIZE_32B - Request is 32 bytes
  //   SIZE_64B - Request is 64 bytes
  typedef enum bit [2:0] {
    CHI5PC_SIZE_1B  = `CHI5PC_SIZE1B,
    CHI5PC_SIZE_2B  = `CHI5PC_SIZE2B,
    CHI5PC_SIZE_4B  = `CHI5PC_SIZE4B,
    CHI5PC_SIZE_8B  = `CHI5PC_SIZE8B,
    CHI5PC_SIZE_16B = `CHI5PC_SIZE16B,
    CHI5PC_SIZE_32B = `CHI5PC_SIZE32B,
    CHI5PC_SIZE_64B = `CHI5PC_SIZE64B
  } eChi5PCSize;

  typedef enum bit[3:0] {
     CHI5PC_Qos_0 = 0,
     CHI5PC_Qos_1 = 1,
     CHI5PC_Qos_2 = 2,
     CHI5PC_Qos_3 = 3,
     CHI5PC_Qos_4 = 4,
     CHI5PC_Qos_5 = 5,
     CHI5PC_Qos_6 = 6,
     CHI5PC_Qos_7 = 7,
     CHI5PC_Qos_8 = 8,
     CHI5PC_Qos_9 = 9,
     CHI5PC_Qos_10 = 10,
     CHI5PC_Qos_11 = 11,
     CHI5PC_Qos_12 = 12,
     CHI5PC_Qos_13 = 13,
     CHI5PC_Qos_14 = 14,
     CHI5PC_Qos_15 = 15
  } eChi5PCQoS;

  typedef enum bit {
     CHI5PC_SECURE = 0,
     CHI5PC_NON_SECURE = 1
  } eChi5PCNS;

  typedef enum bit {
     CHI5PC_STATIC  = 0,
     CHI5PC_DYNAMIC = 1
  } eChi5PCDynPCrd;

  typedef enum bit {
     CHI5PC_NORMAL = 0,
     CHI5PC_EXCL   = 1
  } eChi5PCExcl;

  
  typedef enum {CHI5PC_RN,CHI5PC_SLV,CHI5PC_SNP} eChi5PCTransType;
