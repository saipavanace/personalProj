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
//  File Revision       : 178982
//
//  Date                :  2014-08-20 10:02:17 +0100 (Wed, 20 Aug 2014)
//
//  Release Information : BP066-BU-01000-r0p0-00lac0
//
//------------------------------------------------------------------------------
//  Purpose             : This is the Chi5 protocol checker Chi5 interface.
//                          
//----------------------------------------------------------------------------
// CONTENTS
// ========
//  39.  Module: Chi5PC_if
//  47.    1) Parameters
//  88.    2) typedefs
// 217.    3) Chi5 Signals
// 279.    4) Functions
// 539.    5) File reader helper modport
// 587.    6) End of module
//----------------------------------------------------------------------------

//------------------------------------------------------------------------------
// INDEX: Module: Chi5PC_if
//------------------------------------------------------------------------------
`ifndef Chi5PC_if
  `define Chi5PC_if
  `include "Chi5PC_Chi5_defines.v"
interface Chi5PC_if (
  SRESETn,
  TXREQFLITV,
  TXREQFLIT,
  TXREQLCRDV,
  RXREQFLITV,
  RXREQFLIT,
  RXREQLCRDV,
  TXDATFLITV,
  TXDATFLIT,
  TXDATLCRDV,
  RXDATFLITV,
  RXDATFLIT,
  RXDATLCRDV,
  //TXSNPFLITV,
  //TXSNPFLIT,
  //TXSNPLCRDV,
  RXSNPFLITV,
  RXSNPFLIT,
  RXSNPLCRDV,
  TXRSPFLITV,
  TXRSPFLIT,
  TXRSPLCRDV,
  RXRSPFLITV,
  RXRSPFLIT,
  RXRSPLCRDV,
  TXLINKACTIVEREQ,
  TXLINKACTIVEACK,
  RXLINKACTIVEREQ,
  RXLINKACTIVEACK,
  TXREQFLITPEND,
  RXREQFLITPEND,
  TXRSPFLITPEND,
  RXRSPFLITPEND,
  TXDATFLITPEND,
  RXDATFLITPEND,
  //TXSNPFLITPEND,
  RXSNPFLITPEND,
  TXSACTIVE,
  RXSACTIVE
);
import Chi5PC_pkg::*;
//------------------------------------------------------------------------------
// INDEX:   1) Parameters
//------------------------------------------------------------------------------

  parameter MAX_OS_REQ = 8;
  parameter MAX_OS_SNP = 16;
  parameter MAX_OS_EXCL = 8;
  parameter REQ_RSVDC_WIDTH = 4;
  parameter DAT_RSVDC_WIDTH = 4;
  parameter DAT_FLIT_WIDTH = `CHI5PC_128B_DAT_FLIT_WIDTH;
  parameter eChi5PCDevType NODE_TYPE = RNF;
  parameter int NODE_ID = 0;

  parameter numChi5nodes = 4 ;
  localparam eChi5PCDevType tmp1[1:numChi5nodes] = '{numChi5nodes{RNF}};
  parameter eChi5PCDevType  devQ[1:numChi5nodes]  = tmp1;
  localparam int tmp2[1:numChi5nodes] = '{numChi5nodes{0}};
  parameter int nodeIdQ [1:numChi5nodes] = tmp2 ;
  parameter MAXLLCREDITS = 16;
  parameter MAXLLCREDITS_IN_RXDEACTIVATE = MAXLLCREDITS; // Per sender maximum protocol credits sent 

  localparam int MAX_OS_TX = MAX_OS_REQ;
  localparam int MAXLLCREDITS_MAX_WIDTH = clogb2(MAXLLCREDITS);
  localparam CHI5PC_DAT_FLIT_DATA_MSB = 
    DAT_FLIT_WIDTH == `CHI5PC_128B_DAT_FLIT_WIDTH ? `CHI5PC_128B_DAT_FLIT_DATA_MSB : 
    DAT_FLIT_WIDTH == `CHI5PC_256B_DAT_FLIT_WIDTH ? `CHI5PC_256B_DAT_FLIT_DATA_MSB : 
    DAT_FLIT_WIDTH == `CHI5PC_512B_DAT_FLIT_WIDTH ? `CHI5PC_512B_DAT_FLIT_DATA_MSB : `CHI5PC_128B_DAT_FLIT_DATA_MSB; 
  localparam CHI5PC_DAT_FLIT_DATA_LSB = 
    DAT_FLIT_WIDTH == `CHI5PC_128B_DAT_FLIT_WIDTH ? `CHI5PC_128B_DAT_FLIT_DATA_LSB : 
    DAT_FLIT_WIDTH == `CHI5PC_256B_DAT_FLIT_WIDTH ? `CHI5PC_256B_DAT_FLIT_DATA_LSB : 
    DAT_FLIT_WIDTH == `CHI5PC_512B_DAT_FLIT_WIDTH ? `CHI5PC_512B_DAT_FLIT_DATA_LSB : `CHI5PC_128B_DAT_FLIT_DATA_LSB; 
  localparam CHI5PC_DAT_FLIT_BE_MSB =                                                         
    DAT_FLIT_WIDTH == `CHI5PC_128B_DAT_FLIT_WIDTH ? `CHI5PC_128B_DAT_FLIT_BE_MSB : 
    DAT_FLIT_WIDTH == `CHI5PC_256B_DAT_FLIT_WIDTH ? `CHI5PC_256B_DAT_FLIT_BE_MSB : 
    DAT_FLIT_WIDTH == `CHI5PC_512B_DAT_FLIT_WIDTH ? `CHI5PC_512B_DAT_FLIT_BE_MSB : `CHI5PC_128B_DAT_FLIT_BE_MSB; 
  localparam CHI5PC_DAT_FLIT_BE_LSB =                                                         
    DAT_FLIT_WIDTH == `CHI5PC_128B_DAT_FLIT_WIDTH ? `CHI5PC_128B_DAT_FLIT_BE_LSB : 
    DAT_FLIT_WIDTH == `CHI5PC_256B_DAT_FLIT_WIDTH ? `CHI5PC_256B_DAT_FLIT_BE_LSB : 
    DAT_FLIT_WIDTH == `CHI5PC_512B_DAT_FLIT_WIDTH ? `CHI5PC_512B_DAT_FLIT_BE_LSB : `CHI5PC_128B_DAT_FLIT_BE_LSB; 
  localparam CHI5PC_DAT_FLIT_BE_WIDTH =                                                       
    DAT_FLIT_WIDTH == `CHI5PC_128B_DAT_FLIT_WIDTH ? `CHI5PC_128B_DAT_FLIT_BE_WIDTH : 
    DAT_FLIT_WIDTH == `CHI5PC_256B_DAT_FLIT_WIDTH ? `CHI5PC_256B_DAT_FLIT_BE_WIDTH : 
    DAT_FLIT_WIDTH == `CHI5PC_512B_DAT_FLIT_WIDTH ? `CHI5PC_512B_DAT_FLIT_BE_WIDTH : `CHI5PC_128B_DAT_FLIT_BE_WIDTH; 

  localparam CHI5PC_DATA_WIDTH = 
    DAT_FLIT_WIDTH == `CHI5PC_128B_DAT_FLIT_WIDTH ? `CHI5PC_128B_DAT_FLIT_DATA_WIDTH : 
    DAT_FLIT_WIDTH == `CHI5PC_256B_DAT_FLIT_WIDTH ? `CHI5PC_256B_DAT_FLIT_DATA_WIDTH : 
    DAT_FLIT_WIDTH == `CHI5PC_512B_DAT_FLIT_WIDTH ? `CHI5PC_512B_DAT_FLIT_DATA_WIDTH : `CHI5PC_128B_DAT_FLIT_DATA_WIDTH; 



  localparam int this_nodeIndex =  get_nodeIndex(NODE_ID);
//------------------------------------------------------------------------------
// INDEX:   2) typedefs
//------------------------------------------------------------------------------


  typedef union packed{
    logic [63:0] full_BE;
    logic [3:0] [15:0] BE;
    }BE_union;
  typedef struct packed {
      logic L;
      logic [`CHI5PC_REQ_FLIT_ADDR_DVM_S2S1_RANGE] S2S1;
      logic [`CHI5PC_REQ_FLIT_ADDR_DVM_ASID_RANGE] ASID;
      logic [`CHI5PC_REQ_FLIT_ADDR_DVM_VMID_RANGE] VMID;
      eChi5PCDvmType Type;
      eChi5PCDvmHyp Hyp;
      eChi5PCDvmNs NS;
      logic ASID_Valid;
      logic VMID_Valid;
      logic VA_Valid;
      logic Partnum;
      }snpDVM_ADDR_struct;
  typedef struct packed {
      logic [2:0] addr43_41;
      logic L;
      logic [`CHI5PC_REQ_FLIT_ADDR_DVM_S2S1_RANGE] S2S1;
      logic [`CHI5PC_REQ_FLIT_ADDR_DVM_ASID_RANGE] ASID;
      logic [`CHI5PC_REQ_FLIT_ADDR_DVM_VMID_RANGE] VMID;
      eChi5PCDvmType Type;
      eChi5PCDvmHyp Hyp;
      eChi5PCDvmNs NS;
      logic ASID_Valid;
      logic VMID_Valid;
      logic VA_Valid;
      logic Partnum;
      logic [2:0] reqDVM_ADDR2_0_RSVD0;
      }reqDVM_ADDR_struct;
  typedef union packed{
    reqDVM_ADDR_struct REQ_DVM;
    logic [43:0] Addr43_0;
    }REQAddr_union;
  typedef struct packed {
     logic [3:0] Exp_DATID;
     logic [3:0] DATID;
     logic [1:0] CCID;
     BE_union Exp_BE ;
     logic [3:0] RspOpCode1;
     logic [3:0] RspOpCode2;
     logic CompAck;
     logic [`CHI5PC_RSP_FLIT_DBID_WIDTH-1:0] DBID;
     logic [`CHI5PC_REQ_FLIT_PCRDTYPE_WIDTH-1:0]PCrdType;
     logic ExpCompAck;
     eChi5PCExcl Excl;
     logic [2:0] LPID;
     logic LikelyShared;
     eChi5PCOrder Order;
     eChi5PCDynPCrd DynPCrd;
     eChi5PCNS NS;
     REQAddr_union Addr;
     eChi5PCSize Size;
     eChi5PCReqOp OpCode;
     eChi5PCQoS QoS;
     logic [1:MAX_OS_TX] Previous;//max requests
     logic [`CHI5PC_REQ_FLIT_TXNID_WIDTH-1:0] TxnID;
     logic [`CHI5PC_REQ_FLIT_TGTID_WIDTH-1:0] TgtID;
     logic [`CHI5PC_REQ_FLIT_TGTID_WIDTH-1:0] TgtID_rmp;
     logic [`CHI5PC_REQ_FLIT_SRCID_WIDTH-1:0] SrcID;
     logic [`CHI5PC_REQ_FLIT_SNPATTR_WIDTH-1:0] SnpAttr;
     logic [`CHI5PC_REQ_FLIT_MEMATTR_WIDTH-1:0] MemAttr;
     logic [`CHI5PC_DAT_FLIT_RESP_WIDTH-1:0] DATResp;
     logic [`CHI5PC_DAT_FLIT_RESPERR_WIDTH-1:0] DATRespErr;
     logic in_Retry;

  } Chi5PC_Info;
  typedef struct packed {
     logic [`CHI5PC_REQ_FLIT_ADDR_WIDTH-1:0] Addr;
     logic [`CHI5PC_REQ_FLIT_SRCID_WIDTH-1:0] SrcID;
     logic [`CHI5PC_REQ_FLIT_TGTID_WIDTH-1:0] TgtID;
     logic [`CHI5PC_REQ_FLIT_TGTID_WIDTH-1:0] TgtID_rmp;
     logic [`CHI5PC_REQ_FLIT_LPID_WIDTH-1:0] LPID;
     logic [`CHI5PC_REQ_FLIT_TXNID_WIDTH-1:0] TxnID;
     BE_union Exp_BE ;
     eChi5PCSize Size;
     eChi5PCNS NS;
     logic LikelyShared;
     logic [`CHI5PC_REQ_FLIT_SNPATTR_WIDTH-1:0] SnpAttr;
     logic [`CHI5PC_REQ_FLIT_MEMATTR_WIDTH-2:0] MemAttr;
     logic LDEX_fail;
     logic LDEX_comp;
     logic STREX_fail;
     logic in_LDEX;
     logic in_STREX;
     logic interim_write;
     logic Snoopable;
  } Chi5PC_Excl_Info;
  typedef struct packed {
     Chi5PC_Info [1:8] Info;
  }Chi5PC_Info_Cam;
  typedef struct packed {
     logic [1:0] DVMPart;
     logic [1:numChi5nodes] [3:0] DATID ; 
     logic [1:numChi5nodes] [1:0] RespErr ;
     logic [1:numChi5nodes] [2:0] Resp ;
     logic [1:numChi5nodes] Rcvd_RSP;
     logic [1:numChi5nodes] Expect_RSP;
     snpDVM_ADDR_struct Addr;
     eChi5PCNS NS;
     logic [43:3] Addr43_3;
     eChi5PCSnpOp OpCode;
     eChi5PCDatOp DatOpCode;
     logic [`CHI5PC_RSP_FLIT_DBID_WIDTH-1:0] DBID;
     eChi5PCQoS QoS;
     logic [1:MAX_OS_SNP] Previous;//max os snps
     logic [`CHI5PC_SNP_FLIT_TXNID_WIDTH-1:0] TxnID;
     eChi5PCSize Size;
     logic [`CHI5PC_SNP_FLIT_SRCID_WIDTH-1:0] SrcID;
  } Chi5PC_SNP_Info;

  typedef struct packed {
     eChi5PCReqOp OpCode;
     logic PCrdGrnt;
     logic [6:0] Ref_ID;
     logic [`CHI5PC_SNP_FLIT_TXNID_WIDTH-1:0] TxnID;
     logic Retried;
     logic [`CHI5PC_REQ_FLIT_PCRDTYPE_WIDTH-1:0]PCrdType;
  } Chi5PC_Ret_Crdgnt_Info;

 // Packed Structure for Chi5 Flit so that we can easily expand the fields in Waves and understand about the Flit
  // Request VC flit (REQ)
  typedef struct packed {
       logic [REQ_RSVDC_WIDTH-1:0] RSVDC;
       logic ExpCompAck;
       eChi5PCExcl Excl;
       logic [`CHI5PC_REQ_FLIT_LPID_WIDTH-1:0] LPID;
       logic [`CHI5PC_REQ_FLIT_SNPATTR_WIDTH-1:0] SnpAttr;
       logic [`CHI5PC_REQ_FLIT_MEMATTR_WIDTH-1:0] MemAttr;
       logic [`CHI5PC_REQ_FLIT_PCRDTYPE_WIDTH-1:0] PCrdType;
       eChi5PCOrder Order;
       eChi5PCDynPCrd DynPCrd;
       bit LikelyShared;
       eChi5PCNS NS;
       logic [`CHI5PC_REQ_FLIT_ADDR_WIDTH-1:0] Addr;
       eChi5PCSize Size;
       eChi5PCReqOp Opcode;
       logic [`CHI5PC_REQ_FLIT_TXNID_WIDTH-1:0] TxnId;
       logic [`CHI5PC_REQ_FLIT_SRCID_WIDTH-1:0] SrcId;
       logic [`CHI5PC_REQ_FLIT_TGTID_WIDTH-1:0] TgtId;
       eChi5PCQoS QoS;
    } Chi5PCReqFlit;

  // Response VC flit (RSP)
  typedef struct packed {
     logic [`CHI5PC_RSP_FLIT_PCRDTYPE_WIDTH-1:0] PCrdType;
     logic [`CHI5PC_RSP_FLIT_DBID_WIDTH-1:0] DbId;
     logic [`CHI5PC_RSP_FLIT_RESP_WIDTH-1:0] Resp;
     eChi5PCRespErr RespErr;
     eChi5PCRspOp Opcode;
     logic [`CHI5PC_RSP_FLIT_TXNID_WIDTH-1:0] TxnId;
     logic [`CHI5PC_RSP_FLIT_SRCID_WIDTH-1:0] SrcId;
     logic [`CHI5PC_RSP_FLIT_TGTID_WIDTH-1:0] TgtId;
     eChi5PCQoS QoS;
  } Chi5PCRspFlit;

  // Snoop VC flit (SNP)
  typedef struct packed {
     logic NS;
     logic [`CHI5PC_SNP_FLIT_ADDR_WIDTH-1:0] Addr;
     eChi5PCSnpOp Opcode;
     logic [`CHI5PC_SNP_FLIT_TXNID_WIDTH-1:0] TxnId;
     logic [`CHI5PC_SNP_FLIT_SRCID_WIDTH-1:0] SrcId;
     eChi5PCQoS QoS;
  } Chi5PCSnpFlit;

  // Data VC flit (DAT)
  typedef struct packed {
     logic [CHI5PC_DATA_WIDTH-1:0] Data;
     logic [CHI5PC_DAT_FLIT_BE_WIDTH-1:0] BE;
     logic [DAT_RSVDC_WIDTH-1:0] RSVDC;
     logic [`CHI5PC_DAT_FLIT_DATAID_WIDTH-1:0] DataId;
     logic [`CHI5PC_DAT_FLIT_CCID_WIDTH-1:0] CcId;
     logic [`CHI5PC_DAT_FLIT_DBID_WIDTH-1:0] DbId;
     logic [`CHI5PC_DAT_FLIT_RESP_WIDTH-1:0] Resp;
     eChi5PCRespErr RespErr;
     eChi5PCDatOp Opcode;
     logic [`CHI5PC_DAT_FLIT_TXNID_WIDTH-1:0] TxnId;
     logic [`CHI5PC_DAT_FLIT_SRCID_WIDTH-1:0] SrcId;
     logic [`CHI5PC_DAT_FLIT_TGTID_WIDTH-1:0] TgtId;
     eChi5PCQoS QoS;
  } Chi5PCDatFlit;


//------------------------------------------------------------------------------
// INDEX:   3) Chi5 Signals
//------------------------------------------------------------------------------

  input SRESETn;
  input TXREQFLITV;
  input [`CHI5PC_REQ_FLIT_RANGE] TXREQFLIT;
  input TXREQLCRDV;
  input RXREQFLITV;
  input [`CHI5PC_REQ_FLIT_RANGE] RXREQFLIT;
  input RXREQLCRDV;
  input TXDATFLITV;
  input [DAT_FLIT_WIDTH-1:0] TXDATFLIT;
  input TXDATLCRDV;
  input RXDATFLITV;
  input [DAT_FLIT_WIDTH-1:0] RXDATFLIT;
  input RXDATLCRDV;
//  input  TXSNPFLITV;
//  input [`CHI5PC_SNP_FLIT_RANGE] TXSNPFLIT;
//  input TXSNPLCRDV;
  input RXSNPFLITV;
  input [`CHI5PC_SNP_FLIT_RANGE] RXSNPFLIT;
  input RXSNPLCRDV;
  input TXRSPFLITV;
  input [`CHI5PC_RSP_FLIT_RANGE] TXRSPFLIT;
  input TXRSPLCRDV;
  input RXRSPFLITV;
  input [`CHI5PC_RSP_FLIT_RANGE] RXRSPFLIT;
  input RXRSPLCRDV;
  input TXLINKACTIVEREQ;
  input TXLINKACTIVEACK;
  input RXLINKACTIVEREQ;
  input RXLINKACTIVEACK;
  input TXREQFLITPEND;
  input RXREQFLITPEND;
  input TXRSPFLITPEND;
  input RXRSPFLITPEND;
  input TXDATFLITPEND;
  input RXDATFLITPEND;
//  input TXSNPFLITPEND;
  input RXSNPFLITPEND;
  input TXSACTIVE;
  input RXSACTIVE;

  logic  TXSNPFLITV;
  logic [`CHI5PC_SNP_FLIT_RANGE] TXSNPFLIT;
  logic TXSNPLCRDV;
  logic TXSNPFLITPEND;
  logic [31:0] BroadcastVector;

  Chi5PCReqFlit STRUCT_TXREQFLIT;
  assign STRUCT_TXREQFLIT = TXREQFLIT;
  Chi5PCReqFlit STRUCT_RXREQFLIT;
  assign STRUCT_RXREQFLIT = RXREQFLIT;
  Chi5PCRspFlit STRUCT_TXRSPFLIT;
  assign STRUCT_TXRSPFLIT = TXRSPFLIT;
  Chi5PCRspFlit STRUCT_RXRSPFLIT ;
  assign STRUCT_RXRSPFLIT = RXRSPFLIT;
  Chi5PCSnpFlit STRUCT_TXSNPFLIT;
  assign STRUCT_TXSNPFLIT = TXSNPFLIT;
  Chi5PCSnpFlit STRUCT_RXSNPFLIT;
  assign STRUCT_RXSNPFLIT = RXSNPFLIT;
  Chi5PCDatFlit STRUCT_RXDATFLIT;
  assign STRUCT_RXDATFLIT = RXDATFLIT;
  Chi5PCDatFlit STRUCT_TXDATFLIT;
  assign STRUCT_TXDATFLIT = TXDATFLIT;

//------------------------------------------------------------------------------
// INDEX:   4) Functions
//------------------------------------------------------------------------------

  function [8:0] get_stripe_index(logic [1:MAX_OS_REQ] stripe);
    begin
      for (int i = 1; i<=MAX_OS_REQ ; i++)
      if (stripe[i])
        return i;
    end
  endfunction

  function  has_HNF(Chi5PC_pkg::eChi5PCDevType nodeType);
    begin
      has_HNF =  ((nodeType == HNF) || (nodeType == HNF_MN) || (nodeType == HNF_HNI) || (nodeType == HNF_HNI_MN) );
    end
  endfunction

  function has_HNI(eChi5PCDevType nodeType);
    begin
      has_HNI = ((nodeType == HNI) || (nodeType == HNI_MN) || (nodeType == HNF_HNI) || (nodeType == HNF_HNI_MN) );
    end
  endfunction

  function has_MN(eChi5PCDevType nodeType);
    begin
      has_MN = ((nodeType == MN) || (nodeType == HNI_MN) || (nodeType == HNF_MN) || (nodeType == HNF_HNI_MN) );
    end
  endfunction

  function eChi5PCDevType get_NodeType(logic[6:0] nodeId);
    begin
      for (int i = 1; i<= numChi5nodes; i++)
      if (nodeIdQ[i] == nodeId)
        return devQ[i];
    end
  endfunction

  function logic[6:0] get_nodeIndex(int nodeID);
    begin
      for (int i = 1; i<= numChi5nodes; i++)
      if (nodeIdQ[i] == nodeID)
         return i;
    end
  endfunction

  function logic NODE_exists(int nodeID);
    begin
      NODE_exists = 1'b0;
      for(int i = 1; i <= numChi5nodes; i++)
      begin
        if (nodeIdQ[i] == nodeID)
        begin
          NODE_exists = 1'b1;
        end
      end
    end
  endfunction

  function logic is_RN(int nodeID);
    begin
      is_RN = 1'b0;
      for(int i = 1; i <= numChi5nodes; i++)
      begin
        if (nodeIdQ[i] == nodeID && ((devQ[i] == RNF) || (devQ[i] == RNI) || (devQ[i] == RND)))
        begin
          is_RN = 1'b1;
        end
      end
    end
  endfunction
  function BE_union Expect_BE (input bit[5:0] addr_, 
    input logic device_,
    input bit[2:0] size_);
                                   
    logic [63:0] size_mask;
    logic [5:0] align_mask; 
    logic [6:0] upper_boundary ;
    logic [63:0] upper_boundary_mask ;
    logic [5:0] aligned_address;
    logic [63:0] return_value;
    int tx_bytes;
    tx_bytes = 1 << size_;
    size_mask = (size_ == 3'b000  ? 64'h00000001 : //1B
                (size_ == 3'b001  ? 64'h00000003 : //2B   
                (size_ == 3'b010  ? 64'h0000000F : //4B
                (size_ == 3'b011  ? 64'h000000FF : //8B
                (size_ == 3'b100  ? 64'h0000FFFF : //16B
                (size_ == 3'b101  ? 64'hFFFFFFFF : //32B
                (size_ == 3'b110  ? 64'hFFFFFFFFFFFFFFFF :64'h0  )))))));//64B

    align_mask =  6'b111111  << size_;
    aligned_address =  addr_ & align_mask;
    upper_boundary = aligned_address + tx_bytes ;
    upper_boundary_mask = ~(64'hFFFFFFFFFFFFFFFF << upper_boundary);
    if (device_)
    begin
     return (size_mask << unsigned'(addr_)) & upper_boundary_mask ;
    end
    else
    begin
     return size_mask << aligned_address;
    end
  endfunction

  //Create a vector of the expected data beats
  function logic [3:0] Expect_DATAID(input Chi5PCReqFlit Req);
    logic [3:0] databus_width_bytes_;
    logic [10:0] addr_mask_;
    logic [1:0] shift;
    begin
      if (Req.Opcode == `CHI5PC_CLEANSHARED ||
          Req.Opcode == `CHI5PC_CLEANINVALID ||
          Req.Opcode == `CHI5PC_MAKEINVALID ||
          Req.Opcode == `CHI5PC_CLEANUNIQUE ||
          Req.Opcode == `CHI5PC_MAKEUNIQUE ||
          Req.Opcode == `CHI5PC_EOBARRIER ||
          Req.Opcode == `CHI5PC_ECBARRIER ||
          Req.Opcode == `CHI5PC_EVICT ||
          Req.Opcode == `CHI5PC_DVMOP
        )
      begin
          return 4'b0000;
      end
      if (Req.Opcode == `CHI5PC_READONCE ||
          Req.Opcode == `CHI5PC_READNOSNP ||
          Req.Opcode == `CHI5PC_WRITENOSNPPTL || 
          Req.Opcode == `CHI5PC_WRITEUNIQUEPTL 
          )
      begin
        case (DAT_FLIT_WIDTH)
          `CHI5PC_128B_DAT_FLIT_WIDTH:
          begin
            databus_width_bytes_ = 16;
            case (Req.Size)
              `CHI5PC_SIZE1B,`CHI5PC_SIZE2B,`CHI5PC_SIZE4B,`CHI5PC_SIZE8B, `CHI5PC_SIZE16B:
                begin
                  shift = Req.Addr[5:4];
                  return 4'b0001 << shift;
                end
              `CHI5PC_SIZE32B :
                begin
                  shift = {Req.Addr[5],1'b0};
                  return 4'b0011 << shift;
                end
              `CHI5PC_SIZE64B :
                return 4'b1111;
            endcase
          end
          `CHI5PC_256B_DAT_FLIT_WIDTH:
          begin
            databus_width_bytes_ = 32;
            case (Req.Size)
              `CHI5PC_SIZE1B,`CHI5PC_SIZE2B,`CHI5PC_SIZE4B,`CHI5PC_SIZE8B, `CHI5PC_SIZE16B,`CHI5PC_SIZE32B:
                return {(Req.Addr[5]),(Req.Addr[5]),!(Req.Addr[5]),!(Req.Addr[5])};
              `CHI5PC_SIZE64B :
                return 4'b1111;
            endcase
          end
          `CHI5PC_512B_DAT_FLIT_WIDTH:
          begin
            databus_width_bytes_ = 64;
                return 4'b1111;
          end
        endcase
      end
      else
      begin
          return 4'b1111;
      end
    end
  endfunction

  function logic [1:0] Next_DATID(input Chi5PC_Info Info);
    logic [1:0] result;
    begin
      result = 2'b00;
      if (~|Info.DATID)
      begin
        case (DAT_FLIT_WIDTH)
          `CHI5PC_128B_DAT_FLIT_WIDTH:
            result = Info.CCID;
          `CHI5PC_256B_DAT_FLIT_WIDTH:
            result = {Info.CCID[1],1'b0};
          default:
            result = 2'b00;
        endcase
      end
      else
      begin
        case (Info.Exp_DATID)
          4'b1111:
          begin
          case (DAT_FLIT_WIDTH)
            `CHI5PC_128B_DAT_FLIT_WIDTH:
              begin
                result = (Info.DATID[3] && !Info.DATID[0])? 2'b00 :
                         (Info.DATID[0] && !Info.DATID[1])? 2'b01 :
                         (Info.DATID[1] && !Info.DATID[2])? 2'b10 :
                          2'b11 ;
              end
            `CHI5PC_256B_DAT_FLIT_WIDTH:
              begin
                result = Info.DATID[0] ? 2'b10 : 2'b00 ;
              end
              default:
                result = 2'b00;
            endcase
          end
          4'b0011:
          begin
            //must be CHI5PC_128B_DAT_FLIT_WIDTH
            result = {1'b0,(Info.DATID[0])};
          end
          4'b1100:
          begin
            //must be CHI5PC_128B_DAT_FLIT_WIDTH
            result = {1'b1,(Info.DATID[2])};
          end
          4'b0101:
          begin
            //must be CHI5PC_256B_DAT_FLIT_WIDTH
            result = {(Info.DATID[0]), 1'b0} ;
          end
        endcase
      end
      return result;
    end
  endfunction
  function logic [1:0] Next_snpDATID(input bit[3:0] DATID, input bit[1:0] CCID);
    logic [1:0] result;
    begin
      result = 2'b00;
      case (DAT_FLIT_WIDTH)
        `CHI5PC_128B_DAT_FLIT_WIDTH:
        begin
          case (DATID)
            4'b0000:
            begin
              result =  CCID;
            end
            4'b1000,4'b1100,4'b1110:
            begin
              result = 2'b00 ;
            end
            4'b0001,4'b1001,4'b1101:
            begin
              result = 2'b01 ;
            end
            4'b0010,4'b0011,4'b1011:
            begin
              result = 2'b10 ;
            end
            4'b0100,4'b0110,4'b0111:
            begin
              result = 2'b11 ;
            end
          endcase
        end
        `CHI5PC_256B_DAT_FLIT_WIDTH:
        begin
          case (DATID)
            4'b0000:
            begin
              result = {CCID[1], 1'b0} ;
            end
            4'b0011:
            begin
              result = 2'b10 ;
            end
            4'b1100:
            begin
              result = 2'b00 ;
            end
          endcase
        end
        default:
        begin
          result = 2'b00 ;
        end
      endcase
      return result;
    end
  endfunction


  function logic overlapping(input logic[43:0] Addr1_, input logic device1_, input logic [2:0] size1_, 
                           input logic[43:0] Addr2_, input logic device2_, input logic [2:0] size2_);
    logic [43:6] Addr1_43_6;
    logic [43:6] Addr2_43_6;
    logic [5:0] Addr1_5_0;
    logic [5:0] Addr2_5_0;
    logic [63:0] full_BE1;
    logic [63:0] full_BE2;
    Addr1_43_6 = Addr1_[43:6];
    Addr2_43_6 = Addr2_[43:6];
    Addr1_5_0 = Addr1_[5:0];
    Addr2_5_0 = Addr2_[5:0];
    if (Addr1_43_6 == Addr2_43_6)
    begin
      full_BE1 = Expect_BE(Addr1_5_0,device1_,size1_);
      full_BE2 = Expect_BE(Addr2_5_0,device2_,size2_);
      if (|(full_BE1 & full_BE2))
        return 1'b1;
    end
    else
    begin
        return 1'b0;
    end
  endfunction

//------------------------------------------------------------------------------
// INDEX:   5) File reader helper modport
//------------------------------------------------------------------------------

   modport fr_if(
     import get_NodeType,
     output SRESETn,
     output TXSACTIVE,
     output RXSACTIVE,
     output TXLINKACTIVEREQ,
     output TXLINKACTIVEACK,
     output RXLINKACTIVEREQ,
     output RXLINKACTIVEACK,
     output TXREQFLITV,
     output TXREQFLIT,
     output TXREQLCRDV,
     output TXREQFLITPEND,
     output RXREQFLITV,
     output RXREQFLIT,
     output RXREQLCRDV,
     output RXREQFLITPEND,
     output TXDATFLITV,
     output TXDATFLIT,
     output TXDATLCRDV,
     output TXDATFLITPEND,
     output RXDATFLITV,
     output RXDATFLIT,
     output RXDATLCRDV,
     output RXDATFLITPEND,
     output TXSNPFLITV,
     output TXSNPFLIT,
     output TXSNPLCRDV,
     output TXSNPFLITPEND,
     output RXSNPFLITV,
     output RXSNPFLIT,
     output RXSNPLCRDV,
     output RXSNPFLITPEND,
     output TXRSPFLITV,
     output TXRSPFLIT,
     output TXRSPLCRDV,
     output TXRSPFLITPEND,
     output RXRSPFLITV,
     output RXRSPFLIT,
     output RXRSPLCRDV,
     output RXRSPFLITPEND
);


//------------------------------------------------------------------------------
// INDEX:   6) End of module
// ------------------------------------------------------------------------------

endinterface:Chi5PC_if 

`endif
